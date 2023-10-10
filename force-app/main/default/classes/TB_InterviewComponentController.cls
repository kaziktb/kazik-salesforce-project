/**
 * Created by jowitakozlak on 13/12/2021.
 */

public with sharing class TB_InterviewComponentController {
    public static Integer maxDaysInMonth = 31;
    public static Map<String, String> enMonthToPlMonth = new Map<String,String>{
        'January' => 'stycznia',
        'February' => 'lutego',
        'March' => 'marca',
        'April' => 'kwietnia',
        'May' => 'maja',
        'June' => 'czerwca',
        'July' => 'lipca',
        'August' => 'sierpnia',
        'September' => 'września',
        'October' => 'października',
        'November' => 'listopada',
        'December' => 'grudnia'
    };
    public static Map<String, String> enDayToPlDay = new Map<String,String>{
        'Monday' => 'poniedziałek',
        'Tuesday' => 'wtorek',
        'Wednesday' => 'środa',
        'Thursday' => 'czwartek',
        'Friday' => 'piątek',
        'Saturday' => 'sobota',
        'Sunday' => 'niedziela'
    };

    @AuraEnabled
    public static Boolean isDatetimePickerAvailable(String applicationId) {
        hed__Application__c app = [
            SELECT Id, TB_Qualification_Term__c
            FROM hed__Application__c
            WHERE Id = :applicationId
        ];
        return String.isBlank(app.TB_Qualification_Term__c);
    }

    @AuraEnabled
    public static String getInfoFromItem(String applicationId, String language) {
        try {
            hed__Application__c app = [
                SELECT Id, TB_Qualification__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            TB_Application_Qualification__c qualification = [
                SELECT Id, TB_Qualification_Description_EN__c, TB_Qualification_Description_PL__c
                FROM TB_Application_Qualification__c
                WHERE Id = :app.TB_Qualification__c
            ];
            return String.valueOf(qualification.get('TB_Qualification_Description_' + language + '__c'));
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static List<Integer> findDateWithClosestTerm (String applicationId) {

        try {
            hed__Application__c app = [
                SELECT Id, TB_Qualification__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            TB_Application_Qualification__c qualification = [
                SELECT Id, TB_Qualification_Requirement_Item__c
                FROM TB_Application_Qualification__c
                WHERE Id = :app.TB_Qualification__c
            ];

            List<TB_Qualification_Requirement_Item_Term__c> terms = [
                SELECT Id, TB_Start_Now_DST__c, TB_Date_Time_Available__c
                FROM TB_Qualification_Requirement_Item_Term__c
                WHERE TB_Qualification_Requirement_Item__c = :qualification.TB_Qualification_Requirement_Item__c
                AND TB_Date_Time_Visible__c = TRUE
                AND TB_Date_Time_Available__c = TRUE
                ORDER BY TB_Start_Now_DST__c
            ];

            List<Integer> closestDateParts = new List<Integer>();
            if (terms.size() > 0) {
                closestDateParts.add(terms[0].TB_Start_Now_DST__c.year());
                closestDateParts.add(terms[0].TB_Start_Now_DST__c.month());
                closestDateParts.add(terms[0].TB_Start_Now_DST__c.day());
            }

            if (!closestDateParts.isEmpty()) {
                return closestDateParts;
            } else {
                return null;
            }
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static List<TermsWrapper> getTermsByDay(String applicationId, String pickedDate,
        Integer formatHours, Integer formatMinutes, Integer formatSign) {
        List<String> dateParts = new List<String>();
        if (pickedDate.contains('/')) {
            dateParts = pickedDate.split('/');
        } else {
            dateParts = pickedDate.split('\\.');
        }
        Date pickedDateConverted = Date.newInstance(
            Integer.valueOf(dateParts[2]), //year
            Integer.valueOf(dateParts[1]),
            Integer.valueOf(dateParts[0])
        );
        List<Date> datesConverted = new List<Date>{
            pickedDateConverted,
            pickedDateConverted.addDays(1),
            pickedDateConverted.addDays(-1)
        };

        try {
            hed__Application__c app = [
                SELECT Id, TB_Qualification__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            TB_Application_Qualification__c qualification = [
                SELECT Id, TB_Qualification_Requirement_Item__c
                FROM TB_Application_Qualification__c
                WHERE Id = :app.TB_Qualification__c
            ];

            List<TB_Qualification_Requirement_Item_Term__c> terms = [
                SELECT Id, TB_Start_Now_DST__c, TB_Date_Time_Available__c
                FROM TB_Qualification_Requirement_Item_Term__c
                WHERE TB_Qualification_Requirement_Item__c = :qualification.TB_Qualification_Requirement_Item__c
                AND DAY_ONLY(TB_Start_Now_DST__c) IN :datesConverted
                AND TB_Date_Time_Visible__c = TRUE
                ORDER BY TB_Start_Now_DST__c
            ];

            Integer actualDay = pickedDateConverted.day();
            List<TermsWrapper> termsWrappers = new List<TermsWrapper>();
            for (TB_Qualification_Requirement_Item_Term__c term : terms) {
                if (term.TB_Start_Now_DST__c.addHours(formatHours*formatSign).addMinutes(formatMinutes*formatSign).day() == actualDay) {
                    TermsWrapper termsWrapper = new TermsWrapper(term, formatHours, formatMinutes, formatSign);
                    termsWrappers.add(termsWrapper);
                }
            }
            return termsWrappers;
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static List<TB_Admissions_Dictionary__c> getExamScopesFromBundle(String applicationId) {
        try {
            hed__Application__c app = [
                SELECT Id, TB_Qualification__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            TB_Application_Qualification__c qualification = [
                SELECT Id, TB_Qualification_Requirement_Item__r.TB_Exam_Scopes_Bundle__c
                FROM TB_Application_Qualification__c
                WHERE Id = :app.TB_Qualification__c
            ];
            List<TB_JSON_Wrapper__c> jsonWrappers = [
                SELECT Id, TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Record_Type_Dev_Name__c = 'TB_Exam_Scope'
                AND TB_Parent_JSON_Wrapper__r.TB_Object_Id__c = :qualification.TB_Qualification_Requirement_Item__r.TB_Exam_Scopes_Bundle__c
            ];

            Set<TB_Admissions_Dictionary__c> admissionsDictionaries = new Set<TB_Admissions_Dictionary__c>();
            for (TB_JSON_Wrapper__c jsonWrapper : jsonWrappers) {
                TB_Admissions_Dictionary__c admissionsDictionary = (TB_Admissions_Dictionary__c) JSON.deserialize(
                    jsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class
                );
                if (admissionsDictionary.TB_Active__c == true) {
                    admissionsDictionaries.add(admissionsDictionary);
                }
            }
            return new List<TB_Admissions_Dictionary__c>(admissionsDictionaries);
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String updateApplicationQualification(String applicationId, String dictionaryJSON, String contactId, Boolean isBooking) {
        try {
            Boolean userWasEnroll = false;
            hed__Application__c app = [
                SELECT Id, TB_Qualification__c, Name, hed__Applicant__r.Id
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            TB_Application_Qualification__c qualification = [
                SELECT Id, TB_Exam_Scope__c, TB_Exam_Scope_Description_EN__c, TB_Exam_Scope_Description_PL__c,
                    TB_Exam_Scope_Name_EN__c, TB_Exam_Scope_Name_PL__c, TB_Moodle_Exam_ID__c, TB_Moodle_Id__c
                FROM TB_Application_Qualification__c
                WHERE Id = :app.TB_Qualification__c
            ];
            TB_Admissions_Dictionary__c admissionsDictionary = (TB_Admissions_Dictionary__c) JSON.deserialize(
                dictionaryJSON, TB_Admissions_Dictionary__c.class
            );
            if (isBooking && qualification.TB_Moodle_Exam_ID__c != null) {
                Object integrationResult = createMoodleLink(qualification, app.hed__Applicant__r.Id, app.Name);
                if (integrationResult instanceof TB_Application_Qualification__c){
                    TB_Application_Qualification__c appQuaIntegrationResult = (TB_Application_Qualification__c)integrationResult;
                    for(String appQ : appQuaIntegrationResult.getPopulatedFieldsAsMap().keySet()){
                        qualification.put(appQ, appQuaIntegrationResult.get(appQ));
                    }
                    userWasEnroll = true;
                }
                if (integrationResult instanceof  AuraHandledException) {
                    throw (AuraHandledException)integrationResult;
                }
            }else{
                qualification.TB_Moodle_Exam_Started__c = false;
            }
            qualification.TB_Exam_Scope__c = admissionsDictionary.Id;
            qualification.TB_Exam_Scope_Description_EN__c = admissionsDictionary.TB_Description_EN__c;
            qualification.TB_Exam_Scope_Description_PL__c = admissionsDictionary.TB_Description_PL__c;
            qualification.TB_Exam_Scope_Name_EN__c = admissionsDictionary.TB_Display_Name_EN__c;
            qualification.TB_Exam_Scope_Name_PL__c = admissionsDictionary.TB_Display_Name_PL__c;
            update qualification;
            if (isBooking && userWasEnroll && qualification.TB_Moodle_Exam_ID__c != null) {
                TB_Application_Qualification__c appQua = [
                    SELECT
                        TB_Qualification_Available__c,
                        TB_Qualification_Available_From__c,
                        TB_Qualification_Available_To__c,
                        TB_Moodle_Username__c,
                        TB_Moodle_Exam_ID__c,
                        TB_Moodle_Password__c,
                        TB_Moodle_Id__c
                    FROM TB_Application_Qualification__c
                    WHERE ID = :qualification.Id
                ];
                Contact contact = [SELECT Email FROM Contact WHERE Id = :contactId];
            }
            return 'success';
        } catch(Exception e) {
            if (!e.getMessage().contains(TB_Constants.TB_AURA_ERROR_SEPARATOR)) {
                e = new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_InterviewComponentController.class.getName(), e.getStackTraceString(),applicationId));
            }
            throw  e;
        }
    }

    @AuraEnabled
    public static String updateTermAndApplication(String applicationId, String termId, Boolean change) {
        hed__Application__c application = [
            SELECT Id, TB_Qualification_Term__c
            FROM hed__Application__c
            WHERE Id = :applicationId
        ];
        TB_Qualification_Requirement_Item_Term__c term = [
            SELECT Id, TB_Date_Time_Available__c
            FROM TB_Qualification_Requirement_Item_Term__c
            WHERE Id = :termId
        ];
        if (term.TB_Date_Time_Available__c) {
            application.TB_Qualification_Term__c = term.Id;
            try {
                update application;
                return 'success';
            } catch(Exception e) {
                insert TB_LogUtils.registerLog(e);
                return null;
            }
        } else {
            return ''; //second stage control if term is already taken while booking
        }
    }

    @AuraEnabled
    public static List<String> getPickedTermConfirmation(String applicationId, Boolean isPl,
        Integer formatHours, Integer formatMinutes, Integer formatSign) {
        String hourText = '';
        String monthText = '';
        String dayText = '';
        try {
            hed__Application__c app = [
                SELECT Id, TB_Qualification_Term__c, TB_Qualification__r.TB_Exam_Scope__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            TB_Qualification_Requirement_Item_Term__c term = [
                SELECT Id, TB_Start_Now_DST__c, TB_Now_DST__c, TB_Location__c, TB_Location_Details__c
                FROM TB_Qualification_Requirement_Item_Term__c
                WHERE Id = :app.TB_Qualification_Term__c
            ];
            if (isPl) {
                hourText = ' godzina';
                monthText = enMonthToPlMonth.get(term.TB_Start_Now_DST__c.format('MMMM'));
                dayText = enDayToPlDay.get(term.TB_Start_Now_DST__c.format('EEEE'));
            } else {
                monthText = term.TB_Start_Now_DST__c.format('MMMM');
                dayText = term.TB_Start_Now_DST__c.format('EEEE');
            }
            return new List<String>{
                term.Id,
                term.TB_Start_Now_DST__c.addHours(formatHours*formatSign).addMinutes(formatMinutes*formatSign).format('dd \'' + monthText + '\' yyyy, \'' + dayText + ',' + hourText + '\' HH:mm'),
                String.valueOf(term.TB_Now_DST__c),
                term.TB_Location__c,
                term.TB_Location_Details__c,
                app.TB_Qualification__r.TB_Exam_Scope__c
            };
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String getDST() {
        Datetime now = System.now();
        //format returns values from 1 to 7, 7 being Sunday, we need Sunday to be 1
        Integer weekday = Integer.valueOf(now.format('u')) == 7 ? 1 : Integer.valueOf(now.format('u')) + 1;
        Integer dst;
        if (now.month() < 3 || now.month() > 10) {
            dst = 1;
        } else if (now.month() > 3 && now.month() < 10) {
            dst = 2;
        } else if (now.month() == 3) {
            dst = now.day() - weekday >= 24 ? 2 : 1;
        } else if (now.month() == 10) {
            dst = now.day() - weekday < 24 ? 2 : 1;
        } else {
            dst = 1;
        }
        return String.valueOf(dst);
    }

    @AuraEnabled
    public static List<String> getEmptyDates(String applicationId, String pickedDate,
        Integer formatHours, Integer formatMinutes, Integer formatSign) {
        List<String> dateParts = new List<String>();
        if (pickedDate.contains('/')) {
            dateParts = pickedDate.split('/');
        } else {
            dateParts = pickedDate.split('\\.');
        }
        Date pickedDateConverted = Date.newInstance(
            Integer.valueOf(dateParts[2]), //year
            Integer.valueOf(dateParts[1]),
            Integer.valueOf(dateParts[0])
        );
        List<Date> datesConverted = new List<Date>{
            pickedDateConverted,
            pickedDateConverted.addMonths(1),
            pickedDateConverted.addMonths(-1)
        };
        Integer year = Integer.valueOf(dateParts[2]);
        Integer month = Integer.valueOf(dateParts[1]);
        try {
            hed__Application__c app = [
                SELECT Id, TB_Qualification__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            TB_Application_Qualification__c qualification = [
                SELECT Id, TB_Qualification_Requirement_Item__c
                FROM TB_Application_Qualification__c
                WHERE Id = :app.TB_Qualification__c
            ];
            List<TB_Qualification_Requirement_Item_Term__c> terms = [
                SELECT Id, TB_Start_Now_DST__c, TB_Date_Time_Available__c
                FROM TB_Qualification_Requirement_Item_Term__c
                WHERE TB_Qualification_Requirement_Item__c = :qualification.TB_Qualification_Requirement_Item__c
                AND ((CALENDAR_MONTH(TB_Start_Now_DST__c) = :month AND CALENDAR_YEAR(TB_Start_Now_DST__c) = :year)
                OR (CALENDAR_MONTH(TB_Start_Now_DST__c) = :datesConverted[1].month() AND CALENDAR_YEAR(TB_Start_Now_DST__c) = :datesConverted[1].year())
                OR (CALENDAR_MONTH(TB_Start_Now_DST__c) = :datesConverted[2].month() AND CALENDAR_YEAR(TB_Start_Now_DST__c) = :datesConverted[2].year()))
                AND TB_Date_Time_Visible__c = TRUE
                ORDER BY TB_Start_Now_DST__c
            ];

            List<Integer> days = new List<Integer>();
            List<String> emptyDates = new List<String>();
            for (TB_Qualification_Requirement_Item_Term__c term : terms)
            {
                if (term.TB_Start_Now_DST__c.addHours(formatHours * formatSign).addMinutes(formatMinutes * formatSign).month() == month) {
                    days.add(term.TB_Start_Now_DST__c.addHours(formatHours * formatSign).addMinutes(formatMinutes * formatSign).day());
                }
            }
            for (Integer dayInMonth = 1; dayInMonth <= maxDaysInMonth; dayInMonth++) {
                if (!days.contains(dayInMonth)) {
                    String emptyDate;
                    if (month < 10) {
                        if (dayInMonth < 10) {
                            emptyDate = String.valueOf(year) + '-0' + String.valueOf(month) + '-0' + String.valueOf(dayInMonth);
                        } else {
                            emptyDate = String.valueOf(year) + '-0' + String.valueOf(month) + '-' + String.valueOf(dayInMonth);
                        }
                    } else {
                        if( dayInMonth < 10) {
                            emptyDate = String.valueOf(year) + '-' + String.valueOf(month) + '-0' + String.valueOf(dayInMonth);
                        } else {
                            emptyDate = String.valueOf(year) + '-' + String.valueOf(month) + '-' + String.valueOf(dayInMonth);
                        }
                    }
                    emptyDates.add(emptyDate);
                }
            }

            return emptyDates;
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String cancelBooking(String applicationId, String termId) {
        hed__Application__c app = new hed__Application__c(Id=applicationId);
        app.TB_Qualification_Term__c = null;
        try {
            update app;
            return 'success';
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public static Object createMoodleLink(TB_Application_Qualification__c appQua, String contactId, String appName){
        Contact contact = [SELECT FirstName, LastName, Email From Contact WHERE Id =: contactId];
        String courseId;
        if (appQua.TB_Moodle_Exam_ID__c.contains(TB_MoodleConstants.USER_ID)) {
            courseId = appQua.TB_Moodle_Exam_ID__c.split('=').get(1).split(TB_MoodleConstants.USER_USERNAME).get(0);
        }
        TB_MoodleWebService.WrapperClass wrapper = new TB_MoodleWebService.WrapperClass();
        wrapper.methodToken = appQua.TB_Moodle_Id__c != null? TB_MoodleConstants.FUNC_ENROL_USER :TB_MoodleConstants.FUNC_CREATE_AND_ENROL_USER;
        wrapper.appQualId = appQua.Id;
        wrapper.applicationName= appName;
        wrapper.firstname= contact.FirstName;
        wrapper.lastname= contact.LastName;
        wrapper.email= contact.Email;
        wrapper.courseId= courseId;
        wrapper.moodleUserId = appQua.TB_Moodle_Id__c;
        return TB_MoodleWebService.rightMoodleMethod(wrapper, null);
    }

    public class TermsWrapper
    {
        @AuraEnabled public TB_Qualification_Requirement_Item_Term__c term {get;set;}
        @AuraEnabled public String startTime {get;set;}

        public TermsWrapper(TB_Qualification_Requirement_Item_Term__c term, Integer formatHours, Integer formatMinutes, Integer formatSign)
        {
            this.term = term;
            String start = term.TB_Start_Now_DST__c.addHours(formatHours*formatSign).addMinutes(formatMinutes*formatSign).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            String hour = start.substringAfter('T').substringBefore(':');
            if (hour.length() == 1) {
                hour = '0' + hour;
            }
            String minute = start.substringAfter(':').substringBefore(':');
            if (minute.length() == 1) {
                minute = '0' + minute;
            }
            String second = start.substringAfterLast(':').substringBefore('Z');
            if (second.length() == 1) {
                second = '0' + second;
            }
            this.startTime = hour + ':' + minute + ':' + second;
        }
    }
}
public with sharing class TB_QualificationComponentController {

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
    private static final Date today = System.today();

    @AuraEnabled
    public static String getDatesAndTerms(
        String applicationId, Integer formatHours, Integer formatMinutes, Integer formatSign, Boolean isPl
    ) {
        try {
            hed__Application__c app = [
                SELECT Id, TB_Qualification__r.TB_Qualification_Requirement_Item__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            List<TB_Qualification_Requirement_Item_Term__c> terms = [
                SELECT Id, TB_Date__c, TB_Start_Now_DST__c
                FROM TB_Qualification_Requirement_Item_Term__c
                WHERE TB_Qualification_Requirement_Item__c = :app.TB_Qualification__r.TB_Qualification_Requirement_Item__c
                AND TB_Date_Time_Available__c = TRUE
                AND TB_Date__c >= :today
                ORDER BY TB_Start_Now_DST__c
            ];

            Set<Date> uniqueDates = new Set<Date>();
            for (TB_Qualification_Requirement_Item_Term__c term : terms) {
                uniqueDates.add(term.TB_Date__c);
            }
            List<DateWrapper> dateWrappers = new List<DateWrapper>();
            for (Date singleDate : uniqueDates) {
                DateWrapper dateWrapper = new DateWrapper(singleDate, isPl);
                for (TB_Qualification_Requirement_Item_Term__c term : terms) {
                    if (term.TB_Date__c == singleDate) {
                        TermWrapper termWrapper = new TermWrapper(term, formatHours, formatMinutes, formatSign);
                        dateWrapper.terms.add(termWrapper);
                    }
                }
                dateWrappers.add(dateWrapper);
            }
            return JSON.serialize(dateWrappers);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static Boolean isDatetimePickerAvailable(String applicationId) {
        try {
            hed__Application__c app = [
                SELECT Id, TB_Qualification_Term__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            return String.isBlank(app.TB_Qualification_Term__c);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
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
        } catch (Exception e) {
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
        } catch (Exception e) {
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
                //Moodle User is created in Flow
            } else {
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
        } catch (Exception e) {
            if (!e.getMessage().contains(TB_Constants.TB_AURA_ERROR_SEPARATOR)) {
                e = new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_InterviewComponentController.class.getName(), e.getStackTraceString(),applicationId));
            }
            throw  e;
        }
    }

    @AuraEnabled
    public static String updateApplication(String applicationId, String termId) {
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
            } catch (Exception e) {
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
                monthText = enMonthToPlMonth.get(term.TB_Start_Now_DST__c.addHours(formatHours*formatSign).addMinutes(formatMinutes*formatSign).format('MMMM'));
                dayText = enDayToPlDay.get(term.TB_Start_Now_DST__c.addHours(formatHours*formatSign).addMinutes(formatMinutes*formatSign).format('EEEE'));
            } else {
                monthText = term.TB_Start_Now_DST__c.addHours(formatHours*formatSign).addMinutes(formatMinutes*formatSign).format('MMMM');
                dayText = term.TB_Start_Now_DST__c.addHours(formatHours*formatSign).addMinutes(formatMinutes*formatSign).format('EEEE');
            }
            return new List<String>{
                term.Id,
                term.TB_Start_Now_DST__c.addHours(formatHours*formatSign).addMinutes(formatMinutes*formatSign).format('dd \'' + monthText + '\' yyyy, \'' + dayText + ',' + hourText + '\' HH:mm'),
                String.valueOf(term.TB_Now_DST__c),
                term.TB_Location__c,
                term.TB_Location_Details__c,
                app.TB_Qualification__r.TB_Exam_Scope__c
            };
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String getDST() {
        try {
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
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String cancelBooking(String applicationId) {
        hed__Application__c app = new hed__Application__c(Id=applicationId);
        app.TB_Qualification_Term__c = null;
        try {
            update app;
            return 'success';
        } catch (Exception e) {
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

    public class DateWrapper
    {
        @AuraEnabled public Date dateValue { get; set; }
        @AuraEnabled public String dateLabel { get; set; }
        @AuraEnabled public List<TermWrapper> terms { get; set; }

        public DateWrapper(Date dateValue, Boolean isPl) {
            this.dateValue = dateValue;
            this.terms = new List<TermWrapper>();

            this.dateLabel = ((Datetime) this.dateValue).format('d MMMM yyyy\', \'EEEE');
            if (isPl) {
                this.dateLabel = this.dateLabel
                    .replace(this.dateLabel.substringAfter(' ').substringBefore(' '),enMonthToPlMonth.get(this.dateLabel.substringAfter(' ').substringBefore(' ')))
                    .replace(this.dateLabel.substringAfter(', '),enDayToPlDay.get(this.dateLabel.substringAfter(', ')));
            }
        }
    }

    public class TermWrapper
    {
        @AuraEnabled public TB_Qualification_Requirement_Item_Term__c term { get;set; }
        @AuraEnabled public String startTime { get;set; }
        @AuraEnabled public String boxStyle { get;set; }

        public TermWrapper(
            TB_Qualification_Requirement_Item_Term__c term, Integer formatHours, Integer formatMinutes,
            Integer formatSign
        ) {
            this.term = term;
            this.boxStyle = '';
            String start = term.TB_Start_Now_DST__c.addHours(formatHours*formatSign).addMinutes(formatMinutes*formatSign).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            String hour = start.substringAfter('T').substringBefore(':');
            if (hour.length() == 1) {
                hour = '0' + hour;
            }
            String minute = start.substringAfter(':').substringBefore(':');
            if (minute.length() == 1) {
                minute = '0' + minute;
            }
            this.startTime = hour + ':' + minute;
        }
    }

}
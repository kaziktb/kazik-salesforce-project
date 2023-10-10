public with sharing class TB_LanguageCourseSelection {

    private static final Integer ZERO_VALUE = 0;

    @AuraEnabled(Cacheable = true)
    public static List<TB_Admissions_Dictionary__c> findLanguageCourses(String applicationId) {
        try {
        List<TB_Admissions_Dictionary__c> allActiveLanguageCourses = fetchAllActiveLanguageCourses();
        hed__Application__c application = [
                SELECT Name, TB_Applicant_Citizenship__c, TB_Applying_To_Offered_Product__c
                FROM hed__Application__c
                WHERE Id = :applicationId
        ];
        Map<Id, TB_Admissions_Dictionary__c> idToLanguageCourse = new Map<Id, TB_Admissions_Dictionary__c>(allActiveLanguageCourses);
        List<TB_Application_Qualification__c> qualifications = fetchLanguageTestQualifications(application);
            Decimal moodleTestResultPercent = (qualifications.size() == ZERO_VALUE)
                    ? ZERO_VALUE
                    : processQualificationTestResult(qualifications[0]);
        Set<TB_Admissions_Dictionary__c> matchedAssignmentsLanguageCourses = matchCoursesWithOfferedProduct(idToLanguageCourse, application);
        List<TB_Admissions_Dictionary__c> matchedLanguageCourses = new List<TB_Admissions_Dictionary__c>();
        for (TB_Admissions_Dictionary__c languageCourse : matchedAssignmentsLanguageCourses) {
            if (hasEnoughPoints(moodleTestResultPercent, languageCourse)
                    && matchesCitizenship(application, languageCourse)) {
                matchedLanguageCourses.add(languageCourse);
            }
        }
        return matchedLanguageCourses;
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_LanguageCourseSelection.class.getName(), e.getStackTraceString(), applicationId));
        }
    }

    public static Boolean hasCourses(Id applicationId) {
        return findLanguageCourses(applicationId).size() > 0;
    }

    private static Boolean hasEnoughPoints(Decimal moodleTestResultPercent, TB_Admissions_Dictionary__c languageCourse) {
        return moodleTestResultPercent != null
                && moodleTestResultPercent >= languageCourse.TB_Moodle_Test_Score_From__c
                && moodleTestResultPercent <= languageCourse.TB_Moodle_Test_Score_To__c;
    }

    private static List<TB_Application_Qualification__c> fetchLanguageTestQualifications(hed__Application__c application) {
        return [
                SELECT TB_Moodle_Test_Result_Percent__c
                FROM TB_Application_Qualification__c
                WHERE TB_Application__c = :application.Id
                AND TB_Qualification_Type__c = :TB_Constants.TB_APPLICATION_QUALIFICATION_TYPE_LANGUAGE_TEST
                AND TB_Active__c = TRUE
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
    }

    private static List<TB_Admissions_Dictionary__c> fetchAllActiveLanguageCourses() {
        List<TB_Admissions_Dictionary__c> languageCourses = new List<TB_Admissions_Dictionary__c>();
        for (TB_JSON_Wrapper__c wrapper : [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = :TB_Constants.TB_OBJECT_API_NAME_ADMISSIONS_DICTIONARY
                AND TB_Record_Type_Dev_Name__c = :TB_Constants.ADMISSIONS_DICTIONARY_RT_LANGUAGE_COURSE_DEVNAME
        ]) {
            TB_Admissions_Dictionary__c languageCourse = (TB_Admissions_Dictionary__c) JSON.deserialize(wrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if (languageCourse.TB_Active__c) {
                languageCourses.add(languageCourse);
            }
        }
        return languageCourses;
    }

    private static Decimal processQualificationTestResult(TB_Application_Qualification__c qualification) {
        String testResult = qualification.TB_Moodle_Test_Result_Percent__c;
        if (String.isBlank(testResult)) {
            return ZERO_VALUE;
        }
        Decimal resultDecimalValue;
        String normalizedResult = testResult.replaceAll('[\\s%]', '').replaceAll(',', '.');
        try {
            resultDecimalValue = Decimal.valueOf(normalizedResult);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            resultDecimalValue = ZERO_VALUE;
        }
        return resultDecimalValue;
    }

    private static Boolean matchesCitizenship(hed__Application__c application, TB_Admissions_Dictionary__c languageCourse) {
        return !String.isBlank(languageCourse.TB_Citizenships__c)
                && !String.isBlank(application.TB_Applicant_Citizenship__c)
                && (languageCourse.TB_Citizenships__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_EVERYONE
                || languageCourse.TB_Citizenships__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_POLISH_CITIZENS && isPolishCitizen(application)
                || languageCourse.TB_Citizenships__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_NON_POLISH_CITIZENS && !isPolishCitizen(application));
    }

    private static Boolean isPolishCitizen(hed__Application__c application) {
        return application.TB_Applicant_Citizenship__c == TB_Constants.TB_APPLICANT_CITIZENSHIP_POLAND
                || application.TB_Applicant_Citizenship__c == TB_Constants.LANGUAGE_PL;
    }

    private static Set<TB_Admissions_Dictionary__c> matchCoursesWithOfferedProduct(Map<Id, TB_Admissions_Dictionary__c> idToLanguageCourse, hed__Application__c application) {
        Set<TB_Admissions_Dictionary__c> matchedCourses = new Set<TB_Admissions_Dictionary__c>();
        for (TB_Admissions_Dictionary__c assignment : fetchAllLanguageCourseAssignments()) {
            if (idToLanguageCourse.keySet().contains(assignment.TB_Language_Course__c)
                    && application.TB_Applying_To_Offered_Product__c == assignment.TB_Offered_Product__c) {
                matchedCourses.add(idToLanguageCourse.get(assignment.TB_Language_Course__c));
            }
        }
        return matchedCourses;
    }

    private static List<TB_Admissions_Dictionary__c> fetchAllLanguageCourseAssignments() {
        List<TB_Admissions_Dictionary__c> assignments = new List<TB_Admissions_Dictionary__c>();
        for (TB_JSON_Wrapper__c wrapper : [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = :TB_Constants.TB_OBJECT_API_NAME_ADMISSIONS_DICTIONARY
                AND TB_Record_Type_Dev_Name__c = :TB_Constants.ADMISSIONS_DICTIONARY_RT_LANGUAGE_COURSE_ASSIGNMENT_DEVNAME
        ]) {
            TB_Admissions_Dictionary__c assignment = (TB_Admissions_Dictionary__c) JSON.deserialize(wrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if (assignment.TB_Active__c) {
                assignments.add(assignment);
            }
        }
        return assignments;
    }
}
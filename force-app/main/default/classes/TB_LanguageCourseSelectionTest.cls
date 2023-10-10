@IsTest
private class TB_LanguageCourseSelectionTest {

    private static final String APPLICANT_LAST_NAME = 'TestL';
    private static final String APPLICANT_CITIZENSHIP = 'Angola';
    private static final String STUDIES_NAME = 'Test Studies';
    private static final String MOODLE_TEST_RESULT = '60 , 3 %';
    private static final String LANGUAGE_COURSE_NAME = 'Test Language Course';
    private static final Integer NUMBER_OF_LANGUAGE_COURSE_RECORDS = 30;
    private static final String LANGUAGE_GERMAN = 'German';
    private static final String LANGUAGE_ITALIAN = 'Italian';

    @TestSetup
    private static void setupMethod() {
        Contact contact = new Contact(
                LastName = APPLICANT_LAST_NAME,
                hed__Citizenship__c = APPLICANT_CITIZENSHIP
        );
        insert contact;

        TB_Offered_Product__c studies = new TB_Offered_Product__c(
                Name = STUDIES_NAME
        );
        insert studies;

        hed__Application__c application = new hed__Application__c(
                TB_Applying_To_Offered_Product__c = studies.Id,
                TB_Applicant_Citizenship__c = APPLICANT_CITIZENSHIP,
                TB_Active__c = true,
                hed__Applicant__c = contact.Id
        );
        insert application;

        TB_Application_Qualification__c qualification = TB_TestDataFactory.createApplicationQualification(false, application.Id);
        qualification.TB_Moodle_Test_Result_Percent__c = MOODLE_TEST_RESULT;
        qualification.TB_Qualification_Type__c = TB_Constants.TB_APPLICATION_QUALIFICATION_TYPE_LANGUAGE_TEST;
        insert qualification;

        Id languageCourseRecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.recordTypeInfosByDeveloperName
                .get(TB_Constants.ADMISSIONS_DICTIONARY_RT_LANGUAGE_COURSE_DEVNAME).getRecordTypeId();
        List<TB_Admissions_Dictionary__c> languageCourses = new List<TB_Admissions_Dictionary__c>();
        for (Integer i = 0; i < NUMBER_OF_LANGUAGE_COURSE_RECORDS; i++) {
            String citizenship = (i < 20)
                    ? TB_Constants.TB_CITIZENSHIP_DEPENDENCY_NON_POLISH_CITIZENS
                    : TB_Constants.TB_CITIZENSHIP_DEPENDENCY_POLISH_CITIZENS;
            String languageOfCourse = (i < 10)
                    ? LANGUAGE_GERMAN
                    : LANGUAGE_ITALIAN;
            String fromPoints = (i < 10 || i > 19)
                    ? '80'
                    : '50';
            languageCourses.add(new TB_Admissions_Dictionary__c(
                    TB_Active__c = true,
                    Name = LANGUAGE_COURSE_NAME,
                    TB_Citizenships__c = citizenship,
                    RecordTypeId = languageCourseRecordTypeId,
                    TB_Moodle_Test_Score_From__c = Decimal.valueOf(fromPoints),
                    TB_Moodle_Test_Score_To__c = 100,
                    TB_Language_of_Course__c = languageOfCourse
            ));
        }
        insert languageCourses;

        Id languageCourseAssignmentRecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.recordTypeInfosByDeveloperName
                .get(TB_Constants.ADMISSIONS_DICTIONARY_RT_LANGUAGE_COURSE_ASSIGNMENT_DEVNAME).getRecordTypeId();
        List<TB_Admissions_Dictionary__c> assignments = new List<TB_Admissions_Dictionary__c>();
        for (TB_Admissions_Dictionary__c course : languageCourses) {
            if (course.TB_Language_of_Course__c == LANGUAGE_ITALIAN) {
                assignments.add(new TB_Admissions_Dictionary__c(
                        TB_Active__c = true,
                        TB_Offered_Product__c = studies.Id,
                        RecordTypeId = languageCourseAssignmentRecordTypeId,
                        TB_Language_Course__c = course.Id
                ));
            }
        }
        insert assignments;
    }

    @IsTest
    private static void findLanguageCoursesPositiveTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c];

        Test.startTest();
        List<TB_Admissions_Dictionary__c> languageCourses = TB_LanguageCourseSelection.findLanguageCourses(application.Id);
        Test.stopTest();

        System.assertEquals(10, languageCourses.size(), 'Incorrect number of language courses was found');
    }

    @IsTest
    private static void hasCoursesPositiveTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c];

        Test.startTest();
        Boolean hasCourses = TB_LanguageCourseSelection.hasCourses(application.Id);
        Test.stopTest();

        System.assert(hasCourses);

    }

    @IsTest
    private static void hasCoursesNegativeTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c];
        application.TB_Applicant_Citizenship__c = null;
        update application;

        Test.startTest();
        Boolean hasCourses = TB_LanguageCourseSelection.hasCourses(application.Id);
        Test.stopTest();

        System.assert(!hasCourses);
    }

    @IsTest
    private static void findCoursesApplicationCitizenshipNullTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c];
        application.TB_Applicant_Citizenship__c = null;
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> languageCourses = TB_LanguageCourseSelection.findLanguageCourses(application.Id);
        Test.stopTest();

        System.assertEquals(0, languageCourses.size(), 'No language courses were expected to be found if citizenship on application is null');
    }

    @IsTest
    private static void findCoursesCourseCitizenshipNullTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c];
        List<TB_JSON_Wrapper__c> wrappers = [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = :TB_Constants.TB_OBJECT_API_NAME_ADMISSIONS_DICTIONARY
                AND TB_Record_Type_Dev_Name__c = :TB_Constants.ADMISSIONS_DICTIONARY_RT_LANGUAGE_COURSE_DEVNAME
        ]; List<TB_Admissions_Dictionary__c> courses = new List<TB_Admissions_Dictionary__c>();
        for (TB_JSON_Wrapper__c wrapper : wrappers) {
            TB_Admissions_Dictionary__c languageCourse = (TB_Admissions_Dictionary__c) JSON.deserialize(wrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            languageCourse.TB_Citizenships__c = null;
            courses.add(languageCourse);
        }
        update courses;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> languageCourses = TB_LanguageCourseSelection.findLanguageCourses(application.Id);
        Test.stopTest();

        System.assertEquals(0, languageCourses.size(), 'No language courses were expected to be found if citizenship on language course record is null');
    }

    @IsTest
    private static void findCoursesNoExamPointsTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c];
        TB_Application_Qualification__c qualification = [
                SELECT Id, TB_Moodle_Test_Result_Percent__c
                FROM TB_Application_Qualification__c
                WHERE TB_Application__c = :application.Id
        ][0];
        qualification.TB_Moodle_Test_Result_Percent__c = null;
        update qualification;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> languageCourses = TB_LanguageCourseSelection.findLanguageCourses(application.Id);
        Test.stopTest();

        System.assertEquals(0, languageCourses.size(), 'No language courses were expected to be found if test result is null');
    }

    @IsTest
    private static void findCoursesNoQualificationTest() {
        Contact contact = [SELECT Id FROM Contact];
        TB_Offered_Product__c studies = [SELECT Id FROM TB_Offered_Product__c];
        hed__Application__c applicationWithNoQualification = new hed__Application__c(
                TB_Applying_To_Offered_Product__c = studies.Id,
                TB_Applicant_Citizenship__c = APPLICANT_CITIZENSHIP,
                TB_Active__c = true,
                hed__Applicant__c = contact.Id
        );
        insert applicationWithNoQualification;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> languageCourses = TB_LanguageCourseSelection.findLanguageCourses(applicationWithNoQualification.Id);
        Test.stopTest();

        System.assertEquals(0, languageCourses.size(), 'No language courses were expected to be found if there is no associated qualification record');
    }

    @IsTest
    private static void findLanguageCoursesNegativeTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c];
        TB_Application_Qualification__c qualification = [
                SELECT Id, TB_Moodle_Test_Result_Percent__c
                FROM TB_Application_Qualification__c
                WHERE TB_Application__c = :application.Id
        ][0];
        qualification.TB_Moodle_Test_Result_Percent__c = 'not decimal value';
        update qualification;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> languageCourses = TB_LanguageCourseSelection.findLanguageCourses(application.Id);
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals(0, languageCourses.size(), 'No language courses were expected to be found in case of wrong decimal value of test result');
    }

    @IsTest
    private static void findCoursesNoQualificationPositiveTest() {
        Contact contact = [SELECT Id FROM Contact];
        TB_Offered_Product__c studies = [SELECT Id FROM TB_Offered_Product__c];
        hed__Application__c applicationWithNoQualification = new hed__Application__c(
                TB_Applying_To_Offered_Product__c = studies.Id,
                TB_Applicant_Citizenship__c = APPLICANT_CITIZENSHIP,
                TB_Active__c = true,
                hed__Applicant__c = contact.Id
        );
        insert applicationWithNoQualification;

        Id languageCourseRecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.recordTypeInfosByDeveloperName
                .get(TB_Constants.ADMISSIONS_DICTIONARY_RT_LANGUAGE_COURSE_DEVNAME).getRecordTypeId();
        TB_Admissions_Dictionary__c course = new TB_Admissions_Dictionary__c(
                TB_Active__c = true,
                Name = LANGUAGE_COURSE_NAME,
                TB_Citizenships__c = TB_Constants.TB_CITIZENSHIP_DEPENDENCY_NON_POLISH_CITIZENS,
                RecordTypeId = languageCourseRecordTypeId,
                TB_Moodle_Test_Score_From__c = 0,
                TB_Moodle_Test_Score_To__c = 100,
                TB_Language_of_Course__c = LANGUAGE_GERMAN
        );
        insert course;

        Id languageCourseAssignmentRecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.recordTypeInfosByDeveloperName
                .get(TB_Constants.ADMISSIONS_DICTIONARY_RT_LANGUAGE_COURSE_ASSIGNMENT_DEVNAME).getRecordTypeId();
        TB_Admissions_Dictionary__c assignment = new TB_Admissions_Dictionary__c(
                TB_Active__c = true,
                TB_Offered_Product__c = studies.Id,
                RecordTypeId = languageCourseAssignmentRecordTypeId,
                TB_Language_Course__c = course.Id
        );
        insert assignment;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> languageCourses = TB_LanguageCourseSelection.findLanguageCourses(applicationWithNoQualification.Id);
        Test.stopTest();

        System.assertEquals(1, languageCourses.size());
    }
}
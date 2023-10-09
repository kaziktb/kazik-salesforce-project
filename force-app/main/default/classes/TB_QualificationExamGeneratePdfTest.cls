/**
 * Created by annaseveryna on 25/02/2022.
 */
@IsTest
private class TB_QualificationExamGeneratePdfTest {

    private static final String APPLICANT_FULL_NAME = 'TestF TestL';
    private static final String QUALIFICATION_NAME = 'Qualification';
    private static final String FILENAME_PART = '-TestF TestL-Item';
    private static final Integer NUMBER_OF_QUALIFICATIONS = 2;
    private static final Integer NUMBER_OF_APPLICATIONS = 5;

    @TestSetup
    private static void setupMethod() {

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < NUMBER_OF_APPLICATIONS; i++) {
            contacts.add(TB_TestDataFactory.createContact(false));
        }
        insert contacts;

        TB_Admissions_Process__c admissionsProcess = new TB_Admissions_Process__c();
        insert admissionsProcess;
        TB_Offered_Product__c studies = TB_TestDataFactory.createOfferedProduct(false);
        insert studies;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Contact contact : contacts) {
            hed__Application__c application = new hed__Application__c();
            application.TB_Admissions_Process__c = admissionsProcess.Id;
            application.TB_Applying_To_Offered_Product__c = studies.Id;
            application.hed__Applicant__c = contact.Id;
            applications.add(application);
        }
        insert applications;

        TB_Admissions_Committee__c committee = TB_TestDataFactory.createAdmissionsCommittee(true);
        TB_Qualification_Requirement_Item__c qualificationRequirementItem = TB_TestDataFactory.createQualificationRequirementItem(true, committee.Id);

        List<TB_Application_Qualification__c> qualifications = new List<TB_Application_Qualification__c>();
        for (hed__Application__c application : applications) {
            for (Integer i = 0; i < NUMBER_OF_QUALIFICATIONS; i++) {
                TB_Application_Qualification__c qualification = TB_TestDataFactory.createApplicationQualification(false, application.Id);
                qualification.TB_Qualification_Requirement_Item__c = qualificationRequirementItem.Id;
                qualification.TB_Qualification_Requirement_Name__c = QUALIFICATION_NAME + i;
                qualifications.add(qualification);
            }
        }
        insert qualifications;
    }

    @IsTest
    private static void savePdfNotMultipleTest() {
        List<hed__Application__c> applications = [SELECT Name FROM hed__Application__c LIMIT 1];
        List<TB_Application_Qualification__c> qualifications = [SELECT Id FROM TB_Application_Qualification__c WHERE TB_Application__c = :applications[0].Id];
        TB_QualificationExamProtocolWrapper wrapper = new TB_QualificationExamProtocolWrapper();
        List<String> qualificationIds = new List<String>();
        for (TB_Application_Qualification__c qualification : qualifications) {
            qualificationIds.add(qualification.Id);
        }
        wrapper.isMultiple = false;
        wrapper.applicationId = applications[0].Id;
        wrapper.qualificationIds = String.join(qualificationIds, TB_Constants.TB_SEPARATOR_SEMICOLON);
        wrapper.applicantFullName = APPLICANT_FULL_NAME;
        wrapper.applicationName = applications[0].Name;
        List<TB_QualificationExamProtocolWrapper> wrapperList = new List<TB_QualificationExamProtocolWrapper>{ wrapper };

        Test.startTest();
        List<String> contentVersionsResult = TB_QualificationExamGeneratePdf.savePdf(wrapperList);
        Test.stopTest();

        List<Id> contentVersionIds = contentVersionsResult[0].split(TB_Constants.TB_SEPARATOR_SLASH);
        List<ContentVersion> contentVersions = [SELECT Title FROM ContentVersion WHERE Id IN :contentVersionIds];

        for (Integer i = 0; i < contentVersions.size(); i++) {
            String expectedFileName =
                    TB_QualificationExamGeneratePdf.TITLE_PART_PROTOCOL
                            + applications[0].Name + FILENAME_PART
                            + TB_Constants.TB_PARAM_PDF_EXTENSION;
            System.assertEquals(expectedFileName, contentVersions[i].Title);
        }
        System.assertEquals(1, contentVersionsResult.size());
        System.assertEquals(NUMBER_OF_QUALIFICATIONS, contentVersionIds.size());
    }

    @IsTest
    private static void savePdfTestMultiplePositive() {
        TB_Qualification_Requirement_Item__c qualificationRequirementItem = [SELECT Id FROM TB_Qualification_Requirement_Item__c];
        List<TB_Application_Qualification__c> qualifications = [SELECT TB_Qualification_Requirement_Name__c, TB_Application__c FROM TB_Application_Qualification__c WHERE TB_Qualification_Requirement_Item__c = :qualificationRequirementItem.Id];
        TB_QualificationExamProtocolWrapper wrapper = new TB_QualificationExamProtocolWrapper();
        wrapper.isMultiple = true;
        wrapper.qualifications = qualifications;
        wrapper.indexToStartWith = 0;
        List<TB_QualificationExamProtocolWrapper> wrapperList = new List<TB_QualificationExamProtocolWrapper>{ wrapper };

        Test.startTest();
        List<String> contentVersionsResult = TB_QualificationExamGeneratePdf.savePdf(wrapperList);
        Test.stopTest();

        Integer contentVersionsNumber = contentVersionsResult[0].split(TB_Constants.TB_SEPARATOR_SLASH).size();
        for (String contentVersions : contentVersionsResult) {
            System.assertEquals(10, contentVersionsNumber);
        }
    }

    @IsTest
    private static void savePdfTestNegative() {
        List<TB_QualificationExamProtocolWrapper> wrapperList = new List<TB_QualificationExamProtocolWrapper>();
        wrapperList.add(new TB_QualificationExamProtocolWrapper());
        Boolean isException;

        Test.startTest();
        try {
            TB_QualificationExamGeneratePdf.savePdf(wrapperList);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assertEquals(true, isException);
    }
}
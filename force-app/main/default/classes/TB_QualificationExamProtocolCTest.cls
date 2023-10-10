/**
 * Created by annaseveryna on 25/02/2022.
 */
@IsTest
private class TB_QualificationExamProtocolCTest {
    private static final String EXPECTED_TERM_NAME = '2022-01-01 10:10 - 2022-01-02 10:10';
    private static final String CONTACT_LAST_NAME = 'TestL';
    private static final Integer NUMBER_OF_RECORDS = 2;
    private static final Datetime TERM_START_DATE = Datetime.newInstance(2022, 01, 01, 10, 10, 10);
    private static final Datetime TERM_END_DATE = Datetime.newInstance(2022, 01, 02, 10, 10, 10);
    private static final Integer NUMBER_OF_QUALIFICATIONS = 3;
    private static final Integer EVALUATION_MAX_POINTS = 10;

    @TestSetup
    private static void setupMethod() {
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjectsAndNestedLookup(true);
        TB_Admissions_Committee__c committee = TB_TestDataFactory.createAdmissionsCommittee(true);

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
            Contact contact = TB_TestDataFactory.createContact(false);
            contact.LastName = CONTACT_LAST_NAME + i;
            contacts.add(contact);
        }
        insert contacts;

        List<TB_Admissions_Committee__c> committeeMembers = new List<TB_Admissions_Committee__c>();
        for (Contact contact : contacts) {
            committeeMembers.add(new TB_Admissions_Committee__c(
                    RecordTypeId = TB_Constants.TB_ADMISSIONS_COMMITTEE_RT_COMMITTEE_MEMBER_ID,
                    TB_Admissions_Committee__c = committee.Id,
                    TB_Committee_Member__c = contact.Id));
        }
        insert committeeMembers;

        TB_Qualification_Requirement_Item__c requirementItem = TB_TestDataFactory.createQualificationRequirementItem(true, committee.Id);
        TB_Qualification_Requirement_Item_Term__c term = TB_TestDataFactory.createQualificationRequirementItemTerm(false, requirementItem.Id);
        term.TB_Start__c = TERM_START_DATE;
        term.TB_End__c = TERM_END_DATE;
        insert term;

        List<TB_Application_Qualification__c> qualifications = new List<TB_Application_Qualification__c>();
        for (Integer i = 0; i < NUMBER_OF_QUALIFICATIONS; i++) {
            TB_Application_Qualification__c qualification = TB_TestDataFactory.createApplicationQualification(false, application.Id);
            qualification.TB_Qualification_Requirement_Item__c = requirementItem.Id;
            qualification.TB_Qualification_Requirement_Item_Term__c = term.Id;
            qualifications.add(qualification);
        }
        insert qualifications;

        List<TB_Application_Evaluation__c> evaluations = new List<TB_Application_Evaluation__c>();
        for (TB_Application_Qualification__c qualification : qualifications) {
            for (Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
                evaluations.add(new TB_Application_Evaluation__c(
                        TB_Max_Points__c = EVALUATION_MAX_POINTS,
                        TB_Evaluation_Points__c = Math.random() * 10,
                        TB_Application_Qualification__c = qualification.Id,
                        TB_Application__c = application.Id,
                        TB_Admissions_Committee__c = committee.Id));
            }
        }
        insert evaluations;
    }

    @IsTest
    private static void getQualificationsPositiveTest() {
        PageReference page = Page.TB_QualificationExamProtocol;
        Test.setCurrentPage(page);
        List<hed__Application__c> applications = [SELECT Id FROM hed__Application__c];
        List<TB_Application_Qualification__c> qualifications = [SELECT Id FROM TB_Application_Qualification__c];
        List<Id> qualificationIds = new List<Id>();
        for (TB_Application_Qualification__c qualification : qualifications) {
            qualificationIds.add(qualification.Id);
        }
        String qualificationIdsParameter = String.join(qualificationIds, TB_Constants.TB_SEPARATOR_SEMICOLON);
        ApexPages.currentPage().getParameters().put(TB_QualificationExamProtocolController.URL_PARAMETER_APPLICATION_ID, applications[0].Id);
        ApexPages.currentPage().getParameters().put(TB_QualificationExamProtocolController.URL_PARAMETER_QUALIFICATION, EncodingUtil.urlEncode(qualificationIdsParameter, TB_Constants.ENCODING_SYSTEM_UTF_8));
        TB_QualificationExamProtocolController controller = new TB_QualificationExamProtocolController();

        Test.startTest();
        List<TB_QualificationExamProtocolController.QualificationsWrapper> wrappers = controller.getQualifications();
        Test.stopTest();

        System.assertEquals(3, wrappers.size());
        for (TB_QualificationExamProtocolController.QualificationsWrapper wrapper : wrappers) {
            System.assertEquals(NUMBER_OF_RECORDS, wrapper.evaluations.size());
            System.assertEquals(EVALUATION_MAX_POINTS, wrapper.evaluations[0].TB_Max_Points__c);
            System.assertEquals(EXPECTED_TERM_NAME, wrapper.applicationQualification.TB_Qualification_Requirement_Item_Term__r.Name);
            System.assertEquals(NUMBER_OF_RECORDS, wrapper.commissionMembersNames.size());
        }
    }

    @IsTest
    private static void getQualificationsNegativeTest() {
        PageReference page = Page.TB_QualificationExamProtocol;
        Test.setCurrentPage(page);
        TB_QualificationExamProtocolController controller = new TB_QualificationExamProtocolController();

        Test.startTest();
        controller.getQualifications();
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    private static void getApplicationTest() {
        PageReference page = Page.TB_QualificationExamProtocol;
        Test.setCurrentPage(page);
        List<hed__Application__c> applications = [SELECT Id FROM hed__Application__c];
        ApexPages.currentPage().getParameters().put(TB_QualificationExamProtocolController.URL_PARAMETER_APPLICATION_ID, applications[0].Id);
        TB_QualificationExamProtocolController controller = new TB_QualificationExamProtocolController();

        Test.startTest();
        hed__Application__c returnedApplication = controller.getApplication();
        Test.stopTest();

        System.assertEquals(applications[0].Id, returnedApplication.Id);
    }
}
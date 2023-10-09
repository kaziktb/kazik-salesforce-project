@IsTest
private class TB_QualificationComponentControllerTest {
    public static String INTERVIEW = TB_Constants.QUALIFICATION_ITEM_TYPE_INTERVIEW;

    @TestSetup
    static void testSetup() {

        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        insert product;

        Contact contact = TB_TestDataFactory.createContact(false);
        insert contact;

        hed__Application__c application = TB_TestDataFactory.createApplication(null,product.Id,false);
        application.hed__Applicant__c = contact.Id;
        insert application;

        TB_Admissions_Campaign__c campaign = TB_TestDataFactory.createAdmissionsCampaign(false);
        insert campaign;

        TB_Admissions_Committee__c committee = TB_TestDataFactory.createAdmissionsCommittee(false);
        insert committee;

        TB_Qualification_Requirement_Item__c item = TB_TestDataFactory.createQualificationRequirementItem(false, committee.Id);
        item.TB_Info_EN__c = 'INFO_EN';
        item.TB_Status__c = 'Published';
        insert item;

        TB_Qualification_Requirement_Item_Term__c itemTerm = TB_TestDataFactory.createQualificationRequirementItemTerm(false, item.Id);
        itemTerm.TB_Available__c = true;
        insert itemTerm;

        TB_Application_Qualification__c applicationQualification = TB_TestDataFactory.createApplicationQualification(false, application.Id);
        applicationQualification.TB_Qualification_Type__c = INTERVIEW;
        applicationQualification.TB_Qualification_Requirement_Item__c = item.Id;
        applicationQualification.TB_Qualification_Description_EN__c = 'INFO_EN';
        applicationQualification.TB_Moodle_Exam_ID__c = TB_MoodleMock.URL_COURSE;
        insert applicationQualification;

        application.TB_Qualification__c = applicationQualification.Id;
        update application;

        TB_Admissions_Dictionary__c dictionary = TB_TestDataFactory.createAdmissionDictionary(false);
        dictionary.Name = 'Test';
        dictionary.RecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_Exam_Scope').getRecordTypeId();
        dictionary.TB_Active__c = true;
        insert dictionary;

        insert new TB_Marketing_Cloud_API__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            TB_Auth_End_Point__c = 'https://test.com',
            TB_POST_End_Point__c = 'https://test.com',
            TB_Client_Id__c = '123',
            TB_Secret__c = '123',
            TB_Grant_Type__c = 'token'
        );
        insert new TB_Moodle__c(
            TB_Moodle_Login_URL__c = 'test.pl',
            TB_Moodle_usr__c = 'test',
            TB_Moodle_psw__c = 'test',
            TB_Moodle_WS_URL__c = 'test',
            TB_Moodle_Student_Role_Id__c = '123'
        );
    }

    @IsTest
    static void getDatesAndTerms() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        String result = TB_QualificationComponentController.getDatesAndTerms(application.Id,1, 0, 1, true);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(result));
    }

    @IsTest
    static void isDatetimePickerAvailableBlankTerm() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        Boolean isAvailable = TB_QualificationComponentController.isDatetimePickerAvailable(application.Id);
        Test.stopTest();
        System.assertEquals(true, isAvailable);
    }

    @IsTest
    static void isDatetimePickerAvailableIsTerm() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Qualification_Requirement_Item_Term__c itemTerm = [SELECT Id FROM TB_Qualification_Requirement_Item_Term__c LIMIT 1];
        application.TB_Qualification_Term__c = itemTerm.Id;
        update application;
        Test.startTest();
        Boolean isAvailable = TB_QualificationComponentController.isDatetimePickerAvailable(application.Id);
        Test.stopTest();
        System.assertEquals(false, isAvailable);
    }

    @IsTest
    static void getInfoFromItemPositive() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        String result = TB_QualificationComponentController.getInfoFromItem(application.Id, 'EN');
        Test.stopTest();
        System.assertEquals('INFO_EN', result);
    }

    @IsTest
    static void updateApplication() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        TB_Qualification_Requirement_Item_Term__c itemTerm = [SELECT Id FROM TB_Qualification_Requirement_Item_Term__c LIMIT 1];
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        String result = TB_QualificationComponentController.updateApplication(application.Id, itemTerm.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void getPickedTermConfirmationPL() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        hed__Application__c application = [SELECT Id, TB_Qualification_Term__c FROM hed__Application__c LIMIT 1];
        TB_Qualification_Requirement_Item_Term__c itemTerm = [SELECT Id FROM TB_Qualification_Requirement_Item_Term__c LIMIT 1];
        application.TB_Qualification_Term__c = itemTerm.Id;
        update application;
        Test.startTest();
        List<String> result = TB_QualificationComponentController.getPickedTermConfirmation(application.Id, true, 1, 0, 1);
        Test.stopTest();
        System.assertEquals(6, result.size());
    }

    @IsTest
    static void getPickedTermConfirmationEN() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        hed__Application__c application = [SELECT Id, TB_Qualification_Term__c FROM hed__Application__c LIMIT 1];
        TB_Qualification_Requirement_Item_Term__c itemTerm = [SELECT Id FROM TB_Qualification_Requirement_Item_Term__c LIMIT 1];
        application.TB_Qualification_Term__c = itemTerm.Id;
        update application;
        Test.startTest();
        List<String> result = TB_QualificationComponentController.getPickedTermConfirmation(application.Id, false, 1, 0, 1);
        Test.stopTest();
        System.assertEquals(6, result.size());
    }

    @IsTest
    static void getDST() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Qualification_Requirement_Item_Term__c itemTerm = [SELECT Id FROM TB_Qualification_Requirement_Item_Term__c LIMIT 1];
        itemTerm.TB_Application__c = application.Id;
        update itemTerm;
        Test.startTest();
        String result = TB_QualificationComponentController.getDST();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void cancelBooking() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        TB_Qualification_Requirement_Item_Term__c itemTerm = [SELECT Id FROM TB_Qualification_Requirement_Item_Term__c LIMIT 1];
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        application.TB_Qualification_Term__c = itemTerm.Id;
        update application;
        System.assertNotEquals(null, TB_QualificationComponentController.cancelBooking(application.Id));
    }

    @IsTest
    static void getExamScopesFromBundle() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());

        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        System.assertNotEquals(null,TB_QualificationComponentController.getExamScopesFromBundle(application.Id));
    }

    @IsTest
    static void updateApplicationQualification() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        // Test.setMock(HttpCalloutMock.class, new TB_MoodleMock(TB_MoodleConstants.FUNC_CREATE_USER, '', ''));
        Id contactId = [SELECT ID From Contact].Id;
        TB_Admissions_Dictionary__c dictionary = [
            SELECT Id, TB_Display_Name_EN__c, TB_Description_EN__c, TB_Display_Name_PL__c, TB_Description_PL__c
            FROM TB_Admissions_Dictionary__c
            WHERE Name = 'Test'
        ];
        String dictionaryJSON = JSON.serialize(dictionary);
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        System.assertNotEquals(null,TB_QualificationComponentController.updateApplicationQualification(application.Id,dictionaryJSON, contactId, true));
    }
}
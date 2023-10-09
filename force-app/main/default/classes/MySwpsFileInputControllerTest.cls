@IsTest
private class MySwpsFileInputControllerTest {
    private static final String TEST_STUDENT_USER_COMMUNITY_NICKNAME = 'Super Test Nickname';
    private static final Id CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP);
    private static final Id CAREER_SERVICES_APPLICATION_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP = Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP);

    @TestSetup
    public static void setup() {
        User admin = UserTestDataFactory.createAdminUser(true);

        System.runAs(admin) {
            Contact studentContact = ContactTestDataFactory.createStudent(true);
            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, 'communityStudent@test.invalid', TEST_STUDENT_USER_COMMUNITY_NICKNAME, true);
        }
    }

    @IsTest
    public static void fileHandlerTest() {
        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .save()
            .get();

        Career_Services_Application__c application;

        Test.startTest();
        System.runAs(studentUser) {
            application = new CsApplicationTestData()
                .withOffer(offer.Id)
                .withStudent(studentUser.ContactId)
                .withRecordType(CAREER_SERVICES_APPLICATION_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
                .save()
                .get();

            MySwpsFileInputController.FileWrapper fileWrapper = new MySwpsFileInputController.FileWrapper();
            fileWrapper.base64 = EncodingUtil.base64Encode(Blob.valueOf('Mock'));
            fileWrapper.fileName = 'Test.pdf';
            MySwpsFileInputController.fileHandler(fileWrapper, application.Id);
        }
        Test.stopTest();

        application = [SELECT Id, (SELECT Id FROM ContentDocumentLinks) FROM Career_Services_Application__c];
        Assert.areEqual(1, application.ContentDocumentLinks.size());
    }
}

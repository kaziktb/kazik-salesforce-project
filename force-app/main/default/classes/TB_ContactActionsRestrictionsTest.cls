/**
 * Created by jowitakozlak on 08/02/2023.
 */

@IsTest
private class TB_ContactActionsRestrictionsTest {

    @TestSetup
    private static void testSetup() {
        User adminUser = TB_TestDataFactory.createUser(TB_re_Constants.PROFILE_NAME_ADMINISTRATOR, false);
        adminUser.LastName = 'Restricted';
        insert adminUser;
        insert new TB_Contact_Actions_Restriction__c(
            TB_Applicant_Block_Create__c = true,
            TB_Applicant_Block_Edit__c = true,
            SetupOwnerId = adminUser.ProfileId
        );
    }

    @IsTest
    private static void checkRestrictionsInsertTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'Restricted'];
        System.runAs(adminUser) {
            Contact contact = TB_TestDataFactory.createApplicantContact(false, 'Restricted', '', '');

            Test.startTest();
            Database.SaveResult result = Database.insert(contact, false);
            Test.stopTest();

            System.assert(result.isSuccess() == false);
            System.assert(result.getErrors().size() == 1);
        }
    }

    @IsTest
    private static void checkRestrictionsUpdateTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'Restricted'];
        System.runAs(adminUser) {
            TB_StaticTest.setDoNotRunTriggers();
            Contact contact = TB_TestDataFactory.createApplicantContact(true, 'Restricted', '', '');
            TB_StaticTest.unsetDoNotRunTriggers();

            Test.startTest();
            contact.DT_Document_Series_and_Number__c = 'Restricted';
            Database.SaveResult result = Database.update(contact, false);
            Test.stopTest();

            System.assert(result.isSuccess() == false);
            System.assert(result.getErrors().size() == 1);
        }
    }

}
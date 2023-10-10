@IsTest
public with sharing class TB_AgreementStatusStepControllerTest {
    @TestSetup
    public static void testSetup() {
        User internalUser = TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false);
        User externalUser;
        hed__Application__c app;
        System.runAs(internalUser) {
            app = TB_TestDataFactory.createApplicationWithRelatedObjects(false);
            externalUser = TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_APPLICANT, false);
            externalUser.ContactId = app.hed__Applicant__c;
            insert externalUser;
        }

        System.runAs(externalUser) {
            insert app;
        }
    }

    @IsTest
    public static void terminateAgreementTest(){
        hed__Application__c app = [SELECT Id, hed__Applicant__c FROM hed__Application__c];
        User externalUser = [SELECT Id FROM User WHERE ContactId = :app.hed__Applicant__c];

        Test.startTest();
        System.runAs(externalUser) {
            TB_AgreementStatusStepController.terminateAgreement(app.Id, null, null, 'borwserTestInfo');
        }
        Test.stopTest();

        app = [SELECT TB_Agreement_Status__c FROM hed__Application__c];
        System.assertEquals(TB_Constants.TB_APPLICATION_AGREEMENT_STATUS_TERMINATED, app.TB_Agreement_Status__c);
    }

    @IsTest
    public static void alreadyTerminatedTest(){
        hed__Application__c app = [SELECT Id, hed__Applicant__c FROM hed__Application__c];
        app.TB_Agreement_Status__c = 'Terminated';
        update app;
        User externalUser = [SELECT Id FROM User WHERE ContactId = :app.hed__Applicant__c];

        Boolean isException = false;
        Test.startTest();
        System.runAs(externalUser) {
            try {
                TB_AgreementStatusStepController.terminateAgreement(app.Id, null, null, 'borwserTestInfo');
            } catch (AuraHandledException e) {
                isException = true;
            }
        }
        Test.stopTest();

        System.assert(isException);
    }

}
/**
 * Created by Kamil Pilarski on 27.12.2021.
 */

@IsTest
public with sharing class TB_AgreementConclusionControllerTest {
    @TestSetup
    public static void testSetup() {
        User internalUser = TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false);
        User externalUser;
        TB_Document_Template__c documentTemplate;
        hed__Application__c app;
        System.runAs(internalUser) {
            app = TB_TestDataFactory.createApplicationWithRelatedObjects(false);
            externalUser = TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_APPLICANT, false);
            externalUser.ContactId = app.hed__Applicant__c;
            insert externalUser;

            documentTemplate = TB_TestDataFactory.createDocumentTemplate(true);
            ContentVersion templateContentVersion = new ContentVersion(
                    PathOnClient = 'template.html',
                    VersionData = Blob.valueOf('${Application.Id}')
            );
            insert templateContentVersion;
            ContentDocument templateContentDocument = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion)];
            insert new ContentDocumentLink(ContentDocumentId = templateContentDocument.Id, LinkedEntityId = documentTemplate.Id, ShareType = 'I', Visibility = 'AllUsers');

        }

        System.runAs(externalUser) {
            insert app;

            insert new List<TB_Application_Document__c>{
                    new TB_Application_Document__c(
                            TB_Active__c = true,
                            TB_Document_Category__c = TB_Constants.TB_APP_DOCUMENT_CATEGORY_STUDY_AGREEMENT_ELECTRONIC,
                            TB_Document_Type__c = TB_Constants.TB_APP_DOCUMENT_TYPE_ELECTRONIC_TEMPLATE,
                            TB_Application__c = app.Id,
                            TB_Document_Template__c = documentTemplate.Id
                    ),
                    new TB_Application_Document__c(
                            TB_Active__c = true,
                            TB_Document_Category__c = TB_Constants.TB_APP_DOCUMENT_CATEGORY_STUDY_AGREEMENT_ELECTRONIC,
                            TB_Document_Type__c = TB_Constants.TB_APP_DOCUMENT_TYPE_ELECTRONIC,
                            TB_Application__c = app.Id
                    )
            };
        }
    }

    @IsTest
    public static void testGetAgreementHtml() {
        hed__Application__c app = [SELECT Id, hed__Applicant__c FROM hed__Application__c];
        User applicant = [SELECT Id FROM User WHERE ContactId = :app.hed__Applicant__c];
        System.runAs(applicant) {
            Test.startTest();
            String html = TB_AgreementConclusionController.getAgreementHtml(app.Id, 'browser', null, null);
            Test.stopTest();

            System.assertEquals(app.Id, html);
        }
    }

    @IsTest
    public static void testGetAgreementHtmlNegative() {
        hed__Application__c app = [SELECT Id, hed__Applicant__c FROM hed__Application__c];
        User applicant = [SELECT Id FROM User WHERE ContactId = :app.hed__Applicant__c];
        System.runAs(applicant) {
            Test.startTest();
            TB_AgreementConclusionController.getAgreementHtml(applicant.Id, 'browser', null, null);
            Test.stopTest();

            System.assertEquals(2, [SELECT COUNT() FROM TB_Log__c]);
        }
    }

    @IsTest
    public static void testMissingTemplate() {
        hed__Application__c app = [SELECT Id, hed__Applicant__c FROM hed__Application__c];
        delete [SELECT Id FROM TB_Application_Document__c WHERE TB_Document_Category__c = :TB_Constants.TB_APP_DOCUMENT_CATEGORY_STUDY_AGREEMENT_ELECTRONIC];
        User applicant = [SELECT Id FROM User WHERE ContactId = :app.hed__Applicant__c];
        System.runAs(applicant) {
            Test.startTest();
            String html = TB_AgreementConclusionController.getAgreementHtml(app.Id, 'browser', null, null);
            Test.stopTest();

            System.assertEquals(1, [SELECT COUNT() FROM TB_Log__c]);
            System.assertEquals('Error', [SELECT TB_Agreement_Status__c FROM hed__Application__c].TB_Agreement_Status__c);
            System.assertEquals(1, [SELECT COUNT() FROM TB_Application_Step_History__c WHERE TB_Status__c = 'Error']);
        }
    }

    @IsTest
    public static void testSaveAcceptedAgreement() {
        hed__Application__c app = [SELECT Id, hed__Applicant__c FROM hed__Application__c];
        Test.startTest();
        TB_AgreementConclusionController.saveAcceptedAgreement(app.Id, 'browser', null, null);
        Test.stopTest();
        app = [SELECT TB_Agreement_Status__c FROM hed__Application__c];
        System.assertEquals(TB_Constants.TB_APPLICATION_AGREEMENT_STATUS_CONCLUDED, app.TB_Agreement_Status__c);
        System.assertEquals(1, [SELECT COUNT() FROM TB_Application_Step_History__c WHERE TB_Status__c = :TB_Constants.TB_APP_STEP_HISTORY_STATUS_CONCLUDED]);
    }

    @IsTest
    public static void logUnknownExcpetionTest() {
        hed__Application__c app = [SELECT Id, hed__Applicant__c FROM hed__Application__c];

        Test.startTest();
        TB_AgreementConclusionController.logUnknownException(new AuraHandledException('asdf'), app.Id, 'browser', null, null);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM TB_Log__c]);
        System.assertEquals('Error', [SELECT TB_Agreement_Status__c FROM hed__Application__c].TB_Agreement_Status__c);
        System.assertEquals(1, [SELECT COUNT() FROM TB_Application_Step_History__c WHERE TB_Status__c = 'Error']);
    }

    @IsTest
    public static void getAgreementPdfUrl() {
        hed__Application__c app = [SELECT Id, hed__Applicant__c FROM hed__Application__c];
        Test.startTest();
        TB_AgreementConclusionController.getAgreementPdfUrl(app.Id);
        Test.stopTest();
    }

}
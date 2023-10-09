/**
 * Created by Aneta on 13/12/2022.
 */

@IsTest
private class TB_MassMailCreatorControllerTest {

     @TestSetup
     static void testSetup() {
        TB_StaticTest.setDoNotRunTriggers();
        List<Contact> contacts = new List<Contact>();
         for(Integer i = 0; i < 5; i++) {
             contacts.add(TB_TestDataFactory.createContact(false));
         }
         contacts.add(new Contact(
                 LastName = 'testContact1',
                 FirstName = 'testContact1'
         ));
         insert contacts;

         createApplicationWithApplicant(contacts[0].Id, true);

         System.runAs(TB_TestDataFactory.createUser('System Administrator',true)) {
             insert new EmailTemplate(
                     DeveloperName='newEmailTemplate',
                     Name='newEmail',
                     FolderId = UserInfo.getUserId(),
                     TemplateType='Text'
             );
         }
     }

     @IsTest
     static void getDataForCreator() {
         Test.startTest();
         TB_MassMailCreatorController.getDataForCreator(false);
         Test.stopTest();
         System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getDataForCreatorWithNull() {
         Test.startTest();
         TB_MassMailCreatorController.getDataForCreator(null);
         Test.stopTest();
         System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getListViewQuery() {
         Test.startTest();
         TB_MassMailCreatorController.getListViewQuery(null, null);
         Test.stopTest();
         System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getDataForCreatorFromMeta() {
         Test.startTest();
         TB_MassMailCreatorController.getDataForCreator(true);
         Test.stopTest();
         System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getListViewsPositive() {
         Test.startTest();
         List<ListView> result = TB_MassMailCreatorController.getListViews('Contact');
         Test.stopTest();
         System.assertEquals(true, result.size() > 0);
         System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getListViewsIncorrectApiName() {
         Test.startTest();
         List<ListView> result = TB_MassMailCreatorController.getListViews('TEST_API_NAME');
         Test.stopTest();

         System.assertEquals(null, result);
         System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getRecipientsNegative() {
         Test.startTest();
         String result = TB_MassMailCreatorController.getRecipients(null, null, null, null);
         Test.stopTest();

         System.assertEquals('EXCEPTION', result);
         System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getRecipientsPositive() {
         Test.setMock(HttpCalloutMock.class, new TB_MassMailCreatorControllerMock('Contact'));

         ListView listView = [SELECT Id, DeveloperName FROM ListView WHERE SobjectType = 'Contact' LIMIT 1];
         List<String> emailApiNames = new List<String>{'Email'};
         Test.startTest();
         String result = TB_MassMailCreatorController.getRecipients(listView.Id, emailApiNames, 'Contact', null);
         Test.stopTest();

         List<TB_CreateMailWrapper> wrappers = (List<TB_CreateMailWrapper>) JSON.deserialize(result, List<TB_CreateMailWrapper>.class);
         System.assertEquals(true, result != null);
         System.assertEquals(6, wrappers.size());
         System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getRecipientsPositiveApplication() {
         Test.setMock(HttpCalloutMock.class, new TB_MassMailCreatorControllerMock('hed__Application__c'));

         ListView listView = [SELECT Id, DeveloperName FROM ListView WHERE SobjectType = 'hed__Application__c' LIMIT 1];
         List<String> emailApiNames = new List<String>{'TB_Applicant_Email__c'};
         Test.startTest();
         TB_MassMailCreatorController.getRecipients(listView.Id, emailApiNames, 'hed__Application__c', 'xdocSenderEmail');
         Test.stopTest();
         System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getMassMailLimits() {
         Test.startTest();
         TB_MassMailCreatorController.getMassMailLimits();
         Test.stopTest();
         System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
     }

     @IsTest
     static void getEmailTemplateHtmlValue() {
         EmailTemplate template = [SELECT Id, HtmlValue FROM EmailTemplate LIMIT 1];
         Test.startTest();
         EmailTemplate resultTemplate = TB_MassMailCreatorController.getEmailTemplatesHtmlValue(template.Id);
         Test.stopTest();
         System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
         System.assertEquals(template.Id, resultTemplate.Id);
         System.assertEquals(template.HtmlValue, resultTemplate.HtmlValue);
     }

     private static hed__Application__c createApplicationWithApplicant(Id contactId, Boolean withInsert) {
         hed__Application__c application = TB_TestDataFactory.createApplication(
                 TB_TestDataFactory.createAdmissionProcess(true).Id,
                 TB_TestDataFactory.createOfferedProduct(true).Id,
                 false
         );
         application.hed__Applicant__c = contactId;
         if(withInsert) {
             insert application;
         }
         return application;
     }
}
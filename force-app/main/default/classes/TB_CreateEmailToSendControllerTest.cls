/**
 * Created by Aneta on 09/06/2021.
 */

@IsTest
private class TB_CreateEmailToSendControllerTest {

    private static final Map<String,String> objectTypes = new Map<String,String>{
            'Contact' => 'Contact',
            'Application' => 'hed__Application__c'
    };

    private static final Map<String,List<String>> emailApiNames = new Map<String,List<String>>{
            'Contact' =>  new List<String>{'Email'},
            'Application' => new List<String>{'TB_Applicant_Email__c', 'TB_x_Recipient_Email__c'}
    };

    private static final String CORRECT_HTML_VALUE = '<h2>Default</h2>';
    private static final String INCORRECT_HTML_VALUE_WITH_TAG = '<h2>Default {!App.Id}</h2>';
    private static final String SUBJECT = 'Subject Test';

    @TestSetup
    static void testSetup() {

        User u = TB_TestDataFactory.createUser('System Administrator',true);

        EmailTemplate emailTemplate = new EmailTemplate(DeveloperName='newEmailTemplate', Name='newEmail',FolderId=UserInfo.getUserId(),TemplateType='Text');
        insert emailTemplate;

        EmailTemplate emptyEmailTemplate = new EmailTemplate(DeveloperName = 'TB_Empty_Template_for_Create_and_Sent_Email', Name='newEmail',FolderId=UserInfo.getUserId(),TemplateType='Text');
        insert emptyEmailTemplate;

        EnhancedLetterhead enhancedLetterhead = new EnhancedLetterhead(Name='newEnhancedLetterhead', LetterheadHeader='tmpHeader', LetterheadFooter='tmpFooter');
        insert enhancedLetterhead;

        System.runAs(u) {
            TB_TestDataFactory.createApplicationWithRelatedObjects(true);
        }
    }

    @IsTest
    static void createEmailTemplatePositive() {
        Test.startTest();
        String recordId = TB_CreateEmailToSendController.createEmailTemplate(SUBJECT, CORRECT_HTML_VALUE, null);
        Test.stopTest();
        System.assertEquals(true, recordId != null);
        System.assertEquals(18, recordId.length());
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getEmailTemplatePositive() {
        String emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName=:'newEmailTemplate' LIMIT 1].Id;
        Test.startTest();
        List<EmailTemplate> templates = TB_CreateEmailToSendController.getEmailTemplate(emailTemplateId);
        Test.stopTest();
        System.assertEquals(true, templates != null);
        System.assertEquals(1, templates.size());
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getEnhancedLetterheadPositive() {
        String enhancedLetterheadId = [SELECT Id FROM EnhancedLetterhead WHERE Name=:'newEnhancedLetterhead' LIMIT 1].Id;
        Test.startTest();
        List<EnhancedLetterhead> letterheads = TB_CreateEmailToSendController.getEnhancedLetterhead(enhancedLetterheadId);
        Test.stopTest();
        System.assertEquals(1, letterheads.size());
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void updateTemplateAfterSendMail() {
        EmailTemplate template = [
                SELECT Id
                FROM EmailTemplate
                WHERE Name =: 'TB_Empty_Template_for_Create_and_Sent_Email'
        ];
        Test.startTest();
        TB_CreateEmailToSendController.deleteTemplateAfterSendMails(template.Id);
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals(0, [SELECT Id FROM EmailTemplate WHERE Id =: template.Id].size());
    }

    @IsTest
    static void getObjectRecordsPositive(){
        String objectType = 'Contact';
        Test.startTest();
        List<Map<String,String>> result = TB_CreateEmailToSendController.getObjectRecords(objectType, null, ' Contact WHERE LastName = \'testContact\'', emailApiNames.get(objectType));
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getObjectRecordsNegative(){
        String objectType = 'Application';
        Test.startTest();
        List<Map<String,String>> result = TB_CreateEmailToSendController.getObjectRecords(objectTypes.get(objectType), 'xdocSenderEmail', 'INVALID QUERY', emailApiNames.get(objectType));
        Test.stopTest();
        System.assertEquals(0, result.size());
        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void sendMassEmailForApplication(){
        List<Map<String,String>> objectsMap = new List<Map<String,String>>();
        objectsMap.add(new Map<String, String>{
                'contactId' => null,
                'emailList' => 'test@test.com',
                'orgWideAddressId'=> null,
                'recordId' => null
        });

        Test.startTest();
        String result = TB_CreateEmailToSendController.sendMassEmailForApplication(objectsMap, objectTypes.get('Contact'), null,null);
        Test.stopTest();
        System.assertEquals(true, result == 'true');
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void deleteFileNegative() {
        Test.startTest();
        String result = TB_CreateEmailToSendController.deleteFile('INVALID_ID');
        Test.stopTest();
        System.assertEquals('FAILED', result.substring(0, 6));
        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }

//    @IsTest
//    static void sendSingleEmailMessagesWithFile(){
//        Contact firstContact = [SELECT Id FROM Contact WHERE LastName = 'testContact'];
//
//        List<Map<String,String>> objectsMap = new List<Map<String,String>>();
//        objectsMap.add(new Map<String, String>{
//                'contactId' => firstContact.Id,
//                'emailList' => 'test@test.com',
//                'orgWideAddressId'=> null,
//                'recordId' => firstContact.Id
//        });
//
//        Test.startTest();
//        TB_CreateEmailToSendController.sendMassEmailForApplication(objectsMap, objectTypes.get('Contact'),[SELECT Id FROM EmailTemplate LIMIT 1].Id,null);
//        Test.stopTest();
//        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
//    }

}
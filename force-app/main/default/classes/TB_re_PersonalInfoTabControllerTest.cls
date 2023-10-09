@IsTest
private with sharing class TB_re_PersonalInfoTabControllerTest {
    @IsTest
    static void isTooYoungNegative() {
        Boolean result;
        Test.startTest();
        result = TB_re_PersonalInfoTabController.isTooYoung(null, null, null);
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertEquals(1, [SELECT Id From TB_Log__c].size());
    }

    @IsTest
    static void isTooYoungTrue() {
        Boolean result;
        Test.startTest();
        result = TB_re_PersonalInfoTabController.isTooYoung(
            System.today().year(),
            System.today().month(),
            System.today().day()
        );
        Test.stopTest();
        System.assertEquals(true, result);
        System.assertEquals(0, [SELECT Id From TB_Log__c].size());
    }

    @IsTest
    static void isTooYoungFalse() {
        Boolean result;
        Test.startTest();
        result = TB_re_PersonalInfoTabController.isTooYoung(
            System.today().year() - 16,
            System.today().month(),
            System.today().day()
        );
        Test.stopTest();
        System.assertEquals(false, result);
        System.assertEquals(0, [SELECT Id From TB_Log__c].size());
    }

    @IsTest
    static void blockDuplicatesPeselExceptionFalse() {
        Boolean result;
        String type = 'PERSONAL_INFORMATION.DT_PESEL__C.EXCEPTION';
        String data = '97081633909';
        Contact contact = TB_TestDataFactory.createContact(true);
        Test.startTest();
        result = TB_re_PersonalInfoTabController.blockDuplicates(type, data, contact.Id);
        Test.stopTest();
        System.assertEquals(false, result);
        System.assertEquals(0, [SELECT Id From TB_Log__c].size());
    }

    @IsTest
    static void blockDuplicatesDocumentSearchExceptionFalse() {
        Boolean result;
        String type = 'PERSONAL_INFORMATION.TB_X_Document_Search__C.EXCEPTION';
        String data = '97081633909';
        Contact contact = TB_TestDataFactory.createContact(true);
        Test.startTest();
        result = TB_re_PersonalInfoTabController.blockDuplicates(type, data, contact.Id);
        Test.stopTest();
        System.assertEquals(false, result);
        System.assertEquals(0, [SELECT Id From TB_Log__c].size());
    }

    @IsTest
    static void blockDuplicatesPeselExceptionTrue() {
        Boolean result;
        String type = 'PERSONAL_INFORMATION.DT_PESEL__C.EXCEPTION';
        String data = '88121212121';
        Contact contact = TB_TestDataFactory.createApplicantContact(true, '88121212121', null, null);
        Contact newContact = TB_TestDataFactory.createApplicantContact(false, '88121212121', null, null);
        Test.startTest();
        result = TB_re_PersonalInfoTabController.blockDuplicates(type, data, newContact.Id);
        Test.stopTest();
        System.assertEquals(true, result);
        System.assertEquals(0, [SELECT Id From TB_Log__c].size());
    }

    @IsTest
    static void blockDuplicatesDocumentSearchExceptionTrue() {
        Boolean result;
        String type = 'PERSONAL_INFORMATION.TB_X_Document_Search__C.EXCEPTION';
        String data = 'PL88121212121';
        Contact contact = TB_TestDataFactory.createApplicantContact(true, null, '88121212121', 'PL');
        Contact newContact = TB_TestDataFactory.createApplicantContact(false, null, '88121212121', 'PL');
        Test.startTest();
        result = TB_re_PersonalInfoTabController.blockDuplicates(type, data, newContact.Id);
        Test.stopTest();
        System.assertEquals(true, result);
        System.assertEquals(0, [SELECT Id From TB_Log__c].size());
    }
}
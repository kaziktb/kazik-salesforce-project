@IsTest
private class TB_MultiContact360ViewControllerTest {
    public static final String STUDENT = 'TB_Student';
    public static final String CONTACT_STUDENT_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(STUDENT).getRecordTypeId();
    public static final String STRING_TO_BLOB = 'stringtest';
    public static final String CONTENT_VERSION_TITLE = 'titletest';
    public static final String PATH_ON_CLIENT = 'pathtest';
    public static final String PHOTO_CATEGORY = 'Profile_Photo';

    @TestSetup
    static void testSetup() {
        TB_StaticTest.setDoNotRunTriggers();
        Individual individual = new Individual(LastName = 'test', FirstName = 'individual');
        insert individual;
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            contacts.add(TB_TestDataFactory.createContact(false));
            contacts[i].RecordTypeId = CONTACT_STUDENT_RT_ID;
            contacts[i].IndividualId = individual.Id;
        }
        insert contacts;
        ContentVersion contentVersion = TB_TestDataFactory.createContentVersion(false, CONTENT_VERSION_TITLE, PATH_ON_CLIENT, STRING_TO_BLOB);
        contentVersion.TB_Category__c = PHOTO_CATEGORY;
        insert contentVersion;
        contentVersion = [SELECT ContentDocumentId FROM ContentVersion];
        TB_TestDataFactory.createContentDocumentLink(true, contentVersion.ContentDocumentId, contacts[0].Id);
        hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c(hed__Contact__c=contacts[0].Id, TB_Semester__c = 1);
        insert programEnrollment;
    }

    @IsTest
    static void getContactTypesPositive() {
        Contact contact = [SELECT RecordType.DeveloperName FROM Contact LIMIT 1];
        String result;
        Test.startTest();
        result = TB_MultiContact360ViewController.getContactTypes(contact.Id);
        Test.stopTest();
        System.assertEquals(true, result.contains(contact.RecordType.DeveloperName));
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getContactTypesNegative() {
        String result;
        Test.startTest();
        result = TB_MultiContact360ViewController.getContactTypes('');
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getProfilePhotosPositive() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        ContentVersion contentVersion = [SELECT Id FROM ContentVersion];
        String result;
        Test.startTest();
        result = TB_MultiContact360ViewController.getProfilePhotos(contact.Id);
        Test.stopTest();
        System.assertEquals(true, result.contains(contentVersion.Id));
        System.assertEquals(true, result.contains(contact.Id));
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getProfilePhotosNegative() {
        String result;
        Test.startTest();
        result = TB_MultiContact360ViewController.getProfilePhotos('');
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getContactWrappersPositive() {
        String result;
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        result = TB_MultiContact360ViewController.getContactWrappers(contact.Id);
        Test.stopTest();
        System.assertEquals(true, result.contains(contact.Id));
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getContactWrappersNegative() {
        String result;
        Test.startTest();
        result = TB_MultiContact360ViewController.getContactWrappers('');
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getWrapperListPositive() {
        List<TB_MultiContact360ViewController.DataTableWrapp> result;
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        result = TB_MultiContact360ViewController.getWrapperList(contact.Id);
        Test.stopTest();
        System.assertEquals(true, result[0].id == contact.Id);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getWrapperListNegative() {
        List<TB_MultiContact360ViewController.DataTableWrapp> result;
        Test.startTest();
        result = TB_MultiContact360ViewController.getWrapperList('');
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }
}
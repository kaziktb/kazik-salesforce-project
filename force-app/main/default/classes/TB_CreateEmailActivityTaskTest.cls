@IsTest
private class TB_CreateEmailActivityTaskTest {
    @TestSetup
    static void testSetup() {
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<2; i++) {
            contacts.add(TB_TestDataFactory.createContact(false));
        }
        contacts[1].Email = 'test2@test.com';
        insert contacts;
        Account account = new Account(Name='test');
        insert account;
    }

    @IsTest
    static void TB_CreateEmailActivityTask_MainClassTest() {
        List<TB_CreateEmailActivityTask.WrapperClass> wrapperClasses = new List<TB_CreateEmailActivityTask.WrapperClass>();
        TB_CreateEmailActivityTask.WrapperClass wrapperClass = new TB_CreateEmailActivityTask.WrapperClass();
        Account account = [SELECT Id FROM Account LIMIT 1];
        for(Contact contact : [SELECT Id FROM Contact]) {
            wrapperClass.recordId = contact.Id;
            wrapperClass.relatedToId = account.Id;
            wrapperClass.fromAddress = 'test@test.com';
            wrapperClass.fromName = 'NameTest';
            wrapperClass.subject = 'SubjectTest';
            wrapperClasses.add(wrapperClass);
        }
        Test.startTest();
        TB_CreateEmailActivityTask.TB_CreateEmailActivityTask_MainClass(wrapperClasses);
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM EmailMessage].size());
        Set<Id> test = (new Map<Id, Contact>([SELECT Id FROM Contact])).keyset();
        System.assertEquals(2, [SELECT Id FROM EmailMessageRelation WHERE RelationId IN :test].size());
    }
}
@IsTest
private class TB_CT_DeleteAssociatedRecordsTest {
    private static final String EMAIL_TEST_TWO = 'test2@test.com';
    private static final String TEST_CONTACT = 'testContact';
    private static final String PHONE = '809890890';
    private static final Id EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Account acc = new Account(
                  Name = 'Test Account'
        );
        insert acc;


        Contact contact = new Contact(
            FirstName = TEST_CONTACT + '1', 
            LastName = TEST_CONTACT + '1',
            MiddleName = TEST_CONTACT + '1',
            hed__AlternateEmail__c = EMAIL_TEST_TWO,
            Phone = PHONE,
            hed__PreferredPhone__c = PHONE,
            MobilePhone = PHONE,
            TB_x_Disable_User__c = true,
            TB_x_User_Synced__c = false,
            RecordTypeId = EMPLOYEE_RECORD_TYPE_ID,
            TB_Active__c = true
            );
        insert contact;
        hed__Affiliation__c affiliationNotSynced = new hed__Affiliation__c(hed__Contact__c = contact.Id, hed__Role__c = 'Employee');
        insert affiliationNotSynced;
        Case caseTest = new Case(Origin = 'Email', ContactId = contact.Id);
        insert caseTest;
    }

    @IsTest 
    private static void testDeleteAssociated(){
      List<Contact> contactsNotSynced = [SELECT Id FROM Contact];
      Map<Id,User> usersNotSyncedMap = new Map<Id,User>([SELECT Id FROM User WHERE ContactId  = :contactsNotSynced[0].Id]);
      Map<Id, Account> accountsToDeleteMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1]);

      Test.startTest();
      System.enqueueJob(new TB_CT_DeleteAssociatedRecords(null, contactsNotSynced, usersNotSyncedMap.keySet(), null, accountsToDeleteMap.keySet()));
      Test.stopTest();

      List<Contact> deletedContact = [SELECT Id FROM Contact];
      List<Account> deletedAcc =  [SELECT Id FROM Account WHERE Name = 'Test Account'];
      List<hed__Affiliation__c> deletedAffiliation =  [SELECT Id FROM hed__Affiliation__c];
      Assert.isTrue(deletedContact.isEmpty(), 'Contact should be deleted');
      Assert.isTrue(deletedAcc.isEmpty(), 'Account should be deleted');
      Assert.isTrue(deletedAffiliation.isEmpty(), 'Affiliation should be deleted');
    }


    @IsTest
    private static void testDeleteAssociatedSync(){
      List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
      contacts[0].TB_x_User_Synced__c = true;
      update contacts;

      Map<Id,User> usersNotSyncedMap = new Map<Id,User>([SELECT Id FROM User WHERE ContactId  = :contacts[0].Id]);
      List<Account> acc = [SELECT Id FROM Account WHERE Name = 'Test Account'];

      Test.startTest();
      System.enqueueJob(new TB_CT_DeleteAssociatedRecords(contacts,null,usersNotSyncedMap.keySet(), acc, null));
      Test.stopTest();

      List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Account'];
      List<Contact> contactsAfter = [SELECT Id FROM Contact];
      List<hed__Affiliation__c> affiliations  = [SELECT Id FROM hed__Affiliation__c];

      System.assert(!accounts.isEmpty(), 'Accounts should not be deleted');
      System.assert(!contactsAfter.isEmpty(), 'Contacts should not be deleted');
      System.assert(!affiliations.isEmpty(), 'Affiliation should not be deleted');
    }
}

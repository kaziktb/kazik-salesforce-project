@isTest
private class TB_vu_StudentOrganizationDetailsTest {
    static final String PL_LANG = 'PL';

    @TestSetup
    static void testSetup() {
        List<User> usersToInsert = new List<User>();
        List<Contact> contactsToInsert = new List<Contact>();

        User notChairmanUser = TB_TestDataFactory.createUser(TB_TestDataFactory.SYSTEM_ADMINISTRATOR, false);
        notChairmanUser.Email = 'notchairman@usertest.com';
        usersToInsert.add(notChairmanUser);

        User user = TB_TestDataFactory.createUser(TB_TestDataFactory.SYSTEM_ADMINISTRATOR, false);
        user.TimeZoneSidKey = 'Europe/Warsaw';
        usersToInsert.add(user);

        insert usersToInsert;

        Contact contact = TB_TestDataFactory.createContact(false);
        contact.TB_User__c = user.Id;
        contactsToInsert.add(contact);

        Contact notChairmanContact = TB_TestDataFactory.createContact(false);
        notChairmanContact.FirstName = 'notChairman';
        notChairmanContact.Email = 'notchairman@contacttest.com';
        notChairmanContact.TB_User__c = notChairmanUser.Id;
        contactsToInsert.add(notChairmanContact);

        insert contactsToInsert;

        List<Account> accs = TB_TestDataFactory.createAccounts(
            1,
            TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID,
            false
        );
        for (Account a : accs) {
            a.TB_Account_Name_EN__c = 'TestEN';
            a.TB_Account_Name_PL__c = 'TestPL';
            a.TB_Organisation_Type__c = 'Scientific_Organisation';
            a.TB_Description_PL__c = '<p>Description</p>';
            a.hed__Primary_Contact__c = contact.Id;
            a.TB_Status__c = 'Pending_Approval';
        }
        insert accs;

        Task taskAssignedToAcc = new Task(
            WhatId=accs[0].Id, 
            WhoId = contact.Id,
            TB_Active__c = true,
            Status = 'In Progress',
            Possible_Approval_Decisions__c='Approved');

        insert taskAssignedToAcc;

        hed__Affiliation__c affiliation = TB_TestDataFactory.createAffiliation(contact, accs[0], true);

        ContentVersion content = TB_TestDataFactory.createContentVersion(
            false,
            'test content',
            '/testPath',
            'testVersion'
        );

        content.TB_Category__c = 'Students_Organisation_Regulations';
        insert content;

        ContentDocumentLink contentDocumentLink = TB_TestDataFactory.createContentDocumentLink(
            true,
            [SELECT ContentDocumentId FROM contentversion WHERE Id = :content.Id]
            .ContentDocumentId,
            accs[0].Id
        );
    }

    @isTest
    static void shouldReturnStudentOrganizationDetailsWrapperObjectWithPLLanguage() {
        Account account = [SELECT Id, TB_Account_Name_PL__c FROM Account WHERE TB_Account_Name_PL__c = 'TestPL'];

        TB_vu_StudentOrganizationDetails.StudentOrganizationDetailsWrapper result;

        Test.startTest();
        result = TB_vu_StudentOrganizationDetails.getOrganizationDetails(account.Id, 'PL');
        Test.stopTest();

        System.assertEquals(
            account.TB_Account_Name_PL__c,
            result.AccName,
            'Query should return object with particular language Name'
        );
    }

    @isTest
    static void shouldReturnStudentOrganizationDetailsWrapperObjectWithoutHTMLTagsAndUnderscores() {
        Account account = [
            SELECT Id, TB_Account_Name_PL__c, TB_Description_PL__c, TB_Organisation_Type__c
            FROM Account
            WHERE TB_Account_Name_PL__c = 'TestPL'
        ];
        TB_vu_StudentOrganizationDetails.StudentOrganizationDetailsWrapper result;

        Test.startTest();
        result = TB_vu_StudentOrganizationDetails.getOrganizationDetails(account.Id, 'PL');
        Test.stopTest();

        System.assertEquals('<p>Description</p>', result.Description, 'Query should return rich text Description');
        System.assertEquals('Scientific Organisation', result.Type, 'Query should return object without underscores');
    }

    @isTest
    static void shouldReturnStudentOrganizationDetailsWrapperObjectWithENLanguage() {
        Account account = [SELECT Id, TB_Account_Name_EN__c FROM Account WHERE TB_Account_Name_PL__c = 'TestPL'];
        TB_vu_StudentOrganizationDetails.StudentOrganizationDetailsWrapper result;

        Test.startTest();
        result = TB_vu_StudentOrganizationDetails.getOrganizationDetails(account.Id, 'EN');
        Test.stopTest();

        System.assertEquals(
            account.TB_Account_Name_EN__c,
            result.AccName,
            'Query should return object with particular language Name'
        );
    }

    @isTest
    static void shouldReturnStudentOrganizationDetailsWrapperWithRulesWrapper() {
        Account account = [SELECT Id, TB_Account_Name_EN__c FROM Account WHERE TB_Account_Name_PL__c = 'TestPL'];
        TB_vu_StudentOrganizationDetails.StudentOrganizationDetailsWrapper result;

        Test.startTest();
        result = TB_vu_StudentOrganizationDetails.getOrganizationDetails(account.Id, 'PL');
        Test.stopTest();

        System.assertEquals(
            'test content',
            result.RulesWrapper.FileName,
            'Query should not return object with null RulesWrapper'
        );
    }

    @isTest
    static void throwAnErrorOn_whenFoundNull() {
        Boolean errorOccurred = false;

        Test.startTest();
        try {
            TB_vu_StudentOrganizationDetails.getOrganizationDetails('something', 'PL');
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        System.assertEquals(true, errorOccurred, 'Query should return exception');
    }

    @isTest
    static void shouldReturnStudentOrganizationMemberWrapperWithOneContactAsPrimaryContact() {
        hed__Affiliation__c affiliation = [SELECT Id, hed__Account__c FROM hed__Affiliation__c];
        List<TB_vu_StudentOrganizationDetails.StudentOrganizationMemberWrapper> result;

        Test.startTest();
        result = TB_vu_StudentOrganizationDetails.getMembers(affiliation.hed__Account__c, 'true');
        Test.stopTest();

        System.assertEquals(
            1,
            result.size(),
            'Amount of contacts in Student Organization doesnt match with expected value'
        );
    }

    @isTest
    static void shouldReturnStudentOrganizationMemberWrapperWithOneContactAsNotPrimaryContact() {
        hed__Affiliation__c affiliation = [SELECT Id, hed__Account__c FROM hed__Affiliation__c];
        List<TB_vu_StudentOrganizationDetails.StudentOrganizationMemberWrapper> result;

        Test.startTest();
        result = TB_vu_StudentOrganizationDetails.getMembers(affiliation.hed__Account__c, 'false');
        Test.stopTest();

        System.assertEquals(
            1,
            result.size(),
            'Amount of contacts in Student Organization doesnt match with expected value'
        );
    }

    @isTest
    static void throwAnErrorOn_whenWrongIdPassed() {
        List<TB_vu_StudentOrganizationDetails.StudentOrganizationMemberWrapper> result;

        Test.startTest();
        result = TB_vu_StudentOrganizationDetails.getMembers('something', 'false');
        Test.stopTest();

        System.assertEquals(0, result.size());
    }

    @isTest
    static void shouldReturnTrueOnChairmanIsLogged() {
        Account account = [
            SELECT Id, TB_Account_Name_PL__c
            FROM Account
            WHERE TB_Account_Name_PL__c = 'TestPL'
            LIMIT 1
        ];
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'puser%' LIMIT 1];
        TB_vu_StudentOrganizationDetails.StudentOrganizationDetailsWrapper result;

        System.runAs(user) {
            Test.startTest();
            result = TB_vu_StudentOrganizationDetails.getOrganizationDetails(account.Id, PL_LANG);
            Test.stopTest();
        }

        System.assertEquals(true, result.IsChairmanLogged, 'Should return true');
    }

    @isTest
    static void shouldReturnFalseOnChairmanIsLogged() {
        Account account = [
            SELECT Id, TB_Account_Name_PL__c
            FROM Account
            WHERE TB_Account_Name_PL__c = 'TestPL'
            LIMIT 1
        ];
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'notchairman%' LIMIT 1];
        TB_vu_StudentOrganizationDetails.StudentOrganizationDetailsWrapper result;

        System.runAs(user) {
            Test.startTest();
            result = TB_vu_StudentOrganizationDetails.getOrganizationDetails(account.Id, PL_LANG);
            Test.stopTest();
        }

        System.assertEquals(false, result.IsChairmanLogged, 'Should return false');
    }

    @isTest
    static void throwAnErrorOn_whenWrongIdPassedToCheckIfChairmanIsLogged() {
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'puser%' LIMIT 1];
        Boolean errorOccurred = false;

        System.runAs(user) {
            Test.startTest();
            try {
                TB_vu_StudentOrganizationDetails.getOrganizationDetails('INVALID', PL_LANG);
            } catch (Exception e) {
                errorOccurred = true;
            }
            Test.stopTest();
        }

        System.assertEquals(true, errorOccurred, 'Should return exception');
    }

    @IsTest
    static void shouldReturnAffiliation() {
        //given
        Account account = [SELECT Id FROM Account WHERE Name LIKE 'Acc Name%' LIMIT 1];
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'puser%' LIMIT 1];
        TB_vu_StudentOrganizationDetails.StudentOrganizationDetailsWrapper result;
        hed__Affiliation__c aff = [SELECT Id, hed__Status__c FROM hed__Affiliation__c];
        aff.hed__Status__c = TB_Constants.AFFILIATION_STATUS_CURRENT;
        update aff;

        //when
        System.runAs(user) {
            Test.startTest();
            result = TB_vu_StudentOrganizationDetails.getOrganizationDetails(account.Id, PL_LANG);
            Test.stopTest();
        }

        //then
        System.assertEquals(true, result.HasAffiliation, 'Should return affiliation');
    }

    @IsTest
    static void shouldCreateAffiliation_whenContactLinkedToCurrentUserFound() {
        //given
        Account account = [SELECT Id FROM Account WHERE Name LIKE 'Acc Name%' LIMIT 1];
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'puser%' LIMIT 1];

        //when
        System.runAs(user) {
            Test.startTest();
            TB_vu_StudentOrganizationDetails.createAffiliation(account.Id);
            Test.stopTest();
        }

        //then
        System.assertEquals(2, [SELECT Id FROM hed__Affiliation__c].size(), 'Should return one affiliation');
    }

    @IsTest
    static void shouldModifyAffiliation() {
        //given
        Account account = [SELECT Id FROM Account WHERE Name LIKE 'Acc Name%' LIMIT 1];
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'puser%' LIMIT 1];
        hed__Affiliation__c aff = [SELECT Id, hed__Status__c FROM hed__Affiliation__c];
        aff.hed__Status__c = TB_Constants.AFFILIATION_STATUS_CURRENT;
        update aff;

        //when
        System.runAs(user) {
            Test.startTest();
            TB_vu_StudentOrganizationDetails.modifyAffiliation(account.Id, null, TB_Constants.ORG_LEAVING_PROCESS_TYPE);
            Test.stopTest();
        }

        //then
        aff = [SELECT Id, hed__Status__c, hed__EndDate__c FROM hed__Affiliation__c];
        System.assertEquals(Date.today(), aff.hed__EndDate__c, 'Should return today as end date');
        System.assertEquals(
            TB_Constants.AFFILIATION_STATUS_FORMER,
            aff.hed__Status__c,
            'Should return Former as status'
        );
    }

    @IsTest
    static void shouldUpdateAffiliationStatus() {
        Account account = [SELECT Id FROM Account WHERE Name LIKE 'Acc Name%' LIMIT 1];
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'puser%' LIMIT 1];
        Contact contact = [SELECT Id, LastName FROM Contact WHERE TB_User__c = :user.Id LIMIT 1];
        hed__Affiliation__c affiliation = [SELECT Id, hed__Status__c FROM hed__Affiliation__c LIMIT 1];
        affiliation.hed__Status__c = TB_Constants.AFFILIATION_STATUS_AWAITING;
        update affiliation;

        System.runAs(user) {
            Test.startTest();
            TB_vu_StudentOrganizationDetails.setUserDecision(
                account.Id,
                contact.Id,
                user.Id,
                TB_Constants.DECISION_CONFIRMED
            );
            Test.stopTest();
        }

        affiliation = [SELECT Id, hed__Status__c FROM hed__Affiliation__c LIMIT 1];

        System.assertEquals(
            TB_Constants.AFFILIATION_STATUS_CURRENT,
            affiliation.hed__Status__c,
            'Should update affiliation status to current'
        );
    }

    @IsTest
    static void shouldThrowExceptionOnUpdateAffiliationStatusAttempt() {
        Account account = [SELECT Id FROM Account WHERE Name LIKE 'Acc Name%' LIMIT 1];
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'puser%' LIMIT 1];
        Contact contact = [SELECT Id, LastName FROM Contact WHERE TB_User__c = :user.Id LIMIT 1];
        Boolean errorOccurred = false;

        System.runAs(user) {
            Test.startTest();
            try {
                TB_vu_StudentOrganizationDetails.setUserDecision(
                    account.Id,
                    contact.Id,
                    user.Id,
                    TB_Constants.DECISION_CONFIRMED
                );
            } catch (Exception e) {
                errorOccurred = true;
            }
            Test.stopTest();
        }

        System.assertEquals(true, errorOccurred, 'Should throw exception on affiliation status update attempt');
    }

    @IsTest
    static void shouldThrowExceptionOnAffiliationStatusUpdateDueToLackOfPrivileges() {
        Account account = [SELECT Id FROM Account WHERE Name LIKE 'Acc Name%' LIMIT 1];
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'puser%' LIMIT 1];
        Contact contact = [SELECT Id, LastName FROM Contact WHERE TB_User__c = :user.Id LIMIT 1];
        hed__Affiliation__c affiliation = [SELECT Id, hed__Status__c FROM hed__Affiliation__c LIMIT 1];
        affiliation.hed__Status__c = TB_Constants.AFFILIATION_STATUS_AWAITING;
        update affiliation;

        Boolean errorOccurred;

        Test.startTest();
        try {
            TB_vu_StudentOrganizationDetails.setUserDecision(
                account.Id,
                contact.Id,
                user.Id,
                TB_Constants.DECISION_CONFIRMED
            );
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        affiliation = [SELECT Id, hed__Status__c FROM hed__Affiliation__c LIMIT 1];

        System.assertEquals(
            true,
            errorOccurred,
            'Should throw exception on affiliation status update due to lack of privileges'
        );
    }

}
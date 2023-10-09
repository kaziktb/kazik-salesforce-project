@IsTest
private class TB_CT_CaseControllerTest {
    private static final String TEST_NAME = 'TEST_TEST';
    private static final String USER_FIRST_NAME = 'Test';
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String EMAIL_VALUE = 'testtest@gmail.com';
    private static final String PROFILE_CONTRACT_TEACHERS = 'SWPS Employee Community User';
    private static final String EXPRESSION_TEST = 'Test';
    private static final String MOBILE_VAL = 'Mobile';
    private static final String CASE_SUBJECT_CONTRACT = 'Other';
    private static final String CONTENT_VERSION_TITLE = 'Test_Case_Attachment';
    private static final Integer NUMBER_OF_INSERTED_RECORDS = 3;
    private static final String CATEGORY_CASE_ATTACHMENT = 'Case_Attachment';
    private static final Id DEPARTMENT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
    private static final Id EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();
    private static final Id CASE_CT_HE_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contract_Teachers_HE_Case').getRecordTypeId();

    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', true)) {
            TB_TC_URLs__c url = new TB_TC_URLs__c(TB_Admissions_Portal__c  = 'https://devtbydct-swpsuniversity.cs174.force.co...');   
            insert url;

            TB_StaticTest.setDoNotRunTriggers();
            TB_App_Tracking__c app = new TB_App_Tracking__c(
                    TB_First_Name__c = 'Fake',
                    TB_Email__c = 'fake@fake.cloud',
                    TB_Last_Name__c = 'fake',
                    TB_Process_Status__c = 'New'
            );
            insert app;

            Id adminUserId = UserInfo.getUserId();
            Contact contact = new Contact(
                LastName = USER_LAST_NAME, 
                TB_Didactic_Applicant_Counter_HE__c = 1,
                RecordTypeId = EMPLOYEE_RECORD_TYPE_ID,
                hed__AlternateEmail__c = EMAIL_VALUE,
                Phone = '123456781',
                hed__PreferredPhone__c = MOBILE_VAL,
                TB_Active__c = true
            );
            Contact primaryResponsible = new Contact(
                    LastName = 'primary',
                    Email = 'primary-responsible@test.test',
                    TB_Customer_Id__c = '09283412',
                    RecordTypeId = EMPLOYEE_RECORD_TYPE_ID,
                    TB_User__c = adminUserId,
                    TB_Active__c = true
            );
            insert new List<Contact>{contact, primaryResponsible};

            Account parentDepartment = new Account(Name = TEST_NAME + ' Parent', RecordTypeId = DEPARTMENT_RECORD_TYPE_ID, Type = 'Faculty', TB_Subtype__c = 'HE');
            insert parentDepartment;

            Account department = new Account(Name = TEST_NAME, ParentId = parentDepartment.Id, RecordTypeId = DEPARTMENT_RECORD_TYPE_ID, Type = 'Faculty',
                                             TB_Subtype__c = 'HE', TB_Faculty_Office__c = parentDepartment.Id);
            insert department;

            User didacticUser = new User(
                    ProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_CONTRACT_TEACHERS].Id,
                    FirstName = EXPRESSION_TEST,
                    LastName = USER_LAST_NAME,
                    Email = 'didactic@crazy.night',
                    Username = 'didactic@amamama.com' + System.currentTimeMillis(),
                    CompanyName = 'TEST',
                    Title = 'title',
                    Alias = 'alias',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ContactId = contact.Id
            );
            insert didacticUser;

            contact.TB_User__c = didacticUser.Id;
            update contact;

            List<hed__Affiliation__c> affiliations = new List<hed__Affiliation__c>();
            for (Integer i = 0; i < 2; i++) {
                hed__Affiliation__c temp = new hed__Affiliation__c(
                    hed__Contact__c = contact.Id,
                    hed__Account__c = department.Id,
                    hed__Role__c = 'Employee',
                    hed__Status__c = 'Current',
                    TB_Employee_Affiliation_Type__c = 'Applicant'
                    );
                    if(i == 1) {
                    temp.hed__Contact__c = primaryResponsible.Id;
                    temp.TB_Employee_Affiliation_Type__c = 'Agreement';
                }
                    affiliations.add(temp);
            }
            insert affiliations;

            app.TB_First_Name__c = USER_FIRST_NAME;
            app.TB_Last_Name__c = USER_LAST_NAME;
            app.TB_Email__c = 'test@test.test';
            app.TB_Process_Status__c = 'New';
            app.TB_Dean_s_Office_Responsible__c = primaryResponsible.Id;
            app.TB_Uni_Work_Department__c = department.Id;
            app.TB_Applicant__c = contact.Id;
            update app;

            Case c1 = new Case(ContactId = primaryResponsible.Id, Status = 'In_Progress',
                    Subject = CASE_SUBJECT_CONTRACT, RecordTypeId = CASE_CT_HE_RECORD_TYPE_ID, TB_CT_Case_Category__c = 'Contact', TB_CT_Department_Id__c = department.Id,TB_CT_Faculty_Office_Name__c = '');
            Case c2 = new Case(ContactId = contact.Id, Status = 'New', Subject = CASE_SUBJECT_CONTRACT,
                    RecordTypeId = CASE_CT_HE_RECORD_TYPE_ID, TB_CT_Case_Category__c = 'Contact', TB_CT_Case_Responsible_Person__c = primaryResponsible.Id);
            insert new List<Case>{c1, c2};

            CaseComment caseComment1 = new CaseComment(ParentId = c2.Id, CommentBody = EXPRESSION_TEST);
            CaseComment caseComment2 = new CaseComment(ParentId = c2.Id, CommentBody = EXPRESSION_TEST);
            insert new List<CaseComment>{caseComment1, caseComment2};
        }
    }

    @IsTest
    private static void updateCaseFacultyOfficeNamesTest() {
        Account departmentToMatch = [SELECT Id, Name FROM Account WHERE Name =:TEST_NAME + ' Parent' LIMIT 1];
        Case createdCase = [SELECT Id, TB_CT_Faculty_Office_Name__c FROM Case WHERE Status = 'In_Progress' LIMIT 1];
        User didacticUser = [SELECT Id FROM User WHERE Email = 'didactic@crazy.night' LIMIT 1];

        Test.startTest();
        TB_CT_CasesControllerSharingSkip.updateCaseFacultyOfficeNames(createdCase.Id);
        Test.stopTest();
        Assert.areEqual(departmentToMatch.Name, [SELECT Id, TB_CT_Faculty_Office_Name__c FROM Case WHERE Status = 'In_Progress' LIMIT 1].TB_CT_Faculty_Office_Name__c, 'Account names must be equal after update!');
    }

    @IsTest
    private static void fetchCasesPositiveTest() {
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :USER_LAST_NAME LIMIT 1];

        Test.startTest();
        List<Case> cases = TB_CT_CasesController.fetchCases(contact.Id);
        Test.stopTest();

        System.assertEquals(1, cases.size());
    }

    @IsTest
    private static void fetchCasesNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_CT_CasesController.fetchCases('invalid_id');
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    private static void fetchCaseCommentsPositiveTest() {
        Case c = [SELECT Id FROM Case WHERE Status = 'New' LIMIT 1];

        Test.startTest();
        List<TB_CT_CasesController.CommentWrapper> comments = TB_CT_CasesController.fetchCaseComments(c.Id);
        Test.stopTest();

        System.assertEquals(2, comments.size());
    }

    @IsTest
    private static void fetchCaseCommentsNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_CT_CasesController.fetchCaseComments('invalid_id');
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    private static void createCaseCommentPositiveTest() {
        Case c = [SELECT Id FROM Case WHERE Status = 'New' LIMIT 1];

        Test.startTest();
        TB_CT_CasesController.createCaseComment(c.Id, EXPRESSION_TEST);
        Test.stopTest();

        List<CaseComment> comments = [SELECT Id FROM CaseComment WHERE ParentId = :c.Id];
        System.assertEquals(3, comments.size());
    }

    @IsTest
    private static void createCaseCommentNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_CT_CasesController.createCaseComment('invalid_id', EXPRESSION_TEST);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    private static void updateContentVersionsPositiveTest() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
        insert version;

        Test.startTest();
        TB_CT_CasesController.updateContentVersions(new List<Id>{
                version.Id
        }, c.Id, '');
        Test.stopTest();

        ContentVersion newVersion = [SELECT TB_Category__c, ContentDocumentId FROM ContentVersion];
        List<ContentDocumentLink> links = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :c.Id];

        System.assertEquals(CATEGORY_CASE_ATTACHMENT, newVersion.TB_Category__c);
        System.assertEquals(newVersion.ContentDocumentId, links[0].ContentDocumentId);
        System.assertEquals(c.Id, links[0].LinkedEntityId);
    }

    @IsTest
    private static void updateContentVersionsNegativeTest() {
        Boolean isException = false;
        ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
        insert version;

        Test.startTest();
        try {
            TB_CT_CasesController.updateContentVersions(new List<Id>{
                    version.Id
            }, 'invalid_id', '');
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    private static void updateContentVersionsWithCaseCommentTest() {
        Case c = [SELECT Id FROM Case WHERE Status = 'New' LIMIT 1];
        List<CaseComment> comments = [SELECT Id FROM CaseComment];
        ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
        insert version;

        Test.startTest();
        TB_CT_CasesController.updateContentVersions(new List<Id>{
                version.Id
        }, c.Id, comments[0].Id);
        Test.stopTest();

        ContentVersion newVersion = [SELECT TB_Category__c, ContentDocumentId FROM ContentVersion];
        System.assertEquals(newVersion.TB_Category__c, CATEGORY_CASE_ATTACHMENT);

    }


    @IsTest
    private static void fetchContactsTest() {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE TB_User__c != NULL LIMIT 1];

        Test.startTest();
        List<LookupSearchResult> returnedContacts = TB_CT_CasesController.fetchContacts(null);
        Test.stopTest();

        System.assertEquals(contacts.size(), returnedContacts.size());
    }

    @IsTest
    private static void userIdToIsTeacherTest() {
        List<User> users = [
                SELECT Id
                FROM User
                WHERE LastName = :USER_LAST_NAME
        ];

        Test.startTest();
        Map<Id, Boolean> userIdToIsTeacher = TB_CT_CasesControllerSharingSkip.userIdToIsTeacher(new List<Id>{
                users[0].Id
        });
        Test.stopTest();

        System.assertEquals(true, userIdToIsTeacher.get(users[0].Id));
    }

    @IsTest
    private static void userIdToNameTest() {
        List<User> users = [
                SELECT Id
                FROM User
                WHERE LastName = :USER_LAST_NAME
        ];

        Test.startTest();
        Map<Id, String> userIdToName = TB_CT_CasesControllerSharingSkip.userIdToName(new List<Id>{
                users[0].Id
        });
        Test.stopTest();

        System.assertEquals('Test CaseTest', userIdToName.get(users[0].Id));
    }

    @IsTest
    private static void fetchCaseWrappersTestWithoutComments() {
        User didacticUser = [SELECT Id, (SELECT Id FROM Contacts__r) FROM User WHERE Email = 'didactic@crazy.night' LIMIT 1];
        Contact contact = didacticUser.Contacts__r[0];

        List<TB_CT_CasesController.CaseWrapper> wrappers = null;
        Test.startTest();
        System.runAs(didacticUser) {
            wrappers = TB_CT_CasesController.fetchDidacticCasesByFilter(null, null, null, contact.Id, 0, 210);
        }
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
        System.assertEquals(0, wrappers[0].caseComments.size());
    }

    @IsTest
    private static void fetchCaseWrappersTestWithContentDocument() {
        Case c = [SELECT ContactId FROM Case WHERE Status = 'New' LIMIT 1];

        List<ContentVersion> versions = new List<ContentVersion>();
        for (Integer i = 0; i < NUMBER_OF_INSERTED_RECORDS; i++) {
            ContentVersion version = TB_TestDataFactory.createContentVersion(false, CONTENT_VERSION_TITLE, CONTENT_VERSION_TITLE + '.pdf', 'Test');
            versions.add(version);
        }
        insert versions;

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentDocument document : [SELECT Id FROM ContentDocument]) {
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(LinkedEntityId = c.Id, ContentDocumentId = document.Id);
            links.add(contentDocumentLink);
        }
        insert links;

        User employeeUser = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com' LIMIT 1];
        List<TB_CT_CasesController.CaseWrapper> wrappers = null;
        Test.startTest();
        System.runAs(employeeUser) {
            wrappers = TB_CT_CasesController.fetchOfficeCasesByFilter(null, null, 'New', null, 0, 210);
        }
        Test.stopTest();

        Assert.areEqual(1, wrappers.size());
        System.assertEquals(NUMBER_OF_INSERTED_RECORDS, wrappers[0].contentVersions.size());
        System.assertEquals(CONTENT_VERSION_TITLE, wrappers[0].contentVersions[0].Title);
    }

    @IsTest
    private static void fetchCommentsTest() {
        Case c = [ SELECT Id FROM Case WHERE Status = 'New' LIMIT 1];

        Test.startTest();
        List<CaseComment> comments = TB_CT_CasesController.fetchComments(c.Id);
        Test.stopTest();

        System.assertEquals(2, comments.size());
    }

    @IsTest
    private static void contentVersionWithCommentTest() {
        Case c = [ SELECT Id FROM Case WHERE Status = 'New' LIMIT 1];
        List<ContentVersion> versions = new List<ContentVersion>();
        for (CaseComment comment : [
                SELECT Id
                FROM CaseComment
        ]) {
            for (Integer i = 0; i < 2; i++) {
                ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
                version.TB_Case_Comment__c = comment.Id;
                versions.add(version);
            }
        }
        insert versions;

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        for (ContentDocument document : [SELECT Id FROM ContentDocument]) {
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(LinkedEntityId = c.Id, ContentDocumentId = document.Id);
            links.add(contentDocumentLink);
        }
        insert links;

        Test.startTest();
        List<TB_CT_CasesController.CommentWrapper> commentWrappers = TB_CT_CasesController.fetchCaseComments(c.Id);
        Test.stopTest();

        System.assertEquals(2, commentWrappers.size());
    }

    @IsTest
    private static void deleteContentDocumentsTest() {
        ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
        insert version;

        Test.startTest();
        TB_CT_CasesController.deleteContentDocuments(new List<Id> {
                version.Id
        });
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM ContentDocument].size());
    }

    @IsTest
    private static void fetchTypeOfStudyPicklistBasedOnEduLevel() {
        Id conId = [SELECT Id FROM Contact WHERE LastName =:USER_LAST_NAME LIMIT 1].Id;

        Test.startTest();
        Map<String,String> resultMap = TB_CT_CasesController.fetchTypeOfStudyPicklistBasedOnEduLevel(conId);
        Test.stopTest();

        System.assert(resultMap.containsKey('Higher Education'), 'Teacher contact should have Higher Education Studies');
    }

    @IsTest
    private static void searchTest() {
        Contact contactFromDB = [SELECT Id FROM Contact WHERE LastName =: USER_LAST_NAME LIMIT 1];
        Test.setFixedSearchResults(new List<Id>{contactFromDB.Id});
        List<LookupSearchResult> results;
        Test.startTest();
        results = TB_CT_CasesController.search(USER_LAST_NAME);
        Test.stopTest();
        System.assertNotEquals(null, results, 'Search results are empty');
        System.assertEquals(contactFromDB.Id, results.get(0).getId(), 'Ids are not the same');
    }

    @IsTest
    private static void fetchOfficeCasesByNoneFiltersTest() {
        User employeeUser = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com' LIMIT 1];
        List<TB_CT_CasesController.CaseWrapper> wrappers = null;

        Test.startTest();
        System.runAs(employeeUser) {
            wrappers = TB_CT_CasesController.fetchOfficeCasesByFilter(null, null, null, null, 0, 210);
        }
        Test.stopTest();

        Integer numOfCasesInDB = [SELECT COUNT() FROM Case];
        Assert.areEqual(numOfCasesInDB, wrappers.size());
    }

    @IsTest
    private static void fetchOfficeCasesBySearchTermFiltersTest() {
        String searchTerm = 'Con';
        User employeeUser = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com' LIMIT 1];
        List<TB_CT_CasesController.CaseWrapper> wrappers = null;

        Test.startTest();
        System.runAs(employeeUser) {
            wrappers = TB_CT_CasesController.fetchOfficeCasesByFilter(searchTerm, null, null, null, 0, 210);
        }
        Test.stopTest();

        Assert.areEqual(2, wrappers.size());
        Assert.isTrue(wrappers[0].createdBy.contains(searchTerm) || wrappers[0].category.contains(searchTerm));
    }

    @IsTest
    private static void fetchDidacticCasesByNoneFiltersTest() {
        User didacticUser = [SELECT Id, (SELECT Id FROM Contacts__r) FROM User WHERE Email = 'didactic@crazy.night' LIMIT 1];
        Contact c = didacticUser.Contacts__r[0];
        List<TB_CT_CasesController.CaseWrapper> wrappers = null;

        Test.startTest();
        System.runAs(didacticUser) {
            wrappers = TB_CT_CasesController.fetchDidacticCasesByFilter(null, null, null, c.Id, 0, 210);
        }
        Test.stopTest();

        Integer numOfCasesInDB = [SELECT COUNT() FROM Case WHERE ContactId =: c.Id];
        Assert.areEqual(numOfCasesInDB, wrappers.size());
    }

    @IsTest
    private static void fetchDidacticCasesBySearchTermFiltersTest() {
        String searchTerm = 'Con';
        User didacticUser = [SELECT Id, (SELECT Id FROM Contacts__r) FROM User WHERE Email = 'didactic@crazy.night' LIMIT 1];
        Contact c = didacticUser.Contacts__r[0];
        List<TB_CT_CasesController.CaseWrapper> wrappers = null;


        Test.startTest();
        System.runAs(didacticUser) {
            wrappers = TB_CT_CasesController.fetchDidacticCasesByFilter(searchTerm, null, null, c.Id, 0, 210);
        }
        Test.stopTest();

        Assert.areEqual(1, wrappers.size());
        Assert.isTrue(wrappers[0].createdBy.contains(searchTerm) || wrappers[0].category.contains(searchTerm));
    }

    @IsTest
    private static void fetchDidacticCasesByAllFiltersTest() {
        String searchTerm = 'Con';
        User didacticUser = [SELECT Id, (SELECT Id FROM Contacts__r) FROM User WHERE Email = 'didactic@crazy.night' LIMIT 1];
        Contact c = didacticUser.Contacts__r[0];
        List<TB_CT_CasesController.CaseWrapper> wrappers = null;

        Test.startTest();
        System.runAs(didacticUser) {
            wrappers = TB_CT_CasesController.fetchDidacticCasesByFilter(searchTerm, 'ASCENDING', 'New', c.Id, 0, 210);
        }
        Test.stopTest();

        Assert.areEqual(1, wrappers.size());
        Assert.isTrue(wrappers[0].createdBy.contains(searchTerm) || wrappers[0].category.contains(searchTerm));
        Assert.isTrue(wrappers[0].status.equals('New'));
    }

    @IsTest
    private static void fetchDepartmentIdTest() {
        TB_StaticTest.setDoNotRunTriggers();
        User didactic = [SELECT Id, ContactId FROM User WHERE LastName = :USER_LAST_NAME LIMIT 1];
        Id departId = [SELECT hed__Account__c FROM hed__Affiliation__c WHERE hed__Contact__c =: didactic.ContactId].hed__Account__c;
        Id parentFacultyId;

        Test.startTest();
        System.runAs(didactic) {
            parentFacultyId = TB_CT_CasesControllerSharingSkip.fetchDepartmentId(true, departId);
        }
        Test.stopTest();

        String accName =  TEST_NAME + ' Parent';
        Assert.areEqual([SELECT Id FROM Account WHERE Name =: accName LIMIT 1].Id, parentFacultyId);
    }
}
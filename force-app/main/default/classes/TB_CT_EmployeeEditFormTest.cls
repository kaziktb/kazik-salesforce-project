@IsTest
private class TB_CT_EmployeeEditFormTest {
    private static final String PARAM_TEST_CITIZENSHIP = 'AD';
    private static final String PARAM_TEST_FIRST_NAME = 'TestF';
    private static final String PARAM_TEST_LAST_NAME = 'TestL';
    private static final Integer NUMBER_OF_RECORDS = 2;
    private static final String CATEGORY_DIPLOMA = 'Diploma';
    private static final String CATEGORY_CV = 'CV';
    private static final String TEST_COMMENT = 'Test comment';
    private static final String PATH_ON_CLIENT = 'Test.jpg';
    private static final String STATUS_DATA_COMPLETION = 'Data_Completion';
    private static final String WORK_DEPARTMENT_EMAIL = 'work.dept@test.test';
    private static final Set<String> EMPLOYEE_PERM_SETS_NAMES = new Set<String>{'TB_SWPS_Contract_Teachers_Coordinator', 'TB_SWPS_Contract_Teachers_Decision_Maker'};
    private static final Id CONTACT_EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();
    private static final String PERM_SET_DECISION_MAKER = 'TB_SWPS_Contract_Teachers_Decision_Maker';
    private static final String PROFILE_NAME_EMPLOYEE = 'SWPS Dean\'s Office Employee';

    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
            TB_CT_TestDataFactory.insertCTEmail();
            TB_CT_TestDataFactory.insertCTUrls();
            Id adminUserId = UserInfo.getUserId();

            User officeEmployee = new User(FirstName = 'Office', LastName = 'primary',
                    ProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_EMPLOYEE].Id,
                    Email = 'jack.sparrow@arrr.com',
                    Username = System.now().millisecond() + 'jack.sparrow@arrr.com',
                    Alias = 'Jacky',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US'
            );
            insert officeEmployee;

            Contact primaryResponsible = new Contact(
                    LastName = 'primary',
                    Email = 'primary-responsible@test.test',
                    TB_Customer_Id__c = '09283412',
                    TB_User__c = officeEmployee.Id
            );

            Id permSetDeansOffice = [SELECT Id FROM PermissionSet WHERE Name = :PERM_SET_DECISION_MAKER].Id;
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permSetDeansOffice,AssigneeId = officeEmployee.Id);
            insert psa;

            Contact responsibleCoordinator = new Contact(
                    LastName = 'coordinator',
                    Email = 'responsible-coordinator@test.test',
                    TB_Customer_Id__c = '09438510',
                    TB_User__c = adminUserId
            );
        
            insert new List<Contact>{primaryResponsible, responsibleCoordinator};
            insert new TB_App_Tracking__c(
                    TB_First_Name__c = PARAM_TEST_FIRST_NAME,
                    TB_Last_Name__c = PARAM_TEST_LAST_NAME,
                    TB_Email__c = 'test@test.test',
                    TB_Dean_s_Office_Responsible__c = primaryResponsible.Id,
                    TB_Responsible_Coordinator__c = responsibleCoordinator.Id
            );
            Contact contact = [SELECT Id, Name FROM Contact WHERE LastName =:PARAM_TEST_LAST_NAME LIMIT 1];

            insert new Contact(LastName = 'QuickTest', TB_Active__c = TRUE, recordTypeId = CONTACT_EMPLOYEE_RECORD_TYPE_ID);
            List<TB_Experience_History__c> experienceHistories = new List<TB_Experience_History__c>();
            for (Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
                experienceHistories.add(
                        new TB_Experience_History__c(
                                TB_Applicant__c = contact.Id
                        )
                );
            }
            insert experienceHistories;

            List<ContentVersion> contentVersions = new List<ContentVersion>();
            ContentVersion versionCV = TB_TestDataFactory.createContentVersion(false, 'Test', PATH_ON_CLIENT, 'Test');
            versionCV.TB_Category__c = CATEGORY_CV;
            insert versionCV;

            List<ContentVersion> insertedContentVersions = [
                    SELECT ContentDocumentId, TB_Category__c
                    FROM ContentVersion
            ];

            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
            for (ContentVersion version : insertedContentVersions) {
                    links.add(TB_TestDataFactory.createContentDocumentLink(false, version.ContentDocumentId, contact.Id));
            }
            insert links;
        }
    }

    @IsTest
    private static void getAppTrackingStatusTest() {
        TB_StaticTest.setDoNotRunTriggers();
        Contact con = null;
        String resultNull = null;

        Set<Id> employeePermSetsIds = new Map<Id, PermissionSet>([SELECT Id FROM PermissionSet WHERE Name IN :EMPLOYEE_PERM_SETS_NAMES]).keySet();
        Id userId = [SELECT AssigneeId 
                     FROM PermissionSetAssignment 
                     WHERE PermissionSetId IN :employeePermSetsIds 
                     AND Assignee.IsActive = TRUE
                     AND Assignee.Lastname = 'primary']
                     [0].AssigneeId;
        User u = [SELECT Id FROM User WHERE Id = :userId LIMIT 1];

        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
        con =  new Contact(LastName = 'Tester', TB_User__c = u.Id);
        insert con;
        } 

        System.runAs(u) {
            Test.startTest();
            resultNull = TB_CT_EmployeeEditForm.getAppTrackingStatus(con.Id);
            Test.stopTest();
        }
        Assert.isTrue(resultNull == null);
    }

    @IsTest
    private static void getAppTrackingStatusTestContactFromApp() {
        TB_StaticTest.setDoNotRunTriggers();
        Contact con = null;
        String resultNotNull = null;


        Set<Id> employeePermSetsIds = new Map<Id, PermissionSet>([SELECT Id FROM PermissionSet WHERE Name IN :EMPLOYEE_PERM_SETS_NAMES]).keySet();
        Id userId = [SELECT AssigneeId 
                     FROM PermissionSetAssignment 
                     WHERE PermissionSetId IN :employeePermSetsIds 
                     AND Assignee.IsActive = TRUE
                     AND Assignee.Lastname = 'primary' ]
                     [0].AssigneeId;
        User u = [SELECT Id FROM User WHERE Id = :userId LIMIT 1];

        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
            con =  new Contact(LastName = 'Tester', TB_User__c = u.Id);
            insert con;
        }
        Contact contactFromAppTracking = [SELECT Id FROM Contact WHERE LastName =: PARAM_TEST_LAST_NAME LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            resultNotNull = TB_CT_EmployeeEditForm.getAppTrackingStatus(contactFromAppTracking.Id);
            Test.stopTest();
        }
        Assert.isFalse(resultNotNull == null);
    }

    @IsTest
    private static void fetchDegreeFieldInfosTest() {
        Integer experienceHistorySettingsCount = [SELECT Id FROM TB_Experience_History_Setting__mdt].size();

        Test.startTest();
        List<TB_Experience_History_Setting__mdt> experienceHistorySettings = TB_CT_EmployeeEditForm.fetchDegreeFieldInfos();
        Test.stopTest();

        System.assertEquals(experienceHistorySettingsCount, experienceHistorySettings.size());
    }

    @IsTest
    private static void fetchTitlesPositiveTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];

        Test.startTest();
        List<TB_CT_EmployeeEditForm.ContentVersionWrapper> result = TB_CT_EmployeeEditForm.fetchTitles(contact.Id);
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS, result.size());
    }

    @IsTest
    private static void fetchTitlesNegativeTest() {
        Test.startTest();
        List<TB_CT_EmployeeEditForm.ContentVersionWrapper> result = TB_CT_EmployeeEditForm.fetchTitles(null);
        Test.stopTest();

        System.assertEquals(0, result.size());
    }

    @IsTest
    private static void fetchAppTracking() {
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];

        Test.startTest();
        TB_App_Tracking__c result = TB_CT_EmployeeEditForm.fetchAppTracking(contact.Id);
        Test.stopTest();

        TB_App_Tracking__c app = [
                SELECT TB_Applicant__c
                FROM TB_App_Tracking__c
                WHERE Id = :result.Id
        ];
        System.assertEquals(contact.Id, app.TB_Applicant__c);
    }

    @IsTest
    private static void fetchContactsTest() {
        Test.startTest();
        List<Contact> contacts = TB_CT_EmployeeEditForm.fetchContacts();
        Test.stopTest();
        Assert.isTrue(contacts.size() > 0);
    }

    @IsTest
    private static void fetchExperienceHistoryTest() {
        TB_Experience_History__c history = [
                SELECT Id
                FROM TB_Experience_History__c
                LIMIT 1
        ];

        Test.startTest();
        List<TB_Experience_History__c> returnedHistory = TB_CT_EmployeeEditForm.fetchExperienceHistory(history.Id);
        Test.stopTest();

        System.assertEquals(history.Id, returnedHistory[0].Id);
    }

    @IsTest
    private static void fetchLatestContVerBasedOnCategoryTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];

        Test.startTest();
        TB_CT_EmployeeEditForm.ContentVersionWrapper wrapper = TB_CT_EmployeeEditForm.fetchLatestContVerBasedOnCategory(contact.Id, CATEGORY_CV);
        Test.stopTest();

        System.assert(wrapper.hasCV);
        System.assert(wrapper.hasCV);
    }

    @IsTest
    private static void sendCommentEmailToTeacherPositiveTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];
        contact.hed__AlternateEmail__c = 'test@test.test';
        update contact;

        String comment = TEST_COMMENT;

        Test.startTest();
        TB_CT_EmployeeEditForm.sendCommentEmailToTeacher(comment, contact.Id);
        Test.stopTest();

        System.assertEquals(1, Limits.getEmailInvocations(), 'Email should be sent');
    }


    @IsTest
    private static void updateAppTrackingStatusPositiveTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];
        TB_App_Tracking__c app = [
                SELECT Id, TB_Process_Status__c
                FROM TB_App_Tracking__c
                WHERE TB_Applicant__c = :contact.Id
                LIMIT 1
        ];

        Test.startTest();
        TB_CT_EmployeeEditForm.updateAppTrackingStatus(contact.Id, STATUS_DATA_COMPLETION);
        Test.stopTest();

        TB_App_Tracking__c updatedApp = [
                SELECT TB_Process_Status__c
                FROM TB_App_Tracking__c
                WHERE Id = :app.Id
        ];

        System.assertEquals(STATUS_DATA_COMPLETION, updatedApp.TB_Process_Status__c);
    }


    @IsTest
    private static void fetchMultipleContentVersionIdsTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];

        Test.startTest();
        List<Id> contentVersionIds = TB_CT_EmployeeEditForm.fetchMultipleContentVersionIds(contact.Id, CATEGORY_CV);
        Test.stopTest();

        System.assertEquals(1, contentVersionIds.size());
    }

    @IsTest
    private static void fetchMultipleContentVersionIdsCacheableTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];

        Test.startTest();
        List<ContentVersion> contentVersions = TB_CT_EmployeeEditForm.fetchMultipleContentVersionsCacheable(contact.Id, CATEGORY_CV);
        Test.stopTest();

        System.assertEquals(1, contentVersions.size());
    }

    @IsTest
    private static void updateContentVersionsTest() {
        List<ContentVersion> versions = [
                SELECT Id, Description
                FROM ContentVersion
        ];
        for (ContentVersion version : versions) {
            version.Description = TEST_COMMENT;
        }

        Test.startTest();
        TB_CT_EmployeeEditForm.updateContentVersions(versions);
        Test.stopTest();


        for (ContentVersion version : [
                SELECT Id, Description
                FROM ContentVersion
        ]) {
            System.assertEquals(TEST_COMMENT, version.Description);
        }
    }

    @IsTest
    private static void deleteContentDocumentsTest() {
        List<Id> versionIds = new List<Id>();
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentVersion version : [
                SELECT ContentDocumentId
                FROM ContentVersion
        ]) {
            versionIds.add(version.Id);
            contentDocumentIds.add(version.ContentDocumentId);
        }

        Test.startTest();
        TB_CT_EmployeeEditForm.deleteContentDocuments(versionIds);
        Test.stopTest();


        System.assertEquals(0, [
                SELECT Id
                FROM ContentDocument
                WHERE Id IN :contentDocumentIds
        ].size());
    }

    @IsTest
    private static void deleteContentDocumentsWithoutCategoryTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];
        ContentVersion versionWithoutCategory = TB_TestDataFactory.createContentVersion(true, 'Test', PATH_ON_CLIENT, 'Test');
        ContentVersion insertedVersion = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id = :versionWithoutCategory.Id
        ];
        ContentDocumentLink link = TB_TestDataFactory.createContentDocumentLink(false, insertedVersion.ContentDocumentId, contact.Id);
        insert link;


        Test.startTest();
        TB_CT_EmployeeEditForm.deleteContentDocumentsWithoutCategory(contact.Id);
        Test.stopTest();


        System.assertEquals(0, [
                SELECT Id
                FROM ContentDocument
                WHERE Id = :insertedVersion.ContentDocumentId
        ].size());
    }

    @IsTest
    private static void deleteAssociatedFilesTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];

        Test.startTest();
        TB_CT_EmployeeEditForm.deleteAssociatedFiles(contact.Id);
        Test.stopTest();
        List<ContentDocumentLink> hh =  [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :contact.Id
    ];

        System.assertEquals(0, [
                SELECT Id
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :contact.Id
        ].size());
    }

    @IsTest
    private static void sendCommentEmailToResponsiblesTest() {
        Contact contact = [
                SELECT Id, Email
                FROM Contact
                WHERE LastName = :PARAM_TEST_LAST_NAME
        ];

        String comment = 'test comment';

        Test.startTest();
        TB_CT_EmployeeEditForm.sendCommentEmailToResponsibles(comment, contact.Id);
        Test.stopTest();

        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');

    }

    @IsTest
    private static void fetchAffiliationsTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1][0];
        insert new hed__Affiliation__c(hed__Contact__c = contact.Id);

        Test.startTest();
        List<hed__Affiliation__c> affiliations = TB_CT_EmployeeEditForm.fetchAffiliations(contact.Id);
        Test.stopTest();

        System.assertEquals(1, affiliations.size());
    }

    @IsTest
    private static void updateAffiliationsPositiveTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1][0];
        hed__Affiliation__c affiliation = new hed__Affiliation__c(hed__Contact__c = contact.Id);
        insert affiliation;

        Test.startTest();
        TB_CT_EmployeeEditForm.updateAffiliations(new List<hed__Affiliation__c> {affiliation});
        Test.stopTest();

        hed__Affiliation__c updatedAffiliation = [
                SELECT TB_Application_Date__c
                FROM hed__Affiliation__c
        ];

        String formattedDateNow = Datetime.newInstance(Datetime.now().year(),
                                  Datetime.now().month(), 
                                  Datetime.now().day())
                                  .format('yyyy-MM-dd');
        String formattedApplicationDate = Datetime.newInstance(updatedAffiliation.TB_Application_Date__c.year(),
                                                               updatedAffiliation.TB_Application_Date__c.month(), 
                                                               updatedAffiliation.TB_Application_Date__c.day())
                                                               .format('yyyy-MM-dd');
        System.assertEquals(formattedDateNow, formattedApplicationDate);
    }

    @IsTest
    private static void hasAppTrackingTest() {
        TB_App_Tracking__c app = [
                SELECT TB_Applicant__c
                FROM TB_App_Tracking__c
        ];

        Test.startTest();
        Boolean hasAppTracking = TB_CT_EmployeeEditForm.hasAppTracking(app.TB_Applicant__c);
        Test.stopTest();

        System.assert(hasAppTracking);
    }

    @IsTest
    private static void deleteExperienceHistoryRecordTest() {
      Contact contact = [
        SELECT Id
        FROM Contact
        WHERE LastName = :PARAM_TEST_LAST_NAME
      ];
      List<TB_Experience_History__c> expHistories = [ SELECT Id FROM TB_Experience_History__c ];
      List<TB_Experience_History__c> history = [
        SELECT Id
        FROM TB_Experience_History__c
        WHERE TB_Applicant__c = :contact.Id
      ];
      Test.startTest();
      TB_CT_EmployeeEditForm.deleteExperienceHistoryRecord(history[0].Id);
      Test.stopTest();
      List<TB_Experience_History__c> expHistoriesAfterRemove = [ SELECT Id FROM TB_Experience_History__c ];
      List<TB_Experience_History__c> historyRemoved = [
        SELECT Id
        FROM TB_Experience_History__c
        WHERE Id = :history[0].Id
      ];
      Assert.isTrue(expHistoriesAfterRemove.size() == expHistories.size() - 1);
      Assert.isTrue(
        historyRemoved.isEmpty(),
        'Experience History was not deleted'
      );
    }

    @IsTest
    private static void notFoundPeselUniqueTest() {
        Contact c = [SELECT Id FROM Contact WHERE LastName =: PARAM_TEST_LAST_NAME LIMIT 1];

        Test.startTest();
        Boolean isUnique = TB_CT_EmployeeEditForm.isPeselUnique(c.Id, '44112631817');
        Test.stopTest();

        Assert.isTrue(isUnique, 'Pesel should be unique since there are no pesels such as given');
    }

    @IsTest
    private static void foundOnePeselUniqueTest() {
        Contact c = [SELECT Id FROM Contact WHERE LastName =: PARAM_TEST_LAST_NAME LIMIT 1];
        c.DT_PESEL__c = '44112631817';
        update c;

        Test.startTest();
        Boolean isUnique = TB_CT_EmployeeEditForm.isPeselUnique(c.Id, '44112631817');
        Test.stopTest();

        Assert.isTrue(isUnique, 'Pesel should be unique since there is only 1 pesel such as given');
    }

    @IsTest
    private static void foundTwoPeselsUniqueTest() {
        Contact c1 = [SELECT Id FROM Contact WHERE LastName =: PARAM_TEST_LAST_NAME LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = 'QuickTest' LIMIT 1];
        c1.DT_PESEL__c = '44112631817';
        c2.DT_PESEL__c = '44112631817';
        update new List<Contact>{c1, c2};
        Test.startTest();
        Boolean isUnique = TB_CT_EmployeeEditForm.isPeselUnique(c1.Id, '44112631817');
        Test.stopTest();

        Assert.isFalse(isUnique, 'Pesel should not be unique since there are two pesels such as given');
    }

    @IsTest
    private static void notFoundDocumentUniqueTest() {
        Contact c = [SELECT Id FROM Contact WHERE LastName =: PARAM_TEST_LAST_NAME LIMIT 1];
        String docNumber = 'PL hApi:Hapi-HAPI -FUnny Cat';

        Test.startTest();
        Boolean isUnique = TB_CT_EmployeeEditForm.isDocumentUnique(c.Id, docNumber);
        Test.stopTest();

        Assert.isTrue(isUnique, 'Document should be unique since there are no documents such as given');
    }

    @IsTest
    private static void foundOneDocumentUniqueTest() {
        Contact c = [SELECT Id FROM Contact WHERE LastName =: PARAM_TEST_LAST_NAME LIMIT 1];
        c.DT_Document_Issuing_Country__c = 'PL';
        c.DT_Document_Series_and_Number__c = ' hApi: Hapi- HAPI - FUnny Cat  ';
        update c;
        String docNumber = 'PL hApi:Hapi-HAPI -FUnny Cat';

        Test.startTest();
        Boolean isUnique = TB_CT_EmployeeEditForm.isDocumentUnique(c.Id, docNumber);
        Test.stopTest();

        Assert.isTrue(isUnique, 'Document should be unique since there is only 1 document such as given');
    }

    @IsTest
    private static void foundTwoDocumentsUniqueTest() {
        Contact c1 = [SELECT Id FROM Contact WHERE LastName =: PARAM_TEST_LAST_NAME LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = 'QuickTest'  LIMIT 1];
        c1.DT_Document_Issuing_Country__c = 'PL';
        c1.DT_Document_Series_and_Number__c = ' hApi: Hapi- HAPI - FUnny Cat  ';

        c2.DT_Document_Issuing_Country__c = 'PL';
        c2.DT_Document_Series_and_Number__c = ' hApI: Hapi- HAPI - F:U--nny CaT  ';
        update new List<Contact>{c1, c2};

        Test.startTest();
        Boolean isUnique = TB_CT_EmployeeEditForm.isDocumentUnique(c1.Id, c1.DT_Document_Issuing_Country__c + c1.DT_Document_Series_and_Number__c);
        Test.stopTest();

        Assert.isFalse(isUnique, 'Document should not be unique since there are two documents such as given');
    }

    @IsTest
    private static void isHEDidacticTest() {
        Contact c = [SELECT Id FROM Contact WHERE LastName =: PARAM_TEST_LAST_NAME LIMIT 1];
        c.TB_Didactic_Applicant_Counter_HE__c = 1;
        c.TB_Didactic_Applicant_Counter_PG__c = 1;
        update c;

        Test.startTest();
        Boolean isHEDidactic = TB_CT_EmployeeEditForm.isHEDidactic(c.Id);
        Test.stopTest();

        Assert.isTrue(isHEDidactic, 'Counters indicates that didactic should be HE.');
    }

    @IsTest
    private static void isNotHEDidacticTest() {
        Contact c = [SELECT Id FROM Contact WHERE LastName =: PARAM_TEST_LAST_NAME LIMIT 1];
        c.TB_Didactic_Applicant_Counter_HE__c = 0;
        c.TB_Didactic_Applicant_Counter_PG__c = 1;
        update c;

        Test.startTest();
        Boolean isHEDidactic = TB_CT_EmployeeEditForm.isHEDidactic(c.Id);
        Test.stopTest();

        Assert.isFalse(isHEDidactic, 'Counters indicates that didactic should be PG.');
    }
}
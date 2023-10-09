@IsTest
private class MySwpsJobPlacementApplicationModalTest {
    private static final Id JOB_OFFER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Offer__c.getSObjectType(),
        Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER
    );
    private static final Id OFFER_CONTRACT_JOB_OFFER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Offer_Contract__c.getSObjectType(),
        Constants.CAREER_SERVICES_OFFER_CONTRACT_RECORD_TYPE_JOB_OFFER_API_NAME
    );
    private static final Id ADMISSIONS_DICTIONARY_CONSENT_DEFINITION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        TB_Admissions_Dictionary__c.getSObjectType(),
        TB_Constants.TB_CONSENT_CONSENT_DEFINITION_RT_DEVNAME
    );
    private static final String TEST_ADMIN_USERNAME = 'Zbysiu@100.noga';
    private static final String TEST_STUDENT_USERNAME = 'osoba@studencka.test.com';

    @TestSetup
    private static void setup() {
        User adminUser = UserTestDataFactory.createAdminUser(TEST_ADMIN_USERNAME, true);

        System.runAs(adminUser) {
            Account company = AccountTestDataFactory.createBaseBusinessOrganizationAccount(
                Constants.ACCOUNT_STATUS_ACTIVE_API_NAME,
                true
            );

            Contact studentContact = ContactTestDataFactory.createStudent(true);

            Career_Services_Offer__c existingOffer = new CsOfferTestData()
                .withRecordType(JOB_OFFER_RECORD_TYPE_ID)
                .withCompany(company.Id)
                .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
                .save()
                .get();

            Campaign campaign = new CampaignTestData().save().get();
            Contract contract = new ContractTestData().withAccount(company.Id).save().get();

            new CsOfferContractTestData()
                .withRecordType(OFFER_CONTRACT_JOB_OFFER_RECORD_TYPE_ID)
                .withCampaign(campaign.Id)
                .withContract(contract.Id)
                .withStartDate(Date.today().addDays(-7))
                .withEndDate(Date.today().addDays(14))
                .withCareerServicesOffer(existingOffer.Id)
                .save();

            TB_Admissions_Dictionary__c bundle = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentBundle(1, true)[0];
            AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(
                1,
                bundle.Id,
                Constants.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS,
                true
            );

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, TEST_STUDENT_USERNAME, 'stud', true);
        }
    }

    @IsTest
    static void createJobPlacementApplicationWithoutCampaignMemberTest() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Offer__c jobPlacementOffer = [
            SELECT Id, (
                SELECT Id FROM Career_Services_Offer_Contracts__r
            )
            FROM Career_Services_Offer__c
            LIMIT 1
        ];

        Id createdApplicationId;

        Test.startTest();
        System.runAs(studentUser) {
            MySwpsJobPlacementApplicationModalCtrl.JobPlacementApplicationConsentsWrapper consents = fetchConsentWrappers();

            createdApplicationId = MySwpsJobPlacementApplicationModalCtrl.createJobPlacementApplication(
                jobPlacementOffer.Id,
                jobPlacementOffer.Career_Services_Offer_Contracts__r[0].Id,
                consents
            );
        }
        Test.stopTest();

        Assert.isNotNull(createdApplicationId);
    }

    @IsTest
    static void createJobPlacementApplicationWithCampaignMemberTest() {
        User studentUser = [SELECT Id, ContactId FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Offer__c jobPlacementOffer = [
            SELECT Id, (
                SELECT Id, Campaign__c FROM Career_Services_Offer_Contracts__r
            )
            FROM Career_Services_Offer__c
            LIMIT 1
        ];

        CampaignMember campaignMember = new CampaignMember(
            ContactId = studentUser.ContactId,
            CampaignId = jobPlacementOffer.Career_Services_Offer_Contracts__r[0].Campaign__c,
            Status = Constants.CAMPAIGN_MEMBER_STATUS_SENT_API_NAME
        );
        insert campaignMember;

        Id createdApplicationId;

        Test.startTest();
        System.runAs(studentUser) {
            MySwpsJobPlacementApplicationModalCtrl.JobPlacementApplicationConsentsWrapper consents = fetchConsentWrappers();

            createdApplicationId = MySwpsJobPlacementApplicationModalCtrl.createJobPlacementApplication(
                jobPlacementOffer.Id,
                jobPlacementOffer.Career_Services_Offer_Contracts__r[0].Id,
                consents
            );
        }
        Test.stopTest();

        CampaignMember campaignMemberPostTest = [
            SELECT Status
            FROM CampaignMember
            WHERE Id = :campaignMember.Id
        ];

        Assert.areNotEqual(campaignMember.Status, campaignMemberPostTest.Status);
        Assert.isNotNull(createdApplicationId);
    }

    @IsTest
    static void createJobPlacementApplicationWithCampaignMemberAndFilesTest() {
        User studentUser = [SELECT Id, ContactId FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Offer__c jobPlacementOffer = [
            SELECT Id, (
                SELECT Id, Campaign__c FROM Career_Services_Offer_Contracts__r
            )
            FROM Career_Services_Offer__c
            LIMIT 1
        ];

        CampaignMember campaignMember = new CampaignMember(
            ContactId = studentUser.ContactId,
            CampaignId = jobPlacementOffer.Career_Services_Offer_Contracts__r[0].Campaign__c,
            Status = Constants.CAMPAIGN_MEMBER_STATUS_SENT_API_NAME
        );
        insert campaignMember;

        Id createdApplicationId;

        Test.startTest();
        System.runAs(studentUser) {
            MySwpsJobPlacementApplicationModalCtrl.JobPlacementApplicationConsentsWrapper consents = fetchConsentWrappers();

            createdApplicationId = MySwpsJobPlacementApplicationModalCtrl.createJobPlacementApplication(
                jobPlacementOffer.Id,
                jobPlacementOffer.Career_Services_Offer_Contracts__r[0].Id,
                consents
            );

            MySwpsFileInputController.FileWrapper fileWrapper = new MySwpsFileInputController.FileWrapper();
            fileWrapper.base64 = EncodingUtil.base64Encode(Blob.valueOf('Mock'));
            fileWrapper.fileName = 'Test.pdf';
            MySwpsFileInputController.fileHandler(fileWrapper, createdApplicationId);
        }
        Test.stopTest();

        CampaignMember campaignMemberPostTest = [
            SELECT Status
            FROM CampaignMember
            WHERE Id = :campaignMember.Id
        ];

        Career_Services_Application__c createdApplication = [
            SELECT Id, (
                SELECT Id FROM ContentDocumentLinks
            )
            FROM Career_Services_Application__c
            WHERE Id = :createdApplicationId
        ];

        Assert.areNotEqual(campaignMember.Status, campaignMemberPostTest.Status);
        Assert.areEqual(1, createdApplication.ContentDocumentLinks.size());
        Assert.isNotNull(createdApplicationId);
    }

    private static MySwpsJobPlacementApplicationModalCtrl.JobPlacementApplicationConsentsWrapper fetchConsentWrappers() {
        MySwpsJobPlacementApplicationModalCtrl.JobPlacementApplicationConsentsWrapper consentWrapper = new MySwpsJobPlacementApplicationModalCtrl.JobPlacementApplicationConsentsWrapper();
        consentWrapper.formUrl = 'www.test-url.pl';
        consentWrapper.userDetails = 'testUserDetails';
        consentWrapper.checkedConsentIds = new List<Id>();

        for (TB_Admissions_Dictionary__c dictionary : [SELECT Id FROM TB_Admissions_Dictionary__c WHERE RecordTypeId = :ADMISSIONS_DICTIONARY_CONSENT_DEFINITION_RECORD_TYPE_ID]) {
            consentWrapper.checkedConsentIds.add(dictionary.Id);
        }

        return consentWrapper;
    }
}
@IsTest
public class CsApplicationHelperTest {
    private static final String TEST_ADMIN_USER_USERNAME = 'superadmin@test.invalid';

    @TestSetup
    static void setup() {
        User admin = UserTestDataFactory.createAdminUserWithPermissionSetAssigned(TEST_ADMIN_USER_USERNAME);

        System.runAs(admin) {
            Account account = new AccountTestData().save().get();
            Contract contract = ContractTestDataFactory.createContract(account.Id, Constants.CONTRACT_STATUS_NOT_IMPLEMENTED_API_NAME, true);

            Career_Services_Offer__c jobOffer = CsOfferTestDataFactory.createOfferWithRecordType(Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER, false);
            Career_Services_Offer__c internshipOffer = CsOfferTestDataFactory.createOfferWithRecordType(Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP, false);

            insert new List<Career_Services_Offer__c>{jobOffer, internshipOffer};

            insert new List<Career_Services_Offer_Contract__c>{
                CsOfferContractTestDataFactory.createPublishedOfferContractWithRecordType(contract.Id, jobOffer.Id, Constants.CAREER_SERVICES_OFFER_CONTRACT_RECORD_TYPE_JOB_OFFER_API_NAME, false),
                CsOfferContractTestDataFactory.createPublishedOfferContractWithRecordType(contract.Id, internshipOffer.Id, Constants.CAREER_SERVICES_OFFER_CONTRACT_RT_INTERNSHIP, false)
            };

            insert new List<Career_Services_Application__c>{
                CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_JOB_PLACEMENT_APPLICATION, jobOffer.Id, false),
                CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_JOB_PLACEMENT_APPLICATION, jobOffer.Id, false),
                CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP, internshipOffer.Id, false),
                CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP, internshipOffer.Id, false)
            };
        }
    }

    @IsTest
    static void countJobOfferApplicationsTestInsert() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Id jobOfferId = [SELECT Id FROM Career_Services_Offer__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER].Id;
        Career_Services_Offer_Contract__c beforeOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RECORD_TYPE_JOB_OFFER_API_NAME];

        List<Career_Services_Application__c> applications = new List<Career_Services_Application__c>{
            CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_JOB_PLACEMENT_APPLICATION, jobOfferId, false),
            CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_JOB_PLACEMENT_APPLICATION, jobOfferId, false)
        };

        Test.startTest();
        System.runAs(adminUser) {
            insert applications;
        }
        Test.stopTest();

        Career_Services_Offer_Contract__c afterOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RECORD_TYPE_JOB_OFFER_API_NAME];

        Assert.areEqual(2, beforeOfferContract.Candidates__c, 'There should be 2 candidates');
        Assert.areEqual(0, beforeOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
        Assert.areEqual(4, afterOfferContract.Candidates__c, 'There should be 4 candidates');
        Assert.areEqual(0, afterOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
    }

    @IsTest
    static void countInternshipOfferApplicationsTestInsert() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Id internshipOfferId = [SELECT Id FROM Career_Services_Offer__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP].Id;
        Career_Services_Offer_Contract__c beforeOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RT_INTERNSHIP];

        List<Career_Services_Application__c> applications = new List<Career_Services_Application__c>{
            CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP, internshipOfferId, false),
            CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP, internshipOfferId, false)
        };

        Test.startTest();
        System.runAs(adminUser) {
            insert applications;
        }
        Test.stopTest();

        Career_Services_Offer_Contract__c afterOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RT_INTERNSHIP];

        Assert.areEqual(2, beforeOfferContract.Candidates__c, 'There should be 2 candidates');
        Assert.areEqual(0, beforeOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
        Assert.areEqual(4, afterOfferContract.Candidates__c, 'There should be 4 candidates');
        Assert.areEqual(0, afterOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
    }

    @IsTest
    static void countJobOfferApplicationsTestUpdate() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Career_Services_Offer_Contract__c beforeOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RECORD_TYPE_JOB_OFFER_API_NAME];

        Career_Services_Application__c application = [SELECT Id FROM Career_Services_Application__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_APPLICATION_RT_JOB_PLACEMENT_APPLICATION LIMIT 1];
        application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_APPLICATION_ACCEPTED;
        
        Test.startTest();
        System.runAs(adminUser) {
            update application;
        }
        Test.stopTest();

        Career_Services_Offer_Contract__c afterOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RECORD_TYPE_JOB_OFFER_API_NAME];

        Assert.areEqual(2, beforeOfferContract.Candidates__c, 'There should be 2 candidates');
        Assert.areEqual(0, beforeOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
        Assert.areEqual(2, afterOfferContract.Candidates__c, 'There should be 2 candidates');
        Assert.areEqual(1, afterOfferContract.Candidates_Accepted__c, 'There should be 1 candidate accepted');
    }

    @IsTest
    static void countInternshipOfferApplicationsTestUpdate() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Career_Services_Offer_Contract__c beforeOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RT_INTERNSHIP];

        Career_Services_Application__c application = [SELECT Id FROM Career_Services_Application__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP LIMIT 1];
        application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_INTERNSHIP_READY_TO_PROCEED;
        
        Test.startTest();
        System.runAs(adminUser) {
            update application;
        }
        Test.stopTest();

        Career_Services_Offer_Contract__c afterOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RT_INTERNSHIP];

        Assert.areEqual(2, beforeOfferContract.Candidates__c, 'There should be 2 candidates');
        Assert.areEqual(0, beforeOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
        Assert.areEqual(2, afterOfferContract.Candidates__c, 'There should be 2 candidates');
        Assert.areEqual(1, afterOfferContract.Candidates_Accepted__c, 'There should be 1 candidate accepted');
    }

    @IsTest
    static void countJobOfferApplicationsTestDelete() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Career_Services_Offer_Contract__c beforeOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RECORD_TYPE_JOB_OFFER_API_NAME];

        Test.startTest();
        System.runAs(adminUser) {
            delete [SELECT Id FROM Career_Services_Application__c];
        }
        Test.stopTest();

        Career_Services_Offer_Contract__c afterOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RECORD_TYPE_JOB_OFFER_API_NAME];

        Assert.areEqual(2, beforeOfferContract.Candidates__c, 'There should be 2 candidates');
        Assert.areEqual(0, beforeOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
        Assert.areEqual(0, afterOfferContract.Candidates__c, 'There should be 0 candidates');
        Assert.areEqual(0, afterOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
    }

    @IsTest
    static void countInternshipOfferApplicationsTestDelete() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Career_Services_Offer_Contract__c beforeOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RT_INTERNSHIP];

        Test.startTest();
        System.runAs(adminUser) {
            delete [SELECT Id FROM Career_Services_Application__c];
        }
        Test.stopTest();

        Career_Services_Offer_Contract__c afterOfferContract = [SELECT Candidates__c, Candidates_Accepted__c FROM Career_Services_Offer_Contract__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_CONTRACT_RT_INTERNSHIP];

        Assert.areEqual(2, beforeOfferContract.Candidates__c, 'There should be 2 candidates');
        Assert.areEqual(0, beforeOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
        Assert.areEqual(0, afterOfferContract.Candidates__c, 'There should be 0 candidates');
        Assert.areEqual(0, afterOfferContract.Candidates_Accepted__c, 'There should be 0 candidates accepted');
    }

    @IsTest
    static void blockIndividualApplicationsWithoutAgreementTest() {
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c WHERE RecordType.DeveloperName = :Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP];
        Career_Services_Application__c application = CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP, offer.Id, true);
        application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_INTERNSHIP_READY_TO_PROCEED;

        Test.startTest();
        update application;
        Test.stopTest();

        Career_Services_Application__c assertApplication = [SELECT Status__c FROM Career_Services_Application__c WHERE Id = :application.Id];
        Assert.areEqual(Constants.CAREER_SERVICES_APPLICATION_STATUS_INTERNSHIP_READY_TO_PROCEED, assertApplication.Status__c, 'Status should be changed');
    }

    @IsTest
    static void blockIndividualApplicationsWithoutAgreementTestError() {
        String error;
        Career_Services_Offer__c offer = CsOfferTestDataFactory.createOffer(true);
        List<Career_Services_Application__c> applications = new List<Career_Services_Application__c>{
            CsApplicationTestDataFactory.createApplicationWithRecordType(Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP, false),
            CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP, offer.Id, false),
            CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP, offer.Id, false)
        };

        insert applications;

        for (Career_Services_Application__c application : applications) {
            application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_INTERNSHIP_READY_TO_PROCEED;
        }

        Test.startTest();
        try {
            update applications;
        } catch (Exception e) {
            error = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(error.contains(System.Label.Block_Individual_Applications_Without_Agreement_Error_Message), 'Error should contain custom label message');
    }

}
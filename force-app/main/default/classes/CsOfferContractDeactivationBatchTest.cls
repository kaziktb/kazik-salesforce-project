@IsTest
public class CsOfferContractDeactivationBatchTest {

    private static final String PROCESS_AUTOMATION_TEST_USER_USERNAME = 'pautom@email.com.test';

    @TestSetup
    public static void setup() {
        User processAutomationUser = UserTestDataFactory.createProcessAutomationUser(true, PROCESS_AUTOMATION_TEST_USER_USERNAME);

        System.runAs(processAutomationUser) {
            Account account = AccountTestDataFactory.createBaseBusinessOrganizationAccount(Constants.ACCOUNT_STATUS_ACTIVE_API_NAME, true);
            ContractTestDataFactory.createContract(account.Id, Constants.CONTRACT_STATUS_NOT_IMPLEMENTED_API_NAME, true);
            new CsOfferTestData().withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED).save().get();
            AutomationBypassTestDataFactory.createAutomationBypassConfigForUser(true, processAutomationUser.Id);
        }
    }

    @IsTest
    public static void executeForActivation() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c LIMIT 1];
        User processAutomationUser = [SELECT Id FROM User WHERE Username = :PROCESS_AUTOMATION_TEST_USER_USERNAME];
        Career_Services_Offer_Contract__c preBatchOfferContract = CsOfferContractTestDataFactory.createDraftOfferContractStartingToday(contract.Id, offer.Id, true);

        Test.startTest();
        System.runAs(processAutomationUser) {
            Database.executeBatch(new CsOfferContractDeactivationBatch());
        }
        Test.stopTest();

        Career_Services_Offer_Contract__c postBatchOfferContract = [SELECT Id, Status__c FROM Career_Services_Offer_Contract__c WHERE Id = :preBatchOfferContract.Id];

        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME, postBatchOfferContract.Status__c);
    }

    @IsTest
    public static void executeForDeactivationAsCompleted() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id, Status__c FROM Career_Services_Offer__c LIMIT 1];
        User processAutomationUser = [SELECT Id FROM User WHERE Username = :PROCESS_AUTOMATION_TEST_USER_USERNAME];
        Career_Services_Offer_Contract__c preBatchOfferContract = CsOfferContractTestDataFactory.createPublishedOfferContractToBeCompleted(contract.Id, offer.Id, true);

        Test.startTest();
        System.runAs(processAutomationUser) {
            Database.executeBatch(new CsOfferContractDeactivationBatch());
        }
        Test.stopTest();

        Career_Services_Offer_Contract__c postBatchOfferContract = [SELECT Id, Status__c, Career_Services_Offer__r.Status__c FROM Career_Services_Offer_Contract__c WHERE Id = :preBatchOfferContract.Id];

        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_COMPLETED_API_NAME, postBatchOfferContract.Status__c);
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED, offer.Status__c);
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_ARCHIVED_API_NAME, postBatchOfferContract.Career_Services_Offer__r.Status__c);
    }

    @IsTest
    public static void executeForDeactivationAsExpired() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id, Status__c FROM Career_Services_Offer__c LIMIT 1];
        User processAutomationUser = [SELECT Id FROM User WHERE Username = :PROCESS_AUTOMATION_TEST_USER_USERNAME];
        Career_Services_Offer_Contract__c preBatchOfferContract = CsOfferContractTestDataFactory.createPublishedOfferContractToBeExpired(contract.Id, offer.Id, true);

        Test.startTest();
        System.runAs(processAutomationUser) {
            Database.executeBatch(new CsOfferContractDeactivationBatch());
        }
        Test.stopTest();

        Career_Services_Offer_Contract__c postBatchOfferContract = [SELECT Id, Status__c, Career_Services_Offer__r.Status__c FROM Career_Services_Offer_Contract__c WHERE Id = :preBatchOfferContract.Id];

        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_EXPIRED_API_NAME, postBatchOfferContract.Status__c);
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED, offer.Status__c);
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_ARCHIVED_API_NAME, postBatchOfferContract.Career_Services_Offer__r.Status__c);
    }

    @IsTest
    public static void executeForDeactivationAndActivation() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id, Status__c FROM Career_Services_Offer__c LIMIT 1];
        User processAutomationUser = [SELECT Id FROM User WHERE Username = :PROCESS_AUTOMATION_TEST_USER_USERNAME];
        Career_Services_Offer_Contract__c preBatchOfferContractToDeactivate = CsOfferContractTestDataFactory.createPublishedOfferContractToBeExpired(contract.Id, offer.Id, true);
        Career_Services_Offer_Contract__c preBatchOfferContractToActivate = CsOfferContractTestDataFactory.createDraftOfferContractStartingToday(contract.Id, offer.Id, true);

        System.runAs(processAutomationUser) {
            Test.startTest();
                Database.executeBatch(new CsOfferContractDeactivationBatch());
            Test.stopTest();
        }

        Career_Services_Offer_Contract__c postBatchOfferContractToDeactivate = [SELECT Id, Status__c FROM Career_Services_Offer_Contract__c WHERE Id = :preBatchOfferContractToDeactivate.Id];
        Career_Services_Offer_Contract__c postBatchOfferContractToActivate = [SELECT Id, Status__c, Career_Services_Offer__r.Status__c FROM Career_Services_Offer_Contract__c WHERE Id = :preBatchOfferContractToActivate.Id];

        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_EXPIRED_API_NAME, postBatchOfferContractToDeactivate.Status__c);
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME, postBatchOfferContractToActivate.Status__c);
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED, offer.Status__c);
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED, postBatchOfferContractToActivate.Career_Services_Offer__r.Status__c);
    }
}
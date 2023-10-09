@IsTest
public with sharing class CsOfferContractHelperTest {
    @TestSetup
    public static void setup() {
        Account account = AccountTestDataFactory.createBaseBusinessOrganizationAccount(Constants.ACCOUNT_STATUS_ACTIVE_API_NAME, true);
        ContractTestDataFactory.createContract(account.Id, Constants.CONTRACT_STATUS_NOT_IMPLEMENTED_API_NAME, true);
        CsOfferTestDataFactory.createOffer(true);
    }

    @IsTest
    public static void validatePublishedContractDuplicationOnRecordCreate() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c LIMIT 1];

        Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

        Test.startTest();
        Database.SaveResult result = Database.insert(offerContract);
        Test.stopTest();

        Assert.areEqual(true, result.success);
    }

    @IsTest
    public static void validatePublishedContractDuplicationOnSecondRecordCreate() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c LIMIT 1];
        CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, true);

        Career_Services_Offer_Contract__c secondPublishedOfferContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

        Test.startTest();
        Database.SaveResult secondOfferInsertResult = Database.insert(secondPublishedOfferContract, false);
        Test.stopTest();

        Assert.areEqual(false, secondOfferInsertResult.success);
        Assert.areEqual(Label.Career_Services_Offer_Contract_Published_Dupe_Error, secondOfferInsertResult.errors[0].message);
    }
}
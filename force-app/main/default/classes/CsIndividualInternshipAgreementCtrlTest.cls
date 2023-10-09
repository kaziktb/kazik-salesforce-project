@IsTest
public class CsIndividualInternshipAgreementCtrlTest {

    @TestSetup
    static void setup() {
        Account careerOfficeAccount = new AccountTestData()
            .withName('Biuro Karier')
            .withRecordType(Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_DEPARTMENT_API_NAME))
            .save()
            .get();
        Career_Services_Offer__c offer = CsOfferTestDataFactory.createOffer(true);
        Contract contract = new ContractTestData().withAccount(careerOfficeAccount.Id).save().get();
        CsOfferContractTestDataFactory.createPublishedOfferContractWithRecordType(contract.Id, offer.Id, Constants.CAREER_SERVICES_OFFER_CONTRACT_RT_INTERNSHIP, true);
    }

    @IsTest
    static void getRelatedContractIdTest() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c];

        Test.startTest();
        Id assertContractId = CsIndividualInternshipAgreementCtrl.getRelatedContractId(offer.Id);
        Test.stopTest();

        Assert.areEqual(contract.Id, assertContractId, 'Ids should match');
    }

    @IsTest
    static void getCareerOfficeAccountIdTest() {
        Account careerOfficeAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Id assertCareerOfficeAccountId = CsIndividualInternshipAgreementCtrl.getCareerOfficeAccountId();
        Test.stopTest();

        Assert.areEqual(careerOfficeAccount.Id, assertCareerOfficeAccountId, 'Ids should match');
    }
}
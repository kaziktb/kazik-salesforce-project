@IsTest
public class CsOfferContractTestData {
    public static Integer count = 0;
    private final Career_Services_Offer_Contract__c record;

    public CsOfferContractTestData() {
        record = new Career_Services_Offer_Contract__c();
        count++;
        applyDefaults();
    }

    public CsOfferContractTestData(CsOfferContractTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public CsOfferContractTestData applyDefaults() {
        return this;
    }

    public CsOfferContractTestData copy() {
        return new CsOfferContractTestData(this);
    }

    public Career_Services_Offer_Contract__c get() {
        return record;
    }

    public CsOfferContractTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public CsOfferContractTestData withAgreementPeriod(Date value) {
        record.Agreement_Period__c = value;
        return this;
    }

    public CsOfferContractTestData withCampaign(Id value) {
        record.Campaign__c = value;
        return this;
    }

    public CsOfferContractTestData withCandidatesAccepted(Integer value) {
        record.Candidates_Accepted__c = value;
        return this;
    }

    public CsOfferContractTestData withCandidatesToSubmit(Integer value) {
        record.Candidates_To_Submit__c = value;
        return this;
    }

    public CsOfferContractTestData withCareerServicesOffer(Id value) {
        record.Career_Services_Offer__c = value;
        return this;
    }

    public CsOfferContractTestData withContract(Id value) {
        record.Contract__c = value;
        return this;
    }

    public CsOfferContractTestData withEndDate(Date value) {
        record.End_Date__c = value;
        return this;
    }

    public CsOfferContractTestData withAlreadyPaid() {
        record.Is_Paid__c = true;
        return this;
    }

    public CsOfferContractTestData withRecordType(Id value) {
        record.RecordTypeId = value;
        return this;
    }

    public CsOfferContractTestData withRecruitmentStages(String value) {
        record.Recruitment_Stages__c = value;
        return this;
    }

    public CsOfferContractTestData withStartDate(Date value) {
        record.Start_Date__c = value;
        return this;
    }

    public CsOfferContractTestData withStatus(String value) {
        record.Status__c = value;
        return this;
    }

    public CsOfferContractTestData withTeamDescription(String value) {
        record.Team_Description__c = value;
        return this;
    }

    public CsOfferContractTestData withInitialFeePaid() {
        record.Was_Initial_Fee_Paid__c = true;
        return this;
    }
}
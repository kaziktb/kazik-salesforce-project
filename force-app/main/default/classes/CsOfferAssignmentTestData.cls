@IsTest
public class CsOfferAssignmentTestData {
    public static Integer count = 0;
    private final Career_Services_Offer_Assignment__c record;

    public CsOfferAssignmentTestData() {
        record = new Career_Services_Offer_Assignment__c();
        count++;
        applyDefaults();
    }

    public CsOfferAssignmentTestData(CsOfferAssignmentTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public CsOfferAssignmentTestData applyDefaults() {
        return this.withIsObligatory(true);
    }

    public CsOfferAssignmentTestData copy() {
        return new CsOfferAssignmentTestData(this);
    }

    public Career_Services_Offer_Assignment__c get() {
        return record;
    }

    public CsOfferAssignmentTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public CsOfferAssignmentTestData withAccount(Id value) {
        record.Account__c = value;
        return this;
    }

    public CsOfferAssignmentTestData withOffer(Id value) {
        record.Career_Services_Offer__c = value;
        return this;
    }

    public CsOfferAssignmentTestData withSupervisor(Id value) {
        record.Internship_Supervisor__c = value;
        return this;
    }

    public CsOfferAssignmentTestData withDecisionMade() {
        record.Has_Decision_Been_Made__c = true;
        return this;
    }

    public CsOfferAssignmentTestData asAccepted() {
        record.Is_Accepted__c = true;
        return this;
    }

    public CsOfferAssignmentTestData withIsObligatory(Boolean value) {
        record.Is_Obligatory__c = value;
        return this;
    }
}
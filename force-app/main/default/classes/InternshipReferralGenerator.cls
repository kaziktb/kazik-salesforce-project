public with sharing class InternshipReferralGenerator {
    public enum ReferralType {English, Polish}

    public static Blob fetchReferralByRecordIdAndType(Id recordId, ReferralType type) {
        PageReference pageReference;

        switch on type {
            when English {
                pageReference = new PageReference(DT_Utils.INTERNSHIP_APPLICATION_REFERRAL_ENGLISH_URL);
            }
            when Polish {
                pageReference = new PageReference(DT_Utils.INTERNSHIP_APPLICATION_REFERRAL_POLISH_URL);
            }
            when else {
                return null;
            }
        }

        pageReference.getParameters().put('Id', recordId);

        return Test.isRunningTest() ? Blob.valueOf('PDF') : pageReference.getContentAsPDF();
    }
}
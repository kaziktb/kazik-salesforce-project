public with sharing class DT_JobPlacementSummaryGenerator {
    public enum SummaryType {English, Polish}

    public static Blob fetchSummaryPDFByIdAndType(Id recordId, SummaryType type) {
        Pagereference pageReference;

        switch on type {
            when English {
                pageReference = new PageReference(DT_Utils.JOB_OFFER_JOB_PLACEMENT_SUMMARY_ENGLISH_URL);
            }
            when Polish {
                pageReference = new PageReference(DT_Utils.JOB_OFFER_JOB_PLACEMENT_SUMMARY_POLISH_URL);
            }
            when else {
               return null;
            }
        }

        pageReference.getParameters().put('Id', recordId);
        
        return Test.isRunningTest() ? Blob.valueOf('PDF') : pageReference.getContentasPDF();
    }
}
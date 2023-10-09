/**
 * @description : Apex method able to invoke into flow, to handle file upload operations into Flow
 */

public with sharing class DT_FlowFileUploadViewHandler {
    @InvocableMethod(Label = 'Get Single Document Id by Content Type and Target Record Id')
    public static List <Results> fetchSingleDocumentId(List<Requests> inputRequests) {
        List<Results> responseWrapper= new List<Results>();
        Results response = new Results();
        Requests request = inputRequests.get(0);

        List<ContentDocument> documents = DT_FileUploadViewController.getDocumentsWithVersionsByRecordIds(
            request.targetRecordId, request.contentTypeApiName
        );
        for (ContentDocument document : documents) {
            if (document.ContentVersions != null && !document.ContentVersions.isEmpty()) {
                response.documentId = document.Id;
                break;
            }
        }
        responseWrapper.add(response);
        return responseWrapper;
    }

    public class Requests {
        @InvocableVariable(required = true label ='Content Type API Name')
        public String contentTypeApiName;
        @InvocableVariable(required = true label ='SObject record Id')
        public String targetRecordId;
    }

    public class Results {
        @InvocableVariable(label='Document Id' required=true)
        public Id documentId;
    }

}
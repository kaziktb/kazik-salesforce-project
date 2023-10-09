/**
 * Created by Aneta on 30/05/2023.
 */

public with sharing class TB_DocGenControllerBatch implements Database.Batchable<TB_DocGenController.DocRequestWrapper>, Database.Stateful {
    List<TB_DocGenController.DocRequestWrapper> documentGeneratorWrappers = new List<TB_DocGenController.DocRequestWrapper>();
    List<TB_DocGenController.DocResponseWrapper> docResponsesWrapper = new List<TB_DocGenController.DocResponseWrapper>();
    List<ContentVersion> responseContentVersions = new List<ContentVersion>();
    final String endPoint;

    public TB_DocGenControllerBatch (List<TB_DocGenController.DocRequestWrapper> wrappers, String endPoint) {
        this.documentGeneratorWrappers = wrappers;
        this.endPoint = endPoint;
    }

    public Iterable<TB_DocGenController.DocRequestWrapper> start(Database.BatchableContext context) {
        return documentGeneratorWrappers;
    }

    public void execute(Database.BatchableContext context, List<TB_DocGenController.DocRequestWrapper> wrappers) {
        for(TB_DocGenController.DocRequestWrapper singleWrapper : wrappers) {
            HttpResponse response = TB_DocGenController.sendPostRequest(endPoint, singleWrapper.wrap());
            if(response.getStatusCode() != 200) {
                docResponsesWrapper.add(new TB_DocGenController.DocResponseWrapper(response.getStatus(), false));
            }else {
                responseContentVersions.add(TB_DocGenController.prepareContentVersion(response.getBodyAsBlob(), singleWrapper));
            }
        }
    }

    public void finish (Database.BatchableContext context) {
        try {
            insert responseContentVersions;
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }
}
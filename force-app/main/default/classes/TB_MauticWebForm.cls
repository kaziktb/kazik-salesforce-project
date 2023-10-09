/**
 * Created by Think Beyond on 19/09/2021.
 */
 
@RestResource(urlMapping='/mauticwebform')
global class TB_MauticWebForm {
    @HttpPost
    global static String doGet() {
        String name = RestContext.request.params.get('name');
        TB_Web_Form_Submission__c webFormSubmission = new TB_Web_Form_Submission__c();
        webFormSubmission.TB_JSON_Header__c = String.valueOf((Map<String, String>)RestContext.request.headers);
        webFormSubmission.TB_JSON_Body__c = String.valueOf(RestContext.request.requestBody.toString());
        String body = '{';
        for(String str: RestContext.request.params.keySet()){
            body = body + '"' +str  + '"' +':' + '"' + RestContext.request.params.get(str) + '"' + ',';
        }
        body = body.substring(0, body.length()-1);
        body = body + '}';
        webFormSubmission.TB_Request_Body__c = body;
        insert webFormSubmission;
        return 'Exported to SF '+webFormSubmission.Id;
    }
}
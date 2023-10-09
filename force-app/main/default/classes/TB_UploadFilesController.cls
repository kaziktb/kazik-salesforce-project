/**
 * Created by Aneta on 23/11/2021.
 */

public with sharing class TB_UploadFilesController {
    @AuraEnabled
    public static String getUserSessionId() {
        String content = Page.TB_SessionIdWorkaround.getContent().toString();
        Integer s = content.indexOf('---sessionId') + '---sessionId'.length(),
            e = content.indexOf('sessionId---');
        return content.substring(s, e);
    }

    @AuraEnabled
    public static String getFileUploadUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v52.0/sobjects/ContentVersion/';
    }
}
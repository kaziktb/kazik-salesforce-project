/**
 * Created by adampeczkowski on 14/07/2023.
 */

global with sharing class TB_vu_QMSCancelInvocable
{
    private static final String CANCEL_URL = '/api/Slot/CancelReservation';
    private static final String TOKEN_URL = '/api/Authentication/GetEmptyToken/';
    
    @InvocableMethod(label='QMSCancel')
    public static void cancelReservation(List<Id> caseId)
    {
        Case processedCase;
        try
        {
            processedCase = [SELECT Id, TB_QMS_Reservation__c FROM Case WHERE Id IN :caseId];
        }
        catch(Exception e)
        {
            throw new AuraHandledException('Couldn\'t find case');
        }
        if(processedCase.TB_QMS_Reservation__c == null)
        {
            return;
        }
        TB_vu_QMSService.QMSSettingsWrapper qmsSettings = TB_vu_QMSService.getSettings();
        HttpRequest authReq = new HttpRequest();
        authReq.setEndpoint(qmsSettings.baseUrl+TOKEN_URL+qmsSettings.companyName);
        authReq.setMethod('GET');
        authReq.setHeader('Accept','application/json');
        authReq.setTimeout(120000);
        Http http = new Http();
        HttpResponse authRes = http.send(authReq);
        if(authRes.getStatusCode() != 200)
        {
            throw new AuraHandledException(TB_vu_Utils.registerLog('Failed to authenticate with QMS',TB_vu_QMSCancelInvocable.class.getName(),'',caseId[0]));
        }
        TokenResponse authResponse = (TokenResponse)JSON.deserialize(authRes.getBody(),TokenResponse.class);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(qmsSettings.baseUrl+CANCEL_URL+'/'+processedCase.TB_QMS_Reservation__c);
        req.setMethod('GET');
        req.setHeader('Authorization','Bearer ' + authResponse.token);
        req.setHeader('Accept','application/json');
        req.setTimeout(120000);
        HttpResponse res = http.send(req);
        if(res.getStatusCode() != 200)
        {
            throw new AuraHandledException(TB_vu_Utils.registerLog('Failed to cancel the reservation',TB_vu_QMSCancelInvocable.class.getName(),'',caseId[0]));
        }
    }
    
    public class TokenResponse
    {
        String token;
        
        public TokenResponse(String token)
        {
            this.token = token;
        }
    }
}
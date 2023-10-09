/**
 * Created by jowitakozlak on 09/12/2021.
 */

public with sharing class TB_GoogleIntegrator {
    transient HttpRequest req = new HttpRequest();
    TB_Webservice_Credential__mdt googleCredential;
    TB_Webservice_Credential__mdt googleService;
    Map<String, String> wsNameToEndpoint;
    String providerAuthorizationName = TB_Constants.TB_PROVIDER_GOOGLE_AUTHORIZATION;
    String providerServiceName = TB_Constants.TB_PROVIDER_GOOGLE_SERVICE;
    String authorizationToken;
    Integer authorizationExpiresIn = 0;
    DateTime expiresOn = System.now().addSeconds(authorizationExpiresIn);
    Blob jwtHeader;
    String jwtScope;
    String jwtAud;
    String jwtIss;
    String jwtSub;
    Long jwtIat = Datetime.now().getTime()/1000;
    Long jwtExp = jwtIat + 3600;
    String jwtKey;
    String jwtInput;

    public TB_GoogleIntegrator() {
        googleCredential = [
            SELECT TB_WSC_Endpoint__c, TB_WSC_Client_Email__c, TB_WSC_Private_Key__c,
                TB_WSC_JWT_Header__c, TB_WSC_Scope__c
            FROM TB_Webservice_Credential__mdt
            WHERE DeveloperName = :providerAuthorizationName
        ];
        googleService = [
            SELECT TB_WSC_Endpoint__c
            FROM TB_Webservice_Credential__mdt
            WHERE DeveloperName = :providerServiceName
        ];
    }

    public HttpResponse authorization () {
        wsNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(providerAuthorizationName);
        String reqString = googleCredential.TB_WSC_Endpoint__c + wsNameToEndpoint.get('Authorize');

        String jwt = createJWT(reqString);
        HttpRequest authRequest = new HttpRequest();
        authRequest.setEndpoint(reqString);
        String grantType = 'urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=';
        authRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        authRequest.setBody('grant_type=' + grantType + jwt);
        authRequest.setMethod('POST');

        HttpResponse resp = new Http().send(authRequest);
        TB_WebserviceUtils.throwExceptionWhenIntegrationFails(resp, new TB_GoogleIntegratorException(resp.getBody()));
        return resp;
    }

    public HttpResponse insertEvent (String meetingOrganizer, String meetingAttendees, Datetime meetingStart,
        Datetime meetingEnd, String recordId, String name, String meetingDescription) {
        wsNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(providerServiceName);
        String reqString = googleService.TB_WSC_Endpoint__c + wsNameToEndpoint.get('Insert Event');
        jwtSub = meetingOrganizer;
        prepareRequest();
        req.setEndpoint(reqString);
        Map<String, Object> urlMap = new Map<String, Object>{
            '{calendarId}' => jwtSub,
            'conferenceDataVersion' => 1,
            'sendUpdates' => 'all'
        };
        system.debug(meetingStart);
        Map<String, Object> bodyMap = new Map<String, Object>{
            'start.dateTime' => meetingStart.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Poland'),
            'end.dateTime' => meetingEnd.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Poland'),
            'conferenceData.createRequest.requestId' => recordId +
                String.valueOf(System.now()),
            'conferenceData.createRequest.conferenceSolutionKey.type' => 'hangoutsMeet',
            'summary' => name,
            'description' => meetingDescription
        };
        if(meetingAttendees != null) {
            bodyMap.put('attendees',prepareAttendeesList(meetingAttendees));
        }

        HttpResponse resp = TB_WebserviceUtils.sendPostRequestNoHeader(req, removeNullValuesFromMap(bodyMap), urlMap);
        TB_WebserviceUtils.throwExceptionWhenIntegrationFails(resp, new TB_GoogleIntegratorException(resp.getBody()));
        return resp;
    }

    public HttpResponse deleteEvent (String eventId, String meetingOrganizer) {
        wsNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(providerServiceName);
        String reqString = googleService.TB_WSC_Endpoint__c + wsNameToEndpoint.get('Delete Event');
        jwtSub = meetingOrganizer;
        prepareRequest();
        req.setEndpoint(reqString);
        Map<String, Object> urlMap = new Map<String, Object>{
            '{calendarId}' => jwtSub,
            '{eventId}' => eventId,
            'sendUpdates' => 'all'
        };

        HttpResponse resp = TB_WebserviceUtils.sendDeleteRequest(req, urlMap);
        TB_WebserviceUtils.throwExceptionWhenIntegrationFails(resp, new TB_GoogleIntegratorException(resp.getBody()));
        return resp;
    }

    public void prepareRequest() {
        req = new HttpRequest();
        if(System.now() >= expiresOn) {
            HttpResponse authorizationResponse = authorization();
            authorizationToken = (String) TB_WebserviceUtils.fetchFieldValueFromJSON(
                'access_token',
                authorizationResponse.getBody()
            );
            authorizationExpiresIn = (Integer) TB_WebserviceUtils.fetchFieldValueFromJSON(
                'expires_in',
                authorizationResponse.getBody()
            );
            expiresOn = System.now().addSeconds(authorizationExpiresIn);
        }
        req.setHeader('Authorization', 'Bearer ' + authorizationToken);
    }

    public String retrieveURL(String responseBody) {
        String url = (String) TB_WebserviceUtils.fetchFieldValueFromJSONNoStrict('hangoutLink', responseBody);
        return url;
    }

    public String retrieveEventID(String responseBody) {
        String eventId = (String) TB_WebserviceUtils.fetchFieldValueFromJSONNoStrict('id', responseBody);
        return eventId;
    }

    public String createJWT(String reqString){
        jwtAud = reqString;
        jwtIss = googleCredential.TB_WSC_Client_Email__c;
        jwtKey = googleCredential.TB_WSC_Private_Key__c;
        jwtScope = googleCredential.TB_WSC_Scope__c;
        jwtHeader = Blob.valueOf(googleCredential.TB_WSC_JWT_Header__c);
        String jwtHeaderEncoded = EncodingUtil.base64Encode(jwtHeader);

        Claim claim = new Claim();
        claim.iss = jwtIss;
        claim.sub = jwtSub;
        claim.scope = jwtScope;
        claim.aud = jwtAud;
        claim.exp = jwtExp;
        claim.iat = jwtIat;

        String jwtClaim = JSON.serialize(claim);
        jwtInput = base64urlEncode(Blob.valueOf(jwtClaim));
        jwtInput = jwtHeaderEncoded + '.' + jwtInput;
        Blob rs256sig = Crypto.sign(
            'RSA-SHA256',
            Blob.valueOf(jwtInput),
            EncodingUtil.base64Decode(jwtKey)
        );
        String signature = base64urlEncode(rs256sig);
        String jwt = jwtInput + '.' + signature;
        return jwt;
    }

    public List<Map<String,Object>> prepareAttendeesList(String meetingAttendees) {
        List<Map<String,Object>> attendees = new List<Map<String,Object>>();
        String attendeesRaw = meetingAttendees;
        Integer commasNumberCounter = attendeesRaw.countMatches(',');
        while (commasNumberCounter >= 0) {
            Map<String, Object> attendee = new Map<String, Object>();
            attendee.put('email', attendeesRaw.substringBefore(','));
            attendees.add(attendee);
            attendeesRaw = attendeesRaw.substringAfter(',').trim();
            commasNumberCounter--;
        }
        return attendees;
    }

    public class Claim{
        public String iss;
        public String sub;
        public String scope;
        public String aud;
        public Long exp;
        public Long iat;
    }

    public static String base64urlEncode(Blob input) {
        String output = EncodingUtil.base64Encode(input);
        output = output.replaceAll('\\+','-');
        output = output.replaceAll('/','_');
        output = output.replaceAll('=','');
        return output;
    }

    public Map<String, Object> removeNullValuesFromMap (Map<String, Object> mapToClean){

        for(String element: mapToClean.keySet()){
            if(mapToClean.get(element) == null){
                mapToClean.remove(element);
            }
        }
        return mapToClean;
    }

    public class TB_GoogleIntegratorException extends TB_CustomWithStackTraceException {
    }
}
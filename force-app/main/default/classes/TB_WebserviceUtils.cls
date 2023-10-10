public with sharing class TB_WebserviceUtils {
    public static HttpResponse sendPostRequest (HttpRequest req) {
        return sendPostRequest(req, new Map<String, Object>(), new Map<String, Object>());
    }

    public static HttpResponse sendPostRequest (HttpRequest req, Map<String,Object> bodyMap) {
        return sendPostRequest(req, bodyMap, new Map<String, Object>());
    }

    public static HttpResponse sendPostRequest(
        HttpRequest req,
        Map<String,Object> bodyMap,
        Map<String,Object> urlMap
    ) {
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(bodyMap));
        req.setEndpoint(TB_WebserviceUtils.prepareUrl(urlMap,req.getEndpoint()));
        req.setMethod('POST');
        req.setTimeout(120000);
        HttpResponse resp = new Http().send(req);
        return resp;
    }

    public static HttpResponse sendPostRequest(
        HttpRequest req,
        Map<String,Object> bodyMap,
        String bearerToken
    ) {
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + bearerToken);
        req.setBody(JSON.serialize(bodyMap));
        req.setMethod('POST');
        req.setTimeout(120000);
        HttpResponse resp = new Http().send(req);
        return resp;
    }

    //In progress
    public static HttpResponse sendPostRequestNoHeader(
        HttpRequest req,
        Map<String,Object> bodyMap,
        Map<String,Object> urlMap
    ) {
        req.setBody(String.valueOf(createBodyFromMapAdvanced(bodyMap)));
        req.setEndpoint(TB_WebserviceUtils.prepareUrl(urlMap,req.getEndpoint()));
        req.setMethod('POST');
        HttpResponse resp = new Http().send(req);
        return resp;
    }

    public static HttpResponse sendPostRequestHeaders(
            HttpRequest req,
            Map<String,Object> bodyMap,
            Map<String,Object> urlMap
    ) {
        req.setBody(String.valueOf(createBodyFromMapAdvanced(bodyMap)));
        req.setEndpoint(TB_WebserviceUtils.prepareUrl(urlMap,req.getEndpoint()));
        req.setMethod('POST');
        HttpResponse resp = new Http().send(req);
        return resp;
    }

    //In progress
    public static HttpResponse sendDeleteRequest (
        HttpRequest req,
        Map<String,Object> urlMap
    ) {
        req.setEndpoint(TB_WebserviceUtils.prepareUrl(urlMap,req.getEndpoint()));
        req.setMethod('DELETE');
        HttpResponse resp = new Http().send(req);
        return resp;
    }

    public static Map<String, String> createServiceNameToEndpoint (String providerName) {
        List<TB_Webservice_Endpoint__mdt> webserviceEndpoints = [
            SELECT DeveloperName, TB_Webservice_Suffix__c, TB_Service__c, TB_Named_Credential__c
            FROM TB_Webservice_Endpoint__mdt
            WHERE TB_Provider__c = :providerName
        ];
        System.debug(webserviceEndpoints);
        Map<String, String> serviceNameToEndpoint = new Map<String, String>();
        for (TB_Webservice_Endpoint__mdt wse : webserviceEndpoints) {
            String endpoint = '';
            if ( String.isNotBlank(wse.TB_Named_Credential__c)) {
                endpoint += 'callout:'+ wse.TB_Named_Credential__c;
            }
            if (String.isNotBlank(wse.TB_Webservice_Suffix__c)) {
                endpoint += wse.TB_Webservice_Suffix__c;
            }
            serviceNameToEndpoint.put(wse.TB_Service__c, endpoint);
        }
        return serviceNameToEndpoint;
    }

    public static Object fetchFieldValueFromJSON(String path, String body) {
        String jsonObject;
        Map<String,Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(body);

        while (path.contains('.')) {
            jsonObject = path.substringBefore('.');
            if (jsonMap.containsKey(jsonObject)) {
                jsonMap = (Map<String, Object>) jsonMap.get(jsonObject);
                path = path.substringAfter('.');
            } else {
                throw new TB_WebServiceUtilsException('Object not exist');
            }
        }
        if (!jsonMap.containsKey(path)) {
            throw new TB_WebServiceUtilsException('Value not exist');
        }
        return jsonMap.get(path);
    }

    //In progress
    public static Object fetchFieldValueFromJSONNoStrict(String path, String body) {
        String jsonObject;
        Map<String,Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(body);

        while (path.contains('.')) {
            jsonObject = path.substringBefore('.');
            if (jsonMap.containsKey(jsonObject)) {
                jsonMap = (Map<String, Object>) jsonMap.get(jsonObject);
                path = path.substringAfter('.');
            } else {
                return null;
            }
        }
        if (!jsonMap.containsKey(path)) {
            return null;
        }
        return jsonMap.get(path);
    }

    //In progress
    public static String createBodyFromMapAdvanced (Map<String,Object> bodyParameters) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen = createBodyFromMapAdvanced(bodyParameters, gen);
        return gen.getAsString();
    }

    //In progress
    private static JSONGenerator createBodyFromMapAdvanced (Map<String,Object> bodyParameters, JSONGenerator gen) {
        gen.writeStartObject();
        for (String key : bodyParameters.keySet()) {
            Integer dotsNumberCounter = key.countMatches('.');
            Integer dotsNumber = dotsNumberCounter;
            if(bodyParameters.get(key) instanceof Map<String,Object>){
                gen = createBodyFromMapAdvanced((Map<String,Object>)bodyParameters.get(key), gen);
            } else if(bodyParameters.get(key) instanceof List<Map<String,Object>>) {
                gen.writeFieldName(key);
                gen.writeStartArray();
                for(Map<String,Object> mapParameterToValue : (List<Map<String,Object>>)bodyParameters.get(key)){
                    gen = createBodyFromMapAdvanced(mapParameterToValue, gen);
                }
                gen.writeEndArray();
            } else {
                if (bodyParameters.get(key) != null) {
                    if(dotsNumberCounter > 0) {
                        String extractedKey = key;
                        gen.writeFieldName(extractedKey.substringBefore('.'));
                        extractedKey = key.substringAfter('.');
                        dotsNumberCounter--;
                        while(dotsNumbercounter > 0) {
                            gen.writeStartObject();
                            gen.writeFieldName(extractedKey.substringBefore('.'));
                            extractedKey = extractedKey.substringAfter('.');
                            dotsNumberCounter--;
                        }
                        gen.writeStartObject();
                        gen.writeObjectField(extractedKey,bodyParameters.get(key));
                        while(dotsNumberCounter != dotsNumber) {
                            gen.writeEndObject();
                            dotsNumberCounter++;
                        }
                    } else {
                        gen.writeFieldName(key);
                        gen.writeObject(bodyParameters.get(key));
                    }
                } else {
                    gen.writeNull();
                }
            }
        }
        gen.writeEndObject();
        return gen;
    }

    public static String prepareUrl(Map<String,Object> urlMap, String url) {
        url += '?';
        Boolean isAnyAdded = false;
        for (String key: urlMap.keySet()) {
            if (key.contains('{') && key.contains('}')) {
                url = url.replace(key, String.valueOf(urlMap.get(key)));
            } else {
                url += key + '=' + urlMap.get(key) + '&';
                isAnyAdded = true;
            }
        }
        if (isAnyAdded) {
            url = url.removeEnd('&');
        }
        url = url.removeEnd('?');
        return url;
    }

    public static String urlEncode(Map<String, String> vals) {
        String result = '';
        for(String thisKey : vals.keySet()) {
            result += EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(vals.get(thisKey), 'UTF-8') + '&';
        }
        return result.removeEnd('&');
    }

    public static void throwExceptionWhenIntegrationFails (HttpResponse resp, Exception e) {
        if (resp.getStatusCode() != TB_Constants.HTTP_STATUS_OK
            && resp.getStatusCode() != TB_Constants.HTTP_STATUS_NO_CONTENT
            && resp.getStatusCode() != 302
        ) {
            throw e;
        }
    }
    public class TB_WebServiceUtilsException extends TB_CustomWithStackTraceException {}
}
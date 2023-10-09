public with sharing class TB_HttpCalloutFactory {
    private static TB_HttpCalloutFactory HttpCalloutFactoryInstance;
    public static final String NamedCredentialPrefix = 'callout:Progressive/';
    @TestVisible private Map<String, TB_Http_Callout__mdt> CommandInfo;
    @TestVisible private static Boolean GetResponseFromMock = false;
    protected List<String> EndpointParams = new List<String>();
    private static Organization OrgInfo;

    public static TB_HttpCalloutFactory getInstance() {
        if (HttpCalloutFactoryInstance == null) {
            HttpCalloutFactoryInstance = new TB_HttpCalloutFactory();
        }
        return HttpCalloutFactoryInstance;
    }

    private Boolean isSandbox() {
        if (OrgInfo == null) {
            OrgInfo = [select IsSandbox from Organization limit 1];
        }
        return OrgInfo.IsSandbox;
    }

    private TB_HttpCalloutFactory() {
        CommandInfo = new Map<String, TB_Http_Callout__mdt>();
        for (TB_Http_Callout__mdt command_info : [
            SELECT DeveloperName, Timeout__c, Service_Name__c, Http_Method__c, Mock_Class_Name__c,
                Endpoint__c,Sandbox_End_Point__c, Endpoint_Params__c, Use_Named_Credential__c, Service_Version__c, Content_Type__c
            FROM TB_Http_Callout__mdt
        ]) {
            CommandInfo.put(command_info.DeveloperName, command_info);
        }
    }

    public HttpResponse performHttpCallout(HttpCalloutAbstractBuilder command_implementation) {
        try {
            TB_Http_Callout__mdt command_info = CommandInfo.get(command_implementation.CommandName);
            Boolean run_mock = Test.isRunningTest() || (TB_Integration__c.getInstance().Is_Active__c == false);
            command_implementation.setBody();
            command_implementation.setMethod(command_info.Http_Method__c);
            command_implementation.setCreateLogRecord();

            String service_name =
                String.isNotEmpty(command_info.Service_Name__c) ? command_info.Service_Name__c  : '';
            String service_version =
                String.isNotEmpty(command_info.Service_Version__c) ? command_info.Service_Version__c : '';
            String content_type =
                String.isNotEmpty(command_info.Content_Type__c) ? command_info.Content_Type__c : '';
            String correlation_id = TB_RandomDataUtils.generateUUID();

            String endpoint = isSandbox() && String.isNotBlank(command_info.Sandbox_End_Point__c) ? command_info.Sandbox_End_Point__c : command_info.Endpoint__c;
            String endpoint_final = command_info.Use_Named_Credential__c ? NamedCredentialPrefix + endpoint : endpoint;

            command_implementation
                .setHeader('X-Service-Name', service_name)
                .setHeader('X-Service-Version', service_version)
                .setHeader('Content-Type', content_type)
                .setHeader('Accept', 'application/json')
                .setHeader('Correlation-ID', correlation_id)
                .setOAuthHeader()
                .setHeaders()
                .setTimeout(command_info.Timeout__c)
                .setEndpointParams()
                .setEndpoint(endpoint_final);
               
                if (run_mock) {
                    HttpCalloutMock mock_instance =
                        (HttpCalloutMock)Type.forName(command_info.Mock_Class_Name__c).newInstance();
                    HTTPRequest http_request = command_implementation.HttpApiRequest;
                    command_implementation.HttpApiResponse = mock_instance.respond(http_request);
                    command_implementation.handleCommandResponse();
                    return command_implementation.HttpApiResponse;
                }
                command_implementation.sendRequest();

        } catch (CalloutException e) {
            command_implementation.CommandSuccessful = false;
            command_implementation.CommandError = e.getMessage();
        }

        return command_implementation.HttpApiResponse;
    }

    public Inherited Sharing abstract class HttpCalloutAbstractBuilder {
        @TestVisible protected HttpRequest HttpApiRequest;
        @TestVisible protected HttpResponse HttpApiResponse;
        public String CommandName;
        public Boolean CommandSuccessful;
        public String CommandError;
        public Boolean CreateLogRecord;
        public List<String> EndpointParams;

        public HttpCalloutAbstractBuilder(String command_name) {
            CommandName = command_name;
            HttpApiRequest = new HttpRequest();
        }

        @TestVisible protected virtual String buildJsonBody() {
            return '';
        }

        @TestVisible protected virtual Dom.Document buildXMLBody() {
            return null;
        }

        @TestVisible protected virtual Boolean getCreateLogRecord() {
            return true;
        }

        @TestVisible protected virtual List<String> getEndpointParams() {
            return new List<String>();
        }

        protected virtual Map<String, String> buildMapHeaders() {
            return new Map<String, String>();
        }

        protected HttpCalloutAbstractBuilder setMethod(String method) {
            HttpApiRequest.setMethod(method);
            return this;
        }

        protected virtual HttpCalloutAbstractBuilder setBody() {
            String json_body = buildJsonBody();
            Dom.Document xml_body = buildXMLBody();
            System.debug(json_body);
            if (String.isNotBlank(json_body)) {
                HttpApiRequest.setBody(json_body);
            } else if (xml_body != null) {
                HttpApiRequest.setBodyDocument(xml_body);
            }

            return this;
        }

        protected HttpCalloutAbstractBuilder setEndpoint(String endpoint) {
            if (!EndpointParams.isEmpty()) {
                endpoint = String.format(endpoint, EndpointParams);
            }
            HttpApiRequest.setEndpoint(endpoint);
            return this;
        }

        protected virtual HttpCalloutAbstractBuilder setTimeout(Decimal time_out) {
            if (time_out != null) {
                HttpApiRequest.setTimeout(Integer.valueOf(time_out));
            } else {
                HttpApiRequest.setTimeout(120000);
            }
            return this;
        }

        protected HttpCalloutAbstractBuilder setCreateLogRecord() {
            CreateLogRecord = getCreateLogRecord();
            return this;
        }

        protected HttpCalloutAbstractBuilder setEndpointParams() {
            EndpointParams = getEndpointParams();
            return this;
        }

        public String getEndpoint() {
            return HttpApiRequest.getEndpoint();
        }

        public String getBody() {
            return HttpApiRequest.getBody();
        }

        private void handleCommandResponse() {
            String no_ability_error_message =
                    'There is no ability to show data: BE response is invalid: ';
            if (HttpApiResponse.getStatusCode() == 200) {
                CommandSuccessful = true;
            } else if (HttpApiResponse.getStatusCode() == 403) {
                CommandError = 'Access Denied. Please ask administrator to check credentials.';
                CommandSuccessful = false;
            } else if (HttpApiResponse.getStatusCode() == 500) {
                try {
                    String error_message =
                        (String)((Map<String, Object>)JSON.deserializeUntyped(HttpApiResponse.getBody())).get('message');
                    CommandError = 'Internal Server Error: ' + error_message;
                } catch (Exception e) {
                    CommandError = no_ability_error_message + HttpApiResponse.getBody();
                }
                CommandSuccessful = false;
            } else {
                try {
                    CommandError =
                        'Bad request. ' + (String)((Map<String, Object>)JSON.deserializeUntyped(HttpApiResponse.getBody()))
                        .get('message');
                    CommandSuccessful = false;
                } catch (Exception e) {
                    CommandError = no_ability_error_message + HttpApiResponse.getBody();
                    CommandSuccessful = false;
                }
            }

            if (CreateLogRecord) {
                insert TB_LogUtils.registerLog(CommandError, TB_HttpCalloutFactory.class);       
            }
        }

        protected HttpCalloutAbstractBuilder setHeaders() {
            Map<String, String> headers = buildMapHeaders();
            for (String header_name: headers.keySet()) {
                HttpApiRequest.setHeader(header_name, headers.get(header_name));
            }
            return this;
        }

        protected virtual HttpCalloutAbstractBuilder setOAuthHeader() {
            HttpApiRequest.setHeader('Authorization', '');  //NOPMD - don't enforce using named credentials
            return this;
        }

        protected HttpCalloutAbstractBuilder setHeader(String key, String value) {
            HttpApiRequest.setHeader(key, value);
            return this;
        }

        protected HttpResponse sendRequest() {
            try {
                HttpApiResponse = new Http().send(HttpApiRequest);
                handleCommandResponse();
            } catch(Exception e) {
                if(CreateLogRecord) {
                    insert TB_LogUtils.registerLog(e, TB_HttpCalloutFactory.class);
                }
                System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage());
            }
            return HttpApiResponse;
        }
    }
}

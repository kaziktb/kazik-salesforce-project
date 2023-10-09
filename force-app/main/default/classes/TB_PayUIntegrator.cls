public with sharing class TB_PayUIntegrator {
    public Map<String, String> wsNameToEndpoint;
    String providerName = TB_Constants.TB_PROVIDER_PAYU;
    public String bearerToken;

    private class TB_PayUIntegratorException extends Exception {}

    public TB_PayUIntegrator() {
        wsNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(providerName);
        if (!Test.isRunningTest()) {
            authorize();
        }
    }

    public HttpResponse authorize() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(wsNameToEndpoint.get('Authorization'));

        HttpResponse resp = TB_WebserviceUtils.sendPostRequest(req);
        TB_WebserviceUtils.throwExceptionWhenIntegrationFails(resp, new TB_PayUIntegratorException(resp.getBody()));
        this.bearerToken = String.valueOf(TB_WebserviceUtils.fetchFieldValueFromJSON(
            'access_token', resp.getBody()
        ));
        return resp;
    }

    public HttpResponse createOrder(String posId, hed__Application__c application) {
        HttpRequest req = new HttpRequest();

        String bankAccount = '';
        if (application.TB_Admissions_Fee_Currency__c == 'PLN') {
            bankAccount = application.TB_Applying_To_Offered_Product__r.TB_Admissions_Fee_BA_PLN__c;
        } else if (application.TB_Admissions_Fee_Currency__c == 'EUR') {
            bankAccount = application.TB_Applying_To_Offered_Product__r.TB_Admissions_Fee_BA_EUR__c;
        }

        req.setEndpoint(wsNameToEndpoint.get('Order Create'));
        String notifyUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/PayU?applicationId=' + application.Id;
        Map<String, Object> bodyMap = new Map<String, Object> {
            'notifyUrl' => notifyUrl,
            'continueUrl' => Url.getSalesforceBaseUrl().toExternalForm() + '/s/application/' + application.Id,
            'customerIp' => '127.0.0.1',
            'merchantPosId' => posId,
            'description' => String.isNotBlank(application.TB_Admissions_Payment_Title__c) ? application.TB_Admissions_Payment_Title__c : 'Recruitment fee',
            'currencyCode' => application.TB_Admissions_Fee_Currency__c,
            'totalAmount' => (application.TB_Admissions_Fee__c * 100).intValue(),
            'buyer' => new Map<String, String> {
                'email' => String.isNotBlank(application.hed__Applicant__r.Email) ? application.hed__Applicant__r.Email : 'test@test.com',
                'phone' => application.hed__Applicant__r.Phone,
                'firstName' => application.hed__Applicant__r.FirstName,
                'lastName' => application.hed__Applicant__r.LastName
            },
            'products' => new List< Map<String, Object>> {
                new Map<String, Object> {
                    'name' => String.isNotBlank(application.TB_Admissions_Payment_Title__c) ? application.TB_Admissions_Payment_Title__c : 'Recruitment fee',
                    'unitPrice' => (application.TB_Admissions_Fee__c * 100).intValue(),
                    'quantity' => '1'
                }
            },
            'targetAccount' => bankAccount
        };

        if (application.TB_Foreigner__c) {
            Map<String, String> payMethod = new Map<String, String>{
                'type' => 'PBL',
                'value' => 'c'
            };
            bodyMap.put ('payMethods',
                new Map<String, Object> {
                    'payMethod' => payMethod
                }
            );
        }

        HttpResponse resp = TB_WebserviceUtils.sendPostRequest(
            req, bodyMap, this.bearerToken
        );

        TB_WebserviceUtils.throwExceptionWhenIntegrationFails(resp, new TB_PayUIntegratorException(resp.getBody()));

        return resp;
    }
}
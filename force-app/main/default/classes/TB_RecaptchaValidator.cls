public with sharing class TB_RecaptchaValidator {
    private static String recaptchaSecretKey = '6Lfk_6EdAAAAAA7ZC8SKKdiym2yY2GciEFwN4VjS';
        
    @AuraEnabled
    public static String validateRequest(String recaptchaResponse){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setBody('secret=' + recaptchaSecretKey + '&response=' + recaptchaResponse);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if (result.containsKey('success') && result.get('success') == true) {
                Decimal threshold = 0.5;
                Decimal score = (Decimal)result.get('score');
                if (score > threshold) {
                    return 'success';
                }
                else {
                    return 'failure';
                }
            } 
            else {
                return 'failure';
            }
        }
        return 'invalid request';
    }
}
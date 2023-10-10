public with sharing class TB_PaymentComponentController{
    @AuraEnabled
    public static hed__Application__c getApplication(Id applicationId) {
        return [
            SELECT Id, TB_Admissions_Fee_Currency__c, TB_Admissions_Fee__c, hed__Application_Status__c,
                hed__Applicant__c, hed__Applicant__r.Email,hed__Applicant__r.Phone,
                hed__Applicant__r.FirstName, hed__Applicant__r.LastName, TB_Admissions_Fee_Status__c,
                TB_Admissions_Payment_Title__c, Name, TB_Applying_To_Offered_Product__r.TB_Admissions_Fee_BA_EUR__c,
                TB_Applying_To_Offered_Product__r.TB_Admissions_Fee_BA_PLN__c, TB_Employer_Name__c, TB_Employer_VAT_ID__c,
                TB_Employer_Address__c, TB_Employer_ZIP__c, TB_Employer_City__c, TB_Employer_Country__c,
                TB_No_Admissions_Fee__c, TB_Hide_No_Admissions_Fee__c, TB_VAT_Invoice_Requested__c,
                TB_No_Admissions_Fee_Reason__c, TB_Product_Group__c
            FROM hed__Application__c
            WHERE Id = :applicationId
        ];
    }

    @AuraEnabled
    public static TB_Payment__c createPayment(hed__Application__c application) {
        String posId = TB_Technical_Key__mdt.getInstance('TB_PayU_Pos_Id').TB_Value__c;
        HttpResponse resp = new TB_PayUIntegrator().createOrder(posId, application);
        String orderId = String.valueOf(TB_WebserviceUtils.fetchFieldValueFromJSON('orderId', resp.getBody()));

        TB_Payment__c payment = new TB_Payment__c (
            TB_Transaction_Order_Number__c = orderId,
            TB_Uri__c = String.valueOf(TB_WebserviceUtils.fetchFieldValueFromJSON('redirectUri', resp.getBody())),
            TB_Pos_Id__c = posId,
            TB_Application__c = application.Id,
            TB_Contact__c = application.hed__Applicant__c,
            TB_Amount__c = application.TB_Admissions_Fee__c,
            TB_Currency__c = application.TB_Admissions_Fee_Currency__c,
            TB_Payment_Method__c = 'PayU',
            TB_Payment_Title__c = String.isNotBlank(application.TB_Admissions_Payment_Title__c) ? application.TB_Admissions_Payment_Title__c : 'SWPS University - Admissions fee: ' + application.Name,
            TB_Payment_Date__c = Date.today(),
            TB_Transaction_Started_On__c = Datetime.now(),
            RecordTypeId = TB_Constants.PAYMENT_ADMISSIONS_FEE_RT_ID
        );

        if (payment.TB_Currency__c == 'PLN') {
            payment.TB_Bank_Account_Number__c = application.TB_Applying_To_Offered_Product__r.TB_Admissions_Fee_BA_PLN__c;
        } else if (payment.TB_Currency__c == 'EUR') {
            payment.TB_Bank_Account_Number__c = application.TB_Applying_To_Offered_Product__r.TB_Admissions_Fee_BA_EUR__c;
        }

        insert payment;

        return payment;
    }

    @AuraEnabled
    public static TB_Payment__c getNewestOpenPayment(Id applicationId) {
        List<TB_Payment__c> payments = [
            SELECT TB_Uri__c
            FROM TB_Payment__c
            WHERE TB_Application__c = :applicationId
            AND TB_Provider_Status__c NOT IN ('COMPLETED', 'CANCELED')
            ORDER BY CreatedDate DESC
        ];

        if (payments.isEmpty()) {
            return null;
        } else {
            return payments[0];
        }
    }

    @AuraEnabled
    public static TB_Payment__c getNewestCompletedPayment(Id applicationId) {
        List<TB_Payment__c> payments = [
            SELECT TB_Uri__c
            FROM TB_Payment__c
            WHERE TB_Application__c = :applicationId
            AND TB_Provider_Status__c = 'COMPLETED'
            ORDER BY CreatedDate DESC
        ];

        if (payments.isEmpty()) {
            return null;
        } else {
            return payments[0];
        }
    }
}
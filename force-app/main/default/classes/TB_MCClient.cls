/**
 * Created by Adam Czeczuk on 15/09/2021.
 */

global without sharing class TB_MCClient {
    
    @InvocableMethod(label='sendToMC')
    public static void createDEEntry(List<WrapperClass> entryList) {
        switch on entryList[0].journey {
            when 'Admissions' {
                TB_MCAdmissionsQueueableBatch batch = new TB_MCAdmissionsQueueableBatch(entryList);
                if(!Test.isRunningTest()) Database.executeBatch(batch);
                }
            when 'WebFormSubmission' {
                TB_MCMauticWebFormQueueableBatch batch = new TB_MCMauticWebFormQueueableBatch(entryList);
                if(!Test.isRunningTest()) Database.executeBatch(batch);
                }
            when 'CommerceOrder' {
                TB_MCCommerceOrderQueueableBatch batch = new TB_MCCommerceOrderQueueableBatch(entryList);
                if(!Test.isRunningTest()) Database.executeBatch(batch);
                }    
            when 'CommerceOrderItem' {
                TB_MCCommerceOrderItemQueueableBatch batch = new TB_MCCommerceOrderItemQueueableBatch(entryList);
                if(!Test.isRunningTest()) Database.executeBatch(batch);
                }                
        }
    }

    global class WrapperClass {
        @InvocableVariable
        global Id recordId;
        @InvocableVariable
        global String eventKey;
        @InvocableVariable
        global String journey;
    }
}
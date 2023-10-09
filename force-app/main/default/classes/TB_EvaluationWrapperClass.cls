/**
 * Created by Aneta on 17/08/2021.
 */

global with sharing class TB_EvaluationWrapperClass {
    @InvocableVariable @AuraEnabled
    public String fieldApiName;
    @InvocableVariable @AuraEnabled
    public Id evaluationId;
    @InvocableVariable @AuraEnabled
    public String markValue;
    
}
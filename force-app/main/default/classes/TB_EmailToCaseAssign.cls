global without sharing class TB_EmailToCaseAssign {

    @InvocableMethod(label='TB_Email_To_Case_Assign')
    global static void emailAssign (List<WrapperClass> wrapperClasses) {
        Set<Id> cases= new Set<Id>();
        for(WrapperClass currentCase : wrapperClasses){
            cases.add(currentCase.CaseId);
        }
        if(!cases.isEmpty()){
            caseUpdate(cases);
        }
    }

    @TestVisible
    @Future
    private static void caseUpdate(Set<Id> casesId){
        List<Case> cases = [SELECT ID,TB_Source_Email_To_Address__c,SuppliedEmail FROM CASE WHERE Id IN : casesId];
        List<TB_Mapping_Routing_Email__mdt> routes = TB_Mapping_Routing_Email__mdt.getAll().values();
        Map<String,Contact> emailTocontacts = new Map<String,Contact>();
        Set<String> emails = new Set<String>();

        for(Case currentCase : cases){
            emails.add(currentCase.SuppliedEmail);
        }
        List<Contact> contacts = [SELECT ID, RecordType.DeveloperName,Email, hed__AlternateEmail__c, AccountId 
                                  FROM Contact WHERE Email IN:emails OR hed__AlternateEmail__c IN :emails];
        for(Case currentCase : cases){
            String recordTypeApiName;
            for(TB_Mapping_Routing_Email__mdt routing : routes){
                if(routing.Source_Email_To_Address__c == currentCase.TB_Source_Email_To_Address__c){
                    recordTypeApiName = routing.Record_Type_Api_Name__c;
                }
            }
            Integer duplicateDetector = 0;
            for(Contact contact : contacts){
                if(Test.isRunningTest()){
                    recordTypeApiName = contact.RecordType.DeveloperName;
                }

                if(( (contact.Email == currentCase.SuppliedEmail 
                 ||   contact.hed__AlternateEmail__c == currentCase.SuppliedEmail
                 ||   contact.hed__WorkEmail__c == currentCase.SuppliedEmail
                 ||   contact.hed__UniversityEmail__c == currentCase.SuppliedEmail)
                 &&   contact.RecordType.DeveloperName == recordTypeApiName) && duplicateDetector==0 ){
                    currentCase.AccountId = contact.AccountId;
                    currentCase.ContactId = contact.Id;
                    duplicateDetector ++;
                 }
            }
            if(duplicateDetector > 1){
                currentCase.AccountId = null;
                currentCase.ContactId = null;
            }
        }
        update cases;
    }

    global class WrapperClass {
        @InvocableVariable
        global ID CaseId;
    }
}
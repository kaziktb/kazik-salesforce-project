public with sharing class TB_vu_ApplicationAwaitingController {
    /** @description ownerId == TB_Decision_Maker__c contactId */
    public Id ownerId {get;set;}
    private final static String DECISION_TYPE = 'Request_For_A_Decision';
    private final static String CASE_STATUS = 'Awaiting_Decision_Maker';

    public String getOwnerLanguage() {
        return [SELECT TB_User__r.LanguageLocaleKey FROM Contact WHERE Id= :ownerId LIMIT 1].TB_User__r.LanguageLocaleKey;
    }

    public List<TB_Operation__c> getRelatedOperations() {
        Id recordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get('TB_Decision').getRecordTypeId();

        return  [SELECT TB_Case_Number__c, 
                             TB_Contact_Name__c, 
                             TB_Album_Number__c,
                             TB_Case__r.CreatedDate,
                             toLabel(TB_Case_Subcategory__c),
                             TB_Case__r.TB_Program_Enrollment__r.hed__Program_Plan__r.DT_Study_Field_PL__c,
                             TB_Case__r.TB_Program_Enrollment__r.hed__Program_Plan__r.DT_Study_Field_EN__c,
                             TB_Case__r.TB_Program_Enrollment__r.hed__Account__r.Parent.TB_Account_Name_PL__c,
                             TB_Case__r.TB_Program_Enrollment__r.hed__Account__r.Parent.TB_Account_Name_EN__c,
                             TB_Decision_Maker__c,
                             TB_Decision_Maker__r.TB_User__r.LanguageLocaleKey
                             FROM TB_Operation__c 
                             WHERE TB_Decision_Maker__c= :ownerId
                             AND TB_Type__c =:DECISION_TYPE
                             AND TB_Is_Decision__c = FALSE
                             AND RecordTypeId =: recordTypeId 
                             AND TB_Decision_Maker__c != NULL
                             AND TB_Case__r.Status =: CASE_STATUS
                             ORDER BY TB_Decision_Maker__c ASC
                             ];
    }
}
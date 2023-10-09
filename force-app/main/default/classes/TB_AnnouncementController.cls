public with sharing class TB_AnnouncementController {

    @AuraEnabled
    public static String getMessageLogics(hed__Application__c application, String language) {
        try {
            Set<TB_Admissions_Logic__c> admissionsLogics = new Set<TB_Admissions_Logic__c>();
            Set<Id> admissionsContentsIds = new Set<Id>();
            for (TB_JSON_Wrapper__c jsonWrapper : [
                SELECT Id, TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Parent_JSON_Wrapper__r.TB_Object_Id__c = :application.TB_Admissions_Process_Id__c
                AND TB_Record_Type_Dev_Name__c = :TB_re_Constants.ADMISSIONS_LOGIC_MESSAGE_LOGIC_RT
                ORDER BY TB_Order__c
            ]) {
                TB_Admissions_Logic__c admissionsLogic = (TB_Admissions_Logic__c) JSON.deserialize(
                    jsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Logic__c.class
                );
                if (admissionsLogic.TB_Active__c == true) {
                    admissionsLogics.add(admissionsLogic);
                    admissionsContentsIds.add(admissionsLogic.TB_Admissions_Content__c);
                }
            }
            Set<TB_Admissions_Content__c> admissionsContents = new Set<TB_Admissions_Content__c>();
            for (TB_JSON_Wrapper__c contentWrapper : [
                SELECT Id, TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_Id__c IN :admissionsContentsIds
            ]) {
                TB_Admissions_Content__c admissionsContent = (TB_Admissions_Content__c) JSON.deserialize(
                    contentWrapper.TB_Wrapper_Value__c, TB_Admissions_Content__c.class
                );
                if (admissionsContent.TB_Active__c == true) {
                    admissionsContents.add(admissionsContent);
                }
            }

            List<MessageLogicsWrapper> messageWrappers = new List<MessageLogicsWrapper>();
            for (TB_Admissions_Logic__c logic : admissionsLogics) {
                for (TB_Admissions_Content__c content : admissionsContents) {
                    if (logic.TB_Admissions_Content__c == content.Id && logic.TB_Admissions_Content__c != null) {
                        MessageLogicsWrapper singleWrapper = new MessageLogicsWrapper(logic);
                        singleWrapper.message = String.valueOf(content.get('TB_Content_' + language + '__c'));
                        messageWrappers.add(singleWrapper);
                    }
                }
            }

            return JSON.serialize(messageWrappers);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public class MessageLogicsWrapper {
        @AuraEnabled public TB_Admissions_Logic__c al { get; set; }
        @AuraEnabled public String message { get; set; }

        public MessageLogicsWrapper(TB_Admissions_Logic__c al) {
            this.al = al;
        }
    }

}
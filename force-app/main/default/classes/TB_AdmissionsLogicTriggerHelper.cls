public without sharing class TB_AdmissionsLogicTriggerHelper {
    public static void fillJSONFields(List<TB_Admissions_Logic__c> admissionsLogics) {
        for (TB_Admissions_Logic__c logic : admissionsLogics) {
            logic.TB_Redirect_Logic_JSON__c = TB_AdmissionsProcessTriggerHelper.readAdmissionsLogic(String.valueOf(logic.TB_Redirect_Logic__c));
            logic.TB_Display_Logic_JSON__c = TB_AdmissionsProcessTriggerHelper.readAdmissionsLogic(String.valueOf(logic.TB_Display_Logic__c));
        }
    }

    public static void handleJsonFieldCorrectness (List<TB_Admissions_Logic__c> admissionsLogics, Map<Id, TB_Admissions_Logic__c> idToOldLogics) {
        List<String> fieldsForVerification = new List<String> {'TB_Display_Logic_JSON__c', 'TB_Redirect_Logic_JSON__c'};
        TB_JsonFieldValidation.handleJsonFieldCorrectness(admissionsLogics, idToOldLogics, fieldsForVerification);
    }

    public static void handleLogicFieldCorrectness (List<TB_Admissions_Logic__c> admissionsLogics, Map<Id, TB_Admissions_Logic__c> idToOldLogics) {
        List<String> fieldsForVerification = new List<String> {'TB_Display_Logic__c', 'TB_Redirect_Logic__c'};
        TB_JsonFieldValidation.handleLogicFieldCorrectness(admissionsLogics, idToOldLogics, fieldsForVerification);
    }
}
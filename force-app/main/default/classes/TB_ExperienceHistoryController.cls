public without sharing class TB_ExperienceHistoryController {
    @AuraEnabled
    public static List<TB_Experience_History__c> getExperienceHistories(Id applicationId) {
        try {
            return [
                SELECT TB_PD_Module_Name_EN__c,
                TB_PD_Module_Name_PL__c,TB_Score__c, TB_ECTS__c,
                toLabel(TB_Decision__c) TB_Decision_Label,
                TB_Educational_Institution__c, TB_PD_Subject__c
                FROM TB_Experience_History__c
                WHERE TB_Application__c = :applicationId AND RecordType.DeveloperName = :TB_Constants.RECORD_TYPE_DEVELOPER_NAME_TB_PROGRAM_DIFFERENCES AND IsDeleted = False AND TB_Active__c = True
                ORDER BY TB_Order__c
                LIMIT 50000
            ];
        } catch(Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_ExperienceHistoryController.class.getName(), e.getStackTraceString(), applicationId));
        }
    }
}
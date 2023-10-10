/**
 * Created by adriangawryszewski on 12/29/21.
 */

public with sharing class TB_PDDifferencesController {

    @AuraEnabled(Cacheable=true)
    public static List<TB_Experience_History__c> getProgramDifferencesExperiencesForApp(String recordId) {

        return [
                SELECT Id,
                        TB_PD_Module_Name_PL__c,
                        TB_PD_Module_Name_EN__c,
                        TB_Application__c,
                        TB_Score__c,
                        TB_Hours__c,
                        TB_ECTS__c,
                        TB_Decision__c,
                        TB_Educational_Institution__c,
                        TB_PD_Subject__c,
                        RecordTypeId
                FROM
                        TB_Experience_History__c
                WHERE
                RecordTypeId = :TB_Constants.TB_PD_DIFFERENCES_EXP_RT_ID
                AND
                TB_Application__c = :recordId
                ORDER BY TB_Order__c ASC, CreatedDate
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static TB_Application_Document__c getProgramDifferencesDocumentSlot(String recordId) {
        return [
                SELECT Id,
                        TB_Download_URL__c,
                        TB_Content_Version_Id__c
                FROM
                        TB_Application_Document__c
                WHERE
                TB_Document_Category__c = :TB_Constants.TB_APP_DOCUMENT_CAT_PD_DOCUMENT
                AND
                TB_Application__c = :recordId
                LIMIT 1
        ];
    }

    @AuraEnabled
    public static void upsertProgramDifferencesExperiencesForApp(List<TB_Experience_History__c> expsToUpdate) {
        try {
            upsert expsToUpdate;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }

    @AuraEnabled
    public static void deleteProgramDifferencesExperiencesForApp(Id expsId) {
        try {
            Database.delete(expsId);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }

    @AuraEnabled 
    public static void deleteProgramDifferencesDocumentSlotDoc(String appDocId) {
        try {
            upsert new TB_Application_Document__c(
                    Id = appDocId,
                    TB_Status__c = TB_Constants.TB_APP_DOCUMENT_STATUS_EMPTY
            );
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }
}
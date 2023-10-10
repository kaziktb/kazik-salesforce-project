/**
 * Created by aleksandragonta-kacperska on 08/04/2022.
 */

public without sharing class DT_SpecialtySearchController {
   /* public static final String SPECIALTY_PL = 'Specjalność';

    public DT_SpecialtySearchController () {
    }

    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> getSpecialtyResultsByName(String searchTerm) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        Set<Id> departmentIds = new Set<Id>();
        Id specialtyRecordTypeId = DT_Utils.getRecTypeIdByDevName(DT_Utils.ACCOUNT_SPECIALTY_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT);

        User user = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];

        if (user.ContactId == null) {
            return results;
        }

        for (hed__Program_Enrollment__c enrollment : [
                SELECT hed__Account__r.ParentId
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c = :user.ContactId
        ]) {
            departmentIds.add(enrollment.hed__Account__r.ParentId);
        }

        if(String.isNotEmpty(searchTerm)) {
            searchTerm = String.escapeSingleQuotes(searchTerm);
            searchTerm = '%' + searchTerm + '%';
            for(Account specialty : [
                    SELECT Id, DT_Specialty_PL__c, DT_Specialty_EN__c, FullName__c
                    FROM Account
                    WHERE
                        RecordTypeId =:specialtyRecordTypeId
                            AND (
                                DT_Specialty_PL__c LIKE :searchTerm
                                    OR DT_Specialty_EN__c LIKE :searchTerm
                                    OR FullName__c LIKE :searchTerm
                            )
                        AND DT_Has_Active_Students__c = true
                        AND Parent.ParentId IN :departmentIds
                    ORDER BY DT_Specialty_PL__c
                    LIMIT 10
            ]) {
                results.add(new LookupSearchResult(
                        specialty.Id,
                        SPECIALTY_PL ,
                        'standard:household',
                        specialty.FullName__c,
                        Label.DT_Specialty,
                        specialty.DT_Specialty_PL__c
                ));
            }
        }
        return results;
    }*/
}
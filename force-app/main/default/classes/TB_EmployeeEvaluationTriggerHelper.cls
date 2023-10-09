/**
 * Created by kacperjachowicz on 17/08/2021.
 */

public with sharing class TB_EmployeeEvaluationTriggerHelper {

    public static void updateRelationships(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        EmployeeEvaluationIdWrapper employeeEvaluationIdWrapper = prepareEmployeeEvaluationIdWrapper(newMap, oldMap);
        if (employeeEvaluationIdWrapper.newEmployeeEvaluationId2ContactId.values().isEmpty()) {
            return;
        }
        Map<Id, Contact> processedContacts = retrieveRelatedContacts(employeeEvaluationIdWrapper.newEmployeeEvaluationId2ContactId);
        List<TB_Data_Collection__c> dataCollectionsToUpdate =
            processValuesToUpdate(processedContacts, employeeEvaluationIdWrapper.newEmployeeEvaluationId2ContactId,
                retrieveDataCollection(employeeEvaluationIdWrapper.oldEmployeeEvaluationId2ContactId, newMap)
            );

        update dataCollectionsToUpdate;
    }

    private static EmployeeEvaluationIdWrapper prepareEmployeeEvaluationIdWrapper(
        Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

        Map<Id, TB_Employee_Evaluation__c> newMapEmp = (Map<Id, TB_Employee_Evaluation__c>) newMap;
        Map<Id, TB_Employee_Evaluation__c> oldMapEmp = (Map<Id, TB_Employee_Evaluation__c>) oldMap;
        Map<Id, Id> newEmployeeEvaluationId2ContactId = new Map<Id, Id>();
        Map<Id, Id> oldEmployeeEvaluationId2ContactId = new Map<Id, Id>();

        for (TB_Employee_Evaluation__c employeeEvaluation : newMapEmp.values()) {
            if (newMapEmp.get(employeeEvaluation.Id).TB_Evaluator__c != oldMapEmp.get(employeeEvaluation.Id).TB_Evaluator__c) {
                newEmployeeEvaluationId2ContactId.put(employeeEvaluation.Id, newMapEmp.get(employeeEvaluation.Id).TB_Evaluator__c);
                oldEmployeeEvaluationId2ContactId.put(employeeEvaluation.Id, oldMapEmp.get(employeeEvaluation.Id).TB_Evaluator__c);
            }
            if (newMapEmp.get(employeeEvaluation.Id).TB_Supervisor__c != oldMapEmp.get(employeeEvaluation.Id).TB_Supervisor__c) {
                newEmployeeEvaluationId2ContactId.put(employeeEvaluation.Id, newMapEmp.get(employeeEvaluation.Id).TB_Supervisor__c);
                oldEmployeeEvaluationId2ContactId.put(employeeEvaluation.Id, oldMapEmp.get(employeeEvaluation.Id).TB_Supervisor__c);
            }
            if (newMapEmp.get(employeeEvaluation.Id).TB_Evaluated__c != oldMapEmp.get(employeeEvaluation.Id).TB_Evaluated__c) {
                newEmployeeEvaluationId2ContactId.put(employeeEvaluation.Id, newMapEmp.get(employeeEvaluation.Id).TB_Evaluated__c);
                oldEmployeeEvaluationId2ContactId.put(employeeEvaluation.Id, oldMapEmp.get(employeeEvaluation.Id).TB_Evaluated__c);
            }
        }
        return new EmployeeEvaluationIdWrapper(newEmployeeEvaluationId2ContactId, oldEmployeeEvaluationId2ContactId);
    }

    private static List<TB_Data_Collection__c> processValuesToUpdate(Map<Id, Contact> processedContacts,
        Map<Id, Id> newEmployeeEvaluationId2ContactId, List<TB_Data_Collection__c> dataCollections) {
        SObject sObj;
        String fieldValue;
        List<TB_Data_Collection__c> dataCollectionsToUpdate = new List<TB_Data_Collection__c>();
        for (TB_Data_Collection__c singleDataCollection : dataCollections) {
            if (singleDataCollection.TB_Source_Object_Id__c != null) {
                sObj = processedContacts.get(newEmployeeEvaluationId2ContactId.get(singleDataCollection.TB_Employee_Evaluation__c));
                fieldValue = String.valueOf (
                    sObj.get(singleDataCollection.TB_Source_Object_Field__c)
                );
            } else if (singleDataCollection.TB_Target_Object_Id__c != null) {
                sObj = processedContacts.get(newEmployeeEvaluationId2ContactId.get(singleDataCollection.TB_Employee_Evaluation__c));
                fieldValue = String.valueOf (
                    sObj.get(singleDataCollection.TB_Target_Object_Field__c)
                );
            }
            singleDataCollection.TB_Value_Text__c = fieldValue;
            singleDataCollection.TB_Target_Object_Id__c = newEmployeeEvaluationId2ContactId.get(singleDataCollection.TB_Employee_Evaluation__c);
            singleDataCollection.TB_Source_Object_Id__c = newEmployeeEvaluationId2ContactId.get(singleDataCollection.TB_Employee_Evaluation__c);

            dataCollectionsToUpdate.add(singleDataCollection);
        }
        return dataCollectionsToUpdate;
    }

    private static List<TB_Data_Collection__c> retrieveDataCollection(Map<Id, Id>oldEmployeeEvaluationId2ContactId, Map<Id, SObject> newMap) {
        return [
            SELECT
                Id,
                TB_Value_Text__c,
                TB_Source_Object_Id__c,
                TB_Source_Object_Field__c,
                TB_Target_Object_Id__c,
                TB_Target_Object_Field__c,
                TB_Employee_Evaluation__c
            FROM TB_Data_Collection__c
            WHERE (
                (
                    TB_Target_Object_Id__c IN :oldEmployeeEvaluationId2ContactId.values()
                    AND TB_Target_Object__c IN ('Evaluator', 'Evaluated', 'Supervisor')
                ) OR (
                    TB_Source_Object_Id__c IN :oldEmployeeEvaluationId2ContactId.values()
                    AND TB_Source_Object__c IN ('Evaluator', 'Evaluated', 'Supervisor')
                )
            )
            AND TB_Employee_Evaluation__c IN:newMap.keySet()
        ];
    }

    private static Map<Id, Contact> retrieveRelatedContacts(Map<Id, Id> newEmployeeEvaluationId2ContactId) {
        return new Map<Id, Contact>([
            SELECT AccountId,
                DT_AccountRecordType__c,
                Email,
                FirstName,
                LastName,
                hed__Primary_Organization__c,
                Id,
                IndividualId,
                Name,
                OwnerId,
                Primary_Academic_Program__c,
                Primary_Department__c,
                Primary_Educational_Institution__c,
                Primary_Sports_Organization__c,
                Primary_Student_Organization__c,
                TB_Dean__c,
                TB_Employee_Group__c,
                TB_Employee_Number__c,
                TB_Employee_Position_Group__c,
                TB_Included_In_Evaluations__c,
                TB_Institute_Director_1__c,
                TB_Institute_Director_2__c,
                TB_Is_Exclusion_for_Contact__c,
                TB_ORCID__c,
                TB_Scientific_Discipline_1__c,
                TB_Scientific_Discipline_1_X__c,
                TB_Scientific_Discipline_1_Text__c,
                TB_Scientific_Discipline_2__c,
                TB_Scientific_Discipline_2_X__c,
                TB_Scientific_Discipline_2_Text__c,
                TB_User__c,
                Title
            FROM Contact
            WHERE Id IN:newEmployeeEvaluationId2ContactId.values()
        ]);
    }

    public class EmployeeEvaluationIdWrapper {
        public Map<Id, Id> newEmployeeEvaluationId2ContactId;
        public Map<Id, Id> oldEmployeeEvaluationId2ContactId;

        public EmployeeEvaluationIdWrapper(Map<Id, Id>newEmployeeEvaluationId2ContactId, Map<Id, Id>oldEmployeeEvaluationId2ContactId) {
            this.newEmployeeEvaluationId2ContactId = newEmployeeEvaluationId2ContactId;
            this.oldEmployeeEvaluationId2ContactId = oldEmployeeEvaluationId2ContactId;
        }
    }
}
/**
 * Created by Aneta on 17/08/2021.
 */

public with sharing class TB_UpdateFinalMark {
    @InvocableMethod(label='updateEvaluationMark')
    public static void updateEvaluationMark(List<TB_EvaluationWrapperClass> evaluationWrapperClasses) {
        TB_EvaluationWrapperClass wrapper = evaluationWrapperClasses[0];
        String evaluationId = wrapper.evaluationId;
        String query = 'SELECT Id ';
            query += ' FROM TB_Employee_Evaluation__c WHERE Id = :evaluationId';
        TB_Employee_Evaluation__c evaluationRecord = new TB_Employee_Evaluation__c();
        try{
            evaluationRecord = Database.query(query);
            evaluationRecord.put(wrapper.fieldApiName,wrapper.markValue);
            update  evaluationRecord;
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }
}
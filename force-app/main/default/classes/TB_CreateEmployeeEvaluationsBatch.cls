/**
 * Created by Aneta on 14/07/2021.
 */

public with sharing class TB_CreateEmployeeEvaluationsBatch implements Database.Batchable<SObject>, Database.Stateful {

    String finishMethodName='';
    String processId;
    Boolean executeFlag;
    List<SObject> employeeEvaluations;

    public TB_CreateEmployeeEvaluationsBatch (
        List<TB_Employee_Evaluation__c> employeeEvaluations, String finishMethodName,
        String processId, Boolean executeFlag
    ) {
        this.employeeEvaluations = employeeEvaluations;
        this.finishMethodName = finishMethodName;
        this.processId = processId;
        this.executeFlag = executeFlag;
    }

    public List<SObject> start(Database.BatchableContext context) {
        return employeeEvaluations;
    }

    public void execute(Database.BatchableContext context, List<SObject> employeeEvaluations) {
        try {
            insert employeeEvaluations;
        } catch(Exception e) {
            executeFlag = false;
            insert TB_LogUtils.registerLog(e , TB_CreateEmployeeEvaluations.class);
        }
    }

    public void finish (Database.BatchableContext context) {
        //TODO zapewne te metody będą połączone w jedno?
        switch on finishMethodName {
            when 'ConnectEmployeeEvaluations' {
                TB_ConnectEmployeeEvaluations.connectEmployeeEvaluations(this.processId, this.executeFlag);
            }
            when 'ConnectScientistEmployeeEvaluations' {
                TB_ConnectScientistEmployeeEvaluations.connectScientistEmployeeEvaluations(this.processId, this.executeFlag);
            }
            when 'SendMailToAdministrator' {
                TB_SendNotificationProcessCompleted.SendNotificationToProcessAdministrator(this.processId, this.executeFlag);
            }
        }
    }
}
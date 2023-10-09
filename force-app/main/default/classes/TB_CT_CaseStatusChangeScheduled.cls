public with sharing class TB_CT_CaseStatusChangeScheduled implements Schedulable, Database.Batchable<sObject> {

  public Database.QueryLocator start(Database.BatchableContext BC) {
    Id recordtypeIdHE;
    Id recordtypeIdPG;
    List<RecordType> recTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case'];
    for(RecordType rt: recTypes) {
      if(rt.DeveloperName == 'Contract_Teachers_HE_Case') {
        recordtypeIdHE = rt.Id;
      } else if (rt.DeveloperName == 'Contract_Teachers_PG_Case') {
        recordtypeIdPG = rt.Id;
      }
    }
    String query =  'SELECT Id, TB_CT_Inactivity_Days__c FROM Case WHERE TB_CT_Inactivity_Days__c > 3 AND (RecordTypeId = :recordtypeIdHE OR RecordTypeId = :recordtypeIdPG) AND Status = \'Ready\'';
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<Case> scope) {
    Set<Id> resultIds = (new Map<Id, SObject>(scope)).keySet();
    List<Case> updatedCases = new List<Case>();

    for (Case c : [SELECT Id, Status FROM Case WHERE Id IN :resultIds]) {
      c.Status = 'Closed';
      updatedCases.add(c);
    }

    update updatedCases;
  }

  public void finish(Database.BatchableContext BC) {
  }

  public void execute(SchedulableContext sc) {
    Database.executeBatch(new TB_CT_CaseStatusChangeScheduled(), 100);
  }
}

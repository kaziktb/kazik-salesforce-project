@isTest
public with sharing class TB_CT_CaseStatusChangeScheduledTest {
  @testSetup
  static void setup() {
    Id recordTypeIdHE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contract_Teachers_HE_Case').getRecordTypeId();
    List<Case> cases = new List<Case>();
    Contact con = new Contact(LastName = 'Tester');
    insert con;
    Datetime startTime = Datetime.now();
    Datetime datetimeSubtractDay = startTime.addDays(-15);
    for(Integer i = 0; i< 4; i++) {
      cases.add(new Case(Origin = 'Email', Status = 'Ready', ContactId = con.Id, TB_Last_Activity_Date__c = datetimeSubtractDay, RecordTypeId = recordTypeIdHE));
    }
    insert cases;
  }

  @IsTest
  static void should_testBatchable() {
      Id recordTypeIdHE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contract_Teachers_HE_Case').getRecordTypeId();
      Test.StartTest();
      Database.executeBatch(new TB_CT_CaseStatusChangeScheduled());
      Test.StopTest();
      List<Case> cClosed = [SELECT Id FROM Case WHERE Status = 'Closed' AND RecordTypeId =:recordTypeIdHE ];
      System.assertEquals(
        4,
        cClosed.size(),
        'Incorrect number of records has changed Status'
      );
  }

  @IsTest
  private static void testSchedulable() {
    Test.startTest();
    System.schedule(
      'Delete Logs Schedulable',
      '0 0 1 * * ?',
      new TB_CT_CaseStatusChangeScheduled()
    );
    Test.stopTest();

    List<AsyncApexJob> batchJobs = [
      SELECT Id, Status
      FROM AsyncApexJob
      WHERE
        ApexClass.Name = 'TB_CT_CaseStatusChangeScheduled'
        AND JobType = 'BatchApex'
    ];

    System.assertEquals(
      1,
      batchJobs.size(),
      'Unexpected number of batch jobs ran: ' + batchJobs
    );
    System.assertEquals(
      'Queued',
      batchJobs[0].Status,
      'Job planned with an unexpected status.'
    );
  }
}

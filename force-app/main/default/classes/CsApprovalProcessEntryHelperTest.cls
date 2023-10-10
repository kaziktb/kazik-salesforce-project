@IsTest
public with sharing class CsApprovalProcessEntryHelperTest {
    private static final String DECISION_VALUE = 'Approve';

    @TestSetup
    public static void setup() {
        Career_Services_Offer__c offer = CsOfferTestDataFactory.createInstitutionalInternshipOffer(true);
        Id institutionalInternshipApprovalProcessRecordTypeId = Utils.getRecordTypeIdByDevName(
            Approval_Process__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INTERNSHIP_OFFER
        );
        ApprovalProcessTestDataFactory.createActiveApprovalProcessForRecord(offer.Id, institutionalInternshipApprovalProcessRecordTypeId, true);
    }
    @IsTest
    public static void createDecisionEntry() {
        Approval_Process__c approvalProcess = [SELECT Id, Stage__c FROM Approval_Process__c LIMIT 1];

        Test.startTest();
        CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, DECISION_VALUE, true);
        Test.stopTest();

        Approval_Process__c postEntryCreationApprovalProcess = [
            SELECT Id, Stage__c, (
                SELECT Id, Stage__c, Value__c, RecordType.DeveloperName
                FROM Approval_Process_Entries__r
            )
            FROM Approval_Process__c
            WHERE Id = :approvalProcess.Id
        ];

        Assert.areEqual(1, postEntryCreationApprovalProcess.Approval_Process_Entries__r.size());
        Assert.areEqual(DECISION_VALUE, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].Value__c);
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_DECISION_RECORD_TYPE, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].RecordType.DeveloperName);
        Assert.areEqual(approvalProcess.Stage__c, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].Stage__c);
    }

    @IsTest
    public static void createCommentEntry() {
        final String COMMENT_VALUE = 'Test comment';
        Approval_Process__c approvalProcess = [SELECT Id, Stage__c FROM Approval_Process__c LIMIT 1];
        Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, DECISION_VALUE, true);

        Test.startTest();
        CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, COMMENT_VALUE, decisionEntry.Id, true);
        Test.stopTest();

        Approval_Process__c postEntryCreationApprovalProcess =
        [
            SELECT Id, Stage__c, (
                SELECT Id, Stage__c, Value__c, RecordType.DeveloperName, Parent_Entry__c
                FROM Approval_Process_Entries__r
                ORDER BY CreatedDate DESC
            )
            FROM Approval_Process__c
            WHERE Id = :approvalProcess.Id
        ];

        Assert.areEqual(2, postEntryCreationApprovalProcess.Approval_Process_Entries__r.size());
        Assert.areEqual(COMMENT_VALUE, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].Value__c);
        Assert.areEqual(decisionEntry.Id, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].Parent_Entry__c);
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_COMMENT_RECORD_TYPE, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].RecordType.DeveloperName);
        Assert.areEqual(approvalProcess.Stage__c, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].Stage__c);
    }

    @IsTest
    public static void createReminderEntry() {
        final String REMINDER_VALUE = 'test@test.com.invalid';
        Approval_Process__c approvalProcess = [SELECT Id, Stage__c FROM Approval_Process__c LIMIT 1];

        Test.startTest();
        insert CsApprovalProcessEntryHelper.createReminderEntry(approvalProcess.Id, approvalProcess.Stage__c, REMINDER_VALUE, false);
        Test.stopTest();

        Approval_Process__c postEntryCreationApprovalProcess = [
            SELECT Id, Stage__c, (
                SELECT Id, Stage__c, Value__c, RecordType.DeveloperName
                FROM Approval_Process_Entries__r
            )
            FROM Approval_Process__c
            WHERE Id = :approvalProcess.Id
        ];

        Assert.areEqual(1, postEntryCreationApprovalProcess.Approval_Process_Entries__r.size());
        Assert.areEqual(REMINDER_VALUE, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].Value__c);
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_REMINDER_RECORD_TYPE, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].RecordType.DeveloperName);
        Assert.areEqual(approvalProcess.Stage__c, postEntryCreationApprovalProcess.Approval_Process_Entries__r[0].Stage__c);
    }
}
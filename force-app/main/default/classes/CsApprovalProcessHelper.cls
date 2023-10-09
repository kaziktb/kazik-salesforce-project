public class CsApprovalProcessHelper {
    @TestVisible
    private static Map<String, String> RECORD_TYPE_NAME_2_IMPLEMENTOR_CLASS_NAME = new Map<String, String>{
        Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INDIVIDUAL_APPLICATION => CsIndividualApplicationApprovalLogic.class.getName(),
        Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INSTITUTIONAL_APPLICATION => CsInstitutionalApplicationApprovalLogic.class.getName(),
        Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INTERNSHIP_OFFER => CsInternshipOfferApprovalLogic.class.getName()
    };

    public static CsApprovalProcessStageBaseData retrieveCurrentStageData(String recordTypeDeveloperName, Id approvalProcessId) {
        return getImplementor(recordTypeDeveloperName).fetchCurrentStageData(approvalProcessId);
    }

    public static CsApprovalProcessStageExecutionResult executeCurrentStage(String recordTypeDeveloperName, Id approvalProcessId, String jsonData) {
        return getImplementor(recordTypeDeveloperName).executeCurrentStage(approvalProcessId, jsonData);
    }

    public static void abandonApprovalProcess(Id requestingRecordId) {
        Approval_Process__c approvalProcess = [
            SELECT Id, Stage__c
            FROM Approval_Process__c
            WHERE Status__c = :Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE
                AND Related_Record_Id__c = :requestingRecordId
        ];

        if (approvalProcess == null) {
            return;
        }
        approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ABANDONED;

        update approvalProcess;

        CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, 'Abandon', true);
    }

    public static void sendReminder(Id requestingRecordId, String recipientEmail) {
        Approval_Process__c approvalProcess = [
            SELECT Id, Stage__c
            FROM Approval_Process__c
            WHERE Status__c = :Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE
                AND Related_Record_Id__c = :requestingRecordId
        ];

        if (approvalProcess == null) {
            return;
        }

        CsApprovalProcessEntryHelper.createReminderEntry(approvalProcess.Id, approvalProcess.Stage__c, recipientEmail, true);
    }

    public static void updateRequestingRecordOwnership(Id requestingRecordId) {
        String objectName = requestingRecordId.getSObjectType().getDescribe().getName();
        SObject requestingRecord;

        if (objectName == Constants.CAREER_SERVICES_OFFER_OBJECT_API_NAME) {
            requestingRecord = new Career_Services_Offer__c(Id = requestingRecordId, OwnerId = UserInfo.getUserId());
        } else if (objectName == Constants.CAREER_SERVICES_APPLICATION_OBJECT_API_NAME) {
            requestingRecord = new Career_Services_Application__c(Id = requestingRecordId, Career_Services_Employee__c = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId);
        }

        update requestingRecord;
    }

    private static CsApprovalProcessLogicImplementor getImplementor(String recordTypeDeveloperName) {
        if (!RECORD_TYPE_NAME_2_IMPLEMENTOR_CLASS_NAME.containsKey(recordTypeDeveloperName)) {
            throw new CustomException.ApprovalProcessLogicNotFoundException().saveLog();
        }

        String implementorClassName = RECORD_TYPE_NAME_2_IMPLEMENTOR_CLASS_NAME.get(recordTypeDeveloperName);

        return (CsApprovalProcessLogicImplementor) Type.forName(implementorClassName).newInstance();
    }
}
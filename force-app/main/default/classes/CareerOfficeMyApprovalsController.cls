public without sharing class CareerOfficeMyApprovalsController {

    @AuraEnabled
    public static List<MyApprovalWrapper> fetchMyApprovals() {
        List<MyApprovalWrapper> myApprovals = new List<MyApprovalWrapper>();

        for (DT_Internship__c internship : fetchInternships()) {
            myApprovals.add(createMyApprovalWrapper(internship.Id, internship.Name));
        }

        for (DT_Internship_Application__c internshipApplication : fetchInternshipApplications()) {
            myApprovals.add(createMyApprovalWrapper(internshipApplication.Id, internshipApplication.Name));
        }

        return myApprovals;
    }

    private static MyApprovalWrapper createMyApprovalWrapper(Id recordId, String recordName) {
        MyApprovalWrapper myApprovalWrapper = new MyApprovalWrapper();
        myApprovalWrapper.recordName = recordName;
        myApprovalWrapper.urlToRecord = '/' + recordId;

        return myApprovalWrapper;
    }

    private static List<DT_Internship__c> fetchInternships() {
        return [
            SELECT
                Id, Name
            FROM DT_Internship__c
            WHERE DT_University_Internship_Supervisor_User__c = :UserInfo.getUserId()
                AND DT_Status_Of_The_Offer__c = :DT_Utils.INTERNSHIP_STATUS_IN_PROGRESS];
    }

    private static List<DT_Internship_Application__c> fetchInternshipApplications() {
        return [
            SELECT
                Id, Name
            FROM DT_Internship_Application__c
            WHERE DT_University_Internship_Supervisor_User__c = :UserInfo.getUserId()
            AND DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_ACCEPTANCE];
    }

    @TestVisible
    private class MyApprovalWrapper {
        @AuraEnabled
        public String recordName;
        @AuraEnabled
        public String urlToRecord;
    }
}
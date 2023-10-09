public without sharing class CsSupervisorApprovalsController {
    @AuraEnabled(cacheable=true)
    public static InitialDataWrapper fetchInitialData() {
        InitialDataWrapper wrapper = new InitialDataWrapper();

        List<ApprovalWrapper> individualApplicationApprovals = new List<ApprovalWrapper>();
        for (Career_Services_Application__c application : fetchIndividualApplicationApprovals()) {
            individualApplicationApprovals.add(
                new ApprovalWrapper(
                    application.Id,
                    application.Name,
                    '/' + application.Id,
                    application.Program_Enrollment__r.hed__Account__r.Parent.Name + ' > ' + application.Program_Enrollment__r.hed__Account__r.Name,
                    application.Student__r.Name
                )
            );
        }
        wrapper.individualApplicationApprovals = individualApplicationApprovals;

        List<ApprovalWrapper> internshipOfferApprovals = new List<ApprovalWrapper>();
        for (Career_Services_Offer_Assignment__c assignment : fetchInternshipOfferApprovals()) {
            internshipOfferApprovals.add(
                new ApprovalWrapper(
                    assignment.Id,
                    assignment.Career_Services_Offer__r.Name,
                    '/' + assignment.Career_Services_Offer__r.Id,
                    createHierarchyForInternshipOfferApproval(assignment)
                )
            );
        }
        wrapper.internshipOfferApprovals = internshipOfferApprovals;

        return wrapper;
    }

    private static List<Career_Services_Application__c> fetchIndividualApplicationApprovals() {
        return [
            SELECT Name, Student__r.Name, Program_Enrollment__r.hed__Account__r.Name, Program_Enrollment__r.hed__Account__r.Parent.Name
            FROM Career_Services_Application__c
            WHERE Status__c = :Constants.CAREER_SERVICES_APPLICATION_STATUS_SENT_FOR_SUPERVISOR_ACCEPTANCE
                AND Internal_Supervisor__r.User__c = :UserInfo.getUserId()
            ORDER BY Career_Services_Application__c.Name
        ];
    }

    private static List<Career_Services_Offer_Assignment__c> fetchInternshipOfferApprovals() {
        return [
            SELECT Career_Services_Offer__r.Name, Account__r.Name, Account__r.Parent.Name, Account__r.Parent.Parent.Name, Account__r.Parent.Parent.Parent.Name
            FROM Career_Services_Offer_Assignment__c
            WHERE Internship_Supervisor__r.User__c = :UserInfo.getUserId()
                AND Has_Decision_Been_Made__c = false
            ORDER BY Career_Services_Offer__r.Name
        ];
    }

    private static String createHierarchyForInternshipOfferApproval(Career_Services_Offer_Assignment__c assignment) {
        List<String> hierarchies = new List<String>();

        if (assignment.Account__r.Parent.Parent.Parent.Name != null && assignment.Account__r.Parent.Parent.Parent.Name != Constants.ACCOUNT_DEPARTMENT_ACCOUNT_NAME) {
            hierarchies.add(assignment.Account__r.Parent.Parent.Parent.Name);
        }

        if (assignment.Account__r.Parent.Parent.Name != null && assignment.Account__r.Parent.Parent.Name != Constants.ACCOUNT_DEPARTMENT_ACCOUNT_NAME) {
            hierarchies.add(assignment.Account__r.Parent.Parent.Name);
        }

        hierarchies.add(assignment.Account__r.Parent.Name);
        hierarchies.add(assignment.Account__r.Name);

        return String.join(hierarchies, ' > ');
    }

    public class InitialDataWrapper {
        @AuraEnabled
        public List<ApprovalWrapper> individualApplicationApprovals;
        @AuraEnabled
        public List<ApprovalWrapper> internshipOfferApprovals;

        public InitialDataWrapper() {}
    }

    public class ApprovalWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String hierarchy;
        @AuraEnabled
        public String studentName;

        public ApprovalWrapper(String id, String name, String url, String hierarchy) {
            this.id = id;
            this.name = name;
            this.url = url;
            this.hierarchy = hierarchy;
        }

        public ApprovalWrapper(String id, String name, String url, String hierarchy, String studentName) {
            this(id, name, url, hierarchy);
            this.studentName = studentName;
        }
    }

}
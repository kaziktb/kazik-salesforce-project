public without sharing class TB_CT_UserInfo {
    private static final String PERM_SET_APPLICANT_DIDACTIC = 'TB_SWPS_Contract_Teachers_Applicant_Didactic';
    private static final String PERM_SET_COORDINATOR = 'TB_SWPS_Contract_Teachers_Coordinator';
    private static final String PERM_SET_DECISION_MAKER = 'TB_SWPS_Contract_Teachers_Decision_Maker';

    @AuraEnabled(Cacheable=true)
    public static String getUserProfileLicenseName() {
        return [SELECT Profile.UserLicense.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].Profile.UserLicense.Name;
    }

    @AuraEnabled(Cacheable=true)
    public static UserPermissionSets getUserPermissionSets(Id userId) {
        Id assigneeId = userId == null ? UserInfo.getUserId() : userId;

        List<PermissionSetAssignment> assignments = [
                SELECT PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId =: assigneeId
        ];

        UserPermissionSets userPermissionSets = new UserPermissionSets();
        for(PermissionSetAssignment assignment : assignments) {
            String permSetName = assignment.PermissionSet.Name;
            if (permSetName.equals(PERM_SET_APPLICANT_DIDACTIC)) {
                userPermissionSets.hasPermSetApplicantDidactic = true;
            } else if (permSetName.equals(PERM_SET_COORDINATOR)) {
                userPermissionSets.hasPermSetCoordinator = true;
            } else if (permSetName.equals(PERM_SET_DECISION_MAKER)) {
                userPermissionSets.hasPermSetDecisionMaker = true;
            }
        }
        return userPermissionSets;
    }

    public class UserPermissionSets {
        @AuraEnabled
        public Boolean hasPermSetApplicantDidactic = false;
        @AuraEnabled
        public Boolean hasPermSetCoordinator = false;
        @AuraEnabled
        public Boolean hasPermSetDecisionMaker = false;

        public UserPermissionSets() { }

        public UserPermissionSets(Boolean hasPermSetApplicantDidactic, Boolean hasPermSetCoordinator,
                Boolean hasPermSetDecisionMaker) {
            this.hasPermSetApplicantDidactic = hasPermSetApplicantDidactic;
            this.hasPermSetCoordinator = hasPermSetCoordinator;
            this.hasPermSetDecisionMaker = hasPermSetDecisionMaker;
        }
    }
}
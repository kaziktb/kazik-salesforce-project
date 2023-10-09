public with sharing class TB_IC_ExtendedAccessController {
    private static final String PARTNERSHIP_APPROVERS = 'TB_SWPS_Institutional_CRM_Partnership_Approvers';
    private static final String PARTNERSHIP_MANAGEMENT = 'TB_SWPS_Institutional_CRM_Partnership_Management';

    @AuraEnabled(Cacheable=true)
    public static Boolean isUserWithExtendedAccess(Id partnerId) {
        Boolean isAssignedToAccountTeamMember = [ SELECT Count() 
                                                FROM AccountTeamMember 
                                                WHERE AccountId = :partnerId AND UserId = :UserInfo.getUserId() ] > 0;

        Boolean isAssignedToCustomPermSet = [ SELECT Count() 
                                            FROM PermissionSetAssignment 
                                            WHERE AssigneeId = :Userinfo.getUserId() 
                                            AND ( PermissionSet.Name = :PARTNERSHIP_APPROVERS OR PermissionSet.Name = :PARTNERSHIP_MANAGEMENT ) ] > 0;
                                            
        Boolean hasExtendedAcess = isAssignedToAccountTeamMember || isAssignedToCustomPermSet;

        return hasExtendedAcess;
        }

    @AuraEnabled(Cacheable=true)
    public static String isUserInApprovalProcess() {
        List<Contact> partnerAccountName = [ SELECT TB_Full_Access_Approval_Process_Name__c 
                                            FROM Contact 
                                            WHERE TB_User__c = :Userinfo.getUserId() 
                                            LIMIT 1 ];

        return  partnerAccountName[0].TB_Full_Access_Approval_Process_Name__c;
        }
}
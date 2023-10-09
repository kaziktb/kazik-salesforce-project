public without sharing class TB_CT_CasesControllerSharingSkip {

    private static final List<String> DIDACTIC_PERM_SETS_NAMES = new List<String>{'TB_SWPS_Contract_Teachers_Applicant_Didactic'};

    public static Map<Id, Boolean> userIdToIsTeacher(List<Id> userIds) {
        Map<Id, Boolean> userIdToIsTeacher = new Map<Id, Boolean>();
        for(Id userId : userIds) {
            userIdToIsTeacher.put(userId, false);
        }

        List<PermissionSet> didacticPermSets = [
                SELECT Id
                FROM PermissionSet
                WHERE Name IN :DIDACTIC_PERM_SETS_NAMES
        ];

        List<PermissionSetAssignment> didacticPermSetAssignments = [
                SELECT AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId IN :userIds AND PermissionSetId IN :didacticPermSets
        ];

        for(PermissionSetAssignment permissionSetAssignment : didacticPermSetAssignments) {
            userIdToIsTeacher.put(permissionSetAssignment.AssigneeId, true);
        }
        return userIdToIsTeacher;
    }

    public static Map<Id, String> userIdToName(List<Id> userIds) {
        Map<Id, String> idToName = new Map<Id, String>();
        for (User u : [SELECT FirstName, LastName FROM User WHERE Id IN :userIds]) {
            String name = u.FirstName + ' ' + u.LastName;
            idToName.put(u.Id, name);
        }
        return idToName;
    }

    public static Map<Id, String> userIdToGender(List<Id> userIds) {
        Map<Id, String> idToGender = new Map<Id, String>();
        for (Contact c : [SELECT TB_User__c, hed__Gender__c FROM Contact WHERE TB_User__c IN :userIds]) {
            idToGender.put(c.TB_User__c, c.hed__Gender__c);
        }
        return idToGender;
    }

    private static Id mapFacultyToUniversityDepartment(Id contactId) {
        return [SELECT hed__Account__c
                                            FROM hed__Affiliation__c
                                            WHERE
                                            hed__Contact__c = :contactId
                                            AND hed__Role__c = 'Employee'
                                            AND TB_Employee_Affiliation_Type__c = 'Agreement'
                                            AND hed__Status__c = 'Current'
                                            LIMIT 1
                                            ].hed__Account__c;
    }

    @AuraEnabled
    public static Id fetchDepartmentId(Boolean departmentIsNotEmpty, Id departmentId) {
        Id contactId = [SELECT Id FROM Contact WHERE TB_User__c = :UserInfo.getUserId() LIMIT 1].Id;

        List<PermissionSet> didacticPermSets = [
            SELECT Id
            FROM PermissionSet
            WHERE Name IN :DIDACTIC_PERM_SETS_NAMES
        ];

        List<PermissionSetAssignment> userPermSetAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN :didacticPermSets
        ];

        Boolean isDeansOfficeEmployee = userPermSetAssignments.isEmpty();

        try {
            if (isDeansOfficeEmployee) {
                return mapFacultyToUniversityDepartment(contactId);
            } else if (!departmentIsNotEmpty) {
                return mapFacultyToUniversityDepartment(getResponsiblePersonContact(contactId));
            } else if (departmentIsNotEmpty && departmentId != null) {
                return getFacultyDepartmentId(departmentId);
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_CT_CasesController.class.getName(), e.getStackTraceString(), contactId));
        }
    }

    private static Id getResponsiblePersonContact(Id contactId) {
        TB_App_Tracking__c appTracking = [
            SELECT TB_Dean_s_Office_Responsible__c
            FROM TB_App_Tracking__c
            WHERE TB_Applicant__c = :contactId
            LIMIT 1
        ];
        return appTracking.TB_Dean_s_Office_Responsible__c;
    }

    private static Id getFacultyDepartmentId(Id departmentId) {
        List<Account> facultyAccount = [
            SELECT TB_Faculty_Office__c
            FROM Account
            WHERE Id = :departmentId
            LIMIT 1
        ];
        return (facultyAccount.isEmpty() || facultyAccount[0].TB_Faculty_Office__c == null) ? departmentId : facultyAccount[0].TB_Faculty_Office__c;
    }


    @AuraEnabled
    public static void updateCaseFacultyOfficeNames(String caseId) {
        Case createdCase;
        try {
            createdCase = [SELECT Id,TB_CT_Faculty_Office_Name__c, TB_CT_Department_Id__c FROM Case WHERE Id =:caseId];
            Account acc = [SELECT Id, TB_Faculty_Office__r.Name FROM Account WHERE Id =:createdCase.TB_CT_Department_Id__c];
            createdCase.TB_CT_Faculty_Office_Name__c = acc.TB_Faculty_Office__r.Name;
            update createdCase;
        } catch(Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_CT_CasesController.class.getName(),e.getStackTraceString(), createdCase.Id));
        }
    }
}
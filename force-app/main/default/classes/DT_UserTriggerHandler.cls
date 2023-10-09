public with sharing class DT_UserTriggerHandler {

    public static Map<String, PermissionSetGroup> apiNames2PermissionSetGroups;
    public static Map<String, PermissionSet> apiNames2KnowledgePermissionSets;
    public static Map<String, Profile> apiNames2Profiles;
    
    public static final Set<String> KBC_PRODUCT_CODES = new Set<String>();

    public static void assignNewPermissionSets(Map<Id, User> newMap) {
        fetchProfileAndPermissionUtils();
        fetchKBCProductCodes();
        if (Test.isRunningTest()) {
            Test.calculatePermissionSetGroup(
                getPermissionSetGroupIds(apiNames2PermissionSetGroups.values())
            );
        }

        Map<Id, Set<Id>> userIds2SetOfPermissionSetIds = getMapUserIds2SetOfPermissionSetIds(newMap.keySet());
        List<PermissionSetAssignment> permissionSetAssignmentsToInsert = new List<PermissionSetAssignment>();

        Set<Id> contactIds = new Set<Id>();
        for (User user : newMap.values()) {
            if (user.ContactId != null) {
                contactIds.add(user.ContactId);
            }
        }

        Map<Id, Contact> ids2contacts = fetchContactsIdsToContacts(contactIds);

        for (User user : newMap.values()) {
            /** Assign Permission Sets and Permission Sets Groups by Profile */
            assignDeansOfficePermissionSetGroup(user, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds);

            /** Assign Permission Sets and Permission Sets Groups by individual Contact details */
            if (user.ContactId != null) {
                Contact contact = ids2contacts.get(user.ContactId);
                if (contact != null) {
                    assignStudentPermissionSetGroup(
                        user, contact, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds
                    );
                    assignKBLPermissionSet(
                        user, contact, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds
                    );

                    if (isPostgraduateStudent(user, contact)) {
                        assignKBCPermissionSet(
                            user, contact, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds
                        );
                        assignKBSPermissionSet(
                            user, contact, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds
                        );
                    }

                    if (isStudent(user, contact)) {
                        assignHigherStudiesPermissionSets(
                            user, contact, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds
                        );
                    }
                }
            }
        }
        insert permissionSetAssignmentsToInsert;
    }

    public static void processUsersAfterUpdate(Map<Id, User> oldMap, Map<Id, User> newMap) {
        processApplicants(oldMap, newMap);
    }

    private static void processApplicants(Map<Id, User> oldMap, Map<Id, User> newMap) {
        Map<Id, User> applicantId2UserMap = new Map<Id, User>();
        Id applicantProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_ADMISSIONS_APPLICANT_PROFILE_NAME);
        Id studentProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_STUDENT_PROFILE_NAME);

        for (User afterUpdateUser : newMap.values()) {
            User beforeUpdateUser = oldMap.get(afterUpdateUser.Id);

            if (beforeUpdateUser.ProfileId == applicantProfileId && afterUpdateUser.ProfileId == studentProfileId) {
                applicantId2UserMap.put(afterUpdateUser.Id, afterUpdateUser);
            }
        }

        if (applicantId2UserMap.isEmpty()) {
            return;
        }

        assignNewPermissionSets(applicantId2UserMap);
    }

    private static void assignHigherStudiesPermissionSets(
        User user, Contact contact, List<PermissionSetAssignment> permissionSetAssignmentsToInsert,
        Map<Id, Set<Id>> userIds2SetOfPermissionSetIds
    ) {
        Set<String> campusNames = new Set<String>();
        for (hed__Program_Enrollment__c programEnrollment : contact.hed__Program_Enrollments__r) {
            if (programEnrollment.DT_Level_Of_Studies__c == DT_Utils.PROGRAM_ENROLMENT_LEVEL_OF_STUDIES_BACHELOR
                || programEnrollment.DT_Level_Of_Studies__c == DT_Utils.PROGRAM_ENROLMENT_LEVEL_OF_STUDIES_MASTER
                || programEnrollment.DT_Level_Of_Studies__c == DT_Utils.PROGRAM_ENROLMENT_LEVEL_OF_STUDIES_INTEGRATED_MASTER
                ) {
                campusNames.add(programEnrollment.hed__Program_Plan__r.DT_Campus__c);
            }
        }

        /** Assign CSS permission sets for specified campus*/
        for (String name : campusNames) {
            if (DT_Utils.CAMPUS_NAMES_TO_CSS_PERMISSION_SET_NAMES.containsKey(name)) {
                assignKnowledgePermissionSet(
                    user, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds,
                    DT_Utils.CAMPUS_NAMES_TO_CSS_PERMISSION_SET_NAMES.get(name)
                );
            }
        }
        /** Assign global CSS SWPS permission set*/
        assignKnowledgePermissionSet(
            user, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds,
            DT_Utils.PERMISSION_SET_NAME_KB_CSS_SWPS
        );
        /** Assign Career Office permission set*/
        assignKnowledgePermissionSet(
            user, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds,
            DT_Utils.PERMISSION_SET_NAME_KB_CAREER_OFFICE
        );
    }

    private static void assignKnowledgePermissionSet(
        User user, List<PermissionSetAssignment> permissionSetAssignmentsToInsert,
        Map<Id, Set<Id>> userIds2SetOfPermissionSetIds, String permissionSetName
    ) {
        if (!isPermissionAssigned(
            user.Id, apiNames2KnowledgePermissionSets.get(permissionSetName).Id,
            userIds2SetOfPermissionSetIds
        )) {
            permissionSetAssignmentsToInsert.add(
                assignPermissionSet(
                    user.Id,
                    apiNames2KnowledgePermissionSets.get(permissionSetName).Id
                )
            );
        }
    }

    private static void assignDeansOfficePermissionSetGroup(
        User user, List<PermissionSetAssignment> permissionSetAssignmentsToInsert,
        Map<Id, Set<Id>> userIds2SetOfPermissionSetIds
    ) {
        if (isDeansOfficeEmployee(user)) {
            if (!isPermissionAssigned(
                user.Id, apiNames2PermissionSetGroups.get(DT_Utils.PERMISSION_SET_GROUP_NAME_DEANS_OFFICE).Id,
                userIds2SetOfPermissionSetIds
            )) {
                permissionSetAssignmentsToInsert.add(
                    assignPermissionSetGroup(
                        user.Id,
                        apiNames2PermissionSetGroups.get(DT_Utils.PERMISSION_SET_GROUP_NAME_DEANS_OFFICE).Id
                    )
                );
            }
        }
    }

    private static void assignStudentPermissionSetGroup(
        User user, Contact contact, List<PermissionSetAssignment> permissionSetAssignmentsToInsert,
        Map<Id, Set<Id>> userIds2SetOfPermissionSetIds
    ) {
        if (isStudent(user, contact) || isPostgraduateStudent(user, contact) || isExternalFaculty(user) ||isPostgraduateFaculty(user, contact)) {
            if (!isPermissionAssigned(
                user.Id, apiNames2PermissionSetGroups.get(DT_Utils.PERMISSION_SET_GROUP_NAME_STUDENT).Id,
                userIds2SetOfPermissionSetIds
            )) {
                permissionSetAssignmentsToInsert.add(
                    assignPermissionSetGroup(
                        user.Id,
                        apiNames2PermissionSetGroups.get(DT_Utils.PERMISSION_SET_GROUP_NAME_STUDENT).Id
                    )
                );
            }
        }
    }

    private static void assignKBLPermissionSet(
        User user, Contact contact, List<PermissionSetAssignment> permissionSetAssignmentsToInsert,
        Map<Id, Set<Id>> userIds2SetOfPermissionSetIds
    ) {
        if (isPostgraduateFaculty(user, contact)) {
            if (!isPermissionAssigned(
                user.Id, apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_DC_KBL).Id,
                userIds2SetOfPermissionSetIds
            )) {
                permissionSetAssignmentsToInsert.add(
                    assignPermissionSet(
                        user.Id,
                        apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_DC_KBL).Id
                    )
                );
            }
        }
    }

    private static void assignKBCPermissionSet(
        User user, Contact contact, List<PermissionSetAssignment> permissionSetAssignmentsToInsert,
        Map<Id, Set<Id>> userIds2SetOfPermissionSetIds
    ) {
        if (isKBCStudent(contact)) {
            assignKnowledgePermissionSet(
                user, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds,
                DT_Utils.PERMISSION_SET_NAME_KB_DC_KBC
            );
        }
    }

    private static void assignKBSPermissionSet(
        User user, Contact contact, List<PermissionSetAssignment> permissionSetAssignmentsToInsert,
        Map<Id, Set<Id>> userIds2SetOfPermissionSetIds
    ) {
        if (isKBSStudent(contact)) {
            assignKnowledgePermissionSet(
                user, permissionSetAssignmentsToInsert, userIds2SetOfPermissionSetIds,
                DT_Utils.PERMISSION_SET_NAME_KB_DC_KBS
            );
        }
    }

    private static Boolean isKBSStudent(Contact contact) {
        for (hed__Program_Enrollment__c programEnrollment : contact.hed__Program_Enrollments__r) {
            if (!KBC_PRODUCT_CODES.contains(programEnrollment.hed__Program_Plan__r.DT_Product_Code__c)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean isPermissionAssigned(Id userId, Id permissionSetOrGroupId, Map<Id, Set<Id>> userIds2SetOfPermissionSetIds) {
        return userIds2SetOfPermissionSetIds.get(userId).contains(permissionSetOrGroupId);
    }

    private static Boolean isPostgraduateFaculty(User user, Contact contact) {
        return (
            (user.ProfileId == apiNames2Profiles.get(DT_Utils.SWPS_STUDENT_PROFILE_NAME).Id
            || user.ProfileId == apiNames2Profiles.get(DT_Utils.SWPS_EXTERNAL_FACULTY_PROFILE_NAME).Id )
            && contact.DT_Is_Postgraduate_Faculty__c
        );
    }

    private static Boolean isPostgraduateStudent(User user, Contact contact) {
        return (
            user.ProfileId == apiNames2Profiles.get(DT_Utils.SWPS_STUDENT_PROFILE_NAME).Id
            && contact.DT_Is_Postgraduate_Student__c
        );
    }

    private static Boolean isKBCStudent(Contact contact) {
        for (hed__Program_Enrollment__c programEnrollment : contact.hed__Program_Enrollments__r) {
            if (KBC_PRODUCT_CODES.contains(programEnrollment.hed__Program_Plan__r.DT_Product_Code__c)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean isStudent(User user, Contact contact) {
        return (
            user.ProfileId == apiNames2Profiles.get(DT_Utils.SWPS_STUDENT_PROFILE_NAME).Id
                && (contact.DT_Is_Student__c || contact.RecordTypeId == DT_Utils.getRecTypeIdByDevName(
                    DT_Utils.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME, Contact.getSObjectType().getDescribe().getName()
                ))
        );
    }

    private static Boolean isExternalFaculty(User user) {
        return (
            user.ProfileId == apiNames2Profiles.get(DT_Utils.SWPS_EXTERNAL_FACULTY_PROFILE_NAME).Id
        );
    }

    private static Boolean isDeansOfficeEmployee(User user) {
        return user.ProfileId == apiNames2Profiles.get(DT_Utils.SWPS_DEANS_OFFICE_EMPLOYEE_PROFILE_NAME).Id;
    }

    private static PermissionSetAssignment assignPermissionSet(Id userId, Id permissionSetId) {
        return new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetId = permissionSetId
        );
    }

    private static PermissionSetAssignment assignPermissionSetGroup(Id userId, Id PermissionSetGroupId) {
        return new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetGroupId = PermissionSetGroupId
        );
    }

    public static Map<Id, Set<Id>> getMapUserIds2SetOfPermissionSetIds(Set<Id> userIds) {
        Map<Id, Set<Id>> userIds2SetOfPermissionSetIds = new Map<Id, Set<Id>>();
        List<PermissionSetAssignment> existingPermissionSetAssignments = fetchPermissionSetAssignments(userIds);
        for (PermissionSetAssignment permSetAssignment : existingPermissionSetAssignments) {
            Id permissionSetOrGroupId = permSetAssignment.PermissionSetId == null ?
                permSetAssignment.PermissionSetGroupId : permSetAssignment.PermissionSetId;
            if (userIds2SetOfPermissionSetIds.containsKey(permSetAssignment.AssigneeId)) {
                userIds2SetOfPermissionSetIds.get(permSetAssignment.AssigneeId).add(permissionSetOrGroupId);
            } else {
                userIds2SetOfPermissionSetIds.put(permSetAssignment.AssigneeId, new Set<Id>{
                    permissionSetOrGroupId
                });
            }
        }
        return userIds2SetOfPermissionSetIds;
    }

    public static List<PermissionSetAssignment> fetchPermissionSetAssignments(Set<Id> userIds) {
        return [
            SELECT Id, PermissionSetGroupId, PermissionSetId, AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId IN:userIds
        ];
    }

    public static void fetchProfileAndPermissionUtils() {
        apiNames2PermissionSetGroups = apiNames2PermissionSetGroups == null ?
            DT_Utils.getPermissionSetGroupMapByNames(
                DT_Utils.PROFILE_DEDICATED_PERMISSION_SET_GROUP_NAMES) : apiNames2PermissionSetGroups;

        apiNames2KnowledgePermissionSets = apiNames2KnowledgePermissionSets == null ?
            DT_Utils.getPermissionSetMapByNames(
                DT_Utils.KNOWLEDGE_PERMISSION_SET_NAMES) : apiNames2KnowledgePermissionSets;

        apiNames2Profiles = apiNames2Profiles == null ? DT_Utils.getProfileMapByNames(
            DT_Utils.PERMISSION_ASSIGNMENT_PROFILE_NAMES) : apiNames2Profiles;
    }

    private static void fetchKBCProductCodes() {
        for (DT_KBC_Product_Code__mdt productCode : [
            SELECT DeveloperName, Label, DT_Is_Active__c
            FROM DT_KBC_Product_Code__mdt
            WHERE DT_Is_Active__c = true
        ]) {
            KBC_PRODUCT_CODES.add(productCode.Label);
        }
    }

    private static Map<Id, Contact> fetchContactsIdsToContacts(Set<Id> contactIds) {
        return new Map<Id, Contact>([
            SELECT DT_Is_Student__c, DT_Is_Postgraduate_Faculty__c, DT_Is_Postgraduate_Student__c, RecordTypeId, (
                SELECT DT_Status_by_VDO__c, DT_Level_Of_Studies__c, hed__Program_Plan__r.DT_Product_Code__c,
                    hed__Program_Plan__r.DT_Campus__c
                FROM hed__Program_Enrollments__r
                WHERE DT_Status_by_VDO__c = :DT_Utils.PROGRAM_ENROLMENT_STATUS_BY_VDO_ACTIVE
            )
            FROM Contact
            WHERE Id IN:contactIds
        ]);
    }

    private static List<String> getPermissionSetGroupIds(List<PermissionSetGroup> permissionSetGroups) {
        List<String> psgIds = new List<String>();
        for (PermissionSetGroup psg : permissionSetGroups) {
            psgIds.add(psg.Id);
        }
        return psgIds;
    }
}
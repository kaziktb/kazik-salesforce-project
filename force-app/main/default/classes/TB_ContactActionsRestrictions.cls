public with sharing class TB_ContactActionsRestrictions {
    final private static Map<String, Id> recordTypeLabelToId = new Map<String, Id>{
        'Applicant' => TB_SObjectUtils.getRecordTypeIdByDevName(TB_re_Constants.TB_CONTACT_LABEL, TB_re_Constants.CONTACT_APPLICANT_RT),
        'Student' => TB_SObjectUtils.getRecordTypeIdByDevName(TB_re_Constants.TB_CONTACT_LABEL, TB_re_Constants.CONTACT_STUDENT_RT),
        'Employee' => TB_SObjectUtils.getRecordTypeIdByDevName(TB_re_Constants.TB_CONTACT_LABEL, TB_re_Constants.CONTACT_EMPLOYEE_RT)
    };
    final private static List<String> recordTypes = new List<String>{'Applicant', 'Student', 'Employee'};
    private static Boolean insertDone = false;

    public static void checkRestrictions(List<Contact> contacts) {
        insertDone = true;
        checkCustomSetting('Create', contacts, null);
    }

    public static void checkRestrictions(Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        if (!insertDone) {
            checkCustomSetting('Edit', oldMap.values(), newMap);
        }
    }

    private static void checkCustomSetting(String action, List<Contact> contacts, Map<Id, Contact> newMap) {
        User currentUser = getCurrentUser();
        if (TB_Contact_Actions_Restriction__c.getValues(currentUser.Id) == null
                && TB_Contact_Actions_Restriction__c.getValues(currentUser.ProfileId) != null) {
            TB_Contact_Actions_Restriction__c restriction = TB_Contact_Actions_Restriction__c.getValues(currentUser.ProfileId);
            for (Contact contact : contacts) {
                checkRecordType(
                    action,
                    restriction,
                    contact,
                    action == 'Create' ? null : newMap.get(contact.Id),
                    action == 'Create' ? contact : newMap.get(contact.Id)
                );
            }
        }
    }

    private static void checkRecordType(String action, TB_Contact_Actions_Restriction__c restriction,
        Contact contact, Contact newContact, Contact contactToBlock) {
        for (String recordType : recordTypes) {
            if (Boolean.valueOf(restriction.get('TB_' + recordType + '_Block_' + action + '__c'))
                    && (action == 'Create' && contact.RecordTypeId == recordTypeLabelToId.get(recordType)
                        || action == 'Edit' && (contact.RecordTypeId == recordTypeLabelToId.get(recordType)
                            || newContact.RecordTypeId == recordTypeLabelToId.get(recordType)))) {
                contactToBlock.addError(System.Label.TB_Contact_Action_Restricted);
            }
        }
    }

    private static User getCurrentUser() {
        return [
            SELECT Id, ProfileId
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
    }
}
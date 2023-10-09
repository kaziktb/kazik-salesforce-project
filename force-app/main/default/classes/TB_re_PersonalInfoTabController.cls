public without sharing class TB_re_PersonalInfoTabController {

    @AuraEnabled
    public static Boolean isTooYoung(Integer year, Integer month, Integer day) {
        try {
            Date birthdate = Date.newInstance(year, month, day);
            return birthdate.addYears(15) > System.today();
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static Boolean blockDuplicates (String type, String data, String contactId) {
        try {
            List<Contact> existingContacts = new List<Contact>();
            if (type == 'PERSONAL_INFORMATION.DT_PESEL__C.EXCEPTION') {
                existingContacts = [
                    SELECT Id
                    FROM Contact
                    WHERE DT_PESEL__c = :data
                    AND Id != :contactId
                    AND RecordTypeId = :TB_SObjectUtils.getRecordTypeIdByDevName(
                        TB_re_Constants.TB_CONTACT_LABEL, TB_re_Constants.CONTACT_APPLICANT_RT
                    )
                ];
            } else if (type == 'PERSONAL_INFORMATION.TB_X_Document_Search__C.EXCEPTION') {
                existingContacts = [
                    SELECT Id
                    FROM Contact
                    WHERE TB_x_Document_Search__c = :data
                    AND Id != :contactId
                    AND RecordTypeId = :TB_SObjectUtils.getRecordTypeIdByDevName(
                        TB_re_Constants.TB_CONTACT_LABEL, TB_re_Constants.CONTACT_APPLICANT_RT
                    )
                ];
            }

            return !existingContacts.isEmpty();
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

}
public with sharing class TB_CT_AffiliationController {
    private static final String NOT_FOUND = '-';
    private static final Id CT_RT_ACCOUNT_UNI_DEPART_ID = Schema.SObjectType.Account.recordTypeInfosByDeveloperName.get(TB_Constants.TB_CT_RECORD_TYPE_UNI_DEPARTMENTS).getRecordTypeId();

    @AuraEnabled(Cacheable=true)
    public static List<AffiliationWrapper> fetchAllAffiliationsByContactId(Id contactId) {
        List<AffiliationWrapper> affiliationWrappers = new List<AffiliationWrapper>();
        for (hed__Affiliation__c affiliation : [
                SELECT
                        Id,
                        Name,
                        hed__Account__c,
                        hed__Account__r.Name,
                        TB_Campus__c,
                        TB_EmploymentCat__c,
                        TB_Position__c,
                        hed__Role__c,
                        TB_RoleType__c,
                        TB_Location__c,
                        hed__Contact__r.Name,
                        hed__Contact__r.FirstName,
                        hed__Contact__r.LastName,
                        hed__Contact__r.TB_Title_Grade__c,
                        TB_EmploymentType__c,
                        hed__Status__c,
                        TB_Application_Date__c
                FROM hed__Affiliation__c
                WHERE hed__Contact__c = :contactId
                AND hed__Role__c = 'Employee'
                AND hed__Account__r.TB_Active__c = TRUE
                AND hed__Account__r.RecordTypeId = :CT_RT_ACCOUNT_UNI_DEPART_ID
                ORDER BY hed__Status__c, Name
                LIMIT 50000
        ]) {
            AffiliationWrapper affiliationWrapper = new AffiliationWrapper();
            affiliationWrapper.setValues(
                    affiliation.Id,
                    affiliation.Name,
                    affiliation.hed__Account__c,
                    affiliation.hed__Account__r.Name,
                    affiliation.TB_Campus__c,
                    affiliation.TB_EmploymentCat__c,
                    affiliation.TB_Position__c,
                    affiliation.hed__Role__c,
                    affiliation.TB_RoleType__c,
                    affiliation.TB_Location__c,
                    affiliation.hed__Contact__r.Name,
                    affiliation.hed__Contact__r.FirstName,
                    affiliation.hed__Contact__r.LastName,
                    affiliation.hed__Contact__r.TB_Title_Grade__c,
                    affiliation.TB_EmploymentType__c,
                    affiliation.hed__Status__c,
                    affiliation.TB_Application_Date__c
            );

            affiliationWrappers.add(affiliationWrapper);
        }
        return affiliationWrappers;
    }

    @AuraEnabled(Cacheable=true)
    public static Account fetchDepartmentAffiliationByAffiliationId(Id affiliationId) {
        return [
            SELECT Name, TB_Account_Name_EN__c, TB_Account_Name_PL__c
            FROM Account
            WHERE RecordTypeId = :CT_RT_ACCOUNT_UNI_DEPART_ID
            AND TB_Active__c = TRUE
            AND Id IN (SELECT hed__Account__c FROM hed__Affiliation__c WHERE Id =: affiliationId)
            LIMIT 1
        ];
    }

    public class AffiliationWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String affiliationName;
        @AuraEnabled public Id workDepartmentId;
        @AuraEnabled public String workDepartmentName;
        @AuraEnabled public String campus;
        @AuraEnabled public String employmentCategory;
        @AuraEnabled public String position;
        @AuraEnabled public String role;
        @AuraEnabled public String roleType;
        @AuraEnabled public String location;
        @AuraEnabled public String fullName;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String title;
        @AuraEnabled public String employmentType;
        @AuraEnabled public String status;
        @AuraEnabled public String applicationDate;


        public void setValues(
                Id id,
                String affiliationName,
                Id workDepartmentId,
                String workDepartmentName,
                String campus,
                String employmentCategory,
                String position,
                String role,
                String roleType,
                String location,
                String fullName,
                String firstName,
                String lastName,
                String title,
                String employmentType,
                String status,
                Date applicationDate
        ) {
            this.id = id;
            this.affiliationName = checkIfNullAndSetValue(affiliationName);
            this.workDepartmentId = workDepartmentId;
            this.workDepartmentName = checkIfNullAndSetValue(workDepartmentName);
            this.campus = checkIfNullAndSetValue(campus);
            this.employmentCategory = checkIfNullAndSetValue((String) employmentCategory);
            this.position = checkIfNullAndSetValue(position);
            this.role = checkIfNullAndSetValue(role);
            this.roleType = checkIfNullAndSetValue(roleType);
            this.location = checkIfNullAndSetValue(location);
            this.fullName = checkIfNullAndSetValue(fullName);
            this.firstName = checkIfNullAndSetValue(firstName);
            this.lastName = checkIfNullAndSetValue(lastName);
            this.title = checkIfNullAndSetValue(title);
            this.employmentType = checkIfNullAndSetValue(employmentType);
            this.status = checkIfNullAndSetValue(status);
            this.applicationDate = checkIfNullAndSetValue(String.valueOf(applicationDate));
        }

    }

    private static String checkIfNullAndSetValue(String value) {
        return (value == null) ? NOT_FOUND : value;
    }
}
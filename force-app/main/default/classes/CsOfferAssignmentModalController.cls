public without sharing class CsOfferAssignmentModalController {
    public enum AccountType {
        department,
        academicProgram,
        specialty
    }

    @AuraEnabled(cacheable=true)
    public static InitialDataWrapper fetchInitialData() {
        List<PicklistOptionWrapper> supervisors = new List<PicklistOptionWrapper>();
        List<PicklistOptionWrapper> departments = new List<PicklistOptionWrapper>();

        for (Internship_Supervisor__c supervisor : [SELECT Name FROM Internship_Supervisor__c ORDER BY Name]) {
            supervisors.add(new PicklistOptionWrapper(supervisor.Name, supervisor.Id));
        }

        for (Account department : [SELECT Name FROM Account WHERE RecordTypeId = :Utils.getRecordTypeIdByDevName(Account.SObjectType, Constants.ACCOUNT_RECORD_TYPE_DEPARTMENT_API_NAME) AND Parent.Name = :Constants.ACCOUNT_DEPARTMENT_ACCOUNT_NAME ORDER BY Name]) {
            departments.add(new PicklistOptionWrapper(department.Name, department.Id));
        }

        return new InitialDataWrapper(supervisors, departments);
    }

    @AuraEnabled
    public static OfferAssignmentWrapper fetchOfferAssignmentData(String type, Id parentAccountId, OfferAssignmentWrapper offerAssignment) {
        AccountType accountType = AccountType.valueOf(type);
        List<PicklistOptionWrapper> options = new List<PicklistOptionWrapper>();

        switch on accountType {
            when department {
                for (Account account : [SELECT Name FROM Account WHERE RecordTypeId = :Utils.getRecordTypeIdByDevName(Account.SObjectType, Constants.ACCOUNT_RECORD_TYPE_ACADEMIC_PROGRAM_API_NAME) AND ParentId = :parentAccountId ORDER BY Name]) {
                    options.add(new PicklistOptionWrapper(account.Name, account.Id));
                }

                offerAssignment.academicProgramOptions = options;
                offerAssignment.academicProgram = null;
                offerAssignment.specialty = null;
            }
            when academicProgram {
                for (Account account : [SELECT Name FROM Account WHERE RecordTypeId = :Utils.getRecordTypeIdByDevName(Account.SObjectType, Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME) AND ParentId = :parentAccountId AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_SPECIALTY_API_NAME AND DT_Has_Active_Students__c = true ORDER BY Name]) {
                    options.add(new PicklistOptionWrapper(account.Name, account.Id));
                }

                offerAssignment.specialtyOptions = options;
                offerAssignment.specialty = null;
            }
            when specialty {
                for (Account account : [SELECT Name FROM Account WHERE RecordTypeId = :Utils.getRecordTypeIdByDevName(Account.SObjectType, Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME) AND ParentId = :parentAccountId AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME ORDER BY Name]) {
                    options.add(new PicklistOptionWrapper(account.Name, account.Id));
                }

                offerAssignment.pathwayOptions = options;
            }
        }

        offerAssignment.pathway = null;

        return offerAssignment;
    }

    public class InitialDataWrapper {
        @AuraEnabled
        public List<PicklistOptionWrapper> supervisors;
        @AuraEnabled
        public List<PicklistOptionWrapper> departments;

        public InitialDataWrapper(List<PicklistOptionWrapper> supervisors, List<PicklistOptionWrapper> departments) {
            this.supervisors = supervisors;
            this.departments = departments;
        }
    }

    public class PicklistOptionWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public PicklistOptionWrapper() {}

        public PicklistOptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class OfferAssignmentWrapper {
        @AuraEnabled
        public String supervisor {get; set;}
        @AuraEnabled
        public String department {get; set;}
        @AuraEnabled
        public String academicProgram {get; set;}
        @AuraEnabled
        public String specialty {get; set;}
        @AuraEnabled
        public String pathway {get; set;}
        @AuraEnabled
        public List<PicklistOptionWrapper> academicProgramOptions {get; set;}
        @AuraEnabled
        public List<PicklistOptionWrapper> specialtyOptions {get; set;}
        @AuraEnabled
        public List<PicklistOptionWrapper> pathwayOptions {get; set;}
    }

}
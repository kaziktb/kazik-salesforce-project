public with sharing class MySwpsCsApplicationDetailController {
    private static final Id individualInternshipApplicationId = Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP);
    private static final Id institutionalInternshipApplicationId = Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP);
    @AuraEnabled(Cacheable=true)
    public static RecordTypesWrapper fetchRecordTypes(Id recordId) {
        if (String.isBlank(recordId)) {
            return null;
        }

        Career_Services_Application__c application = [SELECT RecordTypeId FROM Career_Services_Application__c WHERE Id = :recordId];

        RecordTypesWrapper wrapper = new RecordTypesWrapper(application);

        return wrapper;
    }

    public class RecordTypesWrapper {
        @AuraEnabled
        public Boolean isIndividualInternshipApplication {get; set;}
        @AuraEnabled
        public Boolean isInstitutionalInternshipApplication {get; set;}

        public RecordTypesWrapper(Career_Services_Application__c application) {
            isIndividualInternshipApplication = application.RecordTypeId == individualInternshipApplicationId;
            isInstitutionalInternshipApplication = application.RecordTypeId == institutionalInternshipApplicationId;
        }
    }
}
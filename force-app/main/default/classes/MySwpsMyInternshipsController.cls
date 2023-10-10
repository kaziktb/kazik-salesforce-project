public with sharing class MySwpsMyInternshipsController {

    private final static List<Id> INTERNSHIP_APPLICATION_RECORD_TYPE_IDS = new List<Id>{
        Utils.getRecordTypeIdByDevName(
            Career_Services_Application__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP
        ),
        Utils.getRecordTypeIdByDevName(
            Career_Services_Application__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP
        )
    };

    @AuraEnabled
    public static ResultWrapper fetchInternshipApplications(Integer offset, Integer recordsCountToReturn) {
        User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        ResultWrapper resultWrapper = new ResultWrapper();
        Boolean hasNext = false;
        Integer recordsCountToQuery = recordsCountToReturn + 1;

        List<Career_Services_Application__c> applications = [
                SELECT Name, toLabel(Status__c), Internal_Supervisor__r.Name, Career_Services_Offer__r.Company__r.Name, toLabel(RecordType.Name), Career_Services_Offer__r.Offer_Title__c
                FROM Career_Services_Application__c
                WHERE Student__c = :currentUser.ContactId AND RecordTypeId IN :INTERNSHIP_APPLICATION_RECORD_TYPE_IDS
                ORDER BY Name DESC
                LIMIT :recordsCountToQuery
                OFFSET :offset
        ];

        if (applications.size() == recordsCountToQuery) {
            applications.remove(applications.size() - 1);
            hasNext = true;
        }

        resultWrapper.hasNext = hasNext;

        for (Career_Services_Application__c application : applications) {
            InternshipApplicationWrapper wrapper = new InternshipApplicationWrapper();
            wrapper.id = application.Id;
            wrapper.name = application.Name;
            wrapper.status = application.Status__c;
            wrapper.offerTitle = application.Career_Services_Offer__r.Offer_Title__c;
            wrapper.internshipProviderName = application.Career_Services_Offer__r.Company__r.Name;
            wrapper.internshipSupervisorName = application.Internal_Supervisor__r.Name;
            wrapper.applicationType = application.RecordType.Name;
            resultWrapper.applications.add(wrapper);
        }

        resultWrapper.offset = offset + resultWrapper.applications.size();
        return resultWrapper;
    }

    public class ResultWrapper {

        public ResultWrapper() {
            applications = new List<InternshipApplicationWrapper>();
        }

        @AuraEnabled
        public Boolean hasNext {get; set;}
        @AuraEnabled
        public Integer offset  {get; set;}
        @AuraEnabled
        public List<InternshipApplicationWrapper> applications {get; set;}
    }

    public class InternshipApplicationWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String offerTitle;
        @AuraEnabled
        public String internshipSupervisorName;
        @AuraEnabled
        public String internshipProviderName;
        @AuraEnabled
        public String applicationType;
    }

}
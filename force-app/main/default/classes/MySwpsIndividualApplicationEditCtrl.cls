public without sharing class MySwpsIndividualApplicationEditCtrl {

    @AuraEnabled
    public static UpdateResult updateApplication(UpdateModel applicationUpdateModelWrapper) {
        UpdateResult result = new UpdateResult(canEdit(applicationUpdateModelWrapper.applicationId));

        if (!result.canEdit) {
           return result;
        }

        Career_Services_Offer__c offerUpdateModel = new Career_Services_Offer__c();

        if (applicationUpdateModelWrapper.hasSupervisorData) {
            Contact externalSupervisorUpdateModel = new Contact(
                FirstName = applicationUpdateModelWrapper.supervisorFirstName,
                LastName = applicationUpdateModelWrapper.supervisorLastName,
                hed__WorkEmail__c = applicationUpdateModelWrapper.supervisorWorkEmail,
                hed__WorkPhone__c = applicationUpdateModelWrapper.supervisorWorkPhone
            );

            if (String.isEmpty(applicationUpdateModelWrapper.supervisorId)) {
                MySwpsUtils.createFormContactsWithAccountRelation(new Map<String, Contact>{externalSupervisorUpdateModel.hed__WorkEmail__c => externalSupervisorUpdateModel}, applicationUpdateModelWrapper.companyId);
            } else {
                externalSupervisorUpdateModel.RecordTypeId = Utils.getRecordTypeIdByDevName(Contact.getSObjectType(), Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME);
                externalSupervisorUpdateModel.Id = applicationUpdateModelWrapper.supervisorId;

                update externalSupervisorUpdateModel;
            }
            offerUpdateModel.External_Supervisor__c = externalSupervisorUpdateModel.Id;
            result.supervisorId = externalSupervisorUpdateModel.Id;
        }

        update new Career_Services_Application__c(
            Id = applicationUpdateModelWrapper.applicationId,
            Internship_Commencement_Date__c = applicationUpdateModelWrapper.startDate,
            Internship_Completion_Date__c = applicationUpdateModelWrapper.endDate
        );

        offerUpdateModel.Id = applicationUpdateModelWrapper.offerId;
        offerUpdateModel.Offer_Title__c = applicationUpdateModelWrapper.offerTitle;
        offerUpdateModel.Description_Of_Completed_Tasks__c = applicationUpdateModelWrapper.descriptionOfCompletedTasks;
        offerUpdateModel.External_Supervisor_Education__c = applicationUpdateModelWrapper.supervisorEducation;

        update offerUpdateModel;

        result.supervisorEducation = [SELECT toLabel(External_Supervisor_Education__c) FROM Career_Services_Offer__c WHERE Id = :offerUpdateModel.Id].External_Supervisor_Education__c;

        update new Contact(
            Id = applicationUpdateModelWrapper.representativeId,
            FirstName = applicationUpdateModelWrapper.representativeFirstName,
            LastName = applicationUpdateModelWrapper.representativeLastName,
            hed__WorkEmail__c = applicationUpdateModelWrapper.representativeWorkEmail,
            hed__WorkPhone__c = applicationUpdateModelWrapper.representativeWorkPhone
        );

        update new Account(
            Id = applicationUpdateModelWrapper.companyId,
            Website = applicationUpdateModelWrapper.website
        );

        return result;
    }

    private static Boolean canEdit(Id applicationId) {
        Career_Services_Application__c application = [SELECT Status__c FROM Career_Services_Application__c WHERE Id = :applicationId];
        return application.Status__c == Constants.CAREER_SERVICES_APPLICATION_STATUS_CORRECTION_NEEDED;
    }

    public class UpdateModel {
        @AuraEnabled
        public Id offerId {get;set;}
        @AuraEnabled
        public Id applicationId {get;set;}
        @AuraEnabled
        public Id companyId {get;set;}
        @AuraEnabled
        public Id representativeId {get;set;}
        @AuraEnabled
        public Id supervisorId {get;set;}
        @AuraEnabled
        public String offerTitle { get; set; }
        @AuraEnabled
        public String descriptionOfCompletedTasks { get; set; }
        @AuraEnabled
        public Date startDate { get; set; }
        @AuraEnabled
        public Date endDate { get; set; }
        @AuraEnabled
        public String website { get; set; }
        @AuraEnabled
        public String representativeFirstName { get; set; }
        @AuraEnabled
        public String representativeLastName { get; set; }
        @AuraEnabled
        public String representativeWorkEmail { get; set; }
        @AuraEnabled
        public String representativeWorkPhone { get; set; }
        @AuraEnabled
        public Boolean hasSupervisorData { get; set; }
        @AuraEnabled
        public String supervisorEducation { get; set; }
        @AuraEnabled
        public String supervisorFirstName { get; set; }
        @AuraEnabled
        public String supervisorLastName { get; set; }
        @AuraEnabled
        public String supervisorWorkEmail { get; set; }
        @AuraEnabled
        public String supervisorWorkPhone { get; set; }
    }

    public class UpdateResult {
        public UpdateResult(Boolean canEdit) {
            this.canEdit = canEdit;
        }

        @AuraEnabled
        public Boolean canEdit;
        @AuraEnabled
        public Id supervisorId;
        @AuraEnabled
        public String supervisorEducation;
    }
}
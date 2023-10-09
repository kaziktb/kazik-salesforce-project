public without sharing class MySwpsInternshipOfferFormController {
    @AuraEnabled(Cacheable=true)
    public static FormInitialDataWrapper fetchFormInitialData() {
        FormInitialDataWrapper wrapper = new FormInitialDataWrapper();

        wrapper.internshipOfferRecordTypeId = Utils.getRecordTypeIdByDevName(
            Career_Services_Offer__c.getSObjectType(),
            Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP
        );

        wrapper.companyAccountRecordTypeId = Utils.getRecordTypeIdByDevName(
            Account.getSObjectType(),
            Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME
        );

        wrapper.partnerContactRecordTypeId = Utils.getRecordTypeIdByDevName(
            Contact.getSObjectType(),
            Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME
        );

        return wrapper;
    }

    @AuraEnabled
    public static void submitOffer(
        Account companyAccount,
        Contact representativeContact,
        Contact supervisorContact,
        Contact recruiterContact,
        Career_Services_Offer__c offer,
        InternshipOfferConsentsWrapper consentsWrapper,
        List<InternshipOfferTagWrapper> tags
    ) {
        Group careerServicesQueueGroup = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = :Constants.GROUP_CAREER_OFFICE_QUEUE_DEVELOPER_NAME
            LIMIT 1
        ];
        List<Career_Services_Offer_Tag__c> offerTagsToInsert = new List<Career_Services_Offer_Tag__c>();
        Map<Id, InternshipOfferTagWrapper> tagId2TagWrapper = new Map<Id, MySwpsInternshipOfferFormController.InternshipOfferTagWrapper>();

        List<Account> existingAccounts = [
            SELECT Id
            FROM Account
            WHERE DT_Company_Tax_Id__c = :companyAccount.DT_Company_Tax_Id__c
        ];

        if (!existingAccounts.isEmpty()) {
            companyAccount.Id = existingAccounts[0].Id;
        }

        upsert companyAccount;

        Map<String, Contact> workEmail2FormContact = new Map<String, Contact>{
            representativeContact.hed__WorkEmail__c => representativeContact,
            recruiterContact.hed__WorkEmail__c => recruiterContact
        };

        if (offer.Has_Internship_Supervisor_Assistance__c && String.isNotEmpty(supervisorContact.hed__WorkEmail__c)) {
            workEmail2FormContact.put(supervisorContact.hed__WorkEmail__c, supervisorContact);
        }

        MySwpsUtils.createFormContactsWithAccountRelation(workEmail2FormContact, companyAccount.Id);

        if (offer.Has_Internship_Supervisor_Assistance__c && supervisorContact.Id != null) {
            offer.External_Supervisor__c = supervisorContact.Id;
        }

        MySwpsConsentCreator.createConsentsForContact(
            new Set<Id>(consentsWrapper.checkedConsentIds),
            consentsWrapper.userDetails,
            consentsWrapper.formUrl,
            recruiterContact.Id
        );

        offer.Organisation_Contact__c = representativeContact.Id;
        offer.Recruiter__c = recruiterContact.Id;
        offer.Company__c = companyAccount.Id;
        offer.Is_Internship_Paid__c = offer.Salary__c != Constants.CAREER_SERVICES_OFFER_SALARY_UNPAID;
        offer.OwnerId = careerServicesQueueGroup.Id;
        offer.Institution_Website__c = String.isNotBlank(companyAccount.Website) ? companyAccount.Website : '';

        insert offer;

        for (InternshipOfferTagWrapper tag : tags) {
            tagId2TagWrapper.put(tag.id, tag);
        }

        for (Tag__c tag : [SELECT Category__c FROM Tag__c WHERE Id IN :tagId2TagWrapper.keySet()]) {
            InternshipOfferTagWrapper tagWrapper = tagId2TagWrapper.get(tag.Id);

            Career_Services_Offer_Tag__c offerTag = new Career_Services_Offer_Tag__c(
                Career_Services_Offer__c = offer.Id,
                Category__c = tag.Category__c,
                Level__c = tagWrapper.level,
                Tag__c = tag.Id
            );

            offerTagsToInsert.add(offerTag);
        }

        if (!offerTagsToInsert.isEmpty()) {
            insert offerTagsToInsert;
        }
    }

    public class FormInitialDataWrapper {
        @AuraEnabled
        public Id internshipOfferRecordTypeId;
        @AuraEnabled
        public Id companyAccountRecordTypeId;
        @AuraEnabled
        public Id partnerContactRecordTypeId;
    }

    public class InternshipOfferConsentsWrapper {
        @AuraEnabled
        public List<Id> checkedConsentIds { get; set; }
        @AuraEnabled
        public String formUrl { get; set; }
        @AuraEnabled
        public String userDetails { get; set; }
    }

    public class InternshipOfferTagWrapper {
        @AuraEnabled
        public Id id {get; set;}
        @AuraEnabled
        public String level {get; set;}
    }
}
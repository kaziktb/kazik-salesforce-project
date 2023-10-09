public without sharing class MySwpsJobOfferFormController {
    @AuraEnabled(Cacheable=true Scope='global')
    public static JobOfferRecordTypeIdsWrapper fetchRecordTypesIdWrapper() {
        JobOfferRecordTypeIdsWrapper recordTypesWrapper = new JobOfferRecordTypeIdsWrapper();

        recordTypesWrapper.companyAccountRecordTypeId = Utils.getRecordTypeIdByDevName(
            Account.getSObjectType(),
            Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME
        );
        recordTypesWrapper.jobOfferCareerServicesOfferRecordTypeId = Utils.getRecordTypeIdByDevName(
            Career_Services_Offer__c.getSObjectType(),
            Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER
        );
        recordTypesWrapper.recruiterContactRecordTypeId = Utils.getRecordTypeIdByDevName(
            Contact.getSObjectType(),
            Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME
        );

        return recordTypesWrapper;
    }

    @AuraEnabled
    public static Id formSubmissionHandler(
        Account companyAccount,
        Contact recruiterContact,
        JobOfferConsentsWrapper consentsWrapper,
        Career_Services_Offer__c jobOffer,
        Boolean isJobPlacement,
        List<String> cooperationWays,
        List<JobOfferTagWrapper> tags
    ) {
        Contact existingContact;
        List<Career_Services_Offer_Tag__c> offerTagsToInsert = new List<Career_Services_Offer_Tag__c>();
        List<Opportunity> cooperationOpportunities = new List<Opportunity>();
        Map<Id, JobOfferTagWrapper> tagId2TagWrapper = new Map<Id, MySwpsJobOfferFormController.JobOfferTagWrapper>();
        Group careerServicesQueueGroup = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = :Constants.GROUP_CAREER_OFFICE_QUEUE_DEVELOPER_NAME
            LIMIT 1
        ];

        List<Account> existingAccounts = [
            SELECT Id
            FROM Account
            WHERE DT_Company_Tax_Id__c = :companyAccount.DT_Company_Tax_Id__c
        ];

        if (!existingAccounts.isEmpty()) {
            companyAccount.Id = existingAccounts[0].Id;
        }

        upsert companyAccount;

        List<Contact> existingContacts = [
            SELECT Id, AccountId
            FROM Contact
            WHERE hed__WorkEmail__c = :recruiterContact.hed__WorkEmail__c
                AND RecordTypeId = :recruiterContact.RecordTypeId
        ];

        if (!existingContacts.isEmpty()) {
            existingContact = existingContacts[0];
            recruiterContact.Id = existingContact.Id;
            recruiterContact.AccountId = String.isBlank(existingContact.AccountId) ? companyAccount.Id : existingContact.AccountId;
        } else {
            recruiterContact.AccountId = companyAccount.Id;
        }

        upsert recruiterContact;

        if (existingContact != null && existingContact.AccountId != companyAccount.Id) {
            List<AccountContactRelation> accountContactRelations = [
                SELECT Id
                FROM AccountContactRelation
                WHERE AccountId = :companyAccount.Id
                    AND ContactId = :recruiterContact.Id
            ];

            if (accountContactRelations.isEmpty()) {
                AccountContactRelation accountContactRelation = new AccountContactRelation(
                    AccountId = companyAccount.Id,
                    ContactId = recruiterContact.Id
                );

                insert accountContactRelation;
            }
        }

        MySwpsConsentCreator.createConsentsForContact(
            new Set<Id>(consentsWrapper.checkedConsentIds),
            consentsWrapper.userDetails,
            consentsWrapper.formUrl,
            recruiterContact.Id
        );

        jobOffer.Company__c = companyAccount.Id;
        jobOffer.Recruiter__c = recruiterContact.Id;
        jobOffer.Institution_Website__c = String.isNotBlank(companyAccount.Website) ? companyAccount.Website : '';
        jobOffer.OwnerId = careerServicesQueueGroup.Id;

        insert jobOffer;

        for (JobOfferTagWrapper tag : tags) {
            tagId2TagWrapper.put(tag.id, tag);
        }

        for (Tag__c tag : [SELECT Category__c FROM Tag__c WHERE Id IN :tagId2TagWrapper.keySet()]) {
            JobOfferTagWrapper tagWrapper = tagId2TagWrapper.get(tag.Id);

            Career_Services_Offer_Tag__c offerTag = new Career_Services_Offer_Tag__c(
                Career_Services_Offer__c = jobOffer.Id,
                Category__c = tag.Category__c,
                Level__c = tagWrapper.level,
                Tag__c = tag.Id
            );

            offerTagsToInsert.add(offerTag);
        }

        if (!offerTagsToInsert.isEmpty()) {
            insert offerTagsToInsert;
        }

        if (!isJobPlacement && cooperationWays.isEmpty()) {
            return jobOffer.Id;
        }

        if (isJobPlacement) {
            cooperationWays.add(Constants.OPPORTUNITY_ADDITIONAL_WAYS_OF_COOPERATION_JOB_PLACEMENT_API_NAME);
        }

        Id opportunityRecordTypeCareerOfficeId = Utils.getRecordTypeIdByDevName(
            Opportunity.getSObjectType(),
            Constants.OPPORTUNITY_RECORD_TYPE_CAREER_OFFICE_DEVELOPER_NAME
        );

        for (Opportunity cooperationOpportunity : [
            SELECT Additional_Ways_Of_Cooperation__c
            FROM Opportunity
            WHERE AccountId = :companyAccount.Id
                AND StageName NOT IN :Constants.OPPORTUNITY_STAGE_NAMES_CLOSED
                AND RecordTypeId = :opportunityRecordTypeCareerOfficeId
                AND Additional_Ways_Of_Cooperation__c IN :cooperationWays
        ]) {
            if (cooperationWays.contains(cooperationOpportunity.Additional_Ways_Of_Cooperation__c)) {
                cooperationWays.remove(cooperationWays.indexOf(cooperationOpportunity.Additional_Ways_Of_Cooperation__c));
            }
        }

        if (cooperationWays.isEmpty()) {
            return jobOffer.Id;
        }

        for (String cooperationWay : cooperationWays) {
            List<Object> formatArguments = new List<Object>{
                companyAccount.Name,
                cooperationWay
            };

            String opportunityName = String.format(Constants.OPPORTUNITY_COOPERATION_NAME_FORMAT, formatArguments);

            cooperationOpportunities.add(new Opportunity(
                AccountId = companyAccount.Id,
                Additional_Ways_Of_Cooperation__c = cooperationWay,
                DT_Partner_Contact_Person__c = recruiterContact.Id,
                Name = opportunityName,
                RecordTypeId = opportunityRecordTypeCareerOfficeId,
                StageName = Constants.OPPORTUNITY_STAGE_NAME_NEW_API_NAME,
                CloseDate = jobOffer.Offer_Expiration_Date__c
            ));
        }

        if (!cooperationOpportunities.isEmpty()) {
            insert cooperationOpportunities;
        }

        return jobOffer.Id;
    }

    public class JobOfferFileWrapper {
        @AuraEnabled
        public String base64 {get; set;}
        @AuraEnabled
        public String fileName {get; set;}
    }

    public class JobOfferConsentsWrapper {
        @AuraEnabled
        public List<Id> checkedConsentIds {get; set;}
        @AuraEnabled
        public String formUrl {get; set;}
        @AuraEnabled
        public String userDetails {get; set;}
    }

    public class JobOfferRecordTypeIdsWrapper {
        @AuraEnabled
        public Id companyAccountRecordTypeId {get; set;}
        @AuraEnabled
        public Id jobOfferCareerServicesOfferRecordTypeId {get; set;}
        @AuraEnabled
        public Id recruiterContactRecordTypeId {get; set;}
    }

    public class JobOfferTagWrapper {
        @AuraEnabled
        public Id id {get; set;}
        @AuraEnabled
        public String level {get; set;}
    }
}
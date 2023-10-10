public without sharing class MySwpsUtils {
    public static void createFormContactsWithAccountRelation(Map<String, Contact> workEmail2FormContact, Id companyAccountId) {
        Id partnerRecordTypeId = Utils.getRecordTypeIdByDevName(
            Contact.getSObjectType(),
            Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME
        );

        Set<String> contactWorkEmailsWithoutRelation = new Set<String>();

        Set<Id> existingContactIds = new Set<Id>();
        Map<String, Contact> workEmail2ExistingContact = new Map<String, Contact>();
        Set<Id> contactIdsWithFormAccountRelation = new Set<Id>();

        for (Contact contact : [
            SELECT AccountId, hed__WorkEmail__c, (
                SELECT Id
                FROM AccountContactRelations
                WHERE AccountId = :companyAccountId
            )
            FROM Contact
            WHERE hed__WorkEmail__c IN :workEmail2FormContact.keySet()
            AND RecordTypeId = :partnerRecordTypeId
        ]) {
            workEmail2ExistingContact.put(contact.hed__WorkEmail__c, contact);
            existingContactIds.add(contact.Id);

            if (contact.AccountContactRelations.size() > 0) {
                contactIdsWithFormAccountRelation.add(contact.Id);
            }
        }

        for (String formContactWorkEmail : workEmail2FormContact.keySet()) {
            Contact formContact = workEmail2FormContact.get(formContactWorkEmail);

            if (Test.isRunningTest()) {
                formContact.hed__Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_ALTERNATE;
                formContact.hed__AlternateEmail__c = 'myswpsutils@test.invalid';
            }

            if (workEmail2ExistingContact.containsKey(formContactWorkEmail)) {
                Contact existingContact = workEmail2ExistingContact.get(formContactWorkEmail);

                formContact.Id = existingContact.Id;
                formContact.AccountId = String.isBlank(existingContact.AccountId) ? companyAccountId : existingContact.AccountId;

                if (!contactIdsWithFormAccountRelation.contains(existingContact.Id)) {
                    contactWorkEmailsWithoutRelation.add(formContact.hed__WorkEmail__c);
                }
            } else {
                formContact.AccountId = companyAccountId;
            }
        }

        upsert workEmail2FormContact.values();

        List<AccountContactRelation> accountContactRelationsToCreate = new List<AccountContactRelation>();

        for (String workEmail : contactWorkEmailsWithoutRelation) {
            Contact formContact = workEmail2FormContact.get(workEmail);
            accountContactRelationsToCreate.add(new AccountContactRelation(
                AccountId = companyAccountId,
                ContactId = formContact.Id
            ));
        }

        insert accountContactRelationsToCreate;
    }

    @AuraEnabled
    public static void changeCurrentUserLanguage(String language) {
        update new User(
            Id = UserInfo.getUserId(),
            LanguageLocaleKey = language
        );
    }

    public static Map<Id, String> buildLanguagesTagMapWithExcludedValues(String languageLocaleKey, List<String> excludedEnglishNames) {
        return buildLanguagesTagCore(languageLocaleKey, excludedEnglishNames);
    }

    private static Map<Id, String> buildLanguagesTagCore(String languageLocaleKey, List<String> excludedEnglishNames) {
        Map<Id, String> id2LanguageName = new Map<Id, String>();

        String languageAwareNameFieldApiName = languageLocaleKey == Constants.LANGUAGE_LOCALE_KEY_POLISH
            ? Tag__c.Name.getDescribe().getName()
            : Tag__c.English_Name__c.getDescribe().getName();

        String query = 'SELECT English_Name__c, Name ' +
            'FROM Tag__c ' +
            'WHERE Category__c = \'' + Constants.TAG_CATEGORY_LANGUAGE_API_NAME + '\'' +
            'AND English_Name__c NOT IN ' + Utils.buildMultiselectOrCondition(excludedEnglishNames) +
            'ORDER BY ' + languageAwareNameFieldApiName + ' ASC';

        for (Tag__c tag : Database.query(query)) {
            id2LanguageName.put(tag.Id, languageLocaleKey == Constants.LANGUAGE_LOCALE_KEY_POLISH ? tag.Name : tag.English_Name__c);
        }

        return id2LanguageName;
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean checkInternshipOfferAssignmentsMatch(Id internshipOfferId) {
        Id contactId = fetchCustomerUserContactIdOrThrow(UserInfo.getUserId());
        Boolean hasOfferNonObligatoryAssignment = false;

        Set<Id> offerAssignmentAccountIds = new Set<Id>();

        Career_Services_Offer__c internshipOffer = [
            SELECT
                Id, Required_Recruitment_Documents__c, (
                SELECT Id, Account__c, Is_Obligatory__c
                FROM Career_Services_Offer_Assignments__r
                WHERE Is_Accepted__c = TRUE
            )
            FROM Career_Services_Offer__c
            WHERE Id = :internshipOfferId
        ];

        for (Career_Services_Offer_Assignment__c assignment : internshipOffer.Career_Services_Offer_Assignments__r) {
            offerAssignmentAccountIds.add(assignment.Account__c);
            if (!assignment.Is_Obligatory__c) {
                hasOfferNonObligatoryAssignment = true;
            }
        }

        List<hed__Education_History__c> educationHistories = [
            SELECT Id, Name, (
                SELECT Id
                FROM hed__Program_Enrollments__r
                ORDER BY hed__Start_Date__c DESC
                LIMIT 1
            ), (
                SELECT Id, Name, Education_History__c,
                    Internship_Group__r.Academic_Program__c,
                    Internship_Group__r.Specialty__c,
                    Internship_Group__r.Pathway__c
                FROM Internship_Requirements__r
                WHERE Is_Completed__c = FALSE
            )
            FROM hed__Education_History__c
            WHERE hed__Contact__c = :contactId
            AND hed__Status__c = :Constants.EDUCATION_HISTORY_STATUS_STUDYING
        ];

        List<Internship_Requirement__c> internshipRequirements = new List<Internship_Requirement__c>();
        for (hed__Education_History__c history : educationHistories) {
            if (!history.Internship_Requirements__r.isEmpty()) {
                internshipRequirements.addAll(history.Internship_Requirements__r);
            }
        }

        if (!internshipRequirements.isEmpty()) {
            Boolean hasMatchingRequirementToAssignments = false;
            for (Internship_Requirement__c requirement : internshipRequirements) {
                if (requirement.Internship_Group__r.Pathway__c != null && offerAssignmentAccountIds.contains(requirement.Internship_Group__r.Pathway__c)) {
                    hasMatchingRequirementToAssignments = true;
                } else if (requirement.Internship_Group__r.Specialty__c != null && offerAssignmentAccountIds.contains(requirement.Internship_Group__r.Specialty__c)) {
                    hasMatchingRequirementToAssignments = true;
                } else if (offerAssignmentAccountIds.contains(requirement.Internship_Group__r.Academic_Program__c)) {
                    hasMatchingRequirementToAssignments = true;
                }

                if (hasMatchingRequirementToAssignments) {
                    break;
                }
            }
            return hasMatchingRequirementToAssignments;
        } else {
            return hasOfferNonObligatoryAssignment;
        }
    }

    public static Id fetchCustomerUserContactIdOrThrow(Id userId) {
        User communityUser = [SELECT ContactId FROM User WHERE Id = :userId];

        if (communityUser.ContactId == null) {
            new CustomException.CommunityUserWithoutContactException().saveLog();
            throw new AuraHandledException(Label.MySWPS_No_Contact_Relation_On_User_Error_Message);
        }

        return communityUser.ContactId;
    }
}
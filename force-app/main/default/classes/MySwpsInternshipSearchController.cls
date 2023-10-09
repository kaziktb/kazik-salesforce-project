public without sharing class MySwpsInternshipSearchController {

    @AuraEnabled(Cacheable=true)
    public static InitDataWrapper fetchInitData(String pageContextLanguage) {
        final List<String> EXCLUDED_LANGUAGE_ENGLISH_NAMES = new List<String>{Constants.TAG_ENGLISH_NAME_VALUE_POLISH};
        InitDataWrapper wrapper = new InitDataWrapper();

        wrapper.languages = MySwpsUtils.buildLanguagesTagMapWithExcludedValues(pageContextLanguage, EXCLUDED_LANGUAGE_ENGLISH_NAMES);

        wrapper.careerServicesOfferInstitutionalInternshipRecordTypeId = Utils.getRecordTypeIdByDevName(
            Career_Services_Offer__c.getSObjectType(),
            Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP
        );

        wrapper.accountBusinessOrganizationRecordTypeId = Utils.getRecordTypeIdByDevName(
            Account.getSObjectType(),
            Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME
        );

        return wrapper;
    }

    @AuraEnabled
    public static SearchWrapper fetchOffers(
        FilterWrapper filtersWrapper,
        Integer offset,
        Integer recordsCountToReturn,
        Id internshipOfferRecordTypeId
    ) {
        Boolean hasNext = false;
        Integer recordsCountToQuery = recordsCountToReturn + 1;
        List<Id> availableForAccountIds = new List<Id>();
        List<Internship_Requirement__c> internshipRequirements = new List<Internship_Requirement__c>();
        User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];

        for (hed__Education_History__c educationHistory : [
            SELECT Id, (
                SELECT Internship_Group__r.Academic_Program__c, Internship_Group__r.Specialty__c, Internship_Group__r.Pathway__c
                FROM Internship_Requirements__r
                WHERE Is_Completed__c = FALSE
            )
            FROM hed__Education_History__c
            WHERE hed__Contact__c = :currentUser.ContactId
                AND hed__Status__c = :Constants.EDUCATION_HISTORY_STATUS_STUDYING
        ]) {
            internshipRequirements.addAll(educationHistory.Internship_Requirements__r);
        }

        for (Internship_Requirement__c requirement : internshipRequirements) {
            if (requirement.Internship_Group__r.Pathway__c != null) {
                availableForAccountIds.add(requirement.Internship_Group__r.Pathway__c);
            } else if (requirement.Internship_Group__r.Specialty__c != null) {
                availableForAccountIds.add(requirement.Internship_Group__r.Specialty__c);
            } else {
                availableForAccountIds.add(requirement.Internship_Group__r.Academic_Program__c);
            }
        }

        String offerFilters = 'Status__c = \'' + Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME + '\' AND RecordTypeId = \'' + internshipOfferRecordTypeId + '\' ';

        if (String.isNotBlank(filtersWrapper.isPaid)) {
            offerFilters += 'AND Is_Internship_Paid__c = ' + filtersWrapper.isPaid + ' ';
        }

        if (String.isNotBlank(filtersWrapper.industry)) {
            offerFilters += 'AND Company__r.Industry IN' + Utils.buildMultiselectOrCondition(filtersWrapper.industry);
        }

        if (String.isNotBlank(filtersWrapper.workplaceType)) {
            offerFilters += 'AND Workplace_Type__c IN' + Utils.buildMultiselectOrCondition(filtersWrapper.workplaceType);
        }

        if (String.isNotBlank(filtersWrapper.sector)) {
            offerFilters += 'AND Sector__c IN' + Utils.buildMultiselectOrCondition(filtersWrapper.sector);
        }

        if (String.isNotBlank(filtersWrapper.isPolishRequired)) {
            offerFilters += 'AND Is_Polish_Required__c = ' + filtersWrapper.isPolishRequired + ' ';
        }

        if (String.isNotBlank(filtersWrapper.languages)) {
            Set<Id> offerIdsWithSelectedLanguages = new Set<Id>();

            String languagesQuery = 'SELECT Career_Services_Offer__c ' +
                                    'FROM Career_Services_Offer_Tag__c ' +
                                    'WHERE Tag__c IN ' + Utils.buildMultiselectOrCondition(filtersWrapper.languages);

            for (Career_Services_Offer_Tag__c csoTag : Database.query(languagesQuery)) {
                offerIdsWithSelectedLanguages.add(csoTag.Career_Services_Offer__c);
            }

            offerFilters += 'AND Id IN ' + Utils.buildMultiselectOrCondition(offerIdsWithSelectedLanguages);
        }

        offerFilters += 'AND Id IN (' +
            'SELECT Career_Services_Offer__c ' +
            'FROM Career_Services_Offer_Assignment__c ' +
            'WHERE Is_Accepted__c = TRUE ';

        if (internshipRequirements.isEmpty()) {
            offerFilters += ' AND Is_Obligatory__c = FALSE) ';
        } else {
            offerFilters += ' AND Account__c IN (\'' + String.join(availableForAccountIds, '\',\'') + '\')) ';
        }

        offerFilters += 'AND Id IN (' +
                        'SELECT Career_Services_Offer__c ' +
                        'FROM Career_Services_Offer_Contract__c W' +
                        'HERE Status__c = \'' + Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME + '\') ';

        offerFilters += 'LIMIT ' + String.valueOf(recordsCountToQuery) + ' ' +
                        'OFFSET ' + String.valueOf(offset);

        String offerQuery = 'SELECT Id, Offer_Title__c, Company__r.Name, Workplace__c, Workplace_Type__c, ' +
                            'toLabel(Workplace_Type__c) WorkplaceTypeLabel, toLabel(Salary__c) SalaryLabel, ' +
                            'Internship_Period_From__c, Offer_Expiration_Date__c ' +
                            'FROM Career_Services_Offer__c ' +
                            'WHERE ' + offerFilters;

        System.debug(offerQuery);

        List<Career_Services_Offer__c> offers = Database.query(offerQuery);

        if (offers.size() == recordsCountToQuery) {
            offers.remove(offers.size() - 1);
            hasNext = true;
        }

        SearchWrapper searchWrapper = new SearchWrapper();
        searchWrapper.hasNext = hasNext;
        searchWrapper.offers = offers;
        searchWrapper.offset = offset + offers.size();
        searchWrapper.hasAnyRequirement = !internshipRequirements.isEmpty();

        return searchWrapper;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public Map<Id, String> languages;
        @AuraEnabled
        public Id careerServicesOfferInstitutionalInternshipRecordTypeId;
        @AuraEnabled
        public Id accountBusinessOrganizationRecordTypeId;
    }

    public class SearchWrapper {
        @AuraEnabled
        public Boolean hasNext {get;set;}
        @AuraEnabled
        public Integer offset {get; set;}
        @AuraEnabled
        public List<Career_Services_Offer__c> offers {get; set;}
        @AuraEnabled
        public Boolean hasAnyRequirement;
    }

    public class FilterWrapper {
        @AuraEnabled
        public String industry {get; set;}
        @AuraEnabled
        public String workplaceType {get; set;}
        @AuraEnabled
        public String sector {get; set;}
        @AuraEnabled
        public String isPaid {get; set;}
        @AuraEnabled
        public String languages {get; set;}
        @AuraEnabled
        public String isPolishRequired {get; set;}
    }
}
public with sharing class MySwpsJobOfferSearchController {
    @AuraEnabled(Cacheable=true)
    public static InitialDataWrapper fetchInitialData(String languageLocaleKey) {
        final List<String> EXCLUDED_LANGUAGE_ENGLISH_NAMES = new List<String>{Constants.TAG_ENGLISH_NAME_VALUE_POLISH};
        InitialDataWrapper initialDataWrapper = new InitialDataWrapper();

        initialDataWrapper.jobOfferRecordTypeId = Utils.getRecordTypeIdByDevName(
            Career_Services_Offer__c.getSObjectType(),
            Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER
        );

        initialDataWrapper.languages = MySwpsUtils.buildLanguagesTagMapWithExcludedValues(languageLocaleKey, EXCLUDED_LANGUAGE_ENGLISH_NAMES);

        return initialDataWrapper;
    }
    @AuraEnabled
    public static SearchResultWrapper fetchSearchResults(
        FilterWrapper filters,
        Integer offset,
        Integer recordsCountToReturn,
        String jobOfferRecordTypeId
    ) {
        Boolean hasNext = false;
        Integer recordsCountToQuery = recordsCountToReturn + 1;
        String offerQuery = 'SELECT Offer_Title__c, Workplace__c, toLabel(Workplace_Type__c) WorkplaceTypeLabel, ' +
                            'toLabel(Business_Categories__c) BusinessCategoriesLabel, toLabel(Employment_Type__c) EmploymentTypeLabel, ' +
                            'Offer_Expiration_Date__c, Company__r.Name ' +
                            'FROM Career_Services_Offer__c ' +
                            'WHERE RecordTypeId = \'' + jobOfferRecordTypeId + '\' ';

        if (String.isNotBlank(filters.businessCategory)) {
            offerQuery += 'AND Business_Categories__c IN ' + Utils.buildMultiselectOrCondition(filters.businessCategory);
        }

        if (String.isNotBlank(filters.employmentType)) {
            offerQuery += 'AND Employment_Type__c IN ' + Utils.buildMultiselectOrCondition(filters.employmentType);
        }

        if (String.isNotBlank(filters.isPolishRequired)) {
            offerQuery += 'AND Is_Polish_Required__c = ' + filters.isPolishRequired + ' ';
        }

        if (String.isNotBlank(filters.nearestCampus)) {
            offerQuery += 'AND Locations_Of_SWPS__c IN ' + Utils.buildMultiselectOrCondition(filters.nearestCampus);
        }

        if (String.isNotBlank(filters.positionLevel)) {
            offerQuery += 'AND Position_Level__c IN ' + Utils.buildMultiselectOrCondition(filters.positionLevel);
        }

        if (String.isNotBlank(filters.workplaceType)) {
            offerQuery += 'AND Workplace_Type__c IN ' + Utils.buildMultiselectOrCondition(filters.workplaceType);
        }

        if (String.isNotBlank(filters.weeklyWorkingHoursMin)) {
            offerQuery += 'AND Weekly_Working_Hours_Minimum__c >= ' + filters.weeklyWorkingHoursMin + ' ';
        }

        if (String.isNotBlank(filters.weeklyWorkingHoursMax)) {
            offerQuery += 'AND Weekly_Working_Hours_Maximum__c <= ' + filters.weeklyWorkingHoursMax + ' ';
        }

        if (String.isNotBlank(filters.languages)) {
            offerQuery += 'AND Id IN (' +
                          'SELECT Career_Services_Offer__c ' +
                          'FROM Career_Services_Offer_Tag__c ' +
                          'WHERE Tag__c IN ' + Utils.buildMultiselectOrCondition(filters.languages) + ') ';
        }

        offerQuery += 'AND Status__c = \'' + Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME + '\' ' +
                      'LIMIT ' + String.valueOf(recordsCountToQuery) + ' ' +
                      'OFFSET ' + String.valueOf(offset);

        List<Career_Services_Offer__c> filteredOffers = Database.query(offerQuery);

        if (filteredOffers.size() == recordsCountToQuery) {
            filteredOffers.remove(filteredOffers.size() - 1);
            hasNext = true;
        }

        SearchResultWrapper searchResultWrapper = new SearchResultWrapper();
        searchResultWrapper.hasNext = hasNext;
        searchResultWrapper.offers = filteredOffers;
        searchResultWrapper.offset = offset + searchResultWrapper.offers.size();
        return searchResultWrapper;
    }

    public class InitialDataWrapper {
        @AuraEnabled
        public Id jobOfferRecordTypeId {get; set;}
        @AuraEnabled
        public Map<Id, String> languages {get; set;}
    }

    public class FilterWrapper {
        @AuraEnabled
        public String nearestCampus {get; set;}
        @AuraEnabled
        public String businessCategory {get; set;}
        @AuraEnabled
        public String isPolishRequired {get; set;}
        @AuraEnabled
        public String languages {get; set;}
        @AuraEnabled
        public String weeklyWorkingHoursMin {get; set;}
        @AuraEnabled
        public String weeklyWorkingHoursMax {get; set;}
        @AuraEnabled
        public String positionLevel {get; set;}
        @AuraEnabled
        public String employmentType {get; set;}
        @AuraEnabled
        public String workplaceType {get; set;}
    }

    public class SearchResultWrapper {
        @AuraEnabled
        public Boolean hasNext {get; set;}
        @AuraEnabled
        public Integer offset  {get; set;}
        @AuraEnabled
        public List<Career_Services_Offer__c> offers {get; set;}
    }
}
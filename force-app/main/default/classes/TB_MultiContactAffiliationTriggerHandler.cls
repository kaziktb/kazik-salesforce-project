/**
 * Created by jakubWrzodek on 19/01/23.
 */
public without sharing class TB_MultiContactAffiliationTriggerHandler extends TB_TriggerHandler {
    @TestVisible final private static List<String> KEY_AFFILIATION_FIELDS = new List<String> {'hed__Role__c', 'TB_Level_of_Study__c', 'TB_Employee_Affiliation_Type__c', 'TB_Employment_Group_3__c', 'hed__Status__c', 'TB_Organization_Type__c'};
    @TestVisible final private static Map<String, String> AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP = new Map<String, String> {
        'hed__Role__c' => 'TB_Affiliation_Role__c',
        'TB_Level_of_Study__c' => 'TB_Affiliation_Level_of_Study__c',
        'TB_Employee_Affiliation_Type__c' => 'TB_Affiliation_Employee_Affiliation_Type__c',
        'TB_Employment_Group_3__c' => 'TB_Affiliation_Employment_Group_3__c',
        'hed__Status__c' => 'TB_Affiliation_Status__c',
        'TB_Organization_Type__c' => 'TB_Affiliation_Organization_Type__c'
    };

    public override void afterInsert() {
        updateParentContactPersonTypeCounters(Trigger.new);
    }

    public override void afterUpdate() {
        updateParentContactPersonTypeCounters(Trigger.oldMap, Trigger.new);
    }

    public static void updateParentContactPersonTypeCounters(List<hed__Affiliation__c> affiliations) {
        futureUpdateParentContactPersonTypeCounters(TB_SObjectUtils.getIds(affiliations));
    }

    public static void updateParentContactPersonTypeCounters(Map<Id, SObject> oldAffiliationMap, List<hed__Affiliation__c> affiliations) {
        affiliations = filterAffiliations(oldAffiliationMap, affiliations);
        futureUpdateParentContactPersonTypeCounters(TB_SObjectUtils.getIds(affiliations));
    }

    @Future
    public static void futureUpdateParentContactPersonTypeCounters(List<Id> recordIds) {
        List<TB_Contact_Affiliation_Counter__mdt> matchingRules = getMatchingRules();
        if (recordIds != null && !recordIds.isEmpty()) {
            List<hed__Affiliation__c> affiliations = getAffiliationsFrom(recordIds);
            updateParentContactPersonTypeCounters(affiliations, matchingRules);
        }
    }

    @TestVisible
    private static void updateParentContactPersonTypeCounters(List<hed__Affiliation__c> affiliations, List<TB_Contact_Affiliation_Counter__mdt> matchingRules) {
        try {
            List<Contact> contactsToUpdate = getParentContacts(affiliations, matchingRules);
            for (Contact contact : contactsToUpdate) {
                contact = resetContactCounterValues(contact, matchingRules);
                for (TB_Contact_Affiliation_Counter__mdt matchingRule : matchingRules) {
                    for (hed__Affiliation__c affiliation : contact.hed__Affl_Accounts__r) {
                        if (isAffiliationMatchingToRule(affiliation, matchingRule)) {
                            Integer value = Integer.valueOf(contact.get(matchingRule.TB_Contact_Counter_API_Name__c)) + 1;
                            contact.put(matchingRule.TB_Contact_Counter_API_Name__c, value);
                        }
                    }
                }
            }
            if(contactsToUpdate != null) {
                update contactsToUpdate;
            }
        } catch (Exception ex) {
            insert TB_LogUtils.registerLog(ex);
        }
    }

    @TestVisible
    private static Boolean isAffiliationMatchingToRule(hed__Affiliation__c affiliation, TB_Contact_Affiliation_Counter__mdt matchingRule) {
        for (String field : AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.keySet()) {
            String matchingRuleFieldValue = String.valueOf(matchingRule.get(AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.get(field)));
            if (matchingRuleFieldValue != null && affiliation.get(field) != matchingRuleFieldValue) {
                return false;
            }
        }
        return true;
    }

    private static Contact resetContactCounterValues(Contact contact, List<TB_Contact_Affiliation_Counter__mdt> matchingRules) {
        for (TB_Contact_Affiliation_Counter__mdt matchingRule : matchingRules) {
            contact.put(matchingRule.TB_Contact_Counter_API_Name__c, 0);
        }
        return contact;
    }

    @TestVisible
    private static List<hed__Affiliation__c> filterAffiliations(Map<Id, SObject> oldAffiliationMap, List<hed__Affiliation__c> affiliations) {
        List<hed__Affiliation__c> result = new List<hed__Affiliation__c>();
        for (hed__Affiliation__c affiliation : affiliations) {
            Boolean hasUpdatedKeyField = false;
            for (String fieldName : KEY_AFFILIATION_FIELDS) {
                if (!hasUpdatedKeyField && affiliation.get(fieldName) != oldAffiliationMap.get(affiliation.Id).get(fieldName)) {
                    result.add(affiliation);
                    hasUpdatedKeyField = true;
                }
            }
        }
        return result;
    }

    private static List<hed__Affiliation__c> getAffiliationsFrom(List<Id> recordIds) {
        if(!recordIds.isEmpty()) {
        String query =  ' SELECT Id, hed__Contact__c, ' + TB_SObjectUtils.getFieldsToSelectAsString(KEY_AFFILIATION_FIELDS) + 
                        ' FROM hed__Affiliation__c' + 
                        ' WHERE Id IN ' + TB_SObjectUtils.getFieldsToSetConditionAsString(recordIds);
        return (List<hed__Affiliation__c>) Database.query(query);
        } else {
            return null;
        }
    }

    private static List<TB_Contact_Affiliation_Counter__mdt> getMatchingRules() {
        return [
            SELECT TB_Affiliation_Employee_Affiliation_Type__c, TB_Affiliation_Employment_Group_3__c, TB_Affiliation_Level_of_Study__c, TB_Affiliation_Role__c, TB_Affiliation_Status__c, TB_Contact_Counter_API_Name__c,
            TB_Affiliation_Organization_Type__c
            FROM TB_Contact_Affiliation_Counter__mdt 
            WHERE 
                TB_Active__c = true
        ];
    }

    private static List<Contact> getParentContacts(List<hed__Affiliation__c> affiliations, List<TB_Contact_Affiliation_Counter__mdt> matchingRules) {
        List<String> recordIds = new List<String>();
        Set<String> contactCounterFields = new Set<String>();
        for (hed__Affiliation__c affiliation : affiliations) {
            recordIds.add(affiliation.hed__Contact__c);
        }
        if(!recordIds.isEmpty()) {
            for (TB_Contact_Affiliation_Counter__mdt matchingRule : matchingRules) {
                contactCounterFields.add(matchingRule.TB_Contact_Counter_API_Name__c);
            }
            String contactCounterFieldsString = !contactCounterFields.isEmpty() ? TB_SObjectUtils.getFieldsToSelectAsString(contactCounterFields) + ', ' : ' ';
            String query =
                    ' SELECT Id, ' + contactCounterFieldsString + getRelatedAffiliationQuery() +
                            ' FROM Contact' +
                            ' WHERE Id IN ' + TB_SObjectUtils.getFieldsToSetConditionAsString(recordIds);
            return (List<Contact>) Database.query(query);
        }else {
            return null;
        }
    }

	private static String getRelatedAffiliationQuery() {
		return  '( SELECT Id, ' + TB_SObjectUtils.getFieldsToSelectAsString(KEY_AFFILIATION_FIELDS) + 
			    ' FROM hed__affl_Accounts__r )';
	}
}
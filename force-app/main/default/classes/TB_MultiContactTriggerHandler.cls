/**
 * Created by jakubWrzodek on 12/01/23.
 */
public without sharing class TB_MultiContactTriggerHandler extends TB_TriggerHandler {
    public static Boolean IGNORE_TRIGGER = false;
    final private static String CONTACT_MATCHING_FIELD_NAME = 'TB_Matching_Field_Name__c';
    final private static String CONTACT_MATCHING_CONCAT_SIGN = '+';
    final private static String CONTACT_MATCHING_OBJECT_ID_FIELD_NAME = 'TB_Matching_Object_Id__c';
    final private static String CONTACT_TRIGGER_UPDATE_FIELD_NAME = 'TB_x_Trigger_Multicontact_Update__c';
    final private static Map<String, String> CONTACT_TO_INDIVIDUAL_KEY_FIELDS_MAP = new Map<String, String> {
        'TB_Global_Id__c' => 'TB_Global_Id__c',
        'DT_VDO_ID__c' => 'TB_VDO_Id__c',
        'TB_IM_Id__c' => 'TB_Student_IM_Id__c'
    };

    private static Boolean shouldFutureUpdateOtherContacts = false;

    public override void beforeInsert() {
        checkMultiContactDuplicates(Trigger.new);
    }

    public override void beforeUpdate() {
        checkMultiContactDuplicates(Trigger.oldMap, Trigger.new);
    }

    private static void checkMultiContactDuplicates(List<Contact> contacts) {
        List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules = getMatchingRules();
        checkMultiContactDuplicates(contacts, matchingRules);
    }

    private static void checkMultiContactDuplicates(Map<Id, SObject> oldContactsMap, List<Contact> contacts) {
        List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules = getMatchingRules();
        checkMultiContactDuplicates(oldContactsMap, contacts, matchingRules);
        clearTriggerMultiContactUpdateCheckbox(contacts);
    }

    @TestVisible
    private static void checkMultiContactDuplicates(Map<Id, SObject> oldContactsMap, List<Contact> contacts, List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules) {
        List<Contact> affectedContacts = new List<Contact>();
        shouldFutureUpdateOtherContacts = false;
        for (Contact contact : contacts) {
            Boolean isAffected = false;
            for (TB_Multi_Contact_Matching_Rule__mdt matchingRule : matchingRules) {
                if (IGNORE_TRIGGER) {
                    shouldFutureUpdateOtherContacts = contact.get(CONTACT_TRIGGER_UPDATE_FIELD_NAME) != null && Boolean.valueOf(contact.get(CONTACT_TRIGGER_UPDATE_FIELD_NAME));
                } else {
                    shouldFutureUpdateOtherContacts = Trigger.isUpdate
                            || (contact.get(CONTACT_TRIGGER_UPDATE_FIELD_NAME) != null && Boolean.valueOf(contact.get(CONTACT_TRIGGER_UPDATE_FIELD_NAME)));
                }

                if (!isAffected) {
                    Boolean isConcat = matchingRule.TB_Matching_Field_API_Name__c.contains(CONTACT_MATCHING_CONCAT_SIGN);
                    List<String> fieldApiNames = isConcat ?
                            matchingRule.TB_Matching_Field_API_Name__c.replaceAll('\\s+', '').split('\\' + CONTACT_MATCHING_CONCAT_SIGN) :
                            new List<String>{matchingRule.TB_Matching_Field_API_Name__c};
                    for (String fieldApiName : fieldApiNames) {
                        Boolean isFieldChanged = contact.get(fieldApiName) != oldContactsMap.get(contact.Id).get(fieldApiName);
                        if (isFieldChanged || shouldFutureUpdateOtherContacts) {
                            isAffected = true;
                            affectedContacts.add(contact);
                            break;
                        }
                    }
                }
            }
        }
        if (affectedContacts.size() > 0) {
            checkMultiContactDuplicates(affectedContacts, matchingRules);
        }
    }

    @TestVisible
    private static void checkMultiContactDuplicates(List<Contact> contacts, List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules) {
        List<Contact> otherContacts = getOtherContacts(contacts, matchingRules);
        List<ContactMatcher> contactMatchers = new List<ContactMatcher>();
        List<IndividualMatcher> individualMatchers = new List<IndividualMatcher>();
        Set<Id> duplicatedIndividualsIds = new Set<Id>();
        for (Contact contact : contacts) {
            Matcher matcher = searchForDuplicates(contact, otherContacts, matchingRules, duplicatedIndividualsIds);
            if (matcher != null && matcher instanceof ContactMatcher) {
                contactMatchers.add((ContactMatcher) matcher);
            } else if (matcher != null && matcher instanceof IndividualMatcher) {
                individualMatchers.add((IndividualMatcher) matcher);
            }
        }
        performCrudActionsFrom(contactMatchers, contacts);
        updateIndividualFields(individualMatchers);
    }

    private static List<TB_Multi_Contact_Matching_Rule__mdt> getMatchingRules() {
        return [
            SELECT TB_Matching_Field_API_Name__c,
                    TB_Order__c,
                    TB_Active__c,
                    TB_Is_Triggered__c
                    FROM TB_Multi_Contact_Matching_Rule__mdt
                    WHERE TB_Active__c = true
                    AND TB_Is_Triggered__c = true
                    ORDER BY TB_Order__c
        ];
    }

    @TestVisible
    private static List<Contact> getOtherContacts(List<Contact> contacts, List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules) {
        final List<String> PREPARED_FIELDS = new List<String>{'Id', 'CreatedDate', 'FirstName', 'LastName', 'Salutation', 'BirthDate', 'TB_User__c', 'IndividualId'};
        Set<String> fieldsToGetSet = new Set<String>(PREPARED_FIELDS);
        List<String> fieldsConditions = new List<String>();
        for (TB_Multi_Contact_Matching_Rule__mdt matchingRule : matchingRules) {
            Boolean isConcat = matchingRule.TB_Matching_Field_API_Name__c.contains(CONTACT_MATCHING_CONCAT_SIGN);
            List<String> fieldApiNames = isConcat ?
                    matchingRule.TB_Matching_Field_API_Name__c.replaceAll('\\s+', '').split('\\' + CONTACT_MATCHING_CONCAT_SIGN) :
                    new List<String>{matchingRule.TB_Matching_Field_API_Name__c};
            fieldsToGetSet.addAll(fieldApiNames);
            for (Contact contact : contacts) {
                for (String fieldApiName : fieldApiNames) {
                    fieldsConditions.add(
                        fieldApiName + ' = \'' + contact.get(fieldApiName) + '\''
                    );
                }
            }
        }
        return matchingRules.size() > 0 && fieldsConditions.size() > 0 ? getContactsWithAnyFieldsFrom(new List<String>(fieldsToGetSet), fieldsConditions) : new List<Contact>();
    }

    @TestVisible
    private static List<Contact> getContactsWithAnyFieldsFrom(List<String> fieldsNames, List<String> fieldsConditions) {
        String fieldsToGetString = '';
        String fieldsConditionsString = fieldsConditions.size() > 0 ? ' AND ( ' : '';
        for (Integer i = 0; i < fieldsNames.size(); i++) {
            fieldsToGetString += fieldsNames.get(i) + 
                (i != fieldsNames.size() - 1 ? ', ' : '');
        }
        for (Integer i = 0; i < fieldsConditions.size(); i++) {
            fieldsConditionsString += fieldsConditions.get(i) + 
                (i != fieldsConditions.size() - 1 ? ' OR ' : ' )');
        }
        String queryString = 'SELECT ' + fieldsToGetString + ' FROM Contact WHERE TB_Active__c = true' + fieldsConditionsString + ' ORDER BY CreatedDate ASC';
        return Database.query(queryString);
    }

    @TestVisible
    private static Set<User> getUsersToUpdateFrom(Map<String, String> userIdToIndividualIdMap) {
        Set<User> result = new Set<User>([
            SELECT Id
            FROM User
            WHERE
                Id IN :userIdToIndividualIdMap.keySet() AND
                UserType = 'Standard'
        ]);
        for (User user : result) {
            user.IndividualId = userIdToIndividualIdMap.get(user.Id);
        }
        return result;
    }

    @TestVisible
    private static Matcher searchForDuplicates(
        Contact contact,
        List<Contact> otherContacts, 
        List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules,
            Set<Id> duplicatedIndividualsIds
    ) {
        Matcher result;
        Boolean hasDuplicate = false;
        Contact duplicateContact = null;
        String matchingFieldName = null;
        for (TB_Multi_Contact_Matching_Rule__mdt matchingRule : matchingRules) {
            if(!hasDuplicate) {
                matchingFieldName = matchingRule.TB_Matching_Field_API_Name__c;
                Boolean isConcat = matchingFieldName.contains(CONTACT_MATCHING_CONCAT_SIGN);
                for (Contact otherContact : otherContacts) {
                    if (otherContact.Id == contact.Id) {
                        continue;
                    }
                    if (!hasDuplicate && (isConcat ? areAllConcatFieldsEqual(contact, otherContact, matchingFieldName) :
                            contact.get(matchingFieldName) != null && contact.get(matchingFieldName) == otherContact.get(matchingFieldName))) {
                        hasDuplicate = true;
                        duplicateContact = otherContact;
                        contact.put(CONTACT_MATCHING_FIELD_NAME, matchingFieldName);
                        contact.put(CONTACT_MATCHING_OBJECT_ID_FIELD_NAME, otherContact.Id);
                    }
                }
            }
        }

        if (duplicateContact != null && duplicateContact.IndividualId != null
                && contact.IndividualId != duplicateContact.IndividualId) {

            if (Test.isRunningTest() || shouldFutureUpdateOtherContacts || Trigger.isInsert) {
                if (duplicatedIndividualsIds.contains(contact.IndividualId)) {
                    return (Matcher) new IndividualMatcher(contact.IndividualId, contact);
                }
                duplicatedIndividualsIds.add(duplicateContact.IndividualId);

                contact.IndividualId = duplicateContact.IndividualId;
                result = (Matcher) new IndividualMatcher(duplicateContact.IndividualId, contact);
            }

        } else if (contact.IndividualId == null || shouldFutureUpdateOtherContacts) {
            ContactMatcher matcher = new ContactMatcher(contact);
            matcher.otherContact = duplicateContact;
            matcher.individual = new Individual(
                LastName = contact.LastName,
                FirstName = contact.FirstName,
                Salutation = contact.Salutation,
                BirthDate = contact.BirthDate,
                TB_Global_Id__c = contact.TB_Global_Id__c,
                TB_VDO_Id__c = contact.DT_VDO_ID__c
            );
            if (TB_re_Utils.isStudentContact(contact)) {
                matcher.individual.TB_Student_IM_Id__c = contact.TB_IM_Id__c;
            }
            matcher.matchingFieldName = matchingFieldName;
            result = (Matcher) matcher;
        }
        return result;
    }

    private static Boolean areAllConcatFieldsEqual(Contact firstContact, Contact secondContact, String matchingField) {
        List<String> fieldsNames = matchingField.replaceAll('\\s+', '').split('\\' + CONTACT_MATCHING_CONCAT_SIGN);
        for (String fieldName : fieldsNames) {
            if (!(firstContact.get(fieldName) != null && firstContact.get(fieldName) == secondContact.get(fieldName))) {
                return false;
            }
        }
        return true;
    }

    @TestVisible
    private static void performCrudActionsFrom(List<ContactMatcher> contactMatchers, List<Contact> contacts) {
        try {
            Set<Contact> otherContactsToUpdate = new Set<Contact>();
            Map<String, String> otherContactsIdToIndividualIdMap = new Map<String, String>();
            Map<String, String> userIdToIndividualIdMap = new Map<String, String>();
            upsertIndividuals(contactMatchers);

            for (Contact contact : contacts) {
                if (contact.IndividualId != null) {
                    userIdToIndividualIdMap.put(contact.TB_User__c, contact.IndividualId);
                }
            }
            for (ContactMatcher contactMatcher : contactMatchers) {
                contactMatcher.setIndividualId(contactMatcher.individual.Id);
                if (contactMatcher.otherContact != null) {
                    otherContactsIdToIndividualIdMap.put(contactMatcher.otherContact.Id, contactMatcher.individual.Id);
                    otherContactsToUpdate.add(contactMatcher.otherContact);
                }
                userIdToIndividualIdMap.put(contactMatcher.newContact.TB_User__c, contactMatcher.individual.Id);
            }
            if (shouldFutureUpdateOtherContacts) {
                TB_MultiContactTriggerHandlerService.asyncUpdateContacts(otherContactsIdToIndividualIdMap);
            } else if (!otherContactsToUpdate.isEmpty()) {
                update new List<Contact>(otherContactsToUpdate);
            }

            Set<User> usersToUpdate = getUsersToUpdateFrom(userIdToIndividualIdMap);
            update new List<User>(usersToUpdate);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }

    private static void upsertIndividuals(List<ContactMatcher> contactMatchers) {
        Set<Decimal> globalIds = new Set<Decimal>();
        Set<String> studentImIds = new Set<String>();
        Set<String> vdoIds = new Set<String>();
        for (ContactMatcher contactMatcher : contactMatchers) {
            if (contactMatcher.individual.TB_Global_Id__c != null) {
                globalIds.add(contactMatcher.individual.TB_Global_Id__c);
            }
            if (contactMatcher.individual.TB_Student_IM_Id__c != null) {
                studentImIds.add(contactMatcher.individual.TB_Student_IM_Id__c);
            }
            if (contactMatcher.individual.TB_VDO_Id__c != null) {
                vdoIds.add(contactMatcher.individual.TB_VDO_Id__c);
            }
        }
        List<Individual> relatedIndividuals = [
            SELECT Id, TB_Global_Id__c, TB_Student_IM_Id__c, TB_VDO_Id__c
            FROM Individual
            WHERE TB_Global_Id__c IN :globalIds OR TB_Student_IM_Id__c IN :studentImIds OR TB_VDO_Id__c IN :vdoIds
        ];
        for (ContactMatcher contactMatcher : contactMatchers) {
            for (ContactMatcher otherContactMatcher : contactMatchers) {
                if (areIndividualsRelated(contactMatcher.individual, otherContactMatcher.individual)) {
                    contactMatcher.individual = copyInfoToOtherIndividual(contactMatcher.individual, otherContactMatcher.individual);
                }
            }
            for (Individual relatedIndividual : relatedIndividuals) {
                if (areIndividualsRelated(contactMatcher.individual, relatedIndividual)) {
                    contactMatcher.individual = copyInfoToOtherIndividual(contactMatcher.individual, relatedIndividual);
                }
            }
        }
        Set<Individual> individuals = new Set<Individual>();
        for (ContactMatcher contactMatcher : contactMatchers) {
            if (contactMatcher.individual != null) {
                individuals.add(contactMatcher.individual);
            }
        }

        if (!individuals.isEmpty()) {
            upsert new List<Individual>(individuals);
        }
    }

    private static Boolean areIndividualsRelated(Individual firstIndividual, Individual secondIndividual) {
        return secondIndividual != null && ((firstIndividual.TB_Global_Id__c != null && firstIndividual.TB_Global_Id__c == secondIndividual.TB_Global_Id__c) ||
                (firstIndividual.TB_Student_IM_Id__c != null && firstIndividual.TB_Student_IM_Id__c == secondIndividual.TB_Student_IM_Id__c) ||
                (firstIndividual.TB_VDO_Id__c != null && firstIndividual.TB_VDO_Id__c == secondIndividual.TB_VDO_Id__c));
    }

    private static Individual copyInfoToOtherIndividual(Individual fromIndividual, Individual toIndividual) {
        toIndividual.LastName = fromIndividual.LastName;
        toIndividual.FirstName = fromIndividual.FirstName;
        toIndividual.Salutation = fromIndividual.Salutation;
        toIndividual.BirthDate = fromIndividual.BirthDate;
        toIndividual.TB_Global_Id__c = fromIndividual.TB_Global_Id__c;
        toIndividual.TB_VDO_Id__c = fromIndividual.TB_VDO_Id__c;
        toIndividual.TB_Student_IM_Id__c = fromIndividual.TB_Student_IM_Id__c;
        return toIndividual;
    }

    @TestVisible
    private static void updateIndividualFields(List<IndividualMatcher> individualsMatchers) {
        Map<Id, Contact> individualIdToContactMap = new Map<Id, Contact>();
        for (IndividualMatcher matcher : individualsMatchers) {
            individualIdToContactMap.put(matcher.individualId, matcher.contact);
        }
        Map<Id, Individual> individualMap = new Map<Id, Individual>([
            SELECT Id, TB_Global_Id__c, TB_VDO_Id__c, TB_Student_IM_Id__c
            FROM Individual
            WHERE 
                Id IN :individualIdToContactMap.keySet()
        ]);
        for (Individual individual : individualMap.values()) {
            Contact contact = individualIdToContactMap.get(individual.Id);
            for (String contactField : CONTACT_TO_INDIVIDUAL_KEY_FIELDS_MAP.keySet()) {
                String individualField = CONTACT_TO_INDIVIDUAL_KEY_FIELDS_MAP.get(contactField);
                if (individual.get(individualField) == null && contact.get(contactField) != null) {
                    individual.put(individualField, contact.get(contactField));
                }
            }
        }
        update individualMap.values();
    }

    private static void clearTriggerMultiContactUpdateCheckbox(List<Contact> contacts) {
        for(Contact contact : contacts) {
            contact.TB_x_Trigger_Multicontact_Update__c = false;
        }
    }

    public abstract class Matcher {} 

    public class ContactMatcher extends Matcher {
        public String matchingFieldName;
        public Contact newContact;
        public Contact otherContact;
        public Individual individual;

        public ContactMatcher(Contact newContact) {
            this.newContact = newContact;
        }

        public void setIndividualId(String individualId) {
            newContact.IndividualId = individualId;
            if (otherContact != null) {
                otherContact.IndividualId = individualId;
            }
        }
    }

    public class IndividualMatcher extends Matcher {
        public Id individualId;
        public Contact contact;

        public IndividualMatcher(Id individualId, Contact contact) {
            this.contact = contact;
            this.individualId = individualId;
        }
    }
}

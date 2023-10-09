public with sharing class TB_CT_SearchExistingEmployeeController {

    private static final Integer MAX_RESULTS = 5;
    private static final String CONTACT_ICON = 'standard:contact';
    private static final String CONTACT_FIELD_FIRST_NAME = Contact.FirstName.getDescribe().getName();
    private static final String CONTACT_FIELD_LAST_NAME = Contact.LastName.getDescribe().getName();
    private static final String CONTACT_FIELD_CITIZENSHIP = Contact.TB_Citizenship__c.getDescribe().getName();
    private static final String CONTACT_FIELD_TITLE = Contact.TB_Title_Grade__c.getDescribe().getName();
    private static final String CONTACT_FIELD_WORK_PHONE = Contact.hed__WorkPhone__c.getDescribe().getName();
    private static final String CONTACT_FIELD_ALTERNATE_EMAIL = Contact.hed__AlternateEmail__c.getDescribe().getName();
    private static final String CONTACT_FIELD_PHONE = Contact.Phone.getDescribe().getName();
    private static final String CONTACT_FIELD_MOBILE_PHONE = Contact.MobilePhone.getDescribe().getName();
    private static final String CONTACT_FIELD_PESEL = Contact.DT_PESEL__c.getDescribe().getName();
    private static final String CONTACT_FIELD_ID = Contact.Id.getDescribe().getName();
    private static final String OBJECT_CONTACT = Schema.SObjectType.Contact.getName();
    private static final String CONTACT_FIELD_RECORD_TYPE = Contact.RecordTypeId.getDescribe().getName();
    private static final String CONTACT_RECORD_TYPE_EMPLOYEE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();

    @AuraEnabled
    public static List<ContactWrapper> searchExistingEmployee(String phone, String email, String pesel, String firstName,
            String lastName, String citizenship, String title, String uniWorkDepartment) {
        try {
            List<SObject> result = new List<SObject> ();
            String query = getQuery(firstName, lastName, citizenship, title, uniWorkDepartment, phone, email, pesel);
            result = Database.query(query);

            return getContactWrappers(result);
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(
                    e.getMessage(), TB_CT_SearchExistingEmployeeController.class.getName(),
                    e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
        }
    }

    @AuraEnabled
    public static DuplicateWrapper checkDuplicates(String email, String pesel) {
        String contactQuery = 'SELECT Id,DT_PESEL__c, hed__AlternateEmail__c '
                + 'FROM Contact WHERE hed__AlternateEmail__c =:email '
                + 'AND RecordTypeId = :CONTACT_RECORD_TYPE_EMPLOYEE_ID AND (TB_Didactic_Applicant_HE__c = true OR TB_Didactic_Applicant_PG__c = true OR TB_x_Existing_Didactic__c = true) ';
        String appTrackQuery = 'SELECT Id,TB_Email__c,TB_PESEL__c FROM TB_App_Tracking__c WHERE TB_Email__c = :email';

        List<Contact> contacts = (List<Contact>) Database.query(contactQuery);
        List<TB_App_Tracking__c> appTrackings = (List<TB_App_Tracking__c>) Database.query(appTrackQuery);

        DuplicateWrapper wrapper = new DuplicateWrapper();
        checkDuplicates(contacts,wrapper,email,pesel);
        checkDuplicates(appTrackings,wrapper,email,pesel);
        return wrapper;
    }

    private static void checkDuplicates(List<Contact> contacts,DuplicateWrapper wrapper,String email, String pesel){
        for(Contact cont : contacts){
            if(cont.hed__AlternateEmail__c == email){
                wrapper.isDuplicateContact = true;
            }
            if(cont.DT_PESEL__c == pesel){
                wrapper.isDuplicateContactPesel = true;
            }
        }
    }

    private static void checkDuplicates(List<TB_App_Tracking__c> appTrackings,DuplicateWrapper wrapper,String email, String pesel){
        for(TB_App_Tracking__c app : appTrackings){
            if(app.TB_Email__c == email){
                wrapper.isDuplicateAppTracking = true;
            }
            if(app.TB_PESEL__c == pesel){
                wrapper.isDuplicateAppTrackingPesel = true;
            }
        }
    }

    private static List<LookupSearchResult> filterContacts(List<Contact> contacts) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        for(Contact c : contacts) {
            results.add(new LookupSearchResult(c.Id, 'Contact', CONTACT_ICON, c.Name, 'contact'));
        }

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchContacts(String name) {
        name += '*';

        List<List<SObject>> searchResults = [
                FIND :name
                IN NAME FIELDS
                RETURNING CONTACT(
                        Id, Name
                        WHERE
                        RecordTypeId =: CONTACT_RECORD_TYPE_EMPLOYEE_ID
                )
                LIMIT :MAX_RESULTS
        ];

        Contact[] contacts = (List<Contact>) searchResults[0];
        List<LookupSearchResult> filteredContacts = filterContacts(contacts);
        filteredContacts.sort();
        return filteredContacts;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> initLookupResults() {
        return filterContacts(fetchContacts());
    }

    @AuraEnabled(Cacheable=true)
    public static List<Contact> fetchContacts() {
        return [SELECT LastName, FirstName, Name, Email
                FROM Contact
                WHERE RecordTypeId = :CONTACT_RECORD_TYPE_EMPLOYEE_ID AND TB_Active__c = TRUE
                LIMIT :MAX_RESULTS];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Account> fetchUniversityDepartments(Boolean isSearch) {
        Id recordTypeId = Schema.SObjectType.Account.recordTypeInfosByDeveloperName.get(TB_Constants.TB_CT_RECORD_TYPE_UNI_DEPARTMENTS).getRecordTypeId();
        if(!isSearch) {
            return [SELECT Name, TB_Account_Name_EN__c, TB_Account_Name_PL__c
            FROM Account
            WHERE RecordTypeId = :recordTypeId
            AND Type = :TB_Constants.TB_CT_ACCOUNT_TYPE_FACULTY
            AND TB_Active__c = TRUE
            LIMIT 50000
            ];
        }

        Set<Id> affiliationsWithDepartsIds = new Set<Id>();
        for(hed__Affiliation__c affiliationWithDepart : [SELECT hed__Account__c FROM hed__Affiliation__c WHERE hed__Role__c = 'Employee' AND hed__Account__r.TB_Active__c = TRUE LIMIT 25000]) {
            affiliationsWithDepartsIds.add(affiliationWithDepart.hed__Account__c);
        }
        return [SELECT Name, TB_Account_Name_EN__c, TB_Account_Name_PL__c
                FROM Account
                WHERE Id IN :affiliationsWithDepartsIds
                AND RecordTypeId = :recordTypeId
                AND Type = :TB_Constants.TB_CT_ACCOUNT_TYPE_FACULTY
                AND TB_Active__c = TRUE
                LIMIT 25000
        ];
    }

    private static String getQuery(String firstName, String lastName, String citizenship, String title,
            String department, String phone, String email, String pesel) {
        String query = 'SELECT '
                + CONTACT_FIELD_LAST_NAME + ', '
                + CONTACT_FIELD_FIRST_NAME + ', '
                + CONTACT_FIELD_WORK_PHONE + ', '
                + CONTACT_FIELD_ALTERNATE_EMAIL + ', '
                + CONTACT_FIELD_PHONE + ', '
                + CONTACT_FIELD_MOBILE_PHONE + ', '
                + CONTACT_FIELD_PESEL + ', '
                + CONTACT_FIELD_TITLE + ', '
                + CONTACT_FIELD_CITIZENSHIP + ', '
                + ' TB_x_Existing_Didactic__c '
                        + ' FROM '
                + OBJECT_CONTACT + ' WHERE ';
        List<String> conditions = new List<String>();
        if (String.isNotBlank(firstName)) {
            conditions.add(CONTACT_FIELD_FIRST_NAME + ' = ' + '\'' + String.escapeSingleQuotes(firstName) + '\'');
        }
        if (String.isNotBlank(lastName)) {
            conditions.add('(' + CONTACT_FIELD_LAST_NAME + ' LIKE ' + '\'' + lastName + '%\' OR ' + CONTACT_FIELD_LAST_NAME
                    + ' LIKE \'% ' + + String.escapeSingleQuotes(lastName) + '%\' OR ' + CONTACT_FIELD_LAST_NAME +
                    ' LIKE \'%-' + + String.escapeSingleQuotes(lastName) + '%\')');
        }
        if (String.isNotBlank(citizenship)) {
            conditions.add(CONTACT_FIELD_CITIZENSHIP + ' = ' + '\'' + String.escapeSingleQuotes(citizenship) + '\'');
        }
        if (String.isNotBlank(title)) {
            conditions.add(CONTACT_FIELD_TITLE + ' = ' + '\'' + String.escapeSingleQuotes(title) + '\'');
        }
        if (String.isNotBlank(department)) {
            List<AggregateResult> affiliations = [
                    SELECT hed__Contact__c contactId
                    FROM hed__Affiliation__c
                    WHERE hed__Account__c = :department
                    GROUP BY hed__Contact__c
            ];
            List<Id> applicantIds = new List<Id>();
            for (AggregateResult aggRes : affiliations) {
                applicantIds.add((Id) aggRes.get('contactId'));
            }
            String queryExpression = CONTACT_FIELD_ID + ' = ' + '\'';
            String applicantIdsJoined = String.join(
                    applicantIds,
                    '\'' + TB_Constants.PARAM_WHITESPACE + TB_Constants.LOGIC_OPERATOR_OR + TB_Constants.PARAM_WHITESPACE + queryExpression
            );
            String queryPart = '(' + queryExpression + applicantIdsJoined + '\'' + ')';
            conditions.add(queryPart);
        }
        if(String.isNotBlank(phone)){
            conditions.add(CONTACT_FIELD_PHONE + ' LIKE ' + '\'' + String.escapeSingleQuotes(phone) + '%\'');
        }
        if(String.isNotBlank(email)){
            conditions.add(CONTACT_FIELD_ALTERNATE_EMAIL + ' = ' + '\'' + String.escapeSingleQuotes(email) + '\'');
        }
        if(String.isNotBlank(pesel)){
            conditions.add(CONTACT_FIELD_PESEL + ' = ' + '\'' + String.escapeSingleQuotes(pesel) + '\'');
        }

        String separator = TB_Constants.PARAM_WHITESPACE + TB_Constants.LOGIC_OPERATOR_AND + TB_Constants.PARAM_WHITESPACE;
        conditions.add(CONTACT_FIELD_RECORD_TYPE + ' = ' + '\'' + String.escapeSingleQuotes(CONTACT_RECORD_TYPE_EMPLOYEE_ID) + '\'');
        conditions.add('(TB_Didactic_Applicant_HE__c = true OR TB_Didactic_Applicant_PG__c = true OR TB_x_Existing_Didactic__c = true)');
        query += String.join(conditions, separator);
        return query;
    }

    private static List<ContactWrapper> getContactWrappers( List<SObject> objects) {
        List<Contact> contacts = objects;
        Set<String> contactIds = TB_SObjectUtils.createIdFieldValueSet(contacts, Contact.Id);
        Map<Id, TB_App_Tracking__c> applicantIdToAppTracking = new Map<Id, TB_App_Tracking__c>();
        for (TB_App_Tracking__c app : [
                SELECT TB_Process_Status__c, TB_Uni_Work_Department__r.Name, TB_Applicant__c, TB_Uni_Work_Department__c
                FROM TB_App_Tracking__c
                WHERE TB_Applicant__c
                        IN :contactIds
        ]) {
            applicantIdToAppTracking.put(app.TB_Applicant__c, app);
        }
        List<ContactWrapper> result = new List<ContactWrapper>();
        for (Contact contact : contacts) {
            ContactWrapper wrapper = new ContactWrapper();
            wrapper.id = contact.Id;
            wrapper.firstName = contact.FirstName;
            wrapper.lastName = contact.LastName;
            wrapper.workPhone = contact.hed__WorkPhone__c;
            wrapper.email = contact.hed__AlternateEmail__c;
            wrapper.phone = contact.Phone;
            wrapper.mobilePhone = contact.MobilePhone;
            wrapper.pesel = contact.DT_PESEL__c;
            wrapper.citizenship = contact.TB_Citizenship__c;
            wrapper.title = contact.TB_Title_Grade__c;
            wrapper.status = applicantIdToAppTracking.get(contact.Id)?.TB_Process_Status__c;
            wrapper.departmentName = applicantIdToAppTracking.get(contact.Id)?.TB_Uni_Work_Department__r.Name;
            wrapper.departmentId = applicantIdToAppTracking.get(contact.Id)?.TB_Uni_Work_Department__c;
            wrapper.xExistingDidactic = contact.TB_x_Existing_Didactic__c;
            result.add(wrapper);
        }
        return result;
    }

    public class DuplicateWrapper {
        @AuraEnabled public Boolean isDuplicateContact;
        @AuraEnabled public Boolean isDuplicateAppTracking;
        @AuraEnabled public Boolean isDuplicateContactPesel;
        @AuraEnabled public Boolean isDuplicateAppTrackingPesel;

        public DuplicateWrapper(){
            this.isDuplicateAppTracking = false;
            this.isDuplicateAppTrackingPesel = false;
            this.isDuplicateContact = false;
            this.isDuplicateAppTrackingPesel = false;
        }
    }

    public class ContactWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String lastName;
        @AuraEnabled public String firstName;
        @AuraEnabled public String workPhone;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String mobilePhone;
        @AuraEnabled public String pesel;
        @AuraEnabled public String citizenship;
        @AuraEnabled public String title;
        @AuraEnabled public String status;
        @AuraEnabled public String departmentName;
        @AuraEnabled public String departmentId;
        @AuraEnabled public Boolean xExistingDidactic;
    }
}
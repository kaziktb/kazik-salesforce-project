public without sharing class TB_vu_StudentOrganizationWizard {
    public static final String studentOrganisationRecordTypeName = 'TB_Students_Organisation';
    public static final String unitTypeName = 'WYDZIAL';
    public static final String QUERY_ERROR_CONTACTS_NOT_FOUND = 'Contacts not found';
    public static final String DELETE_ACTION = 'DELETE';
    public static final String INSERT_ACTION = 'INSERT';

    public class Organization {
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String chairman { get; set; }
        @AuraEnabled public String supervisor { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String shortName { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String department { get; set; }
        @AuraEnabled public Date startDate { get; set; }
        @AuraEnabled public String description { get; set; }
    }

    public class ContactWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String email { get; set; }
    }

    @AuraEnabled(Cacheable=true)
    public static List<Account> getUniversityDepartments() {
        try {
            return [
                SELECT Id, TB_Account_Name_PL__c, TB_Account_Name_EN__c, RecordTypeId
                FROM Account
                WHERE DT_Unit_Type__c = :unitTypeName
                AND TB_Active__c = TRUE
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_StudentOrganizationWizard.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }

    @AuraEnabled
    public static String saveOrganization(Organization organizationData, List<String> memberIds) {
        try {
            Account newOrganization = new Account();
            newOrganization.Id = organizationData.recordId;
            newOrganization.TB_Status__c = organizationData.status;
            newOrganization.hed__Primary_Contact__c = organizationData.chairman;
            newOrganization.TB_Supervisor__c = organizationData.supervisor;
            newOrganization.Name = organizationData.name;
            newOrganization.TB_Account_Name_PL__c = organizationData.name;
            newOrganization.TB_Account_Name_EN__c = organizationData.name;
            newOrganization.TB_Account_Name_Short_PL__c = organizationData.shortName;
            newOrganization.TB_Account_Name_Short_EN__c = organizationData.shortName;
            newOrganization.TB_Organisation_Type__c = organizationData.type;
            newOrganization.ParentId = organizationData.department;
            newOrganization.TB_Start_Date__c = Date.today();
            newOrganization.TB_Description_PL__c = organizationData.description;
            newOrganization.TB_Description_EN__c = organizationData.description;
            newOrganization.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(studentOrganisationRecordTypeName).getRecordTypeId();

            upsert newOrganization;

            Set<String> memberIdsCopy = new Set<String>();
            if(!memberIds.isEmpty()) {
                memberIdsCopy.addAll(memberIds);
            }
            Map<String, List<hed__Affiliation__c>> affiliationMap = new Map<String, List<hed__Affiliation__c>>{
                    TB_Constants.AFFILIATION_ROLE_CHAIRMAN => new List<hed__Affiliation__c>(),
                    TB_Constants.AFFILIATION_ROLE_SUPERVISOR => new List<hed__Affiliation__c>(),
                    DELETE_ACTION => new List<hed__Affiliation__c>(),
                    INSERT_ACTION => new List<hed__Affiliation__c>()
            };

            for(hed__Affiliation__c a : [SELECT Id, hed__Role__c, hed__Status__c, hed__Contact__c FROM hed__Affiliation__c
            WHERE hed__Account__c =: newOrganization.Id
            AND hed__Role__c IN: TB_Constants.NEW_ORGANISATION_ROLES
            AND hed__Status__c IN: TB_Constants.NEW_ORGANISATIONS_STATUSES]){
                if(a.hed__Role__c == TB_Constants.AFFILIATION_ROLE_CHAIRMAN){
                    affiliationMap.get(TB_Constants.AFFILIATION_ROLE_CHAIRMAN).add(a);
                } else if(a.hed__Role__c == TB_Constants.AFFILIATION_ROLE_SUPERVISOR){
                    affiliationMap.get(TB_Constants.AFFILIATION_ROLE_SUPERVISOR).add(a);
                } else if(a.hed__Role__c == TB_Constants.AFFILIATION_ROLE_MEMBER && a.hed__Status__c == TB_Constants.AFFILIATION_STATUS_AWAITING){
                    if(!memberIds.contains(a.hed__Contact__c)){
                        affiliationMap.get(DELETE_ACTION).add(a);
                    } else {
                        memberIdsCopy.remove(a.hed__Contact__c);
                    }
                }
            }

            //CHAIRMAN LOGIC
            manageRelatedAffiliations(affiliationMap, newOrganization, TB_Constants.AFFILIATION_ROLE_CHAIRMAN,
                    TB_Constants.AFFILIATION_STATUS_CURRENT, 'hed__Primary_Contact__c');

            //SUPERVISOR LOGIC
            manageRelatedAffiliations(affiliationMap, newOrganization, TB_Constants.AFFILIATION_ROLE_SUPERVISOR,
                    TB_Constants.AFFILIATION_STATUS_AWAITING, 'TB_Supervisor__c');

            //MEMBER LOGIC
            if(!memberIdsCopy.isEmpty()) {
                for (String contactId : memberIdsCopy) {
                    affiliationMap.get(INSERT_ACTION).add(prepareNewAffiliation(newOrganization.Id, contactId, TB_Constants.AFFILIATION_ROLE_MEMBER, TB_Constants.AFFILIATION_STATUS_AWAITING));
                }
            }
            delete affiliationMap.get(DELETE_ACTION);
            insert affiliationMap.get(INSERT_ACTION);
            return newOrganization.Id;
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_StudentOrganizationWizard.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }

    @AuraEnabled
    public static Account getDraft(String recordId) {
        try {
            return [
                SELECT Id, TB_Status__c, hed__Primary_Contact__c, TB_Account_Name_PL__c, TB_Account_Name_EN__c,
                    TB_Account_Name_Short_PL__c, TB_Account_Name_Short_EN__c, TB_Organisation_Type__c,
                    ParentId, TB_Description_PL__c, TB_Start_Date__c, TB_Description_EN__c, TB_Supervisor__c, TB_Supervisor__r.Name,
                    (SELECT Id, Name, hed__Contact__r.Name, hed__Contact__r.TB_x_University_Email_Tech__c, hed__Contact__c
                    FROM hed__Affl_Contacts__r WHERE hed__Role__c = 'SO_Member')
                FROM Account
                WHERE Id = :recordId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_StudentOrganizationWizard.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }

    @AuraEnabled
    public static Contact getContactDataBasedOnCurrentUserId() {
        try {
            return [
                    SELECT Id, Name, hed__UniversityEmail__c
                    FROM Contact
                    WHERE TB_User__c = :UserInfo.getUserId()
                    AND TB_Active__c = TRUE
                    AND TB_Anonymization_Status__c = NULL
                    AND TB_Duplicate__c = FALSE
                    LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_StudentOrganizationWizard.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }

    @AuraEnabled
    public static ContactWrapper getContactDataBasedOnEmail(String email, Boolean supervisor) {
        try {
            ContactWrapper cw = new ContactWrapper();
            String userEmail = String.isBlank(email) ? UserInfo.getUserEmail() : String.escapeSingleQuotes(email);
            String queryString = 'SELECT Id, Name, TB_x_University_Email_Tech__c, TB_x_Work_Email_Tech__c FROM Contact WHERE ' +
                    'TB_Active__c = true AND TB_Duplicate__c = false AND TB_Anonymization_Status__c = null AND ';
            if(supervisor){
                queryString += 'TB_Eligible_For_SO_Supervisor__c = true AND TB_x_Work_Email_Tech__c =: userEmail AND RecordType.DeveloperName = \'TB_Employee\' ';
            } else {
                queryString += 'TB_x_University_Email_Tech__c =: userEmail AND RecordType.DeveloperName = \'TB_Student\'';
            }
            queryString += 'ORDER BY LastModifiedDate DESC';
            List<Contact> contacts = Database.query(queryString);
            if(contacts.size() != 1){
                String errorMsg = contacts.size() == 0 ? QUERY_ERROR_CONTACTS_NOT_FOUND : Label.TB_Error_More_Than_One_Contact;
                throw new QueryException(errorMsg);
            }
            cw.id = contacts[0].Id;
            cw.name = contacts[0].Name;
            cw.email = supervisor ? contacts[0].TB_x_Work_Email_Tech__c : contacts[0].TB_x_University_Email_Tech__c;
            return cw;
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_StudentOrganizationWizard.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }

    private static void manageRelatedAffiliations(Map<String, List<hed__Affiliation__c>> affiliationMap,
            Account acc, String role, String status, String fieldApiName){
        if(affiliationMap.get(role).size() == 0 && String.isNotEmpty((String)acc.get(fieldApiName))){
            affiliationMap.get(INSERT_ACTION).add(prepareNewAffiliation(acc.Id, (Id)acc.get(fieldApiName), role, status));
        } else if(affiliationMap.get(role).size() == 1) {
            if (affiliationMap.get(role)[0].hed__Contact__c != (Id)acc.get(fieldApiName)) {
                affiliationMap.get(DELETE_ACTION).addAll(affiliationMap.get(role));
                if(String.isNotEmpty((String)acc.get(fieldApiName))){
                    affiliationMap.get(INSERT_ACTION).add(prepareNewAffiliation(acc.Id, (Id)acc.get(fieldApiName), role, status));
                }
            }
        } else if(affiliationMap.get(role).size() > 1){
            affiliationMap.get(DELETE_ACTION).addAll(affiliationMap.get(role));
            if(String.isNotEmpty((String)acc.get(fieldApiName))){
                affiliationMap.get(INSERT_ACTION).add(prepareNewAffiliation(acc.Id, (Id)acc.get(fieldApiName), role, status));
            }
        }
    }

    private static hed__Affiliation__c prepareNewAffiliation(Id accountId, Id contactId, String role, String status){
        return new hed__Affiliation__c(
                hed__Account__c = accountId,
                hed__Contact__c = contactId,
                hed__Role__c = role,
                hed__Status__c = status,
                hed__StartDate__c = Date.today()
        );
    }
}
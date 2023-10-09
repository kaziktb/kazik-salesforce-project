public with sharing class TB_MultiContact360ViewController {
    public static final String PHOTO_CATEGORY = 'Profile_Photo';
    public static final String CONTACT_API_NAME = 'Contact';
    public static final String CONTACT_STUDENT_API_NAME = 'TB_Student';
    public static final Map<String, String> CONTACT_LOOKUP_API_NAMES = new Map<String, String>{
            'Case' => 'ContactId',
            'hed__Application__c' => 'hed__Applicant__c',
            'hed__Program_Enrollment__c' => 'hed__Contact__c'
    };

    @AuraEnabled(Cacheable=true)
    public static String getContactTypes(String contactId) {
        try {
            String individual = [
                    SELECT IndividualId
                    FROM Contact
                    WHERE Id = :contactId
            ].IndividualId;

            if (String.isNotBlank(individual)) {
                return JSON.serialize([
                        SELECT RecordType.DeveloperName
                        FROM Contact
                        WHERE IndividualId = :individual
                ]);
            } else {
                return null;
            }
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static String getProfilePhotos(String contactId) {
        try {
            Set<Id> contactIds = (new Map<Id, Contact>([
                    SELECT Id
                    FROM Contact
                    WHERE IndividualId = :[
                            SELECT IndividualId
                            FROM Contact
                            WHERE Id = :contactId
                    ].IndividualId
            ])).keySet();

            List<ContentDocumentLink> contentDocumentLinks = [
                    SELECT ContentDocumentId, LinkedEntityId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :contactIds
            ];

            List<String> contentDocumentLinkIds = new List<String>();
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
                contentDocumentLinkIds.add(contentDocumentLink.ContentDocumentId);
            }

            List<ContentVersion> contentVersions = [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE ContentDocumentId = :contentDocumentLinkIds
                    AND TB_Category__c = :PHOTO_CATEGORY
            ];

            Map<String, String> contentMap = new Map<String, String>();
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
                for (ContentVersion contentVersion : contentVersions) {
                    if (contentDocumentLink.ContentDocumentId == contentVersion.ContentDocumentId) {
                        contentMap.put(String.valueOf(contentDocumentLink.LinkedEntityId), String.valueOf(contentVersion.Id));
                    }
                }
            }
            return JSON.serialize(contentMap);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static String getContactWrappers(String contactId) {
        List<Contact> contacts = getContactDataWrapper(contactId);
        List<ContactWrapper> contactWrappers = new List<ContactWrapper>();
        try {
            for (Contact singleContact : contacts) {
                contactWrappers.add(new ContactWrapper(singleContact));
            }
            return JSON.serialize(contactWrappers);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    private static List<Contact> getContactDataWrapper(String contactId) {
        try {
            return [
                    SELECT toLabel (Salutation) Salutation__Label, FirstName, MiddleName, LastName, TB_Title_PL__c, TB_Title_EN__c,
                            toLabel(TB_Citizenship__c) Citizenship__Label, RecordType.DeveloperName,
                            toLabel(hed__Gender__c) Gender__Label,
                            hed__Gender__c,
                            toLabel(TB_Anonymization_Status__c) Anonymization__Label,
                            TB_Active__c, TB_Test__c, TB_Duplicate__c, TB_Has_Potential_Duplicate__c,
                            TB_Email_Consent_Status__c, TB_SMS_Consent_Status__c, TB_Phone_Consent_Status__c, TB_PDP_Consent_Status__c,
                            MailingStreet, MailingCity, MailingPostalCode, MailingCountry,
                            OtherStreet, OtherCity, OtherPostalCode, OtherCountry, (
                            SELECT
                                    Name,
                                    toLabel (hed__Application_Status__c) Application_Status__Label,
                                    TB_x_Campus_PL__c,
                                    TB_x_Faculty_PL__c,
                                    toLabel (TB_Level_of_Study__c) Level__Label,
                                    toLabel (TB_Mode_of_Study__c) Mode__Label,
                                    TB_x_Course_Speciality_Path__c,
                                    hed__Term__r.Name,
                                    hed__Application_Date__c,
                                    TB_Last_Status_Change_Date_Time__c,
                                    TB_Archived__c
                            FROM hed__Applications_Applicant__r
                            ORDER BY hed__Application_Date__c DESC
                    ), (
                            SELECT
                                    toLabel(DT_Level_Of_Studies__c) LevelOfStudies__Label,
                                    toLabel(DT_Mode_Of_Studies__c) ModeOfStudies__Label,
                                    DT_Campus__c,
                                    DT_Department__c,
                                    DT_Album_Number__c,
                                    hed__Start_Date__c,
                                    hed__End_Date__c,
                                    DT_Status_by_VDO__c,
                                    TB_Semester__c,
                                    TB_Enrolled_for_Semester__c
                            FROM hed__Program_Enrollments__r
                            ORDER BY hed__Start_Date__c DESC
                    ), (
                            SELECT
                                    CaseNumber,
                                    Status,
                                    Subject,
                                    TB_Category__c,
                                    DT_Subcategory__c,
                                    RecordType.Name,
                                    Owner.Name,
                                    TB_Last_Activity_Date__c
                            FROM Cases
                            ORDER BY CreatedDate DESC
                    )
                    FROM Contact
                    WHERE IndividualId = :[SELECT IndividualId FROM Contact WHERE Id = :contactId].IndividualId
            ];
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public class ContactWrapper {
        @AuraEnabled public Contact con { get; set; }
        @AuraEnabled public List<hed__Application__c> app { get; set; }
        @AuraEnabled public List<hed__Program_Enrollment__c> enroll { get; set; }
        @AuraEnabled public List<Case> cases { get; set; }

        public ContactWrapper(Contact contact) {
            this.con = contact;
            this.app = contact.hed__Applications_Applicant__r;
            this.enroll = contact.hed__Program_Enrollments__r;
            this.cases = contact.cases;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<hed__Program_Enrollment__c> getEnrollmentData(String recordId, String objectApiName, String lookupContactApiName) {
        try {
            Id lookupId;
            if (objectApiName == CONTACT_API_NAME) {
                lookupId = recordId;
            } else if (CONTACT_LOOKUP_API_NAMES.get(objectApiName) != null) {
                lookupContactApiName = CONTACT_LOOKUP_API_NAMES.get(objectApiName);
                List<SObject> records = Database.query('SELECT ' + lookupContactApiName + ' FROM ' + objectApiName + ' WHERE Id =:recordId LIMIT 1');
                if (records.size() > 0) {
                    lookupId = (Id) records[0].get(lookupContactApiName);
                }
            }
            List<Contact> StudentIds = [
                    SELECT Id, IndividualId, RecordType.DeveloperName
                    FROM Contact
                    WHERE (
                            IndividualId = :[SELECT IndividualId FROM Contact WHERE Id = :lookupId].IndividualId
                            AND
                            RecordType.DeveloperName = :CONTACT_STUDENT_API_NAME
                    )
            ];
            if (StudentIds.size() == 0 || StudentIds[0].IndividualId == null) {
                return null;
            } else {
                List<hed__Program_Enrollment__c> enrollments = [
                        SELECT
                                toLabel(DT_Level_Of_Studies__c) LevelOfStudies__Label,
                                toLabel(DT_Mode_Of_Studies__c) ModeOfStudies__Label,
                                DT_Campus__c,
                                DT_Department__c,
                                DT_Album_Number__c,
                                hed__Start_Date__c,
                                hed__End_Date__c,
                                DT_Status_by_VDO__c,
                                TB_Semester__c,
                                TB_Enrolled_for_Semester__c,
                                hed__Contact__c
                        FROM hed__Program_Enrollment__c
                        WHERE hed__Contact__c IN :StudentIds
                        ORDER BY hed__Start_Date__c DESC
                ];
                    return enrollments.size() == 0 ? null : enrollments;
            }
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<DataTableWrapp> getWrapperList(String contactId) {
        List<DataTableWrapp> wrapperList = new List<DataTableWrapp>();
        try {
            for (Contact cont : [
                    SELECT Name,
                            CreatedDate,
                            CreatedBy.Name,
                            TB_Has_Potential_Duplicate__c,
                            TB_Test__c,
                            TB_Active__c,
                            RecordType.DeveloperName
                    FROM Contact
                    WHERE IndividualId = :
                            [
                                    SELECT IndividualId
                                    FROM Contact
                                    WHERE Id = :contactId
                            ].IndividualId
            ]) {
                DataTableWrapp obj = new DataTableWrapp(cont);
                wrapperList.add(obj);
            }
            return wrapperList;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public class DataTableWrapp {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public Datetime createDate { get; set; }
        @AuraEnabled
        public String createBy { get; set; }
        @AuraEnabled
        public Boolean hasDuplicate { get; set; }
        @AuraEnabled
        public Boolean test { get; set; }
        @AuraEnabled
        public Boolean active { get; set; }
        @AuraEnabled
        public String type { get; set; }

        public DataTableWrapp(Contact cont) {
            id = cont.Id;
            name = cont.Name;
            createDate = cont.CreatedDate;
            createBy = cont.CreatedBy.Name;
            hasDuplicate = cont.TB_Has_Potential_Duplicate__c;
            test = cont.TB_Test__c;
            active = cont.TB_Active__c;
            type = cont.RecordType.DeveloperName;
        }
    }
}
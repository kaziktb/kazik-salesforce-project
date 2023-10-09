public with sharing class TB_CT_EmployeeEditForm {
    private static final Id CONTACT_EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();
    private static final String CATEGORY_CV = 'CV';
    private static final String EXISTING_DIDACTIC_STATUS_VALUE = 'Existing_Didactic';
    private static final String CATEGORY_DIPLOMA = 'Diploma';
    private static final String MERGE_TAG_COMMENT_REGEX = '\\{!COMMENT\\}';
    private static final String SEND_FROM_EMAIL = getSendFromEmailCustomSetting();
    private static final Set<String> PERM_SETS_NAMES_ALLOWED_TO_HAVE_STATUS = new Set<String>{'TB_SWPS_Contract_Teachers_Applicant_Didactic', 'TB_SWPS_Contract_Teachers_Coordinator', 'TB_SWPS_Contract_Teachers_Decision_Maker'};
    private static final CheckUniqueness CHECK_UNIQUENESS_CLASS = new CheckUniqueness();

    @AuraEnabled (Cacheable = true)
    public static List<TB_Experience_History_Setting__mdt> fetchDegreeFieldInfos() {
        return [
                SELECT TB_Title_or_Grade__c, TB_Title_Grade_Type__c, TB_Sending_Mode__c, TB_Title_Grade_Year__c,
                        TB_Field_of_Study__c, TB_Field_Discipline_Old_New__c,
                        TB_Field_Discipline_Historical__c,
                        TB_Discipline_Old__c, TB_Discipline_New__c, TB_Subject_for_Title__c,
                        TB_Institution_Title_Grade__c, TB_Country_Title_Grade__c,
                        TB_Subject_Nostrifying__c, TB_Foreign_Grade_Base__c, TB_Institution_Name__c
                FROM TB_Experience_History_Setting__mdt
        ];
    }

    @AuraEnabled
    public static List<ContentVersionWrapper> fetchTitles(Id contactId) {
        List<ContentVersionWrapper> wrappers = new List<ContentVersionWrapper>();
        if (String.isBlank(contactId)) {
            return wrappers;
        }
        List<TB_Experience_History__c> experienceHistories = [
                SELECT TB_Title_or_Grade__c, TB_Title_Grade_Type__c, TB_Sending_Mode__c, TB_Title_Grade_Year__c,
                        TB_Field_of_Study__c, TB_Field_Discipline_Old_New__c,
                        TB_Field_Discipline_Historical__c, TB_Field__c,
                        TB_Discipline_Old__c, TB_Discipline_New__c, TB_Subject_for_Title__c,
                        TB_Institution_Title_Grade__c, TB_Country_Title_Grade__c,
                        TB_Subject_Nostrifying__c, TB_Foreign_Grade_Base__c, TB_Institution_Name__c
                FROM TB_Experience_History__c
                WHERE TB_Applicant__c = :contactId
                ORDER BY TB_Title_Grade_Year__c DESC
        ];
        if (experienceHistories.size() > 0) {
            Set<String> experienceHistoryIds = TB_SObjectUtils.createIdFieldValueSet(experienceHistories, TB_Experience_History__c.Id);
            List<ContentDocumentLink> contentLinks = getContentLinks(experienceHistoryIds);
            Set<String> contentDocIds = TB_SObjectUtils.createIdFieldValueSet(contentLinks, ContentDocumentLink.ContentDocumentId);
            List<ContentVersion> contentVersions = getContentVersions(CATEGORY_DIPLOMA, contentDocIds);
            Map<Id, List<ContentVersion>> experienceHistoryIdToContentVersions = experienceHistoryIdToContentVersions(
                    contentLinks, contentVersions
            );
            for (TB_Experience_History__c history : experienceHistories) {
                List<ContentVersion> linkedContentVersions = experienceHistoryIdToContentVersions?.get(history.Id) == null
                        ? new List<ContentVersion>()
                        : experienceHistoryIdToContentVersions.get(history.Id);
                wrappers.add(new ContentVersionWrapper(
                        history, linkedContentVersions
                ));
            }
        }
        return wrappers;
    }

    private static Map<Id, List<ContentVersion>> experienceHistoryIdToContentVersions(List<ContentDocumentLink> contentLinks, List<ContentVersion> contentVersions) {
        Map<Id, List<ContentVersion>> result = new Map<Id, List<ContentVersion>>();
        Map<String, String> documentIdToHistoryId = TB_SObjectUtils.createFieldToFieldStringMap(contentLinks, ContentDocumentLink.ContentDocumentId, ContentDocumentLink.LinkedEntityId);
        for (ContentVersion version : contentVersions) {
            Id experienceHistoryId = documentIdToHistoryId?.get(version.ContentDocumentId);
            if (!String.isBlank(experienceHistoryId)) {
                if (result?.get(experienceHistoryId) == null) {
                    result.put(experienceHistoryId, new List<ContentVersion>());
                }
                result.get(experienceHistoryId).add(version);
            }
        }
        return result;
    }

    @AuraEnabled (Cacheable = true)
    public static List<Contact> fetchContacts() {
        return [
                SELECT LastName,
                        FirstName,
                        hed__WorkPhone__c,
                        hed__AlternateEmail__c,
                        DT_PESEL__c,
                        Salutation,
                        DT_Document_Type__c,
                        DT_Document_Series_and_Number__c,
                        DT_Document_Issuing_Country__c,
                        Birthdate,
                        TB_Country_of_Origin__c,
                        TB_Citizenship__c,
                        DT_Country_of_Birth__c
                        FROM Contact
                WHERE TB_Active__c = TRUE
                AND RecordTypeId =: CONTACT_EMPLOYEE_RECORD_TYPE_ID
                LIMIT 50000
        ];
    }

    @AuraEnabled
    public static TB_App_Tracking__c fetchAppTracking(Id contactId) {
        List<TB_App_Tracking__c> apps = [
                SELECT Id, TB_Employment_Type__c, TB_Process_Status__c
                FROM TB_App_Tracking__c
                WHERE TB_Applicant__c = :contactId
                ORDER BY CreatedDate DESC
        ];
        return apps.size() > 0 ? apps[0] : null;
    }

    @AuraEnabled
    public static List<TB_Experience_History__c> fetchExperienceHistory(Id recordId) {
        return [
                SELECT
                TB_Applicant__r.Name, 
                TB_Title_or_Grade__c, 
                TB_Title_Grade_Year__c, 
                TB_Field_of_Study__c, 
                TB_Field__c,
                TB_Discipline_New__c,
                TB_Discipline_Old__c
                FROM TB_Experience_History__c
                WHERE Id = :recordId
        ];
    }

    @AuraEnabled
    public static ContentVersionWrapper fetchLatestContVerBasedOnCategory(Id linkedEntityId, String category) {
        List<ContentDocumentLink> contentLinks = getContentLinks(new Set<String>{
                linkedEntityId
        });
        Set<String> contentDocIds = TB_SObjectUtils.createIdFieldValueSet(contentLinks, ContentDocumentLink.ContentDocumentId);
        List<ContentVersion> contentVersions = getContentVersions(category, contentDocIds);
        ContentVersionWrapper wrapper = new ContentVersionWrapper();
        wrapper.hasCV = category == CATEGORY_CV && (contentVersions.size() > 0);
        wrapper.hasDiploma = category == CATEGORY_DIPLOMA && (contentVersions.size() > 0);
        wrapper.contentVersion = (wrapper.hasCV || wrapper.hasDiploma)
                ? contentVersions[0]
                : null;
        return wrapper;
    }

    @AuraEnabled
    public static void sendCommentEmailToTeacher(String comment, Id contactId) {
        try {
            TB_GenericSendEmailWithoutContact.WrapperClass wrapper = new TB_GenericSendEmailWithoutContact.WrapperClass();
            Contact contact = [
                    SELECT hed__AlternateEmail__c, 
                        TB_User__c,
                        TB_x_Existing_Didactic__c
                    FROM Contact
                    WHERE Id = :contactId
            ][0];

            String templateDevName, emailLanguage;
            User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :contact.TB_User__c];
            emailLanguage = u.LanguageLocaleKey;
            
            templateDevName = emailLanguage?.toLowerCase() == 'pl'
                    ? 'TB_Comment_From_Edit_Form_PL'
                    : 'TB_Comment_From_Edit_Form_ENG';

            EmailTemplate template = [
                    SELECT Id, HtmlValue, Body, Subject
                    FROM EmailTemplate
                    WHERE DeveloperName = :templateDevName
            ];
            String[] htmlBodyParts = template.HtmlValue.split(MERGE_TAG_COMMENT_REGEX);
            String[] plainTextBodyParts = template.Body.split(MERGE_TAG_COMMENT_REGEX);
            wrapper.toAddress = contact?.hed__AlternateEmail__c;
            wrapper.htmlBody = String.join(htmlBodyParts, comment);
            wrapper.plainTextBody = String.join(plainTextBodyParts, comment);
            wrapper.subject = template.Subject;
            wrapper.targetObjectId = contact?.Id;
            wrapper.sendFromEmail = SEND_FROM_EMAIL;
            TB_GenericSendEmailWithoutContact.sendEmail(new List<TB_GenericSendEmailWithoutContact.WrapperClass>{
                    wrapper
            });
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(
                    e.getMessage(), TB_CT_EmployeeEditForm.class.getName(),
                    e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
        }
    }

    @AuraEnabled
    public static void sendCommentEmailToResponsibles(String comment, Id contactId) {
        try {
            TB_App_Tracking__c app = [
                               SELECT
                               TB_Primary_Responsible_Email__c,
                               TB_University_Work_Department_Email__c,
                               TB_CT_Responsible_Person_Language__c
                               FROM TB_App_Tracking__c
                               WHERE TB_Applicant__c = :contactId
                               ];            
            String templateDevName = app.TB_CT_Responsible_Person_Language__c == 'pl'
                                   ? 'TB_Comment_From_Edit_Form_PL'
                                    : 'TB_Comment_From_Edit_Form_ENG';
            EmailTemplate template = [
                    SELECT Id, HtmlValue, Body, Subject
                    FROM EmailTemplate
                    WHERE DeveloperName = :templateDevName
            ];
            String[] htmlBodyParts = template.HtmlValue.split(MERGE_TAG_COMMENT_REGEX);
            String[] plainTextBodyParts = template.Body.split(MERGE_TAG_COMMENT_REGEX);

            List<String> emailDestinations = new List<String>();
            if (!String.isBlank(app?.TB_Primary_Responsible_Email__c)) {
                emailDestinations.add(app?.TB_Primary_Responsible_Email__c);
            }
            if (!String.isBlank(app?.TB_University_Work_Department_Email__c)) {
                emailDestinations.add(app?.TB_University_Work_Department_Email__c);
            }
            List<TB_GenericSendEmailWithoutContact.WrapperClass> wrappers = new List<TB_GenericSendEmailWithoutContact.WrapperClass>();
            for (String email : emailDestinations) {
                TB_GenericSendEmailWithoutContact.WrapperClass wrapper = new TB_GenericSendEmailWithoutContact.WrapperClass();
                wrapper.toAddress = email;
                wrapper.htmlBody = String.join(htmlBodyParts, comment);
                wrapper.plainTextBody = String.join(plainTextBodyParts, comment);
                wrapper.subject = template.Subject;
                wrapper.whatId = app?.Id;
                wrapper.sendFromEmail = SEND_FROM_EMAIL;
                wrappers.add(wrapper);
            }
            TB_GenericSendEmailWithoutContact.sendEmail(wrappers);
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(
                    e.getMessage(), TB_CT_EmployeeEditForm.class.getName(),
                    e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
        }
    }

    @AuraEnabled
    public static void updateAppTrackingStatus(Id contactId, String statusValue) {
        try {
            TB_App_Tracking__c app = [
                    SELECT TB_Process_Status__c
                    FROM TB_App_Tracking__c
                    WHERE TB_Applicant__c = :contactId
                    ORDER BY CreatedDate DESC
            ][0];
            app.TB_Process_Status__c = statusValue;
            update app;
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(
                    e.getMessage(), TB_CT_EmployeeEditForm.class.getName(),
                    e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
        }
    }

    @AuraEnabled (Cacheable = true)
    public static String getAppTrackingStatus(Id contactId) {
        try {
            Set<Id> allowedPermSetsIds = new Map<Id, PermissionSet>([SELECT Id FROM PermissionSet WHERE Name IN :PERM_SETS_NAMES_ALLOWED_TO_HAVE_STATUS]).keySet();

            List<PermissionSetAssignment> userPermSetAssignments = [
                    SELECT Id
                    FROM PermissionSetAssignment
                    WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSetId IN :allowedPermSetsIds
            ];

            if(!userPermSetAssignments.isEmpty()){
                    List<TB_App_Tracking__c> apps = [
                        SELECT TB_Process_Status__c
                        FROM TB_App_Tracking__c
                        WHERE TB_Applicant__c = :contactId
                        ORDER BY CreatedDate DESC
                ];
                if(apps.isEmpty()){
                    return null;
                }else {
                    return apps.get(0).TB_Process_Status__c;
                }
            }else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(
                    e.getMessage(), TB_CT_EmployeeEditForm.class.getName(),
                    e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
        }
    }

    @AuraEnabled
    public static List<Id> fetchMultipleContentVersionIds(Id linkedEntityId, String category) {
        List<ContentVersion> contentVersions = fetchMultipleContentVersions(linkedEntityId, category);
        Set<String> contentVersionIds = TB_SObjectUtils.createIdFieldValueSet(contentVersions, ContentVersion.Id);
        return new List<String>(contentVersionIds);
    }

    @AuraEnabled
    public static List<ContentVersion> fetchMultipleContentVersions(Id linkedEntityId, String category) {
        List<ContentDocumentLink> contentLinks = getContentLinks(new Set<String>{
                linkedEntityId
        });
        Set<String> contentDocIds = TB_SObjectUtils.createIdFieldValueSet(contentLinks, ContentDocumentLink.ContentDocumentId);
        List<ContentVersion> contentVersions = getContentVersions(category, contentDocIds);
        return contentVersions;
    }

    @AuraEnabled (Cacheable = true)
    public static List<ContentVersion> fetchMultipleContentVersionsCacheable(Id linkedEntityId, String category) {
        return fetchMultipleContentVersions(linkedEntityId, category);
    }

    @AuraEnabled
    public static void updateContentVersions(List<ContentVersion> contentVersions) {
        try {
            if (Schema.SObjectType.ContentVersion.fields.Description.isUpdateable()
                    && Schema.SObjectType.ContentVersion.fields.TB_Category__c.isUpdateable()
                    && Schema.SObjectType.ContentVersion.fields.Title.isUpdateable()) {
                update new List<ContentVersion>(contentVersions);
            }
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(
                    e.getMessage(), TB_CT_EmployeeEditForm.class.getName(),
                    e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
        }
    }

    @AuraEnabled
    public static void deleteContentDocuments(List<Id> contentVersionIds) {
        try {
            List<ContentVersion> contentVersions = [
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE Id IN :contentVersionIds
            ];
            Set<String> contentDocIds = TB_SObjectUtils.createIdFieldValueSet(contentVersions, ContentVersion.ContentDocumentId);
            List<UserRecordAccess> deletableRecords = [
                    SELECT RecordId
                    FROM UserRecordAccess
                    WHERE UserId = :UserInfo.getUserId()
                    AND HasDeleteAccess = TRUE
                    AND RecordId IN :contentDocIds
            ];
            List<Id> deletableRecordIds = new List<Id>();
            for (UserRecordAccess deletableRecord : deletableRecords) {
                deletableRecordIds.add(deletableRecord.Id);
            }
            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE Id IN :deletableRecordIds];
            delete documents;
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(
                    e.getMessage(), TB_CT_EmployeeEditForm.class.getName(),
                    e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
        }
    }

    @AuraEnabled
    public static void deleteContentDocumentsWithoutCategory(Id linkedEntityId) {
        List<ContentVersion> contentVersions = fetchAssociatedContentVersions(linkedEntityId);
        List<Id> versionsWithNoCategoryIds = findContentVersionIdsWithoutCategory(contentVersions);
        deleteContentDocuments(versionsWithNoCategoryIds);
    }

    @AuraEnabled
    public static void deleteAssociatedFiles(Id linkedEntityId) {
        List<ContentVersion> versions = fetchAssociatedContentVersions(linkedEntityId);
        List<Id> versionIds = new List<Id>();
        for (ContentVersion version : versions) {
            versionIds.add(version.Id);
        }
        deleteContentDocuments(versionIds);
    }

    @AuraEnabled
    public static List<hed__Affiliation__c> fetchAffiliations(Id contactId) {
        return [
                SELECT TB_Campus__c, TB_Application_Date__c,
                        TB_EmploymentCat__c, TB_Position__c, hed__Role__c,
                        TB_RoleType__c, TB_Location__c,
                        hed__Account__c, hed__Account__r.Name, TB_EmploymentType__c
                FROM hed__Affiliation__c
                WHERE hed__Contact__c = :contactId
                ORDER BY TB_Application_Date__c DESC
        ];
    }

    @AuraEnabled
    public static void updateAffiliations(List<hed__Affiliation__c> affiliationsToUpdate) {
        try {
            if (affiliationsToUpdate.size() > 0) {
                update affiliationsToUpdate;
            }
        } catch(Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(
                    e.getMessage(), TB_CT_EmployeeEditForm.class.getName(),
                    e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
        }
    }

    @AuraEnabled (Cacheable = true)
    public static Boolean hasAppTracking(Id contactId) {
        return [
                SELECT Id
                FROM TB_App_Tracking__c
                WHERE TB_Applicant__c = :contactId
        ].size() > 0;
    }

    @AuraEnabled (Cacheable = true)
    public static ContactWrapper getContact(Id contactId) {
        Contact c = [
                SELECT TB_Title_Grade__c, FirstName, LastName, Email, Phone, MiddleName, TB_x_Existing_Didactic__c
                FROM Contact
                WHERE Id = :contactId
        ];
        String status;
        if(!c.TB_x_Existing_Didactic__c){
            TB_App_Tracking__c app = [
                    SELECT TB_Process_Status__c
                    FROM TB_App_Tracking__c
                    WHERE TB_Applicant__c = :contactId
            ];
            status = app.TB_Process_Status__c;
        } else {
            status = EXISTING_DIDACTIC_STATUS_VALUE;
        }
        return new ContactWrapper(
                c.FirstName,
                c.LastName,
                c.TB_Title_Grade__c,
                status,
                c.Email,
                c.Phone,
                c.MiddleName,
                c.TB_x_Existing_Didactic__c
        );
    }

    @AuraEnabled
    public static void deleteExperienceHistoryRecord(Id recordId) {
        ExperienceHistoryWithoutSharing innerClass = new ExperienceHistoryWithoutSharing();
        innerClass.removeExperienceHistoryRecord(recordId);
    }

    @AuraEnabled
    public static Boolean isPeselUnique(Id contactId, String pesel) {
        Set<Id> idsWithPesel = CHECK_UNIQUENESS_CLASS.getPeselSet(pesel);
        return idsWithPesel.size() == 0 || (idsWithPesel.size() == 1 && idsWithPesel.contains(contactId));
    }

    // docNumber = DT_Document_Issuing_Country__c + DT_Document_Series_and_Number__c
    @AuraEnabled
    public static Boolean isDocumentUnique(Id contactId, String docNumber) {
        docNumber = prepareDocumentNumber(docNumber);
        Set<Id> idsWithDocNumber = CHECK_UNIQUENESS_CLASS.getDocumentsSet(docNumber);
        return idsWithDocNumber.size() == 0 || (idsWithDocNumber.size() == 1 && idsWithDocNumber.contains(contactId));
    }

    @AuraEnabled
    public static Boolean isHEDidactic(Id contactId) {
        return [SELECT TB_Didactic_Applicant_HE__c FROM Contact WHERE Id =: contactId].TB_Didactic_Applicant_HE__c;
    }

    private static String prepareDocumentNumber(String docNumber) {
        return docNumber.deleteWhitespace().replace('-', '').replace(':', '').toUpperCase();
    }

    private static List<ContentVersion> fetchAssociatedContentVersions(Id linkedEntityId) {
        List<ContentDocumentLink> contentLinks = getContentLinks(new Set<String>{
                linkedEntityId
        });
        Set<String> contentDocIds = TB_SObjectUtils.createIdFieldValueSet(contentLinks, ContentDocumentLink.ContentDocumentId);
        List<ContentVersion> contentVersions = getContentVersions(contentDocIds);
        return contentVersions;
    }

    private static List<Id> findContentVersionIdsWithoutCategory(List<ContentVersion> contentVersions) {
        List<Id> versionIdsWithNoCategory = new List<Id>();
        for (ContentVersion version : contentVersions) {
            if (String.isBlank(version.TB_Category__c)) {
                versionIdsWithNoCategory.add(version.Id);
            }
        }
        return versionIdsWithNoCategory;
    }

    private static List<ContentVersion> getContentVersions(String category, Set<String> contentDocIds) {
        return [
                SELECT Id, Title, Description, TB_Category__c, ContentDocumentId,
                        VersionData, CreatedDate,  FileExtension, ContentSize
                FROM ContentVersion
                WHERE TB_Category__c = :category AND ContentDocumentId IN :contentDocIds
                ORDER BY CreatedDate DESC
        ];
    }

    private static List<ContentVersion> getContentVersions(Set<String> contentDocIds) {
        return [
                SELECT Id, Title, Description, TB_Category__c, ContentDocumentId, VersionData
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocIds
                ORDER BY CreatedDate DESC
        ];
    }

    private static List<ContentDocumentLink> getContentLinks(Set<String> linkedEntityIds) {
        List<ContentDocumentLink> contentLinks = [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :linkedEntityIds
                ORDER BY SystemModstamp DESC
                LIMIT 1000
        ];
        return contentLinks;
    }

    private static String getSendFromEmailCustomSetting(){
        TB_CT_Contract_Teachers_Email__c cs = TB_CT_Contract_Teachers_Email__c.getInstance();
        return cs.TB_CT_Email__c;
    }

    public class ContactWrapper {
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String title;
        @AuraEnabled public String status;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String middleName;
        @AuraEnabled public Boolean xExistingDidactic;

        public ContactWrapper(String firstName, String lastName,
                String title, String status, String email, String phone, String middleName, Boolean xExistingDidactic) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.title = title;
            this.status = status;
            this.email = email;
            this.phone = phone;
            this.middleName = middleName;
            this.xExistingDidactic = xExistingDidactic;
        }
    }

    public class ContentVersionWrapper {
        @AuraEnabled public Boolean hasCV;
        @AuraEnabled public Boolean hasDiploma;
        @AuraEnabled public ContentVersion contentVersion;
        @AuraEnabled public List<ContentVersion> contentVersions;
        @AuraEnabled public TB_Experience_History__c experienceHistory;

        public ContentVersionWrapper() {
        }

        public ContentVersionWrapper(TB_Experience_History__c experienceHistory, List<ContentVersion> contentVersions) {
            this.experienceHistory = experienceHistory;
            this.contentVersions = contentVersions;
        }

        public ContentVersionWrapper(TB_Experience_History__c experienceHistory, Boolean hasDiploma) {
            this.experienceHistory = experienceHistory;
            this.hasDiploma = hasDiploma;
        }
    }

    private without sharing class ExperienceHistoryWithoutSharing {
        public void removeExperienceHistoryRecord(Id recordId) {
            delete [SELECT Id FROM TB_Experience_History__c WHERE Id = :recordId];
        }
    }

    private without sharing class CheckUniqueness {
        public Set<Id> getPeselSet(String pesel) {
            return new Map<Id, Contact>([SELECT Id FROM Contact WHERE RecordTypeId =: CONTACT_EMPLOYEE_RECORD_TYPE_ID AND DT_PESEL__c =: pesel]).keySet();
        }

        public Set<Id> getDocumentsSet(String docNumber) {
            return new Map<Id, Contact>([SELECT Id FROM Contact WHERE RecordTypeId =: CONTACT_EMPLOYEE_RECORD_TYPE_ID AND TB_x_Document_Search__c =: docNumber]).keySet();
        }
    }
}
public without sharing class TB_vu_StudentOrganizationDetails {
    private static final String EMPTY_VALUE_PL = 'Brak';
    private static final String EMPTY_VALUE_EN = 'Empty';
    private static final String PENDING_APPROVAL_STATUS = 'Pending_Approval';

    @AuraEnabled
    public static StudentOrganizationDetailsWrapper getOrganizationDetails(String recordId, String language) {
        String emptyValue = language == 'PL' ? EMPTY_VALUE_PL : EMPTY_VALUE_EN;
        StudentOrganizationDetailsWrapper toReturnWrapper = new StudentOrganizationDetailsWrapper();
        try {
            Account toReturn = [
                SELECT
                    TB_Account_Name_PL__c,
                    TB_Account_Name_Short_PL__c,
                    TB_Account_Name_EN__c,
                    TB_Account_Name_Short_EN__c,
                    toLabel(TB_Organisation_Type__c),
                    Parent.TB_Account_Name_PL__c,
                    Parent.TB_Account_Name_EN__c,
                    hed__Primary_Contact__r.Name,
                    hed__Primary_Contact__c,
                    TB_Supervisor__r.Name,
                    TB_Start_Date__c,
                    TB_Description_PL__c,
                    TB_Description_EN__c,
                    hed__Primary_Contact__r.TB_User__c,
                    TB_Status__c,
                    TB_Knowledge_Base_Link__c
                FROM Account
                WHERE Id = :recordId
            ];

            toReturnWrapper.Id = toReturn.Id;
            toReturnWrapper.IsChairmanLogged = toReturn.hed__Primary_Contact__r.TB_User__c == UserInfo.getUserId();
            toReturnWrapper.chairmanId = toReturn.hed__Primary_Contact__c;
            toReturnWrapper.HasAffiliation =
                [
                    SELECT Id
                    FROM hed__Affiliation__c
                    WHERE
                        hed__Account__c = :recordId
                        AND hed__Contact__r.TB_User__c = :UserInfo.getUserId()
                        AND hed__Status__c IN :TB_Constants.NEW_ORGANISATIONS_CURRENT_PENDING
                ]
                .size() > 0;
            toReturnWrapper.PrimaryContactName = String.isBlank(toReturn.hed__Primary_Contact__r.Name)
                ? emptyValue
                : toReturn.hed__Primary_Contact__r.Name;
            toReturnWrapper.SupervisorName = String.isBlank(toReturn.TB_Supervisor__r.Name)
                ? emptyValue
                : toReturn.TB_Supervisor__r.Name;
            toReturnWrapper.Type = String.isBlank(toReturn.TB_Organisation_Type__c)
                ? emptyValue
                : getRidOffUnderscores(toReturn.TB_Organisation_Type__c);
            toReturnWrapper.KnowledgeBaseLink = String.isBlank(toReturn.TB_Knowledge_Base_Link__c)
                ? null
                : toReturn.TB_Knowledge_Base_Link__c;
            toReturnWrapper.StartDate = toReturn.TB_Start_Date__c;
            toReturnWrapper.Status = toReturn.TB_Status__c;
            toReturnWrapper.RulesWrapper = getRulesWrapper(recordId);
            toReturnWrapper.TaskWrapper = toReturn.TB_Status__c == PENDING_APPROVAL_STATUS 
            ? getAssignedTask(recordId) 
            : null;
            
            if (language == 'PL') {
                toReturnWrapper.AccName = String.isBlank(toReturn.TB_Account_Name_PL__c)
                    ? emptyValue
                    : toReturn.TB_Account_Name_PL__c;
                toReturnWrapper.AccShortName = String.isBlank(toReturn.TB_Account_Name_Short_PL__c)
                    ? emptyValue
                    : toReturn.TB_Account_Name_Short_PL__c;
                toReturnWrapper.ParentAccName = String.isBlank(toReturn.Parent.TB_Account_Name_PL__c)
                    ? emptyValue
                    : toReturn.Parent.TB_Account_Name_PL__c;
                toReturnWrapper.Description = String.isBlank(toReturn.TB_Description_PL__c)
                    ? emptyValue
                    : toReturn.TB_Description_PL__c;
            } else if (language == 'EN') {
                toReturnWrapper.AccName = String.isBlank(toReturn.TB_Account_Name_EN__c)
                    ? emptyValue
                    : toReturn.TB_Account_Name_EN__c;
                toReturnWrapper.AccShortName = String.isBlank(toReturn.TB_Account_Name_Short_EN__c)
                    ? emptyValue
                    : toReturn.TB_Account_Name_Short_EN__c;
                toReturnWrapper.ParentAccName = String.isBlank(toReturn.Parent.TB_Account_Name_EN__c)
                    ? emptyValue
                    : toReturn.Parent.TB_Account_Name_EN__c;
                toReturnWrapper.Description = String.isBlank(toReturn.TB_Description_EN__c)
                    ? emptyValue
                    : toReturn.TB_Description_EN__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_StudentOrganizationDetails.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
        return toReturnWrapper;
    }

    @AuraEnabled
    public static List<StudentOrganizationMemberWrapper> getMembers(String recordId, String isChairmanLogged) {
        Boolean chairmanLogged = isChairmanLogged == null ? false : Boolean.valueOf(isChairmanLogged);
        List<String> memberStatuses = chairmanLogged
            ? new List<String>{ 'Current', 'Awaiting', 'Pending_Approval' }
            : new List<String>{ 'Current' };
        List<String> memberRoles = new List<String>{ 'SO_Member', 'SO_Chairman' };
        String statusToPass = null;
        List<StudentOrganizationMemberWrapper> toReturnWrapper = new List<StudentOrganizationMemberWrapper>();

        try {
            List<hed__Affiliation__c> affilationList = [
                SELECT hed__Contact__r.Name, hed__StartDate__c, hed__Status__c
                FROM hed__Affiliation__c
                WHERE hed__Status__c = :memberStatuses AND hed__Account__c = :recordId AND hed__Role__c = :memberRoles
                ORDER BY hed__Role__c, hed__StartDate__c
            ];

            for (hed__Affiliation__c r : affilationList) {
                toReturnWrapper.add(
                    new StudentOrganizationMemberWrapper(
                        r.Id,
                        r.hed__Contact__c,
                        r.hed__Contact__r.Name,
                        r.hed__StartDate__c,
                        getRidOffUnderscores(r.hed__Status__c)
                    )
                );
            }
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_StudentOrganizationDetails.class.getName(),e.getStackTraceString(),'')
            );
        }
        return toReturnWrapper;
    }

    @AuraEnabled
    public static void createAffiliation(String accountId) {
        try {
            Id userContact = [SELECT Id FROM Contact WHERE TB_User__c = :UserInfo.getUserId()].Id;
            insert new hed__Affiliation__c(
                hed__Account__c = accountId,
                hed__Contact__c = userContact,
                hed__Status__c = TB_Constants.AFFILIATION_STATUS_PENDING_APPROVAL,
                hed__StartDate__c = Date.today(),
                hed__Role__c = TB_Constants.AFFILIATION_ROLE_MEMBER
            );
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_StudentOrganizationDetails.class.getName(),e.getStackTraceString(),'')
            );
        }
    }

    @AuraEnabled
    public static void modifyAffiliation(String accountId, String affiliationId, String processType) {
        try {
            hed__Affiliation__c aff;

            if (processType == TB_Constants.ORG_LEAVING_PROCESS_TYPE) {
                aff = [
                    SELECT Id
                    FROM hed__Affiliation__c
                    WHERE
                        hed__Account__c = :accountId
                        AND hed__Contact__r.TB_User__c = :UserInfo.getUserId()
                        AND hed__Status__c IN :TB_Constants.NEW_ORGANISATIONS_CURRENT_PENDING
                ];

                aff.hed__Status__c = TB_Constants.AFFILIATION_STATUS_FORMER;
                aff.hed__EndDate__c = Date.today();
                aff.hed__Role__c = TB_Constants.AFFILIATION_ROLE_MEMBER;
            } else {
                aff = [SELECT Id FROM hed__Affiliation__c WHERE Id = :affiliationId];

                if (processType == TB_Constants.CANDIDATE_APPROVAL_PROCESS_TYPE) {
                    aff.hed__Status__c = TB_Constants.AFFILIATION_STATUS_CURRENT;
                    aff.hed__StartDate__c = Date.today();
                } else {
                    aff.hed__Status__c = TB_Constants.AFFILIATION_STATUS_REJECTED;
                    aff.hed__EndDate__c = Date.today();
                }
            }
            update aff;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_StudentOrganizationDetails.class.getName(),e.getStackTraceString(),'')
            );
        }
    }

    @AuraEnabled
    public static void setUserDecision(String accountId, String contactId, String userId, String decision) {
        try {
            if (userId != UserInfo.getUserId()) {
                throw new AuraHandledException(
                    TB_vu_Utils.registerLog(
                        TB_Constants.USER_UNAUTHORIZED,
                        TB_vu_StudentOrganizationDetails.class.getName(),
                        '',
                        ''
                    )
                );
            }

            hed__Affiliation__c affiliation = [
                SELECT Id
                FROM hed__Affiliation__c
                WHERE
                    hed__Account__c = :accountId
                    AND hed__Contact__c = :contactId
                    AND hed__Contact__r.TB_User__c = :userId
                    AND hed__Role__c = :TB_Constants.AFFILIATION_ROLE_MEMBER
                    AND hed__Status__c = :TB_Constants.AFFILIATION_STATUS_AWAITING
            ];

            if (decision == TB_Constants.DECISION_CONFIRMED) {
                affiliation.hed__Status__c = TB_Constants.AFFILIATION_STATUS_CURRENT;
                affiliation.hed__StartDate__c = Date.today();

                update affiliation;
            }
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_StudentOrganizationDetails.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }

    private static StudentOrganizationTaskWrapper getAssignedTask(String recordId){
        try{
            List<Id> contactsAssignedToUser = new List<Id>();
            for(Contact c : [SELECT Id FROM Contact WHERE TB_User__c =: UserInfo.getUserId()]){
                contactsAssignedToUser.add(c.Id);
            }
            List<Task> assignedTask = [SELECT Id, WhatId, WhoId, Status, TB_Active__c 
                                FROM Task 
                                WHERE Status = 'In Progress' 
                                AND TB_Active__c = true
                                AND WhatId =: recordId
                                AND WhoId =: contactsAssignedToUser
                                LIMIT 1];

            if(assignedTask.size() > 0){
                return new StudentOrganizationTaskWrapper(
                    assignedTask[0].Id,
                    assignedTask[0].WhoId
                );
            }
            return null;

        }catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_StudentOrganizationDetails.class.getName(),e.getStackTraceString(), '')
            );
        }
    }

    private static String getRidOffUnderscores(String text) {
        String toReturn = text;
        if (String.isNotBlank(text) && text.contains('_')) {
            toReturn = text.replaceAll('_', ' ');
        }
        return toReturn;
    }

    private static StudentOrganizationRulesWrapper getRulesWrapper(String accountId) {
        try {
            List<ContentDocumentLink> contentDocumentLink = [
                SELECT
                    ContentDocumentId,
                    LinkedEntityId,
                    ContentDocument.LatestPublishedVersion.TB_Category__c,
                    ContentDocument.LatestPublishedVersion.LastModifiedDate,
                    ContentDocument.FileExtension,
                    ContentDocument.Title
                FROM ContentDocumentLink
                WHERE
                    LinkedEntityId = :accountId
                    AND ContentDocument.LatestPublishedVersion.TB_Category__c = 'Students_Organisation_Regulations'
                ORDER BY ContentDocument.LatestPublishedVersion.LastModifiedDate DESC
                LIMIT 1
            ];

            if (contentDocumentLink.size() > 0) {
                return new StudentOrganizationRulesWrapper(
                    contentDocumentLink[0].ContentDocument.Title,
                    contentDocumentLink[0].ContentDocumentId
                );
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_StudentOrganizationDetails.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
        
    }

    public class StudentOrganizationDetailsWrapper {
        @AuraEnabled
        public Id Id { get; set; }
        @AuraEnabled
        public String AccName { get; set; }
        @AuraEnabled
        public String AccShortName { get; set; }
        @AuraEnabled
        public String ParentAccName { get; set; }
        @AuraEnabled
        public String PrimaryContactName { get; set; }
        @AuraEnabled
        public String chairmanId { get; set; }
        @AuraEnabled
        public String SupervisorName { get; set; }
        @AuraEnabled
        public String Type { get; set; }
        @AuraEnabled
        public Date StartDate { get; set; }
        @AuraEnabled
        public String Description { get; set; }
        @AuraEnabled
        public Boolean IsChairmanLogged { get; set; }
        @AuraEnabled
        public Boolean HasAffiliation { get; set; }
        @AuraEnabled
        public String Status { get; set; }
        @AuraEnabled
        public String KnowledgeBaseLink { get; set; }
        @AuraEnabled
        public StudentOrganizationRulesWrapper RulesWrapper { get; set; }
        @AuraEnabled
        public StudentOrganizationTaskWrapper TaskWrapper { get; set; }
    
    }

    public class StudentOrganizationMemberWrapper {
        @AuraEnabled
        public String RecordId { get; set; }
        @AuraEnabled
        public String ContactId { get; set; }
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public Date StartDate { get; set; }
        @AuraEnabled
        public String Status { get; set; }

        public StudentOrganizationMemberWrapper(
            String recordId,
            String contactId,
            String name,
            Date startDate,
            String status
        ) {
            this.RecordId = recordId;
            this.ContactId = contactId;
            this.Name = name;
            this.StartDate = startDate;
            this.Status = status;
        }
    }

    public class StudentOrganizationRulesWrapper {
        @AuraEnabled
        public String FileName { get; set; }
        @AuraEnabled
        public String Href { get; set; }

        public StudentOrganizationRulesWrapper(String fileName, String documentId) {
            this.FileName = fileName;
            this.Href = TB_Constants.DOWNLOAD_FILE_HREF + documentId;
        }
    }

    public class StudentOrganizationTaskWrapper {
        @AuraEnabled
        public Id TaskId { get; set; }
        @AuraEnabled
        public Id ContactId { get; set; }

        public StudentOrganizationTaskWrapper(String taskId, String contactId) {
            this.TaskId = taskId;
            this.ContactId = contactId;
        }

    }
}
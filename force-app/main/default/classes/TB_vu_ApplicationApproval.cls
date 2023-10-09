public with sharing class TB_vu_ApplicationApproval {
    private static final String TYPE_DECISION = 'Decision';
    private static final String AUTHOR_DECISION = 'Decision_Maker';
    private static final String TYPE_INTERNAL_COMMENT = 'Internal_Comment';
    private static final String RECORD_TYPE_DECISION = 'TB_Decision';
    private static final String RECORD_TYPE_CONVERSATION = 'TB_Conversation';
    private static final String LANG_PL = 'pl';

    private static String getRecordTypeId(String developerName){
        try {
            return Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_ApplicationApproval.class.getName(),e.getStackTraceString(),''));
        }
    }

    @AuraEnabled
    public static String sendOperation(OperationParameters parameters){
        try {
            TB_Operation__c operation = new TB_Operation__c();

            if(parameters.type == TYPE_DECISION){
                operation.TB_Type__c = parameters.type;
                operation.TB_Case__c = parameters.parentCaseId;
                operation.TB_Contact__c = parameters.contactId;
                operation.TB_Decision_Maker__c = parameters.decisionMakerId;
                operation.TB_Author__c = AUTHOR_DECISION;
                operation.TB_Description_Rich_Text__c = parameters.comment;
                operation.TB_Is_Decision__c = true;
                operation.TB_Publish__c = false;
                operation.RecordTypeId = getRecordTypeId(RECORD_TYPE_DECISION);
            }
            else if(parameters.type == TYPE_INTERNAL_COMMENT){
                operation.TB_Case__c = parameters.parentCaseId;
                operation.TB_Contact__c = parameters.contactId;
                operation.TB_Decision_Maker__c = parameters.decisionMakerId;
                operation.TB_Type__c = parameters.type;
                operation.TB_Author__c = AUTHOR_DECISION;
                operation.TB_Description_Rich_Text__c = parameters.comment;
                operation.TB_Publish__c = false;
                operation.RecordTypeId = getRecordTypeId(RECORD_TYPE_CONVERSATION);
            }
    
            return new WithoutSharing().insertOperation(operation).Id;
            
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(), TB_vu_ApplicationApproval.class.getName(),e.getStackTraceString(),''));
        }
    }
    
    @AuraEnabled
    public static CaseWrapper getCaseInfo(Id caseId, Id contactId)
    {
        List<TB_Operation__c> caseOperations = [
                SELECT Id,
                    RecordType.DeveloperName,
                    TB_Type__c,
                    TB_Is_Decision__c,
                    TB_Decision_Maker__c,
                    TB_Initial__c,
                    TB_Awaiting_CSS__c,
                    TB_Contact__c,
                    CreatedDate,
                    TB_Case_Number__c,
                    TB_Album_Number__c,
                    TB_Case_Faculty_With_Attributes_EN__c,
                    TB_Case_Faculty_With_Attributes_PL__c,
                    TB_Case_Level_Of_Study_EN__c,
                    TB_Case_Level_Of_Study_PL__c,
                    TB_Case_Mode_Of_Study_PL__c,
                    TB_Case_Mode_Of_Study_EN__c,
                    TB_Case_Pathway_EN__c,
                    TB_Case_Pathway_PL__c,
                    TB_Case_Semester__c,
                    TB_Case_Study_Field_EN__c,
                    TB_Case_Study_Field_PL__c,
                    TB_Case_Faculty__c,
                    TB_Case_Study_Name_With_Attributes_EN__c,
                    TB_Case_Study_Name_With_Attributes_PL__c,
                    toLabel(TB_Case_Category__c),
                    toLabel(TB_Case_Subcategory__c),
                    TB_Contact_Name__c
                FROM TB_Operation__c
                WHERE TB_Case__c = :caseId
        ];
        CaseWrapper cw = new CaseWrapper();

        Id initialOperationId;
        for(TB_Operation__c op : caseOperations)
        {
            if(op.RecordType.DeveloperName == 'TB_Decision' && op.TB_Type__c == 'Request_For_A_Decision' && !op.TB_Is_Decision__c && op.TB_Decision_Maker__c == contactId)
            {
                cw.isAccessible = true;
            }
            if(op.TB_Initial__c)
            {
                initialOperationId = op.Id;
                cw.contactId = op.TB_Contact__c;
                cw.decisionUnavailable = op.TB_Awaiting_CSS__c && op.TB_Initial__c;
                cw.caseNumber = op.TB_Case_Number__c;
                cw.albumNumber = op.TB_Album_Number__c;
                cw.caseCategory = op.TB_Case_Category__c;
                cw.caseSubcategory = op.TB_Case_Subcategory__c;
                cw.contactName = op.TB_Contact_Name__c;
                cw.faculty = op.TB_Case_Faculty__c;
                cw.facultyWithAttributes = UserInfo.getLanguage() == LANG_PL ? op.TB_Case_Faculty_With_Attributes_PL__c : op.TB_Case_Faculty_With_Attributes_EN__c;
                cw.specialty = UserInfo.getLanguage() == LANG_PL ? op.TB_Case_Study_Field_PL__c : op.TB_Case_Study_Field_EN__c;
                cw.pathway = UserInfo.getLanguage() == LANG_PL ? op.TB_Case_Pathway_PL__c : op.TB_Case_Pathway_EN__c;
                cw.modeOfStudy = UserInfo.getLanguage() == LANG_PL ? op.TB_Case_Mode_Of_Study_PL__c : op.TB_Case_Mode_Of_Study_EN__c;
                cw.levelOfStudy = UserInfo.getLanguage() == LANG_PL ? op.TB_Case_Level_Of_Study_PL__c : op.TB_Case_Level_Of_Study_EN__c;
                cw.semester = op.TB_Case_Semester__c;
                cw.caseCreatedDate = formatDate(op.CreatedDate);
            }
        }
        if(initialOperationId != null)
        {
            List<ContentDocumentLink> links =
            [
                    SELECT ContentDocument.LatestPublishedVersionId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :initialOperationId
                    AND ContentDocument.LatestPublishedVersion.TB_Category__c = 'Student_Application'
                    ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate DESC
                    LIMIT 1
            ];
            if(!links.isEmpty())
            {
                cw.pdfContentVersionId = links[0].ContentDocument.LatestPublishedVersionId;
            }
        }
        return cw;
    }

    private static String formatDate(DateTime d) {
        String month = d.month() < 10 ? '0' + String.valueOf(d.month()) : String.valueOf(d.month());
        return d.day() + '.' + month + '.' + d.year();
    }
    
    public class CaseWrapper
    {
        @AuraEnabled
        public Boolean isAccessible = false;
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public Id pdfContentVersionId;
        @AuraEnabled
        public Boolean decisionUnavailable;
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String albumNumber;
        @AuraEnabled
        public String caseCategory;
        @AuraEnabled
        public String caseSubcategory;
        @AuraEnabled
        public String faculty;
        @AuraEnabled
        public String facultyWithAttributes;
        @AuraEnabled
        public String specialty;
        @AuraEnabled
        public String pathway;
        @AuraEnabled
        public String modeOfStudy;
        @AuraEnabled
        public String levelOfStudy;
        @AuraEnabled
        public Decimal semester;
        @AuraEnabled
        public String caseCreatedDate;
    }

    public class OperationParameters{
        @AuraEnabled
        public String parentCaseId { get; set; }
        @AuraEnabled
        public String contactId { get; set; }
        @AuraEnabled
        public String decisionMakerId { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String comment { get; set; }
    }
    
    private without sharing class WithoutSharing
    {
        TB_Operation__c insertOperation(TB_Operation__c operation)
        {
            insert operation;
            return operation;
        }
    }
}
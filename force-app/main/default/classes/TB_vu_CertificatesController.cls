public with sharing class TB_vu_CertificatesController {
    private static final String POLISH_LANGUAGE_CODE = 'PL';
    private static final String CERTIFICATE_RECORD_TYPE = 'TB_Student_Certificate_HE';
    private static final String CONTENT_VERSION_CATEGORY = 'Student_Certificate';
    private static final String NEW_CASE_STATUS = 'New';
    private static final String CLOSED_CASE_STATUS = 'Closed';
    private static final String VU_CASE_ORIGIN = 'Virtual_University';
    private static final String REQUEST_FOR_CERTIFIACTE_CASE_CREATION_METHOD = 'Request_For_Certificate';
    private static final String AUTOMATICALLY_GENERATED_CASE_CREATION_METHOD = 'Automatically_Generated';
    private static final String TRADITIONAL_POST_CASE_METHOD_OF_DELIVERY = 'Traditional_Post';
    private static final String STUDET_AUTHOR = 'Student';
    private static final String EXTERNAL_COMMENT_TYPE = 'External_Comment';
    private static final String CONVERSATION_OPERATION_RT = 'TB_Conversation';
    private static final String STUDENT_CERTIFICATE_CONTENT_VERSION_CATEGORY = 'Student_Certificate';
    private static final Map<String,String> SUBCATEGORIES_FOR_CREATION_METHODS = new Map<String,String>{
        'Request_For_Certificate' => 'Created_By_CSS',
        'Automatically_Generated' => 'Automatically_Generated'
    };
    private static final List<String> PROGRAM_ENROLMENT_LEVEL_OF_STUDIES = TB_vu_Constants.PROGRAM_ENROLMENT_LEVEL_OF_STUDIES;

    public class CaseWrapper {
        @AuraEnabled public Id caseId;
        @AuraEnabled public String contactName;
        @AuraEnabled public String subject;
        @AuraEnabled public String type;
        @AuraEnabled public String subtype;
        @AuraEnabled public String programEnrollment;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Datetime lastActivityDate;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String priorStatus;
        @AuraEnabled public String description;
        @AuraEnabled public String descriptionPlain;
        @AuraEnabled public String certificateFileHref;
        @AuraEnabled public Boolean showReplyButton;
        @AuraEnabled public Boolean showCancelButton;
        @AuraEnabled public Boolean showDownloadButton;
    }

    public class CommentWrapper {
        @AuraEnabled public TB_Operation__c comment;
        @AuraEnabled public String authorFullName;
        @AuraEnabled public String authorIndex;
        @AuraEnabled public List<ContentVersion> commentContentVersions;

        public CommentWrapper(TB_Operation__c comment, String authorFullName, String authorIndex, List<ContentVersion> commentContentVersions) {
            this.comment = comment;
            this.authorFullName = authorFullName;
            this.authorIndex = authorIndex;
            this.commentContentVersions = commentContentVersions;
        }
    }

    public class CertificateParameters{
        @AuraEnabled 
        public String creationMethod { get; set; }
        @AuraEnabled 
        public String studyNameId { get; set; }
        @AuraEnabled 
        public String contactId { get; set; }
        @AuraEnabled 
        public String category { get; set; }
        @AuraEnabled
        public String subject { get; set; }
        @AuraEnabled 
        public String description { get; set; }
        @AuraEnabled 
        public String documentName { get; set; }
        @AuraEnabled 
        public String methodOfDelivery { get; set; }
        @AuraEnabled 
        public DeliveryDataWrapper deliveryData { get; set; }
    }

    public class DeliveryDataWrapper{
        @AuraEnabled 
        public String addressName { get; set; }
        @AuraEnabled 
        public String street { get; set; }
        @AuraEnabled 
        public String city { get; set; }
        @AuraEnabled 
        public String postalCode { get; set; }
        @AuraEnabled 
        public String country { get; set; }
        @AuraEnabled 
        public String mobile { get; set; }
    }

    public class StudyNameWrapper{
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String studyName { get; set; }
        @AuraEnabled
        public String status { get; set; }


        public StudyNameWrapper(String id, String studyName, String status) {
            this.id = id;
            this.studyName = studyName;
            this.status = status;
        }
    }

    @AuraEnabled
    public static List<Id> createCertificate(CertificateParameters certificateParameters){
        try {
            Case newCertificate = new Case(
                RecordTypeId = TB_vu_CasesController.getRecordTypeId(CERTIFICATE_RECORD_TYPE),
                Origin = VU_CASE_ORIGIN,
                ContactId = certificateParameters.contactId,
                TB_Category__c = certificateParameters.category,
                TB_Subcategory__c = SUBCATEGORIES_FOR_CREATION_METHODS.get(certificateParameters.creationMethod),
                TB_Program_Enrollment__c = certificateParameters.studyNameId,
                TB_Creation_Method__c = certificateParameters.creationMethod,
                TB_Document_Template_Name__c = certificateParameters.documentName,
                TB_Method_Of_Delivery__c = certificateParameters.methodOfDelivery,
                Subject = certificateParameters.subject
            );

            List<hed__Program_Enrollment__c> relatedProgramEnrollment = [
                SELECT 
                    Id, 
                    TB_Study_Name_With_Attributes_PL__c, 
                    TB_Study_Name_With_Attributes_EN__c 
                FROM hed__Program_Enrollment__c 
                WHERE Id = :certificateParameters.studyNameId];

            TB_Operation__c newOperation = new TB_Operation__c(
                TB_Author__c = STUDET_AUTHOR,
                TB_Description_Rich_Text__c = certificateParameters.description,
                TB_Contact__c = certificateParameters.contactId,
                TB_Publish__c = true,
                RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(CONVERSATION_OPERATION_RT).getRecordTypeId(),
                TB_Type__c = EXTERNAL_COMMENT_TYPE,
                TB_Initial__c = true,
                TB_Case_Study_Name_With_Attributes_PL__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].TB_Study_Name_With_Attributes_PL__c,
                TB_Case_Study_Name_With_Attributes_EN__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].TB_Study_Name_With_Attributes_EN__c
            );

            if(certificateParameters.creationMethod == AUTOMATICALLY_GENERATED_CASE_CREATION_METHOD){
                newCertificate.Status = CLOSED_CASE_STATUS;
                
                insert newCertificate;
                newOperation.TB_Case__c = newCertificate.Id;
                insert newOperation;
                return new List<Id>{
                    newCertificate.Id
                };
            }

            newCertificate.Status = NEW_CASE_STATUS;
            newCertificate.TB_Description_Rich_Text__c = certificateParameters.description;
            if(certificateParameters.methodOfDelivery == TRADITIONAL_POST_CASE_METHOD_OF_DELIVERY){
                newCertificate.TB_Shipping_Address_Name__c = certificateParameters.deliveryData.addressName;
                newCertificate.TB_Shipping__Street__s = certificateParameters.deliveryData.street;
                newCertificate.TB_Shipping__City__s = certificateParameters.deliveryData.city;
                newCertificate.TB_Shipping__PostalCode__s = certificateParameters.deliveryData.postalCode;
                newCertificate.TB_Shipping__CountryCode__s = certificateParameters.deliveryData.country;
                newCertificate.TB_Shipping_Mobile__c = certificateParameters.deliveryData.mobile;
            }

            insert newCertificate;
            newOperation.TB_Case__c = newCertificate.Id;
            insert newOperation;

            return new List<Id>{
                newCertificate.Id,
                newOperation.Id
            };
            
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CertificatesController.class.getName(),e.getStackTraceString(),'')
            );
        }
    }

    @AuraEnabled
    public static Id generatePdf(Id caseId)
    {
        try
        {
            Case processedCase = [
                    SELECT Id, CaseNumber, TB_Document_Template_Name__c, TB_x_Contact_Name__c,
                           TB_Document_Additional_Comment__c,TB_Qualified_Signer__r.TB_x_Contact_Name__c
                    FROM Case
                    WHERE Id = :caseId
            ];
            return generatePDF(processedCase);
        }
        catch(Exception e)
        {
            throw new AuraHandledException(
                    TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CertificatesController.class.getName(),e.getStackTraceString(),caseId)
            );
        }
    }

    private static Id generatePDF(Case caseToProcess){
        TB_vu_PDFGeneratorController.PDFQueueableParams params = new TB_vu_PDFGeneratorController.PDFQueueableParams();
        params.templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(caseToProcess.TB_Document_Template_Name__c);
        params.networkId = Network.getNetworkId();
        params.objects = new List<TB_vu_PDFGeneratorController.PDFObjectWrapper>();
        TB_vu_PDFGeneratorController.PDFObjectWrapper wrapper = new TB_vu_PDFGeneratorController.PDFObjectWrapper();
        wrapper.recordId = caseToProcess.Id;
        wrapper.relatedRecordIds.add(caseToProcess.Id);
        wrapper.linkToIds.add(caseToProcess.Id);
        wrapper.category = STUDENT_CERTIFICATE_CONTENT_VERSION_CATEGORY;
        wrapper.fileName = Label.TB_Certificate_PDF_Name + ' ' + caseToProcess.CaseNumber + ' - ' + caseToProcess.TB_x_Contact_Name__c;
        wrapper.replacements = new Map<String,String>();
        wrapper.replacements.put('CreationDate',Date.today().format());
        wrapper.replacements.put('AdditionalComment',String.isBlank(caseToProcess.TB_Document_Additional_Comment__c) ? '' : caseToProcess.TB_Document_Additional_Comment__c);
        wrapper.replacements.put('Signer',String.isBlank(caseToProcess.TB_Qualified_Signer__r.TB_x_Contact_Name__c) ? '.............................' : caseToProcess.TB_Qualified_Signer__r.TB_x_Contact_Name__c);
        params.objects.add(wrapper);
        return new TB_vu_PDFGeneratorController.PDFQueueable(params).executeSync();
    }

    @AuraEnabled
    public static List<StudyNameWrapper> getStudyNames(String language, String contactId){
        try {
            Integer daysBeforeEnrollmentStartDay = (Integer)TB_SS_Program_Enrollment_Setting__c.getOrgDefaults().TB_Days_Before_Enrollment_Start_Day__c;
            List<StudyNameWrapper> toReturn = new List<StudyNameWrapper>();
            Map<String, hed__Program_Enrollment__c> withoutRoundNumberDuplicates = new Map<String, hed__Program_Enrollment__c>();
            for(hed__Program_Enrollment__c pe : [SELECT Id, TB_Study_Name_With_Attributes_EN__c,
                    TB_Study_Name_With_Attributes_PL__c, hed__Start_Date__c, hed__End_Date__c,
                    DT_VDO_Round_ID__c, hed__Enrollment_Status__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c =: contactId AND
                DT_Level_Of_Studies__c IN: PROGRAM_ENROLMENT_LEVEL_OF_STUDIES AND 
                hed__Start_Date__c <=:  Date.today() + daysBeforeEnrollmentStartDay]){
                    if(pe.hed__End_Date__c == null || pe.hed__Start_Date__c <= pe.hed__End_Date__c){
                        if(withoutRoundNumberDuplicates.get(pe.DT_VDO_Round_ID__c) == null){
                            withoutRoundNumberDuplicates.put(pe.DT_VDO_Round_ID__c, pe);
                        }
                        else if(withoutRoundNumberDuplicates.get(pe.DT_VDO_Round_ID__c).hed__Start_Date__c < pe.hed__Start_Date__c){
                            withoutRoundNumberDuplicates.put(pe.DT_VDO_Round_ID__c, pe);
                        }
                    }
            }

            for(hed__Program_Enrollment__c pe : withoutRoundNumberDuplicates.values()){
                String facultyToAdd = language == POLISH_LANGUAGE_CODE ? pe.TB_Study_Name_With_Attributes_PL__c : pe.TB_Study_Name_With_Attributes_EN__c;
                toReturn.add(new StudyNameWrapper(
                    pe.Id,
                    facultyToAdd,
                    pe.hed__Enrollment_Status__c
                ));
            }

            return toReturn;

        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CertificatesController.class.getName(),e.getStackTraceString(),''));
        }
    }

    @AuraEnabled
    public static Map<String, TB_Certificate_Form__mdt> getCertificateFormsMetadata() {
        return TB_Certificate_Form__mdt.getAll();
    }

    @AuraEnabled
    public static List<CaseWrapper> fetchCaseWrappers(Id contactId) {
        List<Case> cases = fetchCases(contactId);
        return prepareCaseWrappers(cases);
    }

    private static List<CaseWrapper> prepareCaseWrappers(List<Case> cases) {
        List<Id> caseIds = new List<Id>();
        for (Case c : cases) {
            caseIds.add(c.Id);
        }
        List<CaseWrapper> resultWrappers = new List<CaseWrapper>();
        if (caseIds.size() > 0) {
            Map<Id, String> certificateFileHrefs = getCertificateFileHrefs(caseIds);
            for (Case c : cases) {
                CaseWrapper wrapper = new CaseWrapper();
                wrapper.caseId = c.Id;
                wrapper.contactName = c.Contact.TB_x_Contact_Name__c;
                wrapper.subject = c.TB_Category__c;
                wrapper.type = c.TB_Category__c;
                wrapper.subtype = c.TB_Subcategory__c;
                wrapper.programEnrollment = UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? c.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c : c.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c;
                wrapper.createdDate = c.CreatedDate;
                wrapper.caseNumber = c.CaseNumber;
                wrapper.status = c.TB_Status_For_Student__c;
                wrapper.priorStatus = c.TB_Prior_Status__c;
                wrapper.description = c.TB_Description_Rich_Text__c;
                wrapper.descriptionPlain = c.Description;
                wrapper.lastActivityDate = c.TB_Last_Activity_Date__c == null ? c.CreatedDate : c.TB_Last_Activity_Date__c;
                wrapper.showReplyButton = c.TB_Available_To_Reply__c;
                wrapper.showCancelButton = c.TB_Available_To_Cancel__c;
                wrapper.showDownloadButton = c.TB_Available_To_Download__c;
                wrapper.certificateFileHref = c.TB_Available_To_Download__c ? certificateFileHrefs.get(c.Id): null;
                resultWrappers.add(wrapper);
            }
        }
        return resultWrappers;
    }

    private static Map<Id, List<ContentVersion>> getIdToContentVersions(List<Id> ids) {
        Map<Id, List<ContentVersion>> idToContentVersions = new Map<Id, List<ContentVersion>>();
        List<ContentDocumentLink> contentDocumentLinks = getContentLinks(ids);

        Set<Id> allVersionIds = new Set<Id>();

        for (ContentDocumentLink link : contentDocumentLinks) {
            allVersionIds.add(link.ContentDocument.LatestPublishedVersionId);

        }
        Map<Id, ContentVersion> allContentIdToVersions = new Map<Id, ContentVersion>([
            SELECT FileExtension, ContentSize, Title, TB_Case_Comment__c
            FROM ContentVersion
            WHERE Id IN :allVersionIds
        ]);

        for (ContentDocumentLink link : contentDocumentLinks) {
            Id versionId = link.ContentDocument.LatestPublishedVersionId;
            if (idToContentVersions.get(link.LinkedEntityId) == null) {
                idToContentVersions.put(link.LinkedEntityId, new List<ContentVersion>{
                    allContentIdToVersions.get(versionId)
                });
            } else {
                idToContentVersions.get(link.LinkedEntityId).add(allContentIdToVersions.get(versionId));
            }
        }
        return idToContentVersions;
    }

    @AuraEnabled
    public static List<Case> fetchCases(Id contactId) {
        try {
            return [
                SELECT Id, CaseNumber, Contact.TB_x_Contact_Name__c,  toLabel(TB_Category__c), toLabel(TB_Subcategory__c), TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c,
                    TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c, toLabel(TB_Status_For_Student__c), CreatedDate,
                    CreatedById, Description, TB_Description_Rich_Text__c, TB_Last_Activity_Date__c, ClosedDate, IsClosed,
                    TB_Available_To_Reply__c, TB_Available_To_Cancel__c, TB_Available_To_Download__c, TB_Prior_Status__c
                FROM Case
                WHERE ContactId =: contactId AND RecordType.DeveloperName =: CERTIFICATE_RECORD_TYPE
                ORDER BY TB_Last_Activity_Date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CertificatesController.class.getName(),e.getStackTraceString(),'')
            );
        }
    }

    @AuraEnabled
    public static List<CommentWrapper> fetchCaseComments(Id caseId) {
        try {
            List<CommentWrapper> commentWrappers = new List<CommentWrapper>();
            List<TB_Operation__c> comments = [
                SELECT TB_Description_Rich_Text__c, CreatedDate, CreatedById, TB_Case__c, TB_Contact_Name__c,TB_Contact__r.TB_HE_Index__c
                FROM TB_Operation__c
                WHERE TB_Case__c = :caseId AND TB_Publish__c = TRUE
                ORDER BY CreatedDate
            ];

            List<Id> caseCommentIds = new List<Id> ();
            for (TB_Operation__c comment : comments) {
                caseCommentIds.add(comment.Id);
            }

            Map<Id, List<ContentVersion>> commentIdToContentVersions = getIdToContentVersions(caseCommentIds);

            for (TB_Operation__c comment : comments) {
                commentWrappers.add(
                    new CommentWrapper(
                        comment,
                        comment.TB_Contact_Name__c,
                        comment.TB_Contact__r.TB_HE_Index__c,
                        commentIdToContentVersions.get(comment.Id)
                    )
                );
            }
            return commentWrappers;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CertificatesController.class.getName(),e.getStackTraceString(),''));
        }
    }

    private static List<ContentDocumentLink> getContentLinks(List<Id> linkedEntityIds) {
        List<ContentDocumentLink> contentLinks = [
            SELECT ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :linkedEntityIds
            ORDER BY SystemModstamp DESC
            LIMIT 1000
        ];
        return contentLinks;
    }

    private static Map<Id,String> getCertificateFileHrefs(List<String> caseIds) {
        try {
            Map<Id, String> toReturn = new Map<Id,String>();
            for(ContentDocumentLink cdl :[
                SELECT
                    LinkedEntityId,
                    ContentDocumentId
                FROM ContentDocumentLink
                WHERE
                    LinkedEntityId IN :caseIds AND 
                    ContentDocument.LatestPublishedVersion.TB_Category__c = :CONTENT_VERSION_CATEGORY
                ORDER BY ContentDocument.LatestPublishedVersion.LastModifiedDate DESC
                
            ]){
                toReturn.put(cdl.LinkedEntityId, TB_Constants.DOWNLOAD_FILE_HREF + cdl.ContentDocumentId);
            }

            return toReturn;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CertificatesController.class.getName(),e.getStackTraceString(),''));
        }
    }
}
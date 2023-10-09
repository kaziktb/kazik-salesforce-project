/**
 * Created by kacperjachowicz on 25/08/2021.
 */

@IsTest
public with sharing class TB_TestDataFactory {
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';

    public static TB_Employee_Evaluation_Process_Stage__c prepareEmployeeEvaluationProcessStage(
            String processStageType
    ) {
        return new TB_Employee_Evaluation_Process_Stage__c(
                TB_Process_Stage_Type__c = processStageType
        );
    }

    public static User prepareUser() {
        return new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
                        .Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
        );
    }
    public static TB_Document_Template_Bundle_Item__c createDocumentTemplatesBundleItem(Boolean withInsert, ID documentTemplateId, ID documentTemplatesBundleId) {
        TB_Document_Template_Bundle_Item__c documentTemplatesBundleItem = new TB_Document_Template_Bundle_Item__c(
                TB_Document_Template__c = documentTemplateId,
                TB_Document_Templates_Bundle__c = documentTemplatesBundleId
        );

        if (withInsert) {
            insert documentTemplatesBundleItem;
        }
        return documentTemplatesBundleItem;
    }

    public static TB_Document_Templates_Bundle__c createDocumentTemplatesBundle(Boolean withInsert, String name, Boolean onDemandDocuments, String productGroup, Boolean isActive) {
        TB_Document_Templates_Bundle__c documentTemplatesBundle = new TB_Document_Templates_Bundle__c(
                Name = name,
                TB_On_Demand_Documents__c = onDemandDocuments,
                TB_Product_Group__c = productGroup,
                TB_Active__c = isActive
        );

        if (withInsert) {
            insert documentTemplatesBundle;
        }
        return documentTemplatesBundle;
    }

    public static Contact prepareContact(Boolean withInsert) {
        return prepareContact('Mr', withInsert);
    }

    public static Contact prepareContact(String title, Boolean withInsert) {
        return prepareContact(title, null, withInsert);
    }

    public static Contact prepareContact(
            String title,
            String hedEmail,
            Boolean withInsert
    ) {
        Contact contact = new Contact(
                FirstName = 'Test',
                LastName = 'Kowalski',
                hed__WorkEmail__c = hedEmail,
                Title = title
        );

        if (withInsert) {
            insert contact;
        }
        return contact;
    }

    public static TB_Employee_Evaluation__c prepareEmployeeEvaluation(
            Id evaluatedId,
            String processType
    ) {
        return prepareEmployeeEvaluation(evaluatedId, null, processType);
    }

    public static TB_Employee_Evaluation__c prepareEmployeeEvaluation(
            Id evaluatedId,
            Id evaluatorId,
            String processType
    ) {
        return new TB_Employee_Evaluation__c(
                TB_Evaluated__c = evaluatedId,
                TB_Process_Type__c = processType,
                TB_Evaluator__c = evaluatorId
        );
    }

    public static TB_Employee_Evaluation_Stage__c prepareEmployeeEvaluationStage(
            Id employeeEvaluationProcessStageId,
            Id employeeEvaluationId
    ) {
        return prepareEmployeeEvaluationStage(
                employeeEvaluationProcessStageId,
                employeeEvaluationId,
                null,
                null,
                null
        );
    }

    public static TB_Employee_Evaluation_Stage__c prepareEmployeeEvaluationStage(
            Id employeeEvaluationProcessStageId,
            Id employeeEvaluationId,
            String stageType
    ) {
        return prepareEmployeeEvaluationStage(
                employeeEvaluationProcessStageId,
                employeeEvaluationId,
                null,
                stageType,
                null
        );
    }

    public static TB_Employee_Evaluation_Stage__c prepareEmployeeEvaluationStage(
            Id employeeEvaluationProcessStageId,
            Id employeeEvaluationId,
            String stageStatus,
            String stageType,
            Date stageEndDate
    ) {
        return new TB_Employee_Evaluation_Stage__c(
                TB_Employee_Evaluation__c = employeeEvaluationId,
                TB_Employee_Evaluation_Process_Stage__c = employeeEvaluationProcessStageId,
                TB_Evaluation_Stage_End_Date__c = stageEndDate,
                TB_Employee_Stage_Type__c = stageType,
                TB_Evaluation_Stage_Status__c = stageStatus
        );
    }

    public static TB_Data_Collection__c prepareDataCollection(
            Id emplEvalStageId
    ) {
        return prepareDataCollection(emplEvalStageId, null, null);
    }

    public static TB_Data_Collection__c prepareDataCollection(
            Id emplEvalStageId,
            String sourceObject,
            String sourceField
    ) {
        return prepareDataCollection(
                emplEvalStageId,
                sourceObject,
                sourceField,
                null,
                null
        );
    }

    public static TB_Data_Collection__c prepareDataCollection(
            Id emplEvalStageId,
            String sourceObject,
            String sourceField,
            String targetObject,
            String targetField
    ) {
        return new TB_Data_Collection__c(
                Name = 'test',
                TB_Employee_Evaluation_Stage__c = emplEvalStageId,
                TB_Source_Object__c = sourceObject,
                TB_Source_Object_Field__c = sourceField,
                TB_Target_Object__c = targetObject,
                TB_Target_Object_Field__c = targetField
        );
    }

    public static TB_Employee_Evaluation_Stage_Document__c prepareEmployeeEvaluationStageDocument(
            Id dataCollectionId,
            Id eEvaluationStageId
    ) {
        return new TB_Employee_Evaluation_Stage_Document__c(
                Name = 'ProcessStage',
                TB_Data_Collection__c = dataCollectionId,
                TB_Employee_Evaluation_Stage__c = eEvaluationStageId
        );
    }

    public static hed__Attribute__c prepareContactAttribute(
            Id contactId,
            Boolean withInsert
    ) {
        hed__Attribute__c attribute = new hed__Attribute__c(
                hed__Contact__c = contactId
        );

        if (withInsert) {
            insert attribute;
        }
        return attribute;
    }

    public static List<hed__Attribute__c> prepareContactAttributes(List<Contact> contacts, Boolean withInsert) {
        List<hed__Attribute__c> attributes = new List<hed__Attribute__c>();
        for (Contact contact : contacts) {
            attributes.add(new hed__Attribute__c(
                    hed__Contact__c = contact.Id
            ));
        }
        if (withInsert) {
            insert attributes;
        }
        return attributes;
    }

    public static User createUser(String profileName, Boolean withInsert) {
        User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName]
                        .Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
        );
        if (withInsert) {
            insert u;
        }
        return u;
    }

    public static hed__Application__c createApplicationWithRelatedObjects(
            Boolean withInsert
    ) {
        hed__Application__c application = new hed__Application__c(
                TB_Admissions_Fee__c = 100,
                TB_Test__c = true
        );
        application.hed__Applicant__c = createContact(true).Id;
        application.TB_Admissions_Process__c = createAdmissionProcess(true).Id;
        application.TB_Applying_To_Offered_Product__c = createOfferedProduct(true)
                .Id;

        if (withInsert) {
            insert application;
        }
        return application;
    }

    public static hed__Application__c createApplicationWithRelatedObjectsAndNestedLookup(
            Boolean withInsert
    ) {
        hed__Application__c application = new hed__Application__c(
                TB_Admissions_Fee__c = 100,
                TB_Test__c = true
        );
        application.hed__Applicant__c = createContact(true).Id;
        application.TB_Admissions_Process__c = createAdmissionProcess(true).Id;
        application.TB_Applying_To_Offered_Product__c = createOfferedProductWithAdmissionsProcess(
                application.TB_Admissions_Process__c,
                true
        )
                .Id;

        if (withInsert) {
            insert application;
        }
        return application;
    }

    public static hed__Application__c createApplicationWithNestedLookup(Boolean withInsert, Id contactId) {
        hed__Application__c application = new hed__Application__c(
                TB_Admissions_Fee__c = 100,
                TB_Test__c = true
        );
        application.hed__Applicant__c = contactId;
        application.TB_Admissions_Process__c = createAdmissionProcess(true).Id;
        application.TB_Applying_To_Offered_Product__c = createOfferedProductWithAdmissionsProcess(application.TB_Admissions_Process__c, true).Id;

        if (withInsert) {
            insert application;
        }
        return application;
    }

    public static ContentVersion createContentVersion(
            Boolean withInsert,
            String title,
            String pathOnClient,
            String versionData
    ) {
        ContentVersion contentVersion = new ContentVersion(
                Title = title,
                PathOnClient = pathOnClient,
                VersionData = Blob.valueof(versionData)
        );
        if (withInsert) {
            insert contentVersion;
        }
        return contentVersion;
    }

    public static ContentDocumentLink createContentDocumentLink(
            Boolean withInsert,
            Id contentDocumentId,
            Id linkedEntityId
    ) {
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = contentDocumentId,
                LinkedEntityId = linkedEntityId
        );
        if (withInsert) {
            insert contentDocumentLink;
        }
        return contentDocumentLink;
    }

    public static TB_Application_Document__c createApplicationDocument(
            Boolean withInsert,
            Id tbApplicationId,
            String tbDocumentType
    ) {
        TB_Application_Document__c applicationDocument = new TB_Application_Document__c(
                TB_Application__c = tbApplicationId,
                TB_Document_Type__c = tbDocumentType
        );
        if (withInsert) {
            insert applicationDocument;
        }
        return applicationDocument;
    }

    public static TB_Application_Document__c createApplicationDocument(
            Boolean withInsert,
            String documentName,
            Id tbApplicationId,
            String tbDocumentType,
            Boolean isActive,
            String documentCategory,
            String status
    ) {
        TB_Application_Document__c applicationDocument = new TB_Application_Document__c(
                TB_Document_Name__c = documentName,
                TB_Application__c = tbApplicationId,
                TB_Document_Type__c = tbDocumentType,
                TB_Active__c = isActive,
                TB_Document_Category__c = documentCategory,
                TB_Status__c = status
        );
        if (withInsert) {
            insert applicationDocument;
        }
        return applicationDocument;
    }

    public static TB_Document_Template__c createDocumentTemplate(Boolean withInsert, String type, String name) {
        TB_Document_Template__c documentTemplate = new TB_Document_Template__c(
                Name = name,
                TB_Document_Type__c = type
        );
        if (withInsert) {
            insert documentTemplate;
        }
        return documentTemplate;
    }

    public static TB_Document_Template__c createDocumentTemplate(
            Boolean withInsert
    ) {
        TB_Document_Template__c documentTemplate = new TB_Document_Template__c();
        if (withInsert) {
            insert documentTemplate;
        }
        return documentTemplate;
    }

    public static Contact createApplicantContact(Boolean withInsert, String PESEL, String documentNumber, String documentIssueCountry) {
        Contact contact = createContact();
        contact.RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName(
                TB_re_Constants.TB_CONTACT_LABEL, TB_re_Constants.CONTACT_APPLICANT_RT
        );
        contact.DT_PESEL__c = PESEL;
        contact.DT_Document_Series_and_Number__c = documentNumber;
        contact.DT_Document_Issuing_Country__c = documentIssueCountry;
        if (withInsert) {
            insert contact;
        }
        return contact;
    }

    public static Contact createContact(Boolean withInsert) {
        Contact contact = new Contact(LastName = 'testContact', FirstName = 'testContact', 
        TB_Communication_Language__c = 'English', Email = 'test@test.com',
        Birthdate = Date.today() - 365*24);
        if (withInsert) {
            insert contact;
        }
        return contact;
    }

    public static Contact createContact() {
        return createContact(false);
    }

    public static TB_Offered_Product__c createOfferedProduct(Boolean withInsert) {
        TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c(
                Name = 'testProduct'
        );
        if (withInsert) {
            insert offeredProduct;
        }
        return offeredProduct;
    }

    public static TB_Offered_Product__c createOfferedProductWithAdmissionsProcess(
            String admissionsProcessId,
            Boolean withInsert
    ) {
        TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c(
                Name = 'testProduct',
                TB_Admissions_Process__c = admissionsProcessId
        );
        if (withInsert) {
            insert offeredProduct;
        }
        return offeredProduct;
    }

    public static TB_Related_Offered_Product__c createRelatedOfferedProduct(
            Boolean withInsert
    ) {
        TB_Related_Offered_Product__c relatedOfferedProduct = new TB_Related_Offered_Product__c(
                TB_Deactivation_Mode__c = 'Automatic'
        );
        if (withInsert) {
            insert relatedOfferedProduct;
        }
        return relatedOfferedProduct;
    }

    public static hed__Application__c createApplication(
            Id admissionProcessId,
            Id offeredProductId,
            Boolean withInsert
    ) {
        hed__Application__c application = new hed__Application__c();
        application.TB_Admissions_Process__c = admissionProcessId;
        application.TB_Applying_To_Offered_Product__c = offeredProductId;
        application.TB_Test__c = true;
        if (withInsert) {
            insert application;
        }
        return application;
    }

    public static hed__Application__c createApplicationWithComments(
            Id facultyId,
            Id campusId,
            Id offeredProductId,
            Id contactId,
            String commentCategory,
            Boolean withInsert
    ) {
        hed__Application__c application = new hed__Application__c(
                TB_Active__c = true,
                TB_Archived__c = false,
                hed__Application_Status__c = 'Verification',
                TB_Comments_To_Applicant__c = 'Test',
                TB_Comments_To_Applicant_Category__c = commentCategory,
                TB_Faculty__c = facultyId,
                TB_Campus__c = campusId,
                TB_Mode_of_Study__c = 'Full_Time',
                TB_Level_of_Study__c = 'Master',
                hed__Applicant__c = contactId,
                TB_Applying_To_Offered_Product__c = offeredProductId
        );

        if (withInsert) {
            insert application;
        }
        return application;
    }

    public static List<TB_Data_History__c> createDataHistories(
            Integer numberOfDataHistories,
            Boolean withInsert
    ) {
        List<TB_Data_History__c> dataHistories = new List<TB_Data_History__c>();
        for (Integer i = 1; i <= numberOfDataHistories; i++) {
            TB_Data_History__c dataHistory = new TB_Data_History__c();
            dataHistory.TB_New_Value__c = 'New Value ' + i;
            dataHistory.TB_Prior_Value__c = 'Prior Value ' + i;
            dataHistories.add(dataHistory);
        }
        if (withInsert) {
            insert dataHistories;
        }
        return dataHistories;
    }

    public static TB_Admissions_Process__c createAdmissionProcess(
            Boolean withInsert
    ) {
        TB_Admissions_Process__c admissionsProcess = createAdmissionProcessWithRT(
                TB_Constants.ADMISSION_PROCESS_ADMISSION_PROCESS_RT,
                null,
                null
        );
        if (withInsert) {
            insert admissionsProcess;
        }
        return admissionsProcess;
    }

    public static TB_Admissions_Process__c createAdmissionStage(
            Boolean withInsert,
            Id admissionProcessId
    ) {
        TB_Admissions_Process__c admissionsProcess = createAdmissionProcessWithRT(
                TB_Constants.ADMISSION_PROCESS_ADMISSION_STAGE_RT,
                admissionProcessId,
                null
        );
        admissionsProcess.TB_Display_Name_EN__c = 'Test EN';
        admissionsProcess.TB_Display_Name_PL__c = 'Test PL';
        if (withInsert) {
            insert admissionsProcess;
        }
        return admissionsProcess;
    }

    public static TB_Admissions_Process__c createAdmissionStep(
            Boolean withInsert,
            Id admissionStageId
    ) {
        TB_Admissions_Process__c admissionsProcess = createAdmissionProcessWithRT(
                TB_Constants.ADMISSION_PROCESS_ADMISSION_STEP_RT,
                null,
                admissionStageId
        );
        admissionsProcess.TB_Display_Name_EN__c = 'Test EN';
        admissionsProcess.TB_Display_Name_PL__c = 'Test PL';
        if (withInsert) {
            insert admissionsProcess;
        }
        return admissionsProcess;
    }

    public static TB_Admissions_Process__c createAdmissionProcessWithRT(
            String recordTypeDevName,
            Id admissionProcessId,
            Id admissionStageId
    ) {
        String recordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName(
                'TB_Admissions_Process__c',
                recordTypeDevName
        );
        return new TB_Admissions_Process__c(
                RecordTypeId = recordTypeId,
                TB_Admissions_Process__c = admissionProcessId,
                TB_Admissions_Stage__c = admissionStageId
        );
    }

    public static TB_Admissions_Step_Dynamic_Content__c createAdmissionsStepDynamicContent(
            Boolean withInsert,
            Id admissionStepId,
            Id admissionContentId
    ) {
        TB_Admissions_Step_Dynamic_Content__c admissionsStepDynamicContent = new TB_Admissions_Step_Dynamic_Content__c(
                TB_Admissions_Step__c = admissionStepId,
                TB_Admissions_Content__c = admissionContentId
        );

        if (withInsert) {
            insert admissionsStepDynamicContent;
        }
        return admissionsStepDynamicContent;
    }

    public static TB_Admissions_Content__c createAdmissionsContent(
            Boolean withInsert
    ) {
        return createAdmissionsContent(withInsert, 'recordCode');
    }

    public static TB_Admissions_Content__c createAdmissionsContent(
            Boolean withInsert,
            String recordCode
    ) {
        return createAdmissionsContent(
                withInsert,
                recordCode,
                'Message',
                'Warning'
        );
    }

    public static TB_Admissions_Content__c createPortalContent(
            Boolean withInsert,
            String recordCode,
            String contentType,
            String contentSubType
    ) {
        TB_Admissions_Content__c admissionsContent = new TB_Admissions_Content__c(
                TB_Content_Type__c = contentType,
                TB_Content_Sub_Type__c = contentSubType,
                TB_Record_Code__c = recordCode,
                TB_Content_PL__c = '<p>Wiadomosc</p>',
                TB_Content_EN__c = '<p>Message</p>'
        );

        if (withInsert) {
            insert admissionsContent;
        }
        return admissionsContent;
    }

    public static TB_Admissions_Content__c createAdmissionsContent(
            Boolean withInsert,
            String recordCode,
            String contentType,
            String contentSubType
    ) {
        TB_Admissions_Content__c admissionsContent = new TB_Admissions_Content__c(
                TB_Content_Type__c = contentType,
                TB_Content_Sub_Type__c = contentSubType,
                TB_Record_Code__c = recordCode,
                TB_Content_PL__c = '<p>Wiadomosc</p>',
                TB_Content_EN__c = '<p>Message</p>'
        );

        if (withInsert) {
            insert admissionsContent;
        }
        return admissionsContent;
    }

    public static TB_Admissions_Dictionary__c createAdmissionDictionary(
            Boolean withInsert
    ) {
        TB_Admissions_Dictionary__c admissionDictionary = new TB_Admissions_Dictionary__c();
        if (withInsert) {
            insert admissionDictionary;
        }
        return admissionDictionary;
    }

    public static TB_Admissions_Data_Definition__c createAdmissionsDataDefinition(
            Boolean withInsert
    ) {
        TB_Admissions_Data_Definition__c admissionsDataDefinition = new TB_Admissions_Data_Definition__c(
                TB_Data_Type__c = 'Checkbox',
                TB_Label_PL__c = 'labelPl',
                TB_Label_EN__c = 'labelEn',
                TB_Purpose__c = 'Data_Display'
        );
        if (withInsert) {
            insert admissionsDataDefinition;
        }
        return admissionsDataDefinition;
    }

    public static TB_Admissions_Logic__c createAdmissionsLogic(
            Boolean withInsert
    ) {
        TB_Admissions_Logic__c admissionsLogic = new TB_Admissions_Logic__c(
                RecordTypeId = TB_Constants.ADMISSIONS_LOGIC_PROCESS_LOGIC_RT_ID
        );
        if (withInsert) {
            insert admissionsLogic;
        }
        return admissionsLogic;
    }

    public static TB_Admissions_Step_Data__c createAdmissionsStepData(
            Boolean withInsert,
            String admissionsStepId,
            String admissionsDataDefinition
    ) {
        TB_Admissions_Step_Data__c admissionsStepData = new TB_Admissions_Step_Data__c(
                TB_Admissions_Step__c = admissionsStepId,
                TB_Admissions_Data_Definition__c = admissionsDataDefinition
        );
        if (withInsert) {
            insert admissionsStepData;
        }
        return admissionsStepData;
    }

    public static TB_Admissions_Survey__c createAdmissionsSurvey(
            Boolean withInsert
    ) {
        TB_Admissions_Survey__c admissionsSurvey = new TB_Admissions_Survey__c();
        if (withInsert) {
            insert admissionsSurvey;
        }
        return admissionsSurvey;
    }

    public static TB_Admissions_Survey_Answer__c createAdmissionsSurveyAnswer(
            Boolean withInsert
    ) {
        TB_Admissions_Survey_Answer__c admissionsSurveyAnswer = new TB_Admissions_Survey_Answer__c();
        if (withInsert) {
            insert admissionsSurveyAnswer;
        }
        return admissionsSurveyAnswer;
    }

    public static TB_Portal__c createPortal(
            Boolean withInsert
    ) {
        TB_Portal__c portal = new TB_Portal__c();
        if (withInsert) {
            insert portal;
        }
        return portal;
    }

    public static Contract createContract(
        Boolean withInsert,
        String accountId
    ) {
        Contract contract = new Contract(AccountId = accountId);
        if (withInsert) {
            insert contract;
        }
        return contract;
    }

    public static DT_Contract_Product__c createContractProduct(
        Boolean withInsert,
        String contractId
    ) {
        DT_Contract_Product__c contractProduct = new DT_Contract_Product__c(DT_Contract__c = contractId);
        if (withInsert) {
            insert contractProduct;
        }
        return contractProduct;
    }

    public static TB_Qualification_Requirement__c createQualificationRequirement(
            Boolean withInsert
    ) {
        TB_Qualification_Requirement__c qualificationRequirement = new TB_Qualification_Requirement__c();
        if (withInsert) {
            insert qualificationRequirement;
        }
        return qualificationRequirement;
    }

    public static TB_Admissions_Campaign__c createAdmissionsCampaign(
            Boolean withInsert
    ) {
        TB_Admissions_Campaign__c admissionsCampaign = new TB_Admissions_Campaign__c(
                Name = 'Admissions campaign'
        );
        if (withInsert) {
            insert admissionsCampaign;
        }
        return admissionsCampaign;
    }

    public static TB_Admissions_Committee__c createAdmissionsCommittee(
            Boolean withInsert
    ) {
        Id committeeRecordTypeId = SObjectType.TB_Admissions_Committee__c.getRecordTypeInfosByDeveloperName()
                .get('TB_Committee')
                .getRecordTypeId();

        TB_Admissions_Committee__c admissionsCommittee = new TB_Admissions_Committee__c(
                RecordTypeId = committeeRecordTypeId,
                TB_Study_Level_Group__c = 'Postgraduate',
                TB_Admissions_Campaign__c = createAdmissionsCampaign(true).Id
        );
        if (withInsert) {
            insert admissionsCommittee;
        }
        return admissionsCommittee;
    }

    public static TB_Qualification_Requirement_Item__c createQualificationRequirementItem(
            Boolean withInsert,
            String admissionsCommitteeId
    ) {
        TB_Qualification_Requirement_Item__c qualificationItem = new TB_Qualification_Requirement_Item__c(
                Name = 'Item',
                TB_Type__c = TB_Constants.QUALIFICATION_ITEM_TYPE_INTERVIEW,
                TB_Location_Type__c = 'Online',
                TB_Location_Details__c = 'Test details',
                TB_Hours_Limit_Before_Registration__c = 24,
                TB_Term_Capacity_Limit__c = 1,
                TB_Committee__c = admissionsCommitteeId,
                TB_Status__c = 'Published'
        );

        if (withInsert) {
            insert qualificationItem;
        }
        return qualificationItem;
    }

    public static TB_Qualification_Requirement_Item_Term__c createQualificationRequirementItemTerm(
            Boolean withInsert,
            String qualificationItemId
    ) {
        TB_Qualification_Requirement_Item_Term__c qualificationItemTerm = new TB_Qualification_Requirement_Item_Term__c(
                Name = 'Test Item Term',
                TB_Qualification_Requirement_Item__c = qualificationItemId,
                TB_Location__c = 'Online',
                TB_Location_Details__c = 'url.com',
                TB_Start__c = Datetime.now(),
                TB_End__c = Datetime.now().addDays(2),
                TB_Limit__c = 1
        );

        if (withInsert) {
            insert qualificationItemTerm;
        }
        return qualificationItemTerm;
    }

    public static TB_Application_Qualification__c createApplicationQualification(
            Boolean withInsert,
            String applicationId
    ) {
        TB_Application_Qualification__c applicationQualification = new TB_Application_Qualification__c(
                TB_Application__c = applicationId,
                TB_Qualification_Order__c = 10
        );

        if (withInsert) {
            insert applicationQualification;
        }
        return applicationQualification;
    }

    public static TB_Payment__c createPayment(
            Boolean withInsert,
            Id applicationId
    ) {
        TB_Payment__c payment = new TB_Payment__c(
                TB_Application__c = applicationId
        );

        if (withInsert) {
            insert payment;
        }
        return payment;
    }

    public static TB_Admissions_Dictionary__c createConsentBundle(
            Boolean withInsert
    ) {
        TB_Admissions_Dictionary__c consentBundle = new TB_Admissions_Dictionary__c(
                Name = 'Consent Bundle',
                RecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName()
                        .get('TB_Consents_Definitions_Bundle')
                        .getRecordTypeId()
        );
        if (withInsert) {
            insert consentBundle;
        }
        return consentBundle;
    }

    public static TB_Admissions_Dictionary__c createConsent(
            String consentType,
            String consentBundleId,
            Boolean withInsert
    ) {
        TB_Admissions_Dictionary__c consent = new TB_Admissions_Dictionary__c(
                Name = 'Consent',
                TB_Active__c = true,
                TB_Consents_Bundle__c = consentBundleId,
                TB_Description_PL__c = 'Desc PL',
                TB_Description_EN__c = 'Desc EN',
                TB_Consent_Type__c = consentType,
                RecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName()
                        .get('TB_Consent_Definition')
                        .getRecordTypeId()
        );
        if (withInsert) {
            insert consent;
        }
        return consent;
    }

    public static TB_Admissions_Dictionary__c createRequest(Boolean withInsert) {
        Id requestRecordTypeId = SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName()
                .get('TB_Application_Request')
                .getRecordTypeId();
        TB_Admissions_Dictionary__c request = new TB_Admissions_Dictionary__c(
                RecordTypeId = requestRecordTypeId,
                TB_Active__c = true,
                TB_Valid_From__c = Date.newInstance(2020, 2, 2),
                TB_Valid_To__c = Date.newInstance(2032, 2, 2),
                TB_Level_of_Study__c = 'Bachelor;Master;Integrated_Master;Postgraduate',
                TB_Mode_of_Study__c = 'Full_Time;Part_Time',
                TB_Language_of_Study__c = 'English',
                TB_Citizenships__c = 'Non_Polish_Citizens',
                TB_Application_Status__c = 'Conditionally_Accepted;Accepted;Initially_Selected',
                TB_Agreement_Type__c = 'Paper;Electronic',
                TB_Info_PL__c = 'Zwracam się z uprzejmą prośbą o zwrot opłaty za czesne, ze względu na .....\n' +
                        'Imię i nazwisko Kandydata: ...\n' +
                        'Numer Aplikacji: ...\n' +
                        'Imię i nazwisko właściciela konta: ....\n' +
                        'Numer konta do zwrotu: ...\n' +
                        'Nazwa banku: ....\n' +
                        'IBAN: .....\n' +
                        'SWIFT: .....\n' +
                        'W załączeniu przesyłam potwierdzenie wpłaty.',
                TB_Info_EN__c = 'I would like to request a refund of my tuition fee for the following reason(s): ...\n' +
                        'Student\'s full name: ...\n' +
                        'The Application number: ...\n' +
                        'First and last name of the account holder: ...\n' +
                        'Account number: ...\n' +
                        'Bank name: ...\n' +
                        'IBAN: ..\n' +
                        'SWIFT: ...\n' +
                        'I have attached a payment confirmation.'
        );

        if (withInsert) {
            insert request;
        }
        return request;
    }

    public static TB_Qualification_Requirement__c prepareQualificationRequirement(
            Id offeredProductId,
            Id recordType,
            String examType,
            String citizenshipDep,
            Decimal points
    ) {
        TB_Qualification_Requirement__c requirement = new TB_Qualification_Requirement__c();
        requirement.TB_Offered_Product__c = offeredProductId;
        requirement.RecordTypeId = recordType;
        requirement.TB_HS_Exam_Type__c = examType;
        requirement.TB_Active__c = true;
        requirement.TB_Citizenship_Dependency__c = citizenshipDep;
        requirement.TB_HS_Exam_Points__c = points;
        return requirement;
    }

    public static TB_Qualification_Requirement__c createQualificationRequirement(
            Id offeredProductId,
            Id recordType,
            String examType,
            String citizenshipDep,
            Decimal points
    ) {
        TB_Qualification_Requirement__c resultObj = prepareQualificationRequirement(
                offeredProductId,
                recordType,
                examType,
                citizenshipDep,
                points
        );
        insert resultObj;
        return resultObj;
    }

    public static TB_Qualification_Requirement__c createQualificationRequirementForLanguageCertificate(
            String citizenshipDependency,
            String productId,
            Boolean withInsert
    ) {
        String recordTypeLanguageCertificateId = Schema.SObjectType.TB_Qualification_Requirement__c.getRecordTypeInfosByDeveloperName()
                .get('TB_Language_Certificate')
                .getRecordTypeId();
        TB_Qualification_Requirement__c requirement = new TB_Qualification_Requirement__c(
                RecordTypeId = recordTypeLanguageCertificateId,
                TB_Citizenship_Dependency__c = citizenshipDependency,
                TB_Offered_Product__c = productId,
                TB_Active__c = true
        );
        if (withInsert) {
            insert requirement;
        }
        return requirement;
    }

    public static TB_Experience_History__c createExperienceHistoryWithRecordType(
            String recordTypeId,
            Id appId,
            Boolean withInsert,
            String name
    ) {
        TB_Experience_History__c expHist = new TB_Experience_History__c(
                RecordTypeId = recordTypeId,
                TB_Name__c = name,
                TB_Application__c = appId,
                TB_Active__c = true
        );
        if (withInsert) {
            insert expHist;
        }
        return expHist;
    }

    public static TB_Employee_Evaluation_Process__c prepareEmployeeEvaluationProcess(
            String name,
            String processYear,
            Id rectorId,
            Id adminId
    ) {
        TB_Employee_Evaluation_Process__c employeeEvaluationProcess = new TB_Employee_Evaluation_Process__c(
                Name = name,
                TB_Process_Year__c = processYear,
                TB_Rector__c = rectorId,
                TB_Administrator__c = adminId
        );
        return employeeEvaluationProcess;
    }

    public static TB_Employee_Evaluation_Process__c createEmployeeEvaluationProcess(
            String name,
            String processYear,
            Id rectorId,
            Id adminId
    ) {
        TB_Employee_Evaluation_Process__c eep = prepareEmployeeEvaluationProcess(
                name,
                processYear,
                rectorId,
                adminId
        );
        insert eep;
        return eep;
    }
    public static TB_Moodle__c prepareMoodleCustomSetting(String url, String user, String psw, String wsUrl, String role) {
        return new TB_Moodle__c(
                TB_Moodle_Login_URL__c = url,
                TB_Moodle_usr__c = user,
                TB_Moodle_psw__c = psw,
                TB_Moodle_WS_URL__c = wsUrl,
                TB_Moodle_Student_Role_Id__c = role);
    }

    public static TB_Moodle__c createMoodleCustomSetting(String url, String user, String psw, String wsUrl, String role) {
        TB_Moodle__c moodle = prepareMoodleCustomSetting(url, user, psw, wsUrl, role);
        insert moodle;
        return moodle;
    }

    public static List<Account> prepareAccounts(Integer numberOfAccounts, Id recTypeId) {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            accs.add(new Account(
                    RecordTypeId = recTypeId,
                    Name = 'Acc name' + i,
                    TB_Email__c = 'TBemail@email.invalid.email' + i,
                    TB_Active__c = true));
        }
        return accs;
    }

    public static List<Account> createAccounts(Integer numberOfAccounts, Id recTypeId, Boolean withInsert) {
        List<Account> accs = prepareAccounts(numberOfAccounts, recTypeId);
        if (withInsert) {
            insert accs;
        }
        return accs;
    }

    public static hed__Affiliation__c createAffiliation(Contact contactToPass, Account accountToPass, Boolean toInsert) {
        hed__Affiliation__c affiliation = new hed__Affiliation__c(
                hed__Contact__c = contactToPass.Id,
                hed__Account__c = accountToPass.Id,
                hed__StartDate__c = Date.today(),
                hed__Role__c = 'SO_Member');
        if (toInsert) {
            insert affiliation;
        }
        return affiliation;
    }

    public static List<Contact> prepareContacts(Integer numberOfContacts, Boolean withInsert, String lastName) {
        List<Contact> contacts = new List<Contact>();
        String contLastName = lastName != null ? lastName : 'contactLastName';
        for (Integer i = 0; i < numberOfContacts; i++) {
            contacts.add(new Contact(
                    LastName = contLastName + i,
                    TB_Active__c = true,
                    TB_Duplicate__c = false,
                    TB_Anonymization_Status__c = null));
        }
        if (withInsert) {
            insert contacts;
        }
        return contacts;
    }

    public static TB_Rating__c createRating(Boolean withInsert, Id contactId, Id offeredProduct) {
        TB_Rating__c rating = new TB_Rating__c(TB_Teacher__c = contactId, TB_Offered_Product__c = offeredProduct);
        if (withInsert) {
            insert rating;
        }
        return rating;
    }
    
    public static TB_Operation__c createOperation(Id contactId, Id caseId, String description, Boolean withInsert){
        TB_Operation__c operation = new TB_Operation__c(
                TB_Contact__c = contactId,
                TB_Case__C = caseId,
                TB_Description__c = description
        );
        if(withInsert) insert operation;
        return operation;
    }
    
    public static List<Case> createCases(Integer numberOfCases, String subject, Id contactId, Boolean withInsert){
        List<Case> cases = new List<Case>();
        for(Integer i=0; i<numberOfCases; i++){
            cases.add(new Case(
                    Subject = subject + i,
                    ContactId = contactId
            ));
        }
        if(withInsert) insert cases;
        return cases;
    }
    
    public static List<Event> createEvents(Integer numberOfEvents, Id whoId, Id whatId, Id ownerId, Boolean withInsert){
        List<Event> events = new List<Event>();
        Datetime now = DateTime.now();
        for(Integer i=0; i<numberOfEvents; i++){
            events.add(new Event(
                    WhatId = whatId,
                    IsVisibleInSelfService = true,
                    WhoId = whoId,
                    OwnerId = ownerId,
                    StartDateTime = now.addHours(4),
                    EndDateTime = now.addHours(5)
            ));
        }
        if(withInsert) insert events;
        return events;
    }

    public static List<TB_Knowledge_Category__c> createKnowledgeCategories(Integer numberOfRecords, String categoryApiName, String businessOwner, Boolean withInsert){
        List<TB_Knowledge_Category__c> knowledgeCategories = new List<TB_Knowledge_Category__c>();
        for(Integer i=0; i<numberOfRecords; i++){
            knowledgeCategories.add(new TB_Knowledge_Category__c(
                TB_Category_API_Name__c = categoryApiName + i,
                TB_Public__c = true,
                TB_Category_Name_PL__c = categoryApiName + '_PL' + '_' + i,
                TB_Category_Name_EN__c = categoryApiName + '_EN' + '_' + i,
                TB_Business_Owner__c = businessOwner
            ));
        }
        if(withInsert) insert knowledgeCategories;
        return knowledgeCategories;
    }

    public static List<Knowledge__kav> createKnowledgeKavs(Integer numberOfRecords, String title, Boolean withInsert){
        List<Knowledge__kav> knowledgeKavs = new List<Knowledge__kav>();
        for(Integer i=0; i<numberOfRecords; i++){
            knowledgeKavs.add(new Knowledge__kav(
                Title = title,
                TB_Content__c = '<p>- Jak to jest być skrybą? Dobrze? Moim zdaniem to nie ma tak, że dobrze albo że nie dobrze. Gdybym miał powiedzieć, co cenię w życiu najbardziej, powiedziałbym, że ludzi. Ekhm...</p>',
                UrlName = title + 'url',
                Language = 'en_US',
                TB_Last_Activity_Date__c = Datetime.now()
            ));
        }
        if(withInsert) insert knowledgeKavs;
        return knowledgeKavs;
    }

    public static List<TB_Suggested_Article_Group__c> createSuggestedArticleGroups(Integer numberOfRecords, String name, String knowledgeCategoryId, String recordTypeDeveloperName, String contactGroup, Boolean withInsert){
        List<TB_Suggested_Article_Group__c> sags = new List<TB_Suggested_Article_Group__c>();
        for(Integer i=0; i<numberOfRecords; i++){
            sags.add(new TB_Suggested_Article_Group__c(
                TB_Owner_Name__c = name + i,
                TB_Knowledge_Category__c = knowledgeCategoryId,
                TB_Suggested_Article_Group_Name_PL__c = name + ' PL ' + i,
                TB_Suggested_Article_Group_Name_EN__c = name + ' EN ' + i,
                RecordTypeId = TB_kb_SuggestedArticlesController.getRecordTypeId(recordTypeDeveloperName),
                TB_Contact_Group__c = contactGroup,
                TB_Order__c = i
            ));
        }
        if(withInsert) insert sags;
        return sags;
    }

    public static List<TB_Suggested_Article_Group_Element__c> createSuggestedArticleGroupElements(Integer numberOfRecords, String sagId, String kavId, Boolean withInsert){
        List<TB_Suggested_Article_Group_Element__c> sages = new List<TB_Suggested_Article_Group_Element__c>();
        for(Integer i=0; i<numberOfRecords; i++){
            sages.add(new TB_Suggested_Article_Group_Element__c(
                TB_Suggested_Article_Group__c = sagId,
                TB_Article__c = kavId,
                TB_Order__c = i
            ));
        }
        if(withInsert) insert sages;
        return sages;
    }
}
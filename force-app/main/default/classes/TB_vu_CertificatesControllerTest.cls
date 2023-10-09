@IsTest
private with sharing class TB_vu_CertificatesControllerTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';
    private static final String STUDENT_AUTHOR = 'Student';
    private static final String ADMIN_PROFILE = 'System Administrator';
    private static final String ADMIN_ROLE = 'Admin';
    private static final String EXPRESSION_TEST = 'Test';
    private static final String CASE_SUBJECT_CONTRACT = 'Other';
    private static final String CONTENT_VERSION_TITLE = 'Test_Case_Attachment';
    private static final String INVALID_ID_PARAM = 'invalid_id';
    private static final String STUDENT_CERTIFICATE_RECORD_TYPE = 'TB_Student_Certificate_HE';
    private static final String VIRTUAL_UNIVERSITY_ORIGIN = 'Virtual_University';
    private static final String CONTENT_VERSION_CATEGORY = 'Student_Certificate';
    private static final String STUDY_CERTIFICATE_CATEGORY = 'Study_Certificate';
    private static final String AUTOMATICALLY_GENERATED_CREATION_METHOD = 'Automatically_Generated';
    private static final String REQUEST_FOR_CERTIFIACTE_CASE_CREATION_METHOD = 'Request_For_Certificate';
    private static final String TRADITIONAL_POST_DELIVETY_METHOD = 'Traditional_Post';
    private static final String LANG_PL = 'PL';
    private static final String MOBILE_TEST = '123456789';
    private static final String INTEGRATED_MASTER_LEVEL_OF_STUDIES = 'Integrated_Master';

    @TestSetup
    static void setupMethod() {
        TB_StaticTest.setDoNotRunTriggers();
        System.runAs(TB_DataFactory.createUser(ADMIN_PROFILE, ADMIN_ROLE, false)) {
            Contact contact = new Contact(LastName = USER_LAST_NAME);
            insert contact;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(STUDENT_CERTIFICATE_RECORD_TYPE).getRecordTypeId();
            Case c = new Case(ContactId = contact.Id);
            c.Subject = CASE_SUBJECT_CONTRACT;
            c.TB_Category__c = STUDY_CERTIFICATE_CATEGORY;
            c.RecordTypeId = recordTypeId;
            c.Origin = VIRTUAL_UNIVERSITY_ORIGIN;
            insert c;
            ContentVersion version = TB_TestDataFactory.createContentVersion(
                false, 
                CONTENT_VERSION_TITLE, 
                CONTENT_VERSION_TITLE + '.pdf', 
                EXPRESSION_TEST);
            version.TB_Category__c = CONTENT_VERSION_CATEGORY;
            insert version;
            ContentDocumentLink contentDocumentLink = TB_TestDataFactory.createContentDocumentLink(
                true,
                [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :version.Id]
                .ContentDocumentId,
                c.Id
            );
            insert new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Author__c = STUDENT_AUTHOR, TB_Publish__c = true);
            insert new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Author__c = STUDENT_AUTHOR, TB_Publish__c = true);
            User u = TB_DataFactory.createUser(SWPS_STUDENT_PROFILE, false);
            u.FirstName = EXPRESSION_TEST;
            u.LastName = USER_LAST_NAME;
            u.ContactId = contact.Id;
            Integer maxRetries = 3;
            Integer retries = 0;
            while (retries < maxRetries) {
                try {
                    insert u;
                    break;
                } catch (Exception e) {
                    retries++;
                    TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CertificatesControllerTest.class.getName(),e.getStackTraceString(),'');
                }
            }
            contact.TB_User__c = u.Id;
            update contact;
            hed__Program_Enrollment__c peToInsert = new hed__Program_Enrollment__c(
                hed__Contact__c = contact.Id,
                DT_Level_Of_Studies__c = INTEGRATED_MASTER_LEVEL_OF_STUDIES,
                hed__Start_Date__c = Date.today()
            );
            insert peToInsert;
            TB_SS_Program_Enrollment_Setting__c customSetting = new TB_SS_Program_Enrollment_Setting__c();
            customSetting.TB_Days_Before_Enrollment_Start_Day__c = 0;
            insert customSetting;
        }
    }

    static TB_vu_CertificatesController.CertificateParameters returnCertificateParameters(){
        TB_vu_CertificatesController.DeliveryDataWrapper deliveryParameters = new TB_vu_CertificatesController.DeliveryDataWrapper();
        deliveryParameters.addressName = EXPRESSION_TEST;
        deliveryParameters.street = EXPRESSION_TEST;
        deliveryParameters.city = EXPRESSION_TEST;
        deliveryParameters.postalCode = EXPRESSION_TEST;
        deliveryParameters.country = LANG_PL;
        deliveryParameters.mobile = MOBILE_TEST;
        TB_vu_CertificatesController.CertificateParameters parameters = new TB_vu_CertificatesController.CertificateParameters();
        parameters.category = STUDY_CERTIFICATE_CATEGORY;
        parameters.description = EXPRESSION_TEST;
        parameters.creationMethod = AUTOMATICALLY_GENERATED_CREATION_METHOD;
        parameters.contactId = '';
        parameters.studyNameId = '';       
        parameters.methodOfDelivery ='';
        parameters.deliveryData = deliveryParameters;

        return parameters;
    }

    @IsTest
    static void shouldReturnCaseConnectedToContact() {
        Contact contact = [SELECT Id FROM Contact WHERE LastName =: USER_LAST_NAME];

        Test.startTest();
        List<Case> cases = TB_vu_CertificatesController.fetchCases(contact.Id);
        Test.stopTest();

        System.assertEquals(1, cases.size());
    }

    @IsTest
    static void shouldReturnAllCertificateFormsMetadata() {
        Map<String, TB_Certificate_Form__mdt> result;

        Test.startTest();
        result = TB_vu_CertificatesController.getCertificateFormsMetadata();
        Test.stopTest();

        System.assert(result.size() > 0);
    }

    @IsTest
    static void shouldReturnStudyNames(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id FROM Contact WHERE LastName =: USER_LAST_NAME];
        List<TB_vu_CertificatesController.StudyNameWrapper> result = new List<TB_vu_CertificatesController.StudyNameWrapper>();

        Test.startTest();
        System.runAs(user){
            result = TB_vu_CertificatesController.getStudyNames(LANG_PL, contact.Id);
        }
        Test.stopTest();

        System.assert(result.size() > 0 , true);
    }

    @IsTest
    static void shouldAutomaticallyGenerateCertificateAndReturnDocumentId(){
        Contact contact = [SELECT Id FROM Contact WHERE LastName =: USER_LAST_NAME LIMIT 1];
        TB_vu_CertificatesController.CertificateParameters parameters = returnCertificateParameters();
        parameters.contactId = contact.Id;
        parameters.studyNameId = TB_vu_CertificatesController.getStudyNames(LANG_PL, contact.Id)[0].id;
        List<Id> result;
        Test.startTest();
            result = TB_vu_CertificatesController.createCertificate(parameters);
        Test.stopTest();

        System.assert(result.size() == 1, true);
    }

    @IsTest
    static void shouldSendRequestForCertificateWithTraditionalPostDeliveryAndReturnCaseAndOperationId(){
        Contact contact = [SELECT Id FROM Contact WHERE LastName =: USER_LAST_NAME LIMIT 1];
        TB_vu_CertificatesController.CertificateParameters parameters = returnCertificateParameters();
        parameters.contactId = contact.Id;
        parameters.studyNameId = TB_vu_CertificatesController.getStudyNames(LANG_PL, contact.Id)[0].id;
        parameters.creationMethod = REQUEST_FOR_CERTIFIACTE_CASE_CREATION_METHOD;
        parameters.methodOfDelivery = TRADITIONAL_POST_DELIVETY_METHOD;
        List<Id> result;
        Test.startTest();
            result = TB_vu_CertificatesController.createCertificate(parameters);
        Test.stopTest();

        System.assert(result.size() == 2 , true);
    }

    @IsTest
    static void throwAnError_whenInvalidParametersPassedToCreateCertificate(){
        TB_vu_CertificatesController.CertificateParameters parameters = returnCertificateParameters();
        parameters.contactId = INVALID_ID_PARAM;
        parameters.studyNameId = INVALID_ID_PARAM;
        parameters.creationMethod = INVALID_ID_PARAM;
        parameters.methodOfDelivery = INVALID_ID_PARAM;
        List<Id> result;
        
        Boolean isException = false;
        Test.startTest();
        try {
            result = TB_vu_CertificatesController.createCertificate(parameters);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    static void throwAnError_whenInvalidContactIdIsPassedToFetchCases() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_CertificatesController.fetchCases(INVALID_ID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    static void shouldFetchCaseCommentsConnectedToCase() {
        Case c = [SELECT Id FROM Case];

        Test.startTest();
        List<TB_vu_CertificatesController.CommentWrapper> comments = TB_vu_CertificatesController.fetchCaseComments(c.Id);
        Test.stopTest();

        System.assertEquals(2, comments.size());
    }

    @IsTest
    static void throwAnError_whenInvalidCaseIdIsPassedToFetchCaseComments() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_CertificatesController.fetchCaseComments(INVALID_ID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    static void shouldReturnCaseWrappersConnectedToContact() {
        Contact contact = [SELECT Id FROM Contact];

        Test.startTest();
        List<TB_vu_CertificatesController.CaseWrapper> wrappers = TB_vu_CertificatesController.fetchCaseWrappers(contact.Id);
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
    }

    @IsTest
    static void shouldReturnCaseWrappersWithFileAttachedToCase() {
        Contact contact = [SELECT Id FROM Contact];
        Case c = [SELECT Id, Status, TB_Decision_Issued__c FROM Case LIMIT 1];
        c.Status = 'Closed';
        c.TB_Decision_Issued__c = true;
        update c;

        Test.startTest();
        List<TB_vu_CertificatesController.CaseWrapper> wrappers = TB_vu_CertificatesController.fetchCaseWrappers(contact.Id);
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
    }
}
@isTest
private class TB_vu_CasesControllerTest {
    private static final String EXPRESSION_TEST = 'Test';
    private static final String CASE_SUBJECT_CONTRACT = 'Contract';
    private static final String CATEGORY_EXAMPLE = 'Finances';
    private static final String SUBCATEGORY_EXAMPLE = 'Invoices';
    private static final String RECORD_TYPE_DEVELOPER_NAME = 'TB_Student_Question_HE';
    private static final String LANG_PL = 'PL';
    private static final String INTEGRATED_MASTER_LEVEL_OF_STUDIES = 'Integrated_Master';

    @TestSetup
    static void setupMethod() {
        List<Account> acc = TB_TestDataFactory.createAccounts(1, TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID, true);

        Contact contact = TB_TestDataFactory.createContact(false);
        contact.TB_User__c = UserInfo.getUserId();
        contact.accountId = acc[0].Id;
        insert contact;

        Case c = new Case(ContactId = contact.Id);
        c.Subject = CASE_SUBJECT_CONTRACT;
        insert c;

        TB_SS_Program_Enrollment_Setting__c customSetting = new TB_SS_Program_Enrollment_Setting__c();
        customSetting.TB_Days_Before_Enrollment_Start_Day__c = 0;
        insert customSetting;

        hed__Program_Enrollment__c programToInsert = new hed__Program_Enrollment__c(
            hed__Contact__c = contact.Id,
            DT_Level_Of_Studies__c = INTEGRATED_MASTER_LEVEL_OF_STUDIES,
            hed__Start_Date__c = Date.today()
        );
        insert programToInsert;

        insert new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);
        insert new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);
    }

    @isTest
    static void shouldReturnRecordTypeId(){
        String result;
        Test.startTest();
        result = TB_vu_CasesController.getRecordTypeId(RECORD_TYPE_DEVELOPER_NAME);
        Test.stopTest();

        System.assertEquals(true, result.length() > 0,'Size doesnt match with expected value');
    }

    @isTest
    static void throwAnErrorOn_PassingInvalidDeveloperName(){
        Boolean errorOccurred = false;
        String result;

        Test.startTest();
        try {
            result = TB_vu_CasesController.getRecordTypeId('INVALID');
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        System.assertEquals(true, errorOccurred, 'Query should return exception');
    }

    @IsTest
    static void shouldSendCase(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        hed__Program_Enrollment__c programEnrollment = [SELECT Id, hed__Contact__c
            FROM hed__Program_Enrollment__c
            WHERE hed__Contact__c =: contact.Id LIMIT 1];

        TB_vu_CasesController.CaseParameters caseParameters = new TB_vu_CasesController.CaseParameters();
        caseParameters.category = CATEGORY_EXAMPLE;
        caseParameters.subcategory = SUBCATEGORY_EXAMPLE;
        caseParameters.studyNameId = programEnrollment.Id;
        caseParameters.subject = 'subject';
        caseParameters.description = 'description';
        caseParameters.language = LANG_PL;
        caseParameters.recordTypeId = TB_vu_CasesController.getRecordTypeId(RECORD_TYPE_DEVELOPER_NAME);
        caseParameters.contactId = contact.Id;

        Test.startTest();
        System.runAs(user){
           result = TB_vu_CasesController.sendCase(caseParameters);
        }
        Test.stopTest();

        System.assertEquals(true, result.size() == 2,'Size doesnt match with expected value');

    }

    @IsTest
    static void shouldReturnStudyNames(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<TB_vu_CasesController.StudyNameWrapper> result = new List<TB_vu_CasesController.StudyNameWrapper>();

        Test.startTest();
        System.runAs(user){
            result = TB_vu_CasesController.getStudyNames(LANG_PL, contact.Id);
        }
        Test.stopTest();

        System.assert(result.size() > 0 , true);
    }

    @isTest
    static void throwAnErrorOn_PassingInvalidDataToSendCase(){
        Boolean errorOccurred = false;
        List<String> result;

        TB_vu_CasesController.CaseParameters caseParameters = new TB_vu_CasesController.CaseParameters();
        caseParameters.category = 'INVALID';
        caseParameters.subcategory = 'INVALID';
        caseParameters.studyNameId = 'INVALID';
        caseParameters.subject = 'INVALID';
        caseParameters.description = 'INVALID';
        caseParameters.language = 'INVALID';
        caseParameters.recordTypeId = 'INVALID';
        caseParameters.contactId = 'INVALID';

        Test.startTest();
        try {
            result = TB_vu_CasesController.sendCase(caseParameters);
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        System.assertEquals(true, errorOccurred, 'Query should return exception');
    }
}

@isTest
private class TB_vu_ApplicationAppealControllerTest {
    private static final String APPLICATION_APPEAL_DESCRIPTION = '<p>Test</p>';
    private static final String APPLICATION_APPEAL_CATEGORY = 'Finances';
    private static final String APPLICATION_APPEAL_SUBCATEGORY = 'Change_of_the_payment_system';
    private static final String APPLICATION_APPEAL_TYPE = 'Decision';
    private static final String INVALID_PARAMETER = 'INVALID';

    @TestSetup
    static void testSetup(){
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c(
            DT_Campus__c = 'Ka'
        );
        insert pe;

        Contact contact = TB_TestDataFactory.createContact(true);

        Case c = new Case(
            TB_Category__c = APPLICATION_APPEAL_CATEGORY,
            TB_Subcategory__c = APPLICATION_APPEAL_SUBCATEGORY,
            TB_Program_Enrollment__c = pe.Id,
            Subject = APPLICATION_APPEAL_CATEGORY + ' ' + APPLICATION_APPEAL_SUBCATEGORY,
            TB_Description_Rich_Text__c = APPLICATION_APPEAL_DESCRIPTION,
            Language = 'PL',
            ContactId = contact.Id,
            RecordTypeId = TB_vu_CasesController.getRecordTypeId('TB_Student_Application_HE')
        );
        insert c;

        TB_Operation__c operation = new TB_Operation__c(
            TB_Type__c = APPLICATION_APPEAL_TYPE,
            TB_Description_Rich_Text__c = APPLICATION_APPEAL_DESCRIPTION,
            TB_Case__c = c.Id
        );
        insert operation;
    }

    @isTest 
    static void shouldSendApplicationAppeal(){
        TB_Operation__c operation = [SELECT Id, TB_Type__c, TB_Case__c FROM TB_Operation__c WHERE TB_Type__c = 'Decision'];
        
        Test.startTest();
        TB_vu_ApplicationAppealController.sendApplicationAppeal(operation.Id, APPLICATION_APPEAL_DESCRIPTION);
        Test.stopTest();
        
        Case caseAppeal = [SELECT Id, Parent.TB_Appeal__c, TB_Appeal__c FROM Case WHERE TB_Appeal__c = true AND ParentId =: operation.TB_Case__c];

        System.assert(caseAppeal.TB_Appeal__c, 'Query couldnt find case with TB_Appeal = true');
        System.assert(caseAppeal.Parent.TB_Appeal__c, 'Parent case should have TB_Appeal = true');
        System.assert([SELECT Id, TB_Case__c FROM TB_Operation__c WHERE TB_Case__c =: caseAppeal.Id].size() > 0, 'Should return TB_Operation record');
    }

    @isTest 
    static void throwAnError_whenInvalidParametersPassedToApplicationAppeal(){
        Boolean errorOccured = false;
    
        Test.startTest();
        try {
            TB_vu_ApplicationAppealController.sendApplicationAppeal(INVALID_PARAMETER,INVALID_PARAMETER);
        } catch (Exception e) {
            errorOccured = true;
        }
        Test.stopTest();
        
        System.assert(errorOccured);
    }

    @isTest 
    static void shouldGetApplicationComment(){
        TB_Operation__c operation = [SELECT Id, TB_Description_Rich_Text__c, TB_Type__c FROM TB_Operation__c WHERE TB_Type__c = 'Decision'];
        String result;

        Test.startTest();
        result = TB_vu_ApplicationAppealController.getApplicationComment(operation.Id);
        Test.stopTest();
        
        System.assertEquals(result, '<p>Test</p>', 'Result doesnt match with expected value');
    }

    @isTest 
    static void throwAnError_whenInvalidParametersPassedToGetApplicationComment(){
        Boolean errorOccured = false;
    
        Test.startTest();
        try {
            TB_vu_ApplicationAppealController.getApplicationComment(INVALID_PARAMETER);
        } catch (Exception e) {
            errorOccured = true;
        }
        Test.stopTest();
        
        System.assert(errorOccured);
    }
}
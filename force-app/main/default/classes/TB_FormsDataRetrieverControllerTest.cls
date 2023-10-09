@IsTest
private with sharing class TB_FormsDataRetrieverControllerTest {
    @TestSetup
    private static void testSetup() {
        TB_Admissions_Content__c admissionsContent = TB_TestDataFactory.createAdmissionsContent(true, 'code1', 'Exception', 'Warning');
    }

    @IsTest
    private static void getAdmissionsContentTest() {
        Test.startTest();
        Map<String, TB_FormsDataRetrieverController.AdmissionsContentWrapper> recordCodeToWrappers = TB_FormsDataRetrieverController.getAdmissionsContent();
        Test.stopTest();

        System.assertEquals(1, recordCodeToWrappers.size());
        System.assert(recordCodeToWrappers.keySet().contains('code1'));
        System.assertEquals('warning', recordCodeToWrappers.values()[0].contentType);
        System.assertEquals('MODAL.HEADER.WARNING', recordCodeToWrappers.values()[0].header);
    }
}
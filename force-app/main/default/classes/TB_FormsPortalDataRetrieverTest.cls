@IsTest
private without sharing class TB_FormsPortalDataRetrieverTest {
    @TestSetup
    private static void testSetup() {
        TB_Admissions_Content__c admissionsContent_1 = TB_TestDataFactory.createPortalContent(true, 'code1', 'Translations', 'Information');
        TB_Admissions_Content__c admissionsContent_2 = TB_TestDataFactory.createPortalContent(true, 'code2', 'Exception', 'Warning');
    }
    @IsTest
    private static void getPortalContentTest() {
        Map<String, TB_FormsPortalDataRetrieverController.PortalContentWrapper> recordCodeToWrappers_1 = new Map<String, TB_FormsPortalDataRetrieverController.PortalContentWrapper>();
        Map<String, TB_FormsPortalDataRetrieverController.PortalContentWrapper> recordCodeToWrappers_2 = new Map<String, TB_FormsPortalDataRetrieverController.PortalContentWrapper>();

        Test.startTest();
        recordCodeToWrappers_1 = TB_FormsPortalDataRetrieverController.getAllPortalContent();
        recordCodeToWrappers_2 = TB_FormsPortalDataRetrieverController.getPortalContent(null);
        Test.stopTest();

        System.assertEquals(2, recordCodeToWrappers_1.size());
        System.assert(recordCodeToWrappers_1.keySet().contains('code1'));
        System.assertEquals('Translations', recordCodeToWrappers_1.values()[0].contentType);
        System.assertEquals('MODAL.HEADER.INFO', recordCodeToWrappers_1.values()[0].header);

        System.assertEquals(2, recordCodeToWrappers_2.size());
        System.assert(recordCodeToWrappers_2.keySet().contains('code2'));
        System.assertEquals('Exception', recordCodeToWrappers_2.values()[1].contentType);
        System.assertEquals('MODAL.HEADER.WARNING', recordCodeToWrappers_2.values()[1].header);

    }
}
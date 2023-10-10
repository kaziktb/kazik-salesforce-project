/**
 * Created by Aneta on 26/06/2023.
 */

@IsTest
private class TB_KReMDictionaryContSchedulableTest {
    @TestSetup
    static void testSetup() {
       TB_re_TestDataFactory.createHSExamSubjectDictionary(true);
    }

    @IsTest
    static void testGeneratePdfInvoicesPositive() {
        Test.setMock(HttpCalloutMock.class, new TB_KReMSIOIntegratorMock('sheetsPositive'));
        Test.startTest();
        TB_KReMDictionaryControllerSchedulable integrationKReMSchedulable = new TB_KReMDictionaryControllerSchedulable();
        String chron = '0 0 23 * * ?';
        System.schedule('Test Sched', chron, integrationKReMSchedulable);
        Test.stopTest();
    }

    @IsTest
    static void testGeneratePdfInvoicesNegative() {
        Test.setMock(HttpCalloutMock.class, new TB_KReMSIOIntegratorMock('error'));
        Test.startTest();
        TB_KReMDictionaryControllerSchedulable integrationKReMSchedulable = new TB_KReMDictionaryControllerSchedulable();
        String chron = '0 0 23 * * ?';
        System.schedule('Test Sched', chron, integrationKReMSchedulable);
        Test.stopTest();
    }


}
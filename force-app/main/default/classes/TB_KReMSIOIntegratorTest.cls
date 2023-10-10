/**
 * Created by Aneta on 29/06/2023.
 */

@IsTest
private class TB_KReMSIOIntegratorTest {
    @IsTest
    static void testGetResultCodesPositive() {
        List<TB_KReM_Response_Code__mdt> resultCodeObjects = TB_KReM_Response_Code__mdt.getAll().values();
        Test.startTest();
        Map<Integer, String> results = TB_KReMSIOIntegrator.getResultCodes();
        Test.stopTest();
        System.assertEquals(resultCodeObjects.size(), results.size());
    }

    @IsTest
    static void testGetResultsForLWC() {
        Test.setMock(HttpCalloutMock.class, new TB_KReMSIOIntegratorMock('resultsPositive'));
        Test.startTest();
        String result =  TB_KReMSIOIntegrator.getRetrievedResults(new List<String> {'66666666666'}, true);
        Test.stopTest();

        TB_KReMSIOIntegrator.Body body = (TB_KReMSIOIntegrator.Body) JSON.deserialize(result, TB_KReMSIOIntegrator.Body.class);
        System.assertEquals(0, body.responseCode);
        System.assertEquals('Ok', body.responseCodeDetail);
        System.assertEquals(true, body.responses != null);
    }

    @IsTest
    static void testGetResultsNotForLWC() {
        Test.setMock(HttpCalloutMock.class, new TB_KReMSIOIntegratorMock('resultsPositive'));
        Test.startTest();
        String result = TB_KReMSIOIntegrator.getRetrievedResults(new List<String> {'66666666666'}, false);
        Test.stopTest();
        TB_KReMSIOIntegrator.Body body = (TB_KReMSIOIntegrator.Body) JSON.deserialize(result, TB_KReMSIOIntegrator.Body.class);
        System.assertEquals(0, body.responseCode);
        System.assertEquals('Ok', body.responseCodeDetail);
        System.assertEquals(true, body.responses != null);
    }

    @IsTest
    static void testGetSheets() {
        Test.setMock(HttpCalloutMock.class, new TB_KReMSIOIntegratorMock('sheetsPositive'));
        Test.startTest();
        List<TB_KReMSIOIntegrator.SubjectWrapper> result = TB_KReMSIOIntegrator.getSheets();
        Test.stopTest();

        System.assertEquals(4, result.size());
    }

    @IsTest
    static void testGetResultsForLWCNegative() {
        Test.setMock(HttpCalloutMock.class, new TB_KReMSIOIntegratorMock('resultsNegative'));
        Test.startTest();
        String result = TB_KReMSIOIntegrator.getRetrievedResults(new List<String> {'66666666666'}, false);
        Test.stopTest();
        System.assertEquals(true, result.startsWith(TB_re_Constants.ERROR_OCCURRED));
    }
}
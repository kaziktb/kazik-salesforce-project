/**
 * Created by Aneta on 10/12/2021.
 */
@IsTest
private class TB_UserLocationControllerTest {

    @IsTest
    private static void checkIsAllowedCountry() {
        String checkResult;
        Test.startTest();
        checkResult = TB_UserLocationController.checkIsAllowedCountry();
        Test.stopTest();
        System.assertEquals('ALLOW', checkResult);
    }
    
    @IsTest
    private static void getCountryByIp() {
        Test.startTest();
        String checkResult = TB_UserLocationController.getCountryByIp('89.64.78.128');
        Test.stopTest();
        System.assertEquals('ALLOW', checkResult);
    }

    @IsTest
    private static void getCountryByIpNegative() {
        Test.startTest();
        String checkResult = TB_UserLocationController.getCountryByIp('0.0.0.0');
        Test.stopTest();
        System.assertEquals('ALLOW', checkResult);
    }

}
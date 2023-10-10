@isTest
public class TB_RecaptchaValidatorTest{
    @isTest
    static void testRecaptchaValidator() {
        Test.setMock(HttpCalloutMock.class, new TB_RecaptchaHttpCalloutMock()); 
        String result = TB_RecaptchaValidator.validateRequest('test');
        String expectedResult = 'success';
        System.assertEquals(result, expectedResult);
    }
}
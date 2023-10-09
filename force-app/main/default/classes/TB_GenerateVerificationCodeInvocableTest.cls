@IsTest
private class TB_GenerateVerificationCodeInvocableTest {
   @isTest 
   private static void generateCodeTestStandard(){
    TB_GenerateVerificationCodeInvocable.GenerateCodeWrapperClasses testData = new TB_GenerateVerificationCodeInvocable.GenerateCodeWrapperClasses();
    testData.id = '093AWSEFWESFWEFW0239';
    testData.isStandard = true;
    testData.sizeOfGeneratedCode = 10;
    List<TB_GenerateVerificationCodeInvocable.GenerateCodeWrapperClasses> inputData = new List<TB_GenerateVerificationCodeInvocable.GenerateCodeWrapperClasses>();
    inputData.add(testData);
    List<TB_GenerateVerificationCodeInvocable.Results> output;
    Test.startTest();
    output = TB_GenerateVerificationCodeInvocable.generateCode(inputData);
    Test.stopTest();
    System.assertEquals(output.get(0).generatedNumber.length(), testData.sizeOfGeneratedCode, 'Generated code length should be equal as defined one');
   }
   @isTest 
   private static void generateCodeTestCustom(){
    TB_GenerateVerificationCodeInvocable.GenerateCodeWrapperClasses testData = new TB_GenerateVerificationCodeInvocable.GenerateCodeWrapperClasses();
    testData.id = '093AWSEFWESFWEFW0239';
    testData.isStandard = false;
    testData.sizeOfGeneratedCode = 10;
    List<TB_GenerateVerificationCodeInvocable.GenerateCodeWrapperClasses> inputData = new List<TB_GenerateVerificationCodeInvocable.GenerateCodeWrapperClasses>();
    inputData.add(testData);
    List<TB_GenerateVerificationCodeInvocable.Results> output;
    Test.startTest();
    output = TB_GenerateVerificationCodeInvocable.generateCode(inputData);
    Test.stopTest();
    System.assertEquals(output.get(0).generatedNumber.length(), testData.sizeOfGeneratedCode, 'Generated code length should be equal as defined one');
    }
}

/**
 * Created by annaseveryna on 30/12/2021.
 */
@IsTest
public with sharing class TB_BankAccountGeneratorTest {
    public static String customerId = '1500122';
    public static List<TB_BankAccountGenerator.FlowInputs> inputs = new List<TB_BankAccountGenerator.FlowInputs>();
    public static TB_BankAccountGenerator.FlowInputs input = new TB_BankAccountGenerator.FlowInputs();

    @IsTest static void generateBankAccountTestPositive() {
        input.customerId = customerId;
        inputs.add(input);

        Test.startTest();
        List<TB_BankAccountGenerator.FlowOutputs> outputs = TB_BankAccountGenerator.invokeGenerateBankAccounts(inputs);
        Test.stopTest();

        System.assertEquals('67109000047551000001500122', outputs[0].bankAccountPLN);
        System.assertEquals('05109000048518100001500122', outputs[0].bankAccountEUR);
    }

    @IsTest static void generateBankAccountTestPositivePlnOneDigitModulo() {
        input.customerId = '1300200';
        inputs.add(input);

        Test.startTest();
        List<TB_BankAccountGenerator.FlowOutputs> outputs = TB_BankAccountGenerator.invokeGenerateBankAccounts(inputs);
        Test.stopTest();

        System.assertEquals('08109000047551000001300200', outputs[0].bankAccountPLN);
        System.assertEquals('43109000048518100001300200', outputs[0].bankAccountEUR);
    }

    @IsTest static void generateBankAccountTestNegativeCustomerId() {
        Boolean isException = false;
        String message = '';

        Test.startTest();
        try {
            TB_BankAccountGenerator.invokeGenerateBankAccounts(null);
        } catch(Exception e) {
            isException = true;
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, isException);
        System.assertEquals('Input is null or empty', message);
    }
}
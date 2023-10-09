/**
 * Created by annaseveryna on 29/12/2021.
 */

public with sharing class TB_BankAccountGenerator {
    private static final String TEMPLATE_PLN = '1090000475510';
    private static final String TEMPLATE_EUR = '1090000485181';
    private static final String COUNTRY_CODE = 'PL';

    @InvocableMethod (label = 'Generate Bank Account' description = 'Returns bank account numbers (in PLN and EUR) corresponding to the customer ID')
    public static List<FlowOutputs> invokeGenerateBankAccounts(List<FlowInputs> inputs) {
        if (inputs == null || inputs.isEmpty()) {
            throw new IllegalArgumentException('Input is null or empty');
        }
        List<FlowOutputs> outputs = new List<FlowOutputs>();
        for (FlowInputs input : inputs) {
            outputs.add(generateBankAccount(input));
        }
        return outputs;
    }

    private static FlowOutputs generateBankAccount(FlowInputs input) {
        if (input.customerId == null || String.isBlank(input.customerId)) {
            throw new IllegalArgumentException('Customer id is not recognized');
        }
        while (input.customerId.length() < 11) {
            input.customerId = '0' + input.customerId;
        }
        String bbanPLN = TEMPLATE_PLN + input.customerId;
        String bbanEUR = TEMPLATE_EUR + input.customerId;
        FlowOutputs output = new FlowOutputs();
        output.bankAccountPLN = controlDigit(bbanPLN) + bbanPLN;
        output.bankAccountEUR = controlDigit(bbanEUR) + bbanEUR;
        return output;
    }

    private static String controlDigit(String bban) {
        String initialIBAN = bban + countryCodeToDigits(COUNTRY_CODE) + '00';
        String moduloResult = findModuloThroughDecimal(initialIBAN, 97);
        Integer controlDigitInt = 98 - Integer.valueOf(moduloResult);
        String controlDigit = String.valueOf(controlDigitInt);
        if (controlDigit.length() == 1) {
            controlDigit = '0' + controlDigit;
        }
        return String.valueOf(controlDigit);
    }

    public static String findModuloThroughDecimal(String initialIBAN, Integer modulo) {
        Decimal decimalNumber = Decimal.valueOf(initialIBAN);
        Decimal numberByModuloDivisionResult = decimalNumber.divide(modulo, 2);
        String wholeDivisionPart = String.valueOf(numberByModuloDivisionResult).split('\\.')[0];
        Decimal divisionResultByModuloMultiplication = Decimal.valueOf(wholeDivisionPart) * modulo;
        Decimal moduloResult = decimalNumber - divisionResultByModuloMultiplication;
        String result = String.valueOf(moduloResult);
        if (result.length() == 1) {
            result = '0' + moduloResult;
        }
        return result;
    }

    private static String countryCodeToDigits(String countryCode) {
        String codeToDigits = '';
        for (String c : countryCode.split('')) {
            codeToDigits += c.getChars()[0] - 55;
        }
        return codeToDigits;
    }

    public class FlowInputs {
        @InvocableVariable
        public String customerId;
    }

    public class FlowOutputs {
        @InvocableVariable
        public String bankAccountPLN;

        @InvocableVariable
        public String bankAccountEUR;
    }
}
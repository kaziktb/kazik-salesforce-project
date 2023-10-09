/**
 * Created by annaseveryna on 09/11/2021.
 */
@IsTest
public with sharing class TB_PeselUtilsTest {
    public static Date birthDate = Date.newInstance(1986, 06, 09);
    public static String salutation = 'Ms';

    @IsTest static void validatePeselPositive() {
        String correctPesel = '86060912640';

        Test.startTest();
        TB_PeselUtils.PeselWrapper pw = TB_PeselUtils.validatePesel(correctPesel, birthDate, salutation);
        Test.stopTest();

        System.assert(pw.valid);
        System.assertEquals('', pw.reason);
    }

    @IsTest static void validatePeselNull() {
        Test.startTest();
        TB_PeselUtils.PeselWrapper pw = TB_PeselUtils.validatePesel(null, birthDate, salutation);
        Test.stopTest();

        System.assert(!pw.valid);
        System.assertEquals('PESEL.MISSING_PARAMETERS', pw.reason);
    }

    @IsTest static void validatePeselContainingLetter() {
        String peselContainingLetter = '8806091264S';

        Test.startTest();
        TB_PeselUtils.PeselWrapper pw = TB_PeselUtils.validatePesel(peselContainingLetter, birthDate, salutation);
        Test.stopTest();

        System.assert(!pw.valid);
        System.assertEquals('PESEL.NOT_NUMERIC', pw.reason);

    }

    @IsTest static void validatePeselWithWrongLength() {
        String peselWithWrongLength = '8806091264';

        Test.startTest();
        TB_PeselUtils.PeselWrapper pw = TB_PeselUtils.validatePesel(peselWithWrongLength, birthDate, salutation);
        Test.stopTest();

        System.assert(!pw.valid);
        System.assertEquals('PESEL.INVALID_LENGTH', pw.reason);
    }

    @IsTest static void validatePeselWithWrongYear() {
        String peselWithWrongYear = '88060912640';

        Test.startTest();
        TB_PeselUtils.PeselWrapper pw = TB_PeselUtils.validatePesel(peselWithWrongYear, birthDate, salutation);
        Test.stopTest();

        System.assert(!pw.valid);
        System.assertEquals('PESEL.INVALID_BIRTH_YEAR', pw.reason);
    }

    @IsTest static void validatePeselWithWrongMonth() {
        String peselWithWrongMonth = '86090912640';

        Test.startTest();
        TB_PeselUtils.PeselWrapper pw = TB_PeselUtils.validatePesel(peselWithWrongMonth, birthDate, salutation);
        Test.stopTest();

        System.assert(!pw.valid);
        System.assertEquals('PESEL.INVALID_BIRTH_MONTH', pw.reason);
    }

    @IsTest static void validatePeselWithWrongDay() {
        String peselWithWrongDate = '86060112640';

        Test.startTest();
        TB_PeselUtils.PeselWrapper pw = TB_PeselUtils.validatePesel(peselWithWrongDate, birthDate, salutation);
        Test.stopTest();

        System.assert(!pw.valid);
        System.assertEquals('PESEL.INVALID_BIRTH_DAY', pw.reason);
    }

    @IsTest static void validatePeselWithWrongGender() {
        String peselWithWrongGender = '86060912650';

        Test.startTest();
        TB_PeselUtils.PeselWrapper pw = TB_PeselUtils.validatePesel(peselWithWrongGender, birthDate, salutation);
        Test.stopTest();

        System.assert(!pw.valid);
        System.assertEquals('PESEL.INVALID_GENDER', pw.reason);
    }

    @IsTest static void validatePeselWithWrongControlNumber() {
        String peselWithWrongControlNumber = '86060912643';

        Test.startTest();
        TB_PeselUtils.PeselWrapper pw = TB_PeselUtils.validatePesel(peselWithWrongControlNumber, birthDate, salutation);
        Test.stopTest();

        System.assert(!pw.valid);
        System.assertEquals('PESEL.INVALID_CONTROL_NUMBER', pw.reason);
    }
}
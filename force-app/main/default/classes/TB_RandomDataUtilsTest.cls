@isTest
public class TB_RandomDataUtilsTest {
    @isTest
    private static void testGenerateRandomText() {
        String text1;
        String text2;
        String text3;
        Test.startTest();
        text1 = TB_RandomDataUtils.generateRandomText(10);
        text2 = TB_RandomDataUtils.generateRandomText(10);
        text3 = TB_RandomDataUtils.generateRandomText(10);
        Test.stopTest();

        System.assertNotEquals(text1, text2, 'Generated texts should be different');
        System.assertNotEquals(text1, text3, 'Generated texts should be different');
        System.assertNotEquals(text2, text3, 'Generated texts should be different');
    }

    @isTest
    private static void testGenerateRandomNumber() {
        String number1;
        String number2;
        String number3;
        Test.startTest();
        number1 = TB_RandomDataUtils.generateRandomNumber(10);
        number2 = TB_RandomDataUtils.generateRandomNumber(10);
        number3 = TB_RandomDataUtils.generateRandomNumber(10);
        Test.stopTest();

        System.assertNotEquals(number1, number2, 'Generated numbers should be different');
        System.assertNotEquals(number1, number3, 'Generated numbers should be different');
        System.assertNotEquals(number2, number3, 'Generated numbers should be different');
    }

    @isTest
    private static void testGenerateUUID() {
        String text1;
        String text2;
        String text3;
        Test.startTest();
        text1 = TB_RandomDataUtils.generateUUID();
        text2 = TB_RandomDataUtils.generateUUID();
        text3 = TB_RandomDataUtils.generateUUID();
        Test.stopTest();

        System.assertNotEquals(text1, text2, 'Generated texts should be different');
        System.assertNotEquals(text1, text3, 'Generated texts should be different');
        System.assertNotEquals(text2, text3, 'Generated texts should be different');
    }

    @isTest
    private static void testGenerateRandomPassword() {
        String number1;
        String number2;
        String number3;
        Test.startTest();
        number1 = TB_RandomDataUtils.generatePassword(10,10,10);
        number2 = TB_RandomDataUtils.generatePassword(10,10,10);
        number3 = TB_RandomDataUtils.generatePassword(10,10,10);
        Test.stopTest();

        System.assertNotEquals(number1, number2, 'Generated numbers should be different');
        System.assertNotEquals(number1, number3, 'Generated numbers should be different');
        System.assertNotEquals(number2, number3, 'Generated numbers should be different');

    }
}

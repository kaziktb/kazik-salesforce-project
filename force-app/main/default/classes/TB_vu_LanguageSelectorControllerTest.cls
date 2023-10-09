@IsTest
private class TB_vu_LanguageSelectorControllerTest {
    static final String PL_LANG = 'pl';

    @TestSetup
    static void testSetup() {
        User user = TB_TestDataFactory.createUser(TB_TestDataFactory.SYSTEM_ADMINISTRATOR, false);
        insert user;
    }

    @IsTest
    static void shouldReturnUser_onCorrectLangLocaleKeyPassed() {
        //given
        User user = [SELECT Id, LanguageLocaleKey FROM User WHERE Email LIKE 'puser%' LIMIT 1];

        //when
        System.runAs(user) {
            Test.startTest();
            TB_vu_LanguageSelectorController.changeLang(PL_LANG);
            Test.stopTest();
        }

        //then
        user = [SELECT Id, LanguageLocaleKey FROM User WHERE Email LIKE 'puser%' LIMIT 1];
        System.assertEquals(PL_LANG, user.LanguageLocaleKey, 'Should return predefined language key');
    }

    @IsTest
    static void shouldThrowAnError_onWrongLangLocaleKeyPassed() {
        //given
        User user = [SELECT Id, LanguageLocaleKey FROM User WHERE Email LIKE 'puser%' LIMIT 1];
        Boolean error = false;

        //when
        System.runAs(user) {
            Test.startTest();
            try {
                TB_vu_LanguageSelectorController.changeLang('xyz');
            } catch (Exception e) {
                error = true;
            }
            Test.stopTest();
        }

        //then
        System.assert(error, 'Should return an aura exception');
    }
}
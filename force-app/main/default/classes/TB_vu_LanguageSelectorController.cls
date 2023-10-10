public with sharing class TB_vu_LanguageSelectorController {
    @AuraEnabled
    public static void changeLang(String lang) {
        try {
            update new User(Id = UserInfo.getUserId(), LanguageLocaleKey = lang);
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_LogUtils.prepareAuraLog(
                    e.getMessage(),
                    TB_vu_LanguageSelectorController.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }
}
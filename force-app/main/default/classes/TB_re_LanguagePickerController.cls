public with sharing class TB_re_LanguagePickerController {
    @AuraEnabled
    public static void changeLang(String lang) {
        try {
            update new User(Id = UserInfo.getUserId(), LanguageLocaleKey = lang);
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_LogUtils.prepareAuraLog(
                    e.getMessage(),
                    TB_re_LanguagePickerController.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }
}
public without sharing class TB_TranslatePickerInv {
    @InvocableMethod(Label = 'getTranslatedValue')
    public static List<String> getLabel(List<Requests> params) {
        PageReference r = Page.TB_TranslatePickerValue;
        r.getParameters().put(TB_TranslatePickerController.PARAM_LANG, params.get(0).language);
        r.getParameters().put(TB_TranslatePickerController.PARAM_FIELD_API_NAME, params.get(0).fieldApiName);
        r.getParameters().put(TB_TranslatePickerController.PARAM_API_VALUE, params.get(0).apiValue);
        r.getParameters().put(TB_TranslatePickerController.PARAM_OBJECT_API_NAME, params.get(0).objectApiName);
        List<String> returnValue = new List<String>{
                Test.isRunningTest() ? TB_TranslatePickerController.TEST_RETURN_VALUE_PL : r.getContent().toString()
        };
        return returnValue;
    }

    public class Requests {
        @InvocableVariable public String apiValue;
        @InvocableVariable public String fieldApiName;
        @InvocableVariable public String language;
        @InvocableVariable public String objectApiName;
    }
}
public without sharing class TB_TranslatePickerController {
    public static final String PARAM_API_VALUE = 'apiValue';
    public static final String PARAM_FIELD_API_NAME = 'fieldApiName';
    public static final String PARAM_LANG = 'lang';
    public static final String PARAM_OBJECT_API_NAME = 'objectApiName';

    public static final String TEST_RETURN_VALUE_PL = 'TEST_PL';

    public String apiValue {get;set;}
    public String fieldApiName {get;set;}
    public String language { get; set; }
    public String objectApiName {get;set;}

    public TB_TranslatePickerController(){
        this.apiValue = ApexPages.currentPage().getParameters().get(PARAM_API_VALUE);
        this.fieldApiName = ApexPages.currentPage().getParameters().get(PARAM_FIELD_API_NAME);
        this.language = ApexPages.currentPage().getParameters().get(PARAM_LANG);
        this.objectApiName = ApexPages.currentPage().getParameters().get(PARAM_OBJECT_API_NAME);
    }

    public String getFieldValue() {
        String returnValue = apiValue;
        List<Schema.PicklistEntry> picklistValues = Schema.getGlobalDescribe().get(objectApiName).
                getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pe: picklistValues) {
            if (pe.value == apiValue ) {
                returnValue = pe.label;
                break;
            }
        }
        return Test.isRunningTest() ? TEST_RETURN_VALUE_PL : returnValue;
    }
    public String getLanguage(){
        return language;
    }


}
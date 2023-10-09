@IsTest
private class TB_TranslatePickerInvTest {
    final static String LANG_PL = 'pl';
    final static String FIELD_API_NAME_ACC_SOURCE = 'AccountSource';
    final static String OBJECT_API_NAME_ACC_SOURCE = 'Account';
    final static String API_VALUE_TEST = 'test';

    @IsTest
    private static void shouldReturnCorrectTranslation (){
        //given
        List<TB_TranslatePickerInv.Requests> paramList = new List<TB_TranslatePickerInv.Requests>();
        TB_TranslatePickerInv.Requests params = new TB_TranslatePickerInv.Requests();
        params.language = LANG_PL;
        params.fieldApiName = FIELD_API_NAME_ACC_SOURCE;
        params.objectApiName = OBJECT_API_NAME_ACC_SOURCE;
        params.apiValue = API_VALUE_TEST;
        paramList.add(params);


        //when
        Test.startTest();
       String result= TB_TranslatePickerInv.getLabel(paramList).get(0);
        Test.stopTest();

        //then
        System.assert(TB_TranslatePickerController.TEST_RETURN_VALUE_PL ==  result, 'should return test pl version');
    }

    @IsTest
    private static void shouldReturnValueToPDF(){
        //given
       TB_TranslatePickerController tbTranslatePickerController = new TB_TranslatePickerController();
        tbTranslatePickerController.language = LANG_PL;
        tbTranslatePickerController.fieldApiName = FIELD_API_NAME_ACC_SOURCE;
        tbTranslatePickerController.objectApiName = OBJECT_API_NAME_ACC_SOURCE;
        tbTranslatePickerController.apiValue = API_VALUE_TEST;

        //when
        Test.startTest();
        String result = tbTranslatePickerController.getFieldValue();
        Test.stopTest();

        //when
        System.assert(TB_TranslatePickerController.TEST_RETURN_VALUE_PL ==  result, 'should return test pl version');
    }
}
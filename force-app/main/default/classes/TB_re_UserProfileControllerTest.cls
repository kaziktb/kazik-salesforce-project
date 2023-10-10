@IsTest
private class TB_re_UserProfileControllerTest {
    @IsTest
    static void getContactTest(){
        Contact result = new Contact();
        Contact contact = new Contact(FirstName = 'Andrew', LastName = 'Test');
        insert contact;
        Id contactId = contact.Id;
        Test.startTest();
        result = TB_re_UserProfileController.getContact(contactId);
        Test.stopTest();
        System.assertEquals('Andrew', result.FirstName);
    }
    @IsTest
    static void getPickListValuesTest(){
        Map<String, TB_StringUtils.PicklistWrapper> result = new Map<String, TB_StringUtils.PicklistWrapper>();
        Test.startTest();
        result = TB_re_UserProfileController.getPicklistValues();
        Test.stopTest();
        System.assertEquals(true, result != null );
    }
    @IsTest
    static void isAnAdultTestNegative(){
        Boolean result;
        Test.startTest();
        result = TB_re_UserProfileController.isAnAdult(null, null, null);
        Test.stopTest();
        System.assertEquals(null,result);
        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }
    @IsTest
    static void isAnAdultTestPositive(){
        Boolean result;
        Test.startTest();
        result = TB_re_UserProfileController.isAnAdult(
            System.today().year() - 19,
            System.today().month(),
            System.today().day()
        );
        Test.stopTest();
        System.assertEquals(true,result);
    }
    @IsTest
    static void getStatesTestPositive(){
        List<TB_Admissions_Dictionary__c> result = new List<TB_Admissions_Dictionary__c>();
        TB_JSON_Wrapper__c testData = new TB_JSON_Wrapper__c(TB_Record_Type_Dev_Name__c = null, TB_Object_Id__c = '1');
        insert testData;
        Test.startTest();
        result = TB_re_UserProfileController.getStates();
        Test.stopTest();
        System.assertEquals(true, result != null);
    }
    @IsTest
    static void getStatesTestNegative(){
        List<TB_Admissions_Dictionary__c> result = new List<TB_Admissions_Dictionary__c>();
        TB_JSON_Wrapper__c testData = new TB_JSON_Wrapper__c(TB_Record_Type_Dev_Name__c = 'TB_Country_State', TB_Object_Id__c = '1' );
        insert testData;
        Test.startTest();
        result = TB_re_UserProfileController.getStates();
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }
    @IsTest
    static void updateContactTestPositive(){
        String result;
        Contact contact = TB_TestDataFactory.createContact(true);
        contact.TB_Company__c = 'test';
        Test.startTest();
        result = TB_re_UserProfileController.updateContact(contact);
        Test.stopTest();
        System.assertEquals('test', contact.TB_Company__c);
        System.assertEquals(null, result);
    }
}
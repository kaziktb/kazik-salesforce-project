@IsTest
private class TB_vu_QMSServiceTest
{
    @IsTest
    static void shouldReturnQMSSettingsWrapper()
    {
        TB_vu_QMS__c customSetting = new TB_vu_QMS__c();
        customSetting.TB_Base_URL__c = 'https://test.com';
        customSetting.TB_Company_Name__c = 'swps';
        insert customSetting;
        
        Test.startTest();
        TB_vu_QMSService.QMSSettingsWrapper wrapper = TB_vu_QMSService.getSettings();
        Test.stopTest();
        
        Assert.isNotNull(wrapper);
        Assert.areEqual('https://test.com',wrapper.baseUrl);
        Assert.areEqual('swps',wrapper.companyName);
    }
    
    @IsTest
    static void shouldReturnAutoFillData()
    {
        Contact testContact = new Contact(FirstName = 'Andrzej', LastName = 'Horse');
        insert testContact;
        Account testAccount = new Account(Name='testAccount',DT_VDO_ID__c = '2137');
        insert testAccount;
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c(hed__Contact__c = testContact.Id, hed__Account__c = testAccount.Id);
        insert pe;
        
        Test.startTest();
        Map<String,String> autoFillMap = TB_vu_QMSService.getAutofillData(new List<Id>{testContact.Id,pe.Id});
        Test.stopTest();
        
        Assert.isNotNull(autoFillMap);
        Assert.areEqual(testContact.FirstName,autoFillMap.get('Imię'));
    }
    
    @IsTest
    static void getAutoFillDataNoRecordId()
    {
        Test.startTest();
        Map<String,String> autoFillMap;
        AuraHandledException ex;
        try
        {
            autoFillMap = TB_vu_QMSService.getAutofillData(new List<Id>());
        }
        catch (AuraHandledException e)
        {
            ex = e;
        }
        Test.stopTest();
        
        Assert.isNull(autoFillMap);
        Assert.isNotNull(ex);
    }
}
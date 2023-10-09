@IsTest
public with sharing class TB_vu_QMSCancelInvocableTest
{
    @IsTest
    static void shouldCancelReservation()
    {
        TB_vu_QMS__c customSetting = new TB_vu_QMS__c();
        customSetting.TB_Base_URL__c = 'https://test.com';
        customSetting.TB_Company_Name__c = 'swps';
        insert customSetting;
        
        Case testCase = new Case(TB_QMS_Reservation__c='testreservationid');
        insert testCase;
    
        TB_vu_QMSMock.positiveResponse = true;
        Test.setMock(HttpCalloutMock.class,new TB_vu_QMSMock());
        
        Test.startTest();
        String exceptionMessage;
        try
        {
            TB_vu_QMSCancelInvocable.cancelReservation(new List<Id> {testCase.Id});
        }
        catch(Exception e)
        {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        List<TB_Log__c> logs = [SELECT Id FROM TB_Log__c];
        Assert.isNull(exceptionMessage);
        Assert.areEqual(0,logs.size());
    }
    @IsTest
    static void shouldNotCancelReservation()
    {
        TB_vu_QMS__c customSetting = new TB_vu_QMS__c();
        customSetting.TB_Base_URL__c = 'https://test.com';
        customSetting.TB_Company_Name__c = 'swps';
        insert customSetting;
        
        Case testCase = new Case(TB_QMS_Reservation__c='testreservationid');
        insert testCase;
    
        TB_vu_QMSMock.positiveResponse = false;
        Test.setMock(HttpCalloutMock.class,new TB_vu_QMSMock());
        
        Test.startTest();
        String exceptionMessage;
        try
        {
            TB_vu_QMSCancelInvocable.cancelReservation(new List<Id> {testCase.Id});
        }
        catch(Exception e)
        {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        List<TB_Log__c> logs = [SELECT Id FROM TB_Log__c];
        Assert.isNotNull(exceptionMessage);
        Assert.areEqual(1,logs.size());
    }
}
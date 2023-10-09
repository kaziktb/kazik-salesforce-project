/**
 * Created by kacperjachowicz on 02/09/2021.
 */
@IsTest
public with sharing class TB_GenericRelatedListControllerTest {
    @TestSetup
    static void createTestData() {
        List<TB_Data_History__c> dataHistories = TB_TestDataFactory.createDataHistories(20, true);
    }
    @IsTest
    static void retrieveRelatedDataTest() {
        Test.startTest();
        List<Object> dataHistories = TB_GenericRelatedListController.retrieveRelatedData(
                'Name,TB_New_Value__c',
                'TB_Data_History__c',
                null,
                'Name!=null',
                'Name'
        );
        Test.stopTest();
        System.assert(dataHistories.size() == 20);
    }
    @IsTest
    static void deleteRelatedDataTest(){
        List<TB_Data_History__c> dataHistories = [SELECT Id,Name FROM TB_Data_History__c];
        List<Id> dataHistoriesIds = new List<Id>();
        for(TB_Data_History__c dataHistory : dataHistories){
            dataHistoriesIds.add(dataHistory.Id);
        }
        System.assert(dataHistories.size() == 20);
        Test.startTest();
        TB_GenericRelatedListController.deleteData(dataHistoriesIds,'TB_Data_History__c');
        Test.stopTest();
        System.assert([SELECT Id,Name FROM TB_Data_History__c].isEmpty());
    }
    @IsTest
    static void retrieveColumnDataTest(){
        Test.startTest();
        String wrapper = TB_GenericRelatedListController.retrieveColumnData('Id,Name','TB_Data_History__c',true,true);
        Test.stopTest();
        System.assert(String.isNotBlank(wrapper));
    }


}
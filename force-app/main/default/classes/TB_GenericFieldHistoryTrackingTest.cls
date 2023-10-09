/**
 * Created by kacperjachowicz on 25/08/2021.
 */
@IsTest
public with sharing class TB_GenericFieldHistoryTrackingTest {

    @TestSetup
    static void testSetup() {
        insert new TB_Marketing_Cloud_API__c(
            TB_Auth_End_Point__c = 'https://test.com',
            TB_POST_End_Point__c = 'https://test.com'
        );
        TB_TestDataFactory.createUser(TB_TestDataFactory.SYSTEM_ADMINISTRATOR, true);
        TB_TestDataFactory.createApplicationWithRelatedObjects(true);
    }

    @IsTest
    static void setFieldHistoryTrackingTest(){
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        hed__Application__c application = [SELECT Id,Name, hed__Application_Status__c FROM hed__Application__c];
        List<TB_Data_History__c> dataHistories = [SELECT Id FROM TB_Data_History__c WHERE TB_Record_Id__c = :application.Id];
        System.assert(dataHistories.size() == 0);

        Test.startTest();
        application.hed__Application_Status__c = 'Verified';
        update application;
        Test.stopTest();

        TB_Data_History__c dataHistoryUpdateStatus = [
            SELECT Id,TB_Field__c,TB_Object__c,TB_Record_Name__c,TB_Field_Label__c,TB_Object_Label__c
            FROM TB_Data_History__c
            WHERE TB_Record_Id__c = :application.Id
        ];
        System.assert(dataHistoryUpdateStatus.TB_Field__c == 'hed__Application_Status__c');
        System.assert(dataHistoryUpdateStatus.TB_Object__c == 'hed__Application__c');
        System.assert(dataHistoryUpdateStatus.TB_Record_Name__c == application.Name);
        System.assert(dataHistoryUpdateStatus.TB_Field_Label__c == 'Application Status');
        System.assert(dataHistoryUpdateStatus.TB_Object_Label__c == 'Application');
    }

    @IsTest
    static void shouldNotSetFieldHistoryTrackingTest() {
        hed__Application__c application = [SELECT Id,Name, hed__Application_Status__c FROM hed__Application__c];
        List<TB_Data_History__c> dataHistories = [SELECT Id FROM TB_Data_History__c WHERE TB_Record_Id__c = :application.Id];
        System.assert(dataHistories.size() == 0);

        Test.startTest();
        application.TB_Agency_Commission__c = 10;
        update application;
        Test.stopTest();

        List<TB_Data_History__c> dataHistoryAfterUpdateNotTrackedField = [SELECT Id FROM TB_Data_History__c WHERE TB_Record_Id__c = :application.Id];
        System.assert(dataHistoryAfterUpdateNotTrackedField.size() == 0);
    }

    @IsTest
    private static void coverSimilarScenariosForOtherObjects() {
        hed__Application__c app = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_Offered_Product__c offeredProduct = TB_TestDataFactory.createOfferedProduct(true);
        TB_Application_Qualification__c applicationQualification = TB_TestDataFactory.createApplicationQualification(true, app.Id);

        List<SObject> sObjects = new List<SObject>{offeredProduct, applicationQualification};
        update sObjects;
        Test.stopTest();
    }
}
/**
 * Created by kacperjachowicz on 25/08/2021.
 */

@IsTest
public with sharing class TB_DataFactory {
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static User createUser(String profileName, Boolean withInsert) {
        User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
        );
        if (withInsert) {
            insert u;
        }
        return u;
    }

    public static User createUser(String profileName, String roleName, Boolean withInsert) {
        User u = createUser(profileName, false);
        Id roleId = [SELECT Id FROM UserRole WHERE DeveloperName = :roleName].Id;
        u.UserRoleId = roleId;
        if (withInsert) {
            insert u;
        }
        return u;
    }
    public static TB_Admissions_Process__c createAdmissionProcess(Boolean withInsert) {
        TB_Admissions_Process__c admissionsProcess = new TB_Admissions_Process__c();
        if (withInsert) {
            insert admissionsProcess;
        }
        return admissionsProcess;
    }
    public static hed__Application__c createApplicationWithRelatedObjects(Boolean withInsert) {
        hed__Application__c application = new hed__Application__c();
        application.TB_Admissions_Process__c = createAdmissionProcess(true).Id;
        application.TB_Applying_To_Offered_Product__c = createOfferedProduct(true).Id;
        if (withInsert) {
            insert application;
        }
        return application;
    }
    public static TB_Offered_Product__c createOfferedProduct(Boolean withInsert) {
        TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c();
        if (withInsert) {
            insert offeredProduct;
        }
        return offeredProduct;
    }
    public static hed__Application__c createApplication(Id admissionProcessId, Id offeredProductId, Boolean withInsert) {
        hed__Application__c application = new hed__Application__c();
        application.TB_Admissions_Process__c = admissionProcessId;
        application.TB_Applying_To_Offered_Product__c = offeredProductId;
        if (withInsert) {
            insert application;
        }
        return application;
    }
    public static List<TB_Data_History__c> createDataHistories(Integer numberOfDataHistories, Boolean withInsert) {
        List<TB_Data_History__c> dataHistories = new List<TB_Data_History__c>();
        for (Integer i = 1; i <= numberOfDataHistories; i++) {
            TB_Data_History__c dataHistory = new TB_Data_History__c();
            dataHistory.TB_New_Value__c = 'New Value ' + i;
            dataHistory.TB_Prior_Value__c = 'Prior Value ' + i;
            dataHistories.add(dataHistory);
        }
        if (withInsert) {
            insert dataHistories;
        }
        return dataHistories;
    }

    public static TB_Admissions_Logic__c createAdmissionsLogic(Boolean withInsert){
        TB_Admissions_Logic__c admissionsLogic = new TB_Admissions_Logic__c();
        if(withInsert){
            insert admissionsLogic;
        }
        return admissionsLogic;
    }

    public static TB_Admissions_Data_Definition__c createDataDefinition(
        Boolean withInsert, String sourceObject, String targetObject,
        String sourceField, String targetField, String type
    ) {
        TB_Admissions_Data_Definition__c dataDefinition = new TB_Admissions_Data_Definition__c(
            Name = 'Test',
            TB_Purpose__c = 'Data_Collection',
            TB_Source_Object__c = sourceObject,
            TB_Target_Object__c = targetObject,
            TB_Source_Object_Field__c = sourceField,
            TB_Target_Object_Field__c = targetField,
            TB_Data_Type__c = type,
            TB_Field_Width__c = 100,
            TB_Label_PL__c = '<i>Test</i>',
            TB_Label_EN__c = '<i>Test</i>'
        );
        if (withInsert) {
            insert dataDefinition;
        }
        return dataDefinition;
    }

    public static TB_Admissions_Step_Data__c createStepData(Boolean withInsert, Id dataDefinitionId, Id stepId) {
        TB_Admissions_Step_Data__c stepData = new TB_Admissions_Step_Data__c(
            TB_Admissions_Step__c = stepId,
            TB_Order__c = 10,
            TB_Admissions_Data_Definition__c = dataDefinitionId,
            TB_Active__c = true
        );
        if (withInsert) {
            insert stepData;
        }
        return stepData;
    }
}
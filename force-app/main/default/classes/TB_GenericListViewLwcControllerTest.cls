/**
 * Created by Aneta on 24/08/2021.
 */

@IsTest
private class TB_GenericListViewLwcControllerTest {

    public static String objectName = 'TB_Employee_Evaluation_Stage__c' ;
    public static String fields = 'TB_Details__c;TB_Employee_Stage_Type__c;toLabel(TB_Employee_Stage_Type__c) TB_Employee_Stage_Type__c_Label;TB_Evaluation_Stage_Status__c;toLabel(TB_Evaluation_Stage_Status__c) TB_Evaluation_Stage_Status__c_Label;TB_Evaluator_Name__c;TB_Evaluation_Process_Type__c;TB_For_Period__c;TB_Evaluation_Stage_End_Date__c' ;
    public static String filter = 'TB_Evaluated__r.TB_User__r.Id = {userId} AND TB_Employee_Stage_Type__c = \'Academic Activity Report\' AND TB_Evaluation_Stage_Status__c !=\'\' AND TB_Active__c=true';
    public static String orderBy = 'TB_Evaluation_Stage_Status__c' ;
    public static String linkingField = 'TB_Details__c';
    public static String link = '/EmployeeEvaluation/s/tb-employee-evaluation-stage/{Id}';
    public static Integer limitRecords = 200;

    @TestSetup
    static void testSetup() {
    }

    @IsTest
    static void getObjects() {
        Test.startTest();
        TB_GenericListViewLwcController.getObjects(objectName, fields, filter, orderBy, limitRecords);
        Test.stopTest();
    }

    @IsTest
    static void getFields() {

        Test.startTest();
        TB_GenericListViewLwcController.getFields(objectName,fields,linkingField);
        Test.stopTest();
    }

    @IsTest
    static void getFieldsApiNames() {

        Test.startTest();
        TB_GenericListViewLwcController.getFieldsApiNames(fields,link);
        Test.stopTest();
    }

}
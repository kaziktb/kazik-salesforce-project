@IsTest
public class TB_AppTrackingTriggerHandlerTest {
    private static final String EMAIL_ONE_VALUE = 'testtest@gmail.com';

   @TestSetup
   static void makeData(){
       System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)){
           TB_TC_URLs__c url = new TB_TC_URLs__c(TB_Admissions_Portal__c  = 'https://devtbydct-swpsuniversity.cs174.force.co...');
           insert url;
           Contact administrator = new Contact(
                   LastName = 'Kowal',
                   hed__WorkEmail__c = 'test@gmail.com',
                   hed__Preferred_Email__c = 'Work',
                   hed__AlternateEmail__c = EMAIL_ONE_VALUE,
                   Phone = '809890890',
                   TB_Customer_Id__c = '1705983'
           );
           insert administrator;
           TB_App_Tracking__c testInput = new TB_App_Tracking__c();
           testInput.TB_Email__c = EMAIL_ONE_VALUE;
           testInput.TB_Phone__c = '809890890';
           testInput.TB_PESEL__c = '78040152352';
           testInput.TB_Last_Name__c = 'Test Last Name';
           testInput.TB_Middle_Name__c = 'Test Middle Name';
           testInput.TB_First_Name__c = 'Test First Name';
           insert testInput;
       }
    }
   
   @IsTest
   static void testAfterInsert(){

    Test.startTest();
        Contact cont = [SELECT Id FROM Contact WHERE Email = :EMAIL_ONE_VALUE LIMIT 1];
        User user = [SELECT Id FROM User WHERE Email = :EMAIL_ONE_VALUE LIMIT 1 ];
    Test.stopTest();

    Assert.areNotEqual(cont, null,'Contact Should be created');
    Assert.areNotEqual(user, null,'User Should be created');
   }

   @IsTest
   static void testAfterUpdate(){
    TB_App_Tracking__c testInput =  [SELECT Id FROM TB_App_Tracking__c LIMIT 1];

    Test.startTest();
       System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
           testInput.TB_Process_Status__c = 'Process_Cancelled';
           update testInput;
       }
    Test.stopTest();

    TB_App_Tracking__c testOutput = [SELECT Id, TB_Process_Status__c FROM TB_App_Tracking__c LIMIT 1];
    Assert.areEqual(testOutput.TB_Process_Status__c, 'Process_Cancelled','Process Should be cancelled');

   }
}
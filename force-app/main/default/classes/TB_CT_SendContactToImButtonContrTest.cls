@isTest
public class TB_CT_SendContactToImButtonContrTest {
   private static final String EMAIL_TEST = 'test@test.com';
   private static final String SEX = 'Female';
   private static final String TITLE_GRANDE = 'mgr. inz';
   private static final String TEST_ACC = 'Test Acc';
   private static final String TEST_ACC_NUMBER = 'ABC341242134OP';
   private static final String TEST_CONTACT = 'testContact';
   private static final String TEST_PHONE = '521345098';
   private static final String TEST_TB_EmploymentType = 'D';
   private static final String TEST_TB_Location = 'W';
   private static final String TEST_TB_Position = 'Test Position';
   private static final String TEST_TB_RoleType = 'O';
   private static final String TEST_TB_EmploymentCat = 'A';
   private static final String TEST_PL = 'PL';
   private static final String TEST_EN = 'EN';
   private static final String TEST_DOWOD = 'POLSKI_DOWOD_OSOBISTY';
   private static final String TEST_DOWOD_NUM = 'AX91233FRE';
   private static final String POLAND = 'PL';
   private static final String ENGLISH = 'English';
   
   @TestSetup
   static void makeData(){
      TB_CT_TestDataFactory.insertCTUrls();
      TB_Admissions_Content__c content = new TB_Admissions_Content__c(
         TB_Active__c = true,
         TB_Content_Type__c = 'Message',
         TB_Content_PL__c = 'Brak rekordów',
         TB_Content_EN__c = 'Lack of records',
         TB_Record_Code__c = 'List has no rows for assignment to SObject'
     );
     insert content;
       
   }
    @IsTest
    public static void createOrUpdatePersonTest(){
      TB_App_Tracking__c testinput = new TB_App_Tracking__c();
      testinput.TB_Email__c = EMAIL_TEST;
      testinput.TB_Phone__c = TEST_PHONE;
      testinput.TB_PESEL__c = '78040152352';
      testinput.TB_Last_Name__c = TEST_CONTACT;
      testinput.TB_Middle_Name__c = 'Test Middle Name';
      testinput.TB_First_Name__c = 'Test First Name';
      System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false))
         {    
               insert testinput;
               Id adminUserId = UserInfo.getUserId();
               Contact cont_appTrack = [SELECT ID FROM Contact Limit 1];
               Contact cont = new Contact(Id = cont_appTrack.Id,LastName = TEST_CONTACT, FirstName = TEST_CONTACT, 
               Email = EMAIL_TEST, Birthdate = Date.today() - 365*19);
               cont.hed__Gender__c = SEX;
               cont.hed__AlternateEmail__c = EMAIL_TEST;
               cont.TB_Title_Grade__c = TITLE_GRANDE;
               cont.Phone = TEST_PHONE;
               cont.DT_Document_Issuing_Country__c = TEST_PL;
               cont.DT_Document_Type__c = TEST_DOWOD;
               cont.DT_Document_Series_and_Number__c = TEST_DOWOD_NUM;
               cont.TB_Citizenship__c = POLAND;
               cont.TB_User__c = adminUserId;
               update cont; 
               Account testAcc = [SELECT ID FROM Account Limit 1];
               hed__Affiliation__c affiliation = new hed__Affiliation__c(hed__Contact__c = cont.Id,hed__Account__c = testAcc.Id);
               affiliation.TB_EmploymentType__c = TEST_TB_EmploymentType;
               affiliation.TB_Location__c = TEST_TB_Location;
               affiliation.TB_Position__c = TEST_TB_Position;
               affiliation.TB_RoleType__c = TEST_TB_RoleType;
               affiliation.TB_EmploymentCat__c = TEST_TB_EmploymentCat;
               affiliation.hed__Primary__c = true;
               insert affiliation;
               String body = TB_CT_SendContactToImButtonController.sendtoim(cont.Id,'PL');
               cont = [SELECT ID ,TB_ERP_Id__c,TB_IM_Id__c FROM CONTACT WHERE ID =:cont.id limit 1];
               System.assert(cont.TB_ERP_Id__c != null, 'ERP Number should not be empty');
               System.assert(body != null, 'body should not be empty');
          }
    }

    @IsTest
    public static void createOrUpdatePersonFailTest(){
       Contact cont = new Contact(LastName = 'testContact', FirstName = 'testContact', 
       Email = 'test@test.com');
       insert cont; 
       String body;
       test.startTest();
       try {
         body = TB_CT_SendContactToImButtonController.sendtoim(cont.Id,'PL');
       } catch (Exception ex) {
          System.assert( ex.getMessage() != null);
       } 
       test.stopTest();
    }
}

@isTest
public class TB_OfficeHoursControllerTest {
    
    public static List<Id> DataFactory(){
        List <Id> factoryIds = new List<Id>();
        Contact applicant = new Contact();
        applicant.LastName = 'Test applicant';
        insert applicant;
        String applicantId = applicant.id;
        
        TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c();
        offeredProduct.Name = 'Test product';
        insert offeredProduct;
        
        hed__Application__c application = new hed__Application__c();
        application.hed__Applicant__c = applicantId;
        application.TB_Applying_To_Offered_Product__c = offeredProduct.id;
        insert application;
        String applicationId = application.id;

        Account office = new Account();
        office.Name = 'Test office';
        insert office;
        String officeId = office.id;
        
        factoryIds.add(applicantId);
        factoryIds.add(applicationId);
        factoryIds.add(officeId);
        return factoryIds;
    }
    
	@isTest
    public static void getApplicationDataTest(){
        List<String> factoryIds = DataFactory();
        test.startTest();
        hed__Application__c application = TB_OfficeHoursController.getApplicationData(factoryIds[1]);
        test.stopTest();
        System.assertNotEquals(null, application.Id);
    }

    @isTest
    public static void getOfficeDataTest(){
        List<String> factoryIds = DataFactory();
        test.startTest();
        Account office = TB_OfficeHoursController.getOfficeData(factoryIds[2]);
        test.stopTest();
        System.assertNotEquals(null, office.Id);
    }
}
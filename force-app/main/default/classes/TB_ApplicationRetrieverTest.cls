/**
 * Created by adriangawryszewski on 1/17/22.
 */
@IsTest
public with sharing class TB_ApplicationRetrieverTest {

    @TestSetup
    static void testSetup() {
        Contact ct = new Contact(
                LastName = 'Testowy',
                Email = 'test@swps.edu.pl.test');
        insert ct;

        TB_Offered_Product__c study = new TB_Offered_Product__c(
                Name = 'Psychologia');
        insert study;

        Contact candidate = new Contact(
                LastName = 'Kandydat',
                Email = 'kandydat@email.test');
        insert candidate;


        hed__Application__c candApplication = new hed__Application__c(
                TB_Active__c = true,
                TB_Applying_To_Offered_Product__c = study.Id,
                hed__Applicant__c = candidate.Id
        );
        insert candApplication;
    }

    @IsTest
    static void testDataRetrieve() {
        hed__Application__c app = [SELECT Id FROM hed__Application__c LIMIT 1];
        hed__Application__c app2;
        Test.startTest();
            app2 = TB_ApplicationRetriever.retrieveAllApplicationFields(app.Id);
        Test.stopTest();

        System.assertEquals(app2.TB_Active__c, true);
        System.assertEquals(app2.hed__Applicant__r.LastName, 'Kandydat');
        System.assertEquals(app2.TB_Applying_To_Offered_Product__r.Name, 'Psychologia');

    }

}
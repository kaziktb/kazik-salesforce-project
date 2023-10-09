/**
 * Created by adriangawryszewski on 3/1/22.
 */
@isTest
public with sharing class TB_CommunicationEventTriggerTest {

    private static final String TEST_SYSTEM = 'TEST_SYSTEM';
    private static final String OBJECT_TYPE = 'Account';


    @TestSetup
    static void dataFactory() {
        Account acc = new Account(
                Name = 'Test Account'
        );
        insert acc;
    }

    @IsTest
    static void testSendEvents() {
        Account acc = [SELECT Id FROM Account];
        Test.setMock(HttpCalloutMock.class, new TB_VDOExportMock('success'));
        Test.startTest();
        insert TB_CommunicationEventUtils.registerOutboundCommunicationEvent(
                TEST_SYSTEM,
                acc.Id,
                OBJECT_TYPE,
                null,
                null,
                JSON.serialize('{"name" : "body"}'),
                null,
                null,
                '123'
        );
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM TB_Communication_Event__c]);
    }

}
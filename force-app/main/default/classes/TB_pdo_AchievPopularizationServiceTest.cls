@isTest
private class TB_pdo_AchievPopularizationServiceTest {

    @TestSetup
    static void makeData(){

        Contact contactMain = new Contact();
        contactMain.FirstName = 'Hue';
        contactMain.LastName = 'Mungus';
        contactMain.hed__WorkEmail__c = 'hue.mungus+autor@gmail.com';
        contactMain.TB_ERP_Id__c = 'P8989898';
        insert contactMain;

        TB_PDO__c testPdo = new TB_PDO__c();
        testPdo.TB_Depositor__c = contactMain.id;
        testPdo.TB_DSpace_Reference_Id__c = '2222-xxxx-qeas-1111';
        testPdo.TB_PDO_Status__c = 'Published';
        testPdo.TB_DSpace_Status__c = 'Published';
        testPdo.TB_Publisher_Ministerial__c = 'Wydawnictwo Naukowe TYGIEL Sp. z o. o.';
        insert testPdo;
        
    }

    @isTest
    static void testIfAchievementIsUpdatedWithValidPoints() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        TB_pdo_SingleRequestMock fakeTokenResp = new TB_pdo_SingleRequestMock(
            200,
            'Complete',
            '{\"token_type\":\"Bearer\",\"scope\":\"User.Readprofileopenidemail\",\"expires_in\":4392,\"ext_expires_in\":4392,\"access_token\":\"eyJ0eXAiOiJKV1Q\",\"refresh_token\":\"0.AQIAOlg2y0Xk0k\",\"id_token\":\"eyJ0eXAiOiJKV\"}',
            null
        );
        TB_pdo_SingleRequestMock fakeSCresponse = new TB_pdo_SingleRequestMock(
            200,
            'Complete',
            '{\"publishers\":[{\"id\":1485,\"mnisw_id\":85900,\"name\":\"Wydawnictwo Naukowe TYGIEL Sp. z o. o.\",\"points\":80}],\"pagination\":{\"page\":1,\"per_page\":1,\"pages\":1}}',
            null
        );
        Map<String, HttpCalloutMock> tokenAndDataResp = new Map<String, HttpCalloutMock>();
        tokenAndDataResp.put('callout:TB_Sciencecloud_Auth', fakeTokenResp);
        tokenAndDataResp.put(
            'callout:TB_Sciencecloud_pdo/publishers?on_ministerial_list=true&query=Wydawnictwo+Naukowe+TYGIEL+Sp.+z+o.+o.',
            fakeSCresponse
        );
        HttpCalloutMock multiCalloutMock = new TB_pdo_MultiRequestMock(
            tokenAndDataResp
        );
        TB_PDO__c pdo = [SELECT Id, TB_Publisher_Ministerial__c FROM TB_PDO__c WHERE TB_DSpace_Reference_Id__c = '2222-xxxx-qeas-1111' LIMIT 1];
        List<TB_pdo_AchievementPopularizationService.PublisherAchievementLink> paramsList = new List<TB_pdo_AchievementPopularizationService.PublisherAchievementLink>();
        TB_pdo_AchievementPopularizationService.PublisherAchievementLink link = new TB_pdo_AchievementPopularizationService.PublisherAchievementLink();
        link.pdoId = pdo.Id;
        link.publisher = pdo.TB_Publisher_Ministerial__c;
        paramsList.add(link);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        TB_pdo_AchievementPopularizationService.updateAchievementWithPublisherPoints(paramsList);
        Test.stopTest();
        TB_PDO__c actualPdo = [SELECT Id, TB_Publisher_Points__c FROM TB_PDO__c WHERE TB_DSpace_Reference_Id__c = '2222-xxxx-qeas-1111' LIMIT 1];
        System.assertEquals(80, actualPdo.TB_Publisher_Points__c);
    }

}
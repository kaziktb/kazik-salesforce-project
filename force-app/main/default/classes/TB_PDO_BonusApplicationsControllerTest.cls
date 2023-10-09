/**
 * @description       : PDO acceptance main flow
 * @author            : jakub.wrzodek@thinkbeyond.cloud
 * Modifications Log
 * Ver   Date         Author
 * 1.0   01-11-2022   Jakub Wrzodek
**/
@isTest
private class TB_PDO_BonusApplicationsControllerTest {
    final static Contact TEST_DEPOSITOR;

    static {
        TEST_DEPOSITOR = populateDepositor();
        insert TEST_DEPOSITOR;
    }

    private static TB_PDO__c populatePdoWith(String status) {
        return populatePdoWith(status, 1);
    }

    private static TB_PDO__c populatePdoWith(String status, Integer index) {
        return new TB_PDO__c(
            TB_Title_Original__c = 'TEST PDO ' + index,
            TB_Bonus_Application_Status__c = status,
            TB_BA_Score__c = 10,
            TB_Year_of_Publication__c = '2022',
            TB_Bonus_Application__c = true
        );
    }

    private static List<TB_PDO__c> populatePdoListWith(String status, Integer amount) {
        List<TB_PDO__c> result = new List<TB_PDO__c>();
        for (Integer i = 0; i < amount; i++) {
            result.add(populatePdoWith(status, i));
        }
        return result;
    }

    private static TB_PDO_Participant__c populateParticipantWith(String status, Id pdoId) {
        return new TB_PDO_Participant__c(
            TB_PDO__c = pdoId,
            TB_Bonus_Application_Status__c = status,
            TB_Bonus_Application_Share__c = 10,
            TB_Bonus_Application__c = true
        );
    }

    private static Contact populateDepositor() {
        Id userId = UserInfo.getUserId();
        return new Contact(
            LastName = 'Depositor',
            TB_User__c = userId
        );
    }

    @isTest 
    public static void getBonusApplications_NoData() {
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplications();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper> wrappedPdos = 
                (List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>)
                    JSON.deserialize(JSON.serialize(responseMap.get('data')), 
                    List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>.class);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(0, wrappedPdos.size(), 'Pdos returned must be in the amount of 0');
    }


    @isTest 
    public static void getBonusApplications_OnePdo() {
        TB_PDO__c testPdo = populatePdoWith('New');
        testPdo.TB_Depositor__c = TEST_DEPOSITOR.Id;
        insert testPdo;
    
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplications();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper> wrappedPdos = 
                (List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>)
                    JSON.deserialize(JSON.serialize(responseMap.get('data')), 
                    List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>.class);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(1, wrappedPdos.size(), 'Pdos returned must be in the amount of 1');
    }

    @isTest
    public static void getBonusApplications_OneParticipant() {
        TB_PDO__c testPdo = populatePdoWith('New');
        insert testPdo;
        TB_PDO_Participant__c testParticipant = populateParticipantWith('To Confirm', testPdo.Id);
        testParticipant.TB_Contact__c = TEST_DEPOSITOR.Id;
        insert testParticipant;
    
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplications();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper> wrappedPdos = 
                (List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>)
                    JSON.deserialize(JSON.serialize(responseMap.get('data')), 
                    List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>.class);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(1, wrappedPdos.size(), 'Pdos returned must be in the amount of 1');
    }

    @isTest
    public static void getBonusApplications_OnePdoOneParticipant() {
        TB_PDO__c testPdoDepositor = populatePdoWith('New');
        testPdoDepositor.TB_Depositor__c = TEST_DEPOSITOR.Id;
        insert testPdoDepositor;
        TB_PDO__c testPdo = populatePdoWith('New');
        insert testPdo;
        TB_PDO_Participant__c testParticipant = populateParticipantWith('To Confirm', testPdo.Id);
        testParticipant.TB_Contact__c = TEST_DEPOSITOR.Id;
        insert testParticipant;
    
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplications();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper> wrappedPdos = 
                (List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>)
                    JSON.deserialize(JSON.serialize(responseMap.get('data')), 
                    List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>.class);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(2, wrappedPdos.size(), 'Pdos returned must be in the amount of 2');
    }

    @isTest
    public static void getBonusApplications_OnePdoOneParticipantSameDepositor() {
        TB_PDO__c testPdo = populatePdoWith('New');
        testPdo.TB_Depositor__c = TEST_DEPOSITOR.Id;
        insert testPdo;
        TB_PDO_Participant__c testParticipant = populateParticipantWith('To Confirm', testPdo.Id);
        testParticipant.TB_Contact__c = TEST_DEPOSITOR.Id;
        insert testParticipant;
    
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplications();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper> wrappedPdos = 
                (List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>)
                    JSON.deserialize(JSON.serialize(responseMap.get('data')), 
                    List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>.class);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(1, wrappedPdos.size(), 'Pdos returned must be in the amount of 1');
    }

    @isTest
    public static void getBonusApplications_FivePdos() {
        List<TB_PDO__c> testPdos = populatePdoListWith('New', 5);
        for (TB_PDO__c pdo : testPdos) {
            pdo.TB_Depositor__c = TEST_DEPOSITOR.Id;
        }
        insert testPdos;
    
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplications();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper> wrappedPdos = 
                (List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>)
                    JSON.deserialize(JSON.serialize(responseMap.get('data')), 
                    List<TB_PDO_BonusApplicationsController.SimplePdoDataWrapper>.class);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(5, wrappedPdos.size(), 'Pdos returned must be in the amount of 5');
    }

    @isTest
    public static void getBonusApplication_InvalidId() {
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplication('InvalidId');
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('data'), 'Data has to be null!');
        System.assertNotEquals(null, responseMap.get('error'), 'Error can not be null!');
    }

    @isTest
    public static void getBonusApplication_PdoNoAccess() {
        TB_PDO__c testPdo = populatePdoWith('New');
        insert testPdo;

        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplication(testPdo.Id);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('data'), 'Data has to be null!');
        System.assertNotEquals(null, responseMap.get('error'), 'Error can not be null!');
    }

    @isTest
    public static void getBonusApplication_CorrectPdo() {
        TB_PDO__c testPdo = populatePdoWith('New');
        testPdo.TB_Depositor__c = TEST_DEPOSITOR.Id;
        insert testPdo;

        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplication(testPdo.Id);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertNotEquals(null, responseMap.get('data'), 'Data can not be null!');
        System.assertEquals(null, responseMap.get('error'), 'Error has to be null!');
    }

    @isTest
    public static void getBonusApplication_ParticipantNoAccess() {
        TB_PDO__c testPdo = populatePdoWith('New');
        insert testPdo;
        TB_PDO_Participant__c testParticipant = populateParticipantWith('To Confirm', testPdo.Id);
        insert testParticipant;

        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplication(testPdo.Id);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('data'), 'Data has to be null!');
        System.assertNotEquals(null, responseMap.get('error'), 'Error can not be null!');
    }

    @isTest
    public static void getBonusApplication_CorrectParticipant() {
        TB_PDO__c testPdo = populatePdoWith('New');
        insert testPdo;
        TB_PDO_Participant__c testParticipant = populateParticipantWith('To Confirm', testPdo.Id);
        testParticipant.TB_Contact__c = TEST_DEPOSITOR.Id;
        insert testParticipant;

        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplication(testParticipant.Id);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertNotEquals(null, responseMap.get('data'), 'Data can not be null!');
        System.assertEquals(null, responseMap.get('error'), 'Error has to be null!');
    }

    @isTest
    public static void getBonusApplicationStatusDetails_InvalidId() {
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplicationStatusDetails('InvalidId');
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('data'), 'Data has to be null!');
        System.assertNotEquals(null, responseMap.get('error'), 'Error can not be null!');
    }

    @isTest
    public static void getBonusApplicationStatusDetails_PdoId() {
        TB_PDO__c testPdo = populatePdoWith('New');
        testPdo.TB_Depositor__c = TEST_DEPOSITOR.Id;
        insert testPdo;

        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplicationStatusDetails(testPdo.Id);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertNotEquals(null, responseMap.get('data'), 'Data can not be null!');
        System.assertEquals(null, responseMap.get('error'), 'Error has to be null!');
    }

    @isTest
    public static void getBonusApplicationStatusDetails_ParticipantId() {
        TB_PDO__c testPdo = populatePdoWith('New');
        insert testPdo;
        TB_PDO_Participant__c testParticipant = populateParticipantWith('To Confirm', testPdo.Id);
        testParticipant.TB_Contact__c = TEST_DEPOSITOR.Id;
        insert testParticipant;

        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplicationStatusDetails(testParticipant.Id);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertNotEquals(null, responseMap.get('data'), 'Data can not be null!');
        System.assertEquals(null, responseMap.get('error'), 'Error has to be null!');
    }

    @isTest
    public static void getBonusApplicationStatuses_CorrectStatuses() {
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.getBonusApplicationStatuses();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertNotEquals(null, responseMap.get('data'), 'Data can not be null!');
        System.assertEquals(null, responseMap.get('error'), 'Error has to be null!');
    }

    @isTest
    public static void acceptBonusApplication_InvalidJson() {
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.acceptBonusApplication('InvalidJson');
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('data'), 'Data has to be null!');
        System.assertNotEquals(null, responseMap.get('error'), 'Error can not be null!');
    }

    @isTest
    public static void acceptBonusApplication_CorrectJson() {
        TB_PDO__c testPdo = populatePdoWith('New');
        testPdo.TB_Depositor__c = TEST_DEPOSITOR.Id;
        insert testPdo;
        String correctJson = JSON.serialize(testPdo);

        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.acceptBonusApplication(correctJson);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            TB_PDO__c returnedPdo = [SELECT TB_Bonus_Application_Status__c FROM TB_PDO__c WHERE ID = :testPdo.Id];
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('error'), 'Error has to be null!');
        System.assertEquals('Confirmation_Pending', returnedPdo.TB_Bonus_Application_Status__c, 
            'Status has to be updated to confirmation pending!');
    }

    @isTest
    public static void acceptParticipantSharing_InvalidJson() {
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.acceptParticipantSharing('InvalidJson');
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('data'), 'Data has to be null!');
        System.assertNotEquals(null, responseMap.get('error'), 'Error can not be null!');
    }

    @isTest
    public static void acceptParticipantSharing_CorrectJson() {
        TB_PDO__c testPdo = populatePdoWith('New');
        insert testPdo;
        TB_PDO_Participant__c testParticipant = populateParticipantWith('To Confirm', testPdo.Id);
        testParticipant.TB_Contact__c = TEST_DEPOSITOR.Id;
        insert testParticipant;
        String correctJson = JSON.serialize(testParticipant);
        correctJson = correctJson.replace('10', '20');

        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.acceptParticipantSharing(correctJson);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            TB_PDO_Participant__c returnedParticipant = [
                SELECT TB_Bonus_Application_Status__c, TB_Bonus_Application_Share__c
                FROM TB_PDO_Participant__c 
                WHERE ID = :testParticipant.Id
            ];
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('error'), 'Error has to be null!');
        System.assertEquals('To_Verify', returnedParticipant.TB_Bonus_Application_Status__c, 
            'Status has to be updated to verify!');
        System.assertEquals(20, returnedParticipant.TB_Bonus_Application_Share__c, 
            'Share has to be updated to 20!');
    }

    @isTest
    public static void updateParticipants_InvalidJson() {
        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.updateParticipants('InvalidJson');
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('data'), 'Data has to be null!');
        System.assertNotEquals(null, responseMap.get('error'), 'Error can not be null!');
    }

    @isTest
    public static void updateParticipants_CorrectJson() {
        TB_PDO__c testPdo = populatePdoWith('New');
        insert testPdo;
        TB_PDO_Participant__c testParticipant = populateParticipantWith('To Confirm', testPdo.Id);
        testParticipant.TB_Contact__c = TEST_DEPOSITOR.Id;
        insert testParticipant;
        String correctJson = JSON.serialize(new List<TB_PDO_Participant__c>{testParticipant});
        correctJson = correctJson.replace('10', '20');

        Test.startTest();
            String jsonResponse = TB_PDO_BonusApplicationsController.updateParticipants(correctJson);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            TB_PDO_Participant__c returnedParticipant = [
                SELECT TB_Bonus_Application_Status__c, TB_Bonus_Application_Share__c
                FROM TB_PDO_Participant__c 
                WHERE ID = :testParticipant.Id
            ];
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Response can not be null!');
        System.assertEquals(null, responseMap.get('error'), 'Error has to be null!');
        System.assertEquals(20, returnedParticipant.TB_Bonus_Application_Share__c, 
            'Share has to be updated to 20!');
    }
}
@IsTest
public with sharing class TB_ObjectSharingTest {

    @TestSetup
    static void testSetup() {
        TB_PDO__c pdo = new TB_PDO__c();
        insert pdo;
        TB_TestDataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, true);
    }

//    @IsTest
//    static void createSharesPositive() {
//        TB_PDO__c pdo = [SELECT Id FROM TB_PDO__c LIMIT 1];
//        User user = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
//        TB_PDO__Share share = new TB_PDO__Share(
//            ParentId = pdo.Id,
//            UserOrGroupId = user.Id,
//            AccessLevel = 'Edit',
//            RowCause = 'TB_PDO__c'
//        );
//
//        Test.startTest();
//        TB_ObjectSharing.createShares(new List<List<SObject>>{new list<SObject>{share}});
//        Test.stopTest();
//
//        List<TB_PDO__Share> shares = [
//            SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId
//            FROM TB_PDO__Share
//            WHERE ParentId = :pdo.Id
//            AND UserOrGroupId = :user.Id
//            AND AccessLevel = 'Edit'
//            AND RowCause = 'TB_PDO__c'
//        ];
//        System.assertEquals(1, shares.size());
//        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
//    }

}
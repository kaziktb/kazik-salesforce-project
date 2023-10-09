/**
* @description       : 
* @author            : aleksandra.gonta-kacperska@devoteam.com
* @group             : 
* @last modified on  : 05-24-2021
* @last modified by  : aleksandra.gonta-kacperska@devoteam.com
* Modifications Log 
* Ver   Date         Author                                    Modification
* 1.0   05-24-2021   aleksandra.gonta-kacperska@devoteam.com   Initial Version
**/
@isTest
public class DT_FavoritesControllerTest {
    public static final String JOB_OFFER_TEST_NAME = 'Test Job';

    @TestSetup
    public static void dataInit() {
        User studentUser;
        DT_Job_Offers__c testJob;
        User adminUser = DT_DataFactory.createAdminUser();

        System.runAs(adminUser) {
            studentUser = DT_DataFactory.createStudentUser();

            testJob = DT_DataFactory.createJobOffers(
                1, true, new DT_Job_Offers__c(
                    DT_Job_Title__c = JOB_OFFER_TEST_NAME
                )
            ).get(0);
        }

        System.runAs(studentUser) {
            DT_Favorites__c favorite = new DT_Favorites__c();
            favorite.DT_User__c = studentUser.Id;
            favorite.DT_Job_Offer__c = testJob.Id;

            insert favorite;
        }
    }

    @isTest
    public static void inFavorites() {
        User student = DT_TestClassUtils.getUserByEmail(DT_DataFactory.USER_STUDENT_EMAIL);
        DT_Job_Offers__c testJob = [
            SELECT Id
            FROM DT_Job_Offers__c
            WHERE DT_Job_Title__c =: JOB_OFFER_TEST_NAME
        ];
        Boolean hasFavorites = false;

        Test.startTest();
            System.runAs(student) {
                hasFavorites = DT_FavoritesController.checkFavorite(testJob.Id, student.Id);
            }
        Test.stopTest();
        System.assertEquals(true, hasFavorites);
    }

    @isTest
    public static void creatingFavorites() {
        User student = DT_TestClassUtils.getUserByEmail(DT_DataFactory.USER_STUDENT_EMAIL);

        DT_Job_Offers__c testJob = [
            SELECT Id
            FROM DT_Job_Offers__c
            WHERE DT_Job_Title__c =: JOB_OFFER_TEST_NAME
        ];
        Test.startTest();
            DT_FavoritesController.createFavorite(testJob.Id, student.Id, student.ContactId);
        Test.stopTest();

        List<DT_Favorites__c> favoriteJob = [
            SELECT Id
            FROM DT_Favorites__c
            WHERE DT_Contact__c = :student.ContactId
        ];
        System.assertEquals(1, favoriteJob.size());
    }

    @isTest
    public static void deletingFavorites() {
        User student = DT_TestClassUtils.getUserByEmail(DT_DataFactory.USER_STUDENT_EMAIL);

        DT_Job_Offers__c testJob = [
            SELECT Id
            FROM DT_Job_Offers__c
            WHERE DT_Job_Title__c =: JOB_OFFER_TEST_NAME
        ];
        Test.startTest();
            System.runAs(student) {
                DT_FavoritesController.deleteFavorites(testJob.Id, student.Id);
            }
        Test.stopTest();

        DT_Favorites__c favoriteRecord = [
            SELECT Id, isDeleted
            FROM DT_Favorites__c
            WHERE DT_Job_Offer__c = :testJob.Id
                AND DT_User__c = :student.Id
            ALL ROWS
        ];
        System.assertEquals(favoriteRecord.IsDeleted, true);
    }

    @isTest
    public static void gettingAllFavorites() {
        User student = DT_TestClassUtils.getUserByEmail(DT_DataFactory.USER_STUDENT_EMAIL);
        List<DT_Favorites__c> favorites;

        Test.startTest();
            System.runAs(student) {
                favorites = DT_FavoritesController.getAllFavorites();
            }
        Test.stopTest();
        System.assertEquals(false, favorites.isEmpty());
        System.assert(favorites.size() > 0);
    }
}
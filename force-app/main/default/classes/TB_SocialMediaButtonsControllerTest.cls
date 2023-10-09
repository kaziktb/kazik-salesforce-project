/**
 * Created by annaseveryna on 04/01/2022.
 */
@IsTest
public with sharing class TB_SocialMediaButtonsControllerTest {

    @TestSetup
    static void setupMethod() {
        TB_Admissions_Content__c postOnFacebook = new TB_Admissions_Content__c(
                TB_Active__c = true,
                TB_Content_Type__c = 'Social_Media',
                TB_Product_Group__c = 'Higher_Education',
                TB_Social_Media__c = 'Facebook'
        );
        TB_Admissions_Content__c postOnLinkedIn = new TB_Admissions_Content__c(
                TB_Active__c = true,
                TB_Content_Type__c = 'Social_Media',
                TB_Product_Group__c = 'Higher_Education',
                TB_Social_Media__c = 'LinkedIn'
        );
        List<TB_Admissions_Content__c> posts = new List<TB_Admissions_Content__c>();
        posts.add(postOnFacebook);
        posts.add(postOnLinkedIn);
        insert posts;
    }

    @IsTest
    static void socialMediaPostsTest() {

        Test.startTest();
        List<TB_Admissions_Content__c> returnedPosts = TB_SocialMediaButtonsController.fetchSocialMediaPosts();
        Test.stopTest();

        System.assertEquals(2, returnedPosts.size());
    }
}
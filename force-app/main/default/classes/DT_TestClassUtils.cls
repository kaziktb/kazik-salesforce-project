/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 12-09-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
**/
public with sharing class DT_TestClassUtils {
    public static User getUserByEmail(String email) {
        return [SELECT Id, ContactId, UserRoleId FROM User WHERE Email = :email].get(0);
    }

    public static DT_Tag__c getTagByName(String name) {
        return [SELECT Id, Name FROM DT_Tag__c WHERE Name = :name].get(0);
    }

    public static DT_Job_Offers__c getJobOfferByTitle(String title) {
        return [
            SELECT Id, DT_Job_Title__c, (
                SELECT Id, Name
                FROM Job_Offer_Tags__r
            )
            FROM DT_Job_Offers__c
            WHERE DT_Job_Title__c = :title
        ].get(0);
    }

    public static Contact getContactByEmail(String email) {
        return [
            SELECT Id, FirstName, LastName, (
                SELECT Id, Name
                FROM Contact_Tags__r
            )
            FROM Contact
            WHERE Email = :email
        ].get(0);
    }

    public static Case getCaseBySubject(String subject) {
        return [
            SELECT Id, Origin, OwnerId, Status, DT_Academic_Program_Picklist__c, DT_Campus_Picklist__c,
                DT_Department_Picklist__c, DT_Level_Of_studies__c, DT_Mode_Of_Studies__c, DT_Philological_Language__c,
                DT_Language_Of_Instruction__c
            FROM Case
            WHERE Subject = :subject
            LIMIT 1
        ];
    }

    public static Case fetchCaseById(Id caseId) {
        return [
            SELECT Id, Origin, OwnerId, Status, DT_Academic_Program_Picklist__c, DT_Campus_Picklist__c,
                DT_Department_Picklist__c, DT_Level_Of_studies__c, DT_Mode_Of_Studies__c, DT_Philological_Language__c,
                DT_Language_Of_Instruction__c, EntitlementId, DT_Result__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
    }

    public static hed__Program_Enrollment__c fetchProgramEnrollmentById(Id programEnrollmentId) {
        return [
            SELECT Id, hed__Account__r.DT_VDO_ID__c, hed__Account__r.DT_Philological_Language_List__c, DT_Campus__c,
                DT_Department__c, DT_Level_Of_Studies__c, DT_Mode_Of_Studies__c, DT_Language_Of_Instruction__c
            FROM hed__Program_Enrollment__c
            WHERE Id =:programEnrollmentId
            LIMIT 1
        ];
    }

    public static hed__Program_Enrollment__c fetchProgramEnrollmentByContactId(Id contactId) {
        return [
            SELECT Id, hed__Account__r.DT_VDO_ID__c, hed__Account__r.DT_Philological_Language_List__c, DT_Campus__c,
                DT_Department__c, DT_Level_Of_Studies__c, DT_Mode_Of_Studies__c, DT_Language_Of_Instruction__c
            FROM hed__Program_Enrollment__c
            WHERE hed__Contact__c =:contactId
            LIMIT 1
        ];
    }

    public static DT_Internship__c  getInternshipByCompany(String company) {
               return [
                SELECT Id, DT_Full_Name_Of_The_Organization__c, (
                        SELECT Id, Name
                        FROM Internship_Tags__r
                )
                FROM DT_Internship__c
                WHERE DT_Full_Name_Of_The_Organization__c =:company
        ].get(0);
    }

    public static Campaign fetchCampaignByName(String campaignName) {
        return [
                SELECT Id, Name, Status
                FROM Campaign
                WHERE Name =:campaignName
        ].get(0);
    }

    public static CampaignMember fetchCampaignMember(Id campaignId, Id contactId) {
        return [
                SELECT Id, CampaignId, ContactId, DT_Date_Of_CV_Application__c
                FROM CampaignMember
                WHERE CampaignId =:campaignId
                AND ContactId =: contactId
        ].get(0);
    }
}
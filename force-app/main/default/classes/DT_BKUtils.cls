/**
 * @File Name          : DT_BKUtils.cls
 * @Description        :
 * @Author             : aleksandra.gonta-kacperska@devoteam.com
 * @Group              :
 * @Last Modified By   : aleksandra.gonta-kacperska@devoteam.com
 * @Last Modified On   : 01-28-2022
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    2/17/2020   slawek.wojcik@avalonsolutions.com     Initial Version
**/
public with sharing class DT_BKUtils {

    @AuraEnabled
    public static List<DT_Job_Offers__c> getAllJobOffers() {
        return [
            SELECT Id, Name ,DT_Job_Title__c, toLabel(DT_Employment_Type__c) EmploymentTypeLabel, DT_Employment_Type__c,
                DT_Position_Level__c, DT_Company_Name__r.Name, DT_Job_Location__c, DT_Offer_valid_for__c,
                toLabel(DT_Business_Category__c) BusinessCategoryLabel, DT_Business_Category__c,
                DT_Valid_Until__c, DT_Polish_Required_Picklist__c, DT_Hours_Range__c, DT_Languages__c
            FROM DT_Job_Offers__c
            WHERE DT_IsExposed__c = true 
                AND RecordTypeId = :DT_Utils.getRecTypeIdByDevName(DT_Utils.JOB_OFFER_RECORD_TYPE_DEVELOPER_NAME_JOB_OFFER, DT_Utils.SOBJ_JOB_OFFER)
        ];
    }

    @AuraEnabled
    public static List<DT_Internship_Application__c> getAllInternshipApplications() {
        List <User> currentUser = [
            SELECT ContactId
            FROM User
            WHERE Id =: UserInfo.getUserId()
            LIMIT 1
        ];
        Id current = currentUser[0].ContactId;
            return [
                SELECT Id, Name, toLabel(DT_Status__c) statusLabel , DT_Student__c, DT_Provider_Institution__c, DT_Student__r.Name
                FROM DT_Internship_Application__c
                WHERE DT_Student__c = :current
            ];
        }

    
    @AuraEnabled
    public static List<DT_Internship__c> getAllInternships() {
        return [
            SELECT Id, Name, DT_Name_Of_Position__c, DT_Company_Name__r.Name, 
                DT_Location__c, DT_Internship_Period_From__c, DT_Internship_Period_To__c,
                toLabel(DT_Industry__c) IndustryLabel, DT_Industry__c, DT_Polish_Required__c,
                toLabel(DT_Languages__c) LanguageLabel, DT_Languages__c, DT_Hours_Range__c,
                DT_Salary_Of_Internships__c, DT_Hours_Range_Max__c, DT_Specialty__c, DT_Specialty_Name__c
            FROM DT_Internship__c
            WHERE DT_Is_Exposed__c = true
        ];
    }

    @AuraEnabled
    public static List<DT_Contact_Tag__c> getCurrentUserTags() {
        String userId = userInfo.getUserId();
        List<User> currentUser = [
            SELECT ContactId
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];
        Id currentContactId = currentUser[0].ContactId;

     	return [
            SELECT DT_Tag__r.Id, DT_Contact__r.Id
            FROM DT_Contact_Tag__c
            WHERE  DT_Contact__c =:currentContactId
        ];
    }

    @AuraEnabled
        public static List<DT_Job_Offer_Tags__c> getJobTags() {
            return [
                SELECT DT_Tag__r.Id, DT_Job_Offers__r.Id
                FROM DT_Job_Offer_Tags__c
            ];
    }
}
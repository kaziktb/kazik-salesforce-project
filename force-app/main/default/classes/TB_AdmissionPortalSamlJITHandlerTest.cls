/**
 * Created by adriangawryszewski on 1/11/22.
 */
@isTest
public with sharing class TB_AdmissionPortalSamlJITHandlerTest {

    static final Id samlSsoProviderId = '0LE000000000000';
    static final Id communityId = '0DB000000000000';
    static final Id portalId = '0DB000000000000';
    static final String federationIdentifier = String.valueof(DateTime.now().getTime()) + '@testswps.com';
    static final Map<String, String> attributesEmployee = new Map<String, String>{
            'firstName' => 'Test',
            'lastName' => 'Test1',
            'employeeType' => 'Worker',
            'employeeID' => '12345'
    };
    static final Map<String, String> attributesStudent = new Map<String, String>{
            'firstName' => 'Test',
            'lastName' => 'Test1',
            'employeeType' => 'Student',
            'employeeID' => '12345'
    };

    static final Map<String, String> attributesOther = new Map<String, String>{
            'firstName' => 'Test',
            'lastName' => 'Test1',
            'employeeType' => 'Other',
            'employeeID' => '12345'
    };
    static final String assertion = 'assertion';

    @TestSetup
    static void testSetup() {
        insert new TB_Admission_Defaults__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                TB_Default_Employee_Profile_Name__c = 'SWPS Admissions - DS Specialist',
                TB_Default_Employee_Perm_Set_Name__c = 'TB_SWPS_Admissions_Applicant',
                TB_Default_Student_Profile_Name__c = 'SWPS Admissions - Applicant (Plus)',
                TB_Default_Student_Perm_Set_Name__c = 'TB_SWPS_Admissions_Applicant',
                TB_Base_Employee_Perm_Set_Name__c = 'Th_Badge_Assigner');

    }

    @IsTest
    static void testUserCreateEmployee() {
        /*PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :TB_Admission_Defaults__c.getOrgDefaults().TB_Default_Employee_Perm_Set_Name__c];
        System.assertEquals(0, [SELECT count() FROM User WHERE FederationIdentifier = :federationIdentifier]);
        System.assertEquals(0, [SELECT count() FROM PermissionSetAssignment WHERE PermissionSetId = :permSet.Id AND AssigneeId = : [SELECT Id FROM User WHERE FederationIdentifier = :federationIdentifier]]);
        Test.startTest();
        TB_AdmissionPortalSamlJITHandler handler = new TB_AdmissionPortalSamlJITHandler();
        handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributesEmployee, assertion);
        Test.stopTest();

        User newUser = [SELECT Id, Email, IsActive, CommunityNickname, FederationIdentifier FROM User WHERE FederationIdentifier = :federationIdentifier];
        System.assertEquals(federationIdentifier, newUser.Email);
        System.assertEquals(true, newUser.IsActive);
        System.debug('newUser: ' + newUser);
        System.assertEquals(federationIdentifier, newUser.FederationIdentifier);

        System.assertEquals(0, [SELECT count() FROM User WHERE FederationIdentifier = :federationIdentifier]);
        System.assertEquals(0, [SELECT count() FROM PermissionSetAssignment WHERE PermissionSetId = :permSet.Id AND AssigneeId = :newUser.Id]);*/

    }

    @IsTest
    static void testUserCreateStudent() {
/*        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :TB_Admission_Defaults__c.getOrgDefaults().TB_Default_Employee_Perm_Set_Name__c];
        System.assertEquals(0, [SELECT count() FROM User WHERE FederationIdentifier = :federationIdentifier]);
        System.assertEquals(0, [SELECT count() FROM PermissionSetAssignment WHERE PermissionSetId = :permSet.Id AND AssigneeId = : [SELECT Id FROM User WHERE FederationIdentifier = :federationIdentifier]]);
        Test.startTest();
        TB_AdmissionPortalSamlJITHandler handler = new TB_AdmissionPortalSamlJITHandler();
        handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributesStudent, assertion);
        Test.stopTest();

        User newUser = [SELECT Id, Email, IsActive, CommunityNickname, FederationIdentifier FROM User WHERE FederationIdentifier = :federationIdentifier];
        System.assertEquals(federationIdentifier, newUser.Email);
        System.assertEquals(true, newUser.IsActive);
        System.debug('newUser: ' + newUser);
        System.assertEquals(federationIdentifier, newUser.FederationIdentifier);

        System.assertEquals(1, [SELECT count() FROM User WHERE FederationIdentifier = :federationIdentifier]);
        System.assertEquals(1, [SELECT count() FROM PermissionSetAssignment WHERE PermissionSetId = :permSet.Id AND AssigneeId = :newUser.Id]);*/

    }

    @IsTest
    static void testUserCreateOther() {
/*        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :TB_Admission_Defaults__c.getOrgDefaults().TB_Default_Employee_Perm_Set_Name__c];
        System.assertEquals(0, [SELECT count() FROM User WHERE FederationIdentifier = :federationIdentifier]);
        System.assertEquals(0, [SELECT count() FROM PermissionSetAssignment WHERE PermissionSetId = :permSet.Id AND AssigneeId = : [SELECT Id FROM User WHERE FederationIdentifier = :federationIdentifier]]);
        Test.startTest();
        TB_AdmissionPortalSamlJITHandler handler = new TB_AdmissionPortalSamlJITHandler();
        handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributesOther, assertion);
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM User WHERE FederationIdentifier = :federationIdentifier]);
        System.assertEquals(1, [SELECT count() FROM TB_Log__c]);*/
    }

    @IsTest
    static void testUpdateUserEmployee() {
/*        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :TB_Admission_Defaults__c.getOrgDefaults().TB_Default_Employee_Perm_Set_Name__c];
        Profile p = [SELECT Id From Profile WHERE Name LIKE '%Sys%' LIMIT 1];
        Contact con = new Contact(
                LastName = 'test',
                email = 'test@test.swps.edu.pl'
        );
        User testUser = TB_UserUtils.createNewUser(
                'test',
                'test',
                federationIdentifier,
                p.Id,
                'Europe/Berlin',
                'en_US',
                'UTF-8',
                'en_US',
                con.Id,
                'test@test.swps.edu.pl'
        );
        insert testUser;
        System.assertEquals(0, [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id AND PermissionSetId =: permSet.Id]);

        Test.startTest();
        TB_AdmissionPortalSamlJITHandler handler = new TB_AdmissionPortalSamlJITHandler();
        handler.updateUser(testUser.Id, samlSsoProviderId, communityId, portalId, federationIdentifier, attributesEmployee, assertion);
        Test.stopTest();
        System.assertEquals(0, [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id AND PermissionSetId =: permSet.Id]);*/
    }

    @IsTest
    static void testUpdateUserStudent() {
/*        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :TB_Admission_Defaults__c.getOrgDefaults().TB_Default_Employee_Perm_Set_Name__c];
        Profile p = [SELECT Id From Profile WHERE Name LIKE '%Sys%' LIMIT 1];
        Contact con = new Contact(
                LastName = 'test',
                email = 'test@test.swps.edu.pl'
        );
        User testUser = TB_UserUtils.createNewUser(
                'test',
                'test',
                federationIdentifier,
                p.Id,
                'Europe/Berlin',
                'en_US',
                'UTF-8',
                'en_US',
                con.Id,
                'test@test.swps.edu.pl'
        );
        insert testUser;
        System.assertEquals(0, [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id AND PermissionSetId =: permSet.Id]);

        Test.startTest();
        TB_AdmissionPortalSamlJITHandler handler = new TB_AdmissionPortalSamlJITHandler();
        handler.updateUser(testUser.Id, samlSsoProviderId, communityId, portalId, federationIdentifier, attributesStudent, assertion);
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id AND PermissionSetId =: permSet.Id]);*/
    }
}
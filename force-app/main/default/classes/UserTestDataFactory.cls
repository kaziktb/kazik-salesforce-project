@IsTest
public class UserTestDataFactory {

    public static User createAdminUser(Boolean withInsert) {
        Id adminProfileId = Utils.getProfileIdByName(Label.System_Administrator_Profile_Name);
        Id adminRoleId = Utils.getUserRoleIdByName('Admin');

        return withInsert
            ? new UserTestData()
                .withProfile(adminProfileId)
                .withRole(adminRoleId)
                .asActive()
                .save()
                .get()
            : new UserTestData()
                .withProfile(adminProfileId)
                .withRole(adminRoleId)
                .asActive()
                .get();
    }

    public static User createAdminUser(String userName, Boolean withInsert) {
        Id adminProfileId = Utils.getProfileIdByName(Label.System_Administrator_Profile_Name);
        Id adminRoleId = Utils.getUserRoleIdByName('Admin');

        return withInsert
            ? new UserTestData()
                .withProfile(adminProfileId)
                .withRole(adminRoleId)
                .withUserName(userName)
                .asActive()
                .save()
                .get()
            : new UserTestData()
                .withProfile(adminProfileId)
                .withRole(adminRoleId)
                .withUserName(userName)
                .asActive()
                .get();
    }

    public static User createAdminUserWithPermissionSetAssigned(String userName) {
        User adminUser = createAdminUser(userName, true);

        Id careerServicesAdministratorPermissionSetId = Utils.getPermissionSetIdByName(Constants.PERMISSION_SET_CAREER_SERVICES_ADMINISTRATOR_API_NAME);
        insert Utils.createPermissionSetAssignment(adminUser.Id, careerServicesAdministratorPermissionSetId);

        return adminUser;
    }

    public static User createStudentUser(Boolean withInsert, Contact studentContact) {
        Id studentProfileId = Utils.getProfileIdByName(Constants.PROFILE_SWPS_STUDENT_NAME);

        if (studentContact == null) {
            Id contactStudentRecordTypeId = Utils.getRecordTypeIdByDevName(
                Contact.getSObjectType(),
                Constants.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME
            );
            studentContact = new ContactTestData().withRecordType(contactStudentRecordTypeId).save().get();
        }

        return withInsert
            ? new UserTestData()
                .withProfile(studentProfileId)
                .withContact(studentContact.Id)
                .asActive()
                .save()
                .get()
            : new UserTestData()
                .withProfile(studentProfileId)
                .withContact(studentContact.Id)
                .asActive()
                .get();
    }

    public static User createApplicantUser(Boolean withInsert, Contact studentContact) {
        Id applicantProfileId = Utils.getProfileIdByName(Constants.PROFILE_SWPS_ADMISSIONS_APPLICANT_NAME);

        if (studentContact == null) {
            Id contactStudentRecordTypeId = Utils.getRecordTypeIdByDevName(
                Contact.getSObjectType(),
                Constants.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME
            );
            studentContact = new ContactTestData().withRecordType(contactStudentRecordTypeId).save().get();
        }

        return withInsert
            ? new UserTestData()
                .withProfile(applicantProfileId)
                .withContact(studentContact.Id)
                .asActive()
                .save()
                .get()
            : new UserTestData()
                .withProfile(applicantProfileId)
                .withContact(studentContact.Id)
                .asActive()
                .get();
    }

    public static User createProcessAutomationUser(Boolean withInsert, String userName) {
        Id systemAdministratorProfileId = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator_Profile_Name LIMIT 1].Id;

        return withInsert
            ? new UserTestData()
                .withProfile(systemAdministratorProfileId)
                .withUserName(userName)
                .asActive()
                .save()
                .get()
            : new UserTestData()
                .withProfile(systemAdministratorProfileId)
                .withUserName(userName)
                .asActive()
                .get();
    }

    public static User createPlatformUser(Boolean withInsert, String userName) {
        Id platformProfileId = Utils.getProfileIdByName(Constants.PROFILE_SWPS_PLATFORM_PROFILE_NAME);

        return withInsert
            ? new UserTestData()
                .withProfile(platformProfileId)
                .withUserName(userName)
                .asActive()
                .save()
                .get()
            : new UserTestData()
                .withProfile(platformProfileId)
                .withUserName(userName)
                .asActive()
                .get();
    }

    public static User createCommunityStudentUser(Id contactId, String userName, String communityNickname, Boolean withInsert) {
        Id platformProfileId = Utils.getProfileIdByName(Constants.PROFILE_SWPS_STUDENT_NAME);

        return withInsert
            ? new UserTestData()
                .withContact(contactId)
                .withProfile(platformProfileId)
                .withUserName(userName)
                .withCommunityNickname(communityNickname)
                .asActive()
                .save()
                .get()
            : new UserTestData()
                .withContact(contactId)
                .withProfile(platformProfileId)
                .withUserName(userName)
                .withCommunityNickname(communityNickname)
                .asActive()
                .get();
    }

    public static User createCareerServicesUser(String userName, Boolean withInsert) {
        Id careerServicesProfileId = Utils.getProfileIdByName(Constants.PROFILE_SWPS_CAREER_SERVICES_PROFILE_NAME);

        UserTestData testData = new UserTestData()
            .withProfile(careerServicesProfileId)
            .withUserName(userName)
            .asActive();

        return withInsert ? testData.save().get() : testData.get();
    }

    public static User createCareerServicesUserWithPermissionSetAssigned(String userName) {
        User careerServicesUser = createCareerServicesUser(userName, true);

        Id careerServicesEmployeePermissionSetId = Utils.getPermissionSetIdByName(Constants.PERMISSION_SET_CAREER_SERVICES_EMPLOYEE_API_NAME);
        insert Utils.createPermissionSetAssignment(careerServicesUser.Id, careerServicesEmployeePermissionSetId);

        return careerServicesUser;
    }
}
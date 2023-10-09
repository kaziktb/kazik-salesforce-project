@IsTest
public with sharing class AccountTestDataFactory {
    public static Account createBaseBusinessOrganizationAccount(String status, Boolean withInsert) {
        Id businessOrganizationRecordTypeId = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME);

        return withInsert
            ? new AccountTestData()
                .withRecordType(businessOrganizationRecordTypeId)
                .withStatus(status)
                .save()
                .get()
            : new AccountTestData()
                .withRecordType(businessOrganizationRecordTypeId)
                .withStatus(status)
                .get();
    }

    public static Account createAdministrativeAccount(Boolean withInsert) {
        Id administrativeRecordTypeId = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_ADMINISTRATIVE_API_NAME);

        return withInsert
            ? new AccountTestData()
                .withRecordType(administrativeRecordTypeId)
                .save()
                .get()
            : new AccountTestData()
                .withRecordType(administrativeRecordTypeId)
                .get();
    }

    public static Account createAcademicProgram(Boolean withInsert) {
        Id academicProgramRecordTypeId = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_ACADEMIC_PROGRAM_API_NAME);

        AccountTestData testData = new AccountTestData()
            .withRecordType(academicProgramRecordTypeId)
            .withSpecialtyPL(AccountTestData.DEFAULT_SPECIALTY_PL)
            .withSpecialtyEN(AccountTestData.DEFAULT_SPECIALTY_EN)
            .withFieldOfStudyPL(AccountTestData.DEFAULT_FIELD_OF_STUDY_PL)
            .withFieldOfStudyEN(AccountTestData.DEFAULT_FIELD_OF_STUDY_EN)
            .withStatus(Constants.ACCOUNT_STATUS_ACTIVE_API_NAME)
            .withAccountType(Constants.ACCOUNT_TYPE_ACADEMIC_PROGRAM_API_NAME);
        
        return withInsert ? testData.save().get() : testData.get();
    }

    public static Account createSpecialty(Boolean withInsert) {
        Id specialtyRecordTypeId = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME);

        return withInsert
            ? new AccountTestData()
                .withRecordType(specialtyRecordTypeId)
                .withAccountType(Constants.ACCOUNT_TYPE_SPECIALTY_API_NAME)
                .withSpecialtyPL(AccountTestData.DEFAULT_SPECIALTY_PL)
                .withSpecialtyEN(AccountTestData.DEFAULT_SPECIALTY_EN)
                .withStatus(Constants.ACCOUNT_STATUS_ACTIVE_API_NAME)
                .save()
                .get()
            : new AccountTestData()
                .withRecordType(specialtyRecordTypeId)
                .withAccountType(Constants.ACCOUNT_TYPE_SPECIALTY_API_NAME)
                .withSpecialtyPL(AccountTestData.DEFAULT_SPECIALTY_PL)
                .withSpecialtyEN(AccountTestData.DEFAULT_SPECIALTY_EN)
                .withStatus(Constants.ACCOUNT_STATUS_ACTIVE_API_NAME)
                .get();
    }

    public static Account createPathway(Boolean withInsert) {
        Id specialtyRecordTypeId = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME);

        return withInsert
            ? new AccountTestData()
                .withRecordType(specialtyRecordTypeId)
                .withAccountType(Constants.ACCOUNT_TYPE_PATHWAY_API_NAME)
                .withSpecialtyPL(AccountTestData.DEFAULT_SPECIALTY_PL)
                .withSpecialtyEN(AccountTestData.DEFAULT_SPECIALTY_EN)
                .withStatus(Constants.ACCOUNT_STATUS_ACTIVE_API_NAME)
                .save()
                .get()
            : new AccountTestData()
                .withRecordType(specialtyRecordTypeId)
                .withAccountType(Constants.ACCOUNT_TYPE_PATHWAY_API_NAME)
                .withSpecialtyPL(AccountTestData.DEFAULT_SPECIALTY_PL)
                .withSpecialtyEN(AccountTestData.DEFAULT_SPECIALTY_EN)
                .withStatus(Constants.ACCOUNT_STATUS_ACTIVE_API_NAME)
                .get();
    }

    public static Account createDepartment(Boolean withInsert) {
        Id departmentRecordTypeId = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_DEPARTMENT_API_NAME);

        return withInsert
            ? new AccountTestData()
                .withRecordType(departmentRecordTypeId)
                .save()
                .get()
            : new AccountTestData()
                .withRecordType(departmentRecordTypeId)
                .get();
    }
}
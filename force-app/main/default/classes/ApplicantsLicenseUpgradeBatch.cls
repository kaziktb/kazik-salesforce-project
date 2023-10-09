public with sharing class ApplicantsLicenseUpgradeBatch implements Database.Batchable<SObject> {

    private static final Id ApplicantProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_ADMISSIONS_APPLICANT_PROFILE_NAME);
    private static final Id StudentProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_STUDENT_PROFILE_NAME);

    private static final String QUERY = 'SELECT Id FROM User WHERE User.ProfileId = \'' + ApplicantProfileId + '\' AND FederationIdentifier != NULL AND IsActive = TRUE';

    public Database.QueryLocator start(Database.BatchableContext context) {
        if(Test.isRunningTest()) {
            return Database.getQueryLocator(QUERY + ' AND FederationIdentifier LIKE \'%.test%\'');
        }

        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext context, List<User> users) {
        for (User user : users) {
            user.ProfileId = StudentProfileId;
        }

        update users;
    }

    public void finish(Database.BatchableContext context) {

    }
}
public without sharing class StudentsDeactivationBatch implements Database.Batchable<SObject> {
    private static final String STUDENT_PROFILE_ID = DT_Utils.getProfileIdByName(DT_Utils.SWPS_STUDENT_PROFILE_NAME);
    private static final String CONTACT_STUDENT_RECORD_TYPE_ID = DT_Utils.getRecTypeIdByDevName(
        DT_Utils.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME, Contact.getSObjectType().getDescribe().getName()
    );
    private static final String PLATFORM_LICENSE_CLAUSE = 'Profile.UserLicense.Name = \'Salesforce Platform\' AND ' + createInactivityClause(1);
    private static final String STUDENT_LICENSE_CLAUSE = 'ProfileId = \'' + STUDENT_PROFILE_ID + '\' ' +
        'AND ContactId != NULL AND Contact.RecordTypeId = \'' + CONTACT_STUDENT_RECORD_TYPE_ID + '\' AND ' + createInactivityClause(3);

    private static String query = 'SELECT Id ' +
        'FROM User ' +
        'WHERE IsActive = TRUE ' +
        'AND Do_Not_Deactivate__c = false ' +
        'AND (' +
            '(' + PLATFORM_LICENSE_CLAUSE + ') OR (' + STUDENT_LICENSE_CLAUSE + ')' +
        ')';

    public Database.QueryLocator start(Database.BatchableContext context) {
        if (Test.isRunningTest()) {
            query += ' LIMIT 10';

        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<User> users) {
        for (User user : users) {
            user.IsActive = false;
        }
        update users;
    }

    public void finish(Database.BatchableContext context) {

    }

    private static String createInactivityClause(Integer daysWithoutInactivity) {
        return '(LastLoginDate < ' + Datetime.now().addDays(-daysWithoutInactivity).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' OR LastLoginDate = NULL)';
    }
}
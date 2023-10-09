public without sharing class TB_vu_QuestionsControllerSharingSkip {

    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';

    public static Map<Id, Boolean> userIdToIsStudent(List<Id> userIds) {
        Profile studentProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = :SWPS_STUDENT_PROFILE
        ];
        Map<Id, Boolean> userIdToIsStudent = new Map<Id, Boolean>();
        for (User user : [
            SELECT ProfileId
            FROM User WHERE Id IN :userIds
        ]) {
            Boolean isStudent = user.ProfileId == studentProfile.Id;
            userIdToIsStudent.put(user.Id, isStudent);
        }
        return userIdToIsStudent;
    }

    public static Map<Id, String> userIdToName(List<Id> userIds) {
        Map<Id, String> idToName = new Map<Id, String>();
        for (User u : [SELECT FirstName, LastName FROM User WHERE Id IN :userIds]) {
            String name = u.FirstName + ' ' + u.LastName;
            idToName.put(u.Id, name);
        }
        return idToName;
    }
}
public class DT_TaskTriggerHandler {
    public static void studentCannotDeleteTask (List<Task> tasks) {

        for (Task task : tasks) {
            if(hasStudentProfile()) {
                task.addError(System.Label.DT_No_Permission_To_Delete);
            }
        }
    }

    private static Boolean hasStudentProfile () {
        return UserInfo.getProfileId() == DT_Utils.getProfileIdByName(DT_Utils.SWPS_STUDENT_PROFILE_NAME);
    }
}
public with sharing class TB_re_TaskCreator {

    @InvocableMethod(label='createTasks')
    public static void createTasks(List<List<Task>> tasksToCreate) {
        Set<Id> userIds = new Set<Id>();
        List<Task> tasksToCreateElement = tasksToCreate[0];
        for (Task task : tasksToCreateElement) {
            userIds.add(task.OwnerId);
        }
        List<User> usersToActivate = [
            SELECT Id, IsActive
            FROM User
            WHERE Id IN: userIds
            AND IsActive = FALSE
        ];
        for (User userToActivate : usersToActivate) {
            userToActivate.IsActive = true;
        }
        try {
            Database.executeBatch(new TB_re_TaskCreatorBatch(usersToActivate, tasksToCreateElement));
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_re_TaskCreator.class);
        }
    }

    public static void insertTasks(List<Task> tasksToCreateElement) {
        try {
            insert tasksToCreateElement;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_re_TaskCreator.class);
        }
    }

}
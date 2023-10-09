public without sharing class TB_re_TaskCreatorBatch implements Database.Batchable<User>, Database.Stateful{

    private List<User> users;
    private List<Task> tasksToCreate;


    public TB_re_TaskCreatorBatch(List<User> users, List<Task> tasksToCreate) {
        this.users = users;
        this.tasksToCreate = tasksToCreate;
    }

    public List<User> start(Database.BatchableContext context) {
        return users;
    }

    public void execute(Database.BatchableContext context, List<User> users) {
        update users;
    }

    public void finish (Database.BatchableContext context) {
        System.enqueueJob(new TB_re_TaskCreatorQueueable(tasksToCreate));
    }

}
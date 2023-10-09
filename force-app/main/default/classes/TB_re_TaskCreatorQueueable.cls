public without sharing class TB_re_TaskCreatorQueueable implements Queueable {

    public List<Task> tasksToCreate;

    public TB_re_TaskCreatorQueueable(List<Task> tasksToCreate) {
        this.tasksToCreate = tasksToCreate;
    }

    public void execute(QueueableContext context) {
        TB_re_TaskCreator.insertTasks(tasksToCreate);
    }

}
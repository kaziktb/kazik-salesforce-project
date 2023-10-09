public without sharing class TB_ObjectSharingQueueable implements Queueable {

    public List<SObject> sharesToCreate;

    public TB_ObjectSharingQueueable(List<SObject> sharesToCreate) {
        this.sharesToCreate = sharesToCreate;
    }

    public void execute(QueueableContext context) {
        TB_ObjectSharing.insertShares(sharesToCreate);
    }

}
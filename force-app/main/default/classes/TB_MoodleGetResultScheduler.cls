global class TB_MoodleGetResultScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        TB_MoodleGetResultBatch sampleBatchObj = new TB_MoodleGetResultBatch();
        database.executeBatch(sampleBatchObj, 50);
    }
}
global class TB_vu_DeleteUnusedFilesSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new TB_vu_DeleteUnusedFilesBatch());
    }
}
public class TB_pdo_GetPdoStatusScheduler implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        TB_pdo_PDORestWebService.synchronizePdoStatuses();
    }
}
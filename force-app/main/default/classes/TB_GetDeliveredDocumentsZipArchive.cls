public class TB_GetDeliveredDocumentsZipArchive implements Queueable {
    public ContentVersion cv;
    private Zippex zipFileData;
    
    public TB_GetDeliveredDocumentsZipArchive(ContentVersion cv, Zippex zipFileData) {
        this.cv = cv;
        this.zipFileData = zipFileData;
    }

    public void execute(QueueableContext context) {
        try{
            this.cv.VersionData = zipFileData.getZipArchive();
            this.cv.TB_Imported__c = true;
            update this.cv;
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e, TB_GetDeliveredDocumentsZipArchive.class);
        }
    }
}
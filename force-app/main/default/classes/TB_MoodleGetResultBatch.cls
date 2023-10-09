public without sharing class TB_MoodleGetResultBatch  implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    private string token;
    private List<TB_Application_Qualification__c> appQuaToSave = new List<TB_Application_Qualification__c>();


    public Iterable<sObject> start(Database.BatchableContext BC) {
        token = TB_MoodleConstants.MOODLE_DEF.TB_Moodle_Token__c;
        Datetime dateTimeLimit = Datetime.now();
        return Database.getQueryLocator([
                SELECT
                        Id,
                        TB_Moodle_Exam_ID__c,
                        TB_Moodle_Id__c
                FROM TB_Application_Qualification__c
                WHERE TB_Moodle_Exam_ID__c != NULL
                AND TB_Moodle_Id__c != NULL
                AND TB_Moodle_Test_Result_Points__c = NULL
                AND (TB_Qualification_Available_From__c <:dateTimeLimit
                OR TB_Moodle_Exam_Started__c = TRUE)
        ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        for (TB_Application_Qualification__c aq : (List<TB_Application_Qualification__c>)scope){
            TB_MoodleWebService.WrapperClass wrapperClass = new TB_MoodleWebService.WrapperClass();
            wrapperClass.appQualId = aq.Id;
            wrapperClass.methodToken = TB_MoodleConstants.FUNC_COURSE_RESULT;
            wrapperClass.courseId = aq.TB_Moodle_Exam_ID__c.split('=')?.get(1).split(TB_MoodleConstants.USER_USERNAME).get(0);
            wrapperClass.moodleUserId = aq.TB_Moodle_Id__c;
            TB_Application_Qualification__c result = (TB_Application_Qualification__c)TB_MoodleWebService.rightMoodleMethod(wrapperClass, token);
            if (result != null && result.TB_Moodle_Test_Result_Points__c != null) {
                appQuaToSave.add(result);
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        List<TB_Log__c> systemLogList = new List<TB_Log__c>();
        List<Database.SaveResult> saveResults = Database.update(appQuaToSave, false);
        for (Database.SaveResult sr : saveResults){
            if (!sr.isSuccess()) {
                systemLogList.add(TB_LogUtils.registerLog(sr.getErrors().get(0).message, TB_MoodleGetResultBatch.class));
            }
        }
        insert systemLogList;
    }


}
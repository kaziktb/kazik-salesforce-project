/**
 * Created by Aneta on 26/06/2023.
 */

global with sharing class TB_KReMDictionaryControllerSchedulable implements Schedulable {

    public static final String HS_EXAM_SUBJECT_RT_ID = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_High_School_Exam_Subject').getRecordTypeId();

    global void execute(SchedulableContext sc) {
        updateHSExamSubjectsCodes();
    }

    @Future(Callout=true)
    public static void updateHSExamSubjectsCodes() {
        try {
            List<TB_KReMSIOIntegrator.SubjectWrapper> subjectWrappers = TB_KReMSIOIntegrator.getSheets();
            List<TB_Admissions_Dictionary__c> dictionaryOfSubjects = [
                    SELECT Id, Name
                    FROM TB_Admissions_Dictionary__c
                    WHERE RecordTypeId = :HS_EXAM_SUBJECT_RT_ID
                    AND TB_Available_For_HS_Exams__c INCLUDES ('New_Polish_HS_Exam_Since_2005')
            ];

            List<TB_Admissions_Dictionary__c> newCodesDictionary = new List<TB_Admissions_Dictionary__c>();
            for (TB_Admissions_Dictionary__c singleDictionarySubject : dictionaryOfSubjects) {
                singleDictionarySubject.TB_KReM_Subject_Code__c = '';
                for (TB_KReMSIOIntegrator.SubjectWrapper singleWrapper : subjectWrappers) {
                    if (singleWrapper.subject?.trim() == singleDictionarySubject.Name?.trim()
                            && singleWrapper.code.substring(3, 4).toLowerCase() == 'p'
                    ) {
                        if(!(String.valueOf(singleDictionarySubject.TB_KReM_Subject_Code__c)
                                .toLowerCase()).contains(singleWrapper.code.substring(0, 4).toLowerCase())) {
                            singleDictionarySubject.TB_KReM_Subject_Code__c += singleWrapper.code.substring(0, 4) + ';';
                        }
                    }
                }
                newCodesDictionary.add(singleDictionarySubject);
            }

            update newCodesDictionary;
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }
}
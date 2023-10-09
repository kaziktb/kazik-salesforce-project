public with sharing class TB_FinalReportController {

    @AuraEnabled
    public static DataWrapper getEE(Id ees) {
        Boolean isFromSF = ees != null;
        List<TB_Employee_Evaluation__c> allEEval = new List<TB_Employee_Evaluation__c>();
        Set<Id> supervisorEESetId = new Set<Id>();
        Map<id, TB_Employee_Evaluation__c> parentEvaluation = new Map<Id, TB_Employee_Evaluation__c>();
        Map<id, TB_Employee_Evaluation__c> childEvaluation = new Map<Id, TB_Employee_Evaluation__c>();
        Map<id, id> parentToChildEEId = new Map<Id, id>();
        List<FinalReportWrapper> finalReportWrapperList = new List<TB_FinalReportController.FinalReportWrapper>();
        try {
            List<String> conditionStage = new List<String>{
                    TB_Constants.EE_EVALUATION_STAGE_TYPE_FINAL_ASSESSMENT,
                    TB_Constants.EE_EVALUATION_STAGE_TYPE_RECTOR_DECISION,
                    TB_Constants.EE_EVALUATION_STAGE_TYPE_SUPERVISOR_DECISION
            };
            Id contactId = [SELECT Id From Contact WHERE TB_User__c = :UserInfo.getUserId() Limit 1].Id;
            Integer index = 1;
            String condition = ' WHERE TB_Evaluation_Stage_Type__c IN:conditionStage';
            condition += isFromSF ? ' AND TB_Employee_Evaluation_Process__c =: ees ' : ' AND TB_Supervisor__c = :contactId ';
            String query = 'SELECT Name, TB_Evaluated__r.Title, TB_Evaluated__r.TB_Employee_Group__c, TB_Faculty_Institute__c, TB_Evaluator__r.Name, TB_Evaluated__r.Name, TB_Supervisor__r.Name, TB_Process_Type__c, TB_Supervisor_Proposal_Mark__c, TB_Employee_Evaluation__c, TB_Employee_Evaluation__r.TB_Supervisor__r.Name, TB_Final_Mark__c, TB_Evaluation_Stage_Type__c, TB_Supervisor_Decision_Mark__c, TB_Rector_Decision_Mark__c From TB_Employee_Evaluation__c' + condition;
            allEEval.addAll((List<TB_Employee_Evaluation__c>) Database.query(query));
            for (TB_Employee_Evaluation__c eeSupervisor : allEEval) {
                supervisorEESetId.add(eeSupervisor.Id);
            }
            for (TB_Employee_Evaluation__c ee : [SELECT Name, TB_Evaluated__r.Title, TB_Evaluated__r.TB_Employee_Group__c, TB_Faculty_Institute__c, TB_Evaluator__r.Name, TB_Evaluated__r.Name, TB_Supervisor__r.Name, TB_Process_Type__c, TB_Supervisor_Proposal_Mark__c, TB_Employee_Evaluation__c, TB_Employee_Evaluation__r.TB_Supervisor__r.Name, TB_Final_Mark__c, TB_Evaluation_Stage_Type__c, TB_Supervisor_Decision_Mark__c, TB_Rector_Decision_Mark__c FROM TB_Employee_Evaluation__c WHERE TB_Employee_Evaluation__c IN:supervisorEESetId]) {
                allEEval.add(ee);

            }
            for (TB_Employee_Evaluation__c ee : allEEval) {
                if (ee.TB_Employee_Evaluation__c == null) {
                    parentEvaluation.put(ee.Id, ee);
                } else {
                    childEvaluation.put(ee.Id, ee);
                    parentToChildEEId.put(ee.TB_Employee_Evaluation__c, ee.Id);
                }
            }
            for (TB_Employee_Evaluation__c ee : parentEvaluation.values()) {
                finalReportWrapperList.add(prepareWrapper(ee, index, childEvaluation.get(parentToChildEEId.get(ee.Id))));
                index++;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return new DataWrapper(finalReportWrapperList, UserInfo.getLanguage(), UserInfo.getName());
    }

    @AuraEnabled
    public static void insertEERRecord() {
        try {
            Contact contact = [SELECT Id, Name From Contact WHERE TB_User__c = :UserInfo.getUserId()];
            TB_Employee_Evaluation_Report__c eer = new TB_Employee_Evaluation_Report__c();
            eer.Name = Label.TB_Final_Report + '_' + contact.Name + '_' + Date.today().year();
            eer.TB_Supervisor__c = contact.Id;
            eer.TB_Report_Date_Time__c = Datetime.now();
            insert eer;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Option> getEEPOptions() {
        List<Option> optionList = new List<TB_FinalReportController.Option>();
        for (TB_Employee_Evaluation_Process__c eep : [SELECT Name, Id From TB_Employee_Evaluation_Process__c]) {
            Option option = new Option();
            option.label = eep.Name;
            option.value = eep.Id;
            optionList.add(option);
        }
        return optionList;

    }

    private static FinalReportWrapper prepareWrapper(TB_Employee_Evaluation__c ee, Integer index, TB_Employee_Evaluation__c childEvaluation) {
        FinalReportWrapper finalReportWrapper = new FinalReportWrapper(ee, index);
        fillPath(finalReportWrapper, ee, childEvaluation);
        Boolean isChange = false;
        String mark = '';
        if (ee.TB_Evaluation_Stage_Type__c != TB_Constants.EE_EVALUATION_STAGE_TYPE_FINAL_ASSESSMENT) {
            if (ee.TB_Evaluation_Stage_Type__c == TB_Constants.EE_EVALUATION_STAGE_TYPE_SUPERVISOR_DECISION && ee.TB_Supervisor_Decision_Mark__c != ee.TB_Final_Mark__c && ee.TB_Supervisor_Decision_Mark__c != TB_Constants.EE_EVALUATION_DECISION_MARK_WITHOUT_CHANGES) {
                isChange = true;
                mark = TB_SObjectUtils.getPicklistTranslate(ee.TB_Supervisor_Decision_Mark__c, TB_Employee_Evaluation__c.TB_Supervisor_Decision_Mark__c);
            }
            finalReportWrapper.isDeanAppeal = getValueByLanguage(UserInfo.getLanguage(), String.valueOf(isChange));
            finalReportWrapper.appealUpheld = mark;
        }
        isChange = false;
        mark = '';
        if (ee.TB_Evaluation_Stage_Type__c == TB_Constants.EE_EVALUATION_STAGE_TYPE_RECTOR_DECISION) {
            if (ee.TB_Rector_Decision_Mark__c != ee.TB_Final_Mark__c && ee.TB_Rector_Decision_Mark__c != TB_Constants.EE_EVALUATION_DECISION_MARK_WITHOUT_CHANGES) {
                isChange = true;
                mark = TB_SObjectUtils.getPicklistTranslate(ee.TB_Rector_Decision_Mark__c, TB_Employee_Evaluation__c.TB_Rector_Decision_Mark__c);
            }
            finalReportWrapper.isRectorAppeal = getValueByLanguage(UserInfo.getLanguage(), String.valueOf(isChange));
            finalReportWrapper.appealUpheld = mark;
        }
        index++;

        return finalReportWrapper;
    }

    private static void fillPath(FinalReportWrapper finalReportWrapper, TB_Employee_Evaluation__c parentEE, TB_Employee_Evaluation__c childEE) {
        List<TB_Employee_Evaluation__c> eeList = new List<TB_Employee_Evaluation__c>{
                parentEE
        };
        if (childEE != null) {
            eeList.add(childEE);
            finalReportWrapper.finalMarkAssessorName = childEE.TB_Employee_Evaluation__r.TB_Supervisor__r.Name;
        } else {
            finalReportWrapper.finalMarkAssessorName = parentEE.TB_Supervisor__r.Name;
        }
        for (TB_Employee_Evaluation__c ee : eeList) {
            if (ee.TB_Process_Type__c == TB_Constants.EE_PROCESS_TYPE_DIDACTIC) {
                finalReportWrapper.didacticAssessors = ee.TB_Evaluator__r.Name;
                finalReportWrapper.didacticApprover = ee.TB_Supervisor__r.Name;
                finalReportWrapper.didacticAssessment = TB_SObjectUtils.getPicklistTranslate(ee.TB_Supervisor_Proposal_Mark__c, TB_Employee_Evaluation__c.TB_Supervisor_Proposal_Mark__c);
            } else if (ee.TB_Process_Type__c == TB_Constants.EE_PROCESS_TYPE_SCIENTIST) {
                finalReportWrapper.researchAssessors = ee.TB_Evaluator__r.Name;
                finalReportWrapper.researchApprover = ee.TB_Supervisor__r.Name;
                finalReportWrapper.researchAssessment = TB_SObjectUtils.getPicklistTranslate(ee.TB_Supervisor_Proposal_Mark__c, TB_Employee_Evaluation__c.TB_Supervisor_Proposal_Mark__c);
            }
        }
    }

    private static String getValueByLanguage(String language, String value) {
        String returnValue = TB_Constants.languageToFieldsTranMap.containsKey(language) ? TB_Constants.languageToFieldsTranMap.get(language).get(value) : TB_Constants.languageToFieldsTranMap.get(TB_Constants.LANGUAGE_EN).get(value);
        return returnValue;
    }

    public class DataWrapper {
        @AuraEnabled public List<FinalReportWrapper> finalReportWrappers;
        @AuraEnabled public String userLanguage;
        @AuraEnabled public String userName;

        public DataWrapper(List<FinalReportWrapper> finalReportWrappers, String language, String userName) {
            this.finalReportWrappers = finalReportWrappers;
            this.userLanguage = language;
            this.userName = userName;
        }
    }

    public class FinalReportWrapper {
        @AuraEnabled public Integer lp;
        @AuraEnabled public String title;
        @AuraEnabled public String name;
        @AuraEnabled public String evaluationPath;
        @AuraEnabled public String unit;
        @AuraEnabled public String didacticAssessors;
        @AuraEnabled public String didacticApprover;
        @AuraEnabled public String didacticAssessment;
        @AuraEnabled public String researchAssessors;
        @AuraEnabled public String researchApprover;
        @AuraEnabled public String researchAssessment;
        @AuraEnabled public String finalMarkAssessorName;
        @AuraEnabled public String finalAssessmentBeforeAppeal;
        @AuraEnabled public String isDeanAppeal;
        @AuraEnabled public String isRectorAppeal;
        @AuraEnabled public String appealUpheld;
        @AuraEnabled public String effectsAssessment;
        @AuraEnabled public String shortInfo;

        public FinalReportWrapper(TB_Employee_Evaluation__c ee, Integer index) {
            this.lp = index;
            this.title = ee.TB_Evaluated__r.Title;
            this.name = ee.TB_Evaluated__r.Name;
            this.unit = ee.TB_Faculty_Institute__c;
            this.evaluationPath = TB_SObjectUtils.getPicklistTranslate(ee.TB_Evaluated__r.TB_Employee_Group__c, Contact.TB_Employee_Group__c);
            this.finalAssessmentBeforeAppeal = TB_SObjectUtils.getPicklistTranslate(ee.TB_Final_Mark__c, TB_Employee_Evaluation__c.TB_Final_Mark__c);
        }
    }

    public class Option {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
}
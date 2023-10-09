/**
 * Created by Aneta on 06/08/2021.
 */

public with sharing class TB_FormsNavigationController {

    public static List<String> roleFieldNames = new List<String> {
        'Evaluated', 'Evaluator','Supervisor', 'Rector', 'Administrator'
    };

    @AuraEnabled
    public static String getNavigationUrl() {
        String navigationUrl = '';
        TB_Community_Link__mdt communityLink = TB_Community_Link__mdt.getInstance('TB_Link_To_Home_Page');
        TB_Community_Link__mdt formPage = TB_Community_Link__mdt.getInstance('TB_Link_To_Form');
        navigationUrl += communityLink.TB_Path__c + formPage.TB_Path__c + '/';
        return navigationUrl;
    }

    @AuraEnabled
    public static String getUrlForActivityStage(Id currentStageId) {

        String currentUserId = UserInfo.getUserId();

        TB_Employee_Evaluation_Stage__c currentStage = [
            SELECT TB_Employee_Evaluation__r.TB_Science_Cloud_Employee__c,
                TB_Employee_Stage_Type__c, TB_Evaluated__r.TB_User__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id = :currentStageId
        ];

        if(
            currentStage.TB_Evaluated__r.TB_User__c == currentUserId &&
                currentStage.TB_Employee_Stage_Type__c == TB_Constants.EEPS_TYPE_ACADEMIC_ACTIVITY_REPORT
            ) {
            return currentStage.TB_Employee_Evaluation__r.TB_Science_Cloud_Employee__c;
        }
        return null;
    }

    @AuraEnabled
    public static List<TB_Employee_Evaluation_Stage__c> getStagesForNavigation(Id currentStageId) {

        String currentUserRole;
        String currentUserId = UserInfo.getUserId();

        TB_Employee_Evaluation_Stage__c currentStage = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Evaluated__r.TB_User__c,
                TB_Evaluator__r.TB_User__c, TB_Supervisor__r.TB_User__c, TB_Rector__r.TB_User__c,
                TB_Administrator__r.TB_User__c, TB_Employee_Evaluation__c, TB_Employee_Evaluation__r.TB_Employee_Evaluation__c,
                TB_Employee_Evaluation__r.TB_Scientist_And_Didactic__c, TB_Employee_Evaluation__r.TB_Scientist_And_Scientist__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: currentStageId
        ];

        for (String singleFieldName : roleFieldNames) {
            Contact con = (Contact) currentStage.getSObject('TB_' + singleFieldName + '__r');
            if(con != null) {
                if(con.TB_User__c == currentUserId) {
                    currentUserRole = singleFieldName;
                }
            }
        }

        List<TB_Employee_Evaluation_Stage__c> evaluationStages = [
            SELECT Id, toLabel(TB_Employee_Stage_Type__c) TB_Evaluation_Stage_Type_Label, TB_Evaluation_Stage_Status__c, TB_Employee_Stage_Type__c, TB_Evaluation_Stage_Order__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE TB_Employee_Evaluation__c =: currentStage.TB_Employee_Evaluation__c
            AND TB_Evaluation_Stage_Status__c !=''
            ORDER BY TB_Evaluation_Stage_Order__c
        ];

        Set<TB_Employee_Evaluation_Stage__c> navigationStages = new Set<TB_Employee_Evaluation_Stage__c>();

        List<String> constantsStageTypes =  new List<String> {
            TB_Constants.EEPS_TYPE_ACADEMIC_ACTIVITY_REPORT,
            TB_Constants.EEPS_TYPE_EVALUATION_OF_ACADEMIC_ACTIVITY
        };

        if(!evaluationStages.isEmpty()) {
            switch on currentUserRole {
                when 'Evaluated', 'Evaluator'
                {
                    navigationStages.addAll(getStagesByType(constantsStageTypes,evaluationStages));
                }
                when 'Supervisor' {
                    constantsStageTypes.add(TB_Constants.EEPS_TYPE_APPROVAL_OR_MODIFICATION);
                    constantsStageTypes.add(TB_Constants.EEPS_TYPE_SUPERVISOR_DECISION);
                    constantsStageTypes.add(TB_Constants.EEPS_TYPE_FINAL_ASSESSMENT);
                    navigationStages.addAll(getStagesByType(constantsStageTypes,evaluationStages));
                }
                when 'Administrator', 'Rector' {
                    navigationStages.addAll(evaluationStages);
                }
            }
            navigationStages.addAll(getCompletedStages(evaluationStages));
        }

        if((currentUserRole=='Evaluated' || currentUserRole=='Evaluator') && currentStage.TB_Employee_Evaluation__r.TB_Employee_Evaluation__c != null) {
            navigationStages = removeFinalStage(navigationStages);
        }else if(currentUserRole=='Supervisor' && currentStage.TB_Employee_Evaluation__r.TB_Employee_Evaluation__c != null
            && currentStage.TB_Employee_Evaluation__r.TB_Scientist_And_Didactic__c == false
            && currentStage.TB_Employee_Evaluation__r.TB_Scientist_And_Scientist__c == false)
        {
            navigationStages = removeFinalStage(navigationStages);
        }

        List<TB_Employee_Evaluation_Stage__c>  navigationStagesToDisplay = removeCurrentStage(new List<TB_Employee_Evaluation_Stage__c>(navigationStages),currentStage);
        return navigationStagesToDisplay;
    }

    private static List<TB_Employee_Evaluation_Stage__c> getCompletedStages(List<TB_Employee_Evaluation_Stage__c> evaluationStages) {
        List<TB_Employee_Evaluation_Stage__c> showStages = new List<TB_Employee_Evaluation_Stage__c>();
        for(TB_Employee_Evaluation_Stage__c singleStage : evaluationStages) {
            if(singleStage.TB_Evaluation_Stage_Status__c == 'Completed') {
                showStages.add(singleStage);
            }
        }
        return showStages;
    }

    private static List<TB_Employee_Evaluation_Stage__c> getStagesByType(List<String> evaluationStageTypes, List<TB_Employee_Evaluation_Stage__c> evaluationStages) {
        List<TB_Employee_Evaluation_Stage__c> showStages = new List<TB_Employee_Evaluation_Stage__c>();
        for(String singleType : evaluationStageTypes) {
            for(TB_Employee_Evaluation_Stage__c singleEvaluationStage : evaluationStages) {
                if(singleEvaluationStage.TB_Employee_Stage_Type__c == singleType) {
                    showStages.add(singleEvaluationStage);
                }
            }
        }
        return showStages;
    }

    private static List<TB_Employee_Evaluation_Stage__c> removeCurrentStage
        (
            List<TB_Employee_Evaluation_Stage__c> navigationStages,
            TB_Employee_Evaluation_Stage__c currentStage
        )
    {
        for(Integer i = navigationStages.size() - 1; i >= 0; i--) {
            if(navigationStages[i].Id == currentStage.Id) {
                navigationStages.remove(i);
            }
        }
        return navigationStages;
    }

    private static Set<TB_Employee_Evaluation_Stage__c> removeFinalStage
        (
            Set<TB_Employee_Evaluation_Stage__c> navigationStages
        )
    {
        List<TB_Employee_Evaluation_Stage__c> toDeleteStages = new List<TB_Employee_Evaluation_Stage__c>();
        for(TB_Employee_Evaluation_Stage__c singleStage : navigationStages) {
            if(singleStage.TB_Employee_Stage_Type__c == TB_Constants.EEPS_TYPE_FINAL_ASSESSMENT) {
                toDeleteStages.add(singleStage);
            }
        }
        navigationStages.removeAll(toDeleteStages);
        return navigationStages;
    }
}
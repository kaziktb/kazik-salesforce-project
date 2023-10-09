public without sharing class TB_vu_StudentOrganizationApproval {
    
    @AuraEnabled
    public static void makeADecision(String contactId, String recordId, String decision, String comment){
        try {
            Task task = [SELECT Id, Description, TB_Decision__c, TB_Active__c FROM Task 
                        WHERE WhoId =: contactId AND WhatId =: recordId AND TB_Active__c = true LIMIT 1];
            task.Description = comment;
            task.TB_Decision__c = decision;

            update task;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(), TB_vu_StudentOrganizationDetails.class.getName(), e.getStackTraceString(), ''));
        }
    }

    @AuraEnabled
    public static StudentOrganizationApproveWrapper getStartData(String recordId, String allowedContactId, String language){
        StudentOrganizationApproveWrapper toReturn = new StudentOrganizationApproveWrapper();
        try {
            Account a = [SELECT Id, TB_Account_Name_PL__c,TB_Account_Name_EN__c, TB_Supervisor__c,hed__Primary_Contact__c FROM Account WHERE Id=: recordId];

            for(Contact c : [SELECT Id FROM Contact WHERE TB_User__c =: UserInfo.getUserId()]){
                if(c.Id == allowedContactId){
                    toReturn.UserIsAllowed = true;
                }
                if(c.Id == a.hed__Primary_Contact__c || c.Id == a.TB_Supervisor__c){
                    toReturn.ChairmanOrSupervisorIsLogged = true;
                }
            }

            toReturn.OrganizationName = language == 'PL' ? a.TB_Account_Name_PL__c : a.TB_Account_Name_EN__c;   
            
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(), TB_vu_StudentOrganizationDetails.class.getName(), e.getStackTraceString(), ''));
        }
        return toReturn;
    }


    @AuraEnabled
    public static Task getTask(String contactId, String recordId){
        try {
            return [SELECT Id, TB_Active__c, Possible_Approval_Decisions__c FROM Task 
                    WHERE WhoId =: contactId AND TB_Active__c = true AND WhatId =: recordId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(), TB_vu_StudentOrganizationDetails.class.getName(), e.getStackTraceString(), ''));
        }
    }

    public class StudentOrganizationApproveWrapper{
        @AuraEnabled public String OrganizationName { get; set; }
        @AuraEnabled public Boolean UserIsAllowed { get; set; }
        @AuraEnabled public Boolean ChairmanOrSupervisorIsLogged { get; set; }

        public StudentOrganizationApproveWrapper(){
            this.UserIsAllowed = false;
            this.ChairmanOrSupervisorIsLogged = false;
        }
    }
    
}
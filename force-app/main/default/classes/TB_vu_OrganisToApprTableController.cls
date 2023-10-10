public with sharing class TB_vu_OrganisToApprTableController {
    static final String IN_PROGRESS_STATUS = 'In Progress';
    static final String PENDING_APPROVAL_STATUS = 'Pending_Approval';

    @AuraEnabled
    public static List<AccountWrapper> getAccounts(String language) {
        try {
            List<Id> contactIdsLinkedWithCurrentUser = new List<Id>(); 
            for(Contact c : [SELECT Id FROM Contact WHERE TB_User__c =: UserInfo.getUserId()]){
                contactIdsLinkedWithCurrentUser.add(c.Id);
            }
            List<AccountWrapper> accountsWrapperList = new List<AccountWrapper>();
            List<String> statuses = TB_Constants.ORGANISATIONS_TO_APPROVE_ACCOUNT_STATUSES;
            String fieldOrderBy = language == 'PL' ? 'TB_Account_Name_PL__c' : 'TB_Account_Name_EN__c';
            if (contactIdsLinkedWithCurrentUser.size() > 0) {
                List<Id> accountIdsWithActiveTasks = new List<Id>();

                for(Task t : [SELECT Id, WhatId, WhoId FROM Task WHERE WhoId IN: contactIdsLinkedWithCurrentUser]){
                    accountIdsWithActiveTasks.add(t.WhatId);
                }
                String q =
                    'SELECT Id, TB_Account_Name_PL__c, TB_Account_Name_EN__c, Parent.TB_Account_Name_PL__c, ' +
                    ' Parent.TB_Account_Name_EN__c, hed__Primary_Contact__r.Name, ' +
                    ' TB_Supervisor__r.Name, toLabel(TB_Organisation_Type__c), toLabel(TB_Status__c),' +
                    ' (SELECT Id, WhatId, WhoId, Status, TB_Active__c FROM Tasks WHERE Status = \'' + IN_PROGRESS_STATUS + '\''+ ' AND TB_Active__c = true AND WhoId IN: contactIdsLinkedWithCurrentUser)' +
                    ' FROM Account WHERE RecordTypeId = \'' +
                    TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID +
                    '\'' +
                    ' AND TB_Active__c = TRUE' +
                    ' AND TB_Status__c IN: statuses' +
                    ' AND (hed__Primary_Contact__c IN: contactIdsLinkedWithCurrentUser OR TB_Supervisor__c IN: contactIdsLinkedWithCurrentUser OR Id IN: accountIdsWithActiveTasks)' +
                    ' ORDER BY TB_Status__c, ' +
                    fieldOrderBy +
                    ' LIMIT 1000';
                for (Account a : Database.query(q)) {
                    AccountWrapper accountWrapper = new AccountWrapper();
                    accountWrapper.Id = a.Id;
                    accountWrapper.AccNameEn = a.TB_Account_Name_EN__c;
                    accountWrapper.AccNamePl = a.TB_Account_Name_PL__c;
                    accountWrapper.ParentAccNameEn = a.Parent.TB_Account_Name_EN__c;
                    accountWrapper.ParentAccNamePl = a.Parent.TB_Account_Name_PL__c;
                    accountWrapper.ContactName = a.hed__Primary_Contact__r.Name;
                    accountWrapper.SupervisorName = a.TB_Supervisor__r.Name;
                    accountWrapper.Type = a.TB_Organisation_Type__c;
                    accountWrapper.Status = a.TB_Status__c;
                    accountWrapper.HighlightBorder = false;
                    if(a.Tasks.size() > 0){
                        for(Task t : a.Tasks){
                            AccountWrapper accWrapperWithTask = new AccountWrapper();
                            accWrapperWithTask.Id = a.Id;
                            accWrapperWithTask.AccNameEn = a.TB_Account_Name_EN__c;
                            accWrapperWithTask.AccNamePl = a.TB_Account_Name_PL__c;
                            accWrapperWithTask.ParentAccNameEn = a.Parent.TB_Account_Name_EN__c;
                            accWrapperWithTask.ParentAccNamePl = a.Parent.TB_Account_Name_PL__c;
                            accWrapperWithTask.ContactName = a.hed__Primary_Contact__r.Name;
                            accWrapperWithTask.SupervisorName = a.TB_Supervisor__r.Name;
                            accWrapperWithTask.Type = a.TB_Organisation_Type__c;
                            accWrapperWithTask.Status = a.TB_Status__c;
                            accWrapperWithTask.TaskId = t.Id;
                            accWrapperWithTask.ContactId = t.WhoId;
                            accWrapperWithTask.HighlightBorder = true;
                            accountsWrapperList.add(accWrapperWithTask);
                        }
                    }
                    else{
                        accountsWrapperList.add(accountWrapper);
                    }
                }
            }
            return accountsWrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(e.getMessage(),TB_vu_OrganisToApprTableController.class.getName(),e.getStackTraceString(),'')
            );
        }
    }

    private static Boolean checkIfTaskIsAssignedToContactsLinkedWithUser(String taskId, List<Id> contactIds){
        return [SELECT Id, WhatId, WhoId, Status, TB_Active__c 
            FROM Task 
            WHERE Status =: IN_PROGRESS_STATUS 
            AND TB_Active__c = true
            AND WhoId IN: contactIds
            AND Id =: taskId].size() > 0;
    }

    public class AccountWrapper {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public Id ContactId { get; set; }
        @AuraEnabled public Id TaskId { get; set; }
        @AuraEnabled public String AccNameEn { get; set; }
        @AuraEnabled public String AccNamePl { get; set; }
        @AuraEnabled public String ParentAccNameEn { get; set; }
        @AuraEnabled public String ParentAccNamePl { get; set; }
        @AuraEnabled public String ContactName { get; set; }
        @AuraEnabled public String SupervisorName { get; set; }
        @AuraEnabled public String Type { get; set; }
        @AuraEnabled public String Status { get; set; }
        @AuraEnabled public Boolean HighlightBorder { get; set; }

    }
}
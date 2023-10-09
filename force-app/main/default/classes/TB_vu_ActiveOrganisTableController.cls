public with sharing class TB_vu_ActiveOrganisTableController {
    public class ActiveOrganisationsAccountWrapper {
        @AuraEnabled
        public Id Id { get; set; }
        @AuraEnabled
        public String AccNameEn { get; set; }
        @AuraEnabled
        public String AccNamePl { get; set; }
        @AuraEnabled
        public String ParentAccNameEn { get; set; }
        @AuraEnabled
        public String ParentAccNamePl { get; set; }
        @AuraEnabled
        public String ContactName { get; set; }
        @AuraEnabled
        public String SupervisorName { get; set; }
        @AuraEnabled
        public String Type { get; set; }
    }

    public class FilterValues {
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String recId { get; set; }
    }

    @AuraEnabled
    public static List<ActiveOrganisationsAccountWrapper> getAccounts(
        Integer limitSize,
        Integer offset,
        List<FilterValues> filterValues,
        String language
    ) {
        try {
            String filtersQuery = '';
            String fieldOrderBy = language == 'PL' ? 'TB_Account_Name_PL__c' : 'TB_Account_Name_EN__c';
            if (filterValues != null && !filterValues.isEmpty())
                for (FilterValues fv : filterValues) {
                    if (fv.type == TB_Constants.CAMPUS_VALUE && String.isNotBlank(fv.value)) {
                        filtersQuery = ' AND Parent.BillingCity = \'' + String.escapeSingleQuotes(fv.value) + '\'';
                    } else if (fv.type == TB_Constants.FACULTY_VALUE && String.isNotBlank(fv.recId)) {
                        // reset queryFilter
                        filtersQuery = ' AND ParentId = \'' + String.escapeSingleQuotes(fv.recId) + '\'';
                    } else if (fv.type == TB_Constants.TYPE_VALUE && String.isNotBlank(fv.value)) {
                        filtersQuery += ' AND TB_Organisation_Type__c = \'' + String.escapeSingleQuotes(fv.value) + '\'';
                    }
                }
            String q =
                'SELECT Id, TB_Account_Name_PL__c, TB_Account_Name_EN__c, Parent.TB_Account_Name_PL__c,' +
                ' Parent.TB_Account_Name_EN__c, hed__Primary_Contact__r.Name,' +
                ' TB_Supervisor__r.Name, toLabel(TB_Organisation_Type__c)' +
                ' FROM Account WHERE' +
                ' RecordTypeId = \'' +
                TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID +
                '\'' +
                ' AND TB_Active__c = TRUE' +
                ' AND TB_Status__c = \'' +
                TB_Constants.ACTIVE_STATUS +
                '\'';
            if (String.isNotBlank(filtersQuery)) {
                q += filtersQuery;
            }
            q += ' ORDER BY ' + fieldOrderBy + ' LIMIT :limitSize OFFSET :offset';
            List<ActiveOrganisationsAccountWrapper> accsWrapperList = new List<ActiveOrganisationsAccountWrapper>();
            for (Account a : Database.query(q)) {
                ActiveOrganisationsAccountWrapper acc = new ActiveOrganisationsAccountWrapper();
                acc.Id = a.Id;
                acc.AccNameEn = a.TB_Account_Name_EN__c;
                acc.AccNamePl = a.TB_Account_Name_PL__c;
                acc.ParentAccNameEn = a.Parent.TB_Account_Name_EN__c;
                acc.ParentAccNamePl = a.Parent.TB_Account_Name_PL__c;
                acc.ContactName = a.hed__Primary_Contact__r.Name;
                acc.SupervisorName = a.TB_Supervisor__r.Name;
                acc.Type = a.TB_Organisation_Type__c;
                accsWrapperList.add(acc);
            }
            return accsWrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_ActiveOrganisTableController.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }

    @AuraEnabled
    public static List<Account> getFilterValues() {
        try {
            return [
                SELECT Id, TB_Account_Name_PL__c, TB_Account_Name_EN__c, Type, ParentId, BillingCity
                FROM Account
                WHERE RecordTypeId = :TB_Constants.UNIVERSITY_DEPARTMENT_REC_TYPE_ID
                AND Type = :TB_Constants.FACULTY_VALUE
                AND TB_Active__c = TRUE
                AND Name LIKE 'Wydział%'
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_ActiveOrganisTableController.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }
}
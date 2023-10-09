public with sharing class TB_CT_ApplicationTrackingController {

    private static final String ACCOUNT_RECORD_TYPE = 'University Department';
    private static final String ACCOUNT_TYPE = 'Faculty';
    private static final String NOT_FOUND = '-';
    private static final String PROCESS_CANCELED = 'Process_Cancelled';
    private static final String CONTACT_RECORD_TYPE_EMPLOYEE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();

    @AuraEnabled
    public static List<AppTrackingWrapper> getAppTrackingByFilters(String searchTerm, String sortType,
            Id departmentId, Id coordinatorId, Boolean citizenship, String status, Boolean isMine,
            Integer offsetFilter, Integer limitFilter) {

        List<TB_App_Tracking__c> appTrackings;
        List<AppTrackingWrapper> wrappers = new List<TB_CT_ApplicationTrackingController.AppTrackingWrapper>();
        String query = buildStringQuery(searchTerm, sortType, departmentId, coordinatorId, citizenship, status,
                isMine, offsetFilter, limitFilter);

        try {
            appTrackings = Database.query(query);
        } catch (Exception ex) {
            TB_LogUtils.registerLog(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        for(TB_App_Tracking__c record : appTrackings) {
            AppTrackingWrapper wrapper = wrapperSetter(record);
            wrappers.add(wrapper);
        }

        return wrappers;
    }


    @AuraEnabled(Cacheable=true)
    public static AppTrackingWrapper getAppTrackingById(Id processId) {
        TB_App_Tracking__c record = null;
        try {
             record = [
                    SELECT
                            Name,
                            TB_Applicant__c,
                            TB_Full_Name__c,
                            TB_First_Name__c,
                            TB_Last_Name__c,
                            TB_Email__c,
                            TB_Phone__c,
                            TB_Dean_s_Office_Responsible__r.Name,
                            TB_Process_Status__c,
                            TB_Uni_Work_Department__c,
                            TB_Is_Foreigner__c,
                            TB_Is_Mine__c,
                            TB_Salutation__c,
                            TB_PESEL__c,
                            TB_Preferred_Language__c,
                            TB_Uni_Work_Department__r.FullName__c,
                            TB_Employee_Type__c,
                            TB_Responsible_Coordinator__r.Name,
                            TB_Additional_Responsible__r.Name,
                            TB_Employment_Type__c
                    FROM TB_App_Tracking__c
                    WHERE TB_Active__c = TRUE
                    AND Id =: processId
                    LIMIT 1];
        } catch (QueryException e) {
            insert TB_LogUtils.registerLog(e, TB_CT_ApplicationTrackingController.class);
            throw new AuraHandledException('QueryException.');
        }

        return wrapperSetter(record);
    }

    @AuraEnabled(Cacheable=true)
    public static List<Account> getAllDepartments(){
        return [
                SELECT Name, TB_Account_Name_EN__c, TB_Account_Name_PL__c
                FROM Account
                WHERE Record_Type_Name__c = :ACCOUNT_RECORD_TYPE AND TB_Active__c = TRUE AND Type = :ACCOUNT_TYPE
        ];
    }

    @AuraEnabled
    public static void cancelProcess(Id processId){
        AppTrackingCancelController cancelCls = new AppTrackingCancelController();
        cancelCls.cancelProcess(processId);
    }

    private static AppTrackingWrapper wrapperSetter(TB_App_Tracking__c record) {
        AppTrackingWrapper wrapper = new AppTrackingWrapper();
        wrapper.setValues(
                record.Id,
                record.Name,
                record.TB_Applicant__c,
                record.TB_Full_Name__c,
                record.TB_First_Name__c,
                record.TB_Last_Name__c,
                record.TB_Email__c,
                record.TB_Phone__c,
                record.TB_Dean_s_Office_Responsible__c,
                record.TB_Dean_s_Office_Responsible__r.Name,
                record.TB_Process_Status__c,
                record.TB_Uni_Work_Department__c,
                record.TB_Is_Foreigner__c,
                record.TB_Is_Mine__c,
                record.TB_Salutation__c,
                record.TB_PESEL__c,
                record.TB_Preferred_Language__c,
                record.TB_Uni_Work_Department__r.FullName__c,
                record.TB_Employee_Type__c,
                record.TB_Responsible_Coordinator__c,
                record.TB_Responsible_Coordinator__r.Name,
                record.TB_Additional_Responsible__c,
                record.TB_Additional_Responsible__r.Name,
                record.TB_Employment_Type__c
        );
        return wrapper;
    }

    private static OrderType toOrderType(String order) {
        for(OrderType type : OrderType.values()) {
            if (type.name() == order) return type;
        }
        return null;
    }

    private static String buildStringQuery(String searchTerm, String sortType, Id departmentId, Id coordinatorId,
            Boolean citizenship, String status, Boolean isMine, Integer offsetFilter, Integer limitFilter) {

        OrderType orderType = toOrderType(sortType);

        String query = 'SELECT Name, TB_Applicant__c, TB_Full_Name__c, TB_First_Name__c, TB_Last_Name__c, TB_Email__c, ' +
                'TB_Phone__c, TB_Dean_s_Office_Responsible__r.Name, TB_Process_Status__c, TB_Uni_Work_Department__c, ' +
                'TB_Is_Foreigner__c, TB_Is_Mine__c, TB_Salutation__c, TB_PESEL__c, TB_Preferred_Language__c, ' +
                'TB_Uni_Work_Department__r.FullName__c, TB_Employee_Type__c, TB_Responsible_Coordinator__r.Name, ' +
                'TB_Additional_Responsible__r.Name, TB_Employment_Type__c FROM TB_App_Tracking__c WHERE TB_Active__c = TRUE ';

        if (searchTerm != null) {
            searchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
            query += 'AND (TB_Full_Name__c LIKE \'' + searchTerm
                    + '\' OR TB_Email__c LIKE \'' + searchTerm
                    + '\' OR TB_Phone__c LIKE \'' + searchTerm + '\') ';
        }

        if (departmentId != null) {
            query += ' AND TB_Uni_Work_Department__c = \'' + String.escapeSingleQuotes(departmentId) + '\'';
        }

        if (coordinatorId != null) {
            query += ' AND (TB_Dean_s_Office_Responsible__c = \'' + String.escapeSingleQuotes(coordinatorId) + '\'' +
                    ' OR TB_Responsible_Coordinator__c = \'' + String.escapeSingleQuotes(coordinatorId) + '\'' +
                    ' OR TB_Additional_Responsible__c = \'' + String.escapeSingleQuotes(coordinatorId) + '\')';
        }

        if (citizenship != null) {
            query += ' AND TB_Is_Foreigner__c = ' + citizenship;
        }

        if (status != null) {
            query += ' AND TB_Process_Status__c = \'' + String.escapeSingleQuotes(status) + '\'';
        }

        if (isMine != null) {
            query += ' AND TB_Is_Mine__c = ' + isMine;
        }


        String orderingTerm = ' ORDER BY ';
        switch on orderType {
            when ASCENDING {
                orderingTerm += 'Name ASC';
            }
            when DESCENDING {
                orderingTerm += 'Name DESC';
            }
            when else {
                orderingTerm += 'LastModifiedDate DESC';
            }
        }
        query += orderingTerm;


        if (limitFilter == null) {
            limitFilter = 10;
        }

        if (offsetFilter == null) {
            offsetFilter = 0;
        }

        query += ' LIMIT ' + limitFilter + ' OFFSET ' + offsetFilter;

        return query;
    }

    public without sharing class AppTrackingCancelController {
        public void cancelProcess(Id processId){
            TB_App_Tracking__c appTracking = [SELECT Id FROM TB_App_Tracking__c WHERE Id =: processId LIMIT 1];
            appTracking.TB_Process_Status__c = PROCESS_CANCELED;
            try {
            update appTracking;
            } catch(DmlException ex) {
                insert TB_LogUtils.registerLog(ex, TB_CT_ApplicationTrackingController.class);
            }
        } 
    }

    public class AppTrackingWrapper{
        @AuraEnabled public Id Id;
        @AuraEnabled public String processName;
        @AuraEnabled public String teacherId;
        @AuraEnabled public String teacherFullName;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String deansOfficeResponsibleId;
        @AuraEnabled public String deansOfficeResponsibleName;
        @AuraEnabled public String status;
        @AuraEnabled public String uniWorkDepartment;
        @AuraEnabled public Boolean isForeigner;
        @AuraEnabled public Boolean isMine;
        @AuraEnabled public String salutation;
        @AuraEnabled public String pesel;
        @AuraEnabled public String preferredLanguage;
        @AuraEnabled public String uniWorkDepartmentName;
        @AuraEnabled public String employeeType;
        @AuraEnabled public String coordinatorId;
        @AuraEnabled public String coordinatorName;
        @AuraEnabled public String additionalResponsibleId;
        @AuraEnabled public String additionalResponsibleName;
        @AuraEnabled public String employmentTypeValue;

        public void setValues(
                Id Id,
                String processName,
                Id teacherId,
                String teacherFullName,
                String firstName,
                String lastName,
                String email,
                String phone,
                String deansOfficeResponsibleId,
                String deansOfficeResponsibleName,
                String status,
                String uniWorkDepartment,
                Boolean isForeigner,
                Boolean isMine,
                String salutation,
                String pesel,
                String preferredLanguage,
                String uniWorkDepartmentName,
                String employeeType,
                String coordinatorId,
                String coordinatorName,
                String additionalResponsibleId,
                String additionalResponsibleName,
                String employmentTypeValue
        ){
            this.Id = Id;
            this.processName = checkIfNullAndSetValue(processName);
            this.teacherId = teacherId;
            this.teacherFullName = checkIfNullAndSetValue(teacherFullName);
            this.firstName = checkIfNullAndSetValue(firstName);
            this.lastName = checkIfNullAndSetValue(lastName);
            this.email = checkIfNullAndSetValue(email);
            this.phone = checkIfNullAndSetValue(phone);
            this.deansOfficeResponsibleId = checkIfNullAndSetValue(deansOfficeResponsibleId);
            this.deansOfficeResponsibleName = checkIfNullAndSetValue(deansOfficeResponsibleName);
            this.status = checkIfNullAndSetValue(status);
            this.uniWorkDepartment = checkIfNullAndSetValue(uniWorkDepartment);
            this.isForeigner = isForeigner;
            this.isMine = isMine;
            this.salutation = checkIfNullAndSetValue(salutation);
            this.pesel = checkIfNullAndSetValue(pesel);
            this.preferredLanguage = checkIfNullAndSetValue(preferredLanguage);
            this.uniWorkDepartmentName = checkIfNullAndSetValue(uniWorkDepartmentName);
            this.employeeType = checkIfNullAndSetValue(employeeType);
            this.coordinatorId = checkIfNullAndSetValue(coordinatorId);
            this.coordinatorName = checkIfNullAndSetValue(coordinatorName);
            this.additionalResponsibleId = checkIfNullAndSetValue(additionalResponsibleId);
            this.additionalResponsibleName = checkIfNullAndSetValue(additionalResponsibleName);
            this.employmentTypeValue = checkIfNullAndSetValue(employmentTypeValue);
        }
    }

    private static String checkIfNullAndSetValue(String value){
        return (value == null) ? NOT_FOUND : value;
    }

    public enum OrderType {ASCENDING, DESCENDING}
}
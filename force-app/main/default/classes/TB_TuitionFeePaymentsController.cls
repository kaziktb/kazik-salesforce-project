public with sharing class TB_TuitionFeePaymentsController {
    static public String contactFieldApis = 'Id';
    static public String applicationFieldApis = 'Id,hed__Applicant__c,hed__Initial_Creation_Date__c,TB_Tuition_Fee__c,' +
        'TB_Tuition_Fee_Currency__c,TB_Tuition_Bank_Account_PLN__c,TB_Tuition_Bank_Account_EUR__c';
    static public String paymentFieldApis = 'Id,TB_Contact__c,TB_Payment_Date__c,TB_x_Paid_Amount__c,TB_Bank_Account_Number__c,' +
        'TB_Currency__c';

    static public Map<String,String> fieldToLabelPl = new Map<String,String>{
        'Contact_Id' => 'Contact Id',
        'Application_Id' => 'Application Id',
        'Payment_Id' => 'Payment Id',
        'Payment_Name' => 'Payment',
        'Application_Name' => 'Application'
    };

    static public Map<String,String> fieldToLabelEn = new Map<String,String>{
        'Contact_Id' => 'Contact Id',
        'Application_Id' => 'Application Id',
        'Payment_Id' => 'Payment Id',
        'Payment_Name' => 'Payment Name',
        'Application_Name' => 'Application Name'
    };

    public static void clearCache(String prefix) {
        List<String> tuitionObjects = new List<String>{'Contacts','Applications','Payments'};
        for (String tuitionObject : tuitionObjects) {
            for (Integer i = 1; i <= Integer.valueOf(Cache.Org.get(prefix + 'tuition' + tuitionObject + 'Index')); i++) {
                Cache.Org.remove(prefix + 'tuition' + tuitionObject + i);
            }
            Cache.Org.remove(prefix + 'tuition' + tuitionObject + 'Index');
        }
        Cache.Org.remove(prefix + 'tuitionRefreshDate');
    }

    @AuraEnabled
    public static Integer getPayments(
        String additionalPaymentFieldApis, String filterPaymentFieldApis, String paymentsQueryLimit,
        String daysQueryLimit, Boolean clearCache, Integer packetSize, String prefix
    ) {
        if (clearCache) {
            clearCache(prefix);
        }
        if (Cache.Org.contains(prefix + 'tuitionPaymentsIndex')) {
            return Integer.valueOf(Cache.Org.get(prefix + 'tuitionPaymentsIndex'));
        } else {
            additionalPaymentFieldApis = String.isNotBlank(additionalPaymentFieldApis) ? ',' + additionalPaymentFieldApis : '';
            Set<String> allPaymentFieldApis = new Set<String>((paymentFieldApis + additionalPaymentFieldApis).split(','));
            filterPaymentFieldApis = String.isNotBlank(filterPaymentFieldApis) ? ' AND ' + filterPaymentFieldApis : '';
            String daysQuery = (String.isBlank(daysQueryLimit) ? 0 : Integer.valueOf(daysQueryLimit)) > 0
                ? ' AND TB_Payment_Date__c = LAST_N_DAYS:' + String.valueOf(Integer.valueOf(daysQueryLimit) - 1)
                : '';
            String paymentsQuery = String.isBlank(paymentsQueryLimit) ? '10000' : paymentsQueryLimit;
            List<TB_Payment__c> payments = Database.query(
                'SELECT ' + String.join(new List<String>(allPaymentFieldApis), ',')
                    + ' FROM TB_Payment__c WHERE RecordTypeId = \''
                    + TB_SObjectUtils.getRecordTypeIdByDevName('TB_Payment__c', 'TB_Tuition_Fee')
                    + '\' AND TB_x_Paid_Amount__c != NULL AND TB_Payment_Date__c != NULL AND TB_Bank_Account_Number__c != NULL AND TB_Currency__c != NULL'
                    + filterPaymentFieldApis + daysQuery + ' ORDER BY TB_Payment_Date__c DESC LIMIT ' + paymentsQuery);
            Integer index = 0;
            for (Integer i = 0; i < payments.size(); i = i + packetSize) {
                index++;
                Cache.Org.put(prefix + 'tuitionPayments' + index, (List<TB_Payment__c>) TB_re_Utils.slice(payments, i, i + packetSize));
            }
            Cache.Org.put(prefix + 'tuitionPaymentsIndex', index);
            return index;
        }
    }

    @AuraEnabled
    public static Integer getContacts(
        String additionalContactFieldApis, String filterContactFieldApis, Integer paymentsIndex, Integer packetSize,
        String prefix
    ) {
        if (Cache.Org.contains(prefix + 'tuitionContactsIndex')) {
            return Integer.valueOf(Cache.Org.get(prefix + 'tuitionContactsIndex'));
        } else {
            List<TB_Payment__c> payments = new List<TB_Payment__c>();
            for (Integer i = 1; i <= paymentsIndex; i++) {
                payments.addAll((List<TB_Payment__c>) Cache.Org.get(prefix + 'tuitionPayments' + i));
            }
            Set<Id> contactIds = new Set<Id>();
            for (TB_Payment__c payment : payments) {
                contactIds.add(payment.TB_Contact__c);
            }
            additionalContactFieldApis = String.isNotBlank(additionalContactFieldApis) ? ',' + additionalContactFieldApis : '';
            Set<String> allContactFieldApis = new Set<String>((contactFieldApis + additionalContactFieldApis).split(','));
            filterContactFieldApis = String.isNotBlank(filterContactFieldApis)
                ? ' WHERE ' + filterContactFieldApis + ' AND Id IN :contactIds'
                : ' WHERE Id IN :contactIds';
            List<Contact> contacts = Database.query('SELECT ' + String.join(new List<String>(allContactFieldApis), ',') + ' FROM Contact' + filterContactFieldApis);
            Integer index = 0;
            for (Integer i = 0; i < contacts.size(); i = i + packetSize) {
                index++;
                Cache.Org.put(prefix + 'tuitionContacts' + index, (List<Contact>) TB_re_Utils.slice(contacts, i, i + packetSize));
            }
            Cache.Org.put(prefix + 'tuitionContactsIndex', index);
            return index;
        }
    }

    @AuraEnabled
    public static Integer getApplications(
        String additionalApplicationFieldApis, String filterApplicationFieldApis, Integer contactsIndex,
        Integer packetSize, String prefix
    ) {
        if (Cache.Org.contains(prefix + 'tuitionApplicationsIndex')) {
            return Integer.valueOf(Cache.Org.get(prefix + 'tuitionApplicationsIndex'));
        } else {
            List<Contact> contacts = new List<Contact>();
            for (Integer i = 1; i <= contactsIndex; i++) {
                contacts.addAll((List<Contact>) Cache.Org.get(prefix + 'tuitionContacts' + i));
            }
            Set<Id> contactIds = new Set<Id>();
            for (Contact contact : contacts) {
                contactIds.add(contact.Id);
            }
            additionalApplicationFieldApis = String.isNotBlank(additionalApplicationFieldApis) ? ',' + additionalApplicationFieldApis : '';
            Set<String> allApplicationFieldApis = new Set<String>((applicationFieldApis + additionalApplicationFieldApis).split(','));
            filterApplicationFieldApis = String.isNotBlank(filterApplicationFieldApis)
                ? ' AND ' + filterApplicationFieldApis + ' AND hed__Applicant__c IN :contactIds'
                : ' AND hed__Applicant__c IN :contactIds';
            List<hed__Application__c> applications = Database.query(
                'SELECT ' + String.join(new List<String>(allApplicationFieldApis), ',')
                    + ' FROM hed__Application__c WHERE TB_Tuition_Fee__c != NULL AND hed__Initial_Creation_Date__c != NULL AND TB_Tuition_Fee_Currency__c != NULL AND TB_Tuition_Bank_Account_EUR__c != NULL AND TB_Tuition_Bank_Account_PLN__c != NULL'
                    + filterApplicationFieldApis);
            Integer index = 0;
            for (Integer i = 0; i < applications.size(); i = i + packetSize) {
                index++;
                Cache.Org.put(prefix + 'tuitionApplications' + index, (List<hed__Application__c>) TB_re_Utils.slice(applications, i, i + packetSize));
            }
            Cache.Org.put(prefix + 'tuitionApplicationsIndex', index);
            Cache.Org.put(prefix + 'tuitionRefreshDate', System.now().format('yyyy.MM.dd\', \'HH:mm:ss', 'Poland'));
            return index;
        }
    }

    @AuraEnabled
    public static String getRefreshDate(String prefix) {
        return String.valueOf(Cache.Org.get(prefix + 'tuitionRefreshDate'));
    }

    @AuraEnabled
    public static List<TuitionFeePaymentWrapper> retrieveRelatedData(
        String additionalContactFieldApis, String additionalPaymentFieldApis, String additionalApplicationFieldApis,
        String acceptedDeviation, Integer contactsIndex, Integer paymentsIndex, Integer applicationsIndex,
        Integer recordsLimit, Integer currentPage, String contactNameFilter,
        String applicationNameFilter, String prefix
    ) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= contactsIndex; i++) {
            contacts.addAll((List<Contact>) Cache.Org.get(prefix + 'tuitionContacts' + i));
        }
        Map<Id,Contact> idToContact = new Map<Id,Contact>();
        for (Contact con : contacts) {
            idToContact.put(con.Id, con);
        }
        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 1; i <= applicationsIndex; i++) {
            applications.addAll((List<hed__Application__c>) Cache.Org.get(prefix + 'tuitionApplications' + i));
        }
        List<TB_Payment__c> payments = new List<TB_Payment__c>();
        for (Integer i = 1; i <= paymentsIndex; i++) {
            payments.addAll((List<TB_Payment__c>) Cache.Org.get(prefix + 'tuitionPayments' + i));
        }
        Map<Id, List<hed__Application__c>> contactIdToApplications = new Map<Id, List<hed__Application__c>>();
        contactIdToApplications = createApplicationsMap(contactIdToApplications, applications);
        Map<Id, List<TB_Payment__c>> contactIdToPayments = new Map<Id, List<TB_Payment__c>>();
        contactIdToPayments = createPaymentsMap(contactIdToPayments, payments);
        try {
            List<String> contactFieldsForCells = String.isNotBlank(additionalContactFieldApis) ? additionalContactFieldApis.split(',') : new List<String>();
            List<String> paymentFieldsForCells = String.isNotBlank(additionalPaymentFieldApis) ? additionalPaymentFieldApis.split(',') : new List<String>();
            List<String> applicationFieldsForCells = String.isNotBlank(additionalApplicationFieldApis) ? additionalApplicationFieldApis.split(',') : new List<String>();
            List<TuitionFeePaymentWrapper> tuitionFeePaymentWrappers = new List<TuitionFeePaymentWrapper>();
            Map<Id, Integer> paymentIdToCount = new Map<Id, Integer>();
            Integer count = 0;
            Decimal deviation = String.isBlank(acceptedDeviation) ? 0 : Decimal.valueOf(acceptedDeviation);

            Contact con;
            for (TB_Payment__c payment : payments) {
                if (contactIdToPayments.get(payment.TB_Contact__c) != null && contactIdToApplications.get(payment.TB_Contact__c) != null) {
                    con = idToContact.get(payment.TB_Contact__c);
                    for (hed__Application__c app : contactIdToApplications.get(payment.TB_Contact__c)) {
                        if (
                            (String.isNotBlank(contactNameFilter) && con.Name.contains(contactNameFilter) || String.isBlank(contactNameFilter))
                                && (String.isNotBlank(applicationNameFilter) && app.Name.contains(applicationNameFilter) || String.isBlank(applicationNameFilter))
                                && compareAmount(payment.TB_x_Paid_Amount__c, app.TB_Tuition_Fee__c, deviation)
                                && payment.TB_Currency__c == app.TB_Tuition_Fee_Currency__c
                                && payment.TB_Bank_Account_Number__c == String.valueOf(app.get('TB_Tuition_Bank_Account_' + app.TB_Tuition_Fee_Currency__c + '__c'))
                                && payment.TB_Payment_Date__c >= app.hed__Initial_Creation_Date__c
                            ) {
                            TuitionFeePaymentWrapper tuitionFeePaymentWrapper = new TuitionFeePaymentWrapper(con, payment, app);
                            tuitionFeePaymentWrapper.contactFields = contactFieldsForCells;
                            tuitionFeePaymentWrapper.paymentFields = paymentFieldsForCells;
                            tuitionFeePaymentWrapper.applicationFields = applicationFieldsForCells;
                            count = paymentIdToCount.get(payment.Id);
                            if (count == null) {
                                paymentIdToCount.put(payment.Id, 1);
                            } else {
                                paymentIdToCount.put(payment.Id, count + 1);
                            }
                            tuitionFeePaymentWrappers.add(tuitionFeePaymentWrapper);
                        }
                    }
                }
            }
            tuitionFeePaymentWrappers = markUnmatchedWrappers(tuitionFeePaymentWrappers, paymentIdToCount);
            return prepareWrappers(recordsLimit, currentPage, tuitionFeePaymentWrappers);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<TuitionFeePaymentWrapper> markUnmatchedWrappers(
        List<TuitionFeePaymentWrapper> tuitionFeePaymentWrappers, Map<Id, Integer> paymentIdToCount) {
        for (Id paymentId : paymentIdToCount.keySet()) {
            if (paymentIdToCount.get(paymentId) > 1) {
                for (TuitionFeePaymentWrapper wrapper : tuitionFeePaymentWrappers) {
                    if (paymentId == wrapper.payment.Id) {
                        wrapper.needsAttention = true;
                    }
                }
            }
        }
        return tuitionFeePaymentWrappers;
    }

    private static List<TuitionFeePaymentWrapper> prepareWrappers(
        Integer recordsLimit, Integer currentPage, List<TuitionFeePaymentWrapper> tuitionFeePaymentWrappers
    ) {
        List<TuitionFeePaymentWrapper> wrappersToReturn = new List<TuitionFeePaymentWrapper>();
        if (tuitionFeePaymentWrappers.size() > 0) {
            Integer index = 1;
            for (TuitionFeePaymentWrapper wrapper : tuitionFeePaymentWrappers) {
                wrapper.index = index;
                index++;
            }
            Integer actualLimit = recordsLimit;
            if (
                currentPage - 1 == tuitionFeePaymentWrappers.size() / recordsLimit
                    && Math.mod(tuitionFeePaymentWrappers.size(), recordsLimit) != 0
                ) {
                actualLimit = Math.mod(tuitionFeePaymentWrappers.size(), recordsLimit);
            }
            for (Integer i = 0; i < actualLimit; i++) {
                if (i < tuitionFeePaymentWrappers.size()) {
                    wrappersToReturn.add(tuitionFeePaymentWrappers[(currentPage - 1) * recordsLimit + i]);
                }
            }
            wrappersToReturn[0].size = tuitionFeePaymentWrappers.size();
        }
        return wrappersToReturn;
    }

    private static Map<Id,List<hed__Application__c>> createApplicationsMap(
        Map<Id,List<hed__Application__c>> contactIdToApplications, List<hed__Application__c> applications
    ) {
        for (hed__Application__c application : applications) {
            List<hed__Application__c> applicationsByContact = new List<hed__Application__c>();
            if (contactIdToApplications.get(application.hed__Applicant__c) != null) {
                applicationsByContact = contactIdToApplications.get(application.hed__Applicant__c);
            }
            applicationsByContact.add(application);
            contactIdToApplications.put(application.hed__Applicant__c, applicationsByContact);
        }
        return contactIdToApplications;
    }

    private static Map<Id,List<TB_Payment__c>> createPaymentsMap(
        Map<Id,List<TB_Payment__c>> contactIdToPayments, List<TB_Payment__c> payments
    ) {
        for (TB_Payment__c payment : payments) {
            List<TB_Payment__c> paymentsByContact = new List<TB_Payment__c>();
            if (contactIdToPayments.get(payment.TB_Contact__c) != null) {
                paymentsByContact = contactIdToPayments.get(payment.TB_Contact__c);
            }
            paymentsByContact.add(payment);
            contactIdToPayments.put(payment.TB_Contact__c, paymentsByContact);
        }
        return contactIdToPayments;
    }

    @AuraEnabled
    public static String getUserLanguage() {
        return UserInfo.getLanguage().substring(0,2);
    }

    @AuraEnabled
    public static String retrieveColumnData (
        Boolean sortable, Boolean editable, String additionalContactFieldApis, String additionalPaymentFieldApis,
        String additionalApplicationFieldApis
    ) {
        try {
            String language = getUserLanguage();
            //schema to validate field api names
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            List<String> objectAPINames = new List<String>{'Contact','hed__Application__c','TB_Payment__c'};
            List<ResponseWrapper> responseWrappers = new List<ResponseWrapper>();
            ResponseWrapper responseWrapperIndex = new ResponseWrapper(sortable, editable);
            responseWrapperIndex.fieldName = 'Index';
            responseWrapperIndex.label = language == 'pl' ? 'Indeks' : 'Index';
            responseWrappers.add(responseWrapperIndex);
            for (String objectAPIName : objectAPINames) {
                Schema.SObjectType objectSchema = schemaMap.get(objectAPIName);
                Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
                String inputFields;
                if (objectAPIName == 'Contact') {
                    inputFields = additionalContactFieldApis;
                } else if (objectAPIName == 'hed__Application__c') {
                    inputFields = additionalApplicationFieldApis;
                } else {
                    inputFields = additionalPaymentFieldApis;
                }
                List<String> fields = String.isNotBlank(inputFields) ? inputFields.split(',') : new List<String>();
                if (!fields.isEmpty()) {
                    for (String objectField : fields) {
                        ResponseWrapper responseWrapper = new ResponseWrapper(sortable, editable);
                        if (objectAPIName == 'Contact') {
                            responseWrapper.fieldName = 'Contact_' + objectField;
                            if (responseWrapper.fieldName == 'Contact_Id') {
                                responseWrapper.type = 'url';
                                responseWrapper.typeAttributes = new TypeAttributes('_blank');
                            }
                        } else if (objectAPIName == 'hed__Application__c') {
                            responseWrapper.fieldName = 'Application_' + objectField;
                        } else if (objectAPIName == 'TB_Payment__c') {
                            responseWrapper.fieldName = 'Payment_' + objectField;
                        }
                        if (fieldToLabelEn.keySet().contains(responseWrapper.fieldName)) {
                            responseWrapper.label = language == 'pl'
                                ? fieldToLabelPl.get(responseWrapper.fieldName)
                                : fieldToLabelEn.get(responseWrapper.fieldName);
                        } else {
                            responseWrapper.label = fieldMap.get(String.valueOf(objectField)).getDescribe().getLabel();
                        }
                        Schema.SObjectField field = fieldMap.get(objectField);
                        Schema.DisplayType fieldType = field.getDescribe().getType();
                        if (String.valueOf(fieldType) == 'PICKLIST') {
                            responseWrapper.picklistLabels = TB_StringUtils.getMapFromPicklist(objectAPIName, objectField);
                        }
                        responseWrappers.add(responseWrapper);
                    }
                }
            }
            ResponseWrapper responseWrapper = new ResponseWrapper(sortable, editable);
            responseWrapper.fieldName = 'Needs_Attention';
            responseWrapper.label = language == 'pl' ? 'Wymaga uwagi' : 'Needs Attention';
            responseWrappers.add(responseWrapper);
            return JSON.serialize(responseWrappers);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public static Boolean compareAmount(Decimal paid, Decimal expected, Decimal acceptedDeviation) {
        if (Math.abs(expected - paid) > expected * acceptedDeviation) {
            return false;
        } else {
            return true;
        }
    }

    public class TuitionFeePaymentWrapper {
        @AuraEnabled public Contact contact { get;set; }
        @AuraEnabled public TB_Payment__c payment { get;set; }
        @AuraEnabled public hed__Application__c application { get;set; }
        @AuraEnabled public List<String> contactFields { get;set; }
        @AuraEnabled public List<String> paymentFields { get;set; }
        @AuraEnabled public List<String> applicationFields { get;set; }
        @AuraEnabled public Boolean needsAttention { get;set; }
        @AuraEnabled public Integer size { get;set; }
        @AuraEnabled public Integer index { get;set; }

        public TuitionFeePaymentWrapper(Contact contact, TB_Payment__c payment, hed__Application__c application) {
            this.contact = contact;
            this.payment = payment;
            this.application = application;
            this.needsAttention = false;
        }
    }

    public class ResponseWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean sortable;
        @AuraEnabled public Boolean editable;
        @AuraEnabled public String type;
        @AuraEnabled public Object typeAttributes;
        @AuraEnabled public Boolean hideDefaultActions;
        @AuraEnabled public Boolean wrapText;
        @AuraEnabled public Map<String,String> picklistLabels { get;set; }

        public ResponseWrapper(Boolean sortable, Boolean editable) {
            this.sortable = sortable;
            this.editable = editable;
            this.hideDefaultActions = true;
            this.wrapText = true;
        }
    }

    public class TypeAttributes {
        @AuraEnabled public String label;
        @AuraEnabled public String target;

        public TypeAttributes(String target) {
            this.target = target;
        }
    }
}
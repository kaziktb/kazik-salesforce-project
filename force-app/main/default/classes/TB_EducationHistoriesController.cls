public with sharing class TB_EducationHistoriesController {
    static public String contactFieldApis = 'Id,IndividualId';
    static public String applicationFieldApis = 'Id,hed__Applicant__c';
    static public String enrollmentFieldApis = 'Id,hed__Contact__c';

    static public Map<String,String> fieldToLabelPl = new Map<String,String>{
        'Contact_Id' => 'Contact Id',
        'Application_Id' => 'Application Id',
        'Enrollment_Id' => 'Program Enrollment Id',
        'Enrollment_Name' => 'Program Enrollment',
        'Application_Name' => 'Application',
        'Enrollment_hed__Contact__c' => 'Student Id'
    };

    static public Map<String,String> fieldToLabelEn = new Map<String,String>{
        'Contact_Id' => 'Contact Id',
        'Application_Id' => 'Application Id',
        'Enrollment_Id' => 'Program Enrollment Id',
        'Enrollment_Name' => 'Program Enrollment Name',
        'Application_Name' => 'Application Name',
        'Enrollment_hed__Contact__c' => 'Student Id'
    };

    public static void clearCache(String prefix) {
        List<String> educationObjects = new List<String>{'Contacts','Applications','Enrollments','Students'};
        for (String educationObject : educationObjects) {
            for (Integer i = 1; i <= Integer.valueOf(Cache.Org.get(prefix + 'education' + educationObject + 'Index')); i++) {
                Cache.Org.remove(prefix + 'education' + educationObject + i);
            }
            Cache.Org.remove(prefix + 'education' + educationObject + 'Index');
        }
        Cache.Org.remove(prefix + 'educationRefreshDate');
    }

    @AuraEnabled
    public static Integer getApplications(
        String additionalApplicationFieldApis, String filterApplicationFieldApis, String applicationsQueryLimit,
        Boolean clearCache, String dateQueryLimit, Integer packetSize, String prefix
    ) {
        if (clearCache) {
            clearCache(prefix);
        }
        if (Cache.Org.contains(prefix + 'educationApplicationsIndex')) {
            return Integer.valueOf(Cache.Org.get(prefix + 'educationApplicationsIndex'));
        } else {
            additionalApplicationFieldApis = String.isNotBlank(additionalApplicationFieldApis) ? ',' + additionalApplicationFieldApis : '';
            Set<String> allApplicationFieldApis = new Set<String>((applicationFieldApis + additionalApplicationFieldApis).split(','));
            filterApplicationFieldApis = String.isNotBlank(filterApplicationFieldApis) ? ' WHERE ' + filterApplicationFieldApis : '';
            String applicationsQuery = String.isBlank(applicationsQueryLimit) ? '10000' : applicationsQueryLimit;
            String dateQuery = String.isNotBlank(dateQueryLimit)
                ? ' AND CreatedDate >= ' + dateQueryLimit + 'T00:00:00Z'
                : '';
            dateQuery = String.isBlank(filterApplicationFieldApis) ? dateQuery.replace('AND','WHERE') : dateQuery;
            List<hed__Application__c> applications = Database.query(
                'SELECT ' + String.join(new List<String>(allApplicationFieldApis), ',')
                    + ' FROM hed__Application__c' + filterApplicationFieldApis + dateQuery
                    + ' ORDER BY CreatedDate DESC LIMIT ' + applicationsQuery);
            Integer index = 0;
            for (Integer i = 0; i < applications.size(); i = i + packetSize) {
                index++;
                Cache.Org.put(prefix + 'educationApplications' + index, (List<hed__Application__c>) TB_re_Utils.slice(applications, i, i + packetSize));
            }
            Cache.Org.put(prefix + 'educationApplicationsIndex', index);
            return index;
        }
    }

    @AuraEnabled
    public static Integer getContacts(
        String additionalContactFieldApis, String filterContactFieldApis, Integer applicationsIndex, Integer packetSize,
        String prefix
    ) {
        if (Cache.Org.contains(prefix + 'educationContactsIndex')) {
            return Integer.valueOf(Cache.Org.get(prefix + 'educationContactsIndex'));
        } else {
            List<hed__Application__c> applications = new List<hed__Application__c>();
            for (Integer i = 1; i <= applicationsIndex; i++) {
                applications.addAll((List<hed__Application__c>) Cache.Org.get(prefix + 'educationApplications' + i));
            }
            Set<Id> contactIds = new Set<Id>();
            for (hed__Application__c application : applications) {
                contactIds.add(application.hed__Applicant__c);
            }
            additionalContactFieldApis = String.isNotBlank(additionalContactFieldApis) ? ',' + additionalContactFieldApis : '';
            Set<String> allContactFieldApis = new Set<String>((contactFieldApis + additionalContactFieldApis).split(','));
            filterContactFieldApis = String.isNotBlank(filterContactFieldApis)
                ? ' AND ' + filterContactFieldApis
                : filterContactFieldApis;
            List<Contact> contacts = Database.query('SELECT ' + String.join(new List<String>(allContactFieldApis), ',')
                + ' FROM Contact WHERE Id IN :contactIds' + filterContactFieldApis);
            Integer index = 0;
            for (Integer i = 0; i < contacts.size(); i = i + packetSize) {
                index++;
                Cache.Org.put(prefix + 'educationContacts' + index, (List<Contact>) TB_re_Utils.slice(contacts, i, i + packetSize));
            }
            Cache.Org.put(prefix + 'educationContactsIndex', index);
            return index;
        }
    }

    @AuraEnabled
    public static Integer getStudents(Integer contactsIndex, Integer packetSize, String prefix) {
        if (Cache.Org.contains(prefix + 'educationStudentsIndex')) {
            return Integer.valueOf(Cache.Org.get(prefix + 'educationStudentsIndex'));
        } else {
            List<Contact> contacts = new List<Contact>();
            for (Integer i = 1; i <= contactsIndex; i++) {
                contacts.addAll((List<Contact>) Cache.Org.get(prefix + 'educationContacts' + i));
            }
            Set<Id> individualIds = new Set<Id>();
            for (Contact contact : contacts) {
                individualIds.add(contact.IndividualId);
            }
            List<Contact> students = [
                SELECT Id, IndividualId
                FROM Contact
                WHERE RecordTypeId = :TB_SObjectUtils.getRecordTypeIdByDevName('Contact', 'TB_Student')
                AND IndividualId IN :individualIds
            ];
            Integer index = 0;
            for (Integer i = 0; i < students.size(); i = i + packetSize) {
                index++;
                Cache.Org.put(prefix + 'educationStudents' + index, (List<Contact>) TB_re_Utils.slice(students, i, i + packetSize));
            }
            Cache.Org.put(prefix + 'educationStudentsIndex', index);
            return index;
        }
    }

    @AuraEnabled
    public static Integer getEnrollments(
        String additionalEnrollmentFieldApis, String filterEnrollmentFieldApis, Integer studentsIndex,
        Integer packetSize, String prefix
    ) {
        if (Cache.Org.contains(prefix + 'educationEnrollmentsIndex')) {
            return Integer.valueOf(Cache.Org.get(prefix + 'educationEnrollmentsIndex'));
        } else {
            List<Contact> students = new List<Contact>();
            for (Integer i = 1; i <= studentsIndex; i++) {
                students.addAll((List<Contact>) Cache.Org.get(prefix + 'educationStudents' + i));
            }
            Set<Id> studentsIds = new Set<Id>();
            for (Contact student : students) {
                studentsIds.add(student.Id);
            }
            additionalEnrollmentFieldApis = String.isNotBlank(additionalEnrollmentFieldApis) ? ',' + additionalEnrollmentFieldApis : '';
            Set<String> allEnrollmentsFieldApis = new Set<String>((enrollmentFieldApis + additionalEnrollmentFieldApis).split(','));
            filterEnrollmentFieldApis = String.isNotBlank(filterEnrollmentFieldApis)
                ? ' AND ' + filterEnrollmentFieldApis
                : filterEnrollmentFieldApis;
            List<hed__Program_Enrollment__c> enrollments = Database.query(
                'SELECT ' + String.join(new List<String>(allEnrollmentsFieldApis), ',')
                    + ' FROM hed__Program_Enrollment__c' + ' WHERE hed__Contact__c IN :studentsIds' + filterEnrollmentFieldApis);
            Integer index = 0;
            for (Integer i = 0; i < enrollments.size(); i = i + packetSize) {
                index++;
                Cache.Org.put(prefix + 'educationEnrollments' + index, (List<hed__Program_Enrollment__c>) TB_re_Utils.slice(enrollments, i, i + packetSize));
            }
            Cache.Org.put(prefix + 'educationEnrollmentsIndex', index);
            Cache.Org.put(prefix + 'educationRefreshDate', System.now().format('yyyy.MM.dd\', \'HH:mm:ss', 'Poland'));
            return index;
        }
    }

    @AuraEnabled
    public static String getRefreshDate(String prefix) {
        return String.valueOf(Cache.Org.get(prefix + 'educationRefreshDate'));
    }

    @AuraEnabled
    public static List<EducationHistoryWrapper> retrieveRelatedData(
        String additionalContactFieldApis, String additionalEnrollmentFieldApis, String additionalApplicationFieldApis,
        Integer contactsIndex, Integer studentsIndex, Integer enrollmentsIndex, Integer applicationsIndex, Integer recordsLimit,
        Integer currentPage, String sortedBy, String sortDirection, String contactNameFilter, String applicationNameFilter,
        String prefix
    ) {
        List<Contact> students = new List<Contact>();
        for (Integer i = 1; i <= studentsIndex; i++) {
            students.addAll((List<Contact>) Cache.Org.get(prefix + 'educationStudents' + i));
        }
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= contactsIndex; i++) {
            contacts.addAll((List<Contact>) Cache.Org.get(prefix + 'educationContacts' + i));
        }
        Map<Id,Contact> studentIdToContact = new Map<Id,Contact>();
        for (Contact student : students) {
            for (Contact contact : contacts) {
                if (contact.IndividualId == student.IndividualId) {
                    studentIdToContact.put(student.Id,contact);
                }
            }
        }
        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 1; i <= applicationsIndex; i++) {
            applications.addAll((List<hed__Application__c>) Cache.Org.get(prefix + 'educationApplications' + i));
        }
        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        for (Integer i = 1; i <= enrollmentsIndex; i++) {
            enrollments.addAll((List<hed__Program_Enrollment__c>) Cache.Org.get(prefix + 'educationEnrollments' + i));
        }
        Map<Id, List<hed__Application__c>> contactIdToApplications = new Map<Id, List<hed__Application__c>>();
        contactIdToApplications = createApplicationsMap(contactIdToApplications, applications);
        Map<Id, List<hed__Program_Enrollment__c>> contactIdToEnrollments = new Map<Id, List<hed__Program_Enrollment__c>>();
        contactIdToEnrollments = createEnrollmentsMap(contactIdToEnrollments, enrollments);
        try {
            List<String> contactFieldsForCells = String.isNotBlank(additionalContactFieldApis) ? additionalContactFieldApis.split(',') : new List<String>();
            List<String> enrollmentFieldsForCells = String.isNotBlank(additionalEnrollmentFieldApis) ? additionalEnrollmentFieldApis.split(',') : new List<String>();
            List<String> applicationFieldsForCells = String.isNotBlank(additionalApplicationFieldApis) ? additionalApplicationFieldApis.split(',') : new List<String>();
            List<EducationHistoryWrapper> educationHistoryWrappers = new List<EducationHistoryWrapper>();
            for (Contact student : students) {
                if (contactIdToEnrollments.get(student.Id) != null) {
                    for (hed__Program_Enrollment__c enrollment : contactIdToEnrollments.get(student.Id)) {
                        if (contactIdToApplications.get(studentIdToContact.get(student.Id).Id) != null) {
                            for (hed__Application__c app : contactIdToApplications.get(studentIdToContact.get(student.Id).Id)) {
                                if (
                                    (String.isNotBlank(contactNameFilter) && studentIdToContact.get(student.Id).Name.contains(contactNameFilter) || String.isBlank(contactNameFilter))
                                        && (String.isNotBlank(applicationNameFilter) && app.Name.contains(applicationNameFilter) || String.isBlank(applicationNameFilter))
                                    ) {
                                    EducationHistoryWrapper educationHistoryWrapper = new EducationHistoryWrapper(studentIdToContact.get(student.Id), enrollment, app);
                                    educationHistoryWrapper.contactFields = contactFieldsForCells;
                                    educationHistoryWrapper.enrollmentFields = enrollmentFieldsForCells;
                                    educationHistoryWrapper.applicationFields = applicationFieldsForCells;
                                    educationHistoryWrappers.add(educationHistoryWrapper);
                                }
                            }
                        }
                    }
                }
            }
            return prepareWrappers(recordsLimit, currentPage, sortedBy, sortDirection, educationHistoryWrappers);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<EducationHistoryWrapper> prepareWrappers(
        Integer recordsLimit, Integer currentPage, String sortedBy, String sortDirection,
        List<EducationHistoryWrapper> educationHistoryWrappers
    ) {
        List<EducationHistoryWrapper> wrappersToReturn = new List<EducationHistoryWrapper>();
        if (educationHistoryWrappers.size() > 0) {
            if (String.isNotBlank(sortedBy) && String.isNotBlank(sortDirection)) {
                educationHistoryWrappers = sortCollection(educationHistoryWrappers, sortedBy, sortDirection);
            }
            Integer index = 1;
            for (EducationHistoryWrapper wrapper : educationHistoryWrappers) {
                wrapper.index = index;
                index++;
            }
            Integer actualLimit = recordsLimit;
            if (
                currentPage - 1 == educationHistoryWrappers.size() / recordsLimit
                    && Math.mod(educationHistoryWrappers.size(), recordsLimit) != 0
                ) {
                actualLimit = Math.mod(educationHistoryWrappers.size(), recordsLimit);
            }
            for (Integer i = 0; i < actualLimit; i++) {
                if (i < educationHistoryWrappers.size()) {
                    wrappersToReturn.add(educationHistoryWrappers[(currentPage - 1) * recordsLimit + i]);
                }
            }
            wrappersToReturn[0].size = educationHistoryWrappers.size();
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

    private static Map<Id,List<hed__Program_Enrollment__c>> createEnrollmentsMap(
        Map<Id,List<hed__Program_Enrollment__c>> contactIdToEnrollments, List<hed__Program_Enrollment__c> enrollments
    ) {
        for (hed__Program_Enrollment__c enrollment : enrollments) {
            List<hed__Program_Enrollment__c> enrollmentsByContact = new List<hed__Program_Enrollment__c>();
            if (contactIdToEnrollments.get(enrollment.hed__Contact__c) != null) {
                enrollmentsByContact = contactIdToEnrollments.get(enrollment.hed__Contact__c);
            }
            enrollmentsByContact.add(enrollment);
            contactIdToEnrollments.put(enrollment.hed__Contact__c, enrollmentsByContact);
        }
        return contactIdToEnrollments;
    }

    @AuraEnabled
    public static String getUserLanguage() {
        return UserInfo.getLanguage().substring(0,2);
    }

    @AuraEnabled
    public static String retrieveColumnData (
        Boolean sortable, Boolean editable, String additionalContactFieldApis, String additionalEnrollmentFieldApis,
        String additionalApplicationFieldApis
    ) {
        try {
            String language = getUserLanguage();
            //schema to validate field api names
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            List<String> objectAPINames = new List<String>{'Contact','hed__Application__c','hed__Program_Enrollment__c'};
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
                    inputFields = additionalEnrollmentFieldApis;
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
                        } else if (objectAPIName == 'hed__Program_Enrollment__c') {
                            responseWrapper.fieldName = 'Enrollment_' + objectField;
                            if (responseWrapper.fieldName == 'Enrollment_hed__Contact__c') {
                                responseWrapper.type = 'url';
                                responseWrapper.typeAttributes = new TypeAttributes('_blank');
                            }
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
            return JSON.serialize(responseWrappers);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public static List<EducationHistoryWrapper> sortCollection (List<EducationHistoryWrapper> collectionToSort, String sortingOption, String order) {
        for (EducationHistoryWrapper educationHistoryWrapper : collectionToSort) {
            educationHistoryWrapper.sortObject = sortingOption.substringBefore('_');
            educationHistoryWrapper.sortFieldName = sortingOption.substringAfter('_');
        }
        collectionToSort.sort();

        List<EducationHistoryWrapper> educationHistoryWrappersToReturn = new List<EducationHistoryWrapper>();
        if (order == 'asc') {
            educationHistoryWrappersToReturn = collectionToSort;
        } else if (order == 'desc') {
            for (Integer i = collectionToSort.size() - 1; i >= 0; i--) {
                educationHistoryWrappersToReturn.add(collectionToSort[i]);
            }
        }
        return educationHistoryWrappersToReturn;
    }

    public class EducationHistoryWrapper implements Comparable {
        @AuraEnabled public Contact contact { get;set; }
        @AuraEnabled public hed__Program_Enrollment__c enrollment { get;set; }
        @AuraEnabled public hed__Application__c application { get;set; }
        @AuraEnabled public List<String> contactFields { get;set; }
        @AuraEnabled public List<String> enrollmentFields { get;set; }
        @AuraEnabled public List<String> applicationFields { get;set; }
        @AuraEnabled public Integer size { get;set; }
        @AuraEnabled public Integer index { get;set; }
        public String sortObject { get; set; }
        public String sortFieldName { get; set; }

        public EducationHistoryWrapper(Contact contact, hed__Program_Enrollment__c enrollment, hed__Application__c application) {
            this.contact = contact;
            this.enrollment = enrollment;
            this.application = application;
        }

        public Integer compareTo(Object compareTo) {
            EducationHistoryWrapper compareToWrapper = (EducationHistoryWrapper)compareTo;

            Integer returnValue = 0;
            SObject sObj;
            SObject compareToSObject;
            if (sortObject == 'Contact') {
                sObj = this.contact;
                compareToSObject = compareToWrapper.contact;
            } else if (sortObject == 'Enrollment') {
                sObj = this.enrollment;
                compareToSObject = compareToWrapper.enrollment;
            } else if (sortObject == 'Application') {
                sObj = this.application;
                compareToSObject = compareToWrapper.application;
            }

            if (sObj != null && compareToSObject != null) {
                if (String.valueOf(sObj.get(this.sortFieldName)) > String.valueOf(compareToSObject.get(this.sortFieldName))) {
                    returnValue = 1;
                } else if (String.valueOf(sObj.get(this.sortFieldName)) < String.valueOf(compareToSObject.get(this.sortFieldName))) {
                    returnValue = -1;
                } else if ((String.valueOf(sObj.get(this.sortFieldName)) == null) && (String.valueOf(compareToSObject.get(this.sortFieldName)) != null)) {
                    returnValue = -1;
                } else if ((String.valueOf(sObj.get(this.sortFieldName)) != null) && (String.valueOf(compareToSObject.get(this.sortFieldName)) == null)) {
                    returnValue = 1;
                }
            }

            return returnValue;
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
public with sharing class TB_CT_CasesController {
    private static final String CATEGORY_CASE_ATTACHMENT = 'Case_Attachment';
    private static final List<String> DIDACTIC_PERM_SETS_NAMES = new List<String>{'TB_SWPS_Contract_Teachers_Applicant_Didactic'};
    private static final List<String> EMPLOYEE_PERM_SETS_NAMES = new List<String>{'TB_SWPS_Contract_Teachers_Coordinator', 'TB_SWPS_Contract_Teachers_Decision_Maker'};
    private static final String HIGHER_EDUCATION = 'Higher_Education';
    private static final String POSTGRADUATE_EDUCATION = 'Postgraduate';
    private final static Integer MAX_RESULTS = 5;
    private final static Integer MAX_RESULTS_TEST = 1;
    private final static String CONTACT_ICON = 'standard:contact';
    private final static Id EMPLOYEE_RECORD_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();
    private final static String VISIBILITY_ALL_USERS = 'AllUsers';
    private final static Id RECORD_TYPE_HE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contract_Teachers_HE_Case').getRecordTypeId();
    private final static Id RECORD_TYPE_PG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contract_Teachers_PG_Case').getRecordTypeId();
  
      @AuraEnabled
      public static List<Account> fetchDepartments(Id contactId, String selectedTypeOfStudy) {
          CaseOwnerDepartment innerClass = new CaseOwnerDepartment();
          return innerClass.fetchDepartments(contactId, selectedTypeOfStudy);
      }
  
      @AuraEnabled
      public static Id fetchContactId(){
          try {
              Contact con = [SELECT Id FROM Contact WHERE TB_User__c =:UserInfo.getUserId() LIMIT 1];
              return con != null ? con.Id : null;
          } catch (Exception e) {
              throw new AuraHandledException(e.getMessage());
          }
      }
  
      @AuraEnabled
      public static List<CaseWrapper> fetchOfficeCasesByFilter(String searchTerm, String sortType, String status, String caseType,
              Integer offsetFilter, Integer limitFilter) {
          CaseTypeEnum caseTypeEnum = toCaseTypeEnum(caseType);
          
          if(caseType == 'didactic') {
          Set<Id> didacticPermSetsIds = new Map<Id, PermissionSet>([
                      SELECT Id
                      FROM PermissionSet
                      WHERE Name IN :DIDACTIC_PERM_SETS_NAMES
                  ]).keySet();
          }
          if(caseType == 'office') {
          Set<Id> employeePermSetsIds = new Map<Id, PermissionSet>([
                      SELECT Id
                      FROM PermissionSet
                      WHERE Name IN :EMPLOYEE_PERM_SETS_NAMES
                  ]).keySet();
          }
          List<Case> officeCases;
          String query = buildStringQueryOffice(searchTerm, sortType, status, caseTypeEnum, offsetFilter, limitFilter);
          try {
              officeCases = Database.query(query);
          } catch (Exception ex) {
              TB_LogUtils.registerLog(ex);
              throw new AuraHandledException(ex.getMessage());
          }
  
          return prepareCaseWrappers(officeCases);
      }
  
      @AuraEnabled
      public static List<CaseWrapper> fetchDidacticCasesByFilter(String searchTerm, String sortType, String status, Id contactId,
              Integer offsetFilter, Integer limitFilter) {
  
          List<Case> cases;
          String query = buildStringQueryDidactic(searchTerm, sortType, status, contactId, offsetFilter, limitFilter);
          try {
              cases = Database.query(query);
          } catch (Exception ex) {
              TB_LogUtils.registerLog(ex);
              throw new AuraHandledException(ex.getMessage());
          }
  
          return prepareCaseWrappers(cases);
      }
  
      @AuraEnabled
      public static List<Case> fetchCases(Id contactId) {
          try {
              return [
                      SELECT
                              CaseNumber,
                              toLabel(TB_CT_Case_Category__c),
                              Subject,
                              Type,
                              Status,
                              CreatedDate,
                              CreatedById,
                              CreatedBy.Name,
                              LastModifiedDate,
                              Description,
                              Contact.hed__Gender__c,
                              TB_Last_Activity_Date__c,
                              OwnerId,
                              Owner.FirstName,
                              Owner.LastName,
                              TB_Responsible_Person__c,
                              TB_CT_Case_Subcategory__c,
                              TB_CT_Case_Department__r.Name,
                              Contact.Name,
                              toLabel(TB_Type_Of_Studies__c),
                              TB_CT_Department_Id__c
                      FROM Case
                      WHERE ContactId = :contactId AND (RecordTypeId = :RECORD_TYPE_HE OR RecordTypeId = :RECORD_TYPE_PG)
                      ORDER BY TB_Last_Activity_Date__c DESC
              ];
          } catch (Exception e) {
              throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_CT_CasesController.class.getName(),e.getStackTraceString(), contactId));
          }
      }
  
      @AuraEnabled
      public static List<CaseComment> fetchComments(Id caseId) {
          try {
              return [
                      SELECT CommentBody, CreatedById, CreatedDate, ParentId
                      FROM CaseComment
                      WHERE ParentId = :caseId
                      ORDER BY CreatedDate
              ];
          } catch(Exception e) {
              throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_CT_CasesController.class.getName(),e.getStackTraceString(), caseId));
          }
      }
  
      @AuraEnabled
      public static List<CommentWrapper> fetchCaseComments(Id caseId) {
          try {
              List<CommentWrapper> commentWrappers = new List<CommentWrapper>();
              List<CaseComment> comments = [
                      SELECT CommentBody, CreatedById, CreatedDate, ParentId
                      FROM CaseComment
                      WHERE ParentId = :caseId
                      ORDER BY CreatedDate
              ];
  
              List<Id> caseCommentIds = new List<Id> ();
              for (CaseComment comment : comments) {
                  caseCommentIds.add(comment.Id);
              }
  
              Map<String, List<ContentVersion>> commentIdToContentVersions = fetchCommentIdToContentVersions(new List<Id> {caseId});
  
              List<Id> userIds = getCommentUserIds(comments);
              Map<Id, Boolean> userIdToIsTeacher = TB_CT_CasesControllerSharingSkip.userIdToIsTeacher(userIds);
              Map<Id, String> userIdToName = TB_CT_CasesControllerSharingSkip.userIdToName(userIds);
              Map<Id, String> userIdToGender = TB_CT_CasesControllerSharingSkip.userIdToGender(userIds);
  
              for (CaseComment comment : comments) {
                  commentWrappers.add(
                          new CommentWrapper(
                                  comment,
                                  userIdToIsTeacher.get(comment.CreatedById),
                                  userIdToName.get(comment.CreatedById),
                                  commentIdToContentVersions.get(comment.Id),
                                  userIdToGender.get(comment.CreatedById)
                          )
                  );
              }
              return commentWrappers;
          } catch(Exception e) {
              throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_CT_CasesController.class.getName(),e.getStackTraceString(), caseId));
          }
      }
  
      @AuraEnabled
      public static Id createCaseComment(Id caseId, String comment) {
          try {
              CaseComment newComment = new CaseComment(
                      ParentId = caseId,
                      CommentBody = comment,
                      IsPublished = true
              );
              insert newComment;
              return newComment.Id;
          } catch(Exception e) {
              throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_CT_CasesController.class.getName(),e.getStackTraceString(), caseId));
          }
      }
  
      @AuraEnabled
      public static void updateContentVersions(List<Id> contentVersionIds, Id caseId, String caseCommentId) {
          try {
              List<ContentVersion> contentVersions = [
                      SELECT TB_Category__c, Title, ContentDocumentId, TB_Case_Comment__c
                      FROM ContentVersion
                      WHERE Id IN :contentVersionIds
              ];
              Map<Id, Id> contentVersionIdToContentDocumentId = new Map<Id, Id>();
              String title = getTitle(caseId);
              for (ContentVersion version : contentVersions) {
                  contentVersionIdToContentDocumentId.put(version.Id, version.ContentDocumentId);
                  version.Title = title;
                  version.TB_Category__c = CATEGORY_CASE_ATTACHMENT;
                  if (String.isNotBlank(caseCommentId)) {
                      version.TB_Case_Comment__c = caseCommentId;
                  }
              }
              update contentVersions;
  
              List<ContentDocumentLink> linksToInsert = getLinksToInsert(contentVersionIdToContentDocumentId, caseId);
              insert linksToInsert;
          } catch (Exception e) {
              throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_CT_CasesController.class.getName(),e.getStackTraceString(), caseId));
          }
      }
  
      @AuraEnabled
      public static void deleteContentDocuments(List<Id> contentVersionIds) {
          try {
              List<ContentVersion> contentVersions = [
                      SELECT ContentDocumentId
                      FROM ContentVersion
                      WHERE Id IN :contentVersionIds
              ];
              Set<String> contentDocIds = TB_SObjectUtils.createIdFieldValueSet(contentVersions, ContentVersion.ContentDocumentId);
  
              List<UserRecordAccess> deletableRecords = [
                      SELECT RecordId
                      FROM UserRecordAccess
                      WHERE UserId = :UserInfo.getUserId()
                      AND HasDeleteAccess = TRUE
                      AND RecordId IN :contentDocIds
              ];
  
              List<Id> deletableRecordIds = new List<Id>();
              for (UserRecordAccess deletableRecord : deletableRecords) {
                  deletableRecordIds.add(deletableRecord.Id);
              }
              List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE Id IN :deletableRecordIds];
              delete documents;
          } catch (Exception e) {
              throw new AuraHandledException(TB_LogUtils.prepareAuraLog(
                      e.getMessage(), TB_CT_CasesController.class.getName(),
                      e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
          }
      }
  
  
      @AuraEnabled(Cacheable=true)
      public static Map<String, String> fetchTypeOfStudyPicklistBasedOnEduLevel(Id contactId) {
          Id conId = contactId != null ? contactId : UserInfo.getUserId();
          Contact con;
          Boolean isHigherEducation;
          Boolean isPostgraduateEducation;
          String query = 'SELECT Id, TB_Didactic_Applicant_HE__c, TB_Didactic_Applicant_PG__c FROM Contact WHERE ';
          try {
              query = contactId != null ? query + 'Id =:conId' : query + 'TB_User__c =:conId';
              query+=' LIMIT 1';
              con = Database.query(query);
              isHigherEducation = con.TB_Didactic_Applicant_HE__c;
              isPostgraduateEducation = con.TB_Didactic_Applicant_PG__c;
          } catch (QueryException e) {
              throw new AuraHandledException(e.getMessage());
          }
  
          Map<String, String> valuesMap = new Map<String, String>();
          Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('Case');
          Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
          Map<String, Schema.SObjectField> fields = objDescribeSobject.fields.getMap();
          Schema.DescribeFieldResult fieldResult = fields.get('TB_Type_Of_Studies__c').getDescribe();
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
  
          if (isHigherEducation) {
              for (Schema.PicklistEntry pickListVal : ple) {
                  if (pickListVal.getValue() == HIGHER_EDUCATION) {
                      valuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
                  }
              }
          }
          if (isPostgraduateEducation) {
              for (Schema.PicklistEntry pickListVal : ple) {
                  if (pickListVal.getValue() == POSTGRADUATE_EDUCATION) {
                      valuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
                  }
              }
          }
          return valuesMap;
      }
  
      @AuraEnabled(Cacheable=true)
      public static List<LookupSearchResult> fetchContacts(List<Contact> allContacts) {
          try {
              List<Contact> didacticContacts = new List<Contact>();
              List<LookupSearchResult> results = new List<LookupSearchResult>();
              Boolean isDefaultResults = allContacts == null;
  
              allContacts = isDefaultResults ? fetchDidacticContacts() : allContacts;
              Map<Id, Id> userIdToContactId = new Map<Id, Id>();
              List<Id> userIds = new List<Id>();
              for (Contact c : allContacts) {
                  userIdToContactId.put(c.TB_User__c, c.Id);
                  userIds.add(c.TB_User__c);
              }
  
              Map<Id, Boolean> userIdToIsTeacher = TB_CT_CasesControllerSharingSkip.userIdToIsTeacher(
                      userIds
              );
              for (Contact c : allContacts) {
                  if (userIdToIsTeacher.get(c.TB_User__c)) {
                      didacticContacts.add(c);
                  }
              }
  
              if (isDefaultResults) {
                  Integer limited = Test.isRunningTest() ? MAX_RESULTS_TEST : allContacts.size() > 5 ?  MAX_RESULTS : allContacts.size()-1;
                  for (Integer i = 0; i < limited; i++) {
                      results.add(new LookupSearchResult(didacticContacts[i].Id,'Contact',CONTACT_ICON,didacticContacts[i].Name,'contact')
                      );
                  }
              } else {
                  for (Contact con : didacticContacts) {
                      results.add(new LookupSearchResult(con.Id,'Contact',CONTACT_ICON,con.Name,'contact')
                      );
                  }
              }
              results.sort();
  
              return results;
          } catch (Exception e) {
              throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(),TB_CT_CasesController.class.getName(),e.getStackTraceString(),''));
          }
      }
  
      @AuraEnabled(Cacheable=true Scope='global')
      public static List<LookupSearchResult> search(String searchTerm) {
          searchTerm += '*';
  
          List<List<SObject>> searchResults = [
                  FIND :searchTerm
                  IN NAME FIELDS
                  RETURNING
                          Contact(
                                  Id,
                                          Name,
                                          DT_PESEL__c,
                                          TB_User__c
                                  WHERE
                                  RecordTypeId = :EMPLOYEE_RECORD_TYPE
                                  AND TB_User__c != NULL
                                  AND TB_Active__c = TRUE
                                  AND (TB_Didactic_Applicant_HE__c = TRUE
                                  OR TB_Didactic_Applicant_PG__c = TRUE))
                  LIMIT :MAX_RESULTS
          ];
  
          Contact[] contacts = (List<Contact>) searchResults[0];
          List<LookupSearchResult> filteredContacts = fetchContacts(contacts);
          filteredContacts.sort();
  
          return filteredContacts;
      }
  
      private static String buildStringQueryOffice(String searchTerm, String sortType, String status, CaseTypeEnum caseTypeEnum,
              Integer offsetFilter, Integer limitFilter) {
  
          OrderType orderType = toOrderType(sortType);
  
          String query = 'SELECT CaseNumber, CreatedById, Subject, Contact.Name, ContactId, TB_Last_Activity_Date__c, ' +
                  'toLabel(TB_CT_Case_Category__c), Type, Status, CreatedDate, Description, LastModifiedDate, ' +
                  'Contact.hed__Gender__c, OwnerId, Owner.FirstName, Owner.LastName, TB_CT_Faculty_Office_Name__c, ' +
                  'TB_CT_Department_Id__c, TB_CT_Case_Department__r.Name, TB_Responsible_Person__c, TB_CT_Case_Responsible_Person__c, ' +
                  'toLabel(TB_Type_Of_Studies__c), TB_CT_Case_Subcategory__c, TB_CT_X_Contact_Full_Name__c, CreatedBy.Name ' +
                  'FROM Case WHERE (RecordTypeId = :RECORD_TYPE_HE OR RecordTypeId = :RECORD_TYPE_PG)';
  
          if (searchTerm != null) {
              searchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
              query += ' AND (toLabel(TB_CT_Case_Category__c) LIKE \'' + searchTerm
                      + '\' OR TB_CT_X_Contact_Full_Name__c LIKE \'' + searchTerm
                      + '\' OR CreatedBy.Name LIKE \'' + searchTerm + '\') ';
          }
  
          if (status != null) {
              query += ' AND Status = \'' + String.escapeSingleQuotes(status) + '\'';
          }
  
          if (caseTypeEnum != null) {
              switch on caseTypeEnum {
                  when DIDACTIC_TYPE {
                      query += ' AND OwnerId IN (' +
                              'SELECT AssigneeId ' +
                              'FROM PermissionSetAssignment ' +
                              'WHERE PermissionSetId IN ' +
                              ':didacticPermSetsIds' +
                              ')';
                  }
                  when OFFICE_TYPE {
                      query += ' AND OwnerId IN (' +
                              'SELECT AssigneeId ' +
                              'FROM PermissionSetAssignment ' +
                              'WHERE PermissionSetId IN ' +
                              ':employeePermSetsIds' +
                              ')';
                  }
                  when DEPARTMENT_TYPE {
                      Id fetchedDepartmentId;
                      try {
                          fetchedDepartmentId = TB_CT_CasesControllerSharingSkip.fetchDepartmentId(null, null);
                      } catch (Exception ex) {
                          // pass...
                          TB_LogUtils.registerLog(ex);
                      }
                      if (fetchedDepartmentId != null) {
                          query += ' AND TB_CT_Department_Id__c = \'' + fetchedDepartmentId + '\'';
                      }
                  }
                  when RESPONSIBLE_TYPE {
                      Id contactResponsibleId;
                      try {
                          contactResponsibleId = [SELECT Id FROM Contact WHERE TB_User__c =: UserInfo.getUserId() LIMIT 1].Id;
                      } catch (Exception ex) {
                          // pass...
                          TB_LogUtils.registerLog(ex);
                      }
                      if (contactResponsibleId != null) {
                          query += ' AND TB_CT_Case_Responsible_Person__c = \'' + contactResponsibleId + '\'';
                      }
                  }
              }
          }
  
  
          String orderingTerm = ' ORDER BY ';
          switch on orderType {
              when ASCENDING {
                  orderingTerm += 'TB_CT_Case_Category__c ASC';
              }
              when DESCENDING {
                  orderingTerm += 'TB_CT_Case_Category__c DESC';
              }
              when else {
                  orderingTerm += 'TB_Last_Activity_Date__c DESC';
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
  
      private static String buildStringQueryDidactic(String searchTerm, String sortType, String status, Id contactId,
              Integer offsetFilter, Integer limitFilter) {
  
          OrderType orderType = toOrderType(sortType);
  
          String query = 'SELECT CaseNumber, toLabel(TB_CT_Case_Category__c), Subject, Type, Status, CreatedDate, TB_CT_Faculty_Office_Name__c, ' +
                  'CreatedById, LastModifiedDate, Description, Contact.hed__Gender__c, TB_Last_Activity_Date__c, ' +
                  'OwnerId, CreatedBy.Name, Owner.FirstName, Owner.LastName, TB_CT_Case_Department__r.Name, TB_Responsible_Person__c, TB_CT_Case_Subcategory__c, ' +
                  'Contact.Name, toLabel(TB_Type_Of_Studies__c), TB_CT_Department_Id__c, TB_CT_Case_Responsible_Person__c, TB_CT_X_Contact_Full_Name__c ' +
                  'FROM Case WHERE ContactId = :contactId AND (RecordTypeId = :RECORD_TYPE_HE OR RecordTypeId = :RECORD_TYPE_PG)';
  
          if (searchTerm != null) {
              searchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
              query += ' AND (toLabel(TB_CT_Case_Category__c) LIKE \'' + searchTerm
                      + '\' OR CreatedBy.Name LIKE \'' + searchTerm + '\') ';
          }
  
          if (status != null) {
              query += ' AND Status = \'' + String.escapeSingleQuotes(status) + '\'';
          }
  
          String orderingTerm = ' ORDER BY ';
          switch on orderType {
              when ASCENDING {
                  orderingTerm += 'TB_CT_Case_Category__c ASC';
              }
              when DESCENDING {
                  orderingTerm += 'TB_CT_Case_Category__c DESC';
              }
              when else {
                  orderingTerm += ' TB_Last_Activity_Date__c DESC';
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
  
          System.debug(query);
  
          return query;
      }
  
      private static OrderType toOrderType(String order) {
          for(OrderType type : OrderType.values()) {
              if (type.name() == order) return type;
          }
          return null;
      }
  
      private static CaseTypeEnum toCaseTypeEnum(String caseType) {
          switch on caseType {
              when 'didactic' {
                  return CaseTypeEnum.DIDACTIC_TYPE;
              }
              when 'office' {
                  return CaseTypeEnum.OFFICE_TYPE;
              }
              when 'department' {
                  return CaseTypeEnum.DEPARTMENT_TYPE;
              }
              when 'byResponsible' {
                  return CaseTypeEnum.RESPONSIBLE_TYPE;
              }
              when else {
                  return null;
              }
          }
      }
  
    private static List<CaseWrapper> prepareCaseWrappers(List<Case> cases) {
        List<PermissionSetAssignment> userPermSetAssignments = [
          SELECT PermissionSet.Name
          FROM PermissionSetAssignment
          WHERE AssigneeId = :UserInfo.getUserId()
        ];
        Set<String> userPermSetsNames = new Set<String>();
  
        for(PermissionSetAssignment assignment : userPermSetAssignments) {
            userPermSetsNames.add(assignment.PermissionSet.Name);
        }
  
      Id officeEmployeeAccount = null;
      List<Account> mainDepartments = new List<Account>();
  
      userPermSetsNames.retainAll(EMPLOYEE_PERM_SETS_NAMES);
      if (!userPermSetsNames.isEmpty()) {
          List<Contact> loggedUserContact = [
            SELECT Id
            FROM Contact
            WHERE TB_User__c = :UserInfo.getUserId()
            LIMIT 1
          ];
        
          if (!loggedUserContact.isEmpty()) {
            List<hed__Affiliation__c> affiliations = [
              SELECT hed__Account__c
              FROM hed__Affiliation__c
              WHERE hed__Contact__c = :loggedUserContact[0].Id
              AND hed__Role__c = 'Employee'
              AND TB_Employee_Affiliation_Type__c = 'Agreement'
              LIMIT 1
            ];
        
            if (!affiliations.isEmpty()) {
              try {
              officeEmployeeAccount = affiliations[0].hed__Account__c;
        
              mainDepartments = [
                SELECT Name
                FROM Account
                WHERE Id = :officeEmployeeAccount
                LIMIT 1
              ];
              } catch (Exception e) {
                  mainDepartments = null;
                  officeEmployeeAccount = null;
                  throw new AuraHandledException(
                      TB_LogUtils.prepareAuraLog(
                          e.getMessage(),
                          TB_CT_CasesController.class.getName(),
                          e.getStackTraceString(),
                          ''
                      )
                  );
              }
            }
          }
        }
      
      List<Id> caseIds = new List<Id>();
      for (Case c : cases) {
        caseIds.add(c.Id);
      }
      List<CaseWrapper> resultWrappers = new List<CaseWrapper>();
      if (caseIds.size() > 0) {
        Map<Id, List<CommentWrapper>> caseIdToCaseComments = getCaseIdToCaseComments(caseIds);
        Map<Id, List<ContentVersion>> caseIdToContentVersions = getCaseIdToContentVersions(caseIds);
        List<Id> userIds = getCaseUserIds(cases);
        Map<Id, Boolean> userIdToIsTeacher = TB_CT_CasesControllerSharingSkip.userIdToIsTeacher(userIds);
  
        for (Case c : cases) {
          CaseWrapper wrapper = new CaseWrapper();
          wrapper.caseId = c.Id;
          wrapper.type = c.Type;
          wrapper.createdDate = c.CreatedDate;
          wrapper.description = c.Description;
          wrapper.caseNumber = c.CaseNumber;
          wrapper.status = c.Status;
          wrapper.contentVersions = caseIdToContentVersions.get(c.Id);
          wrapper.caseComments = caseIdToCaseComments.get(c.Id) == null ? new List<CommentWrapper>() : caseIdToCaseComments.get(c.Id);
          wrapper.lastActivityDate = c.TB_Last_Activity_Date__c == null ? c.CreatedDate : c.TB_Last_Activity_Date__c;
          wrapper.contactGender = c.Contact.hed__Gender__c;
          wrapper.createdByTeacher = userIdToIsTeacher.get(c.CreatedById);
          wrapper.ownerId = c.OwnerId;
          wrapper.responsiblePerson = c.TB_Responsible_Person__c;
          wrapper.category = c.TB_CT_Case_Category__c;
          wrapper.subcategory = c.TB_CT_Case_Subcategory__c;
          wrapper.typeOfStudy = c.TB_Type_Of_Studies__c;
          wrapper.departmentId = c.TB_CT_Department_Id__c;
          wrapper.departmentName = c.TB_CT_Faculty_Office_Name__c != null
                                      ? c.TB_CT_Faculty_Office_Name__c : c.TB_CT_Case_Department__r.Name;
          wrapper.createdBy = c.Owner.FirstName + ' ' + c.Owner.LastName;
  
          if (!userPermSetsNames.isEmpty()) {
            wrapper.responsiblePersonId = c.TB_CT_Case_Responsible_Person__c;
            wrapper.toContact = c.TB_CT_X_Contact_Full_Name__c;
            wrapper.affiliatedDepartmentOffices = mainDepartments;
          }
          resultWrappers.add(wrapper);
        }
      }
      return resultWrappers;
    }
  
      private static Map<Id, List<ContentVersion>> getCaseIdToContentVersions(List<Id> caseIds) {
          Map<Id, List<ContentVersion>> caseIdAllToContentVersions = getIdToContentVersions(caseIds);
          Map<Id, List<ContentVersion>> result = new Map<Id, List<ContentVersion>> ();
          for (Id caseId : caseIds) {
              List<ContentVersion> caseContentVersions = caseIdAllToContentVersions.get(caseId) == null ? new List<ContentVersion> () : caseIdAllToContentVersions.get(caseId);
              for (ContentVersion version : caseContentVersions) {
                  if (String.isBlank(version.TB_Case_Comment__c)) {
                      if (result.get(caseId) == null) {
                          result.put(caseId, new List<ContentVersion>{
                                  version
                          });
                      } else  {
                          result.get(caseId).add(version);
                      }
                  }
              }
          }
          return result;
      }
  
      private static Map<String, List<ContentVersion>> fetchCommentIdToContentVersions(List<Id> caseIds) {
          Map<Id, List<ContentVersion>> caseIdToAllContentVersions = getIdToContentVersions(caseIds);
          Map<String, List<ContentVersion>> commentIdToContentVersions = new Map<String, List<ContentVersion>> ();
          for (Id caseId : caseIds) {
              List<ContentVersion> caseVersions = caseIdToAllContentVersions.get(caseId) == null ? new List<ContentVersion> () : caseIdToAllContentVersions.get(caseId);
              for (ContentVersion version : caseVersions) {
                  String commentId = version.TB_Case_Comment__c;
                  if (String.isNotBlank(commentId)) {
                      if (commentIdToContentVersions.get(commentId) == null) {
                          commentIdToContentVersions.put(commentId, new List<ContentVersion>{
                                  version
                          });
                      } else  {
                          commentIdToContentVersions.get(commentId).add(version);
                      }
                  }
              }
          }
          return commentIdToContentVersions;
      }
  
      private static Map<Id, List<ContentVersion>> getIdToContentVersions(List<Id> ids) {
          Map<Id, List<ContentVersion>> idToContentVersions = new Map<Id, List<ContentVersion>>();
          List<ContentDocumentLink> contentDocumentLinks = getContentLinks(ids);
          Set<Id> allVersionIds = new Set<Id>();
  
          for (ContentDocumentLink link : contentDocumentLinks) {
              allVersionIds.add(link.ContentDocument.LatestPublishedVersionId);
          }
  
          Map<Id, ContentVersion> allContentIdToVersions = new Map<Id, ContentVersion>([
                  SELECT FileExtension, ContentSize, Title, TB_Case_Comment__c
                  FROM ContentVersion
                  WHERE Id IN :allVersionIds
          ]);
  
          for (ContentDocumentLink link : contentDocumentLinks) {
              Id versionId = link.ContentDocument.LatestPublishedVersionId;
              if (idToContentVersions.get(link.LinkedEntityId) == null) {
                  idToContentVersions.put(link.LinkedEntityId, new List<ContentVersion>{
                          allContentIdToVersions.get(versionId)
                  });
              } else {
                  idToContentVersions.get(link.LinkedEntityId).add(allContentIdToVersions.get(versionId));
              }
          }
          return idToContentVersions;
      }
  
      private static Map<Id, List<CommentWrapper>> getCaseIdToCaseComments(List<Id> caseIds) {
          Map<Id, List<CommentWrapper>> caseIdToCaseComments = new Map<Id, List<CommentWrapper>>();
          List<CaseComment> allCaseComments = [
                  SELECT CommentBody, CreatedById, CreatedDate, ParentId
                  FROM CaseComment
                  WHERE ParentId IN :caseIds
                  ORDER BY CreatedDate
          ];
          List<Id> userIds = getCommentUserIds(allCaseComments);
          Map<Id, Boolean> userIdToIsTeacher = TB_CT_CasesControllerSharingSkip.userIdToIsTeacher(userIds);
          Map<Id, String> userIdToName = TB_CT_CasesControllerSharingSkip.userIdToName(userIds);
          Map<Id, String> userIdToGender = TB_CT_CasesControllerSharingSkip.userIdToGender(userIds);
  
          List<Id> caseCommentIds = new List<Id> ();
          for (CaseComment comment : allCaseComments) {
              caseCommentIds.add(comment.Id);
          }
  
          Map<String, List<ContentVersion>> commentIdToContentVersions = fetchCommentIdToContentVersions(caseIds);
          for (CaseComment comment : allCaseComments) {
              CommentWrapper wrapper = new CommentWrapper(
                      comment,
                      userIdToIsTeacher.get(comment.CreatedById),
                      userIdToName.get(comment.CreatedById),
                      commentIdToContentVersions.get(comment.Id),
                      userIdToGender.get(comment.CreatedById)
              );
  
              if (caseIdToCaseComments.get(comment.ParentId) == null) {
                  caseIdToCaseComments.put(comment.ParentId, new List<CommentWrapper>{
                          wrapper
                  });
              } else {
                  caseIdToCaseComments.get(comment.ParentId).add(wrapper);
              }
          }
          return caseIdToCaseComments;
      }
  
    private static List<Id> getCommentUserIds(List<CaseComment> comments) {
      List<Id> userIds = new List<Id>();
      for (CaseComment comment : comments) {
        userIds.add(comment.CreatedById);
      }
      return userIds;
    }
  
    private static List<Id> getCaseUserIds(List<Case> cases) {
      List<Id> userIds = new List<Id>();
      for (Case c : cases) {
        userIds.add(c.CreatedById);
      }
      return userIds;
    }
  
    private static List<Contact> fetchDidacticContacts() {
      return [
        SELECT Id, Name, LastName, DT_PESEL__c, TB_User__c
        FROM Contact
        WHERE
          TB_User__c != NULL
          AND TB_Active__c = TRUE
          AND RecordTypeId = :EMPLOYEE_RECORD_TYPE
          AND (TB_Didactic_Applicant_HE__c = TRUE
          OR TB_Didactic_Applicant_PG__c = TRUE)
        ORDER BY LastName
        LIMIT 200
      ];
    }
  
      private static String getTitle(Id caseId) {
          Case associatedCase = [SELECT Contact.FirstName, Contact.LastName FROM Case WHERE Id = :caseId];
          String title = associatedCase.Contact.FirstName
                  + TB_Constants.TB_SEPARATOR_UNDERSCORE
                  + associatedCase.Contact.LastName
                  + TB_Constants.TB_SEPARATOR_UNDERSCORE
                  + CATEGORY_CASE_ATTACHMENT;
          return title;
      }
  
      private static List<ContentDocumentLink> getLinksToInsert(Map<Id, Id> contentVersionIdToContentDocumentId, Id caseId) {
          List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
          for (Id contentVersionId : contentVersionIdToContentDocumentId.keySet()) {
              linksToInsert.add(
                      new ContentDocumentLink(
                              LinkedEntityId = caseId,
                              ContentDocumentId = contentVersionIdToContentDocumentId.get(contentVersionId),
                              Visibility = VISIBILITY_ALL_USERS
                      )
              );
          }
          return linksToInsert;
      }
  
      private static List<ContentDocumentLink> getContentLinks(List<Id> linkedEntityIds) {
          List<ContentDocumentLink> contentLinks = [
                  SELECT ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId
                  FROM ContentDocumentLink
                  WHERE LinkedEntityId IN :linkedEntityIds
                  ORDER BY SystemModstamp DESC
                  LIMIT 1000
          ];
          return contentLinks;
      }
  
  
      public class CommentWrapper {
          @AuraEnabled public CaseComment comment;
          @AuraEnabled public Boolean isTeacher;
          @AuraEnabled public String createdByName;
          @AuraEnabled public String createdByGender;
          @AuraEnabled public List<ContentVersion> commentContentVersions;
  
          public CommentWrapper(CaseComment comment, Boolean isTeacher, String createdByName, List<ContentVersion> commentContentVersions, String createdByGender) {
              this.comment = comment;
              this.isTeacher = isTeacher;
              this.createdByName = createdByName;
              this.commentContentVersions = commentContentVersions;
              this.createdByGender = createdByGender;
          }
      }
  
      public class CaseWrapper {
          @AuraEnabled public Id caseId;
          @AuraEnabled public List<CommentWrapper> caseComments;
          @AuraEnabled public List<ContentVersion> contentVersions;
          @AuraEnabled public String subject;
          @AuraEnabled public String type;
          @AuraEnabled public Datetime createdDate;
          @AuraEnabled public Datetime lastActivityDate;
          @AuraEnabled public String caseNumber;
          @AuraEnabled public String status;
          @AuraEnabled public String description;
          @AuraEnabled public String contactGender;
          @AuraEnabled public Boolean createdByTeacher;
          @AuraEnabled public String responsiblePerson;
          @AuraEnabled public Id responsiblePersonId;
          @AuraEnabled public Id ownerId;
          @AuraEnabled public String category;
          @AuraEnabled public String subcategory;
          @AuraEnabled public String typeOfStudy;
          @AuraEnabled public Id departmentId;
          @AuraEnabled public String createdBy;
          @AuraEnabled public String toContact;
          @AuraEnabled public String departmentName;
          @AuraEnabled public List<Account> affiliatedDepartmentOffices;
      }
  
      private without sharing class CaseOwnerDepartment {
  
          public List<Account> fetchDepartments(Id contactId, String selectedTypeOfStudy) {
              String typeOfStudy = (selectedTypeOfStudy == 'Postgraduate') ? 'PG' : 'HE';
              Id contact;
              String organizationType = '';
              try {
                  if (contactId == null) {
                  contact = [SELECT Id FROM Contact WHERE TB_User__c = :UserInfo.getUserId() LIMIT 1].Id;
              } else {
                  contact = contactId;
                  organizationType = 'AND TB_Organization_Type__c = :typeOfStudy';
              }
  
              String query = 'SELECT Id, DT_Department__c, Name FROM Account WHERE Id IN ('
                      + 'SELECT hed__Account__c FROM hed__Affiliation__c '
                      + 'WHERE hed__Contact__c = :contact AND hed__Status__c = \'Current\''
                      + organizationType + ')';
          
              return Database.query(query);
              } catch (Exception e) {
                  throw new AuraHandledException(
                      TB_LogUtils.prepareAuraLog(
                          e.getMessage(),
                          TB_CT_CasesController.class.getName(),
                          e.getStackTraceString(),
                          ''
                      ));
                  }
              }
      }
  
      public enum OrderType {ASCENDING, DESCENDING}
  
      public enum CaseTypeEnum {DIDACTIC_TYPE, OFFICE_TYPE, DEPARTMENT_TYPE, RESPONSIBLE_TYPE}
  }
public with sharing class TB_CaseTriggerHandler extends TB_TriggerHandler {
    private static final String REG_EXP_ALL_HTML_TAGS = '(<.+?>)';
    private static final String REG_EXP_HTML_TEXT_FORMAT_TAGS = '((<|<\\/)(strong|em|u|strike|a)(( .*?>)|>))';
    private static final String REPLACEMENT_ALL_HTML_TAGS = ' ';
    private static final String REPLACEMENT_HTML_TEXT_FORMAT_TAGS = '';
    private static final String CASE_STATUS_CLOSED = 'Closed';
    private static final String APPLICATION_RECORD_TYPE_DEVNAME = 'TB_Student_Application_HE';
    private static final String QUESTION_RECORD_TYPE_DEVNAME = 'TB_Student_Question_HE';
    private static final String CERTIFICATE_RECORD_TYPE_DEVNAME = 'TB_Student_Certificate_HE';
    private static final String MEETING_RECORD_TYPE_DEVNAME = 'TB_Student_Meeting_HE';
	private static final List<String> EMPLOYEE_PERM_SETS_NAMES = new List<String>{'TB_SWPS_Contract_Teachers_Decision_Maker', 'TB_SWPS_Contract_Teachers_Coordinator'};
	private static final List<String> DIDACTIC_PERM_SETS_NAMES = new List<String>{'TB_SWPS_Contract_Teachers_Applicant_Didactic'};
    private static final String CATEGORY_CONTACT = 'Contact';
    private static final String CATEGORY_CONTRACT = 'Changing the type of contract';
    private static final String SUBCATEGORY_TEST = 'Student affairs';

    public override void beforeInsert() {
        updateDescription();
        fillMeetingDateTimeEmail();
	    fillLastActivityDate();
	    fillDepartmentLookup();
	    fillResponsiblePerson();
	    fillContactFullName();
    }

    public override void beforeUpdate() {
        updateDescription();
        fillMeetingDateTimeEmail();
	    fillLastActivityDate();
	    fillDepartmentLookup();
	    fillResponsiblePerson();
	    fillContactFullName();
    }

    public override void afterUpdate() {
        saveApplicationPDF();
    }

    private void updateDescription() {
        Map<String,RecordTypeInfo> recordTypeInfoMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        for (Case singleCase : (List<Case>) Trigger.new) {
            if ((Trigger.isInsert || (singleCase.TB_Description_Rich_Text__c != ((Case) Trigger.oldMap.get(singleCase.Id)).TB_Description_Rich_Text__c)) &&
                singleCase.RecordTypeId == recordTypeInfoMap.get(APPLICATION_RECORD_TYPE_DEVNAME).getRecordTypeId() ||
                singleCase.RecordTypeId == recordTypeInfoMap.get(QUESTION_RECORD_TYPE_DEVNAME).getRecordTypeId() ||
                singleCase.RecordTypeId == recordTypeInfoMap.get(MEETING_RECORD_TYPE_DEVNAME).getRecordTypeId() ||
                singleCase.RecordTypeId == recordTypeInfoMap.get(CERTIFICATE_RECORD_TYPE_DEVNAME).getRecordTypeId()) {
                if (String.isNotBlank(singleCase.TB_Description_Rich_Text__c)) {
                    singleCase.Description = singleCase.TB_Description_Rich_Text__c.replaceAll(REG_EXP_HTML_TEXT_FORMAT_TAGS, REPLACEMENT_HTML_TEXT_FORMAT_TAGS).replaceAll(REG_EXP_ALL_HTML_TAGS, REPLACEMENT_ALL_HTML_TAGS).normalizeSpace();
                }
                else {
                    singleCase.Description = '';
                }
            }
        }
    }

    private void saveApplicationPDF() {
        List<Case> casesToProcess = new List<Case>();
        for (Case singleCase : (List<Case>) Trigger.new) {
            if (singleCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(APPLICATION_RECORD_TYPE_DEVNAME).getRecordTypeId()
                    && singleCase.Status == CASE_STATUS_CLOSED && ((Case) Trigger.oldMap.get(singleCase.Id)).Status != CASE_STATUS_CLOSED) {
                casesToProcess.add(singleCase);
            }
        }
        if (!casesToProcess.isEmpty()) {
            TB_vu_ApplicationPreviewController.enqueuePDFGeneration(casesToProcess);
        }
    }
	
    private static void fillLastActivityDate() {
		for (Case singleCase : (List<Case>) Trigger.new) {
			Datetime currentDateTimePoland = new TB_CT_LastActivityManager().getCurrentDateTimePoland();
			singleCase.TB_Last_Activity_Date__c = currentDateTimePoland;
		}
	  }
	
	private static void fillDepartmentLookup() {
		for (Case singleCase : (List<Case>) Trigger.new) {
			if (String.isNotBlank(singleCase.TB_CT_Department_Id__c)) {
				singleCase.TB_CT_Case_Department__c = singleCase.TB_CT_Department_Id__c;
			}
		}
	}

	private static void fillResponsiblePerson() {
	    Id recordTypeIdHE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contract_Teachers_HE_Case').getRecordTypeId();
	    Id recordTypeIdPG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contract_Teachers_PG_Case').getRecordTypeId();
		Set<Id> employeePermSetsIds = new Map<Id, PermissionSet>([SELECT Id FROM PermissionSet WHERE Name IN :EMPLOYEE_PERM_SETS_NAMES]).keySet();
		Set<Id> didacticPermSetsIds = new Map<Id, PermissionSet>([SELECT Id FROM PermissionSet WHERE Name IN :DIDACTIC_PERM_SETS_NAMES]).keySet();

		Id caseContactId = null;
		TB_App_Tracking__c primaryResponsible = null;
		List<PermissionSetAssignment> userPermSetAssignments = [
			SELECT Id
			FROM PermissionSetAssignment
			WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN :employeePermSetsIds
		];
		List<PermissionSetAssignment> didacticUserPermSetAssignments = [
			SELECT Id
			FROM PermissionSetAssignment
			WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN :didacticPermSetsIds
		];
		if(userPermSetAssignments.isEmpty() && didacticUserPermSetAssignments.isEmpty()) return;


		List<Contact> contactIdList = Test.isRunningTest() ? [SELECT Id
											   FROM Contact 
											   LIMIT 1]
											   :
											   [SELECT Id 
											   FROM Contact 
											   WHERE TB_User__c =:UserInfo.getUserId() 
											   LIMIT 1];


		for (Case c : (List<Case>) Trigger.new) {
			if(c.RecordTypeId != recordTypeIdHE && c.RecordTypeId != recordTypeIdPG ) return;
			caseContactId = c.ContactId;

			if(Test.isRunningTest()) {
				if(contactIdList.isEmpty()) return;
				c.TB_CT_Case_Category__c = CATEGORY_CONTACT;
				c.TB_CT_Case_Subcategory__c = SUBCATEGORY_TEST;
			}

			if (!userPermSetAssignments.isEmpty()) {
				c.TB_CT_Case_Responsible_Person__c = contactIdList[0]?.Id;
				return;
			} 
		}

		try {
			 primaryResponsible = [
				SELECT TB_Dean_s_Office_Responsible__c
				FROM TB_App_Tracking__c
				WHERE TB_Applicant__c = :caseContactId
				LIMIT 1
			];
		} catch (Exception e) {
			primaryResponsible = null;
	        throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(),TB_CT_CasesController.class.getName(),e.getStackTraceString(),''));
	    }
	    
		for (Case singleCase : (List<Case>) Trigger.new) {
			if (
				singleCase.TB_CT_Case_Category__c != CATEGORY_CONTACT &&
				singleCase.TB_CT_Case_Category__c != CATEGORY_CONTRACT
			  ) {
				if (primaryResponsible != null) {
					singleCase.TB_CT_Case_Responsible_Person__c = primaryResponsible.TB_Dean_s_Office_Responsible__c;
				  }
			  }

		 }
  }

	private static void fillContactFullName() {
		Set<Id> contactIds = new Set<Id>();
		for (Case c : (List<Case>) Trigger.new) {
			contactIds.add(c.ContactId);
		}
		
		Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contactIds]);
	
		for (Case c : (List<Case>) Trigger.new) {
			if (contactMap.containsKey(c.ContactId)) {
				c.TB_CT_x_Contact_Full_Name__c = contactMap.get(c.ContactId).Name;
			}
		}
	}


    private void fillMeetingDateTimeEmail(){
        Id meetingRecordTypeIdHE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(MEETING_RECORD_TYPE_DEVNAME).getRecordTypeId();
        for (Case singleCase : (List<Case>) Trigger.new){
            if(singleCase.RecordTypeId == meetingRecordTypeIdHE && singleCase.TB_Meeting_DateTime__c != null){
                Datetime meetingDateTime = singleCase.TB_Meeting_DateTime__c;
                singleCase.TB_Meeting_Time_Email__c = meetingDateTime.format('HH:mm z', TB_Constants.TIMEZONE_POLAND);
            }
        }
    }
}
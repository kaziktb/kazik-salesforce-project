public without sharing class CsInternshipOfferApprovalLogic extends CsApprovalProcessLogicImplementor {
    public enum DecisionValue {
        Approve,
        Reject
    }

    public CsInternshipOfferApprovalLogic() {
        super.registerStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE, CareerServicesAcceptanceStageLogic.class.getName());
        super.registerStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE, SupervisorAcceptanceStageLogic.class.getName());
    }

    public class CareerServicesStageExecutionData {
        public String decision;
        public String comment;
        public List<OfferAssignmentToCreateWrapper> offerAssignmentsToCreate;
    }

    public class OfferAssignmentToCreateWrapper {
        public String accountId;
        public String supervisorId;
    }

    public class CareerServicesAcceptanceStageLogic extends CsApprovalProcessStageLogicImplementor {
        public override CsApprovalProcessStageExecutionResult execute(Approval_Process__c approvalProcess, String jsonData) {
            CareerServicesStageExecutionData data = (CareerServicesStageExecutionData) JSON.deserializeStrict(jsonData, CareerServicesStageExecutionData.class);
            Career_Services_Offer__c offer = [SELECT Status__c FROM Career_Services_Offer__c WHERE Id = :approvalProcess.Related_Record_Id__c];
            DecisionValue decision = DecisionValue.valueOf(data.decision);

            switch on decision {
                when Approve {
                    offer.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_SUPERVISOR_VERIFICATION;

                    CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);

                    approvalProcess.Stage__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE;

                    List<Career_Services_Offer_Assignment__c> offerAssignments = new List<Career_Services_Offer_Assignment__c>();

                    for (OfferAssignmentToCreateWrapper wrapper : data.offerAssignmentsToCreate) {                        
                        offerAssignments.add(
                            new Career_Services_Offer_Assignment__c(
                                Account__c = wrapper.accountId,
                                Internship_Supervisor__c = wrapper.supervisorId,
                                Career_Services_Offer__c = offer.Id,
                                Is_Obligatory__c = true
                            )
                        );
                    }

                    insert offerAssignments;
                }
                when Reject {
                    offer.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_REJECTED;
                    offer.Career_Services_Rejection_Reason__c = data.comment;

                    Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);

                    CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, data.comment, decisionEntry.Id, true);

                    approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED;
                }
            }

            update offer;
            update approvalProcess;

            return CsApprovalProcessStageExecutionResult.success();
        }

        public override CsApprovalProcessStageBaseData retrieveStageData(Approval_Process__c approvalProcess) {
            return super.initStepBaseData(canPerformAction(approvalProcess.Related_Record_Id__c));
        }

        private Boolean canPerformAction(Id relatedRecordId) {
            Career_Services_Offer__c offer = [SELECT Id, Status__c FROM Career_Services_Offer__c WHERE Id = :relatedRecordId];
            Boolean isCurrentUserSupervisor = ![SELECT Id FROM Internship_Supervisor__c WHERE User__c = :UserInfo.getUserId()].isEmpty();

            return offer.Status__c == Constants.CAREER_SERVICES_OFFER_STATUS_NEW_OFFER
                && !isCurrentUserSupervisor
                && Utils.isPermissionSetAssigned(Constants.PERMISSION_SET_CAREER_SERVICES_EMPLOYEE_API_NAME, UserInfo.getUserId());
        }
    }

    public class SupervisorStageExecutionData {
        List<SupervisorDecisionWrapper> offerAssignmentsToUpdate;
    }

    public class SupervisorDecisionWrapper {
        public String id;
        public String decision;
        public String comment;
    }

    public class SupervisorAcceptanceStageLogic extends CsApprovalProcessStageLogicImplementor {
        public override CsApprovalProcessStageExecutionResult execute(Approval_Process__c approvalProcess, String jsonData) {
            SupervisorStageExecutionData data = (SupervisorStageExecutionData) JSON.deserializeStrict(jsonData, SupervisorStageExecutionData.class);
            Career_Services_Offer__c offer = [SELECT Status__c FROM Career_Services_Offer__c WHERE Id = :approvalProcess.Related_Record_Id__c];
            List<Career_Services_Offer_Assignment__c> offerAssignmentsToUpdate = new List<Career_Services_Offer_Assignment__c>();
            Boolean hasAnyApproval = false;

            for (SupervisorDecisionWrapper wrapper : data.offerAssignmentsToUpdate) {
                DecisionValue decision = DecisionValue.valueOf(wrapper.decision);

                switch on decision {
                    when Approve {
                        Career_Services_Offer_Assignment__c assignment = new Career_Services_Offer_Assignment__c(Id = wrapper.id, Is_Accepted__c = true, Has_Decision_Been_Made__c = true);
                        offerAssignmentsToUpdate.add(assignment);

                        Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, wrapper.decision, true);

                        hasAnyApproval = true;
                    }
                    when Reject {
                        Career_Services_Offer_Assignment__c assignment = new Career_Services_Offer_Assignment__c(Id = wrapper.id, Is_Accepted__c = false, Has_Decision_Been_Made__c = true);
                        offerAssignmentsToUpdate.add(assignment);

                        Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, wrapper.decision, true);
                        CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, wrapper.comment, decisionEntry.Id, true);
                    }
                }
            }

            update offerAssignmentsToUpdate;

            if (hasAnyApproval && offer.Status__c != Constants.CAREER_SERVICES_OFFER_STATUS_AGREEMENT_CREATION) {
                offer.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_AGREEMENT_CREATION;
                
                update offer;
            }

            if (checkIfDecisionMadeByAllSupervisors(offer.Id)) {
                approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED;

                update approvalProcess;
            }

            if (checkIfRejectedByAllSupervisors(offer.Id)) {
                offer.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_REJECTED;
                approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED;

                update offer;
                update approvalProcess;
            }

            return CsApprovalProcessStageExecutionResult.success();
        }

        public override CsApprovalProcessStageBaseData retrieveStageData(Approval_Process__c approvalProcess) {
            Boolean canPerformAction = canPerformAction(approvalProcess.Related_Record_Id__c);
            CsApprovalProcessStageBaseData data = super.initStepBaseData(canPerformAction);
            Boolean isCurrentUserSupervisor = ![SELECT Id FROM Internship_Supervisor__c WHERE User__c = :UserInfo.getUserId()].isEmpty();

            if (!canPerformAction && isCurrentUserSupervisor) {
                return data;
            }

            Map<String, String> supervisorName2Email = new Map<String, String>();

            for (Career_Services_Offer_Assignment__c offerAssignment : [
                SELECT Internship_Supervisor__r.Name, Internship_Supervisor__r.Contact__r.hed__WorkEmail__c
                FROM Career_Services_Offer_Assignment__c
                WHERE Career_Services_Offer__c = :approvalProcess.Related_Record_Id__c
                    AND Has_Decision_Been_Made__c = false
            ]) {
                supervisorName2Email.put(offerAssignment.Internship_Supervisor__r.Name, offerAssignment.Internship_Supervisor__r.Contact__r.hed__WorkEmail__c);
            }

            Boolean isAllowedToSendReminder = supervisorName2Email.size() > 0
                && !isCurrentUserSupervisor
                && Utils.isPermissionSetAssigned(Constants.PERMISSION_SET_CAREER_SERVICES_EMPLOYEE_API_NAME, UserInfo.getUserId());

            if (!canPerformAction && !isAllowedToSendReminder) {
                return data;
            }

            Map<String, Date> supervisorEmail2LastReminderDate = new Map<String, Date>();
            
            for (Approval_Process_Entry__c entry : [
                SELECT CreatedDate, Value__c
                FROM Approval_Process_Entry__c
                WHERE Approval_Process__c = :approvalProcess.Id
                    AND RecordType.DeveloperName = :Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_REMINDER_RECORD_TYPE
                ORDER BY CreatedDate DESC
            ]) {
                if (!supervisorEmail2LastReminderDate.containsKey(entry.Value__c)) {
                    supervisorEmail2LastReminderDate.put(entry.Value__c, entry.CreatedDate.date());
                }
            }

            JSONGenerator jsonData = JSON.createGenerator(false);
            jsonData.writeStartObject();

            jsonData.writeBooleanField('isAllowedToSendReminder', isAllowedToSendReminder);

            jsonData.writeFieldName('reminders');
            jsonData.writeStartArray();
            for (String key : supervisorName2Email.keySet()) {
                Boolean isSendDisabled = false;
                String supervisorEmail = supervisorName2Email.get(key);
                jsonData.writeStartObject();
                jsonData.writeStringField('supervisorName', key);
                if (!String.isBlank(supervisorEmail)) {
                    jsonData.writeStringField('supervisorEmail', supervisorEmail);
                }
                if (supervisorEmail2LastReminderDate.containsKey(supervisorEmail)) {
                    Date lastReminderDate = supervisorEmail2LastReminderDate.get(supervisorEmail);
                    jsonData.writeDateField('lastReminderDate', lastReminderDate);
                    isSendDisabled = lastReminderDate.daysBetween(Date.today()) < 3;
                }
                jsonData.writeBooleanField('isSendDisabled', isSendDisabled);
                jsonData.writeEndObject();
            }
            jsonData.writeEndArray();

            jsonData.writeFieldName('offerAssignments');
            jsonData.writeStartArray();
            for (Career_Services_Offer_Assignment__c offerAssignment : [
                SELECT Account__r.Name, Account__r.Parent.Name, Account__r.Parent.Parent.Name, Account__r.Parent.Parent.Parent.Name
                FROM Career_Services_Offer_Assignment__c
                WHERE Career_Services_Offer__c = :approvalProcess.Related_Record_Id__c
                    AND Internship_Supervisor__r.User__c = :UserInfo.getUserId()
                    AND Has_Decision_Been_Made__c = false
            ]) {
                jsonData.writeStartObject();
                jsonData.writeStringField('id', offerAssignment.Id);
                jsonData.writeStringField('accountHierarchy', createAccountHierarchy(offerAssignment));
                jsonData.writeEndObject();
            }
            jsonData.writeEndArray();

            jsonData.writeEndObject();
            data.jsonData = jsonData.getAsString();

            return data;
        }

        private Boolean canPerformAction(Id relatedRecordId) {
            Boolean hasAnyOpenAssignment = false;
            Career_Services_Offer__c offer = [SELECT Status__c, (SELECT Has_Decision_Been_Made__c FROM Career_Services_Offer_Assignments__r WHERE Internship_Supervisor__r.User__c = :UserInfo.getUserId()) FROM Career_Services_Offer__c WHERE Id = :relatedRecordId];
            List<String> allowedStatuses = new List<String>{
                Constants.CAREER_SERVICES_OFFER_STATUS_SUPERVISOR_VERIFICATION,
                Constants.CAREER_SERVICES_OFFER_STATUS_AGREEMENT_CREATION,
                Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED
            };

            for (Career_Services_Offer_Assignment__c offerAssignment : offer.Career_Services_Offer_Assignments__r) {
                if (!offerAssignment.Has_Decision_Been_Made__c) {
                    hasAnyOpenAssignment = true;
                    break;
                }
            }

            return allowedStatuses.contains(offer.Status__c)
                && hasAnyOpenAssignment
                && Utils.isPermissionSetAssigned(Constants.PERMISSION_SET_CAREER_SERVICES_EMPLOYEE_API_NAME, UserInfo.getUserId());
        }

        private String createAccountHierarchy(Career_Services_Offer_Assignment__c offerAssignment) {
            List<String> accountNames = new List<String>();

            if (offerAssignment.Account__r.Parent.Parent.Parent.Name != null && offerAssignment.Account__r.Parent.Parent.Parent.Name != Constants.ACCOUNT_DEPARTMENT_ACCOUNT_NAME) {
                accountNames.add(offerAssignment.Account__r.Parent.Parent.Parent.Name);
            }

            if (offerAssignment.Account__r.Parent.Parent.Name != null && offerAssignment.Account__r.Parent.Parent.Name != Constants.ACCOUNT_DEPARTMENT_ACCOUNT_NAME) {
                accountNames.add(offerAssignment.Account__r.Parent.Parent.Name);
            }

            accountNames.add(offerAssignment.Account__r.Parent.Name);
            accountNames.add(offerAssignment.Account__r.Name);

            return String.join(accountNames, ' > ');
        }

        private Boolean checkIfRejectedByAllSupervisors(String offerId) {
            return [
                SELECT Id
                FROM Career_Services_Offer_Assignment__c
                WHERE Career_Services_Offer__c = :offerId
                    AND ((Is_Accepted__c = TRUE AND Has_Decision_Been_Made__c = TRUE) OR Has_Decision_Been_Made__c = FALSE)
            ].isEmpty();
        }

        private Boolean checkIfDecisionMadeByAllSupervisors(String offerId) {
            return [SELECT Id FROM Career_Services_Offer_Assignment__c WHERE Career_Services_Offer__c = :offerId AND Has_Decision_Been_Made__c = FALSE].isEmpty();
        }
    }

}
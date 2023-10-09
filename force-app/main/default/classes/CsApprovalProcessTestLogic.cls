@IsTest
public class CsApprovalProcessTestLogic extends CsApprovalProcessLogicImplementor {
    public final static String TEST_STAGE_DATA_TEST_INTEGER_FIELD_NAME = 'testInteger';
    public final static Integer TEST_STAGE_DATA_TEST_INTEGER_VALUE = 25;

    public CsApprovalProcessTestLogic() {
        super.registerStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE, TestStageOneLogic.class.getName());
        super.registerStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE, TestStageTwoLogic.class.getName());
    }
    public class TestStageOneLogic extends CsApprovalProcessStageLogicImplementor {
        public override CsApprovalProcessStageExecutionResult execute(Approval_Process__c approvalProcess, String jsonData) {
            approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED;

            update approvalProcess;

            return CsApprovalProcessStageExecutionResult.success();
        }

        public override CsApprovalProcessStageBaseData retrieveStageData(Approval_Process__c approvalProcess) {
            Map<String, Object> dataMap = new Map<String, Object> {
                TEST_STAGE_DATA_TEST_INTEGER_FIELD_NAME => TEST_STAGE_DATA_TEST_INTEGER_VALUE
            };

            CsApprovalProcessStageBaseData data = super.initStepBaseData(true);
            data.jsonData = JSON.serialize(dataMap);

            return data;
        }
    }

    public class TestStageTwoLogic extends CsApprovalProcessStageLogicImplementor {

        public override CsApprovalProcessStageExecutionResult execute(Approval_Process__c approvalProcess, String jsonData) {
            return CsApprovalProcessStageExecutionResult.success();
        }

        public override CsApprovalProcessStageBaseData retrieveStageData(Approval_Process__c approvalProcess) {
            return super.initStepBaseData(false);
        }
    }
}


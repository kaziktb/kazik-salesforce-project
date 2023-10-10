declare module "@salesforce/apex/TB_AdmissionsFormsController.getApplication" {
  export default function getApplication(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.disableAdmissionsLogic" {
  export default function disableAdmissionsLogic(): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.getRedirectLogics" {
  export default function getRedirectLogics(param: {application: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.getAdmissionsStages" {
  export default function getAdmissionsStages(param: {application: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.getAdmissionsSteps" {
  export default function getAdmissionsSteps(param: {admissionsSteps: any, stageWrapper: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.getStepsHistory" {
  export default function getStepsHistory(param: {stepsHistory: any, stageWrapper: any, stepsExpected: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.createStepHistory" {
  export default function createStepHistory(param: {applicationId: any, stageId: any, stepId: any, stepData: any, status: any, browserInfo: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.blockFormAbsolutely" {
  export default function blockFormAbsolutely(param: {application: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.registerLastActionsOnApplication" {
  export default function registerLastActionsOnApplication(param: {application: any, action: any, data: any, stepId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.clearComment" {
  export default function clearComment(param: {application: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsFormsController.validateExamResult" {
  export default function validateExamResult(param: {application: any}): Promise<any>;
}

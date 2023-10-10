declare module "@salesforce/apex/CsApprovalProcessController.retrieveCurrentStageData" {
  export default function retrieveCurrentStageData(param: {requestingRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CsApprovalProcessController.initApprovalProcess" {
  export default function initApprovalProcess(param: {requestingRecordId: any, recordTypeDeveloperName: any}): Promise<any>;
}
declare module "@salesforce/apex/CsApprovalProcessController.executeCurrentStage" {
  export default function executeCurrentStage(param: {approvalProcessId: any, recordTypeDeveloperName: any, jsonData: any}): Promise<any>;
}
declare module "@salesforce/apex/CsApprovalProcessController.abandonApprovalProcess" {
  export default function abandonApprovalProcess(param: {requestingRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CsApprovalProcessController.sendReminder" {
  export default function sendReminder(param: {requestingRecordId: any, recipientEmail: any}): Promise<any>;
}

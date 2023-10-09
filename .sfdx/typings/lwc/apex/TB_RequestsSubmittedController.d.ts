declare module "@salesforce/apex/TB_RequestsSubmittedController.loadSubmittedRequests" {
  export default function loadSubmittedRequests(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_RequestsSubmittedController.getCaseComments" {
  export default function getCaseComments(param: {requestId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_RequestsSubmittedController.insertComment" {
  export default function insertComment(param: {requestCaseId: any, comment: any}): Promise<any>;
}

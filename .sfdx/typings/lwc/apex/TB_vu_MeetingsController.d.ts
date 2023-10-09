declare module "@salesforce/apex/TB_vu_MeetingsController.fetchCaseWrappers" {
  export default function fetchCaseWrappers(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_MeetingsController.fetchCases" {
  export default function fetchCases(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_MeetingsController.fetchCaseComments" {
  export default function fetchCaseComments(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_MeetingsController.createCaseComment" {
  export default function createCaseComment(param: {caseId: any, contactId: any, comment: any}): Promise<any>;
}

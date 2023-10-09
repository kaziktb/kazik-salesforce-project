declare module "@salesforce/apex/TB_vu_QuestionsController.fetchCaseWrappers" {
  export default function fetchCaseWrappers(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_QuestionsController.fetchCases" {
  export default function fetchCases(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_QuestionsController.fetchCaseComments" {
  export default function fetchCaseComments(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_QuestionsController.createCaseComment" {
  export default function createCaseComment(param: {caseId: any, contactId: any, comment: any}): Promise<any>;
}

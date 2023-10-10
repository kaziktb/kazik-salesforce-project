declare module "@salesforce/apex/TB_CT_CasesController.fetchDepartments" {
  export default function fetchDepartments(param: {contactId: any, selectedTypeOfStudy: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.fetchContactId" {
  export default function fetchContactId(): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.fetchOfficeCasesByFilter" {
  export default function fetchOfficeCasesByFilter(param: {searchTerm: any, sortType: any, status: any, caseType: any, offsetFilter: any, limitFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.fetchDidacticCasesByFilter" {
  export default function fetchDidacticCasesByFilter(param: {searchTerm: any, sortType: any, status: any, contactId: any, offsetFilter: any, limitFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.fetchCases" {
  export default function fetchCases(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.fetchComments" {
  export default function fetchComments(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.fetchCaseComments" {
  export default function fetchCaseComments(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.createCaseComment" {
  export default function createCaseComment(param: {caseId: any, comment: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.updateContentVersions" {
  export default function updateContentVersions(param: {contentVersionIds: any, caseId: any, caseCommentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.deleteContentDocuments" {
  export default function deleteContentDocuments(param: {contentVersionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.fetchTypeOfStudyPicklistBasedOnEduLevel" {
  export default function fetchTypeOfStudyPicklistBasedOnEduLevel(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.fetchContacts" {
  export default function fetchContacts(param: {allContacts: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_CasesController.search" {
  export default function search(param: {searchTerm: any}): Promise<any>;
}

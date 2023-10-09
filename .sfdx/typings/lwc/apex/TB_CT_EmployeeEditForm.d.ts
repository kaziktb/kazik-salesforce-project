declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchDegreeFieldInfos" {
  export default function fetchDegreeFieldInfos(): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchTitles" {
  export default function fetchTitles(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchContacts" {
  export default function fetchContacts(): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchAppTracking" {
  export default function fetchAppTracking(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchExperienceHistory" {
  export default function fetchExperienceHistory(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchLatestContVerBasedOnCategory" {
  export default function fetchLatestContVerBasedOnCategory(param: {linkedEntityId: any, category: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.sendCommentEmailToTeacher" {
  export default function sendCommentEmailToTeacher(param: {comment: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.sendCommentEmailToResponsibles" {
  export default function sendCommentEmailToResponsibles(param: {comment: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.updateAppTrackingStatus" {
  export default function updateAppTrackingStatus(param: {contactId: any, statusValue: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.getAppTrackingStatus" {
  export default function getAppTrackingStatus(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchMultipleContentVersionIds" {
  export default function fetchMultipleContentVersionIds(param: {linkedEntityId: any, category: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchMultipleContentVersions" {
  export default function fetchMultipleContentVersions(param: {linkedEntityId: any, category: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchMultipleContentVersionsCacheable" {
  export default function fetchMultipleContentVersionsCacheable(param: {linkedEntityId: any, category: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.updateContentVersions" {
  export default function updateContentVersions(param: {contentVersions: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.deleteContentDocuments" {
  export default function deleteContentDocuments(param: {contentVersionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.deleteContentDocumentsWithoutCategory" {
  export default function deleteContentDocumentsWithoutCategory(param: {linkedEntityId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.deleteAssociatedFiles" {
  export default function deleteAssociatedFiles(param: {linkedEntityId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.fetchAffiliations" {
  export default function fetchAffiliations(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.updateAffiliations" {
  export default function updateAffiliations(param: {affiliationsToUpdate: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.hasAppTracking" {
  export default function hasAppTracking(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.getContact" {
  export default function getContact(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.deleteExperienceHistoryRecord" {
  export default function deleteExperienceHistoryRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.isPeselUnique" {
  export default function isPeselUnique(param: {contactId: any, pesel: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.isDocumentUnique" {
  export default function isDocumentUnique(param: {contactId: any, docNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_EmployeeEditForm.isHEDidactic" {
  export default function isHEDidactic(param: {contactId: any}): Promise<any>;
}

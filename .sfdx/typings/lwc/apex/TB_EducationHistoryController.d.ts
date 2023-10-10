declare module "@salesforce/apex/TB_EducationHistoryController.getApplicationNoRequiredStatus" {
  export default function getApplicationNoRequiredStatus(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.getApplication" {
  export default function getApplication(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.updateApplicationCheckboxes" {
  export default function updateApplicationCheckboxes(param: {applicationId: any, isNoOtherEducation: any, noDiploma: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.getEducationHistories" {
  export default function getEducationHistories(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.deleteApplicationDocument" {
  export default function deleteApplicationDocument(param: {appDocumentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.getExperienceHistoryWithDocuments" {
  export default function getExperienceHistoryWithDocuments(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.updateNewExperienceHistory" {
  export default function updateNewExperienceHistory(param: {experienceString: any, productGroup: any, contactId: any, applicationId: any, isChangeGroup: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.deleteExperienceHistory" {
  export default function deleteExperienceHistory(param: {experienceWrapper: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.getEarnedTitlePicklistPL" {
  export default function getEarnedTitlePicklistPL(): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.getEarnedTitlePicklistEN" {
  export default function getEarnedTitlePicklistEN(): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoryController.getPicklistByApiName" {
  export default function getPicklistByApiName(param: {objectApiName: any, fieldApiName: any}): Promise<any>;
}

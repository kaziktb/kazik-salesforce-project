declare module "@salesforce/apex/TB_EducationHistoriesController.getApplications" {
  export default function getApplications(param: {additionalApplicationFieldApis: any, filterApplicationFieldApis: any, applicationsQueryLimit: any, clearCache: any, dateQueryLimit: any, packetSize: any, prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoriesController.getContacts" {
  export default function getContacts(param: {additionalContactFieldApis: any, filterContactFieldApis: any, applicationsIndex: any, packetSize: any, prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoriesController.getStudents" {
  export default function getStudents(param: {contactsIndex: any, packetSize: any, prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoriesController.getEnrollments" {
  export default function getEnrollments(param: {additionalEnrollmentFieldApis: any, filterEnrollmentFieldApis: any, studentsIndex: any, packetSize: any, prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoriesController.getRefreshDate" {
  export default function getRefreshDate(param: {prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoriesController.retrieveRelatedData" {
  export default function retrieveRelatedData(param: {additionalContactFieldApis: any, additionalEnrollmentFieldApis: any, additionalApplicationFieldApis: any, contactsIndex: any, studentsIndex: any, enrollmentsIndex: any, applicationsIndex: any, recordsLimit: any, currentPage: any, sortedBy: any, sortDirection: any, contactNameFilter: any, applicationNameFilter: any, prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoriesController.getUserLanguage" {
  export default function getUserLanguage(): Promise<any>;
}
declare module "@salesforce/apex/TB_EducationHistoriesController.retrieveColumnData" {
  export default function retrieveColumnData(param: {sortable: any, editable: any, additionalContactFieldApis: any, additionalEnrollmentFieldApis: any, additionalApplicationFieldApis: any}): Promise<any>;
}

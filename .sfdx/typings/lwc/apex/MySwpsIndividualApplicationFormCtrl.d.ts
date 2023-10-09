declare module "@salesforce/apex/MySwpsIndividualApplicationFormCtrl.fetchFormInitialData" {
  export default function fetchFormInitialData(param: {pageContextLanguage: any}): Promise<any>;
}
declare module "@salesforce/apex/MySwpsIndividualApplicationFormCtrl.fetchStudentData" {
  export default function fetchStudentData(param: {studentContactId: any, programEnrollmentId: any, pageContextLanguage: any}): Promise<any>;
}
declare module "@salesforce/apex/MySwpsIndividualApplicationFormCtrl.submitApplication" {
  export default function submitApplication(param: {company: any, representative: any, supervisor: any, offer: any, consentsWrapper: any, application: any, selectedRequirementIds: any, studentContactId: any, selectedProgramEnrollmentId: any}): Promise<any>;
}

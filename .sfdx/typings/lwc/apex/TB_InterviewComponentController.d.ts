declare module "@salesforce/apex/TB_InterviewComponentController.isDatetimePickerAvailable" {
  export default function isDatetimePickerAvailable(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.getInfoFromItem" {
  export default function getInfoFromItem(param: {applicationId: any, language: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.findDateWithClosestTerm" {
  export default function findDateWithClosestTerm(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.getTermsByDay" {
  export default function getTermsByDay(param: {applicationId: any, pickedDate: any, formatHours: any, formatMinutes: any, formatSign: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.getExamScopesFromBundle" {
  export default function getExamScopesFromBundle(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.updateApplicationQualification" {
  export default function updateApplicationQualification(param: {applicationId: any, dictionaryJSON: any, contactId: any, isBooking: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.updateTermAndApplication" {
  export default function updateTermAndApplication(param: {applicationId: any, termId: any, change: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.getPickedTermConfirmation" {
  export default function getPickedTermConfirmation(param: {applicationId: any, isPl: any, formatHours: any, formatMinutes: any, formatSign: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.getDST" {
  export default function getDST(): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.getEmptyDates" {
  export default function getEmptyDates(param: {applicationId: any, pickedDate: any, formatHours: any, formatMinutes: any, formatSign: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterviewComponentController.cancelBooking" {
  export default function cancelBooking(param: {applicationId: any, termId: any}): Promise<any>;
}

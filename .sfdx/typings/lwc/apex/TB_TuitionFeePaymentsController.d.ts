declare module "@salesforce/apex/TB_TuitionFeePaymentsController.getPayments" {
  export default function getPayments(param: {additionalPaymentFieldApis: any, filterPaymentFieldApis: any, paymentsQueryLimit: any, daysQueryLimit: any, clearCache: any, packetSize: any, prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_TuitionFeePaymentsController.getContacts" {
  export default function getContacts(param: {additionalContactFieldApis: any, filterContactFieldApis: any, paymentsIndex: any, packetSize: any, prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_TuitionFeePaymentsController.getApplications" {
  export default function getApplications(param: {additionalApplicationFieldApis: any, filterApplicationFieldApis: any, contactsIndex: any, packetSize: any, prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_TuitionFeePaymentsController.getRefreshDate" {
  export default function getRefreshDate(param: {prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_TuitionFeePaymentsController.retrieveRelatedData" {
  export default function retrieveRelatedData(param: {additionalContactFieldApis: any, additionalPaymentFieldApis: any, additionalApplicationFieldApis: any, acceptedDeviation: any, contactsIndex: any, paymentsIndex: any, applicationsIndex: any, recordsLimit: any, currentPage: any, contactNameFilter: any, applicationNameFilter: any, prefix: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_TuitionFeePaymentsController.getUserLanguage" {
  export default function getUserLanguage(): Promise<any>;
}
declare module "@salesforce/apex/TB_TuitionFeePaymentsController.retrieveColumnData" {
  export default function retrieveColumnData(param: {sortable: any, editable: any, additionalContactFieldApis: any, additionalPaymentFieldApis: any, additionalApplicationFieldApis: any}): Promise<any>;
}

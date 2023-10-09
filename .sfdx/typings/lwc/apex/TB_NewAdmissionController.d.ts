declare module "@salesforce/apex/TB_NewAdmissionController.getAllOfferedProducts" {
  export default function getAllOfferedProducts(param: {isTestContact: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_NewAdmissionController.getHiddenOfferedProductWrapper" {
  export default function getHiddenOfferedProductWrapper(param: {offeredProductId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_NewAdmissionController.createNewApplication" {
  export default function createNewApplication(param: {offeredProduct: any, currentContact: any, isPdOptIn: any, fromHidden: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_NewAdmissionController.createConsentsForNewApplication" {
  export default function createConsentsForNewApplication(param: {applicationId: any, admissionConsents: any, communityUrl: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_NewAdmissionController.canApplicantApply" {
  export default function canApplicantApply(param: {contactId: any}): Promise<any>;
}

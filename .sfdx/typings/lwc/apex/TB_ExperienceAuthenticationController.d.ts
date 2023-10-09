declare module "@salesforce/apex/TB_ExperienceAuthenticationController.doLogin" {
  export default function doLogin(param: {username: any, password: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ExperienceAuthenticationController.doesEmailExist" {
  export default function doesEmailExist(param: {username: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ExperienceAuthenticationController.registerUser" {
  export default function registerUser(param: {firstName: any, lastName: any, email: any, password: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ExperienceAuthenticationController.verifyUser" {
  export default function verifyUser(param: {verificationCode: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ExperienceAuthenticationController.sendChangePasswordEmail" {
  export default function sendChangePasswordEmail(param: {email: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ExperienceAuthenticationController.resetPassword" {
  export default function resetPassword(param: {verificationCode: any, password: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ExperienceAuthenticationController.createConsentsForNewUser" {
  export default function createConsentsForNewUser(param: {contactId: any, admissionConsents: any, communityUrl: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ExperienceAuthenticationController.getAdmissionsPortal" {
  export default function getAdmissionsPortal(): Promise<any>;
}

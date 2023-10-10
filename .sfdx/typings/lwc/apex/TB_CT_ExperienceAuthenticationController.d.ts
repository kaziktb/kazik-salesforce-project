declare module "@salesforce/apex/TB_CT_ExperienceAuthenticationController.getContractTeacherPortal" {
  export default function getContractTeacherPortal(): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_ExperienceAuthenticationController.sendChangePasswordEmail" {
  export default function sendChangePasswordEmail(param: {email: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_ExperienceAuthenticationController.resetPassword" {
  export default function resetPassword(param: {verificationCode: any, password: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_ExperienceAuthenticationController.doLogin" {
  export default function doLogin(param: {username: any, password: any}): Promise<any>;
}

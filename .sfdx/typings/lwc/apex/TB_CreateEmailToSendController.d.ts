declare module "@salesforce/apex/TB_CreateEmailToSendController.createEmailTemplate" {
  export default function createEmailTemplate(param: {subject: any, htmlValue: any, enhancedLetterheadId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CreateEmailToSendController.sendMassEmailForApplication" {
  export default function sendMassEmailForApplication(param: {recordObjects: any, objectType: any, emailTemplateId: any, contentVersionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CreateEmailToSendController.getListOfFiles" {
  export default function getListOfFiles(param: {files: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CreateEmailToSendController.getEmailTemplate" {
  export default function getEmailTemplate(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CreateEmailToSendController.getEnhancedLetterhead" {
  export default function getEnhancedLetterhead(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CreateEmailToSendController.getObjectRecords" {
  export default function getObjectRecords(param: {objectType: any, senderEmailType: any, queryFilters: any, emailApiNames: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CreateEmailToSendController.getAllOrgWideAddresses" {
  export default function getAllOrgWideAddresses(): Promise<any>;
}
declare module "@salesforce/apex/TB_CreateEmailToSendController.deleteFile" {
  export default function deleteFile(param: {contentDocumentId: any}): Promise<any>;
}

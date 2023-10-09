declare module "@salesforce/apex/TB_DocumentsDataController.getDocumentsToDownload" {
  export default function getDocumentsToDownload(param: {applicationId: any, stepJson: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocumentsDataController.getDocumentTemplateBundleItems" {
  export default function getDocumentTemplateBundleItems(): Promise<any>;
}
declare module "@salesforce/apex/TB_DocumentsDataController.getDeliveredDocuments" {
  export default function getDeliveredDocuments(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocumentsDataController.getApplicationDocumentType" {
  export default function getApplicationDocumentType(param: {documentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocumentsDataController.getNonGeneratedDocument" {
  export default function getNonGeneratedDocument(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocumentsDataController.getApplicantPhoto" {
  export default function getApplicantPhoto(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocumentsDataController.getNewestApplicantPhoto" {
  export default function getNewestApplicantPhoto(param: {contactId: any}): Promise<any>;
}

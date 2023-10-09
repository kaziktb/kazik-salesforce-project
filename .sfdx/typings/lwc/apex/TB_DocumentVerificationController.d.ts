declare module "@salesforce/apex/TB_DocumentVerificationController.fetchApplicationDocuments" {
  export default function fetchApplicationDocuments(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocumentVerificationController.fetchDocumentComments" {
  export default function fetchDocumentComments(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocumentVerificationController.updateDocumentStatus" {
  export default function updateDocumentStatus(param: {documentIds: any, status: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocumentVerificationController.updateDocuments" {
  export default function updateDocuments(param: {documents: any}): Promise<any>;
}

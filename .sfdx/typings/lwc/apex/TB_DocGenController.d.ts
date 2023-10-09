declare module "@salesforce/apex/TB_DocGenController.generateDocument" {
  export default function generateDocument(param: {jsonString: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocGenController.generateMultiDocuments" {
  export default function generateMultiDocuments(param: {applicationIds: any, externalTemplateId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocGenController.getApplicationDocument" {
  export default function getApplicationDocument(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_DocGenController.getDocumentTemplates" {
  export default function getDocumentTemplates(param: {documentType: any}): Promise<any>;
}

declare module "@salesforce/apex/TB_PDMultiDocumentController.getPDApplicationDocuments" {
  export default function getPDApplicationDocuments(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PDMultiDocumentController.getNewPDApplicationDocument" {
  export default function getNewPDApplicationDocument(param: {applicationDocumentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PDMultiDocumentController.deleteApplicationDocument" {
  export default function deleteApplicationDocument(param: {appDocumentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PDMultiDocumentController.getDocumentsCategory" {
  export default function getDocumentsCategory(): Promise<any>;
}
declare module "@salesforce/apex/TB_PDMultiDocumentController.createNewApplicationDocumentSlot" {
  export default function createNewApplicationDocumentSlot(param: {applicationId: any, applicantId: any, documentCategory: any, documentDescription: any, stepId: any, stageId: any}): Promise<any>;
}

declare module "@salesforce/apex/TB_PhotoComponentController.getApplicationDocument" {
  export default function getApplicationDocument(param: {application: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PhotoComponentController.deleteLastApplicationDocument" {
  export default function deleteLastApplicationDocument(param: {application: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PhotoComponentController.createContentDocument" {
  export default function createContentDocument(param: {file: any, fileName: any, application: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PhotoComponentController.createApplicationDocument" {
  export default function createApplicationDocument(param: {application: any, contentDocuments: any}): Promise<any>;
}

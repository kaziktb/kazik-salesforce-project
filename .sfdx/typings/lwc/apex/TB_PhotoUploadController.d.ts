declare module "@salesforce/apex/TB_PhotoUploadController.removeStepHistory" {
  export default function removeStepHistory(param: {parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PhotoUploadController.clearCurrentFile" {
  export default function clearCurrentFile(param: {parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PhotoUploadController.saveTheChunkFile" {
  export default function saveTheChunkFile(param: {parentId: any, fileName: any, base64Data: any, fileId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PhotoUploadController.appendToFile" {
  export default function appendToFile(param: {contentDocumentId: any, base64Data: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PhotoUploadController.downloadFile" {
  export default function downloadFile(param: {parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PhotoUploadController.getPhotoStatus" {
  export default function getPhotoStatus(param: {parentId: any}): Promise<any>;
}

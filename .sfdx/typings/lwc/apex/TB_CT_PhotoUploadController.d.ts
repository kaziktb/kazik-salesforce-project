declare module "@salesforce/apex/TB_CT_PhotoUploadController.clearCurrentFile" {
  export default function clearCurrentFile(param: {parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_PhotoUploadController.saveTheChunkFile" {
  export default function saveTheChunkFile(param: {parentId: any, fileName: any, base64Data: any, fileId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_PhotoUploadController.downloadFile" {
  export default function downloadFile(param: {parentId: any}): Promise<any>;
}

declare module "@salesforce/apex/TB_GenericRelatedListController.retrieveRelatedData" {
  export default function retrieveRelatedData(param: {fieldApis: any, objectName: any, recordId: any, standardFilter: any, sortOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_GenericRelatedListController.deleteData" {
  export default function deleteData(param: {recordIds: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_GenericRelatedListController.retrieveColumnData" {
  export default function retrieveColumnData(param: {fieldApis: any, objectName: any, sortable: any, editable: any}): Promise<any>;
}

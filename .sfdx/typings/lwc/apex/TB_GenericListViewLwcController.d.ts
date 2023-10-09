declare module "@salesforce/apex/TB_GenericListViewLwcController.getObjects" {
  export default function getObjects(param: {objectName: any, fields: any, filter: any, orderBy: any, limitRecords: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_GenericListViewLwcController.getFields" {
  export default function getFields(param: {objectName: any, fields: any, linkingField: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_GenericListViewLwcController.getFieldsApiNames" {
  export default function getFieldsApiNames(param: {fields: any, link: any}): Promise<any>;
}

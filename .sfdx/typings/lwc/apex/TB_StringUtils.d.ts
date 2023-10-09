declare module "@salesforce/apex/TB_StringUtils.getPicklistByApiName" {
  export default function getPicklistByApiName(param: {objectApiName: any, fieldApiName: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_StringUtils.getDependantPicklistByApiName" {
  export default function getDependantPicklistByApiName(param: {objectApiName: any, fieldApiName: any, controllingValue: any}): Promise<any>;
}

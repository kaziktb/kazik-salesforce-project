declare module "@salesforce/apex/TB_AuraUtils.createLog" {
  export default function createLog(param: {message: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AuraUtils.createLogWithParams" {
  export default function createLogWithParams(param: {message: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AuraUtils.createLogFromLWC" {
  export default function createLogFromLWC(param: {message: any, componentName: any, stackTrace: any, lineNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AuraUtils.getCurrentContact" {
  export default function getCurrentContact(): Promise<any>;
}
declare module "@salesforce/apex/TB_AuraUtils.getCurrentApplicant" {
  export default function getCurrentApplicant(param: {applicationId: any}): Promise<any>;
}

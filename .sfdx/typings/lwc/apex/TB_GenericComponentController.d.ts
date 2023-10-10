declare module "@salesforce/apex/TB_GenericComponentController.getStepsData" {
  export default function getStepsData(param: {stepId: any, applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_GenericComponentController.isAnAdult" {
  export default function isAnAdult(param: {birthDate: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_GenericComponentController.isTooYoung" {
  export default function isTooYoung(param: {birthDate: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_GenericComponentController.updateDataDefinitions" {
  export default function updateDataDefinitions(param: {dataDefinitionsJSON: any, applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_GenericComponentController.blockDuplicates" {
  export default function blockDuplicates(param: {type: any, data: any, app: any}): Promise<any>;
}

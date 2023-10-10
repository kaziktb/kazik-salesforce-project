declare module "@salesforce/apex/TB_CT_ApplicationTrackingController.getAppTrackingByFilters" {
  export default function getAppTrackingByFilters(param: {searchTerm: any, sortType: any, departmentId: any, coordinatorId: any, citizenship: any, status: any, isMine: any, offsetFilter: any, limitFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_ApplicationTrackingController.getAppTrackingById" {
  export default function getAppTrackingById(param: {processId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_ApplicationTrackingController.getAllDepartments" {
  export default function getAllDepartments(): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_ApplicationTrackingController.cancelProcess" {
  export default function cancelProcess(param: {processId: any}): Promise<any>;
}

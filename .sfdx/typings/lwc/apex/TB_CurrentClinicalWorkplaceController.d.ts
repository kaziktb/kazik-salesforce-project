declare module "@salesforce/apex/TB_CurrentClinicalWorkplaceController.getWorkplaceTypes" {
  export default function getWorkplaceTypes(): Promise<any>;
}
declare module "@salesforce/apex/TB_CurrentClinicalWorkplaceController.getWorkplaces" {
  export default function getWorkplaces(param: {applicantId: any, applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CurrentClinicalWorkplaceController.addWorkplace" {
  export default function addWorkplace(param: {workplaceType: any, name: any, workplaceWeeklyTime: any, applicantId: any, applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CurrentClinicalWorkplaceController.updateWorkplace" {
  export default function updateWorkplace(param: {workplaceId: any, workplaceType: any, name: any, workplaceWeeklyTime: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CurrentClinicalWorkplaceController.deleteWorkplace" {
  export default function deleteWorkplace(param: {workplaceId: any}): Promise<any>;
}

declare module "@salesforce/apex/TB_vu_StudentOrganizationWizard.getUniversityDepartments" {
  export default function getUniversityDepartments(): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_StudentOrganizationWizard.saveOrganization" {
  export default function saveOrganization(param: {organizationData: any, memberIds: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_StudentOrganizationWizard.getDraft" {
  export default function getDraft(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_StudentOrganizationWizard.getContactDataBasedOnCurrentUserId" {
  export default function getContactDataBasedOnCurrentUserId(): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_StudentOrganizationWizard.getContactDataBasedOnEmail" {
  export default function getContactDataBasedOnEmail(param: {email: any, supervisor: any}): Promise<any>;
}

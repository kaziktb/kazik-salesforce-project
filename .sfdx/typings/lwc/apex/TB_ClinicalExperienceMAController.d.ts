declare module "@salesforce/apex/TB_ClinicalExperienceMAController.getWorkplaceTypes" {
  export default function getWorkplaceTypes(): Promise<any>;
}
declare module "@salesforce/apex/TB_ClinicalExperienceMAController.getWorkTypes" {
  export default function getWorkTypes(): Promise<any>;
}
declare module "@salesforce/apex/TB_ClinicalExperienceMAController.getExperiences" {
  export default function getExperiences(param: {applicantId: any, applicationId: any, recordTypeName: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ClinicalExperienceMAController.addExperience" {
  export default function addExperience(param: {workplaceType: any, workType: any, name: any, startDate: any, endDate: any, hours: any, applicantId: any, applicationId: any, recordTypeName: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ClinicalExperienceMAController.updateExperience" {
  export default function updateExperience(param: {experienceId: any, workplaceType: any, workType: any, name: any, startDate: any, endDate: any, hours: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ClinicalExperienceMAController.deleteExperience" {
  export default function deleteExperience(param: {experienceId: any}): Promise<any>;
}

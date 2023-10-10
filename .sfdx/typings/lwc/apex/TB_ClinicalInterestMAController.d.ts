declare module "@salesforce/apex/TB_ClinicalInterestMAController.getInterestTypes" {
  export default function getInterestTypes(): Promise<any>;
}
declare module "@salesforce/apex/TB_ClinicalInterestMAController.getInterests" {
  export default function getInterests(param: {applicantId: any, applicationId: any, recordTypeName: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ClinicalInterestMAController.addInterest" {
  export default function addInterest(param: {interestType: any, name: any, startDate: any, endDate: any, hours: any, applicantId: any, applicationId: any, recordTypeName: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ClinicalInterestMAController.updateInterest" {
  export default function updateInterest(param: {interestId: any, interestType: any, name: any, startDate: any, endDate: any, hours: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ClinicalInterestMAController.deleteInterest" {
  export default function deleteInterest(param: {interestId: any}): Promise<any>;
}

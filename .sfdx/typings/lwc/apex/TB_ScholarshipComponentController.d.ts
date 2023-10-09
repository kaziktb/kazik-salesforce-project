declare module "@salesforce/apex/TB_ScholarshipComponentController.matchScholarships" {
  export default function matchScholarships(param: {apId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ScholarshipComponentController.loadSelectedPreviouslyScholarship" {
  export default function loadSelectedPreviouslyScholarship(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ScholarshipComponentController.updateSelectedScholarship" {
  export default function updateSelectedScholarship(param: {scholarshipId: any, applicationId: any, taxOfficeName: any, taxOfficeAddress: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ScholarshipComponentController.createApplicationDocumentsForUpload" {
  export default function createApplicationDocumentsForUpload(param: {applicationId: any, scholarshipId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_ScholarshipComponentController.scholarshipApplicationDocuments" {
  export default function scholarshipApplicationDocuments(param: {applicationId: any}): Promise<any>;
}

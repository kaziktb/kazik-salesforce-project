declare module "@salesforce/apex/TB_SpecializationChoice.getApplicationData" {
  export default function getApplicationData(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_SpecializationChoice.getConsentOptions" {
  export default function getConsentOptions(): Promise<any>;
}
declare module "@salesforce/apex/TB_SpecializationChoice.getRelatedProducts" {
  export default function getRelatedProducts(param: {applicationId: any, higherYear: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_SpecializationChoice.setSpecialization" {
  export default function setSpecialization(param: {applicationId: any, consent: any, specialization: any}): Promise<any>;
}

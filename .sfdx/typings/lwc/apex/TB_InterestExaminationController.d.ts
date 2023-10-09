declare module "@salesforce/apex/TB_InterestExaminationController.getApplicationData" {
  export default function getApplicationData(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterestExaminationController.getRelatedProducts" {
  export default function getRelatedProducts(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterestExaminationController.changeApplication" {
  export default function changeApplication(param: {currentApplicationId: any, productId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_InterestExaminationController.confirmCurrentApplication" {
  export default function confirmCurrentApplication(param: {applicationId: any}): Promise<any>;
}

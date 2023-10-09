declare module "@salesforce/apex/TB_PaymentComponentController.getApplication" {
  export default function getApplication(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PaymentComponentController.createPayment" {
  export default function createPayment(param: {application: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PaymentComponentController.getNewestOpenPayment" {
  export default function getNewestOpenPayment(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PaymentComponentController.getNewestCompletedPayment" {
  export default function getNewestCompletedPayment(param: {applicationId: any}): Promise<any>;
}

declare module "@salesforce/apex/TB_vu_CertificatesController.createCertificate" {
  export default function createCertificate(param: {certificateParameters: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_CertificatesController.generatePdf" {
  export default function generatePdf(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_CertificatesController.getStudyNames" {
  export default function getStudyNames(param: {language: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_CertificatesController.getCertificateFormsMetadata" {
  export default function getCertificateFormsMetadata(): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_CertificatesController.fetchCaseWrappers" {
  export default function fetchCaseWrappers(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_CertificatesController.fetchCases" {
  export default function fetchCases(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_CertificatesController.fetchCaseComments" {
  export default function fetchCaseComments(param: {caseId: any}): Promise<any>;
}

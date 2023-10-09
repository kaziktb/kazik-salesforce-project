declare module "@salesforce/apex/TB_vu_StudentOrganizationDetails.getOrganizationDetails" {
  export default function getOrganizationDetails(param: {recordId: any, language: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_StudentOrganizationDetails.getMembers" {
  export default function getMembers(param: {recordId: any, isChairmanLogged: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_StudentOrganizationDetails.createAffiliation" {
  export default function createAffiliation(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_StudentOrganizationDetails.modifyAffiliation" {
  export default function modifyAffiliation(param: {accountId: any, affiliationId: any, processType: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_vu_StudentOrganizationDetails.setUserDecision" {
  export default function setUserDecision(param: {accountId: any, contactId: any, userId: any, decision: any}): Promise<any>;
}

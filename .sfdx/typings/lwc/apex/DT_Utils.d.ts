declare module "@salesforce/apex/DT_Utils.getCurrentUserLanguage" {
  export default function getCurrentUserLanguage(): Promise<any>;
}
declare module "@salesforce/apex/DT_Utils.changeCurrentUserLanguage" {
  export default function changeCurrentUserLanguage(param: {language: any}): Promise<any>;
}
declare module "@salesforce/apex/DT_Utils.checkIfUserHasSpecifiedProfile" {
  export default function checkIfUserHasSpecifiedProfile(param: {profileName: any}): Promise<any>;
}

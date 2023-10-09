declare module "@salesforce/apex/DT_CTTagsCtrl.getRecordTags" {
  export default function getRecordTags(param: {objName: any, recordId: any, booleanFlag: any}): Promise<any>;
}
declare module "@salesforce/apex/DT_CTTagsCtrl.save" {
  export default function save(param: {objName: any, recordId: any, idsToRemove: any, idsToCreate: any, booleanFlag: any}): Promise<any>;
}
declare module "@salesforce/apex/DT_CTTagsCtrl.getAvailableCategories" {
  export default function getAvailableCategories(): Promise<any>;
}
declare module "@salesforce/apex/DT_CTTagsCtrl.getAvailableTypes" {
  export default function getAvailableTypes(): Promise<any>;
}
declare module "@salesforce/apex/DT_CTTagsCtrl.searchTags" {
  export default function searchTags(param: {category: any, type: any, searchTerm: any, currentTagSet: any, guestLanguage: any}): Promise<any>;
}

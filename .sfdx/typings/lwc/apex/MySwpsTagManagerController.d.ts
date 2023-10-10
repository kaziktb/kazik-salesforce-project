declare module "@salesforce/apex/MySwpsTagManagerController.searchTags" {
  export default function searchTags(param: {searchTerm: any, selectedTagIds: any, category: any, language: any, excludedValues: any}): Promise<any>;
}
declare module "@salesforce/apex/MySwpsTagManagerController.fetchRecordTags" {
  export default function fetchRecordTags(param: {recordId: any, category: any, language: any}): Promise<any>;
}

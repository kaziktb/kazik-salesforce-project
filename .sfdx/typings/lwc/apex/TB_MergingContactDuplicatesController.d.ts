declare module "@salesforce/apex/TB_MergingContactDuplicatesController.mergeContacts" {
  export default function mergeContacts(param: {mergeContactWrapperJson: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_MergingContactDuplicatesController.getContactWrapper" {
  export default function getContactWrapper(param: {remainingContactId: any, duplicateContactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_MergingContactDuplicatesController.getWrappedContactDuplicateLogs" {
  export default function getWrappedContactDuplicateLogs(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_MergingContactDuplicatesController.getWrappedDuplicateLog" {
  export default function getWrappedDuplicateLog(param: {recordId: any}): Promise<any>;
}

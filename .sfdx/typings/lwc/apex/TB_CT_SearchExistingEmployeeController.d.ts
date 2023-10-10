declare module "@salesforce/apex/TB_CT_SearchExistingEmployeeController.searchExistingEmployee" {
  export default function searchExistingEmployee(param: {phone: any, email: any, pesel: any, firstName: any, lastName: any, citizenship: any, title: any, uniWorkDepartment: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_SearchExistingEmployeeController.checkDuplicates" {
  export default function checkDuplicates(param: {email: any, pesel: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_SearchExistingEmployeeController.searchContacts" {
  export default function searchContacts(param: {name: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_SearchExistingEmployeeController.initLookupResults" {
  export default function initLookupResults(): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_SearchExistingEmployeeController.fetchContacts" {
  export default function fetchContacts(): Promise<any>;
}
declare module "@salesforce/apex/TB_CT_SearchExistingEmployeeController.fetchUniversityDepartments" {
  export default function fetchUniversityDepartments(param: {isSearch: any}): Promise<any>;
}

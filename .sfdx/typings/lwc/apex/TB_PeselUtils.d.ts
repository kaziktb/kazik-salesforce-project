declare module "@salesforce/apex/TB_PeselUtils.validatePeselFromParts" {
  export default function validatePeselFromParts(param: {pesel: any, day: any, month: any, year: any, salutation: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_PeselUtils.validatePesel" {
  export default function validatePesel(param: {pesel: any, birthDate: any, salutation: any}): Promise<any>;
}

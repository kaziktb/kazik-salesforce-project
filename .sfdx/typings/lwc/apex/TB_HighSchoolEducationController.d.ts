declare module "@salesforce/apex/TB_HighSchoolEducationController.getAdmissionsDictionaryWrapperForHSExam" {
  export default function getAdmissionsDictionaryWrapperForHSExam(): Promise<any>;
}
declare module "@salesforce/apex/TB_HighSchoolEducationController.getHSExamMetric" {
  export default function getHSExamMetric(param: {applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_HighSchoolEducationController.getApplicationDocuments" {
  export default function getApplicationDocuments(param: {examMetricId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_HighSchoolEducationController.updateApplicationDocuments" {
  export default function updateApplicationDocuments(param: {createFiles: any, deleteFiles: any, hsExamMetric: any, applicationId: any, isForeign: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_HighSchoolEducationController.createHSExamMetric" {
  export default function createHSExamMetric(param: {examMetric: any, noHSExam: any, isForeign: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_HighSchoolEducationController.prepareHSExamFieldsMap" {
  export default function prepareHSExamFieldsMap(): Promise<any>;
}
declare module "@salesforce/apex/TB_HighSchoolEducationController.updateHSExamMetric" {
  export default function updateHSExamMetric(param: {examMetric: any, apiNamesToDeleteValues: any, noDiploma: any, applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_HighSchoolEducationController.handleExamScoreMetrics" {
  export default function handleExamScoreMetrics(param: {examType: any, applicationId: any, applicantId: any, examMetricId: any, deleteMetrics: any, createMetrics: any}): Promise<any>;
}

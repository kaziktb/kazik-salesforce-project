declare module "@salesforce/apex/TB_AdmissionsSurveyController.getSurveyDetails" {
  export default function getSurveyDetails(param: {surveyProcessId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsSurveyController.getQuestions" {
  export default function getQuestions(param: {surveyId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsSurveyController.getQuestionValues" {
  export default function getQuestionValues(param: {questionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsSurveyController.addAnswers" {
  export default function addAnswers(param: {answers: any, surveyId: any, applicationId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_AdmissionsSurveyController.getPreviousAnswers" {
  export default function getPreviousAnswers(param: {surveyId: any, applicationId: any}): Promise<any>;
}

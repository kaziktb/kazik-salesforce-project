declare module "@salesforce/apex/TB_pdo_AdmissionsSurveyController.getSurveyWrapper" {
  export default function getSurveyWrapper(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_pdo_AdmissionsSurveyController.getSurveyDetails" {
  export default function getSurveyDetails(param: {surveyAchievementType: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_pdo_AdmissionsSurveyController.getQuestions" {
  export default function getQuestions(param: {surveyId: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_pdo_AdmissionsSurveyController.getSuveyIdByAchievementType" {
  export default function getSuveyIdByAchievementType(param: {achievementType: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_pdo_AdmissionsSurveyController.getQuestionValues" {
  export default function getQuestionValues(param: {questionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_pdo_AdmissionsSurveyController.addAnswersForPopularisation" {
  export default function addAnswersForPopularisation(param: {serializedAnswers: any}): Promise<any>;
}
declare module "@salesforce/apex/TB_pdo_AdmissionsSurveyController.getPreviousAnswers" {
  export default function getPreviousAnswers(param: {surveyId: any, popularisation: any}): Promise<any>;
}

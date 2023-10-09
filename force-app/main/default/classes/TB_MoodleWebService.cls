public without sharing class TB_MoodleWebService {

    @InvocableMethod(label = 'Create and enroll user to Moodle')
    public static void rightMoodleMethodInv(List<TB_MoodleWebService.WrapperClass> elementList) {
        rightMoodleMethodInvFuture(JSON.serialize(elementList.get(0)));
    }

    @Future(Callout=true)
    public static void rightMoodleMethodInvFuture(String singleElement) {
        try {
            Object integrationResult = rightMoodleMethod((WrapperClass) JSON.deserialize(singleElement, WrapperClass.class), TB_MoodleConstants.MOODLE_DEF.TB_Moodle_Token__c);
            if (integrationResult instanceof TB_Application_Qualification__c) {
                update (TB_Application_Qualification__c) integrationResult;
            }
        }catch (Exception e){
            insert TB_LogUtils.registerLog(e);
        }
    }

    public static Object rightMoodleMethod(TB_MoodleWebService.WrapperClass element , String inputToken) {
        Object result;
        try {
            String token = inputToken != null
                    ? inputToken : TB_MoodleConstants.MOODLE_DEF.TB_Moodle_Token__c != null
                            ? TB_MoodleConstants.MOODLE_DEF.TB_Moodle_Token__c : TB_MoodleHandler.retrieveToken();
        Map<String, String> userDetails;
        if (element.methodToken == TB_MoodleConstants.FUNC_CREATE_USER) {
                result = TB_MoodleHandler.createUser(
                        token,
                        element.appQualId,
                        element.applicationName,
                        element.firstname,
                        element.lastname,
                        element.email,
                        false
                );
        } else if (element.methodToken == TB_MoodleConstants.API_FUNCTION_LOG_USER) {
                result = TB_MoodleHandler.getOneClickLink(
                        token,
                        element.courseUrl,
                        element.username,
                        element.email
                );
        }
        else if (element.methodToken == TB_MoodleConstants.FUNC_CREATE_AND_ENROL_USER) {
                result = userDetails = TB_MoodleHandler.createUser(
                        token,
                        element.appQualId,
                        element.applicationName,
                        element.firstname,
                        element.lastname,
                        element.email,
                        true
                );
                if (userDetails != null && !userDetails.isEmpty()) {
                    result = TB_MoodleHandler.enrolUserToCourse(
                            token,
                            element.appQualId,
                            element.courseId,
                            null,
                            userDetails,
                            true);
                }
        } else if (element.methodToken == TB_MoodleConstants.FUNC_ENROL_USER) {
                result = TB_MoodleHandler.enrolUserToCourse(
                        token,
                        element.appQualId,
                        element.courseId,
                        element.moodleUserId,
                        null,
                        false);
        } else if (element.methodToken == TB_MoodleConstants.FUNC_COURSE_RESULT) {
                result = TB_MoodleHandler.getResultsForUserForCourse(
                        token,
                        element.moodleUserId,
                        element.courseId,
                        element.appQualId);

        } else if(element.methodToken == TB_MoodleConstants.API_FUNCTION_UN_ENROL_USER){
            result = TB_MoodleHandler.unEnrolUserFromExam(
                    token,
                    element.courseId,
                    element.moodleUserId
                    );
            if (String.valueOf(result) == TB_MoodleConstants.RESPONSE_NULL_RESULT) {
                result = TB_MoodleHandler.enrolUserToCourse(
                        token,
                        element.appQualId,
                        element.courseId,
                        element.moodleUserId,
                        null,
                        false);
            }
        } else {
            insert TB_LogUtils.registerLog('Invalid/missing function token', TB_MoodleWebService.class);
        }
        } catch (Exception e) {
            System.debug('element: ' + element);
            //insert TB_LogUtils.registerLog(e, element.appQualId, TB_MoodleWebService.class);

        }
        return result;
    }

    public class WrapperClass {
        @InvocableVariable public String methodToken;
        @InvocableVariable public String appQualId;
        @InvocableVariable public String applicationName;
        @InvocableVariable public String firstname;
        @InvocableVariable public String lastname;
        @InvocableVariable public String email;
        @InvocableVariable public String courseId;
        @InvocableVariable public String moodleUserId;
        @InvocableVariable public String courseUrl;
        @InvocableVariable  public String username;
    }
}
public without sharing class TB_MoodleHandler {

    public static String retrieveToken() {
        String returnValue;
        try {
            HttpResponse res;
            Map<String, String> body = new Map<String, String>();
            body.put(TB_MoodleConstants.USER_USERNAME, TB_MoodleConstants.MOODLE_DEF.TB_Moodle_usr__c);
            body.put(TB_MoodleConstants.AUT_TOKEN_PASSWORD, TB_MoodleConstants.MOODLE_DEF.TB_Moodle_psw__c);
            body.put(TB_MoodleConstants.AUT_TOKEN_SERVICE, TB_MoodleConstants.API_FUNCTION_LOGIN);
            HttpRequest req = new HttpRequest();
            req.setMethod(TB_MoodleConstants.METHOD_POST);
            req.setEndpoint(TB_MoodleConstants.MOODLE_DEF.TB_Moodle_Login_URL__c);
            req.setHeader(TB_MoodleConstants.API_HEADER_KEY, TB_MoodleConstants.API_HEADER_WWW_URL);
            req.setBody(TB_WebserviceUtils.urlEncode(body));
            Http http = new Http();
            if (!Test.isRunningTest()) {
               res = http.send(req);
            }
            returnValue = Test.isRunningTest()? TB_MoodleMock.ONE_CLICK_KEY_AUT :((TokenWrapper) JSON.deserialize(res.getBody(), TokenWrapper.class)).token;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_MoodleHandler.class);
        }
        return returnValue;
    }

    public static Map<String, String> createUser(String token, String appQualId, String applicationName, String firstname, String lastname, String email, Boolean multiStep) {
        List<Map<String, String>> responseBody;
        HttpResponse res;
        String moodleUserPassword = applicationName.toLowerCase().replace('-', '') + String.valueOf(applicationName.hashCode());
        String moodleUser = applicationName.toLowerCase().replace('-', '') + String.valueOf((Math.random() * 100000).intValue());
        Map<String, String> body = new Map<String, String>();
        body.put(TB_MoodleConstants.API_PARAM_TOKEN, token);
        body.put(TB_MoodleConstants.API_PARAM_FUNCTION, TB_MoodleConstants.API_FUNCTION_CREATE_USER);
        body.put(TB_MoodleConstants.API_PARAM_USER_USERNAME, moodleUser);
        body.put(TB_MoodleConstants.API_PARAM_USER_PASSWORD, moodleUserPassword);
        body.put(TB_MoodleConstants.API_PARAM_USER_FIRSTNAME, firstname);
        body.put(TB_MoodleConstants.API_PARAM_USER_LASTNAME, lastname);
        body.put(TB_MoodleConstants.API_PARAM_USER_EMAIL, email);
        HttpRequest req = new HttpRequest();
        req.setMethod(TB_MoodleConstants.METHOD_POST);
        req.setHeader(TB_MoodleConstants.API_HEADER_KEY, TB_MoodleConstants.API_HEADER_WWW_URL);
        Http http = new Http();
        req.setEndpoint(TB_MoodleConstants.MOODLE_DEF.TB_Moodle_WS_URL__c);
        req.setBody(TB_WebserviceUtils.urlEncode(body));
        if(!Test.isRunningTest()){
            res =  http.send(req);
        }
       String result = Test.isRunningTest()? TB_MoodleMock.CREATE_USER_RESPONSE : res.getBody();
        responseBody = (List<Map<String, String>>) JSON.deserialize(result, List<Map<String, String>>.class);
        if (!multiStep) {
            update new TB_Application_Qualification__c(
                    Id = appQualId,
                    TB_Moodle_Password__c = moodleUserPassword,
                    TB_Moodle_Username__c = responseBody[0].get(TB_MoodleConstants.USER_USERNAME),
                    TB_Moodle_Id__c = responseBody[0].get(TB_MoodleConstants.USER_ID)
            );
            return null;
        }
        responseBody[0].put(TB_MoodleConstants.USER_PASSWORD, moodleUserPassword);
        return responseBody != null ? responseBody[0] : null;
    }

    public static TB_Application_Qualification__c enrolUserToCourse(String token, String appQualId, String courseId, String moodleUserId, Map<String, String> userDetails, Boolean multistep) {
        HttpResponse res;
        TB_Application_Qualification__c result;
        Map<String, String> body = new Map<String, String>();
        body.put(TB_MoodleConstants.API_PARAM_TOKEN, token);
        body.put(TB_MoodleConstants.API_PARAM_FUNCTION, TB_MoodleConstants.API_FUNCTION_MANUAL_ENROL_USER_TO_COURSE);
        body.put(TB_MoodleConstants.API_PARAM_ENROL_ROLEID, TB_MoodleConstants.MOODLE_DEF.TB_Moodle_Student_Role_Id__c);
        body.put(TB_MoodleConstants.API_PARAM_ENROL_USERID, userDetails != null && !userDetails.isEmpty() ?
                userDetails.get(TB_MoodleConstants.USER_ID) :
                moodleUserId);
        body.put(TB_MoodleConstants.API_PARAM_ENROL_COURSEID, courseId);
        HttpRequest req = new HttpRequest();
        req.setMethod(TB_MoodleConstants.METHOD_POST);
        Http http = new Http();
        req.setEndpoint(TB_MoodleConstants.MOODLE_DEF.TB_Moodle_WS_URL__c);
        req.setBody(TB_WebserviceUtils.urlEncode(body));
        if (!Test.isRunningTest()) {
            res = http.send(req);
        }
        if (multiStep) {
            result = new TB_Application_Qualification__c(
                    Id = appQualId,
                    TB_Moodle_Username__c = userDetails.get(TB_MoodleConstants.USER_USERNAME),
                    TB_Moodle_Id__c = userDetails.get(TB_MoodleConstants.USER_ID),
                    TB_Moodle_Password__c = userDetails.get(TB_MoodleConstants.USER_PASSWORD),
                    TB_Moodle_Multi_Quiz_Test__c = getQuizIdsForCourse(token, appQualId, courseId)
            );
        }
        return result;
    }

    public static Map<String, String> getOneClickLink(String token, String courseUrl, String username, String email) {
        HttpRequest req = new HttpRequest();
        req.setMethod(TB_MoodleConstants.METHOD_POST);
        Http http = new Http();
        Map<String, String> body = new Map<String, String>();
        body.put(TB_MoodleConstants.API_PARAM_TOKEN, token);
        body.put(TB_MoodleConstants.API_PARAM_FUNCTION, TB_MoodleConstants.API_FUNCTION_LOG_USER);
        req.setEndpoint(TB_MoodleConstants.MOODLE_DEF.TB_Moodle_WS_URL__c);
        body.put(TB_MoodleConstants.API_PARAM_USER_LOGIN_USERNAME, username);
        body.put(TB_MoodleConstants.API_PARAM_USER_LOGIN_EMAIL, email);
        req.setBody(TB_WebserviceUtils.urlEncode(body));
        HttpResponse res = http.send(req);
        return new Map<String, String>{
                TB_MoodleConstants.API_PARAM_LOGIN_URL =>
                        ((Map<String, Object>) JSON.deserializeUntyped(res.getBody())).get(TB_MoodleConstants.API_PARAM_LOGIN_URL) + '/&' + TB_MoodleConstants.API_PARAM_WANT_URL + '=' + courseUrl
        };
    }

    public static TB_Application_Qualification__c getResultsForUserForCourse(String token, String moodleUserId, String courseId, String appQualId) {
        TB_Application_Qualification__c resultAppQua = new TB_Application_Qualification__c();
        TB_MoodleHandler.UserCourseResultsWrapper responseBody;
        Map<String, String> body = new Map<String, String>();
        body.put(TB_MoodleConstants.API_PARAM_TOKEN, token);
        body.put(TB_MoodleConstants.API_PARAM_FUNCTION, TB_MoodleConstants.API_FUNCTION_GET_USER_COURSE_RESULTS);
        body.put(TB_MoodleConstants.API_PARAM_USER_ID, moodleUserId);
        body.put(TB_MoodleConstants.API_PARAM_COURSE_ID, courseId);
        HttpRequest req = new HttpRequest();
        req.setMethod(TB_MoodleConstants.METHOD_POST);
        Http http = new Http();
        req.setEndpoint(TB_MoodleConstants.MOODLE_DEF.TB_Moodle_WS_URL__c);
        req.setBody(TB_WebserviceUtils.urlEncode(body));
        HttpResponse res = http.send(req);
        responseBody = (TB_MoodleHandler.UserCourseResultsWrapper) JSON.deserialize(res.getBody(), TB_MoodleHandler.UserCourseResultsWrapper.class);
        String examPoints = getTestResultsInPoints(responseBody);
        String examPert = getTestResultsInPercentage(responseBody);
        try {
            Double.valueOf(examPoints);
            resultAppQua.TB_Moodle_Test_Result_Points__c = examPoints;
            resultAppQua.TB_Moodle_Test_Result_Percent__c = examPert;
        } catch (Exception e) {
            System.debug(e);
        } finally {
            resultAppQua.Id = appQualId;
        }
        return resultAppQua;
    }

    public static Boolean getQuizIdsForCourse(String token, String appQualId, String courseId) {
        HttpResponse res;
        TB_MoodleHandler.QuizToCourseWrapper responseBody;
        Map<String, String> body = new Map<String, String>();
        body.put(TB_MoodleConstants.API_PARAM_TOKEN, token);
        body.put(TB_MoodleConstants.API_PARAM_FUNCTION, TB_MoodleConstants.API_FUNCTION_MANUAL_QUIZ_IDS_FOR_COURSE);
        body.put(TB_MoodleConstants.API_PARAM_COURSES_0_ID, courseId);
        HttpRequest req = new HttpRequest();
        req.setMethod(TB_MoodleConstants.METHOD_POST);
        Http http = new Http();
        req.setEndpoint(TB_MoodleConstants.MOODLE_DEF.TB_Moodle_WS_URL__c);
        req.setBody(TB_WebserviceUtils.urlEncode(body));
        if (!Test.isRunningTest()) {
            res = http.send(req);
        }
        String result = Test.isRunningTest() ? TB_MoodleMock.GET_RESULT_RESPONSE: res.getBody();
        responseBody = (TB_MoodleHandler.QuizToCourseWrapper) JSON.deserialize(result, TB_MoodleHandler.QuizToCourseWrapper.class);


        return responseBody.quizzes.size() != 1;

    }

    public static String unEnrolUserFromExam(String token, String courseId, String moodleUserId){
        HttpResponse res;
        Map<String, String> body = new Map<String, String>();
        body.put(TB_MoodleConstants.API_PARAM_TOKEN, token);
        body.put(TB_MoodleConstants.API_PARAM_FUNCTION, TB_MoodleConstants.API_FUNCTION_UN_ENROL_USER);
        body.put(TB_MoodleConstants.API_PARAM_ENROL_ROLEID, TB_MoodleConstants.MOODLE_DEF.TB_Moodle_Student_Role_Id__c);
        body.put(TB_MoodleConstants.API_PARAM_ENROL_USERID, moodleUserId);
        body.put(TB_MoodleConstants.API_PARAM_ENROL_COURSEID, courseId);
        HttpRequest req = new HttpRequest();
        req.setMethod(TB_MoodleConstants.METHOD_POST);
        Http http = new Http();
        req.setEndpoint(TB_MoodleConstants.MOODLE_DEF.TB_Moodle_WS_URL__c);
        req.setBody(TB_WebserviceUtils.urlEncode(body));
        if (!Test.isRunningTest()) {
            res = http.send(req);  
        }
        return Test.isRunningTest() ? TB_MoodleConstants.RESPONSE_NULL_RESULT : res.getBody();
    }

    private static String getTestResultsInPoints(UserCourseResultsWrapper element) {
        String gradeInPoints = '';
        for (GradeItemWrapper gww : element.usergrades[0].gradeitems) {
            if (gww.itemmodule == 'quiz' && gww.gradeformatted != '-') {
                gradeInPoints = gradeInPoints + gww.gradeformatted;
                break;
            }
        }
        return gradeInPoints;
    }

    private static String getTestResultsInPercentage(UserCourseResultsWrapper element) {
        String gradeInPercentage = '';
        for (GradeItemWrapper gww : element.usergrades[0].gradeitems) {
            if (gww.itemmodule == 'quiz' && gww.percentageformatted != '-') {
                gradeInPercentage = gradeInPercentage + gww.percentageformatted;
                break;
            }
        }
        return gradeInPercentage;
    }


    public class TokenWrapper {
        public String token;
        public String privateToken;

    }

    public class QuizToCourseWrapper {
        public TB_MoodleHandler.QuizWrapper[] quizzes;
        public TB_MoodleHandler.Warning[] warnings;

    }

    private class Warning {
        String item;
        Integer itemid;
        String warningcode;
        String message;
    }

    private class QuizWrapper {
        Integer id;
        Integer course;
        String coursemodule;
        String name;
        String intro;
        Integer introformat;
        List<String> introfiles;
        Integer timeopen;
        Integer timeclose;
        Integer timelimit;
        String overduehandling;
        Integer graceperiod;
        String preferredbehaviour;
        Integer canredoquestions;
        Integer attempts;
        Integer attemptonlast;
        Integer grademethod;
        Integer decimalpoints;
        Integer questiondecimalpoints;
        Integer reviewattempt;
        Integer reviewcorrectness;
        Integer reviewmarks;
        Integer reviewspecificfeedback;
        Integer reviewgeneralfeedback;
        Integer reviewrightanswer;
        Integer reviewoverallfeedback;
        Integer questionsperpage;
        String navmethod;
        Integer shuffleanswers;
        Decimal sumgrades;
        Decimal grade;
        Integer timecreated;
        Integer timemodified;
        String password;
        String subnet;
        String browsersecurity;
        Integer delay1;
        Integer delay2;
        Integer showuserpicture;
        Integer showblocks;
        Integer completionattemptsexhausted;
        Integer completionpass;
        Integer allowofflineattempts;
        Integer autosaveperiod;
        Integer hasfeedback;
        Integer hasquestions;
        Integer section;
        Integer visible;
        Integer groupmode;
        Integer groupingid;
    }

    public class UserCourseResultsWrapper {
        public TB_MoodleHandler.UserGradesWrapper[] usergrades;
        public List<String> warnings;
    }

    public class UserGradesWrapper {
        Integer courseid;
        Integer userid;
        String userfullname;
        Integer maxdepth;
        List<TB_MoodleHandler.GradeItemWrapper> gradeitems;
    }

    public class GradeItemWrapper {
        Integer id;
        String itemname;
        String itemtype;
        String itemmodule;
        Integer iteminstance;
        Integer itemnumber;
        Integer categoryid;
        Integer outcomeid;
        Integer scaleid;
        Boolean locked;
        Integer cmid;
        Decimal weightraw;
        String weightformatted;
        Decimal graderaw;
        Integer gradedatesubmitted;
        Integer gradedategraded;
        Boolean gradehiddenbydate;
        Boolean gradeneedsupdate;
        Boolean gradeishidden;
        Boolean gradeislocked;
        Boolean gradeisoverridden;
        String gradeformatted;
        String grademin;
        String grademax;
        String rangeformatted;
        String percentageformatted;
        String feedback;
        Integer feedbackformat;
    }
}
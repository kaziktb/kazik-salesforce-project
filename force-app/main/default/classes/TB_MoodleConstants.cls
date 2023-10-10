public without sharing class TB_MoodleConstants {
    public static final String METHOD_POST = 'POST';
    public static final String METHOD_GET = 'GET';

    public static final TB_Moodle__c MOODLE_DEF = TB_Moodle__c.getOrgDefaults();
    public static final String API_FUNCTION_LOGIN = 'salesforce_service_integration';

    public static final String API_HEADER_KEY = 'Content-Type';
    public static final String API_HEADER_WWW_URL = 'application/x-www-form-urlencoded';
    public static final String API_FUNCTION_CREATE_USER = 'core_user_create_users';
    public static final String API_FUNCTION_MANUAL_ENROL_USER_TO_COURSE = 'enrol_manual_enrol_users';
    public static final String API_FUNCTION_LOG_USER = 'auth_userkey_request_login_url';
    public static final String API_FUNCTION_MANUAL_QUIZ_IDS_FOR_COURSE = 'mod_quiz_get_quizzes_by_courses';
    public static final String API_FUNCTION_GET_USER_COURSE_RESULTS = 'gradereport_user_get_grade_items';
    public static final String API_FUNCTION_UN_ENROL_USER = 'enrol_manual_unenrol_users';
    public static final String API_PARAM_TOKEN = 'wstoken';
    public static final String API_PARAM_FUNCTION= 'wsfunction';
    public static final String API_PARAM_USER_ID = 'userid';
    public static final String API_PARAM_COURSE_ID = 'courseid';
    public static final String API_PARAM_LOGIN_URL = 'loginurl';
    public static final String API_PARAM_WANT_URL = 'wantsurl';

    public static final String API_PARAM_USER_USERNAME= 'users[0][username]';
    public static final String API_PARAM_USER_LOGIN_USERNAME= 'user[username]';
    public static final String API_PARAM_USER_LOGIN_EMAIL= 'user[email]';
    public static final String API_PARAM_USER_PASSWORD= 'users[0][password]';
    public static final String API_PARAM_USER_FIRSTNAME= 'users[0][firstname]';
    public static final String API_PARAM_USER_LASTNAME= 'users[0][lastname]';
    public static final String API_PARAM_USER_EMAIL= 'users[0][email]';
    public static final String API_PARAM_ENROL_ROLEID= 'enrolments[0][roleid]';
    public static final String API_PARAM_ENROL_USERID= 'enrolments[0][userid]';
    public static final String API_PARAM_ENROL_COURSEID= 'enrolments[0][courseid]';
    public static final String API_PARAM_COURSES_0_ID= 'courseids[0]';
    public static final String USER_ID = 'id';
    public static final String USER_USERNAME = 'username';
    public static final String AUT_TOKEN_PASSWORD = 'password';
    public static final String AUT_TOKEN_SERVICE = 'service';
    public static final String USER_PASSWORD = 'moodlePassword';

    public static final String FUNC_CREATE_USER = 'CREATE_USER';
    public static final String FUNC_RETRIEVE_TOKEN = 'RETRIEVE_TOKEN';
    public static final String FUNC_CREATE_AND_ENROL_USER = 'CREATE_USER_AND_ENROL';
    public static final String FUNC_ENROL_USER = 'ENROL_USER';
    public static final String FUNC_COURSE_RESULT = 'GET_USER_COURSE_RESULTS';

    public static final String RESPONSE_NULL_RESULT = 'null';
    public static final String RESPONSE_INVALID_RESULT = 'Invalid response';



}
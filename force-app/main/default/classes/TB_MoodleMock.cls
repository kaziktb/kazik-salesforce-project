public without sharing class TB_MoodleMock implements HttpCalloutMock{
    public final static String URL_COURSE = 'https://moodletest0.swps.edu.pl/course/view.php?id=4';
    public final static String TB_MOODLE_EMAIL = 'TB_MECT_test@Test.com';
    public final static String TB_MOODLE_USER_ID = '3497';
    public final static String TB_MOODLE_COURSE_ID = '4';
    public final static String TB_MOODLE_RESULT_POINTS = '42';
    public final static String TB_MOODLE_RESULT_PERC = '40%';
    public static final String ONE_CLICK_KEY_AUT = '4a3ab253561c91579c37405c88661c6e';
    public static final String CREATE_USER_RESPONSE = '[{"id":4415,"username":"tbtestsebaapppli2034576258"}]';
    public static final String GET_RESULT_RESPONSE = '{"quizzes":[{"id":1,"course":2,"coursemodule":1,"name":"Test Poziomuj\\u0105cy z j\\u0119zyka angielskiego","intro":"<p>Masz 110 minut na wykonanie testu. Do testu mo\\u017cna przyst\\u0105pi\\u0107 tylko raz, wi\\u0119c rozpocznij rozwi\\u0105zywanie testu dopiero, gdy dysponujesz wystarczaj\\u0105c\\u0105 ilo\\u015bci\\u0105 czasu.<\\/p>\\r\\n<p>Aby przyst\\u0105pi\\u0107 do rozwi\\u0105zywania testu, naci\\u015bnij przycisk \'Rozwi\\u0105\\u017c quiz\'.<\\/p>","introformat":1,"introfiles":[],"timeopen":0,"timeclose":0,"timelimit":6600,"overduehandling":"autosubmit","graceperiod":0,"preferredbehaviour":"deferredfeedback","canredoquestions":0,"attempts":1,"attemptonlast":0,"grademethod":3,"decimalpoints":2,"questiondecimalpoints":-1,"reviewattempt":65536,"reviewcorrectness":0,"reviewmarks":0,"reviewspecificfeedback":0,"reviewgeneralfeedback":0,"reviewrightanswer":0,"reviewoverallfeedback":0,"questionsperpage":1,"navmethod":"free","shuffleanswers":1,"sumgrades":115,"grade":125,"timecreated":0,"timemodified":1596705505,"password":"","subnet":"","browsersecurity":"-","delay1":0,"delay2":0,"showuserpicture":0,"showblocks":0,"completionattemptsexhausted":0,"completionpass":0,"allowofflineattempts":0,"autosaveperiod":60,"hasfeedback":0,"hasquestions":1,"section":0,"visible":1,"groupmode":0,"groupingid":0}],"warnings":[]}';

    HttpResponse response = new HttpResponse();
    public TB_MoodleMock(String methodType){
        response.setStatusCode(200);
        if (methodType == TB_MoodleConstants.API_FUNCTION_LOG_USER) {
            response.setBody('{"loginurl":"https:\\/\\/moodletest0.swps.edu.pl\\/auth\\/userkey\\/login.php?key=4a3ab253561c91579c37405c88661c6e"}');
        }else if(methodType == TB_MoodleConstants.FUNC_COURSE_RESULT){
            response.setBody('{"usergrades":[{"courseid":' + TB_MOODLE_COURSE_ID + ',"userid":' + TB_MOODLE_USER_ID + ',"userfullname":"Greta Front","maxdepth":2,"gradeitems":[{"id":16,"itemname":"Egzamin II stopie\\u0144","itemtype":"mod","itemmodule":"quiz","iteminstance":6,"itemnumber":0,"categoryid":6,"outcomeid":null,"scaleid":null,"locked":false,"cmid":12,"weightraw":1,"weightformatted":"100.00 %","graderaw":34.714289999999998,"gradedatesubmitted":1626948316,"gradedategraded":1626948316,"gradehiddenbydate":false,"gradeneedsupdate":false,"gradeishidden":true,"gradeislocked":false,"gradeisoverridden":false,"gradeformatted":"'+ TB_MOODLE_RESULT_POINTS +'","grademin":0,"grademax":50,"rangeformatted":"0&ndash;50","percentageformatted":"' + TB_MOODLE_RESULT_PERC + '","feedback":"","feedbackformat":0},{"id":15,"itemname":null,"itemtype":"course","itemmodule":null,"iteminstance":6,"itemnumber":null,"categoryid":null,"outcomeid":null,"scaleid":null,"locked":false,"graderaw":34.714289999999998,"gradedatesubmitted":null,"gradedategraded":1626948316,"gradehiddenbydate":false,"gradeneedsupdate":false,"gradeishidden":false,"gradeislocked":false,"gradeisoverridden":false,"gradeformatted":"' + TB_MOODLE_RESULT_POINTS + '","grademin":0,"grademax":50,"rangeformatted":"0&ndash;50","percentageformatted":"' + TB_MOODLE_RESULT_PERC + '","feedback":"","feedbackformat":0}]}],"warnings":[]}');
        }else if(methodType == TB_MoodleConstants.API_FUNCTION_LOGIN){
            response.setBody('{"token":"8de89ce2dae3850b9ee15e1b5db7e6db","privatetoken":null}');
        }else if(methodType == TB_MoodleConstants.FUNC_CREATE_USER){
            response.setBody('{users[0][email]=sebastian.ryczek@thinkbeyond.clouds, users[0][firstname]=iime, users[0][lastname]=nazwisko, users[0][password]=apppli203451678401045, users[0][username]=tbtestsebaapppli2034576258, wsfunction=core_user_create_users, wstoken=8de89ce2dae3850b9ee15e1b5db7e6db}');
        }
    }

    public HttpResponse respond(HttpRequest req) {
        return response;
    }

}
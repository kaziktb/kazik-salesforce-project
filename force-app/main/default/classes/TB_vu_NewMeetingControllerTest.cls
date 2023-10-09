@IsTest
private class TB_vu_NewMeetingControllerTest {
    private static final String STUDENT_MEETING_RECORD_TYPE = 'TB_Student_Meeting_HE';
    private static final String LANG_PL = 'PL';
    private static final String TEST_VALUE = 'TEST';
    private static final String SALESFORCE_CSS_AVAILABILITY_SOURCE = 'Salesforce_CSS';

    @TestSetup
    static void setupMethod() {
        List<Account> acc = TB_TestDataFactory.createAccounts(1, TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID, true);

        Contact contact = TB_TestDataFactory.createContact(false);
        contact.TB_User__c = UserInfo.getUserId();
        contact.AccountId = acc[0].Id;
        insert contact;

        sfal__Topic__c topic = new sfal__Topic__c(
                TB_Campus__c = 'Wa',
                TB_Availability_Source__c = SALESFORCE_CSS_AVAILABILITY_SOURCE,
                TB_Active__c = true,
                TB_Topic_PL__c = TEST_VALUE + 'PL',
                TB_Topic_EN__c = TEST_VALUE + 'EN'
        );
        insert topic;
        
        Account parentAccount = new Account(Name='Parent',BillingCity='Warszawa');
        insert parentAccount;
        Account childAccount = new Account(Name='Child',ParentId=parentAccount.Id);
        insert childAccount;

        TB_SS_Program_Enrollment_Setting__c customSetting = new TB_SS_Program_Enrollment_Setting__c();
        customSetting.TB_Days_Before_Enrollment_Start_Day__c = 0;
        insert customSetting;

        hed__Program_Enrollment__c programToInsert = new hed__Program_Enrollment__c(
                hed__Contact__c = contact.Id,
                hed__Account__c = childAccount.Id,
                DT_Level_Of_Studies__c = TB_vu_Constants.PROGRAM_ENROLMENT_LEVEL_OF_STUDIES[0],
                hed__Start_Date__c = Date.today()
        );
        insert programToInsert;
    }

    @isTest
    static void shouldReturnRecordTypeId(){
        String result;
        Test.startTest();
        result = TB_vu_NewMeetingController.getRecordTypeId(STUDENT_MEETING_RECORD_TYPE);
        Test.stopTest();

        System.assertEquals(true, result.length() > 0,'Size doesnt match with expected value');
    }

    @IsTest
    static void shouldReturnStudyNames(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<TB_vu_NewMeetingController.StudyNameWrapper> result = new List<TB_vu_NewMeetingController.StudyNameWrapper>();

        Test.startTest();
        System.runAs(user){
            result = TB_vu_NewMeetingController.getStudyNames(LANG_PL, contact.Id);
        }
        Test.stopTest();

        System.assert(result.size() > 0 , true);
    }

    @IsTest
    static void shouldNotReturnStudyNamesWrongLang(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<TB_vu_NewMeetingController.StudyNameWrapper> result = new List<TB_vu_NewMeetingController.StudyNameWrapper>();

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.getStudyNames('czajniz', contact.Id);
            }
            catch (AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected language, got an empty String or invalid language code', exceptionMessage);
    }

    @IsTest
    static void shouldNotReturnStudyNamesWrongId(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        List<TB_vu_NewMeetingController.StudyNameWrapper> result = new List<TB_vu_NewMeetingController.StudyNameWrapper>();

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.getStudyNames(LANG_PL, 'this is not proper Id');
            }
            catch (AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected contactId (Id), got an empty String or invalid type of Id', exceptionMessage);
    }

    @IsTest
    static void shouldReturnTopics(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        sfal__Topic__c topic =
        [
            SELECT Id, TB_Campus__c
            FROM sfal__Topic__c
            LIMIT 1
        ];
        List<TB_vu_NewMeetingController.TopicWrapper> result;

        Test.startTest();
        System.runAs(user){
            result = TB_vu_NewMeetingController.getTopics(topic.TB_Campus__c, SALESFORCE_CSS_AVAILABILITY_SOURCE);
        }
        Test.stopTest();

        Assert.isTrue(result.size() > 0);
    }

    @IsTest
    static void shouldNotReturnTopics(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        List<TB_vu_NewMeetingController.TopicWrapper> result;

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.getTopics(null,null);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected campus, got an empty String' , exceptionMessage);
    }

    @IsTest
    static void shouldNotReturnTopicsSource(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        sfal__Topic__c topic =
        [
                SELECT Id, sfal__Label__c, TB_Campus__c
                FROM sfal__Topic__c
        ];
        List<TB_vu_NewMeetingController.TopicWrapper> result;

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.getTopics(topic.TB_Campus__c,null);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected availabilitySource, got an empty String' , exceptionMessage);
    }

    @IsTest
    static void shouldSendCase(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        hed__Program_Enrollment__c programEnrollment =
        [
            SELECT Id, hed__Contact__c
            FROM hed__Program_Enrollment__c
            WHERE hed__Contact__c =: contact.Id LIMIT 1
        ];

        sfal__Topic__c topic =
        [
            SELECT Id
            FROM sfal__Topic__c
        ];

        TB_vu_NewMeetingController.CaseParameters caseParameters = new TB_vu_NewMeetingController.CaseParameters();
        caseParameters.studyNameId = programEnrollment.Id;
        caseParameters.subject = 'subject';
        caseParameters.description = 'description';
        caseParameters.language = LANG_PL;
        caseParameters.contactId = contact.Id;
        caseParameters.topicId = topic.Id;

        Test.startTest();
        System.runAs(user){
           result = TB_vu_NewMeetingController.sendCase(caseParameters);
        }
        Test.stopTest();

        System.assertEquals(true, result.size() == 2,'Size doesnt match with expected value');
    }

    @IsTest
    static void shouldNotSendCaseWrongStudyNameId(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        sfal__Topic__c topic =
        [
                SELECT Id
                FROM sfal__Topic__c
        ];

        TB_vu_NewMeetingController.CaseParameters caseParameters = new TB_vu_NewMeetingController.CaseParameters();
        caseParameters.studyNameId = 'wrongStudyNameId';
        caseParameters.subject = 'subject';
        caseParameters.description = 'description';
        caseParameters.language = LANG_PL;
        caseParameters.contactId = contact.Id;
        caseParameters.topicId = topic.Id;

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.sendCase(caseParameters);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected studyNameId (Id), got an empty String or invalid type of Id', exceptionMessage);
    }

    @IsTest
    static void shouldNotSendCaseNullSubject(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        hed__Program_Enrollment__c programEnrollment =
        [
                SELECT Id, hed__Contact__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c =: contact.Id LIMIT 1
        ];

        sfal__Topic__c topic =
        [
                SELECT Id
                FROM sfal__Topic__c
        ];

        TB_vu_NewMeetingController.CaseParameters caseParameters = new TB_vu_NewMeetingController.CaseParameters();
        caseParameters.studyNameId = programEnrollment.Id;
        caseParameters.subject = '';
        caseParameters.description = 'description';
        caseParameters.language = LANG_PL;
        caseParameters.contactId = contact.Id;
        caseParameters.topicId = topic.Id;

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.sendCase(caseParameters);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected subject, got null value or subject length is greater than 255', exceptionMessage);
    }

    @IsTest
    static void shouldNotSendCaseTooLongSubject(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        hed__Program_Enrollment__c programEnrollment =
        [
                SELECT Id, hed__Contact__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c =: contact.Id LIMIT 1
        ];

        sfal__Topic__c topic =
        [
                SELECT Id
                FROM sfal__Topic__c
        ];

        String subjectString = 'a';
        for(Integer i = 0; i<=300; i++){
            subjectString += 'a';
        }

        TB_vu_NewMeetingController.CaseParameters caseParameters = new TB_vu_NewMeetingController.CaseParameters();
        caseParameters.studyNameId = programEnrollment.Id;
        caseParameters.subject = subjectString;
        caseParameters.description = 'description';
        caseParameters.language = LANG_PL;
        caseParameters.contactId = contact.Id;
        caseParameters.topicId = topic.Id;

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.sendCase(caseParameters);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected subject, got null value or subject length is greater than 255', exceptionMessage);
    }

    @IsTest
    static void shouldNotSendCaseNullDescription(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        hed__Program_Enrollment__c programEnrollment =
        [
                SELECT Id, hed__Contact__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c =: contact.Id LIMIT 1
        ];

        sfal__Topic__c topic =
        [
                SELECT Id
                FROM sfal__Topic__c
        ];

        TB_vu_NewMeetingController.CaseParameters caseParameters = new TB_vu_NewMeetingController.CaseParameters();
        caseParameters.studyNameId = programEnrollment.Id;
        caseParameters.subject = 'subject';
        caseParameters.description = '';
        caseParameters.language = LANG_PL;
        caseParameters.contactId = contact.Id;
        caseParameters.topicId = topic.Id;

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.sendCase(caseParameters);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected description, got null value or description length is greater than 10000', exceptionMessage);
    }

    @IsTest
    static void shouldNotSendCaseTooLongDescription(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        hed__Program_Enrollment__c programEnrollment =
        [
                SELECT Id, hed__Contact__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c =: contact.Id LIMIT 1
        ];

        sfal__Topic__c topic =
        [
                SELECT Id
                FROM sfal__Topic__c
        ];

        String descriptionString = 'a';
        for(Integer i=0; i<10001; i++){
            descriptionString += 'a';
        }

        TB_vu_NewMeetingController.CaseParameters caseParameters = new TB_vu_NewMeetingController.CaseParameters();
        caseParameters.studyNameId = programEnrollment.Id;
        caseParameters.subject = 'subject';
        caseParameters.description = descriptionString;
        caseParameters.language = LANG_PL;
        caseParameters.contactId = contact.Id;
        caseParameters.topicId = topic.Id;

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.sendCase(caseParameters);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected description, got null value or description length is greater than 10000', exceptionMessage);
    }

    @IsTest
    static void shouldNotSendCaseWrongLanguage(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        hed__Program_Enrollment__c programEnrollment =
        [
                SELECT Id, hed__Contact__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c =: contact.Id LIMIT 1
        ];

        sfal__Topic__c topic =
        [
                SELECT Id
                FROM sfal__Topic__c
        ];

        TB_vu_NewMeetingController.CaseParameters caseParameters = new TB_vu_NewMeetingController.CaseParameters();
        caseParameters.studyNameId = programEnrollment.Id;
        caseParameters.subject = 'subject';
        caseParameters.description = 'description';
        caseParameters.language = 'sułachili';
        caseParameters.contactId = contact.Id;
        caseParameters.topicId = topic.Id;

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.sendCase(caseParameters);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected language, got an empty String or invalid language code', exceptionMessage);
    }

    @IsTest
    static void shouldNotSendCaseWrongContactId(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        hed__Program_Enrollment__c programEnrollment =
        [
                SELECT Id, hed__Contact__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c =: contact.Id LIMIT 1
        ];

        sfal__Topic__c topic =
        [
                SELECT Id
                FROM sfal__Topic__c
        ];

        TB_vu_NewMeetingController.CaseParameters caseParameters = new TB_vu_NewMeetingController.CaseParameters();
        caseParameters.studyNameId = programEnrollment.Id;
        caseParameters.subject = 'subject';
        caseParameters.description = 'description';
        caseParameters.language = LANG_PL;
        caseParameters.contactId = 'This is not proper contactId :(';
        caseParameters.topicId = topic.Id;

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.sendCase(caseParameters);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected contactId (Id), got an empty String or invalid type of Id', exceptionMessage);
    }

    @IsTest
    static void shouldNotSendCaseWrongTopicId(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;

        hed__Program_Enrollment__c programEnrollment =
        [
                SELECT Id, hed__Contact__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c =: contact.Id LIMIT 1
        ];

        sfal__Topic__c topic =
        [
                SELECT Id
                FROM sfal__Topic__c
        ];

        TB_vu_NewMeetingController.CaseParameters caseParameters = new TB_vu_NewMeetingController.CaseParameters();
        caseParameters.studyNameId = programEnrollment.Id;
        caseParameters.subject = 'subject';
        caseParameters.description = 'description';
        caseParameters.language = LANG_PL;
        caseParameters.contactId = contact.Id;
        caseParameters.topicId = 'This is not proper topicId :(';

        String exceptionMessage = '';
        Test.startTest();
        System.runAs(user){
            try{
                result = TB_vu_NewMeetingController.sendCase(caseParameters);
            }
            catch(AuraHandledException e){
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();

        Assert.areEqual('Expected topicId (Id), got an empty String or invalid type of Id', exceptionMessage);
    }
    
    @IsTest
    static void shouldSaveQMSMeeting(){
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Contact contact = [SELECT Id, TB_User__c FROM Contact WHERE TB_User__c =: user.Id];
        List<String> result;
        
        hed__Program_Enrollment__c programEnrollment =
        [
                SELECT Id, hed__Contact__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c =: contact.Id LIMIT 1
        ];
        
        sfal__Topic__c topic =
        [
                SELECT Id
                FROM sfal__Topic__c
        ];
    
        sfal__AppointmentLocation__c appointmentLocation = new sfal__AppointmentLocation__c();
        appointmentLocation.Name = 'Biuro CSS Warszawa';
        appointmentLocation.sfal__Type__c = 'In Person';
        appointmentLocation.sfal__Campus__c = 'Warszawa';
        insert appointmentLocation;
        
        TB_vu_QMS__c customSetting = new TB_vu_QMS__c();
        customSetting.TB_Base_URL__c = 'https://test.com';
        customSetting.TB_Company_Name__c = 'swps';
        customSetting.TB_Default_Meeting_Owner__c = UserInfo.getUserId();
        insert customSetting;
        
        TB_vu_NewMeetingController.QmsMeetingParameters params = new TB_vu_NewMeetingController.QmsMeetingParameters();
        params.contactId = contact.Id;
        params.description = 'test description';
        params.programEnrollmentId = programEnrollment.Id;
        params.reservationId = 'test-reservation-id';
        params.startTime = Datetime.newInstance(1997,2,21,17,0,0);
        params.topicId = topic.Id;
        params.location = 'CSS';
        
        Test.startTest();
        System.runAs(user){
            result = TB_vu_NewMeetingController.saveQMSMeeting(params);
        }
        Test.stopTest();
        
        Assert.areEqual(5,result.size());
    }
}
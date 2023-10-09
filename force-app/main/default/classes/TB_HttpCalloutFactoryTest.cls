@isTest
    private class TB_HttpCalloutFactoryTest {
        @IsTest
        static void testInitClassUnderTest() {
            SetupDataClass setup_data = new SetupDataClass();
            System.runAs(setup_data.TestUser) {
                Test.startTest();
                setup_data.initClassUnderTest();
                Test.stopTest();
                System.assertNotEquals(
                    null, setup_data.ClassUnderTest.CommandInfo, 'CommandInfo should be initialized'
                );
            }
        }

        @IsTest
        static void testPerformSuccesslHttpCallout() {
            SetupDataClass setup_data = new SetupDataClass();
            System.runAs(setup_data.TestUser) {
                setup_data.initClassUnderTest();
                Test.startTest();
                TB_HttpCalloutSuccess new_callout = new TB_HttpCalloutSuccess();
                setup_data.ClassUnderTest.performHttpCallout(new_callout);
                HttpResponse response = new_callout.getHttpResponse();
                String body = new_callout.getBody();
                String endpoint = new_callout.getEndpoint();
                Test.stopTest();
                System.assert(response.getStatusCode() == 200,'StatusCode should be 200');
                System.assert(body != null , 'Body should not be empty');
                System.assert(endpoint != null, 'Endpoint should not be empty');
            }
        }

        static testMethod void testPerformFailedHttpCallout() {
                SetupDataClass setup_data = new SetupDataClass();
                System.runAs(setup_data.TestUser) {
                    setup_data.initClassUnderTest();
                    setup_data.setMockForResponse(false);
                    Test.startTest();
                    TB_HttpCalloutFail new_callout = new TB_HttpCalloutFail();
                    setup_data.ClassUnderTest.performHttpCallout(new_callout);
                    HttpResponse response = new_callout.getHttpResponse();
                    String body = new_callout.getBody();
                    String endpoint = new_callout.getEndpoint();
                    Test.stopTest();
                    System.assertEquals(999, response.getStatusCode(), 'StatusCode should be 999');
                    System.assert(body != null , 'Body should not be empty');
                    System.assert(endpoint != null, 'Endpoint should not be empty');
                }
        }

        static testMethod void testPerformHttpCalloutWith403Response() {
            SetupDataClass setup_data = new SetupDataClass();
            System.runAs(setup_data.TestUser) {
                setup_data.initClassUnderTest();
                setup_data.setMockForResponse(false, 403);
                Test.startTest();
                TB_HttpCallout403Fail new_callout = new TB_HttpCallout403Fail();
                setup_data.ClassUnderTest.performHttpCallout(new_callout);
                HttpResponse response = new_callout.getHttpResponse();
                String body = new_callout.getBody();
                String endpoint = new_callout.getEndpoint();
                Test.stopTest();
                System.assertEquals(403, response.getStatusCode(), 'StatusCode should be 403');
                System.assert(body != null , 'Body should not be empty');
                System.assert(endpoint != null, 'Endpoint should not be empty');
            }
        }

        static testMethod void testPerformHttpCalloutWith500Response() {
            SetupDataClass setup_data = new SetupDataClass();
            System.runAs(setup_data.TestUser) {
                setup_data.initClassUnderTest();
                setup_data.setMockForResponse(false, 500);
                Test.startTest();
                TB_HttpCallout500Fail new_callout = new TB_HttpCallout500Fail();
                setup_data.ClassUnderTest.performHttpCallout(new_callout);
                HttpResponse response = new_callout.getHttpResponse();
                String body = new_callout.getBody();
                String endpoint = new_callout.getEndpoint();
                Test.stopTest();
                System.assertEquals(500, response.getStatusCode(), 'StatusCode should be 500');
                System.assert(body != null , 'Body should not be empty');
                System.assert(endpoint != null, 'Endpoint should not be empty');
            }
        }

        private class SetupDataClass {
            private TB_HttpCalloutFactory ClassUnderTest;
            private User TestUser;
            private Account TestAccount;
     
            private SetupDataClass() {

                Id test_user_profile_id =
                    [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
                String rand_value = String.valueOf(system.now().millisecond());
                TestUser =  new User(
                    FirstName = 'Test',
                    LastName = 'Person',
                    Email = 'testuser' + rand_value + '@thinkbeyond.com',
                    Username = 'testuser' + rand_value + '@thinkbeyond.com',
                    Alias = 'testu',
                    TimeZoneSidKey = 'GMT',
                    EmailEncodingKey = 'UTF-8',
                    LocaleSidKey = 'en_GB',
                    LanguageLocaleKey = 'en_US',
                    ProfileId = test_user_profile_id
                );
                insert TestUser;
            }
    
            private void initClassUnderTest() {
                ClassUnderTest = TB_HttpCalloutFactory.getInstance();
            }

            private void setMockForResponse(Boolean is_success) {
                Test.setMock(HttpCalloutMock.class, new TB_HttpCalloutTestMock(is_success));
            }
    
            private void setMockForResponse(Boolean is_success, Integer status_code) {
                Test.setMock(HttpCalloutMock.class, new TB_HttpCalloutTestMock(is_success, status_code));
            }
    
            private void setMockForResponse(String body) {
                Test.setMock(HttpCalloutMock.class, new TB_HttpCalloutTestMock(body));
            }
        }
}
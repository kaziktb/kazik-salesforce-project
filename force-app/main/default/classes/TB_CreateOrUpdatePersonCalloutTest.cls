@isTest
public class TB_CreateOrUpdatePersonCalloutTest {
    @IsTest
    static void testPerformSuccessfulHttpCallout() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            TB_CreateOrUpdatePersonRequest request_body = new TB_CreateOrUpdatePersonRequest();
            String token = '123123123123123123';
            Test.startTest();
            TB_CreateOrUpdatePersonCallout new_callout = new TB_CreateOrUpdatePersonCallout(request_body, token);
            
            setup_data.ClassUnderTest.performHttpCallout(new_callout);
            TB_CreateOrUpdatePersonResponse response =  (TB_CreateOrUpdatePersonResponse) JSON.deserialize(new_callout.HttpApiResponse.getBody(), TB_CreateOrUpdatePersonResponse.class);
            Test.stopTest();
            System.assert(new_callout.getHttpResponse().getStatusCode() == 200);
            System.assert(response.SfPersonId != null);
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

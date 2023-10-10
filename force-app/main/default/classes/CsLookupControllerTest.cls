@IsTest
public class CsLookupControllerTest {

    @TestSetup
    static void setup() {
        new AccountTestData().withIndustry('Education').save();
        new AccountTestData().withIndustry('Education').save();
    }

    @IsTest
    static void searchTest() {
        Test.startTest();
        List<SObject> results = CsLookupController.search('test', '', 'Account', false);
        Test.stopTest();

        Assert.areEqual(2, results.size(), 'Should return 2 records');
    }

    @IsTest
    static void searchTestDistinctValues() {
        Test.startTest();
        List<SObject> results = CsLookupController.search('Education', 'Industry', 'Account', true);
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should only return one distinct record');
    }

    @IsTest
    static void searchTestErrorCatch() {
        String error;

        Test.startTest();
        try {
            List<SObject> results = CsLookupController.search('test', '', 'Acc', false);
        } catch (Exception e) {
            error = e.getMessage();
        }
        Test.stopTest();

        Assert.isNotNull(error, 'Error should be thrown');
    }

}
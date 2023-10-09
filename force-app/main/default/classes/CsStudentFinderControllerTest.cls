@IsTest
public class CsStudentFinderControllerTest {
    
    @TestSetup
    static void setup() {
        new AccountTestData().save();
        new AccountTestData().save();
    }

    @IsTest
    static void queryTest() {
        Test.startTest();
        List<SObject> results = CsStudentFinderController.query('SELECT Id FROM Account');
        Test.stopTest();

        Assert.areEqual(2, results.size(), 'Should return 2 records');
    }

    @IsTest
    static void queryTestErrorCatch() {
        String error;

        Test.startTest();
        try {
            List<SObject> results = CsStudentFinderController.query('SELECT Id FROM Acc');
        } catch (Exception e) {
            error = e.getMessage();
        }
        Test.stopTest();

        Assert.isNotNull(error, 'Error should be thrown');
    }
}
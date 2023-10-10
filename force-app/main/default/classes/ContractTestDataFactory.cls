@IsTest
public class ContractTestDataFactory {
    public static Contract createContract(Id accountId, String status, Boolean withInsert) {
        return withInsert
            ? new ContractTestData()
                .withAccount(accountId)
                .withStatus(status)
                .withStartDate(Date.today())
                .withEndDate(Date.today().addDays(90))
                .save()
                .get()
            : new ContractTestData()
                .withAccount(accountId)
                .withStatus(status)
                .withStartDate(Date.today())
                .withEndDate(Date.today().addDays(90))
                .get();
    }
}
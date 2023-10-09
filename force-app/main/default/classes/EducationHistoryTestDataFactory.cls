@IsTest
public class EducationHistoryTestDataFactory {

    public static List<hed__Education_History__c> createWithStatusStudying(Id contactId, Integer quantity, Boolean withInsert) {
        List<hed__Education_History__c> educationHistories = new List<hed__Education_History__c>();

        for (Integer i = 0; i < quantity; i++) {
            educationHistories.add(
                new EducationHistoryTestData()
                    .withContact(contactId)
                    .withStatus(Constants.EDUCATION_HISTORY_STATUS_STUDYING)
                    .get()
            );
        }

        if (withInsert) {
            insert educationHistories;
        }

        return educationHistories;
    }
}
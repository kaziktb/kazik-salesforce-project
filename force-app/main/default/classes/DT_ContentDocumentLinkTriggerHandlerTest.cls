/**
 * Created by aleksandragonta-kacperska on 01/12/2021.
 */
@IsTest
public class DT_ContentDocumentLinkTriggerHandlerTest {

    @testSetup static void dataInit() {
        DT_DataFactory.createTasks(1, true, new Task()).get(0);
        DT_DataFactory.createContentVersions(1, true, new ContentVersion()).get(0);

    }
    @IsTest
    public static void testFileLinkedToTask() {
        Task task = [SELECT Id FROM Task LIMIT 1];
        ContentVersion contentVersion = [ SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>{
                new ContentDocumentLink(LinkedEntityId =task.Id,  ContentDocumentId = contentVersion.ContentDocumentId)
        };
        Test.startTest();
                insert contentDocumentLinks;
        Test.stopTest();
       
        ContentDocumentLink contentDocumentLink = [SELECT Visibility FROM ContentDocumentLink WHERE Id = :contentDocumentLinks.get(0).Id];
        System.assertEquals(true, contentDocumentLink.Visibility == DT_Utils.VISIBILITY_TYPE_ALL_USERS);
    }
}
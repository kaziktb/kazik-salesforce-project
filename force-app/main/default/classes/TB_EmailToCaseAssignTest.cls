@isTest
private class TB_EmailToCaseAssignTest {
    @TestSetup
    static void makeData(){

        Case c = new Case();
        c.Origin = 'Email';
        c.SuppliedEmail = 'kowalski.praca@test.pl';
        insert c;

        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'podyplomowe.katowice@swps.edu.pl';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;

        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Kowalski',
            hed__WorkEmail__c = 'kowalski.praca@test.pl',
            hed__AlternateEmail__c= 'kowalski.praca@test.pl',
            Email= 'kowalski.praca@test.pl',
            Title = 'Test Ttile',
            hed__Preferred_Email__c = 'Alternate'
         );
         insert contact;
    }


    @isTest 
    private static void emailAssigntest(){
        Id caseId = [SELECT ID FROM CASE LIMIT 1].Id;
        TB_EmailToCaseAssign.WrapperClass testinput = new TB_EmailToCaseAssign.WrapperClass();
        testinput.CaseId = caseId;
        List<TB_EmailToCaseAssign.WrapperClass> testlist = new List<TB_EmailToCaseAssign.WrapperClass>();
        testlist.add(testinput);
        Test.startTest();
        TB_EmailToCaseAssign.emailAssign(testlist);
        Test.stopTest();

        Case updatedCase = [SELECT Id, AccountId, ContactId FROM CASE LIMIT 1];
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        System.assertEquals(updatedCase.AccountId, accId,'Account should be assigned');
        System.assertEquals(updatedCase.ContactId, contactId,'Contact should be assigned');
    }
}
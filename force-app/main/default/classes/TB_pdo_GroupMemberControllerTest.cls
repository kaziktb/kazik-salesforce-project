/**
 * Created by kamilkwaczynski on 05/01/2023.
 */

@IsTest
private class TB_pdo_GroupMemberControllerTest {
  @TestSetup
  static void testSetup() {
    Group grp = new Group();
    grp.Name = 'TestGroup';
    grp.Email = 'test@group.com';
    grp.Type = 'Queue';
    insert grp;
    User usr = TB_TestDataFactory.createUser('System Administrator', true);
    GroupMember gm = new GroupMember();
    gm.GroupId = grp.Id;
    gm.UserOrGroupId = usr.Id;
    insert gm;
  }

  @IsTest
  static void getRelatedContactsFromGroupMembers() {
    Integer expectedSize = 1;
    User usr = [
      SELECT Id
      FROM User
      WHERE Email = 'puser000@amamama.com'
      LIMIT 1
    ];
    Contact con = new Contact(LastName = 'Pantest', TB_User__c = usr.Id);
    insert con;

    GroupMember gm = [
      SELECT Id, GroupId
      FROM GroupMember
      WHERE UserOrGroupId = :usr.Id
    ];

    Test.startTest();
    List<String> gmGroupIds = new List<String>();
    gmGroupIds.add(gm.GroupId);
    List<List<Contact>> result = TB_pdo_GroupMemberController.getAllContactFromGroupMember(
      gmGroupIds
    );
    Test.stopTest();

    System.assertEquals(con.LastName, result[0][0].LastName);
    System.assertEquals(expectedSize, result[0].size());
  }
}
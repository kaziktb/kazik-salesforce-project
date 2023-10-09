/**
 * Created by kamilkwaczynski on 11/08/2022.
 */

public with sharing class TB_pdo_GroupMemberController {
  @InvocableMethod
  public static List<List<Contact>> getAllContactFromGroupMember(
    List<String> idsOfQueues
  ) {
    List<Id> userIds = new List<Id>();
    for (GroupMember groupMember : [
      SELECT UserOrGroupId
      FROM GroupMember
      WHERE GroupId = :idsOfQueues
    ]) {
      userIds.add(groupMember.UserOrGroupId);
    }
    List<Contact> contacts = [
      SELECT
        Id,
        LastName,
        FirstName,
        Email,
        hed__Gender__c,
        TB_Active__c,
        hed__WorkEmail__c
      FROM Contact
      WHERE TB_User__c = :userIds
    ];
    List<List<Contact>> listOfContacts = new List<List<Contact>>();
    listOfContacts.add(contacts);
    return listOfContacts;
  }
}
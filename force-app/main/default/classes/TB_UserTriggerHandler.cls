public with sharing class TB_UserTriggerHandler extends TB_TriggerHandler {
    public override void afterInsert() {
      Set<Id> usersIds = new Set<Id>();
      for (SObject u : Trigger.new) {
        usersIds.add(u.Id);
      }
      assignPermissionSet(usersIds);
    }

    @Future
    private static void assignPermissionSet(Set<Id> usersId) {
      List<PermissionSet> permissionSet = [
        SELECT Id
        FROM PermissionSet
        WHERE Name = 'TB_SWPS_Contract_Teachers_Applicant_Didactic'
      ];
      List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
      if(permissionSet.isEmpty()) {
        return;
      }

      for (User u : [SELECT Id, Name FROM User WHERE Id IN :usersId AND Profile.Name = 'SWPS Employee Community User']) {
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permissionSet[0]?.Id,AssigneeId = u.Id);
        permissionSetList.add(psa);
      }
      try {
        insert permissionSetList;
      } catch (DmlException ex) {
        insert TB_LogUtils.registerLog(ex.getMessage(),TB_UserTriggerHandler.class);
      }
    }
}

public without sharing class TB_ObjectSharing {

    @InvocableMethod(label='createShares')
    public static void createShares(List<List<SObject>> sharesToCreate) {
        Set<Id> userIds = new Set<Id>();
        List<SObject> sharesToCreateElement = sharesToCreate[0];
        for (SObject share : sharesToCreateElement) {
            if (Id.valueOf(String.valueOf(share.get('UserOrGroupId'))).getSobjectType().getDescribe().getName() == 'User') {
                userIds.add(String.valueOf(share.get('UserOrGroupId')));
            }
        }
        List<User> usersToActivate = [
            SELECT Id, IsActive
            FROM User
            WHERE Id IN: userIds
            AND IsActive = FALSE
        ];
        for (User userToActivate : usersToActivate) {
            userToActivate.IsActive = true;
        }
        try {
            Database.executeBatch(new TB_ObjectSharingBatch(usersToActivate, sharesToCreateElement));
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_ObjectSharing.class);
        }

    }

    public static void insertShares(List<SObject> sharesToCreateElement) {
        List<SObject> sharesToInsert = new List<SObject>();
        for (SObject share : sharesToCreateElement) {
            String objectType = Id.valueOf(String.valueOf(share.get('ParentId'))).getSobjectType().getDescribe().getName();
            SObject sObj = Schema.getGlobalDescribe().get(objectType.replace('c','Share')).newSObject();
            sObj.put('ParentId', String.valueOf(share.get('ParentId')));
            sObj.put('UserOrGroupId', String.valueOf(share.get('UserOrGroupId')));
            sObj.put('AccessLevel', String.valueOf(share.get('AccessLevel')));
            sObj.put('RowCause', String.valueOf(share.get('RowCause')));
            sharesToInsert.add(sObj);
        }
        try {
            insert sharesToInsert;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_ObjectSharing.class);
        }
    }

}
/**
 * Created by annaseveryna on 13/12/2021.
 */

public without sharing class TB_RequestSubmittedControllerSharingSkip {
    public static Map<Id, Boolean> userIdToIsOutboundUser(Set<Id> userIds) {
        List<User> users = [SELECT UserType FROM User WHERE Id = :userIds];
        Map<Id, Boolean> userIdToIsInboundUserMap = new Map<Id, Boolean>();
        for (User user : users) {
            userIdToIsInboundUserMap.put(user.Id,
                user.UserType == 'CspLitePortal'
                || user.UserType == 'PowerPartner'
                || user.UserType == 'PowerCustomerSuccess');
        }
        return userIdToIsInboundUserMap;
    }

    public static Boolean userIdToIsPartnerUser(Id userId) {
        User user = [SELECT UserType FROM User WHERE Id = :userId];
        return  user.UserType == 'PowerPartner';
    }
}
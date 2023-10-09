public without sharing class TB_MultiContactTriggerHandlerService {
    @Future
    public static void asyncUpdateContacts(Map<String, String> otherContactsIdToIndividualIdMap) {
        try {
            List<Contact> contactsToUpdate = [SELECT Id FROM Contact WHERE Id IN :otherContactsIdToIndividualIdMap.keySet()];
            for (Contact contact : contactsToUpdate) {
                contact.IndividualId = otherContactsIdToIndividualIdMap.get(contact.Id);
            }
            if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;
            }
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }
}
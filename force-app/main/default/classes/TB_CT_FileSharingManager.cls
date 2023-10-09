public with sharing class TB_CT_FileSharingManager {
    private static final String CATEGORY_DIPLOMA = 'Diploma';
    private static final String CATEGORY_CV = 'CV';
    private static final String VISIBILITY_ALL_USERS = 'AllUsers';

    List<ContentVersion> versions;

    public TB_CT_FileSharingManager(List<ContentVersion> versions) {
        this.versions = versions;
    }

    public void updateCDLsVisibility() {
        List<ContentDocumentLink> filteredLinks = getFilteredContentDocumentLinks();
        List<ContentDocumentLink> cdlsToUpdate = new List<ContentDocumentLink>();
        cdlsToUpdate.addAll(getCDLsToUpdateFromContacts(filteredLinks));
        cdlsToUpdate.addAll(getCDLsToUpdateFromExperienceHistories(filteredLinks));
        update cdlsToUpdate;
    }

    @TestVisible
    private List<ContentDocumentLink> getFilteredContentDocumentLinks() {
        List<ContentVersion> filteredVersions = new List<ContentVersion>();
        for (ContentVersion version : this.versions) {
            if (version.TB_Category__c == CATEGORY_DIPLOMA || version.TB_Category__c == CATEGORY_CV) {
                filteredVersions.add(version);
            }
        }
        Set<String> documentIds = TB_SObjectUtils.createIdFieldValueSet(filteredVersions, ContentVersion.ContentDocumentId);
        if (documentIds.size() > 0) {
            List<ContentDocumentLink> links = [
                    SELECT Id, LinkedEntityId, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE ContentDocumentId
                            IN :documentIds
            ];
            return links;
        }
        return new List<ContentDocumentLink>();
    }

    private List<ContentDocumentLink> getCDLsToUpdateFromContacts(List<ContentDocumentLink> links) {
        List<ContentDocumentLink> cdlsToUpdate = new List<ContentDocumentLink>();
        for (ContentDocumentLink link : links) {
            if (link.LinkedEntityId.getSobjectType() == Contact.SObjectType) {
                link.Visibility = VISIBILITY_ALL_USERS;
                cdlsToUpdate.add(link);
            }
        }
        return cdlsToUpdate;
    }

    private List<ContentDocumentLink> getCDLsToUpdateFromExperienceHistories(List<ContentDocumentLink> links) {
        List<ContentDocumentLink> cdlsToUpdate = new List<ContentDocumentLink>();
        for (ContentDocumentLink link : links) {
            if (link.LinkedEntityId.getSobjectType() == TB_Experience_History__c.SObjectType) {
                link.Visibility = VISIBILITY_ALL_USERS;
                cdlsToUpdate.add(link);
            }
        }
        return cdlsToUpdate;
    }
}
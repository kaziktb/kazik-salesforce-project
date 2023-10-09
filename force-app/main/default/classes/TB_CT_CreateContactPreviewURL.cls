public with sharing class TB_CT_CreateContactPreviewURL {

    public static String COMMUNITY_URL_SETTING = 'Community_Contact_Preview';

    @InvocableMethod(Label='createContactPreviewUrl')
    public static List<LinkWrapper> createContactPreviewUrl(List<Id> applicantIds) {
        List<LinkWrapper> outputs = new List<LinkWrapper>();
        try {
            TB_Community_main_url__mdt communityLink = TB_Community_main_url__mdt.getInstance(COMMUNITY_URL_SETTING);
            for(Id applicantId : applicantIds) {
                LinkWrapper wrapper = new LinkWrapper();
                wrapper.contactPreviewURL = communityLink.Community_URL__c + '?contact-id=' + applicantId + '&mode=preview';
                outputs.add(wrapper);
            }
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e.getMessage(), TB_CT_CreateContactPreviewURL.class);
        }
        return outputs;
    }

    public class LinkWrapper {
        @InvocableVariable
        public String contactPreviewURL;
    }
}
/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 12-01-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
**/
public class DT_ContentDocumentLinkTriggerHandler {
    public static void changeContentDocumentLinkVisibility(List<ContentDocumentLink> newList) {
        for (ContentDocumentLink cdl : newList) {
            String cdlId = String.valueOf(cdl.LinkedEntityId).substring(0, 3);
            Set <String> objectIdPrefixes = new Set<String>{
                    DT_Utils.TASK_ID_PREFIX,
                    DT_Utils.TEMPLATE_TASK_ID_PREFIX,
                    DT_Utils.SUCCESS_PLAN_ID_PREFIX,
                    DT_Utils.SUCCESS_PLAN_TEMPLATE_ID_PREFIX
            };
            if (objectIdPrefixes.contains(cdlId)) {
                cdl.Visibility = DT_Utils.VISIBILITY_TYPE_ALL_USERS;
            }
        }
    }
}
public with sharing class TB_IC_SidebarNavigation {
    private static final String OBJECT_API_NAME = 'TB_Portal__c';
    private static final String SUB_MENU_ITEM_TYPE = 'Sub_Menu';
    private static final String DEFAULT_ICON_NAME = 'home-outline';
    private static final String PUBLIC_ACCESS_MODE = 'public';
    private static final String PRIVATE_ACCESS_MODE = 'private';
    private static final String NAV_MAIN_ELEMENT_STYLE = 'nav-main-element';
    private static final String NAV_SUB_ELEMENT_STYLE = 'nav-sub-element';
    private static final String POLISH_LANGUAGE_CODE = 'pl';

    public class NavigationItem {
        @AuraEnabled
        public String icon;

        @AuraEnabled
        public String label;

        @AuraEnabled
        public String target;

        @AuraEnabled
        public String params;

        @AuraEnabled
        public Boolean newTab;

        @AuraEnabled
        public Boolean hasChilds;

        @AuraEnabled
        public Boolean showChilds;

        @AuraEnabled
        public String style;

        @AuraEnabled
        public List<NavigationItem> subOptions;

        public NavigationItem() {
            this.hasChilds = false;
            this.showChilds = false;
            this.style = NAV_MAIN_ELEMENT_STYLE;
            this.subOptions = new List<NavigationItem>();
        }
    }

    public static String checkPrivileges() {
        return Auth.CommunitiesUtil.isGuestUser() ? PUBLIC_ACCESS_MODE : PRIVATE_ACCESS_MODE;
    }

    public static Boolean isPolishLanguage() {
        return UserInfo.getLanguage() == POLISH_LANGUAGE_CODE;
    }

    @AuraEnabled
    public static List<NavigationItem> getNavigationItems(String portal, String subMenu) {
        List<TB_Portal__c> navigationItems = new List<TB_Portal__c>();

        try {
            List<TB_JSON_Wrapper__c> wrappers = [
                SELECT Id, TB_Wrapper_Value__c, TB_Object_API_Name__c
                FROM TB_JSON_Wrapper__c
                WHERE
                    TB_Object_API_Name__c = :OBJECT_API_NAME
                    AND TB_Portal_Type__c = :portal
                ORDER BY TB_Order__c
            ];

            for (TB_JSON_Wrapper__c singleWrapper : wrappers) {
                TB_Portal__c navigationItem = (TB_Portal__c) JSON.deserialize(
                    singleWrapper.TB_Wrapper_Value__c,
                    TB_Portal__c.class
                );

                if (navigationItem.TB_Active__c == true) {
                    navigationItems.add(navigationItem);
                }
            }
        } catch (Exception e) {
            TB_LogUtils.registerLogFuture(e.getMessage(), TB_IC_SidebarNavigation.class.getName());
        }

        return prepareData(navigationItems, subMenu);
    }

    public static List<NavigationItem> prepareData(List<TB_Portal__c> navigationItems, String subMenu) {
        String userPrivileges = checkPrivileges();
        Boolean isPolish = isPolishLanguage();
        List<NavigationItem> returnData = new List<NavigationItem>();
        for (TB_Portal__c subMenuItem : navigationItems) {
            if (
                subMenuItem.TB_Item_Type__c == SUB_MENU_ITEM_TYPE &&
                    subMenuItem.TB_Sub_Menu_Name__c == subMenu &&
                    (subMenuItem.TB_Access_Mode__c == PUBLIC_ACCESS_MODE ||
                        subMenuItem.TB_Access_Mode__c == userPrivileges)
            ) {
                for (TB_Portal__c parentNavigationItem : navigationItems) {
                    if (
                        parentNavigationItem.TB_Parent_Navigation_Item__c ==
                            subMenuItem.Id &&
                            (parentNavigationItem.TB_Access_Mode__c == PUBLIC_ACCESS_MODE ||
                                parentNavigationItem.TB_Access_Mode__c == userPrivileges)
                    ) {
                        NavigationItem parentObject = new NavigationItem();

                        parentObject.icon = parentNavigationItem.TB_Icon__c != null ?
                            parentNavigationItem.TB_Icon__c : DEFAULT_ICON_NAME;

                        parentObject.label = isPolish ? parentNavigationItem.TB_Text_PL__c : parentNavigationItem.TB_Text_EN__c;
                        parentObject.target = parentNavigationItem.TB_Page_API_Name__c;
                        parentObject.params = parentNavigationItem.TB_Page_Parameter__c;
                        parentObject.newTab = parentNavigationItem.TB_Open_In_New_Tab__c;

                        for (TB_Portal__c childNavigationItem : navigationItems) {
                            if (
                                childNavigationItem.TB_Parent_Navigation_Item__c ==
                                    parentNavigationItem.Id &&
                                    (childNavigationItem.TB_Access_Mode__c == PUBLIC_ACCESS_MODE ||
                                        childNavigationItem.TB_Access_Mode__c == userPrivileges)
                            ) {
                                parentObject.hasChilds = true;
                                NavigationItem childObject = new NavigationItem();
                                childObject.label = isPolish ? childNavigationItem.TB_Text_PL__c : childNavigationItem.TB_Text_EN__c;
                                childObject.target = childNavigationItem.TB_Page_API_Name__c;
                                childObject.params = childNavigationItem.TB_Page_Parameter__c;
                                childObject.style = NAV_SUB_ELEMENT_STYLE;
                                parentObject.subOptions.add(childObject);
                            }
                        }
                        returnData.add(parentObject);
                    }
                }
            }
        }
        return returnData;
    }
}
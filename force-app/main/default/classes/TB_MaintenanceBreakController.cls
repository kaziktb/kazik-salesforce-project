public without sharing class TB_MaintenanceBreakController {
    private static final String COMMERCE_PORTAL_NAME = 'Commerce';
    private static final String VIRTUAL_UNIVERSITY_PORTAL_NAME = 'Virtual_University';
    private static final String ADMISSIONS_PORTAL_NAME = 'admissions';
    private static final String CONTRACT_TEACHERS_PORTAL_NAME = 'Contract_Teachers';

    @AuraEnabled
    public static TB_Maintenance_Break__c getMaintenanceBreak() {
        return TB_Maintenance_Break__c.getInstance();
    }

    @AuraEnabled
    public static sObject getPortalMaintenanceBreak(String portalName) {
        sObject toReturn = null;
        try{
            if(portalName == COMMERCE_PORTAL_NAME){
                toReturn = (TB_Commerce_Maintenance_Break__c)TB_Commerce_Maintenance_Break__c.getInstance();
            }

            else if(portalName == VIRTUAL_UNIVERSITY_PORTAL_NAME){
                toReturn = (TB_Virtual_University_Maintenance_Break__c)TB_Virtual_University_Maintenance_Break__c.getInstance();
            }

            else if(portalName == ADMISSIONS_PORTAL_NAME){
                toReturn = (TB_Admissions_Maintenance_Break__c)TB_Admissions_Maintenance_Break__c.getInstance();
            }
            else if(portalName == CONTRACT_TEACHERS_PORTAL_NAME){
                toReturn = (TB_Contract_Teachers_Maintenance_Break__c)TB_Contract_Teachers_Maintenance_Break__c.getInstance();
            }

        }catch(Exception e){
            TB_LogUtils.registerLogFuture(
                e.getMessage(),
                TB_MaintenanceBreakController.class.getName()
            );
        }
        return toReturn;

    }

}
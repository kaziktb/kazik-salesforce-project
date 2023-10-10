public with sharing class TB_vu_QMSService
{
    @AuraEnabled(Cacheable=true)
    public static QMSSettingsWrapper getSettings()
    {
        TB_vu_QMS__c customSetting = TB_vu_QMS__c.getInstance();
        return new QMSSettingsWrapper(customSetting.TB_Base_URL__c,customSetting.TB_Company_Name__c);
    }
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,String> getAutofillData(List<Id> recordIds)
    {
        Map<String,String> propertyValues = new Map<String,String>();
        Map<String,TB_QMS_Property_Mapping__mdt> propertyMappings = TB_QMS_Property_Mapping__mdt.getAll();
        if(propertyMappings.isEmpty())
        {
            return propertyValues;
        }
        Map<String,List<String>> fieldsToObjects = new Map<String,List<String>>();
        for(TB_QMS_Property_Mapping__mdt mapping : propertyMappings.values())
        {
            if(fieldsToObjects.get(mapping.TB_Object_API_Name__c) == null)
            {
                fieldsToObjects.put(mapping.TB_Object_API_Name__c, new List<String>{mapping.TB_Field_API_Name__c});
            }
            else
            {
                fieldsToObjects.get(mapping.TB_Object_API_Name__c).add(mapping.TB_Field_API_Name__c);
            }
        }
        
        Map<String,SObject> autoFillRecords = new Map<String,SObject>();
        for(String objectName : fieldsToObjects.keySet())
        {
            if(Schema.getGlobalDescribe().get(objectName) != null && !fieldsToObjects.get(objectName).isEmpty())
            {
                try
                {
                    autoFillRecords.put(objectName,Database.query('SELECT ' + String.join(fieldsToObjects.get(objectName),', ') + ' FROM ' + objectName + ' WHERE Id IN :recordIds'));
                }
                catch(Exception e)
                {
                    throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_QMSService.class.getName(),e.getStackTraceString(), null));
                }
            }
        }
    
        if(autoFillRecords.isEmpty())
        {
            return propertyValues;
        }
        
        for(TB_QMS_Property_Mapping__mdt mapping : propertyMappings.values())
        {
            if(autoFillRecords.get(mapping.TB_Object_API_Name__c) != null)
            {
                Object autoFillObject = autoFillRecords.get(mapping.TB_Object_API_Name__c).get(mapping.TB_Field_API_Name__c);
                if(autoFillObject != null)
                {
                    propertyValues.put(mapping.TB_QMS_Property_Name__c, autoFillObject.toString());
                }
            }
        }
        return propertyValues;
    }
    
    public class QMSSettingsWrapper
    {
        @AuraEnabled
        public String baseUrl;
        @AuraEnabled
        public String companyName;
        
        public QMSSettingsWrapper(String baseUrl, String companyName)
        {
            this.baseUrl = baseUrl;
            this.companyName = companyName;
        }
    }
}
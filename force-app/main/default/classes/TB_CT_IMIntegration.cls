public without sharing class TB_CT_IMIntegration {
    private static final String DATE_FORMAT  = 'yyyy-MM-dd';
    private static final String MISSING_APP_TRACKING_RECORD = System.Label.TB_Missing_App_Tracking;
    private static final String DEFAULT_BUSINESS_UNIT_CODE = 'D003';
    
    public static String createOrUpdatePerson(String contactId, String language, Boolean IsSynced){
        try {
        Contact contact = [SELECT ID,
                                  Birthdate, TB_Citizenship__c,
                                  FirstName, hed__Gender__c, 
                                  DT_Document_Issuing_Country__c, DT_Country_of_Birth__c,
                                  DT_Document_Type__c, DT_PESEL__c,
                                  DT_Document_Series_and_Number__c, TB_Title_Grade__c,
                                  DT_Foreigner__c, LastName, Phone, TB_Family_Name__c,
                                  hed__AlternateEmail__c,
                                  Email, Department, TB_ERP_Id__c, TB_IM_Id__c, hed__WorkEmail__c
                                  FROM Contact WHERE ID =:contactId];

        hed__Affiliation__c affiliation =  
            [SELECT ID, Name, TB_RoleType__c, TB_Location__c, hed__Account__r.TB_Business_Unit_Code__c,
            TB_Position__c, TB_EmploymentType__c, TB_EmploymentCat__c, TB_Application_Date__c
            FROM hed__Affiliation__c
            WHERE hed__Contact__c =:contactId LIMIT 1];
        if(IsSynced){
                deactivateRelatedAffiliations(contactId);
            }
        TB_App_Tracking__c appTracking;
        try {
                appTracking = [SELECT Id,TB_Process_Status__c FROM  TB_App_Tracking__c WHERE TB_Applicant__c =:contact.Id LIMIT 1];    
        } catch (Exception ex) {
                throw new  TB_CT_IMIntegrationException(MISSING_APP_TRACKING_RECORD);
        }    
        
        TB_CreateOrUpdatePersonRequest new_person = new TB_CreateOrUpdatePersonRequest();

        new_person.PersonId = contact.Id;
        new_person.ImPersonId = contact.TB_IM_Id__c != null ? Integer.valueOf(contact.TB_IM_Id__c) : null;

        new_person.PESEL = contact.DT_PESEL__c;
        new_person.BirthDate = Datetime.newInstance(contact.Birthdate.year(), 
                                                contact.Birthdate.month(), 
                                                contact.Birthdate.day()).format(DATE_FORMAT);
        new_person.Citizenship = contact.TB_Citizenship__c;
        new_person.Firstname = contact.FirstName;
        new_person.Gender = contact.hed__Gender__c == 'Female' ? 1 : 0;
        new_person.Lastname = contact.LastName; 
        new_person.OtherNames = contact.TB_Family_Name__c;
        new_person.PrivateEmail = contact.hed__AlternateEmail__c; 
        new_person.Title = contact.TB_Title_Grade__c;
        new_person.Telephone = contact.Phone;
        new_person.Role.Department = affiliation.hed__Account__r.TB_Business_Unit_Code__c == null ?
                        DEFAULT_BUSINESS_UNIT_CODE : affiliation.hed__Account__r.TB_Business_Unit_Code__c; 
        new_person.Role.EmploymentFrom = Datetime.newInstance(affiliation.TB_Application_Date__c.year(), 
                                                          affiliation.TB_Application_Date__c.month(), 
                                                          affiliation.TB_Application_Date__c.day()).format(DATE_FORMAT);     
        new_person.Role.EmploymentType = affiliation.TB_EmploymentType__c;
        new_person.Role.Location = affiliation.TB_Location__c;
        new_person.Role.Position = affiliation.TB_Position__c;
        new_person.Role.RoleId = affiliation.Name;
        new_person.Role.RoleType = affiliation.TB_RoleType__c;
        new_person.Role.EmploymentCategory = affiliation.TB_EmploymentCat__c;

        new_person.IdentityDocument.Country =  contact.DT_Document_Issuing_Country__c; 
        new_person.IdentityDocument.DocumentType = contact.DT_Document_Type__c == 'POLSKI_DOWOD_OSOBISTY' ? 0 : 1;
        new_person.IdentityDocument.Number0 = contact.DT_Document_Series_and_Number__c; 

        String token = TB_IM_Integration_Token__mdt.getInstance('IM_Token').Value__c;

        TB_CreateOrUpdatePersonCallout callout = new TB_CreateOrUpdatePersonCallout(new_person,token);
        TB_HttpCalloutFactory callout_factory = TB_HttpCalloutFactory.getInstance();
        callout_factory.performHttpCallout(callout);
        String response_body = callout.getHttpResponse().getBody();
            if(callout.CommandSuccessful){
                    TB_CreateOrUpdatePersonResponse person_data_response = (TB_CreateOrUpdatePersonResponse) JSON.deserialize(response_body, TB_CreateOrUpdatePersonResponse.class);
                    contact.TB_ERP_Id__c = person_data_response.SfPersonId;
                    contact.TB_IM_Id__c = String.valueOf(person_data_response.ImPersonId);
                    contact.hed__WorkEmail__c = person_data_response.WorkerLogin;
                    update contact;
                    if(!IsSynced){
                        appTracking.TB_Process_Status__c = 'Data_Synced'; 
                        update appTracking; 
                    }
            }
            else{
                    if(!IsSynced){
                        appTracking.TB_Process_Status__c = 'Data_Sync_Error'; 
                        update appTracking; 
                    }
                    throw new TB_CT_IMIntegrationException(response_body);
            }
        return response_body;
        }
         catch (Exception ex) {
            insert TB_LogUtils.registerLog(ex);
            throw new TB_CT_IMIntegrationException(friendlyerrorDecodeToUser(ex,language));
        }
    }

    private static void deactivateRelatedAffiliations(Id contactId){
            List<hed__Affiliation__c> affiliations = new List<hed__Affiliation__c>();
            for (hed__Affiliation__c aff : [SELECT Id FROM hed__Affiliation__c WHERE hed__Contact__c =:contactId]){
                aff.hed__EndDate__c = Date.today();
                affiliations.add(aff);
            }
            update affiliations;
    }

    public static String friendlyerrorDecodeToUser(Exception ex, String language){
        List<String> keys = new List<String>();
        List<String> messages = ex.getMessage().replaceAll('\\]*"*\\[*','').split(',');
        for(String current : messages){
            keys.add(current.split(';').get(0).trim());
        }
        List<TB_Admissions_Content__c> translations = [SELECT Id, TB_Content_EN__c, TB_Content_PL__c, TB_Record_Code__c
                                                 FROM TB_Admissions_Content__c WHERE TB_Record_Code__c IN :keys];
        String message = ' ';
        if(!translations.isEmpty()){
            for(TB_Admissions_Content__c contact : translations){
                message = language == 'EN' ? message + contact.TB_Content_EN__c : message + contact.TB_Content_PL__c;
            }
            return  message;
        }
        else{
            return ex.getMessage();
        }
    }
    public class TB_CT_IMIntegrationException extends Exception {} 
}

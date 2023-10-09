/**
 * Created by Aneta on 30/08/2021.
 */

public without sharing class TB_NewAdmissionController {

    public static List<hed__Application__c> userApplications = new List<hed__Application__c>();
    public static List<TB_Admissions_Dictionary__c> limitsForOfferedProductGroup = new List<TB_Admissions_Dictionary__c>();
    public static List<TB_Admissions_Dictionary__c> limitsForOfferedProductCode = new List<TB_Admissions_Dictionary__c>();

    @AuraEnabled
    public static String getAllOfferedProducts(Boolean isTestContact) {
        List<OfferedProductWrapper> productWrappers = new List<OfferedProductWrapper>();
        for(TB_Offered_Product__c singleProduct : [
            SELECT
                Id, TB_Available_on_Portal__c,
                TB_PD_Available__c,
                TB_Consents_Bundle__c,
                TB_Test__c, TB_Hidden__c,
                TB_Campus_Name__c, TB_Product_Group__c,
                TB_Product_Code__c, TB_Academic_Year__c,
                TB_Course_PL__c, TB_Course_EN__c,
                TB_x_Level_of_Study_PL__c, TB_x_Level_of_Study_EN__c,
                TB_x_Mode_of_Study_PL__c, TB_x_Mode_of_Study_EN__c,
                TB_Speciality_PL__c, TB_Speciality_EN__c,
                TB_Specialisation_PL__c, TB_Specialisation_EN__c,
                TB_Path_PL__c, TB_Path_EN__c,
                TB_Description_PL__c, TB_Description_EN__c,
                TB_x_Product_Group_PL__c, TB_x_Product_Group_EN__c,
                TB_Short_Description_PL__c, TB_Short_Description_EN__c
            FROM TB_Offered_Product__c
            WHERE TB_Available_on_Portal__c = TRUE
            AND RecordTypeId =: TB_re_Constants.TB_OFFERED_PRODUCT_RT_STUDY
        ]) {
            if(isTestContact || (!singleProduct.TB_Hidden__c && !singleProduct.TB_Test__c)) {
                OfferedProductWrapper singleWrapper = new OfferedProductWrapper(singleProduct);
                productWrappers.add(singleWrapper);
            }
        }
       return JSON.serialize(productWrappers); 
    }

    @AuraEnabled
    public static String getHiddenOfferedProductWrapper(String offeredProductId) {
        TB_Offered_Product__c offeredProduct = getSingleOfferedProduct(offeredProductId);
        if(offeredProduct != null) {
            if(offeredProduct.TB_Available_on_Portal__c) {
                OfferedProductWrapper productWrapper = new OfferedProductWrapper(offeredProduct);
                return JSON.serialize(productWrapper);
            }else {
                return 'EMPTY.OFFERED_PRODUCT_NOT_AVAILABLE_ON_PORTAL';
            }
        }else {
            return 'EMPTY.OFFERED_PRODUCT_DOES_NOT_EXIST';
        }
    }

    private static TB_Offered_Product__c getSingleOfferedProduct(String offeredProductId) {
        try {
            TB_JSON_Wrapper__c jsonWrapper = [
                    SELECT TB_Wrapper_Value__c
                    FROM TB_JSON_Wrapper__c
                    WHERE TB_Object_Id__c = : (Id) offeredProductId
            ];
            return (TB_Offered_Product__c) JSON.deserialize(jsonWrapper.TB_Wrapper_Value__c, TB_Offered_Product__c.class);
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }
    
    @AuraEnabled
    public static String createNewApplication(String offeredProduct, String currentContact, Boolean isPdOptIn, Boolean fromHidden) {
        TB_Offered_Product__c product =
            (TB_Offered_Product__c) JSON.deserialize(offeredProduct, TB_Offered_Product__c.class);
        Contact applicantContact = (Contact) JSON.deserialize(currentContact, Contact.class);
        String offeredProductGroup = product.TB_Product_Group__c;
        String offeredProductId = product.Id;
        try {
            if(applicantContact.TB_Test__c) {
                return insertNewApplication(offeredProductId, applicantContact.Id, isPdOptIn, fromHidden);
            }else {
                userApplications = [
                    SELECT TB_Active__c, hed__Application_Status__c,
                        TB_Archived__c, TB_Product_Group__c, TB_Product_Code__c,
                        TB_Applying_To_Offered_Product__c, hed__Term__c
                    FROM hed__Application__c
                    WHERE hed__Applicant__c = :applicantContact.Id
                ];
                if (applicationValidationByProduct(offeredProductId)) {
                    prepareAdmissionsDictionaryLimits(product);
                    if (applicationValidationByProductGroupLimits(offeredProductGroup)) {
                        if(applicationValidationByProductCode(product.TB_Product_Code__c, product.TB_Academic_Year__c)) {
                            return insertNewApplication(offeredProductId, applicantContact.Id, isPdOptIn, fromHidden);
                        }else {
                            return 'NEW_ADMISSION.PRODUCT_CODE_LIMITS_VALIDATION.TOAST.EXCEPTION';
                        }
                    } else {
                        return 'NEW_ADMISSION.PRODUCT_LIMITS_VALIDATION.TOAST.EXCEPTION';
                    }
                } else {
                    return 'NEW_ADMISSION.ACTIVE_APPLICATION_VALIDATION.EXCEPTION';
                }
            }
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'NEW_ADMISSION.CREATE_NEW_ADMISSION.EXCEPTION';
        }
    }

    private static Id insertNewApplication(String offeredProductId, String applicantId, Boolean isPdOptIn, Boolean fromHidden) {
        hed__Application__c application = new hed__Application__c
            (
                TB_Applying_To_Offered_Product__c = offeredProductId,
                hed__Applicant__c = applicantId,
                TB_PD_Opt_In__c = isPdOptIn,
                TB_Created_From_Hidden__c = fromHidden
            );
        insert application;
        return application.Id;
    }

    private static Boolean applicationValidationByProduct(String offeredProductId) {
        for(hed__Application__c singleApplication : userApplications) {
            if(
                singleApplication.TB_Applying_To_Offered_Product__c == offeredProductId &&
                    isActiveApplication(singleApplication)
                ) {
                return false;
            }
        }
        return true;
    }

    private static Boolean applicationValidationByProductGroupLimits(String offeredProductGroup) {
        switch on limitsForOfferedProductGroup.size() {
            when 0 {
                return true;
            }
            when null {
                return true;
            }
            when else {
                return (getNumberOfApplicationsByGroup(offeredProductGroup) < limitsForOfferedProductGroup[0].TB_Limit__c);
            }
        }
    }

    private static Boolean applicationValidationByProductCode(String offeredProductCode, String academicYear) {
        switch on limitsForOfferedProductCode.size() {
            when 0 {
                return true;
            }
            when null {
                return true;
            }
            when else {
                return (getNumberOfApplicationsByProductCode(offeredProductCode, academicYear) < limitsForOfferedProductCode[0].TB_Limit__c);
            }
        }
    }

    private static Integer getNumberOfApplicationsByGroup(String offeredProductGroup) {
        List<hed__Application__c> filteredApplications = new List<hed__Application__c>();
        for(hed__Application__c singleApplication : userApplications) {
            if(
                singleApplication.TB_Product_Group__c == offeredProductGroup && isActiveApplication(singleApplication)
                ) {
                filteredApplications.add(singleApplication);
            }
        }
        return filteredApplications.size();
    }

    private static Integer getNumberOfApplicationsByProductCode(String offeredProductCode, String offeredProductAcademicYear) {
        List<hed__Application__c> filteredApplications = new List<hed__Application__c>();
        for(hed__Application__c singleApplication : userApplications) {
            if(
                singleApplication.TB_Product_Code__c.substring(2) == offeredProductCode.substring(2)
                    && isActiveApplication(singleApplication)
                    && singleApplication.hed__Term__c == offeredProductAcademicYear
                ) {
                filteredApplications.add(singleApplication);
            }
        }
        return filteredApplications.size();
    }

    private static Boolean isActiveApplication(hed__Application__c application) {
        return (application.TB_Active__c &&
            !(application.TB_Archived__c) &&
            !TB_re_Constants.TB_REJECTED_APPLICATIONS_STATUSES.contains(application.hed__Application_Status__c));
    }

    @AuraEnabled
    public static Boolean createConsentsForNewApplication(String applicationId, String admissionConsents, String communityUrl) {
        Set<TB_ConsentsController.AdmissionConsentsWrapper> wrappers;
        try {
            if(admissionConsents != null) {
                wrappers = (Set<TB_ConsentsController.AdmissionConsentsWrapper>) JSON.deserialize(admissionConsents, Set<TB_ConsentsController.AdmissionConsentsWrapper>.class);
            }else {
                return true;
            }
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return false;
        }

        List<TB_Consent__c> consents = new List<TB_Consent__c>();
        for (TB_ConsentsController.AdmissionConsentsWrapper singleWrapper : wrappers) {
            TB_Consent__c singleConsent = new TB_Consent__c(
                Name = singleWrapper.consent.Name,
                TB_Application__c = applicationId,
                TB_Effective_From__c = System.now(),
                TB_Source__c = communityUrl,
                TB_Source_Type__c = 'WWW',
                TB_Consent_Text_EN__c = singleWrapper.consent.TB_Description_EN__c,
                TB_Consent_Text_PL__c = singleWrapper.consent.TB_Description_PL__c,
                TB_Consent_Definition_Id__c = singleWrapper.consent.Id,
                TB_Consent_Type__c = singleWrapper.consent.TB_Consent_Type__c,
                TB_Status__c = getStatusForConsent(singleWrapper)
            );
            consents.add(singleConsent);
        }
        try {
            insert consents;
            return true;
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return false;
        }
    }

    private static String getStatusForConsent(TB_ConsentsController.AdmissionConsentsWrapper singleWrapper) {
        switch on singleWrapper.consent.TB_Consent_Type__c {
            when 'Informational' {
                return 'Seen';
            }
            when 'Marketing' , 'Terms and Conditions' {
               return singleWrapper.value ? 'Opt_In' : 'Lack';
            }
        }
        return null;
    }

    private static void prepareAdmissionsDictionaryLimits(TB_Offered_Product__c product) {
        for (TB_JSON_Wrapper__c jsonWrapper : [
            SELECT TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_API_Name__c =: TB_re_Constants.TB_OBJECT_API_NAME_ADMISSIONS_DICTIONARY
            AND TB_Record_Type_Dev_Name__c =: TB_re_Constants.ADMISSIONS_DICTIONARY_RT_ADMISSIONS_LIMIT_DEVNAME
        ])
        { 
            TB_Admissions_Dictionary__c singleAdmissionsLimit
                = (TB_Admissions_Dictionary__c) JSON.deserialize(jsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if (singleAdmissionsLimit.TB_Product_Group__c == product.TB_Product_Group__c) {
                limitsForOfferedProductGroup.add(singleAdmissionsLimit);
            }else if(product.TB_Product_Code__c != null
                    && singleAdmissionsLimit.TB_Offered_Product_Code__c == product.TB_Product_Code__c.substring(2)
                    && singleAdmissionsLimit.TB_Academic_Year__c == product.TB_Academic_Year__c
                ){
                limitsForOfferedProductCode.add(singleAdmissionsLimit);
            }
        }
    }

    @AuraEnabled
    public static Boolean canApplicantApply(Id contactId) {
        try {
            Contact applicant = [
                SELECT Id, TB_x_Address_Information__c, TB_x_Personal_Information__c
                FROM Contact
                WHERE Id = :contactId
            ];
            return applicant != null ? applicant.TB_x_Address_Information__c && applicant.TB_x_Personal_Information__c : false;
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return false;
        }
    }

    public class OfferedProductWrapper
    {
        @AuraEnabled public TB_Offered_Product__c pro {get;set;}
        public OfferedProductWrapper(TB_Offered_Product__c offeredProduct) {
            this.pro = offeredProduct;
        }
    }

}
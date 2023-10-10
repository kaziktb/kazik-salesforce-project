/**
 * Created by adriangawryszewski on 12/17/21.
 */

 public with sharing class TB_VDOExportDataPrep {


    private static List<hed__Application__c> vDOExportDataPrep(List<String> appIdsToExport) {
        return [
                SELECT Id,
                        TB_Active__c,
                        TB_Test__c,
                        Name,
                        hed__Applicant__c,
                        hed__Applicant__r.TB_IM_Id__c,
                        hed__Applicant__r.DT_VDO_ID__c,
                        hed__Applicant__r.TB_Customer_Id__c,
                        TB_Applying_To_Offered_Product__r.TB_VDO_Id__c,
                        TB_Applying_To_Offered_Product__r.TB_VDO_Study_Id__c,
                        hed__Applicant__r.FirstName,
                        hed__Applicant__r.LastName,
                        hed__Applicant__r.MiddleName,
                        TB_x_Applicant_Gender_EN__c,
                        TB_x_Mother_Full_Name__c,
                        TB_x_Father_Full_Name__c,
                        TB_x_Applicant_City_or_Village_EN__c,
                        hed__Applicant__r.Birthdate,
                        hed__Applicant__r.DT_Place_of_Birth__c,
                        hed__Applicant__r.DT_Country_of_Birth__c,
                        TB_Applicant_Citizenship__c,
                        hed__Applicant__r.TB_Family_Name__c,
                        hed__Applicant__r.DT_PESEL__c,
                        TB_Tuition_Instalment__c,
                        TB_Tuition_Fee_Currency__c,
                        hed__Application_Decision_Date__c,
                        TB_Resignation_Date__c,
                        TB_Tuition_Bank_Account_PLN__c,
                        TB_Tuition_Bank_Account_EUR__c,
                        hed__Applicant__r.hed__AlternateEmail__c,
                        hed__Applicant__r.hed__UniversityEmail__c,
                        hed__Applicant__r.hed__WorkEmail__c,
                        TB_Applicant_Phone__c,
                        TB_Applying_To_Offered_Product__r.TB_Starting_Semester__r.Name,
                        TB_Semester__c,
                        TB_Medical_Certificate_Valid_To__c,
                        hed__Applicant__r.TB_ICE_Contact_Person__c,
                        hed__Applicant__r.TB_ICE_Contact_Phone__c,
                        TB_Decision_Basis_Formula__c,
                        TB_Tuition_Fee_Discount_Amount__c,
                        hed__Applicant__r.DT_Document_Issue_Date__c,
                        hed__Applicant__r.DT_Document_Issuing_Country__c,
                        hed__Applicant__r.DT_Document_Series_and_Number__c,
                        hed__Applicant__r.DT_Document_Issuing_Authority__c,
                        hed__Applicant__r.DT_Document_Validity_Date__c,
                        hed__Applicant__r.DT_Type_of_Identity_Document__c,
                        hed__Applicant__r.MailingCity,
                        hed__Applicant__r.MailingState,
                        hed__Applicant__r.MailingCountry,
                        hed__Applicant__r.MailingPostalCode,
                        hed__Applicant__r.MailingStreet,
                        hed__Applicant__r.OtherCity,
                        hed__Applicant__r.OtherState,
                        hed__Applicant__r.OtherCountry,
                        hed__Applicant__r.OtherPostalCode,
                        hed__Applicant__r.OtherStreet,
                        hed__Applicant__r.TB_Pole_s_Card__c,
                        hed__Applicant__r.Individual.TB_Global_Id__c,
                        hed__Applicant__r.Individual.TB_VDO_Id__c,
                        hed__Applicant__r.Individual.TB_Student_IM_Id__c,
                        hed__Application_Status__c,
                        TB_Level_of_Study__c,
                        TB_Tuition_Fee_Discount_Percent__c,
                        TB_Discount_Type__r.Name,
                        TB_Discount_Type__r.TB_Discount_Direction__c,
                        TB_Discount_Type__r.TB_Discount_Calculation_Method__c,
                        TB_Discount_Type__r.TB_Discount_Type__c,
                        TB_Agreement_Concluded_Date__c,
                        TB_Agreement_Type__c,
                        TB_Agreement__r.Name,
                        TB_Agreement__r.TB_Content_Version_Id__c,
                        hed__Term__r.Name,
                        TB_Initial_Creation_Date_Time__c,
            			TB_Moodle_Language_Placement_Result__c,
            			TB_Moodle_Placement_Test_Level__c,
            			TB_Language_Course_1__c,
            			TB_Language_Course_2__c,
                        TB_Conditional_Admission_2nd_Guest__c, (
                        SELECT Id,
                                RecordTypeId,
                                TB_Educational_Institution__c,
                                TB_Issue_Date__c,
                                TB_Document_Issue_City__c,
                                TB_Document_Number__c,
                                TB_Regional_Examination_Board__r.TB_OKE_Code__c,
                                TB_Educational_Institution_City__c,
                                TB_Educational_Institution_Country__c,
                                TB_HS_Exam_Type__r.Name,
                                TB_Course__c,
                                TB_Defense_of_Thesis_Date_Declared__c,
                                TB_Academic_Title__c,
                                TB_PD_Module_Name_PL__c,
                                TB_PD_Subject__c,
                                TB_Hours__c,
                                TB_ECTS__c,
                                TB_Score__c,
                             	TB_HS_Exam_Country__c 
                        FROM TB_Experience_History__r
                ), (
                        SELECT Id,
                                TB_Consent_Text_EN__c,
                                TB_Consent_Text_PL__c,
                                TB_Effective_From__c,
                                Name,
                                TB_Source_Type__c,
                                TB_Status__c,
                                TB_Consent_Type__c,
                                TB_Communication_Channel__c
                        FROM Consents__r
                ), (
                        SELECT Id,
                                TB_Document_Category__c,
                                TB_Content_Version_Id__c,
                                Name
                        FROM TB_Application_Documents__r
                )
                FROM hed__Application__c
                WHERE Id IN :appIdsToExport
        ];
    }

    @InvocableMethod(Label='handleExport')
    public static void handleApplicationVDOExport(List<String> appIdsToExport) {
        insertVDOExportData(appIdsToExport);
    }

    public static void insertVDOExportData(List<String> appIdsToExport) {
        List<hed__Application__c> appsToExport = vDOExportDataPrep(appIdsToExport);
        if (!appsToExport.isEmpty() && appsToExport != null) {
            List<TB_Communication_Event__c> outboundCommEvents = new List<TB_Communication_Event__c>();
            for (hed__Application__c app : appsToExport) {
                outboundCommEvents.add(
                        createOutboundCommunicationEvent(app)
                );
            }

            try {
                insert outboundCommEvents;
            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e, TB_VDOExportDataPrep.class);
            }
        }
    }

    private static TB_Communication_Event__c createOutboundCommunicationEvent(hed__Application__c app) {
        String key = '' + String.valueOf(app.Name) + String.valueOf(Datetime.now());
        String eventKey = hash('MD5', app.Name + String.valueOf(Datetime.now()));
        return TB_CommunicationEventUtils.registerOutboundCommunicationEvent(
                TB_Constants.TB_SWPS_PROXY_LABEL,
                app.Id,
                TB_Constants.TB_APPLICATION_LABEL,
                null,
                null,
                buildMainExportBodyJSON(app, eventKey),
                null,
                null,
                eventKey
        );

    }

    private static String buildMainExportBodyJSON(hed__Application__c app, String eventKey) {

        TB_SWPSProxyModel.VDOExport vdoExportJSON = new TB_SWPSProxyModel.VDOExport();
        vdoExportJSON.eventId = eventKey;
        vdoExportJSON.photo = getPhotoId(app);
        vdoExportJSON.photoName = getPhotoName(app);
        vdoExportJSON.candidateId = app.hed__Applicant__c;
        vdoExportJSON.applicationId = app.Id;
        vdoExportJSON.applicationNumber = app.Name;
        vdoExportJSON.IMId = app.hed__Applicant__r.Individual.TB_Student_IM_Id__c;
        vdoExportJSON.VDOId = app.hed__Applicant__r.Individual.TB_VDO_Id__c;
        vdoExportJSON.globalId = app.hed__Applicant__r.Individual.TB_Global_Id__c;
        vdoExportJSON.contractorId = app.hed__Applicant__r.TB_Customer_Id__c;
        if (app.TB_Applying_To_Offered_Product__r.TB_VDO_Id__c != null) {
            vdoExportJSON.processRecruitmentId = Integer.valueOf(app.TB_Applying_To_Offered_Product__r.TB_VDO_Id__c.substringBefore('-'));
        }
        if (app.TB_Applying_To_Offered_Product__r.TB_VDO_Study_Id__c != null) {
            vdoExportJSON.specializationId = Integer.valueOf(app.TB_Applying_To_Offered_Product__r.TB_VDO_Study_Id__c);
        }
        vdoExportJSON.firstName = app.hed__Applicant__r.FirstName;
        vdoExportJSON.lastName = app.hed__Applicant__r.LastName;
        vdoExportJSON.secondName = app.hed__Applicant__r.MiddleName;
        vdoExportJSON.gender = app.TB_x_Applicant_Gender_EN__c;
        vdoExportJSON.motherName = app.TB_x_Mother_Full_Name__c;
        vdoExportJSON.fatherName = app.TB_x_Father_Full_Name__c;
        vdoExportJSON.birthdate = app.hed__Applicant__r.Birthdate;
        vdoExportJSON.birthPlace = app.hed__Applicant__r.DT_Place_of_Birth__c;
        //SWPS countryOrigin = Country of birth
        vdoExportJSON.countryOrigin = app.hed__Applicant__r.DT_Country_of_Birth__c;
        vdoExportJSON.citizenship = app.TB_Applicant_Citizenship__c;
        vdoExportJSON.familyName = app.hed__Applicant__r.TB_Family_Name__c;
        vdoExportJSON.PESEL = app.hed__Applicant__r.DT_PESEL__c;
        vdoExportJSON.installmentSystem = app.TB_Tuition_Instalment__c != null ? app.TB_Tuition_Instalment__c : '0';
        vdoExportJSON.paymentCurrency = app.TB_Tuition_Fee_Currency__c;
        vdoExportJSON.dateAdmission = app.hed__Application_Decision_Date__c;
        vdoExportJSON.dateRegistration = app.TB_Initial_Creation_Date_Time__c;
        vdoExportJSON.subAccountPLN = app.TB_Tuition_Bank_Account_PLN__c;
        vdoExportJSON.subAccountEUR = app.TB_Tuition_Bank_Account_EUR__c;
        vdoExportJSON.emailStudent = app.hed__Applicant__r.hed__UniversityEmail__c;
        vdoExportJSON.emailWorker = app.hed__Applicant__r.hed__WorkEmail__c;
        vdoExportJSON.emailPrivate = app.hed__Applicant__r.hed__AlternateEmail__c;
        vdoExportJSON.phonePrivate = app.TB_Applicant_Phone__c;
        vdoExportJSON.semesterName = app.TB_Applying_To_Offered_Product__r.TB_Starting_Semester__r.Name;
        vdoExportJSON.semester = Integer.valueOf(app.TB_Semester__c);
        vdoExportJSON.ICEPerson = app.hed__Applicant__r.TB_ICE_Contact_Person__c;
        vdoExportJSON.ICEPhone = app.hed__Applicant__r.TB_ICE_Contact_Phone__c;
        vdoExportJSON.decisionBasis = app.TB_Decision_Basis_Formula__c;
        vdoExportJSON.cityOrVillage = app.TB_x_Applicant_City_or_Village_EN__c;
        vdoExportJSON.medicalExamination = app.TB_Medical_Certificate_Valid_To__c;
        vdoExportJSON.identification = composeIdentityDocumentElement(app);
        vdoExportJSON.polishCard = app.hed__Applicant__r.TB_Pole_s_Card__c;
        vdoExportJSON.addressCorrespondences = composeCorrespondenceAddress(app);
        vdoExportJSON.addressResidences = composeResidenceAddress(app);
        vdoExportJSON.schoolHigh = composeHighSchool(app);
        vdoExportJSON.SchoolCollege = composeCollegeSchool(app);
        vdoExportJSON.differencesProgram = composeProgramDifferences(app);
        vdoExportJSON.conditional = composeDecisionBasis(app);
        vdoExportJSON.englishTest = composeEnglishTest(app);
        vdoExportJSON.marketingConsents = composeMarketingConsents(app);
        vdoExportJSON.phdSupervisor = null;
        vdoExportJSON.discount = composeDiscounts(app);
        vdoExportJSON.studyAgreement = composeStudyAgreement(app);
        vdoExportJSON.studyLevel = app.TB_Level_of_Study__c;

        return JSON.serialize(vdoExportJSON);
    }

    private static TB_SWPSProxyModel.Identification composeIdentityDocumentElement(hed__Application__c app) {
        return new TB_SWPSProxyModel.Identification(
                app.hed__Applicant__r.DT_Document_Issue_Date__c,
                app.hed__Applicant__r.DT_Document_Issuing_Country__c,
                app.hed__Applicant__r.DT_Document_Series_and_Number__c,
                app.hed__Applicant__r.DT_Document_Issuing_Authority__c,
                app.hed__Applicant__r.DT_Document_Validity_Date__c,
                app.hed__Applicant__r.DT_Type_of_Identity_Document__c
        );
    }

    private static TB_SWPSProxyModel.AddressCorrespondences composeCorrespondenceAddress(hed__Application__c app) {
        return new TB_SWPSProxyModel.AddressCorrespondences(
                app.hed__Applicant__r.MailingCity,
                app.hed__Applicant__r.MailingState,
                app.hed__Applicant__r.MailingCountry,
                app.hed__Applicant__r.MailingPostalCode,
                app.hed__Applicant__r.MailingStreet
        );
    }

    private static TB_SWPSProxyModel.AddressResidences composeResidenceAddress(hed__Application__c app) {
        return new TB_SWPSProxyModel.AddressResidences(
                app.hed__Applicant__r.OtherCity,
                app.hed__Applicant__r.OtherState,
                app.hed__Applicant__r.OtherCountry,
                app.hed__Applicant__r.OtherPostalCode,
                app.hed__Applicant__r.OtherStreet
        );
    }

    private static TB_SWPSProxyModel.SchoolHigh composeHighSchool(hed__Application__c app) {
        TB_SWPSProxyModel.SchoolHigh highSchool;
        for (TB_Experience_History__c exp : app.TB_Experience_History__r) {
            if (exp.RecordTypeId == TB_Constants.TB_EDUCATION_EXP_HS_EXAM_METRIC_RT_ID) {
                highSchool = new TB_SWPSProxyModel.SchoolHigh(
                        exp.TB_Educational_Institution__c,
                        exp.TB_Issue_Date__c,
                        exp.TB_Document_Issue_City__c,
                        exp.TB_Document_Number__c,
                        exp.TB_Regional_Examination_Board__r.TB_OKE_Code__c,
                        exp.TB_Educational_Institution_City__c,
                        exp.TB_Educational_Institution_Country__c,
                        exp.TB_HS_Exam_Type__r.Name,
                    	exp.TB_HS_Exam_Country__c 
                );
            }
        }
        return highSchool;
    }

    private static List<TB_SWPSProxyModel.SchoolCollege> composeCollegeSchool(hed__Application__c app) {
        List<TB_SWPSProxyModel.SchoolCollege> higherEdu;
        for (TB_Experience_History__c exp : app.TB_Experience_History__r) { // sprawdź pola
            if (exp.RecordTypeId == TB_Constants.TB_EDUCATION_EXP_HIGHER_EDUCATION_RT_ID
                    || exp.RecordTypeId == TB_Constants.TB_EDUCATION_EXP_POSTGRAD_EDUCATION_RT_ID
                    || exp.RecordTypeId == TB_Constants.TB_EDUCATION_EXP_COURSE_AND_TRAIN_RT_ID) {
                if (higherEdu == null) {
                    higherEdu = new List<TB_SWPSProxyModel.SchoolCollege>{
                            new TB_SWPSProxyModel.SchoolCollege(
                                    exp.TB_Educational_Institution__c,
                                    exp.TB_Educational_Institution_City__c,
                                    exp.TB_Course__c,
                                    exp.TB_Document_Number__c,
                                    exp.TB_Issue_Date__c,
                                    exp.TB_Defense_of_Thesis_Date_Declared__c,
                                    exp.TB_Academic_Title__c,
                                    exp.TB_Educational_Institution_Country__c
                            )
                    };
                } else {
                    higherEdu.add(new TB_SWPSProxyModel.SchoolCollege(
                            exp.TB_Educational_Institution__c,
                            exp.TB_Educational_Institution_City__c,
                            exp.TB_Course__c,
                            exp.TB_Document_Number__c,
                            exp.TB_Issue_Date__c,
                            exp.TB_Defense_of_Thesis_Date_Declared__c,
                            exp.TB_Academic_Title__c,
                            exp.TB_Educational_Institution_Country__c
                    ));
                }
            }
        }

        return higherEdu;
    }

    private static List<TB_SWPSProxyModel.DifferencesProgram> composeProgramDifferences(hed__Application__c app) {
        List<TB_SWPSProxyModel.DifferencesProgram> programDifferences;
        for (TB_Experience_History__c exp : app.TB_Experience_History__r) {
            if (exp.RecordTypeId == TB_Constants.TB_PD_DIFFERENCES_EXP_RT_ID) {
                if (programDifferences == null) {
                    programDifferences = new List<TB_SWPSProxyModel.DifferencesProgram>{
                            new TB_SWPSProxyModel.DifferencesProgram(
                                    exp.TB_PD_Subject__c,
                                    exp.TB_PD_Module_Name_PL__c,
                                    Integer.valueOf(exp.TB_Hours__c),
                                    Integer.valueOf(exp.TB_ECTS__c),
                                    null,
                                    String.valueOf(exp.TB_Score__c),
                                    exp.TB_Educational_Institution__c
                            )
                    };
                } else {
                    programDifferences.add(new TB_SWPSProxyModel.DifferencesProgram(
                            exp.TB_PD_Subject__c,
                            exp.TB_PD_Module_Name_PL__c,
                            Integer.valueOf(exp.TB_Hours__c),
                            Integer.valueOf(exp.TB_ECTS__c),
                            null,
                            String.valueOf(exp.TB_Score__c),
                            exp.TB_Educational_Institution__c
                    ));
                }
            }
        }

        return programDifferences;
    }

    private static TB_SWPSProxyModel.Conditional composeDecisionBasis(hed__Application__c app) {

        return new TB_SWPSProxyModel.Conditional(
                app.hed__Application_Status__c == TB_Constants.TB_APPLICATION_STATUS_CONDITIONALLY_ACCEPTED,
                app.TB_Conditional_Admission_2nd_Guest__c
        );
    }

    private static TB_SWPSProxyModel.EnglishTest composeEnglishTest(hed__Application__c app) {
        return new TB_SWPSProxyModel.EnglishTest(
        	app.TB_Moodle_Language_Placement_Result__c,
            app.TB_Moodle_Placement_Test_Level__c,
            app.TB_Language_Course_1__c
        );
        
    }

    private static List<TB_SWPSProxyModel.MarketingConsents> composeMarketingConsents(hed__Application__c app) {
        List<TB_SWPSProxyModel.MarketingConsents> consents;
        if (app.Consents__r != null && !app.Consents__r.isEmpty()) {
            for (TB_Consent__c con : app.Consents__r) {
                if (con.TB_Consent_Type__c == 'Marketing'
                        && con.TB_Status__c == 'Signed') {
                    if (consents == null) {
                        consents = new List<TB_SWPSProxyModel.MarketingConsents>{
                                new TB_SWPSProxyModel.MarketingConsents(
                                        con.TB_Communication_Channel__c,
                                        String.valueOf(true),
                                        con.Name,
                                        Date.valueOf(con.TB_Effective_From__c),
                                        con.TB_Consent_Text_PL__c,
                                        con.TB_Consent_Text_EN__c
                                )
                        };
                    } else {
                        consents.add(
                                new TB_SWPSProxyModel.MarketingConsents(
                                        con.TB_Source_Type__c,
                                        String.valueOf(con.TB_Status__c == TB_Constants.TB_SIGNED_CONSENT ? true : false),
                                        con.Name,
                                        Date.valueOf(con.TB_Effective_From__c),
                                        con.TB_Consent_Text_PL__c,
                                        con.TB_Consent_Text_EN__c
                                )
                        );
                    }
                }
            }
        }
        return consents;
    }

    private static TB_SWPSProxyModel.Discount composeDiscounts(hed__Application__c app) {
        return new TB_SWPSProxyModel.Discount(
                app.TB_Discount_Type__r.Name,
                app.TB_Discount_Type__r.TB_Discount_Type__c,
                app.TB_Discount_Type__r.TB_Discount_Calculation_Method__c,
                app.TB_Discount_Type__r.TB_Discount_Direction__c,
                app.TB_Tuition_Fee_Discount_Amount__c,
                app.TB_Tuition_Fee_Discount_Percent__c
        );
    }

    private static TB_SWPSProxyModel.StudyAgreement composeStudyAgreement(hed__Application__c app) {
        return new TB_SWPSProxyModel.StudyAgreement(
                app.hed__Term__r.Name,
                app.TB_Agreement_Type__c,
                app.TB_Agreement_Concluded_Date__c,
                app.TB_Agreement__r.Name,
                app.TB_Agreement__r.TB_Content_Version_Id__c
        );
    }

    private static String getPhotoId(hed__Application__c app) {
        for (TB_Application_Document__c doc : app.TB_Application_Documents__r) {
            if (doc.TB_Document_Category__c == 'Photo') {
                return doc.TB_Content_Version_Id__c;
            }
        }
        return null;
    }

    private static String getPhotoName(hed__Application__c app) {
        for (TB_Application_Document__c doc : app.TB_Application_Documents__r) {
            if (doc.TB_Document_Category__c == 'Photo') {
                return doc.Name;
            }
        }
        return null;
    }

    private static String hash(String algorithmName, String input) {
        return EncodingUtil.convertToHex(Crypto.generateDigest(algorithmName, Blob.valueOf(input)));
    }

}

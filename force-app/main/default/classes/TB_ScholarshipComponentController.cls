///**
// * Created by annaseveryna on 19/11/2021.
// */

public with sharing class TB_ScholarshipComponentController {
    private static final String NULL_EXCEPTION_MESSAGE = 'Parameters cannot be null';
    private static final Date CURRENT_DATE = Test.isRunningTest() ? Date.newInstance(2021, 11, 20) : Date.today();

    @AuraEnabled
    public static List<TB_Admissions_Dictionary__c> matchScholarships(String apId) {
        List<TB_Admissions_Dictionary__c> allActiveScholarships = getScholarships();
        hed__Application__c application = [
                SELECT Id, Name, TB_Applicant_Citizenship__c, TB_Level_of_Study__c, TB_HS_Exam_Date__c,
                        TB_HS_Exam_Score_Top_3__c, TB_Applying_To_Offered_Product__c, TB_Campus__r.Name,
                        TB_Faculty__r.Name, TB_Applying_To_Offered_Product__r.Name, TB_Mode_of_Study__c,
                        TB_HS_Exam_Type__c
                FROM hed__Application__c
                WHERE Id = :apId
        ];
        List<TB_Admissions_Dictionary__c> matchedScholarships = new List<TB_Admissions_Dictionary__c>();
        Set<TB_Admissions_Dictionary__c> scholarshipsMatchedAssignments = matchedWithAssignments(allActiveScholarships, application);

        for (TB_Admissions_Dictionary__c scholarship : scholarshipsMatchedAssignments) {
            if (matchesDates(scholarship)
                    && matchesModeOfStudy(scholarship, application)
                    && matchesCitizenship(scholarship, application)
                    && matchesLevelOfStudy(scholarship, application)
                    && matchesHSExamDate(scholarship, application)
                    && matchesHSExamPoints(scholarship, application)
                    && matchesHSExamType(scholarship, application)) {
                matchedScholarships.add(scholarship);
            }
        }
        return matchedScholarships;
    }

    @AuraEnabled
    public static TB_Admissions_Dictionary__c loadSelectedPreviouslyScholarship(Id applicationId) {
        hed__Application__c application = [SELECT Id, TB_Scholarship__c FROM hed__Application__c WHERE Id = :applicationId];
        if (!String.isBlank(application.TB_Scholarship__c)) {
            TB_JSON_Wrapper__c scholarshipJSON = [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c = :application.TB_Scholarship__c];
            TB_Admissions_Dictionary__c scholarship = (TB_Admissions_Dictionary__c) JSON.deserialize(scholarshipJSON.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            return scholarship;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static void updateSelectedScholarship(Id scholarshipId, Id applicationId, String taxOfficeName, String taxOfficeAddress) {
        if (applicationId != null) {
            update new hed__Application__c (
                    Id = applicationId,
                    TB_Scholarship__c = scholarshipId,
                    TB_Scholarship_Status__c = (scholarshipId != null) ? 'Requested' : null,
                    TB_Tax_Office_Name__c = taxOfficeName,
                    TB_Tax_Office_Address__c = taxOfficeAddress
            );
        } else {
            throw new AuraHandledException(NULL_EXCEPTION_MESSAGE);
        }
    }

    @AuraEnabled
    public static List<TB_Application_Document__c> createApplicationDocumentsForUpload(Id applicationId, Id scholarshipId) {
        try {
            hed__Application__c application = [SELECT hed__Applicant__c FROM hed__Application__c WHERE Id = :applicationId];
            TB_JSON_Wrapper__c scholarshipJSON = [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c = :scholarshipId];
            TB_Admissions_Dictionary__c scholarship = (TB_Admissions_Dictionary__c) JSON.deserialize(scholarshipJSON.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            List<TB_Application_Document__c> applicationDocuments = new List<TB_Application_Document__c>();
            if (scholarship.TB_Request__c) {
                applicationDocuments.add(new TB_Application_Document__c(
                    TB_Application__c = applicationId,
                    TB_Active__c = true,
                    TB_Contact__c = application.hed__Applicant__c,
                    TB_Document_Type__c = 'Scan',
                    TB_Citizenship_Dependency__c = 'Everyone',
                    TB_Order__c = 1000,
                    TB_Output_Format__c = 'Original',
                    TB_Document_Category__c = 'Application_Request'
                ));
            }
            if (scholarship.TB_Contest_Entry__c) {
                applicationDocuments.add(new TB_Application_Document__c(
                    TB_Application__c = applicationId,
                    TB_Active__c = true,
                    TB_Contact__c = application.hed__Applicant__c,
                    TB_Document_Type__c = 'Scan',
                    TB_Document_Category__c = 'Contest_Entry'
                ));
            }
            insert applicationDocuments;

            return [SELECT Id, TB_Document_File_Name__c, TB_Document_Category__c FROM TB_Application_Document__c WHERE Id IN :applicationDocuments];

        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    private static List<TB_Admissions_Dictionary__c> getScholarships() {
        List<TB_JSON_Wrapper__c> scholarshipsJSON = [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = 'TB_Admissions_Dictionary__c' AND TB_Record_Type_Dev_Name__c = 'TB_Scholarship'
        ];
        List<TB_Admissions_Dictionary__c> activeScholarships = new List<TB_Admissions_Dictionary__c>();
        for (TB_JSON_Wrapper__c serializedScholarship : scholarshipsJSON) {
            TB_Admissions_Dictionary__c scholarship = (TB_Admissions_Dictionary__c) JSON.deserialize(serializedScholarship.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if (scholarship.TB_Active__c) {
                activeScholarships.add(scholarship);
            }
        }
        return activeScholarships;
    }

    @AuraEnabled
    public static List<TB_Application_Document__c> scholarshipApplicationDocuments(Id applicationId) {
        List<TB_Application_Document__c> requestDocuments = [
                SELECT Name, TB_Download_URL__c, TB_Document_Category__c
                FROM TB_Application_Document__c
                WHERE TB_Application__c = :applicationId
                AND TB_Document_Category__c = 'Application_Request'
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        List<TB_Application_Document__c> contestEntryDocuments = [
                SELECT Name, TB_Download_URL__c, TB_Document_Category__c
                FROM TB_Application_Document__c
                WHERE TB_Application__c = :applicationId
                AND TB_Document_Category__c = 'Contest_Entry'
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        List<TB_Application_Document__c> documents = new List<TB_Application_Document__c>();
        if (requestDocuments.size() > 0) {
            documents.add(requestDocuments[0]);
        }
        if (contestEntryDocuments.size() > 0) {
            documents.add(contestEntryDocuments[0]);
        }
        return documents;
    }

    private static Set<TB_Admissions_Dictionary__c> matchedWithAssignments(List<TB_Admissions_Dictionary__c> allActiveScholarships, hed__Application__c application) {
        List<TB_JSON_Wrapper__c> assignmentsJSON = [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Record_Type_Dev_Name__c = 'TB_Scholarship_Assignment'];
        Map<Id, TB_Admissions_Dictionary__c> idToAllActiveScholarships = new Map<Id, TB_Admissions_Dictionary__c>(allActiveScholarships);
        List<TB_Admissions_Dictionary__c> assignments = new List<TB_Admissions_Dictionary__c>();
        for (TB_JSON_Wrapper__c assignmentJSON : assignmentsJSON) {
            TB_Admissions_Dictionary__c assignment = (TB_Admissions_Dictionary__c) JSON.deserialize(assignmentJSON.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if (idToAllActiveScholarships.containsKey(assignment.TB_Scholarship__c) && assignment.TB_Active__c) {
                assignments.add(assignment);
            }
        }
        Set<Id> scholarshipsWithAssignments = new Set<Id>();
        Set<Id> scholarshipsMatchedAssignments = new Set<Id>();
        for (TB_Admissions_Dictionary__c assignment : assignments) {
            scholarshipsWithAssignments.add(assignment.TB_Scholarship__c);
            if ((assignment.TB_Campus__c == null || assignment.TB_Campus__c == application.TB_Campus__c)
                    && (assignment.TB_Faculty__c == null || assignment.TB_Faculty__c == application.TB_Faculty__c)
                    && (assignment.TB_Offered_Product__c == null || assignment.TB_Offered_Product__c == application.TB_Applying_To_Offered_Product__c)) {
                scholarshipsMatchedAssignments.add(assignment.TB_Scholarship__c);
            }
        }
        Set<TB_Admissions_Dictionary__c> scholarshipsForNextCheck = new Set<TB_Admissions_Dictionary__c>();
        for (TB_Admissions_Dictionary__c activeScholarship : allActiveScholarships) {
            if (scholarshipsMatchedAssignments.contains(activeScholarship.Id)) {
                scholarshipsForNextCheck.add(activeScholarship);
            }
            if (!scholarshipsWithAssignments.contains(activeScholarship.Id)) {
                scholarshipsForNextCheck.add(activeScholarship);
            }
        }
        return scholarshipsForNextCheck;
    }

    private static Boolean matchesDates(TB_Admissions_Dictionary__c scholarship) {
        return scholarship.TB_Valid_From__c <= CURRENT_DATE && scholarship.TB_Valid_To__c >= CURRENT_DATE;
    }

    private static Boolean matchesModeOfStudy(TB_Admissions_Dictionary__c scholarship, hed__Application__c application) {
        return (scholarship.TB_Mode_of_Study__c == null) || (application.TB_Mode_of_Study__c != null && scholarship.TB_Mode_of_Study__c.contains(application.TB_Mode_of_Study__c));
    }

    private static Boolean matchesCitizenship(TB_Admissions_Dictionary__c scholarship, hed__Application__c application) {
        return (application.TB_Applicant_Citizenship__c != null) && (scholarship.TB_Citizenships__c == null
                || scholarship.TB_Citizenships__c == 'Everyone'
                || (scholarship.TB_Citizenships__c == 'Polish_Citizens' && application.TB_Applicant_Citizenship__c == 'Poland')
                || (scholarship.TB_Citizenships__c == 'Non_Polish_Citizens' && application.TB_Applicant_Citizenship__c != 'Poland'));
    }

    private static Boolean matchesLevelOfStudy(TB_Admissions_Dictionary__c scholarship, hed__Application__c application) {
        return (scholarship.TB_Level_of_Study__c == null) || (application.TB_Level_of_Study__c != null && scholarship.TB_Level_of_Study__c.toLowerCase().contains(application.TB_Level_of_Study__c.toLowerCase()));
    }

    private static Boolean matchesHSExamDate(TB_Admissions_Dictionary__c scholarship, hed__Application__c application) {
        return (scholarship.TB_HS_Exam_Date_From__c == null) || (application.TB_HS_Exam_Date__c != null && scholarship.TB_HS_Exam_Date_From__c <= application.TB_HS_Exam_Date__c);
    }

    private static Boolean matchesHSExamPoints(TB_Admissions_Dictionary__c scholarship, hed__Application__c application) {
        return (scholarship.TB_HS_Exam_Min_Points__c == null) || (application.TB_HS_Exam_Score_Top_3__c != null && scholarship.TB_HS_Exam_Min_Points__c <= application.TB_HS_Exam_Score_Top_3__c);
    }

    private static Boolean matchesHSExamType(TB_Admissions_Dictionary__c scholarship, hed__Application__c application) {
        return (scholarship.TB_High_School_Exams__c == null) || (application.TB_HS_Exam_Type__c != null && scholarship.TB_High_School_Exams__c.toLowerCase().contains(application.TB_HS_Exam_Type__c.toLowerCase()));
    }
}
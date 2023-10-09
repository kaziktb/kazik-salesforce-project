/**
 * Created by annaseveryna on 17/02/2022.
 */

public with sharing class TB_QualificationExamProtocolController {
    public static final String URL_PARAMETER_APPLICATION_ID = 'c__id';
    public static final String URL_PARAMETER_QUALIFICATION = 'c__qua';
    private hed__Application__c application;

    public List<QualificationsWrapper> getQualifications() {
        try {
            List<Id> qualificationIds = getQualificationIds();
            List<TB_Application_Qualification__c> qualifications = [
                    SELECT TB_Qualification_Requirement_Item_Term__r.Name, TB_Qualification_Requirement_Item_Term__r.TB_Start__c,
                            TB_Qualification_Requirement_Item_Term__r.TB_End__c, TB_x_Qualification_Decision_Status_PL__c,
                            TB_Qualification_Requirement_Name__c, TB_Presence_Status__c, (
                            SELECT TB_Evaluation_Category_Name_PL__c, TB_Max_Points__c, TB_Evaluation_Points__c,
                                    TB_Admissions_Committee__c
                            FROM TB_Application_Evaluations__r
                    )
                    FROM TB_Application_Qualification__c
                    WHERE Id IN :qualificationIds
            ];
            Map<Id, Set<String>> qualificationIdToMembersNames = qualificationIdToMembersNames(qualifications);
            return createWrappers(qualifications, qualificationIdToMembersNames);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_QualificationExamProtocolController.class);
            return null;
        }
    }

    public hed__Application__c getApplication() {
        Id applicationId = ApexPages.currentPage().getParameters().get(URL_PARAMETER_APPLICATION_ID);
        application = [
                SELECT Name, hed__Applicant__r.Name, TB_x_Offered_Product_Speciality_EN__c,
                        TB_x_Offered_Product_Speciality_PL__c,
                        TB_x_Level_of_Study_PL__c, TB_x_Language_of_Study_PL__c,
                        TB_x_Applicant_Full_Name__c
                FROM hed__Application__c
                WHERE Id = :applicationId
        ];
        return application;
    }

    private List<QualificationsWrapper> createWrappers(List<TB_Application_Qualification__c> qualifications, Map<Id, Set<String>> qualificationIdToMembersNames) {
        List<QualificationsWrapper> wrappers = new List<QualificationsWrapper>();
        for (TB_Application_Qualification__c qualification : qualifications) {
            QualificationsWrapper wrapper = new QualificationsWrapper(qualification.Id, qualification, qualification.TB_Application_Evaluations__r);
            for (TB_Application_Evaluation__c evaluation : wrapper.evaluations) {
                wrapper.sumOfScore += (evaluation.TB_Max_Points__c == null) ? 0 : evaluation.TB_Max_Points__c;
                wrapper.sumOfEvaluationPoints += (evaluation.TB_Evaluation_Points__c == null) ? 0 : evaluation.TB_Evaluation_Points__c;
            }
            wrapper.commissionMembersNames = qualificationIdToMembersNames.get(wrapper.qualificationId);
            wrapper.examDate = createExamDate(wrapper.applicationQualification);
            wrappers.add(wrapper);
        }
        return wrappers;
    }

    private String createExamDate(TB_Application_Qualification__c qualification) {
        String startDate = qualification.TB_Qualification_Requirement_Item_Term__r?.Name?.substring(0, 10);
        if (!String.isBlank(startDate)) {
            String year = startDate.substring(0, 4);
            String month = startDate.substring(5, 7);
            String day = startDate.substring(8, 10);
            String resultDate = day + TB_Constants.TB_SEPARATOR_HYPHEN + month + TB_Constants.TB_SEPARATOR_HYPHEN + year;
            return resultDate;
        }
        return null;
    }

    private Map<Id, Set<String>> qualificationIdToMembersNames(List<TB_Application_Qualification__c> qualifications) {
        Map<Id, Set<String>> qualificationIdToCommissionIds = new Map<Id, Set<String>>();
        Set<String> allCommissionsIds = new Set<String>();
        for (TB_Application_Qualification__c qualification : qualifications) {
            createValuesSetIfNull(qualificationIdToCommissionIds, qualification.Id);
            for (TB_Application_Evaluation__c evaluation : qualification.TB_Application_Evaluations__r) {
                allCommissionsIds.add(evaluation.TB_Admissions_Committee__c);
                qualificationIdToCommissionIds.get(qualification.Id).add(evaluation.TB_Admissions_Committee__c);
            }
        }
        Set<TB_Admissions_Committee__c> members = new Set<TB_Admissions_Committee__c>();
        members.addAll([
                SELECT TB_Committee_Member__r.Name, TB_Committee_Member__r.Title, TB_Admissions_Committee__c
                FROM TB_Admissions_Committee__c
                WHERE TB_Admissions_Committee__c IN :allCommissionsIds
        ]);
        Map<Id, Set<String>> qualificationIdToMembersNames = new Map<Id, Set<String>>();
        for (Id qualificationId : qualificationIdToCommissionIds.keySet()) {
            for (TB_Admissions_Committee__c member : members) {
                String memberName = getMemberName(member);
                if (qualificationIdToCommissionIds.get(qualificationId).contains(member.TB_Admissions_Committee__c)) {
                    createValuesSetIfNull(qualificationIdToMembersNames, qualificationId);
                    qualificationIdToMembersNames.get(qualificationId).add(memberName);
                }
            }
        }
        return qualificationIdToMembersNames;
    }

    private String getMemberName(TB_Admissions_Committee__c member) {
        String memberTitle = member.TB_Committee_Member__r.Title;
        String titleToConcat = (memberTitle == null)
                || String.isBlank(memberTitle)
                ? TB_Constants.PARAM_EMPTY_STRING
                : memberTitle + TB_Constants.PARAM_WHITESPACE;
        String memberName = titleToConcat + member.TB_Committee_Member__r.Name;
        return memberName;
    }

    private void createValuesSetIfNull(Map<Id, Set<String>> qualificationIdToCommissionIds, Id qualificationId) {
        if (qualificationIdToCommissionIds.get(qualificationId) == null) {
            qualificationIdToCommissionIds.put(qualificationId, new Set<String>());
        }
    }

    private List<Id> getQualificationIds() {
        String qualificationIdsEscaped = ApexPages.currentPage().getParameters().get(URL_PARAMETER_QUALIFICATION);
        String qualificationIdsDecoded = EncodingUtil.urlDecode(qualificationIdsEscaped, TB_Constants.ENCODING_SYSTEM_UTF_8);
        List<Id> qualificationIds = new List<Id>();
        qualificationIds.addAll(qualificationIdsDecoded.split(TB_Constants.TB_SEPARATOR_SEMICOLON));
        return qualificationIds;
    }

    public class QualificationsWrapper {
        public Id qualificationId {
            get;
            set;
        }
        public TB_Application_Qualification__c applicationQualification {
            get;
            set;
        }
        public String examDate {
            get;
            set;
        }
        public List<TB_Application_Evaluation__c> evaluations {
            get;
            set;
        }
        public Decimal sumOfScore {
            get;
            set;
        }
        public Decimal sumOfEvaluationPoints {
            get;
            set;
        }
        public Set<String> commissionMembersNames {
            get;
            set;
        }
        public QualificationsWrapper(Id qualificationId, TB_Application_Qualification__c applicationQualification, List<TB_Application_Evaluation__c> evaluations) {
            this.qualificationId = qualificationId;
            this.applicationQualification = applicationQualification;
            this.evaluations = evaluations;
            this.sumOfScore = 0;
            this.sumOfEvaluationPoints = 0;
        }
    }
}
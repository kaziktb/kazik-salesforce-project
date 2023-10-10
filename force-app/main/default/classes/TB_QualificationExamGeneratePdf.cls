/**
 * Created by annaseveryna on 24/02/2022.
 */

public with sharing class TB_QualificationExamGeneratePdf {
    public static final Integer FILES_IN_PACKAGE_LIMIT = 35;
    public static final String TITLE_PART_PROTOCOL = 'Protokol-';
    private static Boolean isMultiple = false;
    private static Map<Id, String> qualificationIdToName = new Map<Id, String>();
    public static final String EXCEPTION_MESSAGE = 'Application Id cannot be null';
    public static final String VISUALFORCE_PAGE = 'Visualforce Page';


    @InvocableMethod(Label='savePdf')
    public static List<String> savePdf(List<TB_QualificationExamProtocolWrapper> wrappers) {
        setIsMultiple(wrappers);
        if (!isMultiple) {
            handleQualificationIdToName(wrappers);
        } else {
            assignQualificationsFromPackage(wrappers);
        }
        Set<Id> allApplicationIds = fetchApplicationIdsFromMultipleWrappers(wrappers);
        Map<Id, hed__Application__c> idToApplication = new Map<Id, hed__Application__c>([
                SELECT Name, TB_x_Applicant_Full_Name__c
                FROM hed__Application__c
                WHERE Id IN :allApplicationIds
        ]);
        List<TB_QualificationExamProtocolWrapper> wrappersForFileCreation = getWrappersForFileCreation(wrappers, idToApplication);
        List<TB_Application_Document__c> documents = createDocuments(wrappersForFileCreation, true);
        List<ContentVersion> contentVersions = createContentVersions(wrappersForFileCreation, documents, true);
        return getContentVersionIdsForLink(contentVersions);
    }

    private static void setIsMultiple(List<TB_QualificationExamProtocolWrapper> wrappers) {
        isMultiple = wrappers[0].isMultiple;
    }

    private static void assignQualificationsFromPackage(List<TB_QualificationExamProtocolWrapper> wrappers) {
        for (TB_QualificationExamProtocolWrapper wrapper : wrappers) {
            Integer remainingElementsForDownload = wrapper.qualifications?.size() - wrapper.indexToStartWith;
            Integer numberOfElements = (remainingElementsForDownload >= FILES_IN_PACKAGE_LIMIT)
                    ? FILES_IN_PACKAGE_LIMIT
                    : remainingElementsForDownload;
            List<TB_Application_Qualification__c> qualifications = new List<TB_Application_Qualification__c>();
            Integer indexToEndWith = wrapper.indexToStartWith + numberOfElements;
            for (Integer i = wrapper.indexToStartWith; i < indexToEndWith; i++) {
                qualifications.add(wrapper.qualifications[i]);
            }
            wrapper.qualifications = qualifications;
        }
    }

    private static void handleQualificationIdToName(List<TB_QualificationExamProtocolWrapper> wrappers) {
        Set<Id> allQualificationIds = new Set<Id>();
        for (TB_QualificationExamProtocolWrapper wrapper : wrappers) {
            allQualificationIds.addAll(separateQualificationIds(wrapper.qualificationIds));
        }
        for (TB_Application_Qualification__c qualification : [
                SELECT TB_Qualification_Requirement_Name__c
                FROM TB_Application_Qualification__c
                WHERE Id IN :allQualificationIds
        ]) {
            qualificationIdToName.put(qualification.Id, qualification.TB_Qualification_Requirement_Name__c);
        }
    }

    private static Set<Id> fetchApplicationIdsFromMultipleWrappers (List<TB_QualificationExamProtocolWrapper> wrappers) {
        Set<Id> allApplicationIds = new Set<Id>();
        for (TB_QualificationExamProtocolWrapper wrapper : wrappers) {
            if (wrapper.isMultiple) {
                wrapper.applicationIds = new List<Id>();
                for (TB_Application_Qualification__c qualification : wrapper.qualifications) {
                    qualificationIdToName.put(qualification.Id, qualification.TB_Qualification_Requirement_Name__c);
                    wrapper.applicationIds.add(qualification.TB_Application__c);
                }
                allApplicationIds.addAll(wrapper.applicationIds);
            }
        }
        return allApplicationIds;
    }

    private static List<TB_QualificationExamProtocolWrapper> getWrappersForFileCreation(List<TB_QualificationExamProtocolWrapper> wrappers, Map<Id, hed__Application__c> idToApplication) {
        List<TB_QualificationExamProtocolWrapper> wrappersForFileCreation = new List<TB_QualificationExamProtocolWrapper>();
        for (TB_QualificationExamProtocolWrapper wrapper : wrappers) {
            if (wrapper.isMultiple) {
                for (TB_Application_Qualification__c qualification : wrapper.qualifications) {
                    hed__Application__c application = idToApplication.get(qualification.TB_Application__c);
                    TB_QualificationExamProtocolWrapper wrapperForFile = createWrapperForFile(application, qualification.Id);
                    wrappersForFileCreation.add(wrapperForFile);
                }
            } else {
                for (Id qualificationId : separateQualificationIds(wrapper.qualificationIds)) {
                    TB_QualificationExamProtocolWrapper wrapperForFile = createWrapperForFile(wrapper, qualificationId);
                    wrappersForFileCreation.add(wrapperForFile);
                }
            }
        }
        return wrappersForFileCreation;
    }

    private static TB_QualificationExamProtocolWrapper createWrapperForFile(hed__Application__c application, Id qualificationId) {
        return createWrapperForFile(application.Id, application.Name, application.TB_x_Applicant_Full_Name__c, qualificationId);
    }

    private static TB_QualificationExamProtocolWrapper createWrapperForFile(TB_QualificationExamProtocolWrapper wrapper, Id qualificationId) {
        return createWrapperForFile(wrapper.applicationId, wrapper.applicationName, wrapper.applicantFullName, qualificationId);
    }

    private static TB_QualificationExamProtocolWrapper createWrapperForFile(Id applicationId, String applicationName, String applicantFullName, String qualificationIds) {
        TB_QualificationExamProtocolWrapper wrapperForFile = new TB_QualificationExamProtocolWrapper();
        wrapperForFile.applicationId = applicationId;
        wrapperForFile.applicationName = applicationName;
        wrapperForFile.applicantFullName = applicantFullName;
        wrapperForFile.qualificationIds = qualificationIds;
        wrapperForFile.fileName = createTitle(applicationName, applicantFullName, qualificationIds);
        wrapperForFile.pdfPageReference = Page.TB_QualificationExamProtocol;
        return wrapperForFile;
    }

    private static List<Id> separateQualificationIds(String qualificationIdsConcatenated) {
        return (List<Id>) qualificationIdsConcatenated.split(TB_Constants.TB_SEPARATOR_SEMICOLON);
    }

    private static String createTitle(String applicationName, String applicantFullName, String qualificationIdsConcatenated) {
        String qualificationNames = createQualificationNames(qualificationIdsConcatenated);
        String fileNameToNormalize = TITLE_PART_PROTOCOL
                + applicationName
                + TB_Constants.TB_SEPARATOR_HYPHEN + applicantFullName
                + TB_Constants.TB_SEPARATOR_HYPHEN + qualificationNames
                + TB_Constants.TB_PARAM_PDF_EXTENSION;
        return TB_StringUtils.stripPolishAccents(fileNameToNormalize);
    }

    private static String createQualificationNames(String qualificationIdsConcatenated) {
        List<Id> qualificationIds = separateQualificationIds(qualificationIdsConcatenated);
        List<String> qualificationNames = new List<String>();
        for (Id qualificationId : qualificationIds) {
            qualificationNames.add(qualificationIdToName.get(qualificationId));
        }
        return String.join(qualificationNames, TB_Constants.TB_SEPARATOR_HYPHEN);
    }

    private static List<TB_Application_Document__c> createDocuments(List<TB_QualificationExamProtocolWrapper> wrappersForFileCreation, Boolean withInsert) {
        List<TB_Application_Document__c> documents = new List<TB_Application_Document__c>();
        for (TB_QualificationExamProtocolWrapper wrapper : wrappersForFileCreation) {
            if (wrapper.applicationId != null) {
                wrapper.pdfPageReference.getParameters().put(TB_QualificationExamProtocolController.URL_PARAMETER_APPLICATION_ID, wrapper.applicationId);
                wrapper.pdfPageReference.getParameters().put(
                        TB_QualificationExamProtocolController.URL_PARAMETER_QUALIFICATION,
                        EncodingUtil.urlEncode(wrapper.qualificationIds, TB_Constants.ENCODING_SYSTEM_UTF_8)
                );
                TB_Application_Document__c document = new TB_Application_Document__c(
                        TB_Application__c = wrapper.applicationId,
                        TB_Document_Type__c = TB_Constants.TB_APP_DOCUMENT_TYPE_ELECTRONIC,
                        TB_Document_Name_PL__c = wrapper.fileName);
                documents.add(document);
            } else {
                throw new IllegalArgumentException(EXCEPTION_MESSAGE);
            }
        }
        if (withInsert) {
            insert documents;
        }
        return documents;
    }

    private static List<ContentVersion> createContentVersions(List<TB_QualificationExamProtocolWrapper> wrappersForFileCreation, List<TB_Application_Document__c> documents, Boolean withInsert) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < wrappersForFileCreation.size(); i++) {
            TB_QualificationExamProtocolWrapper wrapper = wrappersForFileCreation[i];
            ContentVersion contentVersion = new ContentVersion();
            try {
                contentVersion.VersionData = wrapper.pdfPageReference.getContent();
            } catch (VisualforceException e) {
                contentVersion.VersionData = Blob.valueOf(VISUALFORCE_PAGE);
            }
            contentVersion.TB_Application_Document__c = documents[i].Id;
            contentVersion.Title = wrapper.fileName;
            contentVersion.ContentLocation = TB_Constants.CONTENT_LOCATION_SALESFORCE;
            contentVersion.PathOnClient = wrapper.fileName;
            contentVersions.add(contentVersion);
        }
        if (withInsert) {
            insert contentVersions;
        }
        return contentVersions;
    }

    private static List<String> getContentVersionIdsForLink(List<ContentVersion> contentVersions) {
        List<String> concatenatedContentVersions = new List<String>();
        List<Id> contentVersionIds = new List<Id>();
        for (ContentVersion version : contentVersions) {
            contentVersionIds.add(version.Id);
        }
        concatenatedContentVersions.add(String.join(contentVersionIds, TB_Constants.TB_SEPARATOR_SLASH));
        return concatenatedContentVersions;
    }
}
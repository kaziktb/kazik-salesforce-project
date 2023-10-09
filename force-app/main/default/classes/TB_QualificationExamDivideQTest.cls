/**
 * Created by annaseveryna on 04/03/2022.
 */
@IsTest
private class TB_QualificationExamDivideQTest {

    private static final Integer NUMBER_OF_QUALIFICATIONS = 100;
    private static final Integer EXPECTED_NUMBER_OF_PACKAGES = 3;
    private static final Integer EXPECTED_FILES_IN_PACKAGE_LIMIT = TB_QualificationExamGeneratePdf.FILES_IN_PACKAGE_LIMIT;
    private static final List<Integer> EXPECTED_COUNTERS = new List<Integer> { 1, 2, 3 };
    private static final List<Integer> EXPECTED_QUALIFICATION_INDEXES_TO_BEGIN_WITH = new List<Integer> { 0, 35, 70 };
    private static final String QUALIFICATIONS_NAME = 'Test Name';

    @TestSetup
    private static void setupMethod() {
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjectsAndNestedLookup(true);
        List<TB_Application_Qualification__c> qualifications = new List<TB_Application_Qualification__c>();
        for (Integer i = 0; i < NUMBER_OF_QUALIFICATIONS; i++) {
            TB_Application_Qualification__c qualification = TB_TestDataFactory.createApplicationQualification(false, application.Id);
            qualification.TB_Qualification_Requirement_Name__c = QUALIFICATIONS_NAME + i;
            qualifications.add(qualification);
        }
        insert qualifications;
    }

    @IsTest
    private static void divideQualificationsTest() {
        List<TB_Application_Qualification__c> qualifications = [SELECT Id FROM TB_Application_Qualification__c];
        TB_QualificationExamProtocolWrapper wrapper = new TB_QualificationExamProtocolWrapper();
        wrapper.qualifications = qualifications;
        wrapper.isMultiple = true;
        List<TB_QualificationExamProtocolWrapper> wrappers = new List<TB_QualificationExamProtocolWrapper> { wrapper };

        Test.startTest();
        List<TB_QualificationExamDivideQualifications.FlowOutput> outputs = TB_QualificationExamDivideQualifications.divideQualifications(wrappers);
        Test.stopTest();

        for (TB_QualificationExamDivideQualifications.FlowOutput output : outputs) {
            System.assertEquals(NUMBER_OF_QUALIFICATIONS, output.numberOfQualifications);
            System.assertEquals(EXPECTED_NUMBER_OF_PACKAGES, output.numberOfPackages);
            System.assertEquals(EXPECTED_FILES_IN_PACKAGE_LIMIT, output.filesInPackageLimit);
            System.assertEquals(EXPECTED_COUNTERS, output.counters);
            System.assertEquals(EXPECTED_QUALIFICATION_INDEXES_TO_BEGIN_WITH, output.qualificationIndexesToBeginWith);
        }
    }
}
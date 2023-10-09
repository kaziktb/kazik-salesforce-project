@isTest
private class TB_kb_PathControllerTest {
    private static final String TEST_VALUE = 'TEST';
    private static final String LABEL_VALUE_WITHOUT_NUMBER = 'TEST_EN_';
    private final static String ADMISSIONS_BUSINESS_OWNER = 'Admissions';

    @testSetup
    static void testSetup() {
        List<TB_Knowledge_Category__c> knowledgeCategories = TB_TestDataFactory.createKnowledgeCategories(3, TEST_VALUE,ADMISSIONS_BUSINESS_OWNER, true);
        for(Integer i=0; i<3; i++){
            if(i>0) knowledgeCategories[i].TB_Parent_Category__c = knowledgeCategories[i-1].Id;
        }
        update knowledgeCategories;
    }

    @isTest
    private static void testTestCase() {
        TB_kb_PathController.CategoryWrapper result;
        User userWithEnglishLocaleKey = TB_TestDataFactory.prepareUser();
        Id subcategoryId = [SELECT Id FROM TB_Knowledge_Category__c WHERE TB_Category_API_Name__c =: TEST_VALUE + '2' LIMIT 1].Id;

        Test.startTest();
        System.runAs(userWithEnglishLocaleKey) {
            result = TB_kb_PathController.getCategoriesForPath(subcategoryId);
        }
        Test.stopTest();
    
        Assert.isTrue(result != null);
        Assert.isTrue(result.label == LABEL_VALUE_WITHOUT_NUMBER + '2');
        Assert.isTrue(result.parentCategory.label == LABEL_VALUE_WITHOUT_NUMBER + '1');
        Assert.isTrue(result.parentCategory.parentCategory.label == LABEL_VALUE_WITHOUT_NUMBER + '0');
    }

    @IsTest
    static void throwAnError_whenInvalidIdIsPassed() {
        TB_kb_PathController.CategoryWrapper result;
        Boolean errorOccurred;

        Test.startTest();
        try {
            result = TB_kb_PathController.getCategoriesForPath('INVALID');
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        Assert.isTrue(errorOccurred);
    }
}
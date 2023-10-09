@isTest
private class TB_kb_HomePageControllerTest {
    private final static String ADMISSIONS_BUSINESS_OWNER = 'Admissions';
    private final static String GROUP_CATEGORY_API_NAME = 'Group_Category';
    private final static String PARENT_CATEGORY_API_NAME = 'Parent_Category';

    @TestSetup
    static void testSetup(){
        TB_Knowledge_Category__c groupCategory = new TB_Knowledge_Category__c();
        groupCategory.TB_Category_API_Name__c = GROUP_CATEGORY_API_NAME;
        groupCategory.TB_Public__c= true;
        groupCategory.TB_Business_Owner__c = ADMISSIONS_BUSINESS_OWNER;
        groupCategory.TB_Category_Name_PL__c = 'Group Kategoria';
        groupCategory.TB_Category_Name_EN__c = 'Group Category';
        groupCategory.TB_Public__c = true;
        insert groupCategory;

        TB_Knowledge_Category__c category = new TB_Knowledge_Category__c();
        category.TB_Category_API_Name__c = PARENT_CATEGORY_API_NAME;
        category.TB_Public__c= true;
        category.TB_Business_Owner__c = ADMISSIONS_BUSINESS_OWNER;
        category.TB_Category_Name_PL__c = 'Parent Kategoria';
        category.TB_Category_Name_EN__c = 'Parent Category';
        category.TB_Parent_Category__c = groupCategory.Id;
        category.TB_Public__c = true;
        insert category;

        TB_Knowledge_Category__c subcategory1 = new TB_Knowledge_Category__c();
        subcategory1.TB_Category_API_Name__c = 'Child_Category_1';
        subcategory1.TB_Public__c= true;
        subcategory1.TB_Business_Owner__c = ADMISSIONS_BUSINESS_OWNER;
        subcategory1.TB_Category_Name_PL__c = 'Child Kategoria 1';
        subcategory1.TB_Category_Name_EN__c = 'Child Category 1';
        subcategory1.TB_Parent_Category__c = category.Id;
        subcategory1.TB_Public__c = true;
        insert subcategory1;

        TB_Knowledge_Category__c subcategory2 = new TB_Knowledge_Category__c();
        subcategory2.TB_Category_API_Name__c = 'Child_Category_2';
        subcategory2.TB_Public__c= true;
        subcategory2.TB_Business_Owner__c = ADMISSIONS_BUSINESS_OWNER;
        subcategory2.TB_Category_Name_PL__c = 'Child Kategoria 2';
        subcategory2.TB_Category_Name_EN__c = 'Child Category 2';
        subcategory2.TB_Parent_Category__c = category.Id;
        subcategory2.TB_Public__c = true;
        insert subcategory2;
    }

    @IsTest
    static void shouldReturnDataCategoriesWithoutPassedRecordId() {
        List<TB_kb_HomePageController.DataCategoryWrapper> categoriesWithSubcategories = new List<TB_kb_HomePageController.DataCategoryWrapper>();
        Test.startTest();
        categoriesWithSubcategories = TB_kb_HomePageController.getDataCategories(null);
        Test.stopTest();

        Assert.isTrue(categoriesWithSubcategories.size() == 1);
        Assert.isTrue(categoriesWithSubcategories[0].relatedCategories.size() == 1);
        Assert.isTrue(categoriesWithSubcategories[0].relatedCategories[0].relatedCategories.size() == 2);
    }

    @IsTest
    static void shouldReturnDataCategoriesWithPassedRecordIdAndExpandGroupCategory() {
        List<TB_kb_HomePageController.DataCategoryWrapper> categoriesWithSubcategories = new List<TB_kb_HomePageController.DataCategoryWrapper>();
        Id groupCategoryId = [SELECT Id FROM TB_Knowledge_Category__c WHERE TB_Category_API_Name__c =: GROUP_CATEGORY_API_NAME LIMIT 1].Id;

        Test.startTest();
        categoriesWithSubcategories = TB_kb_HomePageController.getDataCategories(groupCategoryId);
        Test.stopTest();

        Assert.isTrue(categoriesWithSubcategories.size() == 1);
        Assert.isTrue(categoriesWithSubcategories[0].expandedOnPage);
        Assert.isTrue(categoriesWithSubcategories[0].relatedCategories.size() == 1);
        Assert.isTrue(categoriesWithSubcategories[0].relatedCategories[0].relatedCategories.size() == 2);
    }

    @IsTest
    static void shouldReturnDataCategoriesWithPassedRecordIdAndExpandGroupCategoryAndCategory() {
        List<TB_kb_HomePageController.DataCategoryWrapper> categoriesWithSubcategories = new List<TB_kb_HomePageController.DataCategoryWrapper>();
        Id groupCategoryId = [SELECT Id FROM TB_Knowledge_Category__c WHERE TB_Category_API_Name__c =: PARENT_CATEGORY_API_NAME LIMIT 1].Id;

        Test.startTest();
        categoriesWithSubcategories = TB_kb_HomePageController.getDataCategories(groupCategoryId);
        Test.stopTest();

        Assert.isTrue(categoriesWithSubcategories.size() == 1);
        Assert.isTrue(categoriesWithSubcategories[0].expandedOnPage);
        Assert.isTrue(categoriesWithSubcategories[0].relatedCategories.size() == 1);
        Assert.isTrue(categoriesWithSubcategories[0].relatedCategories[0].expandedOnPage);
        Assert.isTrue(categoriesWithSubcategories[0].relatedCategories[0].relatedCategories.size() == 2);
    }

    @IsTest
    static void throwAnError_whenInvalidIdIsPassed() {
        List<TB_kb_HomePageController.DataCategoryWrapper> categoriesWithSubcategories = new List<TB_kb_HomePageController.DataCategoryWrapper>();
        Boolean errorOccurred;

        Test.startTest();
        try {
            categoriesWithSubcategories = TB_kb_HomePageController.getDataCategories('INVALID');
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        Assert.isTrue(errorOccurred);
    }
}
@IsTest(IsParallel=true)
public class LookupSearchResultTest {
    @IsTest
    static void compareToTestTwoNullTitles() {
        LookupSearchResult r1 = getSearchResult(null);
        LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        Assert.areEqual(0, compareResult);
    }

    @IsTest
    static void compareToTestSingleNullTitleFirstResult() {
        LookupSearchResult r1 = getSearchResult(null);
        LookupSearchResult r2 = getSearchResult('a');

        Integer compareResult = r1.compareTo(r2);

        Assert.areEqual(1, compareResult);
    }

    @IsTest
    static void compareToTestSingleNullTitleSecondResult() {
        LookupSearchResult r1 = getSearchResult('a');
        LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        Assert.areEqual(-1, compareResult);
    }

    @IsTest
    static void compareToTestNoNullTitles() {
        LookupSearchResult r1 = getSearchResult('a');
        LookupSearchResult r2 = getSearchResult('b');

        Integer compareResult = r1.compareTo(r2);

        Assert.areEqual(-1, compareResult);
    }

    @IsTest
    static void gettersTest() {
        // For the sake of code coverage
        LookupSearchResult r = new LookupSearchResult('0010R00000yvEyRQAU', 'type', 'icon', 'title', 'subtitle');

        Assert.areEqual('0010R00000yvEyRQAU', r.getId());
        Assert.areEqual('type', r.getSObjectType());
        Assert.areEqual('icon', r.getIcon());
        Assert.areEqual('title', r.getTitle());
        Assert.areEqual('subtitle', r.getSubtitle());
    }

    private static LookupSearchResult getSearchResult(String title) {
        return new LookupSearchResult(null, null, null, title, null);
    }
}
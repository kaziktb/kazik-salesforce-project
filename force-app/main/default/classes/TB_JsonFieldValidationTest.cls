@IsTest
private class TB_JsonFieldValidationTest {
    @IsTest
    static void testCorrectJsonInsert() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            insert new TB_Admissions_Process__c(TB_Display_Logic__c = '(Application.Name=\'Accepted\' OR Application.hed__Application_Status__c=\'Conditionally_Accepted\')');
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(!isExceptionThrown, exceptionMessage);
    }

    @IsTest
    static void testCorrectJsonUpdate() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        TB_Admissions_Process__c process = new TB_Admissions_Process__c(TB_Display_Logic__c = '(Application.Name=\'Accepted\' OR Application.hed__Application_Status__c=\'Conditionally_Accepted\')');
        insert process;

        Test.startTest();
        try {
            process.TB_Display_Logic__c = '(Application.Name=\'Accepted\' AND Application.hed__Application_Status__c=\'Conditionally_Accepted\')';
            update process;
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
            isExceptionThrown = true;
        }

        Test.stopTest();
        System.assert(!isExceptionThrown, exceptionMessage);
    }

    @IsTest
    static void testFixingApostrophes() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        TB_Admissions_Process__c process;
        try {
            process = new TB_Admissions_Process__c(
                TB_Display_Logic__c = 'Application.Name=\"Accepted\"'
            );
            insert process;
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
            isExceptionThrown = true;
        }

        Test.stopTest();

        System.assert(!isExceptionThrown, exceptionMessage);

        TB_Admissions_Process__c processAfterInsert = [
            SELECT TB_Display_Logic__c
            FROM TB_Admissions_Process__c
            WHERE Id = :process.Id
        ];

        System.assertEquals('Application.Name=\'Accepted\'', processAfterInsert.TB_Display_Logic__c);
    }

    @IsTest
    static void testFixingSigns() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        TB_Admissions_Process__c process;
        try {
            process = new TB_Admissions_Process__c(
                TB_Display_Logic__c = 'Application.Name=!\'Accepted\''
            );
            insert process;
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
            isExceptionThrown = true;
        }

        Test.stopTest();

        System.assert(!isExceptionThrown, exceptionMessage);

        TB_Admissions_Process__c processAfterInsert = [
            SELECT TB_Display_Logic__c
            FROM TB_Admissions_Process__c
            WHERE Id = :process.Id
        ];

        System.assertEquals('Application.Name!=\'Accepted\'', processAfterInsert.TB_Display_Logic__c);
    }

    @IsTest
    static void testWrongBracketsInsert() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;
        Test.startTest();
        try {
            insert new TB_Admissions_Process__c(TB_Display_Logic__c = 'Application.Name=\'Accepted\' OR Application.hed__Application_Status__c=\'Conditionally_Accepted\')');
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
            isExceptionThrown = true;
        }
        Test.stopTest();

        System.assert(isExceptionThrown);
        String errorMessage = String.format(Label.TB_JSON_Missing_Brackets, new List<Object>{ 'TB_Display_Logic__c' });
        System.assert(exceptionMessage.contains(errorMessage));
    }

    @IsTest
    static void testWrongBracketsUpdate() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        TB_Admissions_Process__c process = new TB_Admissions_Process__c(TB_Display_Logic__c = '(Application.Name=\'Accepted\' OR Application.hed__Application_Status__c=\'Conditionally_Accepted\') AND Application.TB_Qualification_Type__c=\'Language_Courses\'');
        insert process;

        Test.startTest();
        try {
            process.TB_Display_Logic__c = '(Application.Name=\'Accepted\'';
            update process;
        } catch (Exception e) {
            isExceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(isExceptionThrown);
        String errorMessage = String.format(Label.TB_JSON_Missing_Brackets, new List<Object>{ 'TB_Display_Logic__c' });
        System.assert(exceptionMessage.contains(errorMessage));
    }

    @IsTest
    static void testWrongApostrophesNumber() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;
        Test.startTest();
        try {
            insert new TB_Admissions_Process__c(TB_Display_Logic__c = 'Application.Name= Accepted\'');
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
            isExceptionThrown = true;
        }
        Test.stopTest();

        System.assert(isExceptionThrown);
        String errorMessage = String.format(Label.TB_JSON_Missing_Apostrophes, new List<Object>{ 'TB_Display_Logic__c' });
        System.assert(exceptionMessage.contains(errorMessage));
    }

    @IsTest
    static void testWrongFieldInsert() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;
        Test.startTest();
        try {
            insert new TB_Admissions_Process__c(TB_Display_Logic__c = 'Application.NonExistingField=\'Accepted\'');
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
            isExceptionThrown = true;
        }
        Test.stopTest();

        System.assert(isExceptionThrown);
        List<Object> parameters = new List<Object>{
            'Application.NonExistingField', 'TB_Display_Logic_JSON__c'
        };
        String errorMessage = String.format(Label.TB_JSON_Missing_Field, parameters);
        System.assert(exceptionMessage.contains(errorMessage));
    }

    @IsTest
    static void testWrongFieldUpdate() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        TB_Admissions_Process__c process = new TB_Admissions_Process__c(TB_Display_Logic__c = 'Application.Name=\'Accepted\'');
        insert process;

        Test.startTest();
        try {
            process.TB_Display_Logic__c = 'Application.NonExistingField=\'Accepted\'';
            update process;
        } catch (Exception e) {
            isExceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(isExceptionThrown);
        List<Object> parameters = new List<Object>{
            'Application.NonExistingField', 'TB_Display_Logic_JSON__c'
        };
        String errorMessage = String.format(Label.TB_JSON_Missing_Field, parameters);
        System.assert(exceptionMessage.contains(errorMessage));
    }

    @IsTest
    static void testMissingObjectInsert() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            insert new TB_Admissions_Process__c(TB_Display_Logic__c = 'Name=\'Accepted\'');
        } catch (Exception e) {
            isExceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(isExceptionThrown);
        List<Object> parameters = new List<Object>{
            'Name', 'TB_Display_Logic_JSON__c'
        };
        String errorMessage = String.format(Label.TB_JSON_Missing_Object, parameters);
        System.assert(exceptionMessage.contains(errorMessage));
    }

    @IsTest
    static void testMissingObjectUpdate() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        TB_Admissions_Process__c process = new TB_Admissions_Process__c(TB_Display_Logic__c = 'Application.Name=\'Accepted\'');
        insert process;

        Test.startTest();
        try {
            process.TB_Display_Logic__c = 'Name=\'Accepted\'';
            update process;
        } catch (Exception e) {
            isExceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        List<Object> parameters = new List<Object>{
            'Name', 'TB_Display_Logic_JSON__c'
        };
        String errorMessage = String.format(Label.TB_JSON_Missing_Object, parameters);
        System.assert(exceptionMessage.contains(errorMessage));
    }

    @IsTest
    static void testWrongObjectInsert() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            insert new TB_Admissions_Process__c(TB_Display_Logic__c = 'WrongObject.Name=\'Accepted\'');
        } catch (Exception e) {
            isExceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(isExceptionThrown);
        List<Object> parameters = new List<Object>{
            'WrongObject', 'TB_Display_Logic_JSON__c'
        };
        String errorMessage = String.format(Label.TB_JSON_Wrong_Object, parameters);
        System.assert(exceptionMessage.contains(errorMessage));
    }

    @IsTest
    static void testWrongObjectUpdate() {
        Boolean isExceptionThrown = false;
        String exceptionMessage;

        TB_Admissions_Process__c process = new TB_Admissions_Process__c(TB_Display_Logic__c = 'Application.Name=\'Accepted\'');
        insert process;

        Test.startTest();
        try {
            process.TB_Display_Logic__c = 'WrongObject.Name=\'Accepted\'';
            update process;
        } catch (Exception e) {
            isExceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        List<Object> parameters = new List<Object>{
            'WrongObject', 'TB_Display_Logic_JSON__c'
        };
        String errorMessage = String.format(Label.TB_JSON_Wrong_Object, parameters);
        System.assert(exceptionMessage.contains(errorMessage));
    }
}
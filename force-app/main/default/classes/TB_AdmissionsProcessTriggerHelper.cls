/**
 * Created by kacperjachowicz on 05/10/2021.
 */

public with sharing class TB_AdmissionsProcessTriggerHelper {
    public static void fillJSONFields(List<SObject> sObjects) {
        for (SObject sObj : sObjects) {
            String readLogic = readAdmissionsLogic(String.valueOf(sObj.get('TB_Display_Logic__c')));
            String editLogic = readAdmissionsLogic(String.valueOf(sObj.get('TB_Edit_Logic__c')));
            sObj.put('TB_Display_Logic_JSON__c',readLogic);
            sObj.put('TB_Edit_Logic_JSON__c',editLogic);
        }
    }

    public static void fillJSONFieldsForRedirectLogic(List<SObject> sObjects) {
        for (SObject sObj : sObjects) {
            String redirectLogic = readAdmissionsLogic(String.valueOf(sObj.get('TB_Redirect_Logic__c')));
            sObj.put('TB_Redirect_Logic_JSON__c',redirectLogic);
        }
    }

    public static void handleJsonFieldCorrectness (List<TB_Admissions_Process__c> admissionProcesses, Map<Id, TB_Admissions_Process__c> idToOldProcess) {
        List<String> fieldsForVerification = new List<String> {
            TB_Admissions_Process__c.TB_Display_Logic_JSON__c.getDescribe().getName(),
            TB_Admissions_Process__c.TB_Edit_Logic_JSON__c.getDescribe().getName()
        };
        TB_JsonFieldValidation.handleJsonFieldCorrectness(admissionProcesses, idToOldProcess, fieldsForVerification);
    }

    public static void handleLogicFieldCorrectness (List<TB_Admissions_Process__c> admissionsLogics, Map<Id, TB_Admissions_Process__c> idToOldLogics) {
        List<String> fieldsForVerification = new List<String> {
            TB_Admissions_Process__c.TB_Display_Logic__c.getDescribe().getName(),
            TB_Admissions_Process__c.TB_Edit_Logic__c.getDescribe().getName()
        };
        TB_JsonFieldValidation.handleLogicFieldCorrectness(admissionsLogics, idToOldLogics, fieldsForVerification);
    }

    public static Map<String, String> parentObjectToObjectPath = new Map<String, String>{
        'Application.' => 'hed__Application__c.',
        'Applicant.' => 'hed__Applicant__r.',
        'Agent.' => 'hed__Preparer__r.',
        'Decision_Maker.' => 'TB_PD_Decision_Maker__r.',
        'Approver.' => 'TB_PD_Approver__r.',
        'Offered_Product.' => 'TB_Applying_To_Offered_Product__r.'
    };

    public static Map<String, String> objectPathToParentObject = new Map<String, String>{
        'hed__Application__c' => 'Application.',
        'hed__Applicant__r' => 'Applicant.',
        'hed__Preparer__r' => 'Agent.',
        'TB_PD_Decision_Maker__r' => 'Decision_Maker.',
        'TB_PD_Approver__r' => 'Approver.',
        'TB_Applying_To_Offered_Product__r' => 'Offered_Product.'
    };

    public static Map<String, Set<String>> relationshipToFields = new Map<String, Set<String>>{
        hed__Application__c.SObjectType.getDescribe().getName() => Schema.SObjectType.hed__Application__c.fields.getMap().keySet(),
        hed__Application__c.hed__Applicant__c.getDescribe().getRelationshipName() => Schema.SObjectType.Contact.fields.getMap().keySet(),
        hed__Application__c.hed__Preparer__c.getDescribe().getRelationshipName() => Schema.SObjectType.Contact.fields.getMap().keySet(),
        hed__Application__c.TB_PD_Decision_Maker__c.getDescribe().getRelationshipName() => Schema.SObjectType.Contact.fields.getMap().keySet(),
        hed__Application__c.TB_PD_Approver__c.getDescribe().getRelationshipName() => Schema.SObjectType.Contact.fields.getMap().keySet(),
        hed__Application__c.TB_Applying_To_Offered_Product__c.getDescribe().getRelationshipName() => Schema.SObjectType.TB_Offered_Product__c.fields.getMap().keySet()
    };

    private static List<String> uniqueOperators = new List<String>{
            '>=', '<=', '!=', '>', '<', '(', ')', '='
    };
    private static List<String> uniqueOperatorsWithSpace = new List<String>{
            ' >= ', ' <= ', ' != ', ' > ', ' < ', ' ( ', ' ) ', ' = '
    };
    private static List<String> nameOfUniqueOperators = new List<String>{
            'moreThanOrEqual', 'lowerThanOrEqual', 'notEqual', 'moreThan', 'lowerThan', 'openBracket', 'closeBracket', 'equal'
    };
    private static List<String> operators = new List<String>{
            'AND', 'OR', 'IN'
    };
    private static String newFieldName;


    public static String readAdmissionsLogic(String logicDetails) {
        LogicWrapper logicWrapper = new LogicWrapper();

        List<SingleLogicWrapper> singleLogicWrappers = new List<SingleLogicWrapper>();
        Integer iterator = 0;
        Boolean isEndedWithBracket;
        if (!String.isBlank(logicDetails)) {
            String formattedLogicDetails = formatLogicDetails(logicDetails);
            isEndedWithBracket = formattedLogicDetails.endsWith(') ');
            formattedLogicDetails = removeWordBlank(formattedLogicDetails);
            while (!String.isBlank(formattedLogicDetails)) {
                // need to clear value from newFieldName before retrieving new field name
                newFieldName = '';
                formattedLogicDetails = removeWordIn(formattedLogicDetails,logicWrapper);
                while(formattedLogicDetails.startsWith(' AND') || formattedLogicDetails.startsWith(' OR')
                        || formattedLogicDetails.startsWith(' (') || formattedLogicDetails.startsWith(' )')) {
                    formattedLogicDetails = removeOperatorsFromBeginning(formattedLogicDetails, logicWrapper);
                    formattedLogicDetails = removeBracketsFromLogicDetails(formattedLogicDetails, logicWrapper);
                }
                SingleLogicWrapper singleLogicWrapper = assignValuesToSingleWrapper(formattedLogicDetails);

                formattedLogicDetails = formattedLogicDetails.substringAfter(singleLogicWrapper.value);
                if (!String.isBlank(formattedLogicDetails) || !isEndedWithBracket) {
                    iterator++;
                    singleLogicWrapper.order = iterator;
                    logicWrapper.order += iterator;
                    singleLogicWrappers.add(singleLogicWrapper);
                }
            }
            logicWrapper.singleLogicWrappers = singleLogicWrappers;
        }
        return JSON.serialize(logicWrapper);
    }

    private static String formatLogicDetails(String logicDetails) {
        return replacingQuotesLogicDetails(changeObjectNames(changeNamesToOperatorsWithSpace(changeOperatorsToName(logicDetails))));
    }

    private static String removeWordIn(String formattedLogicDetails, LogicWrapper logicWrapper) {
        String formattedLogicDetailsWithoutIn = '';
        String fieldName = '';
        if (formattedLogicDetails.contains('IN')) {
            String formattedLogicDetailsWithoutBrackets = removeBracketsFromLogicDetails(formattedLogicDetails, logicWrapper);
            logicWrapper.order = '';
            String fieldsInINCondition = formattedLogicDetailsWithoutBrackets.substringAfter('[').substringBefore(']');
            List<String> fieldValues = fieldsInINCondition.split(',');
            String formattedLogicDetailsInIN = formattedLogicDetailsWithoutBrackets.substringBefore('IN');
            for (String uniqueOperator : uniqueOperators) {
                fieldName = retrieveFieldName(formattedLogicDetailsInIN, uniqueOperator);
            }
            String formattedNewCondition = '';
            for (String fieldValue : fieldValues) {
                formattedNewCondition += fieldName + ' = ' + fieldValue + ' OR ';
            }
            formattedNewCondition = formattedNewCondition.removeEnd('OR ');
            formattedLogicDetailsWithoutIn = formattedLogicDetails.replace(fieldName + 'IN ' + '[' + fieldsInINCondition + '] ', formattedNewCondition);
        }
        return String.isBlank(formattedLogicDetailsWithoutIn) ? formattedLogicDetails : formattedLogicDetailsWithoutIn;
    }

    private static String changeOperatorsToName(String logicDetails) {
        for (Integer i = 0; i < uniqueOperators.size(); i++) {
            logicDetails = logicDetails.replace(uniqueOperators[i], nameOfUniqueOperators[i]);
        }
        return logicDetails;
    }

    private static String changeNamesToOperatorsWithSpace(String logicDetails) {
        for (Integer i = 0; i < uniqueOperators.size(); i++) {
            logicDetails = logicDetails.replace(nameOfUniqueOperators[i], uniqueOperatorsWithSpace[i]);
        }
        return logicDetails;
    }

    private static String changeObjectNames(String logicDetails) {
        for (String keyValue : parentObjectToObjectPath.keySet()) {
            logicDetails = logicDetails.replace(keyValue, parentObjectToObjectPath.get(keyValue));
        }
        return logicDetails;
    }

    private static String replacingQuotesLogicDetails(String logicDetails) {
        logicDetails = logicDetails.replace('\"', '\'').replaceAll('\\s+', ' ');

        return logicDetails;
    }

    private static String removeWordBlank(String formattedLogicDetails){
        if(formattedLogicDetails.contains('BLANK')){
            formattedLogicDetails = formattedLogicDetails.replaceAll('BLANK','\'\'');
        }
        return formattedLogicDetails;
    }

    private static String removeOperatorsFromBeginning(String formattedLogicDetails, LogicWrapper logicWrapper) {
        for (String operator : operators) {
            if (formattedLogicDetails.startsWith(' ' + operator + ' ')) {
                formattedLogicDetails = formattedLogicDetails.removeStart(' ' + operator + ' ');
                logicWrapper.order += ' ' + operator + ' ';
            }
        }
        return formattedLogicDetails;
    }

    private static String removeBracketsFromLogicDetails(String formattedLogicDetails, LogicWrapper logicWrapper) {
        if (formattedLogicDetails.startsWith(' (') || formattedLogicDetails.startsWith('( ')) {
            logicWrapper.order += '( ';
            formattedLogicDetails = formattedLogicDetails.substringAfter('( ');
        }
        if (formattedLogicDetails.startsWith(' )')) {
            logicWrapper.order += ' ) ';
            formattedLogicDetails = formattedLogicDetails.substringAfter(')');
        }
        return formattedLogicDetails;
    }

    private static SingleLogicWrapper assignValuesToSingleWrapper(String formattedLogicDetails){
        SingleLogicWrapper singleLogicWrapper = new SingleLogicWrapper();
        for (String uniqueOperator : uniqueOperators) {
            singleLogicWrapper.fieldName = retrieveFieldName(formattedLogicDetails, uniqueOperator);
            singleLogicWrapper.value = retrieveFieldValue(formattedLogicDetails, uniqueOperator);
            singleLogicWrapper.operator = retrieveOperator(formattedLogicDetails, singleLogicWrapper.value, singleLogicWrapper.fieldName);
        }
        return singleLogicWrapper;
    }

    private static String retrieveFieldName(String formattedLogicDetails, String uniqueOperator) {
        String fieldName = formattedLogicDetails.substringBefore(uniqueOperator);
        if (String.isBlank(newFieldName)) {
            newFieldName = fieldName;
        }
        if (fieldName.length() < newFieldName.length()) {
            newFieldName = fieldName;
        }
        return newFieldName.trim();
    }

    private static String retrieveFieldValue(String formattedLogicDetails, String uniqueOperator) {
        String fieldValue = '';
        for (String operator : operators) {
            String newFieldValue = formattedLogicDetails.substringAfter(uniqueOperator).substringBefore(operator);
            if (fieldValue == null || newFieldValue.length() < fieldValue.length() && newFieldValue != '' || fieldValue == '') {
                if (newFieldValue.contains(' )')) {
                    newFieldValue = newFieldValue.substringBefore(' )');
                }
                fieldValue = newFieldValue.trim();
            }
        }
        return fieldValue;
    }

    private static String retrieveOperator(String formattedLogicDetails, String fieldValue, String fieldName) {
        String operator = formattedLogicDetails.substringAfter(fieldName).substringBefore(fieldValue);
        return operator.trim();
    }

    public class LogicWrapper {
        public List<SingleLogicWrapper> singleLogicWrappers;
        public String order;

        public LogicWrapper() {
            order = '';
        }
    }
    public class SingleLogicWrapper {
        public String fieldName;
        public String operator;
        public String value;
        public Integer order;

        public SingleLogicWrapper() {
        }
    }

    //    private static void compareLogicFieldsToApplicationFields(String fieldName, hed__Application__c application, String fieldValue) {
//        String [] splitName = fieldName.split('\\.');
//        List<String> formattedSplitNames = new List<String>();
//        String fieldValueWithoutQuotes = fieldValue.replace('\'', '').trim();
//        for (String singleName : splitName) {
//            formattedSplitNames.add(singleName.trim());
//        }
//        if (!formattedSplitNames.isEmpty()) {
//            if (formattedSplitNames[0] == APPLICATION_API_NAME) {
//                Boolean checkCondition = application.get(formattedSplitNames[1]) == fieldValueWithoutQuotes;
//                finalCondition += checkCondition;
//            } else {
//                for (String keyValue : parentObjectToObjectPath.keySet()) {
//                    if (keyValue != APPLICATION_API_NAME) {
//                        if (formattedSplitNames[0] == parentObjectToObjectPath.get(keyValue).split('\\.')[0]) {
//                            Boolean checkCondition = application.getSObject(formattedSplitNames[0]).get(formattedSplitNames[1]) == fieldValueWithoutQuotes;
//                            finalCondition += checkCondition;
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    private static String formatFinalCondition() {
//        String formattedFinalCondition = finalCondition.replaceAll('OR', '||').replaceAll('AND', '&&');
//        return formattedFinalCondition;
//    }
}
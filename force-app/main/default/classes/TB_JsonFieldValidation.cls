public with sharing class TB_JsonFieldValidation {

    public static void handleLogicFieldCorrectness (List<SObject> sObjects, Map<Id, SObject> idToOldSObject, List<String> fieldNames) {
        List<SObject> sObjectsToVerify = filterObjectsToVerify(sObjects, idToOldSObject, fieldNames);
        
        for (SObject singleSObject : sObjectsToVerify) {
            for (String fieldName : fieldNames) {
                String errorMessage;
                String fieldValue = String.valueOf(singleSObject.get(fieldName));
                if (String.isNotBlank(fieldValue)) {
                    fieldValue = fixApostrophes(fieldValue);
                    fieldValue = fixSigns(fieldValue);

                    singleSObject.put(fieldName, fieldValue);

                    errorMessage = validateNoOfBrackets(fieldName, fieldValue, errorMessage);
                    errorMessage = validateNoOfApostrophes(fieldName, fieldValue, errorMessage);

                    if (String.isNotBlank(errorMessage)) {
                        singleSObject.addError(errorMessage);
                    }
                }
            }
        }
    }

    public static void handleJsonFieldCorrectness (List<SObject> sObjects, Map<Id, SObject> idToOldSObject, List<String> fieldNames) {
        List<SObject> sObjectsToVerify = filterObjectsToVerify(sObjects, idToOldSObject, fieldNames);

        for (SObject singleSObject : sObjectsToVerify) {
            String errorMessage;
            for (String fieldName : fieldNames) {
                errorMessage = validateTyposInObjectAndFieldNames(singleSObject, fieldName);

                if (String.isNotBlank(errorMessage)) {
                    singleSObject.addError(errorMessage);
                }
            }
        }
    }

    private static List<SObject> filterObjectsToVerify (List<SObject> sObjects, Map<Id, SObject> idToOldSObject, List<String> fieldNames) {
        Boolean isInsert = idToOldSObject == null;
        List<SObject> sObjectsToVerify = new List<SObject>();
        if (isInsert) {
            sObjectsToVerify = sObjects;
        } else {
            for (SObject sObj : sObjects) {
                for (String fieldName : fieldNames) {
                    String newFieldValue = String.valueOf(sObj.get(fieldName));
                    String oldFieldValue = String.valueOf(idToOldSObject.get(sObj.Id).get(fieldName));
                    if (newFieldValue != oldFieldValue) {
                        sObjectsToVerify.add(sObj);
                    }
                }
            }
        }
        return sObjectsToVerify;
    }

    private static String fixApostrophes (String fieldValue) {
        return fieldValue.replaceAll('\"', '\'');
    }

    private static String fixSigns (String fieldValue) {
        fieldValue = fieldValue.replaceAll('==', '=');
        fieldValue = fieldValue.replaceAll('=!', '!=');
        return fieldValue;
    }

    private static String validateNoOfBrackets (String fieldName, String fieldValue, String errorMessage) {
        Integer noOfOpenBrackets = fieldValue.countMatches('(');
        Integer noOfClosingBrackets = fieldValue.countMatches(')');

        if (noOfOpenBrackets != noOfClosingBrackets) {
            List<Object> parameters = new List<Object>{ fieldName };
            errorMessage = String.format(Label.TB_JSON_Missing_Brackets, parameters);
        }
        return errorMessage;
    }

    private static String validateNoOfApostrophes (String fieldName, String fieldValue, String errorMessage) {
        Integer noOfApostrophes = fieldValue.countMatches('\'');

        if (Math.mod(noOfApostrophes, 2) == 1) {
            List<Object> parameters = new List<Object>{ fieldName };
            errorMessage = String.format(Label.TB_JSON_Missing_Apostrophes, parameters);
        }
        return errorMessage;
    }

    private static String validateTyposInObjectAndFieldNames (SObject sObj, String jsonToVerify) {
        TB_AdmissionsProcessTriggerHelper.LogicWrapper logicWrapper = (TB_AdmissionsProcessTriggerHelper.LogicWrapper) JSON.deserialize(String.valueOf(sObj.get(jsonToVerify)), TB_AdmissionsProcessTriggerHelper.LogicWrapper.class);

        if (logicWrapper.singleLogicWrappers == null) {
            return null;
        }

        String errorMessage;
        for (TB_AdmissionsProcessTriggerHelper.SingleLogicWrapper singleLogicWrapper : logicWrapper.singleLogicWrappers) {
            String fieldName = singleLogicWrapper.fieldName.substringAfter('.');
            String relationshipName = singleLogicWrapper.fieldName.substringBefore('.');

            errorMessage = validateObjectExistence(fieldName, relationshipName, jsonToVerify, errorMessage);
            errorMessage = validateObjectCorrectness(fieldName, relationshipName, jsonToVerify, errorMessage);
            errorMessage = validateFieldCorrectness(fieldName, relationshipName, jsonToVerify, errorMessage);
        }

        return errorMessage;
    }

    private static String validateObjectExistence(String fieldName, String relationshipName, String jsonToVerify, String errorMessage) {
        if (String.isBlank(fieldName)) {
            List<Object> parameters = new List<Object>{
                relationshipName, jsonToVerify
            };
            errorMessage = String.format(Label.TB_JSON_Missing_Object, parameters);
        }
        return errorMessage;
    }

    private static String validateObjectCorrectness (String fieldName, String relationshipName, String jsonToVerify, String errorMessage) {
        String userFriendlyRelationshipName = TB_AdmissionsProcessTriggerHelper.objectPathToParentObject.get(relationshipName);
        if (String.isNotBlank(fieldName)
            && String.isBlank(userFriendlyRelationshipName)
        ) {
            List<Object> parameters = new List<Object>{
                relationshipName, jsonToVerify
            };
            errorMessage = String.format(Label.TB_JSON_Wrong_Object, parameters);
        }
        return errorMessage;
    }

    private static String validateFieldCorrectness (String fieldName, String relationshipName, String jsonToVerify, String errorMessage) {
        String userFriendlyRelationshipName = TB_AdmissionsProcessTriggerHelper.objectPathToParentObject.get(relationshipName);
        Set<String> objectFields = TB_AdmissionsProcessTriggerHelper.relationshipToFields?.get(relationshipName);

        if (String.isNotBlank(userFriendlyRelationshipName)
            && !objectFields.contains(fieldName.toLowerCase())
        ) {
            List<Object> parameters = new List<Object> {
                userFriendlyRelationshipName + fieldName, jsonToVerify
            };
            errorMessage = String.format(Label.TB_JSON_Missing_Field, parameters);
        }
        return errorMessage;
    }
}
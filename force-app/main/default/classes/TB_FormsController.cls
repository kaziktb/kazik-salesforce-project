/**
 * Created by jowitakozlak on 02/07/2021.
 */

public with sharing class TB_FormsController {

    public static String signatureSigned = System.Label.TB_Signature_Signed;
    public static String signatureNotAllowed = System.Label.TB_Signature_Not_Allowed;
    public static String signatureFirstLine = System.Label.TB_Signature_First_Line;
    public static String signatureSecondLine = System.Label.TB_Signature_Second_Line;

    public static List<String> roleFieldNames = new List<String> {
        'Evaluated', 'Evaluator', 'Supervisor', 'Rector', 'Administrator'
    };

    private class TB_FormsControllerException extends Exception {
    }

    @AuraEnabled
    public static List<DataCollectionsWrapper> getDataCollectionsFromJSON(String stageId) {

        List<TB_JSON_Wrapper__c> jsonWrappers = [
            SELECT Id, TB_Order__c, TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_Id__c = :stageId
            ORDER BY TB_Order__c
        ];

        Set<TB_Data_Collection__c> dataCollections = new Set<TB_Data_Collection__c>();
        for (TB_JSON_Wrapper__c jsonWrapper : jsonWrappers) {
            List<TB_Data_Collection__c> partialDataCollections =
                (List<TB_Data_Collection__c>) JSON.deserialize(jsonWrapper.TB_Wrapper_Value__c, List<TB_Data_Collection__c>.class);
            for (TB_Data_Collection__c dataCollection : partialDataCollections) {
                if (dataCollection.TB_Active__c == true) {
                    dataCollections.add(dataCollection);
                }
            }
        }

        List<DataCollectionsWrapper> dataCollectionsWrappers = new List<DataCollectionsWrapper>();
        for (TB_Data_Collection__c dataCollection : dataCollections) {
            DataCollectionsWrapper dataCollectionsWrapper = new DataCollectionsWrapper(dataCollection);
            if (dataCollection.TB_Data_Type__c == 'Checkbox') {
                if (String.isBlank(dataCollection.TB_Value_Text__c)) {
                    dataCollectionsWrapper.checkboxValue = false;
                } else {
                    dataCollectionsWrapper.checkboxValue = Boolean.valueOf(dataCollection.TB_Value_Text__c);
                }
            }
            if (dataCollection.TB_Data_Type__c == 'Text (Long)') {
                if (String.isBlank(dataCollection.TB_Value_Long_Text__c)) {
                    dataCollectionsWrapper.charactersLeft = dataCollection.TB_Characters__c;
                } else {
                    dataCollectionsWrapper.charactersLeft = dataCollection.TB_Characters__c - dataCollection.TB_Value_Long_Text__c.length();
                }
            }
            if (dataCollection.TB_Data_Type__c == 'Picklist') {
                List<String> picklistChoicesPl = dataCollection.TB_Picklist_Values_PL__c.split(';');
                List<String> picklistChoicesEn = dataCollection.TB_Picklist_Values_EN__c.split(';');
                List<String> picklistAPINames = dataCollection.TB_Picklist_API_Names__c.split(';');
                dataCollectionsWrapper.picklistAPINames = picklistAPINames;
                dataCollectionsWrapper.showPicklistInput = true;
                dataCollectionsWrapper.picklistChoicesPl = picklistChoicesPl;
                dataCollectionsWrapper.picklistChoicesEn = picklistChoicesEn;
            }
            //przypadek headerów i plikow bez inputu
            // TODO może dodać jakiś osobny warunek na headera? purpose?
            if (String.isBlank(dataCollection.TB_Data_Type__c)) {
                dataCollectionsWrapper.showHeader = true;
            }
            if (dataCollection.TB_File__c) {
                dataCollectionsWrapper.showHeader = false;
            }
            if (dataCollection.TB_Web_Excluded__c && !validateUser(stageId)) {
                dataCollectionsWrapper.isWebExcluded = true;
            }
            if (dataCollection.TB_Purpose__c != 'Header') {
                if (dataCollection.TB_Name_PL__c != null && dataCollection.TB_Name_PL__c.contains('<')) {
                    String nameWithoutMarkersPL = dataCollection.TB_Name_PL__c.replaceAll('<[^>]+>',' ');
                    dataCollectionsWrapper.clearNamePl = nameWithoutMarkersPL;
                } else {
                    dataCollectionsWrapper.clearNamePl = dataCollection.TB_Name_PL__c;
                }
                if (dataCollection.TB_Name_EN__c != null && dataCollection.TB_Name_EN__c.contains('<')) {
                    String nameWithoutMarkersEN = dataCollection.TB_Name_EN__c.replaceAll('<[^>]+>',' ');
                    dataCollectionsWrapper.clearNameEn = nameWithoutMarkersEN;
                } else {
                    dataCollectionsWrapper.clearNameEn = dataCollection.TB_Name_EN__c;
                }
            }
            dataCollectionsWrappers.add(dataCollectionsWrapper);
        }

        return dataCollectionsWrappers;
    }

    @AuraEnabled
    public static Boolean isObjection(String stageId) {

        TB_Employee_Evaluation_Stage__c employeeEvaluationStage = [
            SELECT Id, TB_Employee_Stage_Type__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: stageId
        ];

        return employeeEvaluationStage.TB_Employee_Stage_Type__c == 'Objection from Assessment';
    }

    @AuraEnabled
    public static Boolean isTeachingLoadRealized(String stageId) {

        TB_Employee_Evaluation_Stage__c employeeEvaluationStage = [
            SELECT Id, TB_Evaluated__c, TB_Evaluated__r.TB_Employee_Group__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: stageId
        ];

        List<hed__Attribute__c> attributes = [
            SELECT Id, TB_Teaching_Load_Realized__c
            FROM hed__Attribute__c
            WHERE hed__Contact__c = :employeeEvaluationStage.TB_Evaluated__c
            AND hed__Attribute_Type__c = 'Teaching_Load'
            AND TB_Academic_Year__c = '2020/2021'
            ORDER BY CreatedDate DESC
        ];

        hed__Attribute__c attribute = new hed__Attribute__c();
        if(!attributes.isEmpty()) {
            attribute = attributes[0];
        }

        return String.isNotBlank(String.valueOf(attribute.TB_Teaching_Load_Realized__c))
            || employeeEvaluationStage.TB_Evaluated__r.TB_Employee_Group__c == 'Scientist';
    }

    @AuraEnabled
    public static Boolean evaluationReadyToSignByEvaluated(String stageId) {

        String currentUserId = UserInfo.getUserId();

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Evaluator_Signature__c, TB_Evaluated__r.TB_User__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: stageId
        ];

        return (
            stage.TB_Employee_Stage_Type__c == 'Evaluation of Academic Activity'
                && stage.TB_Evaluator_Signature__c
                && currentUserId == stage.TB_Evaluated__r.TB_User__c
        );
    }

    @AuraEnabled
    public static Boolean validateUser(String stageId) {

        Boolean readOnly = true;
        String currentUserId = UserInfo.getUserId();

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Evaluated__r.TB_User__c, TB_Evaluator__r.TB_User__c,
                TB_Supervisor__r.TB_User__c, TB_Rector__r.TB_User__c, TB_Administrator__r.TB_User__c,
                TB_Evaluated_Sharing_Mode__c, TB_Evaluator_Sharing_Mode__c, TB_Supervisor_Sharing_Mode__c,
                TB_Rector_Sharing_Mode__c, TB_Administrator_Sharing_Mode__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: stageId
        ];

        for (String singleFieldName : roleFieldNames) {
            Contact con = (Contact) stage.getSObject('TB_' + singleFieldName + '__r');
//            Id userId = '';
//            if ( String.isNotBlank(con.TB_User__c)) {
//                userId = con.TB_User__c;
//            }
            Id userId = con.TB_User__c;
            String sharingMode = String.valueOf(stage.get('TB_' + singleFieldName + '_Sharing_Mode__c'));
            readOnly = readOnly && !( userId == currentUserId && sharingMode == 'Edit');
        }

        return readOnly;
    }

    @AuraEnabled
    public static String signAndSend(String stageId) {

        String currentUserId = UserInfo.getUserId();
        String signatureNotification = '';

        List<String> roleFieldNamesForSignature = new List<String>();
        for(Integer i = 0; i < roleFieldNames.size() - 1; i++) {
            roleFieldNamesForSignature.add(roleFieldNames[i]);
        }

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Evaluated__r.TB_User__c, TB_Evaluator__r.TB_User__c,
                TB_Supervisor__r.TB_User__c, TB_Rector__r.TB_User__c, TB_Administrator__r.TB_User__c,
                TB_Evaluated_Signature__c, TB_Evaluator_Signature__c, TB_Supervisor_Signature__c, TB_Rector_Signature__c,
                TB_Date_of_Evaluated_Signature__c, TB_Date_of_Evaluator_Signature__c, TB_Date_of_Supervisor_Signature__c,
                TB_Date_of_Rector_Signature__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: stageId
        ];

        for (String singleFieldName : roleFieldNamesForSignature) {
            Contact con = (Contact) stage.getSObject('TB_' + singleFieldName + '__r');
            Id userId = con.TB_User__c;
            Boolean signature = Boolean.valueOf(stage.get('TB_' + singleFieldName + '_Signature__c'));
            Datetime dateOfSignature = Datetime.valueOf(stage.get('TB_Date_of_' + singleFieldName + '_Signature__c'));

            if (currentUserId == userId) {
                if (signature) {
                    signatureNotification = signatureSigned + ' ' + dateOfSignature.format('dd.MM.yyyy\', \'HH:mm:ss', 'Poland');
                    break;
                } else {
                    signatureNotification = signatureFirstLine + ' ' + UserInfo.getName() + signatureSecondLine;
                    break;
                }
            } else {
                signatureNotification = signatureNotAllowed;
            }
        }

        return signatureNotification;
    }

    @AuraEnabled
    public static void updateSignature(String stageId) {

        String currentUserId = UserInfo.getUserId();

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Evaluated__r.TB_User__c, TB_Evaluator__r.TB_User__c,
                TB_Supervisor__r.TB_User__c, TB_Rector__r.TB_User__c, TB_Administrator__r.TB_User__c,
                TB_Evaluated_Signature__c, TB_Evaluator_Signature__c, TB_Supervisor_Signature__c, TB_Rector_Signature__c,
                TB_Date_of_Evaluated_Signature__c, TB_Date_of_Evaluator_Signature__c, TB_Date_of_Supervisor_Signature__c,
                TB_Date_of_Rector_Signature__c, TB_Employee_Evaluation__r.TB_Evaluated__c,
                TB_Employee_Evaluation__r.TB_Evaluator__c, TB_Employee_Evaluation__r.TB_Supervisor__c,
                TB_Employee_Evaluation__r.TB_Rector__c, TB_Employee_Evaluation__r.TB_Evaluation_Form_Completion_Date__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: stageId
        ];

        if(currentUserId == stage.TB_Evaluated__r.TB_User__c) {
            stage.TB_Date_of_Evaluated_Signature__c = Datetime.valueOf(System.now().format('yyyy-MM-dd\' \'HH:mm:ss', 'Poland'));
            stage.TB_Evaluated_Signature__c = true;
        } else if(currentUserId == stage.TB_Evaluator__r.TB_User__c && stage.TB_Employee_Evaluation__r.TB_Evaluation_Form_Completion_Date__c == null) {
            stage.TB_Date_of_Evaluator_Signature__c = Datetime.valueOf(System.now().format('yyyy-MM-dd\' \'HH:mm:ss', 'Poland'));
            stage.TB_Evaluator_Signature__c = true;
        } else if(currentUserId == stage.TB_Supervisor__r.TB_User__c) {
            stage.TB_Date_of_Supervisor_Signature__c = Datetime.valueOf(System.now().format('yyyy-MM-dd\' \'HH:mm:ss', 'Poland'));
            stage.TB_Supervisor_Signature__c = true;
        } else if(currentUserId == stage.TB_Rector__r.TB_User__c) {
            stage.TB_Date_of_Rector_Signature__c = Datetime.valueOf(System.now().format('yyyy-MM-dd\' \'HH:mm:ss', 'Poland'));
            stage.TB_Rector_Signature__c = true;
        }

        try {
            update stage;
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e, TB_FormsControllerException.class);
        }
    }

    @AuraEnabled
    public static Boolean validateDataCollectionsWithFiles(List<Id> dataCollectionIdsWithExpectedFiles) {

        List<TB_Employee_Evaluation_Stage_Document__c> employeeEvaluationStageDocuments = [
            SELECT Id, TB_Data_Collection__c
            FROM TB_Employee_Evaluation_Stage_Document__c
            WHERE TB_Data_Collection__c IN : dataCollectionIdsWithExpectedFiles
        ];

        Set<Id> dataCollectionsIdsWithFiles = new Set<Id>();
        for (TB_Employee_Evaluation_Stage_Document__c stageDocument : employeeEvaluationStageDocuments) {
            dataCollectionsIdsWithFiles.add(stageDocument.TB_Data_Collection__c);
        }

        return dataCollectionIdsWithExpectedFiles.size() != dataCollectionsIdsWithFiles.size();
    }

    @AuraEnabled
    public static String updateDataCollections(String dataCollectionsJSON) {

        String errorMessage = '';
        Set<TB_Data_Collection__c> dataCollections =
            (Set<TB_Data_Collection__c>) JSON.deserialize(dataCollectionsJSON, Set<TB_Data_Collection__c>.class);

        List<TB_Log__c> logs = new List<TB_Log__c>();
        try {
            if (!dataCollections.isEmpty()) {
                Database.SaveResult[] results = Database.update(
                    new List<TB_Data_Collection__c>(dataCollections),
                    false
                );
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        for (Database.Error error : result.getErrors()) {
                            if (String.isNotBlank(error.getMessage())) {
                                if(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                                    String errorLine = error.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ').substringBefore(': [');
                                    errorMessage = errorLine;
                                } else {
                                    errorMessage = error.getMessage();
                                }
                            } else {
                                errorMessage = System.Label.TB_Toast_Error_Message_Wrong;
                                logs.add(TB_LogUtils.registerLog(error.getMessage(), TB_FormsController.class));
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            errorMessage = System.Label.TB_Toast_Error_Message_Wrong;
            logs.add(TB_LogUtils.registerLog(e));
        }

        if(!logs.isEmpty()) {
            insert logs;
        }

        return errorMessage;
    }

    @AuraEnabled
    public static void changeStageStatusToInProgress(String stageId) {

        TB_Employee_Evaluation_Stage__c employeeEvaluationStage = [
            SELECT Id, TB_Evaluation_Stage_Status__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: stageId
        ];

        if (employeeEvaluationStage.TB_Evaluation_Stage_Status__c == 'New') {
            employeeEvaluationStage.TB_Evaluation_Stage_Status__c = 'In Progress';
            try {
                update employeeEvaluationStage;
            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e, TB_FormsControllerException.class);
            }
        }
    }

    @AuraEnabled
    public static Boolean finalMarkGiven(String stageId) {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Evaluation__r.TB_Final_Mark__c, TB_Employee_Stage_Type__c,
                TB_Employee_Evaluation__r.TB_Employee_Evaluation__c, TB_Evaluated__r.TB_User__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: stageId
        ];

        Boolean isEvaluated = UserInfo.getUserId() == stage.TB_Evaluated__r.TB_User__c;
        return (
            stage.TB_Employee_Stage_Type__c == 'Final Assessment'
                && String.isNotBlank(stage.TB_Employee_Evaluation__r.TB_Final_Mark__c)
                && String.isBlank(stage.TB_Employee_Evaluation__r.TB_Employee_Evaluation__c)
                && isEvaluated
        );
    }

    public class DataCollectionsWrapper
    {
        @AuraEnabled public TB_Data_Collection__c dc {get;set;}
        @AuraEnabled public Boolean showTextInput {get;set;}
        @AuraEnabled public Boolean showLongTextInput {get;set;}
        @AuraEnabled public Boolean showCheckboxInput {get;set;}
        @AuraEnabled public Boolean showNumberInput {get;set;}
        @AuraEnabled public Boolean showDateInput {get;set;}
        @AuraEnabled public Boolean showPicklistInput {get;set;}
        @AuraEnabled public List<String> picklistChoicesPl {get;set;}
        @AuraEnabled public List<String> picklistChoicesEn {get;set;}
        @AuraEnabled public List<String> picklistAPINames {get;set;}
        @AuraEnabled public String picklistValueLabel {get;set;}
        @AuraEnabled public Boolean showFileInput {get;set;}
        @AuraEnabled public Boolean showHeader {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        @AuraEnabled public String clearNamePl {get;set;}
        @AuraEnabled public String clearNameEn {get;set;}
        @AuraEnabled public Decimal charactersLeft {get;set;}
        @AuraEnabled public Boolean toUpdate {get;set;}
        @AuraEnabled public Boolean isWebExcluded {get;set;}
        @AuraEnabled public Boolean isReadOnly {get;set;}
        @AuraEnabled public Boolean checkboxValue {get;set;}

        public DataCollectionsWrapper(TB_Data_Collection__c dataCollection) {
            this.dc = dataCollection;
            this.showTextInput = dataCollection.TB_Data_Type__c == 'Text';
            this.showLongTextInput = dataCollection.TB_Data_Type__c == 'Text (Long)';
            this.showCheckboxInput = dataCollection.TB_Data_Type__c == 'Checkbox';
            this.showNumberInput = dataCollection.TB_Data_Type__c == 'Number';
            this.showDateInput = dataCollection.TB_Data_Type__c == 'Date';
            this.showPicklistInput = false;
            this.picklistChoicesPl = null;
            this.picklistChoicesEn = null;
            this.picklistAPINames = null;
            this.showFileInput = dataCollection.TB_File__c;
            this.showHeader = false;
            this.isRequired = dataCollection.TB_Required__c;
            this.clearNamePl = '';
            this.clearNameEn = '';
            this.toUpdate = false;
            this.isWebExcluded = false;
            this.picklistValueLabel = dataCollection.TB_Value_Text__c;
            this.isReadOnly = dataCollection.TB_Read_Only__c;
            this.charactersLeft = dataCollection.TB_Characters__c;
        }
    }
}
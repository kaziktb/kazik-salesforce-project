public without sharing class TB_GenericJsonWrapperGenerator {
  public static void upsertJsonWrappers(List<SObject> sObjects) {
    Map<Id, TB_JSON_Wrapper__c> parentIdToParentJsonWrapper = new Map<Id, TB_JSON_Wrapper__c>();
    List<TB_JSON_Wrapper__c> jsonWrappersToUpsert = new List<TB_JSON_Wrapper__c>();
    List<SObjectWrapper> sObjectWrappers = new List<SObjectWrapper>();

    for (SObject sObj : sObjects) {
      sObjectWrappers.add(new SObjectWrapper(sObj));
    }

    Map<String, String> sObjectTypeToParentField = fetchParentRelation(
      sObjectWrappers,
      'TB_Json_Parent'
    );

    for (SObjectWrapper sObjWrapper : sObjectWrappers) {
      if (sObjectTypeToParentField.containsKey(sObjWrapper.externalKey)) {
        String parentId = String.valueOf(
          sObjWrapper.sObj
            ?.get(sObjectTypeToParentField?.get(sObjWrapper.externalKey))
        );
        parentIdToParentJsonWrapper.put(parentId, null);
      }
    }

    List<TB_JSON_Wrapper__c> parentJsonWrappers = [
      SELECT Id, TB_Object_Id__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c IN :parentIdToParentJsonWrapper.keySet()
    ];

    for (TB_JSON_Wrapper__c parentJson : parentJsonWrappers) {
      parentIdToParentJsonWrapper.put(parentJson.TB_Object_Id__c, parentJson);
    }

    for (SObjectWrapper sObjWrapper : sObjectWrappers) {
      TB_JSON_Wrapper__c jsonWrapper = new TB_JSON_Wrapper__c(
        TB_Object_Id__c = sObjWrapper.sObjId,
        TB_Object_API_Name__c = sObjWrapper.objectName,
        TB_Portal_Type__c = sObjWrapper.portal,
        TB_Wrapper_Value__c = JSON.serialize(sObjWrapper.sObj),
        TB_Order__c = sObjWrapper.order,
        TB_Record_Code__c = sObjWrapper.recordCode,
        TB_Record_Type_Dev_Name__c = sObjWrapper.recordTypeDevName,
        TB_Record_Type_Id__c = sObjWrapper.recordTypeId
      );

      if (sObjectTypeToParentField.containsKey(sObjWrapper.externalKey)) {
        String parentIdFieldName = sObjectTypeToParentField
          ?.get(sObjWrapper.externalKey);
        String parentId = String.valueOf(
          sObjWrapper.sObj?.get(parentIdFieldName)
        );
        jsonWrapper.TB_Parent_JSON_Wrapper__c = parentIdToParentJsonWrapper
          ?.get(parentId)
          ?.Id;
      }

      jsonWrappersToUpsert.add(jsonWrapper);
    }

    upsert jsonWrappersToUpsert TB_Object_Id__c;
  }

  public static void deleteRelatedJsonWrappers(Map<Id, SObject> idTosObjects) {
    delete [
      SELECT Id
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c IN :idTosObjects.keySet()
    ];
  }

  private static Map<String, String> fetchParentRelation(
    List<SObjectWrapper> sObjectWrappers,
    String fieldSetName
  ) {
    Map<String, String> sObjectTypeToParentField = new Map<String, String>();
    Set<String> verifiedObjects = new Set<String>();

    for (SObjectWrapper sObjWrapper : sObjectWrappers) {
      if (verifiedObjects.contains(sObjWrapper.externalKey)) {
        continue;
      } else {
        verifiedObjects.add(sObjWrapper.externalKey);
      }

      Schema.SObjectType sObjectTypeObj = Schema.getGlobalDescribe()
        ?.get(sObjWrapper.objectName);
      Map<String, FieldSet> fieldSetNameToFieldSets = sObjectTypeObj.getDescribe()
        .fieldSets.getMap();

      String fieldSetNameWithRecordType =
        fieldSetName +
        '_' +
        sObjWrapper.recordTypeDevName;

      Schema.FieldSet fieldSetObj;
      if (fieldSetNameToFieldSets.containsKey(fieldSetNameWithRecordType)) {
        fieldSetObj = fieldSetNameToFieldSets.get(fieldSetNameWithRecordType);
      } else {
        fieldSetObj = fieldSetNameToFieldSets.get(fieldSetName);
      }

      String fieldPath = fieldSetObj?.getFields()[0]?.getFieldPath();

      if (String.isNotBlank(fieldPath)) {
        sObjectTypeToParentField.put(
          sObjWrapper.externalKey,
          fieldSetObj.getFields()[0].getFieldPath()
        );
      }
    }

    return sObjectTypeToParentField;
  }

  private class SObjectWrapper {
    SObject sObj;
    String sObjId;
    String recordTypeId;
    String recordTypeDevName;
    String objectName;
    String portal;
    String externalKey;
    Integer order = 0;
    String recordCode;

    public SObjectWrapper(SObject sObj) {
      this.sObj = sObj;
      this.sObjId = sObj.Id;

      DescribeSObjectResult describeResult = sObj.getSObjectType()
        .getDescribe();
      this.objectName = describeResult.name;

      if (describeResult.recordTypeInfos.size() > 1) {
        this.recordTypeId = String.valueOf(sObj?.get('RecordTypeId'));
        if (String.isNotBlank(this.recordTypeId)) {
          this.recordTypeDevName = TB_SObjectUtils.getRecordTypeNameById(
            this.objectName,
            this.recordTypeId
          );
        }
      }
      Map<String, SObjectField> fieldsMap = describeResult.fields.getMap();
      if (fieldsMap.containsKey('TB_Order__c')) {
        order = Integer.valueOf(sObj?.get('TB_Order__c'));
      }
      if (fieldsMap.containsKey('TB_Record_Code__c')) {
        recordCode = String.valueOf(sObj?.get('TB_Record_Code__c'));
      }
      if (fieldsMap.containsKey('TB_Portal_Type__c')) {
        this.portal = String.valueOf(sObj?.get('TB_Portal_Type__c'));
      }
      this.externalKey = this.objectName + this.recordTypeDevName;
    }
  }
}
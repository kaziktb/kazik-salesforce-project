/**
 * @author adam.peczkowski@thinkbeyond.cloud
 * This is a Controller for PDF document generation using uploaded HTML templates exported from MS Word documents.
 * The template should have merge fields formatted as ${SObjectAPIName.SObjectFieldAPIName}
 * This controller supports relationship fields. It also supports using static resources as images using ${Resource.StaticResourceName}
 * Custom replacements can be set to the replacements parameter using a JSON object: {"MergeField":"Merge field replacement value"}
 **/

public without sharing class TB_pdo_PdfGenerator {
  private static final String PARAM_RECORD_IDS = 'recordIds';
  private static final String PARAM_MERGE_FIELD_REPLACEMENTS = 'replacements';

  private static final String EMPTY_STRING = '';
  private static final String SPACE = ' ';
  private static final String DASH = '-';
  private static final String DOLLAR_SIGN = '$';
  private static final String BRACKET_OPEN = '(';
  private static final String BRACKET_CLOSE = ')';

  //Regexes
  private static final String BODY_SEPARATION_REGEX = '<body(.*|\\n*)>|<\\/body>';
  private static final String CLASS_STYLE_STRIPPING_REGEX = '\\s*class=.*?[^>\\s]*';
  private static final String OFFICE_START_TAG_PREFIX_REGEX = '<o:';
  private static final String OFFICE_START_TAG_PREFIX_REPLACEMENT = '<';
  private static final String OFFICE_END_TAG_PREFIX_REGEX = '</o:';
  private static final String OFFICE_END_TAG_PREFIX_REPLACEMENT = '</';
  private static final String MERGE_FIELD_REGEX = '\\$\\{(.|\\n|\\r)*?\\}';
  private static final String MERGE_FIELD_PREFIX_REGEX = '${';
  private static final String MERGE_FIELD_SUFFIX_REGEX = '}';
  private static final String ALL_HTML_TAGS_REGEX = '(<.+?>)';
  private static final String ITERATION_OBJECT_REGEX = ':.*\\((.|\\n|\\r)*\\)';

  private static final String DOT = '.';
  private static final String BOOLEAN_TRUE {
    get {
      return !Test.isRunningTest() && UserInfo.getLanguage() == 'pl'
        ? 'Tak'
        : 'Yes';
    }
  }
  private static final String BOOLEAN_FALSE {
    get {
      return !Test.isRunningTest() && UserInfo.getLanguage() == 'pl'
        ? 'Nie'
        : 'No';
    }
  }
  private static final String COLON = ':';
  private static final String SEMICOLON = ':';
  private static final String COMMA_SPACE = ', ';
  private static final String CURRENCY_SIGN = 'zł';
  private static final String PERCENT = '%';

  private static final String P_START_TAG = '<p>';
  private static final String P_END_TAG = '</p>';
  private static final String UNEXPECTED_ERROR = 'An unexpected error has occurred.';

  private List<String> recordIds { get; set; }
  private Map<String, String> replacements { get; set; }
  public String htmlValue { get; private set; }

  private ContentVersion template;
  private final Map<String, MergeField> mergeFields;
  private Map<SObjectType, Id> idsByObjectTypes;
  private Map<SObjectType, SObject> recordsByObjectTypes;

  public TB_pdo_PdfGenerator() {
    this.recordIds = ApexPages.currentPage()
      .getParameters()
      .get(PARAM_RECORD_IDS)
      .split(',');
    String replacements = ApexPages.currentPage()
      .getParameters()
      .get(PARAM_MERGE_FIELD_REPLACEMENTS);
    if (String.isNotBlank(replacements)) {
      try {
        this.replacements = (Map<String, String>) JSON.deserialize(
          replacements,
          Map<String, String>.class
        );
      } catch (Exception e) {
        handleWarning(e, 'Error when deserializing replacement JSON', null);
      }
    }
    if (getObjectTypes()) {
      this.htmlValue = getCleanHtmlBody(template.VersionData.toString());
      this.mergeFields = getMergeFieldsMap();
      if (!this.mergeFields.isEmpty() && getRecords(getFieldsByObjectTypes())) {
        replaceMergeFieldsWithValues();
      }
    }
  }

  /**
   * This method will get all object types fromm the recordIds parameter, put them in the idsByObjectTypes map and
   * find the template by ContentDocumentId or ContentVersionId.
   * @return true if successful, false if encountered an error
   **/
  private Boolean getObjectTypes() {
    Id documentOrVersionId;
    idsByObjectTypes = new Map<SObjectType, Id>();
    for (String recordId : recordIds) {
      if (recordId instanceof Id) {
        if (
          ((Id) recordId).getSobjectType() == ContentVersion.getSObjectType() ||
          ((Id) recordId).getSobjectType() == ContentDocument.getSObjectType()
        ) {
          documentOrVersionId = recordId;
        } else {
          idsByObjectTypes.put(((Id) recordId).getSobjectType(), (Id) recordId);
        }
      }
    }
    if (documentOrVersionId != null) {
      try {
        if (
          documentOrVersionId.getSobjectType() ==
          ContentVersion.getSObjectType()
        ) {
          template = [
            SELECT VersionData
            FROM ContentVersion
            WHERE Id = :documentOrVersionId
          ];
        } else {
          template = [
            SELECT VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :documentOrVersionId AND IsLatest = TRUE
          ];
        }
      } catch (Exception e) {
        this.htmlValue = handleError(
          e,
          'Template not found! Couldn\'t find a template with this ID: ' +
          documentOrVersionId,
          documentOrVersionId
        );
        return false;
      }
    } else {
      this.htmlValue = handleError(
        'Template not found! The template ID was not provided'
      );
      return false;
    }
    return true;
  }

  /**
   * @param htmlValue HTML contents of a file, exported from a MS Word document.
   *
   * @return Cleaned up HTML body without styling and MS Office tags stripped.
   **/
  public static String getCleanHtmlBody(String htmlValue) {
    try {
      //Matches the body tags, takes the value in between them and trims leading and trailing whitespaces
      htmlValue = htmlValue.split(BODY_SEPARATION_REGEX)[1].trim();
    } catch (Exception e) {
      return handleError(e, 'Problem matching the HTML body', null);
    }

    try {
      //Removes all class and style attributes in html tags (added by ms word)
      htmlValue = htmlValue.replaceAll(
        CLASS_STYLE_STRIPPING_REGEX,
        EMPTY_STRING
      );
      //Removes the "o:" (office) namespace prefix from all start tags - they all(?) have a standard html counterpart
      htmlValue = htmlValue.replaceAll(
        OFFICE_START_TAG_PREFIX_REGEX,
        OFFICE_START_TAG_PREFIX_REPLACEMENT
      );
      //Same as above but for end tags
      htmlValue = htmlValue.replaceAll(
        OFFICE_END_TAG_PREFIX_REGEX,
        OFFICE_END_TAG_PREFIX_REPLACEMENT
      );
    } catch (Exception e) {
      return handleError(e, 'MS Office HTML cleanup failed', null);
    }
    return htmlValue;
  }

  /**
   * @return A map of MergeField objects by the merge field name
   **/
  private Map<String, MergeField> getMergeFieldsMap() {
    Map<String, MergeField> mergeFields = new Map<String, MergeField>();
    try {
      Pattern mergeFieldsPattern = Pattern.compile(MERGE_FIELD_REGEX);
      Matcher mergeFieldsMatcher = mergeFieldsPattern.matcher(htmlValue);
      while (mergeFieldsMatcher.find()) {
        String toReplace = mergeFieldsMatcher.group();
        String key = toReplace.contains(COLON)
          ? toReplace.substringBetween(MERGE_FIELD_PREFIX_REGEX, COLON)
              .replaceAll(ALL_HTML_TAGS_REGEX, EMPTY_STRING)
          : toReplace.substringBetween(
                MERGE_FIELD_PREFIX_REGEX,
                MERGE_FIELD_SUFFIX_REGEX
              )
              .replaceAll(ALL_HTML_TAGS_REGEX, EMPTY_STRING);
        if (mergeFields.containsKey(key)) {
          mergeFields.get(key).addToReplace(toReplace);
        } else {
          mergeFields.put(key, new MergeField(toReplace, replacements));
        }
      }
    } catch (Exception e) {
      handleError(
        e,
        'Encountered an error when getting merge fields',
        String.join(recordIds, COMMA_SPACE)
      );
    }
    return mergeFields;
  }

  /**
   * @return A map of SObjectFields present in the template by SObjectTypes
   **/
  private Map<SObjectType, Set<MergeField>> getFieldsByObjectTypes() {
    Map<SObjectType, Set<MergeField>> fieldsBySObjectType = new Map<SObjectType, Set<MergeField>>();
    for (String key : mergeFields.keySet()) {
      MergeField mf = mergeFields.get(key);
      if (mf.isValid && !mf.isCustom) {
        if (fieldsBySObjectType.containsKey(mf.sObjectType)) {
          fieldsBySObjectType.get(mf.sObjectType).add(mf);
        } else {
          fieldsBySObjectType.put(mf.sObjectType, new Set<MergeField>{ mf });
        }
      } else {
        handleWarning(
          'Encountered an invalid merge field: ' + mf.mergeField,
          null
        );
      }
    }
    return fieldsBySObjectType;
  }

  /**
   * @param fieldsBySObjectType map of SObjectFields present in the template by SObjectType
   * This method will fetch records with all needed in the template and save them to the recordsByObjectTypes map
   * @return true if successful, false if encountered an error
   **/
  private Boolean getRecords(
    Map<SObjectType, Set<MergeField>> fieldsBySObjectType
  ) {
    this.recordsByObjectTypes = new Map<SObjectType, SObject>();
    for (SObjectType sObjectType : fieldsBySObjectType.keySet()) {
      if (!idsByObjectTypes.containsKey(sObjectType)) {
        handleWarning('No ID provided for sObjectType: ' + sObjectType, null);
        continue;
      }
      try {
        List<String> objectFields = new List<String>();
        Map<String, Set<String>> relationshipFields = new Map<String, Set<String>>();
        Map<String, String> relationshipParams = new Map<String, String>();
        for (MergeField mf : fieldsBySObjectType.get(sObjectType)) {
          if (mf.isChildRelationship) {
            if (!mf.childMergeFields.isEmpty()) {
              relationshipFields.put(
                mf.mergeField.substringAfter(DOT),
                new Set<String>()
              );
              relationshipParams.put(
                mf.mergeField.substringAfter(DOT),
                mf.childParams
              );
              for (String childMfKey : mf.childMergeFields.keySet()) {
                if (mf.childMergeFields.get(childMfKey).isValid) {
                  relationshipFields.get(mf.mergeField.substringAfter(DOT))
                    .add(
                      mf.childMergeFields.get(childMfKey)
                        .mergeField.substringAfter(DOT)
                    );
                } else {
                  handleWarning(
                    'Encountered an invalid merge field: ' +
                    mf.childMergeFields.get(childMfKey).mergeField,
                    null
                  );
                }
              }
            }
          } else {
            objectFields.add(mf.mergeField.substringAfter(DOT));
          }
        }
        for (String relationshipName : relationshipFields.keySet()) {
          String subQuery =
            '(SELECT ' +
            String.join(
              new List<String>(relationshipFields.get(relationshipName)),
              COMMA_SPACE
            ) +
            ' FROM ' +
            relationshipName;
          if (String.isNotBlank(relationshipParams.get(relationshipName))) {
            subQuery += ' WHERE ' + relationshipParams.get(relationshipName);
          }
          subQuery += BRACKET_CLOSE;
          objectFields.add(subQuery);
        }
        recordsByObjectTypes.put(
          sObjectType,
          Database.query(
            'SELECT ' +
            String.join(objectFields, COMMA_SPACE) +
            ' FROM ' +
            sObjectType.getDescribe().getName() +
            ' WHERE Id = \'' +
            idsByObjectTypes.get(sObjectType) +
            '\''
          )
        );
      } catch (Exception e) {
        handleError(
          e,
          'Encountered an error while fetching records',
          String.join(recordIds, COMMA_SPACE)
        );
        return false;
      }
    }
    return true;
  }

  /**
   * This method handles replacing the ${SObjectAPIName.SObjectFieldAPIName} merge fields with actual values
   * from MergeField objects
   **/
  private void replaceMergeFieldsWithValues() {
    try {
      for (String key : mergeFields.keySet()) {
        MergeField mf = mergeFields.get(key);
        if (mf.isValid) {
          if (!mf.hasReplacement) {
            mf.setReplacement(recordsByObjectTypes.get(mf.sObjectType));
          }
          if (
            mf.hasReplacement //Check in case the replacement assignment fails
          ) {
            for (String toReplace : mf.toReplace) {
              htmlValue = htmlValue.replace(toReplace, mf.replacementString);
            }
          }
        }
      }
    } catch (Exception e) {
      handleError(
        e,
        'Encountered an error when replacing merge fields with values',
        null
      );
    }
  }

  private class ChildMergeField extends MergeField {
    ChildMergeField(
      String mergeField,
      SObjectType sObjectType,
      Map<String, String> replacements
    ) {
      this.mergeField = mergeField.substringAfter(DOLLAR_SIGN)
        .replaceAll(ALL_HTML_TAGS_REGEX, EMPTY_STRING);
      this.isChildRelationship = false;
      this.toReplace = new Set<String>{ mergeField };
      this.isStaticResource = false;
      this.isCustom = false;
      checkReplacements(replacements);
      try {
        getSObjectTypeAndField(sObjectType);
      } catch (Exception e) {
        sObjectField = null;
        handleWarning(e, 'Error when handling the merge field.', null);
      }
    }
  }

  /**
   * This is an internal class for handling merge fields, the display format, SObjectType, SObjectField, name,
   * actual string to replace(it may contain html tags)
   **/
  private virtual class MergeField {
    public String mergeField { get; private set; }
    public Set<String> toReplace { get; private set; }
    public SObjectType sObjectType { get; private set; }
    public SObjectField sObjectField { get; private set; }
    private SObjectType relatedSObjectType { get; private set; }
    private SObjectField relatedSObjectField { get; private set; }
    private DisplayType displayType;
    public String replacementString { get; private set; }
    public Boolean isStaticResource { get; private set; }
    public Boolean isCustom { get; private set; }
    public Boolean isChildRelationship { get; private set; }
    public Map<String, MergeField> childMergeFields { get; private set; }
    public String childParams { get; private set; }

    public Boolean isValid {
      get {
        return (sObjectType != null &&
          (sObjectField != null ||
          (isChildRelationship && !childMergeFields.isEmpty()))) ||
          isStaticResource ||
          isCustom;
      }
    }
    public Boolean hasReplacement {
      get {
        return replacementString != null || isCustom;
      }
    }

    private MergeField() {
    }

    MergeField(String mergeField, Map<String, String> replacements) {
      this.isChildRelationship = mergeField.contains(COLON);
      this.mergeField = (this.isChildRelationship
          ? mergeField.substringBetween(MERGE_FIELD_PREFIX_REGEX, COLON)
          : mergeField.substringBetween(
              MERGE_FIELD_PREFIX_REGEX,
              MERGE_FIELD_SUFFIX_REGEX
            ))
        .replaceAll(ALL_HTML_TAGS_REGEX, EMPTY_STRING);
      this.toReplace = new Set<String>{ mergeField };
      this.isStaticResource = false;
      this.isCustom = false;
      checkReplacements(replacements);
      try {
        getSObjectTypeAndField();
        if (isChildRelationship)
          handleChildRelationShip(replacements);
      } catch (Exception e) {
        sObjectField = null;
        handleWarning(e, 'Error when handling the merge field.', null);
      }
    }

    private void handleChildRelationShip(Map<String, String> replacements) {
      this.childMergeFields = new Map<String, MergeField>();
      try {
        String wholeMergeField = new List<String>(toReplace)[0];
        String iterationObject;
        Pattern iterationObjectPattern = Pattern.compile(
          ITERATION_OBJECT_REGEX
        );
        Matcher iterationObjectMatcher = iterationObjectPattern.matcher(
          wholeMergeField
        );
        if (iterationObjectMatcher.find()) {
          iterationObject = iterationObjectMatcher.group()
            .substringBetween(COLON, BRACKET_OPEN)
            .trim();
          this.childParams = iterationObjectMatcher.group()
            .substringBetween(BRACKET_OPEN, BRACKET_CLOSE);
        }
        Pattern mergeFieldsPattern = Pattern.compile(
          '\\$' +
          iterationObject +
          '\\.([A-z]|\\d|\\.)*'
        );
        Matcher mergeFieldsMatcher = mergeFieldsPattern.matcher(
          wholeMergeField
        );
        while (mergeFieldsMatcher.find()) {
          String toReplace = mergeFieldsMatcher.group();
          String key = toReplace.substringAfter(DOLLAR_SIGN);
          if (childMergeFields.containsKey(key)) {
            childMergeFields.get(key).addToReplace(toReplace);
          } else {
            childMergeFields.put(
              key,
              new ChildMergeField(toReplace, relatedSObjectType, replacements)
            );
          }
        }
      } catch (Exception e) {
        handleError(e, 'Encountered an error when getting merge fields', null);
      }
    }

    /**
     * This method looks for replacements for custom fields given in params
     **/
    private void checkReplacements(Map<String, String> replacements) {
      if (replacements != null && replacements.containsKey(mergeField)) {
        replacementString = replacements.get(mergeField);
        isCustom = true;
      }
    }

    private void getSObjectTypeAndField() {
      getSObjectTypeAndField(null);
    }

    /**
     * This method processes merge fields, creates replacement string for static resources and gets the SObjectType
     * and SObjectField for a merge field
     **/
    private void getSObjectTypeAndField(SObjectType sObjectTypeOverride) {
      String sObjectApiName = mergeField.substringBefore(DOT);
      if (sObjectApiName == 'Resource') {
        this.isStaticResource = true;
        this.replacementString =
          '<img src="/resource/' +
          mergeField.substringAfter(DOT).substringBefore(SPACE) +
          '"';
        if (
          String.isNotBlank(
            mergeField.substringAfter(DOT).substringAfter(SPACE)
          )
        ) {
          this.replacementString += SPACE + mergeField.substringAfter(SPACE);
        }
        this.replacementString += '/>';
      } else {
        SObjectType sObjectType = sObjectTypeOverride == null
          ? Schema.getGlobalDescribe().get(sObjectApiName)
          : sObjectTypeOverride;
        if (sObjectType != null) {
          this.sObjectType = sObjectType;
          if (isChildRelationship) {
            this.relatedSObjectType = getChildSObjectType();
            if (this.relatedSObjectType == null) {
              handleWarning(
                'Couldn\'t find child SObjectType: ' + mergeField,
                null
              );
            }
          } else {
            this.relatedSObjectType = sObjectType;
            String fieldString = mergeField.substringAfter(DOT);
            String fieldApiName = fieldString.substringBefore(DOT);
            SObjectField field = sObjectType.getDescribe()
              .fields.getMap()
              .get(fieldApiName);
            if (field == null) {
              fieldApiName = getIdFieldFromRelationship(fieldApiName);
              field = sObjectType.getDescribe()
                .fields.getMap()
                .get(fieldApiName);
            }
            this.sObjectField = field;
            this.relatedSObjectField = field;
            if (field == null) {
              handleWarning(
                'Couldn\'t find field: ' +
                fieldString +
                ' in SObject: ' +
                sObjectType,
                null
              );
            } else {
              this.displayType = field.getDescribe().getType();
              getRelatedField(fieldString);
            }
          }
        } else {
          handleWarning('Couldn\'t find SObjectType: ' + sObjectApiName, null);
        }
      }
    }

    private SObjectType getChildSObjectType() {
      for (
        ChildRelationship relationship : sObjectType.getDescribe()
          .childRelationships
      ) {
        if (relationship.relationshipName == mergeField.substringAfter(DOT)) {
          return relationship.childSObject;
        }
      }
      return null;
    }

    /**
     * This method processes SObject relationships and sets appropriate DisplayType
     * @param fieldString SObjectField API Name with relationships, e.g. "Account.Contact.Name"
     **/
    private void getRelatedField(String fieldString) {
      if (relatedSObjectField == null) {
        handleWarning(
          'Couldn\'t find field: ' +
          fieldString +
          ' in SObject: ' +
          relatedSObjectType,
          null
        );
        sObjectField = null;
        return;
      }
      List<SObjectType> referenceTo = relatedSObjectField.getDescribe()
        .getReferenceTo();
      String fieldApiName = fieldString.substringBefore(DOT);
      if (
        relatedSObjectType.getDescribe().fields.getMap().get(fieldApiName) ==
        null
      ) {
        fieldApiName = getIdFieldFromRelationship(fieldApiName);
      }
      if (referenceTo.isEmpty()) {
        handleWarning('Field is not a reference: ' + fieldApiName, null);
      } else if (referenceTo.size() > 1) {
        handleWarning(
          'Field is a reference to multiple objects: ' + fieldApiName,
          null
        );
      } else {
        String relatedFieldApiName = fieldString.substringAfter(DOT)
          .substringBefore(DOT);
        relatedSObjectType = referenceTo[0].getDescribe().getSObjectType();
        if (
          relatedSObjectType.getDescribe()
            .fields.getMap()
            .get(relatedFieldApiName) == null
        ) {
          relatedFieldApiName = getIdFieldFromRelationship(relatedFieldApiName);
        }
        relatedSObjectField = relatedSObjectType.getDescribe()
          .fields.getMap()
          .get(relatedFieldApiName);
        if (fieldString.contains(DOT)) {
          getRelatedField(fieldString.substringAfter(DOT));
        }
      }
    }

    /**
     * @param fieldApiName Relationship field API Name e.g. Account or Account__r(custom)
     * @return ID field api name e.g. AccountId or Account__c(custom)
     **/
    private String getIdFieldFromRelationship(String fieldApiName) {
      if (fieldApiName.endsWith('__c') || fieldApiName.endsWith('Id')) {
        return fieldApiName;
      }
      if (fieldApiName.endsWith('__r')) {
        fieldApiName = fieldApiName.replaceAll('__r$', '__c');
      } else {
        fieldApiName += 'Id';
      }
      return fieldApiName;
    }

    /**
     * This method will set a replacement string for the merge field, using the appropriate formatting
     * for the SObjectField's DisplayType
     * @param replacementSource Queried SObject from which a replacement is taken
     **/
    public void setReplacement(SObject replacementSource) {
      if (replacementSource == null) {
        handleWarning('No replacement for field: ' + mergeField, null);
        replacementString = isChildRelationship ? EMPTY_STRING : DASH;
        return;
      }
      Object replacementObject;
      if (replacementSource.getSObjectType() != sObjectType) {
        handleWarning(
          'Wrong SObjectType (' +
          replacementSource.getSObjectType().getDescribe().getName() +
          ') for the merge field (' +
          sObjectType.getDescribe().getName() +
          BRACKET_CLOSE,
          null
        );
      }
      String fieldString = mergeField;
      try {
        SObject replacementSObject = replacementSource;
        do {
          fieldString = fieldString.substringAfter(DOT);
          if (isChildRelationship) {
            String replacementTemplate = new List<String>(toReplace)[0];
            String mergeFieldReplacement = '';
            Pattern htmlPattern = Pattern.compile(ALL_HTML_TAGS_REGEX);
            Matcher htmlMatcher = htmlPattern.matcher(
              replacementTemplate.substringBefore(BRACKET_CLOSE)
            );
            while (htmlMatcher.find()) {
              mergeFieldReplacement += htmlMatcher.group();
            }
            replacementTemplate = replacementTemplate.replaceAll(
              '\\$\\{.*\\)',
              mergeFieldReplacement
            );
            replacementTemplate = replacementTemplate.replaceAll(
              ':\\}',
              EMPTY_STRING
            );
            String replacement = '';
            for (SObject obj : replacementSObject.getSObjects(fieldString)) {
              String childReplacement = replacementTemplate;
              for (String key : childMergeFields.keySet()) {
                childMergeFields.get(key).setReplacement(obj);
                for (String toReplace : childMergeFields.get(key).toReplace) {
                  childReplacement = childReplacement.replace(
                    toReplace,
                    childMergeFields.get(key).replacementString
                  );
                }
              }
              replacement += childReplacement;
            }
            replacementObject = replacement;
          } else if (
            replacementSObject.getPopulatedFieldsAsMap()
              .get(fieldString.substringBefore(DOT)) instanceof SObject
          ) {
            replacementSObject = (SObject) replacementSObject.getPopulatedFieldsAsMap()
              .get(fieldString.substringBefore(DOT));
          } else {
            replacementObject = replacementSObject.getPopulatedFieldsAsMap()
              .get(fieldString.substringBefore(DOT));
          }
        } while (fieldString.contains(DOT));
      } catch (Exception e) {
        handleWarning(
          e,
          'No such field (' +
          mergeField.substringAfter(DOT) +
          ') in SObject (' +
          sObjectType.getDescribe().getName() +
          BRACKET_CLOSE,
          null
        );
      }

      if (replacementObject == null) {
        replacementString = isChildRelationship ? EMPTY_STRING : DASH;
      } else if (replacementObject instanceof Boolean) {
        replacementString = (Boolean) replacementObject
          ? BOOLEAN_TRUE
          : BOOLEAN_FALSE;
      } else if (replacementObject instanceof Date) {
        replacementString = ((Date) replacementObject).format(); //Using standard format() because it uses user settings
      } else if (replacementObject instanceof Time) {
        Time value = (Time) replacementObject;
        replacementString = value.hour() + COLON + value.minute(); //No standard format()
      } else if (replacementObject instanceof Datetime) {
        replacementString = ((Datetime) replacementObject).format(); //Using standard format() because it uses user settings
      } else if (replacementObject instanceof Decimal) {
        Decimal value = (Decimal) replacementObject;
        switch on displayType {
          when CURRENCY {
            replacementString = value.setScale(2).format() + CURRENCY_SIGN;
          }
          when PERCENT {
            replacementString = value.setScale(2).format() + PERCENT;
          }
          when else {
            replacementString = value.setScale(2).format();
          }
        }
      } else if (replacementObject instanceof String) {
        String value = (String) replacementObject;
        switch on displayType {
          when MULTIPICKLIST {
            List<String> values = value.split(SEMICOLON);
            for (String picklistValue : values) {
              for (
                PicklistEntry picklistEntry : relatedSObjectField.getDescribe()
                  .getPicklistValues()
              ) {
                if (picklistEntry.getValue() == picklistValue) {
                  replacementString = picklistEntry.getLabel();
                }
              }
            }
            replacementString = String.join(
              value.split(SEMICOLON),
              COMMA_SPACE
            );
          }
          when PICKLIST {
            for (
              PicklistEntry picklistEntry : relatedSObjectField.getDescribe()
                .getPicklistValues()
            ) {
              if (picklistEntry.getValue() == value) {
                replacementString = picklistEntry.getLabel();
              }
            }
          }
          when else {
            replacementString = value;
          }
        }
      }
    }

    /**
     * This is for the instance when the same merge field is used in multiple places but it may be a bit different
     * sometimes Word will sneak a span (or maybe a different tag) into a merge field, so this will handle for the difference
     * @param toReplace string to replace with the merge field's replacement string
     **/
    public void addToReplace(String toReplace) {
      this.toReplace.add(toReplace);
    }
  }

  private static String handleError(
    Exception e,
    String customMessage,
    String recordId
  ) {
    if (e != null) {
      System.debug(e.getMessage());
      System.debug(e.getStackTraceString());
      TB_vu_Utils.registerLog(e, TB_pdo_PdfGenerator.class, recordId);
      if (String.isBlank(customMessage)) {
        return handleError(e.getMessage());
      } else {
        return handleError(customMessage);
      }
    } else {
      TB_vu_Utils.registerLog(
        customMessage,
        TB_pdo_PdfGenerator.class.getName(),
        null,
        recordId
      );
      if (String.isBlank(customMessage)) {
        return handleError(EMPTY_STRING);
      } else {
        return handleError(customMessage);
      }
    }
  }

  private static String handleError(String error) {
    if (String.isBlank(error)) {
      System.debug(UNEXPECTED_ERROR);
      return P_START_TAG + UNEXPECTED_ERROR + P_END_TAG;
    } else {
      System.debug(error);
      return P_START_TAG + error + P_END_TAG;
    }
  }

  private static void handleWarning(
    Exception e,
    String customMessage,
    String recordId
  ) {
    if (e != null) {
      System.debug(e.getMessage());
      System.debug(e.getStackTraceString());
      TB_vu_Utils.registerLog(e, TB_pdo_PdfGenerator.class, recordId);
      if (String.isBlank(customMessage)) {
        handleWarning(e.getMessage(), recordId, false);
      } else {
        handleWarning(customMessage, recordId, false);
      }
    } else {
      if (String.isBlank(customMessage)) {
        handleWarning(EMPTY_STRING, recordId);
      } else {
        handleWarning(customMessage, recordId);
      }
    }
  }

  private static void handleWarning(String warning, String recordId) {
    handleWarning(warning, recordId, true);
  }

  private static void handleWarning(
    String warning,
    String recordId,
    Boolean registerLog
  ) {
    System.debug(warning);
    if (registerLog) {
      TB_vu_Utils.registerLog(
        warning,
        TB_pdo_PdfGenerator.class.getName(),
        null,
        recordId
      );
    }
  }

  public class PDFQueueable implements Queueable, Database.AllowsCallouts {
    private final Id templateId;
    private final Id networkId;
    private final List<PDFObjectWrapper> objectsToProcess;

    private PDFObjectWrapper processedRecord;

    public PDFQueueable(PDFQueueableParams params) {
      this.templateId = params.templateId;
      this.objectsToProcess = params.objects;
      this.networkId = params.networkId;
    }

    public void execute(QueueableContext context) {
      if (objectsToProcess.isEmpty() || String.isBlank(templateId)) {
        return;
      }
      processedRecord = (PDFObjectWrapper) objectsToProcess.remove(0);
      try {
        Id contentDocumentId = processedRecord.isUpdate
          ? processedRecord.existingContentDocumentId
          : null;
        ContentVersion pdfCV = new ContentVersion(
          Title = processedRecord.fileName,
          PathOnClient = processedRecord.fileName + '.pdf',
          VersionData = getPDFBody(),
          TB_Category__c = processedRecord.category,
          ContentDocumentId = contentDocumentId,
          NetworkId = networkId
        );
        insert pdfCV;

        createContentDocumentLinks(pdfCV.Id);
      } catch (Exception e) {
        TB_vu_Utils.registerLog(
          e,
          PDFQueueable.class,
          processedRecord.recordId
        );
      } finally {
        if (!Test.isRunningTest() && !objectsToProcess.isEmpty()) {
          System.enqueueJob(this);
        }
      }
    }

    private Blob getPDFBody() {
      PageReference pdfPage = Page.TB_pdo_PdfGenerator;
      String recordIdsParam = templateId + ',' + processedRecord.recordId;
      if (
        processedRecord.relatedRecordIds != null &&
        !processedRecord.relatedRecordIds.isEmpty()
      ) {
        recordIdsParam += String.join(processedRecord.relatedRecordIds, ',');
      }
      pdfPage.getParameters().put(PARAM_RECORD_IDS, recordIdsParam);
      return Test.isRunningTest()
        ? Blob.valueOf('testcontent')
        : pdfPage.getContentAsPDF();
    }

    private void createContentDocumentLinks(Id contentVersionId) {
      ContentVersion contentVersion = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contentVersionId
      ];
      Set<Id> toSkipIds = new Set<Id>();
      if (processedRecord.isUpdate) {
        for (ContentDocumentLink link : [
          SELECT Id, LinkedEntityId
          FROM ContentDocumentLink
          WHERE ContentDocumentId = :contentVersion.ContentDocumentId
        ]) {
          toSkipIds.add(link.LinkedEntityId);
        }
      }
      List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();
      for (Id linkToId : processedRecord.linkToIds) {
        if (toSkipIds.contains(linkToId)) {
          continue;
        }
        cdLinks.add(
          new ContentDocumentLink(
            ContentDocumentId = contentVersion.ContentDocumentId,
            LinkedEntityId = linkToId
          )
        );
      }
      if (!cdLinks.isEmpty()) {
        insert cdLinks;
      }
    }
  }

  public class PDFQueueableParams {
    public Id templateId;
    public Id networkId;
    public List<PDFObjectWrapper> objects;
  }

  public class PDFObjectWrapper {
    public PDFObjectWrapper() {
      this.relatedRecordIds = new List<Id>();
      this.linkToIds = new Set<Id>();
    }

    public Id recordId;
    public List<Id> relatedRecordIds;
    public Set<Id> linkToIds;
    public Boolean isUpdate;
    public String fileName;
    public Id existingContentDocumentId;
    public String category;
  }
}
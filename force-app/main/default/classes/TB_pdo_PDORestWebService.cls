@RestResource(UrlMapping='/pdo/*')
global with sharing class TB_pdo_PDORestWebService {
  private static String eventType;
  private static Map<String, String> fieldsMapping;
  private static String itemId;
  private static Id depositorId;
  private static Boolean isCorrection;
  private static String correctionSourceId;
  private static List<TB_PDO__c> activePdos;

  @HttpPost
  global static Response managePdo() {
    System.RestRequest req = RestContext.request;
    System.RestResponse res = RestContext.response;
    Response response;
    TB_PDO__c pdo;
    Id pdoRecordtype;
    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    /// ================>>> REQUEST <<<=====================]

    TB_pdo_PDORestWebService.eventType = (String) data.get('eventType');
    try {
      if (
        !TB_pdo_PDORestWebService.eventType.equals(
          TB_pdo_Constants.DELETE_DRAFT_EVENT
        ) &&
        !TB_pdo_PDORestWebService.eventType.equals(
          TB_pdo_Constants.EDITOR_CLAIM_EVENT
        ) &&
        !TB_pdo_PDORestWebService.eventType.equals(
          TB_pdo_Constants.EDITOR_REJECT_EVENT
        ) &&
        !TB_pdo_PDORestWebService.eventType.equals(
          TB_pdo_Constants.DEPOSIT_EVENT
        )
      ) {
        pdo = TB_pdo_PDORestWebService.dataMapper(data);
      }
    } catch (Exception e) {
      res.statusCode = 500;
      response = new Response(res.statusCode, e.getMessage());
      return response;
    }
    System.debug('============Request=============');
    System.debug(req.requestBody.toString());
    if (
      TB_pdo_PDORestWebService.eventType.equals(TB_pdo_Constants.DRAFT_EVENT)
    ) {
      /* ******************** DRAFT ******************** */
      pdo.TB_PDO_Status__c = TB_pdo_Constants.IN_PROGRESS_STATUS;
      pdo.TB_DSpace_Status__c = TB_pdo_Constants.DRAFT_STATUS;
      TB_Achivement_type_mapper__mdt at = TB_Achivement_type_mapper__mdt.getInstance(
        (String) data.get('itemType')
      );
      String itemType = (String) data.get('itemType');
      try {
        pdoRecordtype = Schema.SObjectType.TB_PDO__c.getRecordTypeInfosByDeveloperName()
          .get(at.Recordtype_API__c)
          .getRecordTypeId();
      } catch (Exception e) {
        insert TB_LogUtils.registerLog(e);
        res.statusCode = 500;
        response = new Response(res.statusCode, e.getMessage());
        return response;
      }
      pdo.RecordTypeId = pdoRecordtype;
      TB_pdo_PDORestWebService.isCorrection = (Boolean) data.get('correction');
      TB_pdo_PDORestWebService.correctionSourceId = (String) data.get(
        'correctionItemID'
      );
      if (
        TB_pdo_PDORestWebService.isCorrection == true &&
        String.isNotBlank(TB_pdo_PDORestWebService.correctionSourceId)
      ) {
        try {
          TB_PDO__c sourcePdo = [
            SELECT Id
            FROM TB_PDO__c
            WHERE TB_DSpace_Reference_Id__c = :correctionSourceId
            LIMIT 1
          ];
          pdo.TB_VoR_Correction_Source__c = sourcePdo.Id;
          pdo.TB_VoR_Correction__c = true;
        } catch (Exception e) {
          insert TB_LogUtils.registerLog(e);
          res.statusCode = TB_pdo_Constants.SERVER_ERROR_CODE;
          response = new Response(
            res.statusCode,
            TB_pdo_Constants.NO_PDO_FOUND
          );
          return response;
        }
      }
      String originalVersionItemId = (String) data.get('originalVersionItemID');
      Boolean newVersion = (Boolean) data.get('newVersion');
      if (originalVersionItemId != null && newVersion) {
        TB_PDO__c sourcePdo = [
          SELECT Id
          FROM TB_PDO__c
          WHERE TB_DSpace_Reference_Id__c = :originalVersionItemId
          LIMIT 1
        ];
        pdo.TB_Origin_Version__c = sourcePdo.Id;
      }
      try {
        Database.SaveResult saveResult = Database.insert(pdo);
        res.statusCode = TB_pdo_Constants.SUCCESS_CODE;
        response = new Response(
          res.statusCode,
          TB_pdo_Constants.PDO_CREATED + saveResult.getId()
        );
      } catch (Exception e) {
        res.statusCode = TB_pdo_Constants.SERVER_ERROR_CODE;
        insert TB_LogUtils.registerLog(e);
        response = new Response(res.statusCode, e.getMessage());
        return response;
      }
    } else if (
      TB_pdo_PDORestWebService.eventType.equals(
        TB_pdo_Constants.DATA_MODIFICATION_EVENT
      ) ||
      TB_pdo_PDORestWebService.eventType.equals(
        TB_pdo_Constants.EDITOR_QUEUE_EVENT
      )
    ) {
      /* ******************** DATA MODIFICATION ******************** */
      /* ******************** EDITOR QUEUE ******************** */

      String type = (String) getMetadataObjectValue(data, 'dc_type');
      List<Object> coAuthors;
      if (
        type != TB_pdo_Constants.MONOGRAPHY_EDITION_TYPE &&
        type != TB_pdo_Constants.MONOGRAPHY_EDITION_CONFERENCE_TYPE
      ) {
        coAuthors = TB_pdo_PDORestWebService.getMetadataObjects(
          data,
          'dc_contributor_author'
        );
      } else {
        coAuthors = TB_pdo_PDORestWebService.getMetadataObjects(
          data,
          'dc_contributor_editor'
        );
      }

      if (coAuthors == null) {
        coAuthors = new List<Object>();
      }
      List<Contact> contacts = new List<Contact>();
      List<String> erpIdsToSearch = new List<String>();
      List<TB_PDO_Participant__c> incommingParticipants = new List<TB_PDO_Participant__c>();
      String[] name;
      String fullName = '';
      TB_PDO__c pdoToUpdate;
      try {
        pdoToUpdate = [
          SELECT Id, TB_DSpace_Status__c, TB_PDO_Status__c, TB_Version__c
          FROM TB_PDO__c
          WHERE TB_DSpace_Reference_Id__c = :TB_pdo_PDORestWebService.itemId
          LIMIT 1
        ];
      } catch (Exception e) {
        res.statusCode = TB_pdo_Constants.SERVER_ERROR_CODE;
        response = new Response(
          res.statusCode,
          TB_pdo_Constants.NO_PDO_FOUND + TB_pdo_PDORestWebService.itemId
        );
        return response;
      }

      for (Object author : coAuthors) {
        String erpId = (String) ((Map<String, Object>) author).get('authority');
        if (erpId != null) {
          erpIdsToSearch.add(erpId);
        }
      }
      try {
        contacts = [
          SELECT Id, TB_ERP_Id__c
          FROM Contact
          WHERE TB_ERP_Id__c IN :erpIdsToSearch
        ];
      } catch (Exception e) {
        System.debug(e.getMessage());
      }

      for (Object author : coAuthors) {
        TB_PDO_Participant__c participant = new TB_PDO_Participant__c();
        fullName = (String) ((Map<String, Object>) author).get('value');
        name = fullName.split(',');
        participant.TB_PDO__c = pdoToUpdate.Id;
        participant.TB_Last_Name__c = name[0];
        if (name.size() > 1) {
          participant.TB_First_Name__c = name[1];
        }
        participant.TB_Order__c =
          (Integer) ((Map<String, Object>) author).get('place') + 1;
        String erpId = (String) ((Map<String, Object>) author).get('authority');
        for (Contact contact : contacts) {
          if (erpId != null && erpId.equals(contact.TB_ERP_Id__c)) {
            participant.TB_Contact__c = contact.Id;
          }
        }
        participant.TB_Contact_Role__c = TB_pdo_Constants.PARTICIPANT_ROLE_AUTHOR;
        incommingParticipants.add(participant);
      }

      List<TB_PDO_Participant__c> currentParticipants = new List<TB_PDO_Participant__c>();
      currentParticipants = [
        SELECT Id, TB_First_Name__c, TB_Last_Name__c, TB_Contact__c, Name
        FROM TB_PDO_Participant__c
        WHERE TB_PDO__c = :pdoToUpdate.Id
      ];
      List<TB_PDO_Participant__c> participantsToDelete = new List<TB_PDO_Participant__c>();
      if (currentParticipants.size() > 0) {
        for (TB_PDO_Participant__c participant : currentParticipants) {
          Boolean found = false;
          if (participant.TB_Contact__c == null) {
            participantsToDelete.add(participant);
          }
          for (Integer i = 0; i < incommingParticipants.size(); i++) {
            if (
              incommingParticipants[i].TB_Contact__c != null &&
              participant.TB_Contact__c ==
              incommingParticipants[i].TB_Contact__c
            ) {
              found = true;
              incommingParticipants.remove(i);
              i--;
            }
          }
          if (!found) {
            participantsToDelete.add(participant);
          }
        }
      }
      if (
        TB_pdo_PDORestWebService.eventType.equals(
          TB_pdo_Constants.EDITOR_QUEUE_EVENT
        )
      ) {
        if (
          pdoToUpdate.TB_PDO_Status__c.equals(
            TB_pdo_Constants.IN_PROGRESS_STATUS
          ) &&
          pdoToUpdate.TB_DSpace_Status__c.equals(TB_pdo_Constants.DRAFT_STATUS)
        ) {
          pdoToUpdate.TB_DSpace_Status__c = TB_pdo_Constants.TO_VERIFY_STATUS;
        } else if (
          pdoToUpdate.TB_PDO_Status__c.equals(
            TB_pdo_Constants.TO_CORRECT_STATUS
          ) &&
          pdoToUpdate.TB_DSpace_Status__c.equals(
            TB_pdo_Constants.VERIFICATION_PENDING_STATUS
          )
        ) {
          pdoToUpdate.TB_PDO_Status__c = TB_pdo_Constants.CORRECTED_STATUS;
        }
      }
      if (
        !pdoToUpdate.TB_DSpace_Status__c.equals(
          TB_pdo_Constants.PUBLISHED_STATUS
        ) &&
        !pdoToUpdate.TB_DSpace_Status__c.equals(
          TB_pdo_Constants.APPROVED_STATUS
        )
      ) {
        Set<TB_PDO_Participant__c> authorsToDelete = new Set<TB_PDO_Participant__c>();
        authorsToDelete.addAll(participantsToDelete);
        List<TB_PDO_Participant__c> toDelete = new List<TB_PDO_Participant__c>();
        toDelete.addAll(authorsToDelete);
        delete toDelete;
        insert incommingParticipants;
      }
      String currentPdoVersion = (String) getMetadataObjectValue(
        data,
        'dc_description_version'
      );
      Schema.FieldSet pdoIntegrationFieldSet = Schema.SObjectType.TB_PDO__c.FieldSets.TB_PDO_Integration;
      for (
        Schema.FieldSetMember dataField : pdoIntegrationFieldSet.getFields()
      ) {
        pdoToUpdate.put(
          dataField.getFieldPath(),
          pdo.get(dataField.getFieldPath())
        );
      }
      update pdoToUpdate;
      res.statusCode = TB_pdo_Constants.SUCCESS_CODE;
      response = new Response(res.statusCode, TB_pdo_Constants.PDO_UPDATED);
    } else if (
      TB_pdo_PDORestWebService.eventType.equals(
        TB_pdo_Constants.DELETE_DRAFT_EVENT
      )
    ) {
      /* ******************** DELETE DRAFT ******************** */
      TB_pdo_PDORestWebService.itemId = (String) data.get('itemID');
      TB_PDO__c pdoToDelete = [
        SELECT
          Id,
          TB_Active__c,
          TB_Repository_Link__c,
          TB_Workflow_Link__c,
          TB_Workspace_Link__c,
          TB_Deleted_at_DSpace__c
        FROM TB_PDO__c
        WHERE TB_DSpace_Reference_Id__c = :TB_pdo_PDORestWebService.itemId
        LIMIT 1
      ];
      pdoToDelete.TB_Active__c = false;
      pdoToDelete.TB_Deleted_at_DSpace__c = true;
      pdoToDelete.TB_Repository_Link__c = null;
      pdoToDelete.TB_Workflow_Link__c = null;
      pdoToDelete.TB_Workspace_Link__c = null;
      update pdoToDelete;
      res.statusCode = TB_pdo_Constants.SUCCESS_CODE;
      response = new Response(res.statusCode, TB_pdo_Constants.PDO_DELETED);
    } else if (
      TB_pdo_PDORestWebService.eventType.equals(
        TB_pdo_Constants.EDITOR_CLAIM_EVENT
      )
    ) {
      /* ******************** EDITOR_CLAIM ******************** */
      TB_pdo_PDORestWebService.itemId = (String) data.get('itemID');
      String depositorEmail = (String) data.get('actor');
      TB_pdo_PDORestWebService.depositorId = [
        SELECT Id
        FROM Contact
        WHERE hed__WorkEmail__c = :depositorEmail
        LIMIT 1
      ]
      .Id;
      TB_PDO__c currentPdo = [
        SELECT
          Id,
          TB_Editor__c,
          TB_Repository_Link__c,
          TB_Workflow_Link__c,
          TB_Workspace_Link__c,
          TB_Last_Modification__c,
          TB_PDO_Status__c,
          TB_DSpace_Status__c
        FROM TB_PDO__c
        WHERE TB_DSpace_Reference_Id__c = :TB_pdo_PDORestWebService.itemId
        LIMIT 1
      ];
      currentPdo.TB_Editor__c = TB_pdo_PDORestWebService.depositorId;
      currentPdo.TB_Repository_Link__c = (String) data.get('repoLink');
      currentPdo.TB_Workflow_Link__c = (String) data.get('workflowLink');
      currentPdo.TB_Workspace_Link__c = (String) data.get('workspaceLink');
      currentPdo.TB_Last_Modification__c = (String) getMetadataObjectValue(
        data,
        'dc_description_provenance'
      );
      currentPdo.TB_PDO_Status__c = TB_pdo_Constants.IN_PROGRESS_STATUS;
      currentPdo.TB_DSpace_Status__c = TB_pdo_Constants.VERIFICATION_PENDING_STATUS;
      update currentPdo;
      res.statusCode = 200;
      response = new Response(res.statusCode, TB_pdo_Constants.PDO_UPDATED_EC);
    } else if (
      TB_pdo_PDORestWebService.eventType.equals(
        TB_pdo_Constants.EDITOR_REJECT_EVENT
      )
    ) {
      /* ******************** EDITOR_REJECT ******************** */
      TB_pdo_PDORestWebService.itemId = (String) data.get('itemID');
      String depositorEmail = (String) data.get('actor');
      TB_pdo_PDORestWebService.depositorId = [
        SELECT Id
        FROM Contact
        WHERE hed__WorkEmail__c = :depositorEmail
        LIMIT 1
      ]
      .Id;
      TB_PDO__c currentPdo = [
        SELECT
          Id,
          TB_Editor__c,
          TB_Repository_Link__c,
          TB_Workflow_Link__c,
          TB_Workspace_Link__c,
          TB_Last_Modification__c,
          TB_PDO_Status__c,
          TB_DSpace_Status__c,
          TB_Editor_Comment__c
        FROM TB_PDO__c
        WHERE TB_DSpace_Reference_Id__c = :TB_pdo_PDORestWebService.itemId
        LIMIT 1
      ];
      if (currentPdo.TB_Editor__c != TB_pdo_PDORestWebService.depositorId) {
        currentPdo.TB_Editor__c = TB_pdo_PDORestWebService.depositorId;
      }
      currentPdo.TB_Last_Modification__c = (String) getMetadataObjectValue(
        data,
        'dc_description_provenance'
      );
      currentPdo.TB_Repository_Link__c = (String) data.get('repoLink');
      currentPdo.TB_Workflow_Link__c = (String) data.get('workflowLink');
      currentPdo.TB_Workspace_Link__c = (String) data.get('workspaceLink');
      currentPdo.TB_Editor_Comment__c = (String) data.get('editorComment');
      currentPdo.TB_PDO_Status__c = TB_pdo_Constants.TO_CORRECT_STATUS;
      currentPdo.TB_DSpace_Status__c = TB_pdo_Constants.VERIFICATION_PENDING_STATUS;
      update currentPdo;
      res.statusCode = TB_pdo_Constants.SUCCESS_CODE;
      response = new Response(res.statusCode, TB_pdo_Constants.PDO_UPDATED_ER);
      /* ******************** DEPOSIT ******************** */
    } else if (
      TB_pdo_PDORestWebService.eventType.equals(TB_pdo_Constants.DEPOSIT_EVENT)
    ) {
      String itemType = (String) data.get('itemType');
      TB_pdo_PDORestWebService.itemId = (String) data.get('itemID');
      String depositorEmail = (String) data.get('actor');
      TB_pdo_PDORestWebService.depositorId = [
        SELECT Id
        FROM Contact
        WHERE hed__WorkEmail__c = :depositorEmail
        LIMIT 1
      ]
      .Id;
      TB_PDO__c currentPdo = [
        SELECT
          Id,
          TB_Editor__c,
          TB_Repository_Link__c,
          TB_Workflow_Link__c,
          TB_Workspace_Link__c,
          TB_Last_Modification__c,
          TB_PDO_Status__c,
          TB_DSpace_Status__c,
          TB_Editor_Comment__c,
          TB_Sciencecloud_Reference_Id__c,
          TB_Sciencecloud_Status__c,
          TB_Sciencecloud_Editor_Decision__c
        FROM TB_PDO__c
        WHERE TB_DSpace_Reference_Id__c = :TB_pdo_PDORestWebService.itemId
        LIMIT 1
      ];
      currentPdo.TB_Repository_Link__c = (String) data.get('repoLink');
      currentPdo.TB_Workflow_Link__c = (String) data.get('workflowLink');
      currentPdo.TB_Workspace_Link__c = (String) data.get('workspaceLink');
      currentPdo.TB_Version_Number__c = (Integer) data.get('itemVersion') + '';
      String scienceCloudIndicator =(String) getMetadataObjectValue(data, 'dc_swps_sciencecloud');
      if (
        itemType.equals(TB_pdo_Constants.ARTICLE) ||
        itemType.equals(TB_pdo_Constants.BOOK)
      ) {
        if (scienceCloudIndicator == TB_pdo_Constants.SEND) {
          currentPdo.TB_PDO_Status__c = TB_pdo_Constants.PUBLISHED_STATUS;
          currentPdo.TB_DSpace_Status__c = TB_pdo_Constants.PUBLISHED_STATUS;
        } else if (scienceCloudIndicator == TB_pdo_Constants.NO_SEND) {
          currentPdo.TB_PDO_Status__c = TB_pdo_Constants.RELEASED_STATUS;
          currentPdo.TB_DSpace_Status__c = TB_pdo_Constants.RELEASED_STATUS;
          currentPdo.TB_Sciencecloud_Editor_Decision__c = TB_pdo_Constants.NO_SEND;
        }
      } else if (
        itemType.equals(TB_pdo_Constants.DATASET) ||
        itemType.equals(TB_pdo_Constants.ARTISTIC)
      ) {
        currentPdo.TB_PDO_Status__c = TB_pdo_Constants.PUBLISHED_STATUS;
        currentPdo.TB_DSpace_Status__c = TB_pdo_Constants.PUBLISHED_STATUS;
      }
      if (
        ((currentPdo.TB_Sciencecloud_Editor_Decision__c != TB_pdo_Constants.SEND) &&
        (scienceCloudIndicator != null &&
        scienceCloudIndicator.equals(TB_pdo_Constants.SEND))) ||
        itemType.equals(TB_pdo_Constants.ARTISTIC)
      ) {
        String tokenId = TB_pdo_PDORestWebService.getScienceCloudAccessToken();
        if (tokenId != null) {
          Map<String, Object> deserializedData = TB_pdo_PDORestWebService.getSingleAchievementDataFromScienceCloudByExternalId(
            TB_pdo_PDORestWebService.itemId,
            tokenId
          );
          if (deserializedData != null) {
            Map<String, Object> dataValues = (Map<String, Object>) deserializedData.values()
              .get(0);
            currentPdo.TB_Sciencecloud_Reference_Id__c =
              ((Integer) dataValues.get('id')) + '';
            currentPdo.TB_Sciencecloud_Status__c = (String) dataValues.get(
              'status'
            );
            currentPdo.TB_Sciencecloud_Editor_Decision__c = scienceCloudIndicator;
            Map<String, Object> innerData = (Map<String, Object>) dataValues.get(
              'conference_series'
            );
            if (innerData != null) {
              currentPdo.TB_Conference_Ministerial_Id__c =
                ((Integer) innerData.get('mnisw_id')) + '';
            }
            innerData = (Map<String, Object>) dataValues.get('publisher');
            if (innerData != null) {
              currentPdo.TB_Publisher_Points__c = (Integer) innerData.get(
                'points'
              );
            }
          } else {
            res.statusCode = 500;
            response = new Response(
              res.statusCode,
              TB_pdo_Constants.SCIENCECLOUD_FAIL
            );
            return response;
          }
        } else {
          res.statusCode = 500;
          response = new Response(
            res.statusCode,
            TB_pdo_Constants.SCIENCECLOUD_AUTH_FAIL
          );
          return response;
        }
      }
      update currentPdo;
      res.statusCode = 200;
      response = new Response(res.statusCode, TB_pdo_Constants.DEPOSIT_UPDATE);
    }
    return response;
  }
  private static TB_PDO__c dataMapper(Map<String, Object> data) {
    TB_PDO__c pdo = new TB_PDO__c();
    String depositorEmail;
    TB_pdo_PDORestWebService.itemId = (String) data.get('itemID');
    pdo.TB_DSpace_Reference_Id__c = TB_pdo_PDORestWebService.itemId;
    depositorEmail = (String) data.get('actor');
    TB_pdo_PDORestWebService.depositorId = [
      SELECT Id
      FROM Contact
      WHERE hed__WorkEmail__c = :depositorEmail
      LIMIT 1
    ]
    .Id;
    pdo.TB_Depositor__c = TB_pdo_PDORestWebService.depositorId;
    Schema.SObjectType type = Schema.TB_PDO__c.getSObjectType();
    pdo.TB_Version_Number__c = (Integer) data.get('itemVersion') + '';
    pdo.TB_Workspace_Link__c = (String) data.get('workspaceLink');
    pdo.TB_Workflow_Link__c = (String) data.get('workflowLink');
    pdo.TB_Repository_Link__c = (String) data.get('repoLink');
    pdo.TB_Editor_Comment__c = (String) data.get('editorComment');
    pdo.TB_Last_Modification__c = (String) getMetadataObjectValue(
      data,
      'dc_description_provenance'
    );
    pdo.TB_Abstract_Author__c = (String) getMetadataObjectValue(
      data,
      'dc_abstract_author'
    );
    pdo.TB_Abstract_Alternative__c = (String) getMetadataObjectValue(
      data,
      'dc_abstract_other'
    );
    pdo.TB_Abstract_PL__c = (String) getMetadataObjectValue(
      data,
      'dc_abstract_pl'
    );
    pdo.TB_Abstract_EN__c = (String) getMetadataObjectValue(
      data,
      'dc_abstract_en'
    );
    pdo.TB_Abstract_Language__c = (String) getMetadataObjectValue(
      data,
      'dc_language_abstract'
    );
    pdo.TB_Achievement_Category__c = (String) getMetadataObjectValue(
      data,
      'dc_description_type'
    );
    pdo.TB_Language_of_Alternative_Title__c = (String) getMetadataObjectValue(
      data,
      'dc_language_other'
    );
    pdo.TB_Access_Date__c = (String) getMetadataObjectValue(
      data,
      'dc_date_accesioned'
    );
    pdo.TB_Affiliations__c = TB_pdo_PDORestWebService.mergeListValues(
        data,
        'dc_affiliation',
        ' / '
      )
      .trim()
      .replaceFirst('/ ', '');
    pdo.TB_Disciplines__c = TB_pdo_PDORestWebService.mergeListValues(
        data,
        'dc_pbn_affiliation',
        ', '
      )
      .replaceFirst(', ', '');
    pdo.TB_Award_Place__c = (String) getMetadataObjectValue(
      data,
      'dc_description_place'
    );
    pdo.TB_Awards_and_Distinctions_Justification__c = (String) getMetadataObjectValue(
      data,
      'dc_description_abstract'
    );
    pdo.TB_Awards_Laureates__c = (String) getMetadataObjectValue(
      data,
      'dc_description_awards'
    );
    pdo.TB_Volume_Edition__c = (String) getMetadataObjectValue(
      data,
      'dc_description_edition'
    );
    pdo.TB_Conference_City__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_place'
    );
    pdo.TB_Conference_Country__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_country'
    );
    pdo.TB_Conference_Coverage__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_coverage'
    );
    pdo.TB_Conference_End_Date__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_datefinish'
    );
    pdo.TB_Conference_Name__c = (String) getMetadataObjectValue(
      data,
      'dc_conference'
    );
    pdo.TB_Conference_Short_Name__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_shortcut'
    );
    pdo.TB_Conference_Series__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_series'
    );
    pdo.TB_Conference_Series_Short_Name__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_seriesshortcut'
    );
    pdo.TB_Conference_Series_Website__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_seriesweblink'
    );
    pdo.TB_Conference_Start_Date__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_datestart'
    );
    pdo.TB_Conference_Website__c = (String) getMetadataObjectValue(
      data,
      'dc_conference_weblink'
    );
    pdo.TB_Cost_Amount_in_PLN__c = (String) getMetadataObjectValue(
      data,
      'dc_description_financecost'
    );
    pdo.TB_Data_Set_Characteristic__c = (String) getMetadataObjectValue(
      data,
      'dc_description_additional'
    );
    pdo.TB_DOI__c = (String) getMetadataObjectValue(data, 'dc_identifier_doi');
    pdo.TB_eISSN__c = (String) getMetadataObjectValue(
      data,
      'dc_identifier_eissn'
    );
    String evalPoints = (String) getMetadataObjectValue(
      data,
      'dc_editor_points'
    );
    pdo.TB_Evaluation_Points__c = evalPoints != null
      ? Integer.valueOf(evalPoints)
      : null;
    pdo.TB_Exhibition_City__c = (String) getMetadataObjectValue(
      data,
      'dc_exhibition_city'
    );
    pdo.TB_Exhibition_Country__c = (String) getMetadataObjectValue(
      data,
      'dc_exhibition_country'
    );
    pdo.TB_Exhibition_End_Date__c = (String) getMetadataObjectValue(
      data,
      'dc_exhibition_endDate'
    );
    pdo.TB_Exhibition_Editor__c = (String) getMetadataObjectValue(
      data,
      'dc_contributor_serieseditor'
    );
    pdo.TB_Monograph_Editor__c = TB_pdo_PDORestWebService.mergeListValues(
        data,
        'dc_contributor_editor',
        ' & '
      )
      .replaceFirst('& ', '')
      .replace(',', '');
    pdo.TB_Exhibition_Extent__c = (String) getMetadataObjectValue(
      data,
      'dc_format_extent'
    );
    pdo.TB_Exhibition_Medium__c = (String) getMetadataObjectValue(
      data,
      'dc_format_medium'
    );
    pdo.TB_Exhibition_Name__c = (String) getMetadataObjectValue(
      data,
      'dc_exhibition'
    );
    pdo.TB_Place_of_Publication_Exhibition__c = (String) getMetadataObjectValue(
      data,
      'dc_pubinfo'
    );
    pdo.TB_Exhibition_Organizer_Institution__c = (String) getMetadataObjectValue(
      data,
      'dc_contributor_institution'
    );
    pdo.TB_Exhibition_Series__c = (String) getMetadataObjectValue(
      data,
      'dc_exhibition_series'
    );
    pdo.TB_Exhibition_Start_Date__c = (String) getMetadataObjectValue(
      data,
      'dc_exhibition_startDate'
    );
    pdo.TB_Exhibition_Series_Weblink__c = (String) getMetadataObjectValue(
      data,
      'dc_exhibition_seriesweblink'
    );
    pdo.TB_Exhibition_Short_Name__c = (String) getMetadataObjectValue(
      data,
      'dc_exhibition_shortcut'
    );
    pdo.TB_Exhibition_Temporal__c = (String) getMetadataObjectValue(
      data,
      'dc_coverage_temporal'
    );
    pdo.TB_Exhibition_Type__c = (String) getMetadataObjectValue(
      data,
      'dc_description_conftype'
    );
    pdo.TB_Editor_Remarks__c = (String) getMetadataObjectValue(
      data,
      'dc_editor_remarks'
    );
    pdo.TB_Exhibition_Weblink__c = (String) getMetadataObjectValue(
      data,
      'dc_identifier_weblink'
    );
    pdo.TB_Grant_Project_Name__c = (String) getMetadataObjectValue(
      data,
      'dc_description_granttitle'
    );
    pdo.TB_Grant_Project_Number__c = (String) getMetadataObjectValue(
      data,
      'dc_description_grantnumber'
    );
    pdo.TB_Is_Part_Of__c = (String) getMetadataObjectValue(
      data,
      'dc_relation_ispartof'
    );
    pdo.TB_ISSN__c = (String) getMetadataObjectValue(
      data,
      'dc_identifier_issn'
    );
    pdo.TB_Issue_Number__c = (String) getMetadataObjectValue(
      data,
      'dc_description_issue'
    );
    pdo.TB_ISBN__c = (String) getMetadataObjectValue(
      data,
      'dc_identifier_isbn'
    );
    pdo.TB_e_ISBN__c = (String) getMetadataObjectValue(
      data,
      'dc_identifier_eisbn'
    );
    pdo.TB_Journal_Title__c = (String) getMetadataObjectValue(
      data,
      'dc_title_journal'
    );
    pdo.TB_Key_Words_PL__c = TB_pdo_PDORestWebService.mergeListValues(
        data,
        'dc_subject_pl',
        ', '
      )
      .replaceFirst(', ', '');
    pdo.TB_Key_Words_EN__c = TB_pdo_PDORestWebService.mergeListValues(
        data,
        'dc_subject_en',
        ', '
      )
      .replaceFirst(', ', '');
    pdo.TB_Key_Words_Alternative__c = TB_pdo_PDORestWebService.mergeListValues(
        data,
        'dc_subject_other',
        ', '
      )
      .replaceFirst(', ', '');
    pdo.TB_Language_of_Alternative_Title__c = (String) getMetadataObjectValue(
      data,
      'dc_language_titlealternative'
    );
    pdo.TB_Language_of_Publication__c = (String) getMetadataObjectValue(
      data,
      'dc_language'
    );
    pdo.TB_Pages__c = (String) getMetadataObjectValue(
      data,
      'dc_description_physical'
    );
    pdo.TB_Part_of_Series__c = (String) getMetadataObjectValue(
      data,
      'dc_relation_ispartofseries'
    );
    pdo.TB_Relation_Book__c = (String) getMetadataObjectValue(
      data,
      'dc_relation_book'
    );
    pdo.TB_Place_of_Origin_Country__c = (String) getMetadataObjectValue(
      data,
      'dc_place'
    );
    pdo.TB_Publication_Date__c = (String) getMetadataObjectValue(
      data,
      'dc_date_created'
    );
    pdo.TB_Publication_Fees__c = (String) getMetadataObjectValue(
      data,
      'dc_description_finance'
    );
    pdo.TB_Release_Time__c = (String) getMetadataObjectValue(
      data,
      'dc_description_accesstime'
    );
    pdo.TB_Remarks__c = (String) getMetadataObjectValue(
      data,
      'dc_description_additional'
    );
    pdo.TB_Popularization__c = (String) getMetadataObjectValue(
      data,
      'dc_editor_dissemination'
    );
    pdo.TB_Scope_of_Dissemination__c = (String) getMetadataObjectValue(
      data,
      'dc_coverage_spatial'
    );
    pdo.TB_Sponsorship__c = (String) getMetadataObjectValue(
      data,
      'dc_description_sponsorship'
    );
    pdo.TB_Sponsorship_Source__c = (String) getMetadataObjectValue(
      data,
      'dc_description_sponsorshipsource'
    );
    pdo.TB_Sponsorship_Year__c = (String) getMetadataObjectValue(
      data,
      'dc_description_sponsorshipdate'
    );
    pdo.TB_Sub_Type__c = (String) getMetadataObjectValue(data, 'dc_subtype');
    pdo.TB_Time_Range_From__c = (String) getMetadataObjectValue(
      data,
      'dc_coverage_from'
    );
    pdo.TB_Time_Range_To__c = (String) getMetadataObjectValue(
      data,
      'dc_coverage_to'
    );
    pdo.TB_Title_Alternative__c = (String) getMetadataObjectValue(
      data,
      'dc_title_alternative'
    );
    pdo.TB_Title_Original__c = (String) getMetadataObjectValue(
      data,
      'dc_title'
    );
    pdo.TB_Type__c = (String) getMetadataObjectValue(data, 'dc_type');
    pdo.TB_URI__c = (String) getMetadataObjectValue(data, 'dc_identifier_uri');
    pdo.TB_URL__c = (String) getMetadataObjectValue(
      data,
      'dc_identifier_weblink'
    );
    pdo.TB_Version__c = (String) getMetadataObjectValue(
      data,
      'dc_description_version'
    );
    pdo.TB_Volume_Issue_Title__c = (String) getMetadataObjectValue(
      data,
      'dc_title_volume'
    );
    pdo.TB_Volume_Number__c = (String) getMetadataObjectValue(
      data,
      'dc_description_volume'
    );
    pdo.TB_Year_of_Publication__c = (String) getMetadataObjectValue(
      data,
      'dc_date_issued'
    );
    pdo.TB_Rights_Information__c = (String) getMetadataObjectValue(
      data,
      'dc_rights'
    );
    pdo.TB_Rights__c = (String) getMetadataObjectValue(
      data,
      'dc_rights_explanation'
    );
    pdo.TB_Rights_Question__c = (String) getMetadataObjectValue(
      data,
      'dc_rights_question'
    );
    pdo.TB_Publisher__c = (String) getMetadataObjectValue(data, 'dc_publisher');
    pdo.TB_Publisher_Ministerial__c = (String) getMetadataObjectValue(
      data,
      'dc_publisher_ministerial'
    );
    pdo.TB_Dataset_Version__c = (String) getMetadataObjectValue(
      data,
      'dc_dataset_version'
    );
    pdo.TB_Data_Set_Publication_Date__c = (String) getMetadataObjectValue(
      data,
      'dc_date_available'
    );
    pdo.TB_Dataset_Access_Description__c = (String) getMetadataObjectValue(
      data,
      'dc_description_access'
    );
    pdo.TB_Achievement_Characteristics__c = (String) getMetadataObjectValue(
      data,
      'dc_description_art'
    );
    pdo.TB_Founder__c = (String) getMetadataObjectValue(
      data,
      'dc_description_financeorg'
    );
    pdo.TB_Translator__c = (String) getMetadataObjectValue(
      data,
      'dc_contributor_translator'
    );
    return pdo;
  }

  private static List<Object> getMetadataObjects(
    Map<String, Object> jsonData,
    String jsonKey
  ) {
    List<Object> objects = (List<Object>) ((Map<String, Object>) jsonData.get(
        TB_pdo_Constants.METADATALIST
      ))
      .get(jsonKey);
    if (objects == null) {
      objects = new List<Object>();
    }
    return objects;
  }

  private static Object getMetadataObjectValue(
    Map<String, Object> jsonData,
    String jsonKey
  ) {
    List<Object> objects = TB_pdo_PDORestWebService.getMetadataObjects(
      jsonData,
      jsonKey
    );
    return objects.size() == 0
      ? null
      : ((Map<String, Object>) objects.get(0)).get('value');
  }

  private static String mergeListValues(
    Map<String, Object> jsonData,
    String jsonKey,
    String separator
  ) {
    List<Object> results = TB_pdo_PDORestWebService.getMetadataObjects(
      jsonData,
      jsonKey
    );
    String merger = '';
    String finalResult = '';
    for (Object obj : results) {
      String value = (String) ((Map<String, Object>) obj).get('value');
      merger = merger + separator + value;
    }
    return finalResult = merger.trim();
  }

  public static String getScienceCloudAccessToken() {
    String accessToken;
    Http http = new Http();
    HttpRequest scRequest = new HttpRequest();
    HttpResponse scAuthResponse = new HttpResponse();
    scRequest.setEndpoint('callout:TB_Sciencecloud_Auth');
    scRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    scRequest.setMethod('POST');
    String body = 'grant_type=password&scope={!$Credential.TB_Sciencecloud_auth_ext.scope}&client_id={!$Credential.TB_Sciencecloud_auth_ext.client_id}&client_secret={!$Credential.TB_Sciencecloud_auth_ext.client_secret}&username={!$Credential.TB_Sciencecloud_auth_ext.username}&password={!$Credential.TB_Sciencecloud_auth_ext.password}';
    scRequest.setBody(body);
    scAuthResponse = http.send(scRequest);
    if (scAuthResponse.getStatusCode() == TB_pdo_Constants.SUCCESS_CODE) {
      Object responseData = JSON.deserializeUntyped(scAuthResponse.getBody());
      Map<String, Object> deserializedData = (Map<String, Object>) responseData;
      accessToken = (String) deserializedData.get('id_token');
    }
    return accessToken;
  }

  public static Map<String, Object> getSingleAchievementDataFromScienceCloudByExternalId(
    String itemId,
    String accessToken
  ) {
    Http http = new Http();
    HttpRequest scRequest = new HttpRequest();
    HttpResponse scResponse = new HttpResponse();
    Map<String, Object> deserializedData;
    scRequest.setEndpoint(
      'callout:TB_Sciencecloud_pdo' +
      '/achievements/external_id/' +
      itemId
    );
    scRequest.setheader('Authorization', 'Bearer ' + accessToken);
    scRequest.setMethod('GET');
    scRequest.setBody('');
    scResponse = http.send(scRequest);
    if (scResponse.getStatusCode() == TB_pdo_Constants.SUCCESS_CODE) {
      Object responseData = JSON.deserializeUntyped(scResponse.getBody());
      deserializedData = (Map<String, Object>) responseData;
    }
    return deserializedData;
  }

  @future(callout=true)
  public static void updateDataInScienceCloud(
    String dspaceId,
    String field,
    String sfId
  ) {
    Http http = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse resp = new HttpResponse();
    String body = '';
    String token = TB_pdo_PDORestWebService.getScienceCloudAccessToken();
    Map<String, Object> achievement = TB_pdo_PDORestWebService.getSingleAchievementDataFromScienceCloudByExternalId(
      dspaceId,
      token
    );
    List<TB_Affiliation__mdt> availableAffiliations = [
      SELECT Affiliation_Full_Name__c, Affiliation_Code__c
      FROM TB_Affiliation__mdt
    ];
    TB_PDO__c sourcePdo = [SELECT TB_Type__c FROM TB_PDO__C WHERE Id =: sfId LIMIT 1];
    List<TB_PDO_Participant__c> participants = new List<TB_PDO_Participant__c>();
    switch on field {
      when 'Sciencecloud_Status' {
        List<String> erpIds = new List<String>();
        Map<String, Object> erpToAuthor = new Map<String, Object>();
        ((Map<String, Object>) achievement.values().get(0))
          .put('status', TB_pdo_Constants.FOR_APPROVAL_STATUS);
        Map<String, Object> keywords = ((Map<String, Object>) ((Map<String, Object>) ((Map<String, Object>) achievement.values().get(0))).get('language_data'));
        if (keywords != null) {
          keywords.remove('keywords');
        }
        List<Object> authors = (sourcePdo.TB_Type__c != 'MonographyEdition' && sourcePdo.TB_Type__c != 'MonographyEditionConference') ? ((List<Object>) ((Map<String, Object>) achievement.values()
            .get(0))
          .get('authors')) : ((List<Object>) ((Map<String, Object>) achievement.values()
          .get(0))
        .get('editors'));
        String erpId = '';
        for (Object author : authors) {
          List<Object> additinalIds = (List<Object>) ((Map<String, Object>) author)
            .get('employee_additional_ids');
          if (additinalIds != null) {
            for (Object id : additinalIds) {
              if (((Map<String, Object>) id).get('key').equals('erp')) {
                erpId = (String) ((Map<String, Object>) id).get('value');
                erpIds.add(erpId);
                erpToAuthor.put(erpId, author);
              }
            }
          }
        }
        try {
          participants = [
            SELECT
              TB_Participant_ERP_Id__c,
              TB_Affiliate_Statement__r.TB_PBN_Affiliation__c
            FROM TB_PDO_Participant__c
            WHERE TB_Participant_ERP_Id__c IN :erpids AND TB_PDO__c = :sfId
          ];
        } catch (Exception e) {
          System.debug(e.getMessage());
        }
        for (TB_PDO_Participant__c participant : participants) {
          for (TB_Affiliation__mdt affiliation : availableAffiliations) {
            if (
              String.isNotBlank(
                participant.TB_Affiliate_Statement__r.TB_PBN_Affiliation__c
              ) &&
              participant.TB_Affiliate_Statement__r.TB_PBN_Affiliation__c.equals(
                affiliation.Affiliation_Full_Name__c
              )
            ) {
              ((Map<String, Object>) erpToAuthor.get(
                  participant.TB_Participant_ERP_Id__c
                ))
                .put('discipline', affiliation.Affiliation_Code__c);
            }
          }
        }
        body = JSON.serialize(achievement);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('x-role', 'pracownik');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(
          'callout:TB_Sciencecloud_pdo' +
          '/achievements/external_id/' +
          dspaceId
        );
        req.setMethod('PUT');
        req.setBody(body);
        resp = http.send(req);
        if (resp.getStatusCode() == TB_pdo_Constants.SUCCESS_CODE) {
          Object responseData = JSON.deserializeUntyped(resp.getBody());
          Map<String, Object> deserializedData = (Map<String, Object>) responseData;
          TB_PDO__c pdo = [
            SELECT TB_Sciencecloud_Status__c
            FROM TB_PDO__c
            WHERE TB_DSpace_Reference_Id__c = :dspaceId
          ];
          pdo.TB_Sciencecloud_Status__c = TB_pdo_Constants.FOR_APPROVAL_STATUS_UP;
          update pdo;
        }
      }
      when 'Rewarded' {
        Map<String, Object> keywords = ((Map<String, Object>) ((Map<String, Object>) ((Map<String, Object>) achievement.values().get(0))).get('language_data'));
        if (keywords != null) {
          keywords.remove('keywords');
        }
        List<Object> flags = ((List<Object>) ((Map<String, Object>) achievement.values()
            .get(0))
          .get('flags'));
        if (!flags.contains('Premia')) {
          flags.add('Premia');
        }
        body = JSON.serialize(achievement);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('x-role', 'pracownik');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(
          'callout:TB_Sciencecloud_pdo' +
          '/achievements/external_id/' +
          dspaceId
        );
        req.setMethod('PUT');
        req.setBody(body);
        resp = http.send(req);
      }
    }
  }

  @InvocableMethod(Label='updatePdoStatusInScienceCloud' callout=true)
  public static void updatePdoStatusInScienceCloud(List<List<String>> params) {
    List<String> pdoData = params.get(0);
    String field = pdoData.get(0);
    String scid = pdoData.get(1);
    String sfid = pdoData.get(2);
    TB_PDO__c pdo = [
      SELECT TB_DSpace_Reference_Id__c
      FROM TB_PDO__c
      WHERE TB_Sciencecloud_Reference_Id__c = :scid
      LIMIT 1
    ];
    String dspaceId = pdo.TB_DSpace_Reference_Id__c;
    TB_pdo_PDORestWebService.updateDataInScienceCloud(dspaceId, field, sfId);
  }

  public static Map<String, Object> getAchievementsFromScienceCloudByIds(
    List<String> ids
  ) {
    Http http = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse resp = new HttpResponse();
    Map<String, Object> deserializedData = new Map<String, Object>();
    Object responseData;
    String token;
    Map<String, Object> results = new Map<String, Object>();
    Map<String, List<String>> requestData = new Map<String, List<String>>();
    requestData.put('external_ids', ids);
    String body = JSON.serialize(requestData);
    token = TB_pdo_PDORestWebService.getScienceCloudAccessToken();
    if (token != null) {
      req.setEndpoint('callout:TB_Sciencecloud_pdo' + '/achievements/statuses');
      req.setHeader('Authorization', 'Bearer ' + token);
      req.setHeader('Content-Type', 'application/json');
      req.setMethod('POST');
      req.setTimeout(100000);
      req.setBody(body);
      resp = http.send(req);
      if (resp.getStatusCode() == TB_pdo_Constants.SUCCESS_CODE) {
        responseData = JSON.deserializeUntyped(resp.getBody());
        deserializedData = (Map<String, Object>) responseData;
      }
    }

    return deserializedData;
  }
  
  @Future(callout=true)
  public static void synchronizePdoStatuses() {
    List<TB_PDO__c> pdosToUpdate = new List<TB_PDO__c>();
    List<String> statusesToVerifyFromSF = new List<String>{
      TB_pdo_Constants.IMPROVE_STATUS,
      TB_pdo_Constants.FOR_APPROVAL_STATUS_UP,
      TB_pdo_Constants.VERIFIED_STATUS
    };
    List<String> dspaceIds = new List<String>();
    TB_pdo_PDORestWebService.activePdos = [
      SELECT TB_DSpace_Reference_Id__c
      FROM TB_PDO__c
      WHERE
        TB_DSpace_Status__c != NULL
        AND TB_PDO_Status__c != NULL
        AND TB_Sciencecloud_Reference_Id__c != NULL
        AND TB_DSpace_Reference_Id__c != NULL
        AND TB_Sciencecloud_Status__c IN :statusesToVerifyFromSF
    ];
    try {
      for (TB_PDO__c pdo : TB_pdo_PDORestWebService.activePdos) {
        dspaceIds.add(pdo.TB_DSpace_Reference_Id__c);
      }
    } catch (Exception e) {
      System.debug(e.getMessage());
      return;
    }

    Map<String, Object> achievementsToSynchronize = TB_pdo_PDORestWebService.getAchievementsFromScienceCloudByIds(
      dspaceIds
    );
    List<Object> achievements = (List<Object>) achievementsToSynchronize.get(
      'achievements'
    );
    for (Object achievement : achievements) {
      Map<String, Object> achievementFields = (Map<String, Object>) achievement;
      Map<String, Object> achievementFieldValue;
      for (String achievementFieldName : achievementFields.keySet()) {
        achievementFieldValue = (Map<String, Object>) achievementFields.get(
          achievementFieldName
        );
      }
      for (TB_PDO__c pdo : TB_pdo_PDORestWebService.activePdos) {
        if (
          pdo.TB_DSpace_Reference_Id__c ==
          (achievementFieldValue.get('external_id'))
        ) {
          pdo.TB_Sciencecloud_Status__c =
            (achievementFieldValue.get('status')) + '';
          pdosToUpdate.add(pdo);
        }
      }
    }
    update pdosToUpdate;
  }

  global class Response {
    public String message;
    public Integer statusCode;
    public Response(Integer statusCode, String message) {
      this.statusCode = statusCode;
      this.message = message;
    }
  }
}
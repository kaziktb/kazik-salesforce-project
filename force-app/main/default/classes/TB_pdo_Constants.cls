public without sharing class TB_pdo_Constants {
  // ACHIEVEMENT TYPES && VERSIONS
  public final static String ARTICLE = 'Article';
  public final static String ARTISTIC = 'Artistic';
  public final static String BOOK = 'Book';
  public final static String DATASET = 'Dataset';
  public final static String FINAL_PUBLISHED = 'final_published';
  public final static String FINAL_AUTHOR = 'final_author';

  // HTTP CODES
  public final static Integer SUCCESS_CODE = 200;
  public final static Integer SERVER_ERROR_CODE = 500;

  // Integration events
  public final static String DRAFT_EVENT = 'DRAFT';
  public final static String DATA_MODIFICATION_EVENT = 'DATA_MODIFICATION';
  public final static String EDITOR_QUEUE_EVENT = 'EDITOR_QUEUE';
  public final static String DELETE_DRAFT_EVENT = 'DELETE_DRAFT';
  public final static String EDITOR_CLAIM_EVENT = 'EDITOR_CLAIM';
  public final static String EDITOR_REJECT_EVENT = 'EDITOR_REJECT';
  public final static String DEPOSIT_EVENT = 'DEPOSIT';

  //Fields
  public final static String SCIENCECLOUD_STATUS = 'Sciencecloud_Status';
  public final static String REWARDED = 'Rewarded';

  // PDO statuses
  public final static String IN_PROGRESS_STATUS = 'In_Progress';
  public final static String READY_STATUS = 'Ready';
  public final static String TO_VERIFY_STATUS = 'To_Verify';
  public final static String VALIDATED_STATUS = 'Validated';
  public final static String VERIFICATION_STATUS = 'Verification';
  public final static String VERIFICATION_PENDING_STATUS = 'Verification_Pending';
  public final static String CORRECTED_STATUS = 'Corrected';
  public final static String NEW_STATUS = 'New';
  public final static String TO_CONFIRM_STATUS = 'To Confirm';
  public final static String VERIFICATION_STATUS_PL = 'Weryfikacja';
  public final static String READY_STATUS_PL = 'Gotowy';
  public final static String CONFIRMATION_PENDING_STATUS = 'Confirmation_Pending';
  public final static String TO_CORRECT_STATUS = 'To_Correct';
  public static final String STATUS_TO_SIGNATURE = 'To_Signature';
  public final static String PUBLISHED_STATUS = 'Published';
  public final static String APPROVED_STATUS = 'Approved';
  public final static String RELEASED_STATUS = 'Released';
  public final static String DRAFT_STATUS = 'Draft';
  public final static String FOR_APPROVAL_STATUS = 'for_approval';
  public final static String IMPROVE_STATUS = 'Improve';
  public final static String VERIFIED_STATUS = 'Verified';
  public final static String FOR_APPROVAL_STATUS_UP = 'For_Approval';

  // Contact statutses
  public final static String CURRENT_STATUS = 'Current';

  // Messages
  public final static String NO_PDO_FOUND = 'No pdo with given source ID was found';
  public final static String PDO_CREATED = 'Object inserted under Id ';
  public final static String PDO_UPDATED = 'Updated successfully';
  public final static String PDO_DELETED = 'Record scheduled to be deleted';
  public final static String PDO_UPDATED_EC = 'Record updated with editor claim';
  public final static String PDO_UPDATED_ER = 'Record updated with editor reject';
  public final static String SCIENCECLOUD_FAIL = 'Something went wrong with sciencecloud communication';
  public final static String SCIENCECLOUD_AUTH_FAIL = 'Something went wrong with azure authorization';
  public final static String DEPOSIT_UPDATE = 'Record updated successfully';

  // Miscellaneous
  public final static String METADATALIST = 'metadataList';
  public static final String CONTENT_VISIBILITY = 'AllUsers';
  public static final String CONTENT_SHARE_TYPE_V = 'V';
  public static final String ARTISTIC_ACHIEVEMENT_TYPE = 'TB_Artistic_Achievement';
  public static final String ARTISTIC_ACHIEVEMENT_FILE_TEMPLATE_CATEGORY = 'Affiliate_Statement_Template_Artistic';
  public static final String SCIENCE_ACHIEVEMENT_FILE_TEMPLATE_CATEGORY = 'Affiliate_Statement_Template_Science';
  public static final String AFFILIATE_STATEMENT_TEMPLATE_PARTICIPANT = 'Affiliate_Statement_Template_Participant';
  public static final String PARAM_RECORD_IDS = 'recordIds';

  public static final String POLICY_DOCUMENT_CATEGORY = 'Open_Access_Policy_Document';
  public static final String POLICY_DOCUMENT_CATEGORY_EN = 'Open_Access_Policy_Document_EN';

  public static final String POLISH_LANGUAGE_CODE = 'pl';

  public static final String CONTENT_VERSION_ASF_CATEGORY = 'Affiliate_Statement_File';
  public final static String PDO_OBJECT_NAME = 'TB_PDO__c';
  public final static String ARTISTIC_ACHIEVEMENT = 'TB_Artistic_Achievement';
  public final static String DATA_FORMAT = 'yyyyMMdd';

  public final static String MONOGRAPHY_EDITION_TYPE = 'MonographyEdition';
  public final static String MONOGRAPHY_EDITION_CONFERENCE_TYPE = 'MonographyEditionConference';
  public final static String PARTICIPANT_ROLE_AUTHOR = 'Author';

  public final static String SEND = 'send';
  public final static String NO_SEND = 'nosend';
  public final static String AGREEMENT = 'Agreement';
  public final static String RESEARCH = 'Research';
  public final static String INSTITUTION = 'Institution';
  public final static String UNIVERSITY_DEPARTMENT = 'University Department';
  public final static String CATHEDRAL = 'Cathedral';
  public final static String DEPARTMENT = 'Faculty';
  public final static String INSTITUTE = 'Institute';
  public final static String CENTER = 'Center';

  public final static String AEBS = 'AEBS';
  public final static String AEDS = 'AEDS';
  public final static String AERS = 'AERS';
  public final static String DSSS = 'DSSS';
  public final static String NETS = 'NETS';

  // RECORDTYPES
  public final static String EMPLOYEE_RT = 'Employee';
  public final static String CREDENTIAL_RT = 'Credential';
}
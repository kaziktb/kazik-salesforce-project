/**
 * Created by kamilkwaczynski on 07/07/2022.
 */

public with sharing class TB_vu_AvatarsController {
  @TestVisible
  public static Boolean hasDefaultPicture;

  @TestVisible
  public static String url;
  static String gender;

  @AuraEnabled
  public static String getUserAvatarInfo(ID userId) {
    Contact contact;
    try {
      contact = [
        SELECT hed__Gender__c, TB_User__r.SmallPhotoUrl
        FROM Contact
        WHERE TB_User__c = :userId
        LIMIT 1
      ];
    } catch (Exception e) {
    }

    if (contact != null) {
      validateAvatarData(contact.TB_User__r.SmallPhotoUrl);
      TB_vu_AvatarsController.gender = contact.hed__Gender__c;
    } else {
      User user = [SELECT SmallPhotoUrl FROM User WHERE Id = :userId LIMIT 1];
      validateAvatarData(user.SmallPhotoUrl);
      TB_vu_AvatarsController.gender = '';
    }

    Avatar avatar = new Avatar(
      TB_vu_AvatarsController.hasDefaultPicture,
      TB_vu_AvatarsController.gender,
      TB_vu_AvatarsController.url
    );
    system.debug('******');
    system.debug(JSON.serialize(avatar));
    return JSON.serialize(avatar);
  }

  @TestVisible
  private static void validateAvatarData(String pictureUrl) {
    TB_vu_AvatarsController.hasDefaultPicture = pictureUrl.contains('/005');
    TB_vu_AvatarsController.url = TB_vu_AvatarsController.hasDefaultPicture
      ? ''
      : System.Url.getSalesforceBaseURL().toExternalForm() + pictureUrl;
  }

  public class Avatar {
    public Boolean hasDefaultPicture { get; set; }

    public String gender { get; set; }

    public String pictureUrl { get; set; }

    public Avatar(Boolean hasDefaultPicture, String gender, String pictureUrl) {
      this.hasDefaultPicture = hasDefaultPicture;
      this.gender = gender;
      this.pictureUrl = pictureUrl;
    }
  }
}
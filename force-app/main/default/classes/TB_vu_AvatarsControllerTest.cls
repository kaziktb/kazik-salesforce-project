@IsTest
private class TB_vu_AvatarsControllerTest {
  @TestSetup
  static void setup() {
    User user = TB_TestDataFactory.prepareUser();
    insert user;
  }

  @isTest
  static void checkAvatarInfoWhenNoContactsAndDefaultPicture() {
    User user = [
      SELECT Id, SmallPhotoUrl
      FROM User
      WHERE Email = 'puser000@amamama.com'
      LIMIT 1
    ];
    TB_vu_AvatarsController.Avatar avatar = new TB_vu_AvatarsController.Avatar(
      true,
      '',
      ''
    );
    String expectedData = JSON.serialize(avatar);
    Test.startTest();
    String actualData = TB_vu_AvatarsController.getUserAvatarInfo(user.Id);
    Test.stopTest();
    System.assertEquals(expectedData, actualData);
  }

  @isTest
  static void checkAvatarInfoWhenNoContactsAndCustomPicture() {
    String photoUrl = 'https://swps-talenty--devtbpdo.sandbox.file.force.com/profilephoto/0008946/T';

    String picUrl =
      System.Url.getSalesforceBaseURL().toExternalForm() + photoUrl;

    Test.startTest();
    TB_vu_AvatarsController.validateAvatarData(photoUrl);
    Test.stopTest();
    System.assertEquals(picUrl, TB_vu_AvatarsController.url);
  }
}
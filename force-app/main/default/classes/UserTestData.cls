@IsTest
public class UserTestData {
    public static final String DEFAULT_ALIAS = 'Test';
    public static final String DEFAULT_EMAIL = 'test@swps.edu.pl.unit.test';
    public static final String DEFAULT_EMAIL_ENCODING_KEY = 'UTF-8';
    public static final String DEFAULT_LAST_NAME = 'Last Name';
    public static final String DEFAULT_USER_NAME = 'test@swps.edu.pl.unit.test';
    public static final String DEFAULT_FEDERATION_IDENTIFIER = 'federationId@swps.edu.pl.test';
    public static final String LANGUAGE_LOCALE_KEY = 'pl';
    public static final String LOCALE_SID_KEY = 'pl_PL';
    public static final String TIME_ZONE_SID_KEY = 'Europe/Warsaw';
    public static Integer count = 0;
    private User record;

    public UserTestData() {
        this.record = new User();
        count++;
        this.applyDefaults();
    }

    public UserTestData(UserTestData testData) {
        this.record = testData.record.clone(false, true, false, false);
        count++;
        this.applyDefaults();
    }

    public virtual UserTestData applyDefaults() {
        return this.withAlias(getDefaultAlias())
            .withEmail(getDefaultEmail())
            .withEmailEncodingKey(DEFAULT_EMAIL_ENCODING_KEY)
            .withLastName(DEFAULT_LAST_NAME)
            .withUserName(getDefaultUserName())
            .asActive()
            .withLanguageLocaleKey(LANGUAGE_LOCALE_KEY)
            .withLocaleSidKey(LOCALE_SID_KEY)
            .withTimeZone(TIME_ZONE_SID_KEY)
            .withFederationIdentifier(getDefaultFederationIdentifier());
    }

    public UserTestData copy() {
        return new UserTestData(this);
    }

    public User get() {
        return record;
    }

    public UserTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public String getDefaultEmail() {
        return String.join(new List<String>{ String.valueOf(count), DEFAULT_EMAIL }, '');
    }

    public String getDefaultAlias() {
        return String.join(new List<String>{ DEFAULT_ALIAS, String.valueOf(count) }, '');
    }

    public String getDefaultUserName() {
        return String.join(new List<String>{ DEFAULT_USER_NAME, String.valueOf(count) }, '');
    }

    public String getDefaultFederationIdentifier() {
        return String.join(new List<String>{ DEFAULT_FEDERATION_IDENTIFIER, String.valueOf(count) }, '');
    }

    public UserTestData withEmailEncodingKey(String value) {
        record.EmailEncodingKey = value;
        return this;
    }

    public UserTestData withAlias(String value) {
        record.Alias = value;
        return this;
    }

    public UserTestData withEmail(String value) {
        record.Email = value;
        return this;
    }

    public UserTestData withLastName(String value) {
        record.LastName = value;
        return this;
    }

    public UserTestData withUserName(String value) {
        record.Username = value;
        return this;
    }

    public UserTestData withLanguageLocaleKey(String value) {
        record.LanguageLocaleKey = value;
        return this;
    }

    public UserTestData withLocaleSidKey(String value) {
        record.LocaleSidKey = value;
        return this;
    }

    public UserTestData withTimeZone(String value) {
        record.TimeZoneSidKey = value;
        return this;
    }

    public UserTestData withProfile(Id value) {
        record.ProfileId = value;
        return this;
    }

    public UserTestData asActive() {
        record.IsActive = true;
        return this;
    }

    public UserTestData withContact(Id value) {
        record.ContactId = value;
        return this;
    }

    public UserTestData withFederationIdentifier(String federationIdentifier) {
        record.FederationIdentifier = federationIdentifier;
        return this;
    }

    public UserTestData withRole(Id value) {
        record.UserRoleId = value;
        return this;
    }

    public UserTestData withCommunityNickname(String value) {
        record.CommunityNickname = value;
        return this;
    }
}
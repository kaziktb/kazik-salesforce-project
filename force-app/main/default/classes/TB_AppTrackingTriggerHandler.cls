public without sharing class TB_AppTrackingTriggerHandler extends TB_TriggerHandler {
    private final static String HIGHER_EDUCATION = 'Higher_Education';

    public override void beforeInsert() {
      generateregistrationLink(Trigger.new);
      createCommunityUser(Trigger.new);
        for (TB_App_Tracking__c app : (List<TB_App_Tracking__c>) Trigger.new) {
            capitalizeNameValues(app);
        }
    }
    
    public override void beforeUpdate() {
        for (TB_App_Tracking__c app : (List<TB_App_Tracking__c>) Trigger.new) {
            capitalizeNameValues(app);
        }
  }

    public override void afterUpdate() {
        List<TB_App_Tracking__c> toCancel = new List<TB_App_Tracking__c>();
        List<TB_App_Tracking__c> toCancelSynced = new List<TB_App_Tracking__c>();
        for(Id appTrack : Trigger.newMap.keySet()){
            TB_App_Tracking__c newRec = (TB_App_Tracking__c) Trigger.newMap.get( appTrack );
            TB_App_Tracking__c oldRec = (TB_App_Tracking__c) Trigger.oldMap.get( appTrack );
            if(  newRec.TB_Process_Status__c != oldRec.TB_Process_Status__c
                 && newRec.TB_Process_Status__c == 'Process_Cancelled')
                {
                    if( oldRec.TB_Process_Status__c == 'New'
                     || oldRec.TB_Process_Status__c == 'Data_Completion'
                     || oldRec.TB_Process_Status__c == 'Data_Verification')
                    {
                        toCancel.add(newRec);
                    }
                    else if(  oldRec.TB_Process_Status__c == 'Data_Synced'
                            || oldRec.TB_Process_Status__c == 'Data_Sync_Error'
                            || oldRec.TB_Process_Status__c == 'Finished'){
                        toCancelSynced.add(newRec);
                    }
                 }
        }
        if(!toCancel.isEmpty()){
            cancelationOfProcesses(toCancel,false);
        }
        if(!toCancelSynced.isEmpty()){
            cancelationOfProcesses(toCancelSynced,true);
        }
    }


    private static void generateregistrationLink(List <TB_App_Tracking__c> inputs ){
        TB_Community_main_url__mdt communityLink = TB_Community_main_url__mdt.getInstance('Community_Register_Url');

        for(TB_App_Tracking__c current : inputs){
            String tocrypt = current.TB_Email__c +' '+ current.TB_Phone__c;

            current.TB_Registration_Url__c = communityLink.Community_URL__c +
                    '?data='+EncodingUtil.urlEncode(TB_Crypto.cryptLiteral('Application_Tracking_Settings', tocrypt),'UTF-8');
        }
    }

    private static void createCommunityUser(List <TB_App_Tracking__c> inputs ){
        String username = '%' + TB_Community_Default_Account_Owner__mdt.getInstance('Contract_Teacher').User_Name__c + '%';
        String profileName = TB_Community_Default_Account_Owner__mdt.getInstance('Contract_Teacher').Profile_Name__c;
        
        User portalAccountOwner;
        if(!Test.isRunningTest()){
            portalAccountOwner = [SELECT ID,Username FROM User WHERE Username LIKE: username];
        }
        else{
            portalAccountOwner = new User( Id = UserInfo.getUserId());
        } 

        Id profileId = [Select Id From Profile Where Name = :profileName LIMIT 1].Id;

        Map<String,User> usersToInsert = new Map<String,User>();
        Map<String,Contact> contactsToInsert = new Map<String,Contact>();
        Map<String,Account> accountsToinsert = new Map<String,Account>();
        for(TB_App_Tracking__c current : inputs){
            Account act = new Account(
                Name = current.TB_First_Name__c + ' '+ current.TB_Last_Name__c,
                OwnerId = portalAccountOwner.id
            );
            accountsToinsert.put(current.TB_Email__c, act);
        }
        insert accountsToinsert.values();

        for(TB_App_Tracking__c current : inputs){
            String generated_password = TB_RandomDataUtils.generatePassword(5, 5, 3).replace('0', '9');
            current.TB_Generated_Password__c = generated_password;
            Contact con = new Contact(
                FirstName = current.TB_First_Name__c, 
                LastName = current.TB_Last_Name__c,
                MiddleName = current.TB_Middle_Name__c,
                Salutation = current.TB_Salutation__c,
                AccountId = accountsToinsert.get(current.TB_Email__c).Id,
                email=current.TB_Email__c,
                hed__AlternateEmail__c = current.TB_Email__c,
                Phone = current.TB_Phone__c,
                hed__PreferredPhone__c = 'Mobile',
                MobilePhone = current.TB_Phone__c
                );
            contactsToInsert.put(current.TB_Email__c, con);
    }

        insert contactsToInsert.values();

        for(TB_App_Tracking__c current : inputs){
            current.TB_Applicant__c = contactsToInsert.get(current.TB_Email__c).Id;
        }

        for(TB_App_Tracking__c current : inputs){
            String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            String hexDigest = EncodingUtil.convertToHex(hash);
            String verificationCode = TB_RandomDataUtils.generateUUID();

            User communityUser = new User(  FirstName = current.TB_First_Name__c, 
                                            LastName = current.TB_Last_Name__c,
                                            Email = current.TB_Email__c,
                                            ContactId = contactsToInsert.get(current.TB_Email__c).Id,
                                            ProfileId = profileId,
                                            Alias = TB_RandomDataUtils.generateRandomText(6),
                                            UserName = 'Applicant' + verificationCode + '@st.swps.edu.pl',
                                            CommunityNickName = hexDigest,
                                            TimeZoneSidKey = 'Europe/Prague',
                                            LocaleSidKey = 'pl_PL', 
                                            EmailEncodingKey = 'ISO-8859-1', 
                                            LanguageLocaleKey = 'en_US',
                                            TB_Verification_Code__c = verificationCode
                                        );
                        usersToInsert.put(current.TB_Email__c, communityUser); 
        }
        insert usersToInsert.values();
    
        for(TB_App_Tracking__c current : inputs){
            contactsToInsert.get(current.TB_Email__c).TB_User__c = usersToInsert.get(current.TB_Email__c).Id;
        }
        update contactsToInsert.values();

        if(!Test.isRunningTest()){
            for(TB_App_Tracking__c current : inputs){
                System.setPassword(usersToInsert.get(current.TB_Email__c).Id, current.TB_Generated_Password__c);
            }
        }
    
        for(TB_App_Tracking__c current : inputs){
            Map<String, Object> accountActivationFlowParameters = new Map<String, Object>{
                'RecordId' => current.TB_Applicant__c,
                'MessageType' => 'AccountActivation',
                'FirstName' => current.TB_First_Name__c,
                'EmailAddress' => current.TB_Email__c,
                'URL' => getAdmissionsPortal()
                };
                Flow.Interview.TB_Contract_Teachers_Account_Handling_Notification accountActivationFlow = new Flow.Interview.TB_Contract_Teachers_Account_Handling_Notification(
                        accountActivationFlowParameters
                );
                accountActivationFlow.start();
        }
    }

    private static String getAdmissionsPortal() {
        List<TB_TC_URLs__c> admissionsPortal = [
                SELECT TB_Admissions_Portal__c
                FROM TB_TC_URLs__c
        ];
        return admissionsPortal[0].TB_Admissions_Portal__c;
    }

    private static void capitalizeNameValues(TB_App_Tracking__c app) {
        app.TB_First_Name__c = new TB_CT_CapitalLetterUtils(app.TB_First_Name__c).capitalizeValue();
        app.TB_Last_Name__c = new TB_CT_CapitalLetterUtils(app.TB_Last_Name__c).capitalizeValue();
    }

    private static void sendMailDeactivate(Set<String> emailsToSend,TB_App_Tracking__c app,Boolean isSynced){
        Map<String, Object> appTrackAccountDeactivationNotificationFlow = new Map<String, Object>{
            'emailsToSend' => emailsToSend,
            'applicationId' => app.TB_Dean_s_Office_Responsible__c,
            'appTrackId' => app.Id,
            'IsSynced' => isSynced
        };

        Flow.Interview.TB_CT_Send_Cancel_Notification_AppTracking flowNotification = new Flow.Interview.TB_CT_Send_Cancel_Notification_AppTracking(
                appTrackAccountDeactivationNotificationFlow
        );
        flowNotification.start();
    }

    private static void cancelationOfProcesses(List<TB_App_Tracking__c> apps ,Boolean isSynced){
        Set<Id> contactsToDel = new Set<Id>();
        Set<Id> accountsToDel = new Set<Id>();
        Set<Id> usersToDeactivate = new Set<Id>();
        Set<String> emailsToSend = new Set<String>();
        Set<Id> contactsToSend = new Set<Id>();
        for(TB_App_Tracking__c app : apps){
            contactsToDel.add(app.TB_Applicant__c);
            nullFilter(emailsToSend,app.TB_Primary_Responsible_Email__c);
            nullFilter(emailsToSend,app.TB_Email__c);
            nullFilter(emailsToSend,app.TB_Responsible_Coordinator_Email__c);
            nullFilter(emailsToSend,app.TB_Additional_Responsible_Email__c);
            sendMailDeactivate(emailsToSend,app,isSynced);
            
            emailsToSend.clear();
        }
        Map<ID, Contact> m = new Map<ID, Contact>([SELECT Id, AccountId,TB_User__c FROM Contact WHERE ID IN :contactsToDel]);

        for(TB_App_Tracking__c app : apps){
            accountsToDel.add(m.get(app.TB_Applicant__c)?.AccountId);
            usersToDeactivate.add(m.get(app.TB_Applicant__c)?.TB_User__c);
        }
        if(!Test.isRunningTest()){
            System.enqueueJob(new TB_CT_DeactivateUser(contactsToDel,accountsToDel,usersToDeactivate,isSynced));
        }
    }

    private static void  nullFilter( Set<String> emailsToSend  , String email){
        if(email!= null){
            emailsToSend.add(email);
        }
    }
}
public with sharing class TB_IC_RelatedContactsController {
    private static final String BLANK_VALUE = '-';
    private static final String EXTENDED_CONTACT_QUERY = ' OR AccountId = :partnerId';
    private static final String OPPORTUNITY_OWNER_MEMBER_ROLE = 'Opportunity Owner';
    private static final String ACCOUNT_MANAGER_MEMBER_ROLE = 'Account Manager';
    private static final String OWNER_ID = 'Owner_Id';
    private static String setValueForNull(String value) {
        return (value == null) ? BLANK_VALUE : value;
    }

    @AuraEnabled(Cacheable=true)
    public static List<ContactWrapper> fetchRelatedPartnerContact(Id partnerId, Boolean extendedAccess) {
        List<Id> AccountTeamUserId = new List<Id>();
        for(AccountTeamMember userId : [ SELECT UserId FROM AccountTeamMember WHERE AccountId = :partnerId 
                                        AND (TeamMemberRole = :OPPORTUNITY_OWNER_MEMBER_ROLE  
                                        OR TeamMemberRole = :ACCOUNT_MANAGER_MEMBER_ROLE)]){
            AccountTeamUserId.add(userId.UserId);
        }
    
        List<ContactWrapper> PartnerContactWrappers = new List<ContactWrapper>();
        String query = 'SELECT Id, Name, TB_Profession__c, hed__WorkEmail__c, hed__WorkPhone__c, TB_x_Record_Type__c FROM Contact WHERE TB_User__c = :AccountTeamUserId ';
        
        if(extendedAccess){
            query += EXTENDED_CONTACT_QUERY;
        }

        for (Contact record : Database.query(query)) {
            ContactWrapper PartnerContactWrapper = new ContactWrapper();
            PartnerContactWrapper.setValues(
                    record.Id,
                    record.Name,
                    record.TB_Profession__c,
                    record.hed__WorkEmail__c,
                    record.hed__WorkPhone__c,
                    record.TB_x_Record_Type__c
            );
            PartnerContactWrappers.add(PartnerContactWrapper);
        }
        return PartnerContactWrappers;
    }

    public class ContactWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String partnerProfession;
        @AuraEnabled public String partnerEmail;
        @AuraEnabled public String partnerPhone;
        @AuraEnabled public String partnerRecordType;

        public void setValues(
                Id id,
                String name,
                String partnerProfession,
                String partnerEmail,
                String partnerPhone,
                String partnerRecordType 
        ) {
            this.id = id;
            this.name = setValueForNull(name);
            this.partnerProfession = setValueForNull(partnerProfession);
            this.partnerEmail = setValueForNull(partnerEmail);
            this.partnerPhone = setValueForNull(partnerPhone);
            this.partnerRecordType = setValueForNull(partnerRecordType);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ContractContactWrapper> fetchRelatedContractContacts(Id contractId, Boolean extendedAccess) {

        Set<Id> contactIds = new Set<Id>();
        Map<Id, String> contractRole = new Map<Id, String>();

        Contract ownerUserId = [SELECT OwnerId FROM Contract WHERE Id = :contractId];
        if (ownerUserId.OwnerId!= null) {
            Contact ownerContactId = [SELECT Id FROM Contact WHERE TB_User__c = :ownerUserId.OwnerId];
            contactIds.add(ownerContactId.Id);
            contractRole.put(ownerContactId.Id, OWNER_ID);
        }

        if (extendedAccess) {
            Contract contractRecord = [SELECT DT_Company_Signed_By_Contact__c, 
                                                DT_Additional_SWPS_Contact_Person__c,
                                                DT_SWPS_Contact_Person__c, 
                                                DT_Additional_Partner_Contact_Person__c,
                                                DT_Partner_Contact_Person__c 
                                                FROM Contract WHERE Id = :contractId];

            if (contractRecord.DT_Company_Signed_By_Contact__c != null) {
                contactIds.add(contractRecord.DT_Company_Signed_By_Contact__c);
                contractRole.put(contractRecord.DT_Company_Signed_By_Contact__c, Contract.DT_Company_Signed_By_Contact__c.getDescribe().getLabel());
            }
            if (contractRecord.DT_Additional_SWPS_Contact_Person__c != null) {
                contactIds.add(contractRecord.DT_Additional_SWPS_Contact_Person__c);
                contractRole.put(contractRecord.DT_Additional_SWPS_Contact_Person__c, Contract.DT_Additional_SWPS_Contact_Person__c.getDescribe().getLabel());
            }
            if (contractRecord.DT_SWPS_Contact_Person__c != null) {
                contactIds.add(contractRecord.DT_SWPS_Contact_Person__c);
                contractRole.put(contractRecord.DT_SWPS_Contact_Person__c, Contract.DT_SWPS_Contact_Person__c.getDescribe().getLabel());
            }
            if (contractRecord.DT_Additional_Partner_Contact_Person__c != null) {
                contactIds.add(contractRecord.DT_Additional_Partner_Contact_Person__c);
                contractRole.put(contractRecord.DT_Additional_Partner_Contact_Person__c, Contract.DT_Additional_Partner_Contact_Person__c.getDescribe().getLabel());
            }
            if (contractRecord.DT_Partner_Contact_Person__c != null) {
                contactIds.add(contractRecord.DT_Partner_Contact_Person__c);
                contractRole.put(contractRecord.DT_Partner_Contact_Person__c, Contract.DT_Partner_Contact_Person__c.getDescribe().getLabel());
            }
        }

        List<Contact> relatedContacts = [SELECT Id, 
                                                Name, 
                                                TB_Profession__c, 
                                                hed__WorkEmail__c, 
                                                hed__WorkPhone__c, 
                                                TB_x_Record_Type__c 
                                                FROM Contact 
                                                WHERE Id IN :contactIds];
        List<ContractContactWrapper> contractContactWrappers = new List<ContractContactWrapper>();

        for (Contact record : relatedContacts) {
            ContractContactWrapper contractContactWrapper = new ContractContactWrapper();
            contractContactWrapper.setValues(
                    record.Id,
                    record.Name,
                    record.TB_Profession__c,
                    record.hed__WorkEmail__c,
                    record.hed__WorkPhone__c,
                    record.TB_x_Record_Type__c,
                    contractRole.get(record.Id)
            );
            contractContactWrappers.add(contractContactWrapper);
        }
        return contractContactWrappers;     
    }

    public class ContractContactWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String partnerProfession;
        @AuraEnabled public String partnerEmail;
        @AuraEnabled public String partnerPhone;
        @AuraEnabled public String partnerRecordType;
        @AuraEnabled public String role;

        public void setValues(
            Id id,
            String name,
            String partnerProfession,
            String partnerEmail,
            String partnerPhone,
            String partnerRecordType,
            String role
        ) {
            this.id = id;
            this.name = setValueForNull(name);
            this.partnerProfession = setValueForNull(partnerProfession);
            this.partnerEmail = setValueForNull(partnerEmail);
            this.partnerPhone = setValueForNull(partnerPhone);
            this.partnerRecordType = setValueForNull(partnerRecordType);
            this.role = role;
        }
    }    
}
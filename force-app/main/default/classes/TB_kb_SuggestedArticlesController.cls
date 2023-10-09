public without sharing class TB_kb_SuggestedArticlesController {

    @TestVisible
    private static Id getRecordTypeId(String developerName){
        return Schema.SObjectType.TB_Suggested_Article_Group__c.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }

    @AuraEnabled
    public static List<SuggestedArticleWrapper> getSuggestedArticlesBySubcategoryId(Id knowledgeCategoryId) {
        Id assignedToSubcategoryRecordTypeId = getRecordTypeId(TB_kb_Constants.ASSIGNED_TO_SUBCATEGORY_SUGGESTED_ARTICLE_GROUP_RT_DEVNAME);
        List<SuggestedArticleWrapper> toReturn = new List<SuggestedArticleWrapper>();
        try{
            Id suggestedArticleGroupId;
            for(TB_JSON_Wrapper__c singleJsonWrapper : [
                    SELECT TB_Wrapper_Value__c
                    FROM TB_JSON_Wrapper__c
                    WHERE TB_Object_API_Name__c =: TB_kb_Constants.SUGGESTED_ARTICLE_GROUP_API_NAME
                ]) {
                TB_Suggested_Article_Group__c singleElement = (TB_Suggested_Article_Group__c) JSON.deserialize(singleJsonWrapper.TB_Wrapper_Value__c, TB_Suggested_Article_Group__c.class);
                if(singleElement.TB_Knowledge_Category__c == knowledgeCategoryId && singleElement.RecordTypeId == assignedToSubcategoryRecordTypeId){
                    suggestedArticleGroupId = singleElement.Id;
                    break;
                }
            }

			Map<Decimal, List<Id>> orderToKaIds = new Map<Decimal, List<Id>>();
            Set<Id> kaIds = new Set<Id>();
            for(TB_JSON_Wrapper__c singleJsonWrapper : [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c =: TB_kb_Constants.SUGGESTED_ARTICLE_GROUP_ELEMENT_API_NAME
                ORDER BY TB_Order__c
            ]){
                TB_Suggested_Article_Group_Element__c singleElement = (TB_Suggested_Article_Group_Element__c) JSON.deserialize(singleJsonWrapper.TB_Wrapper_Value__c, TB_Suggested_Article_Group_Element__c.class);
                if(singleElement.TB_Suggested_Article_Group__c == suggestedArticleGroupId){
                    if(orderToKaIds.get(singleElement.TB_Order__c) == null)
                        orderToKaIds.put(singleElement.TB_Order__c, new List<Id>{singleElement.TB_Article_Parent_Id__c});
                    else 
                        orderToKaIds.get(singleElement.TB_Order__c).add(singleElement.TB_Article_Parent_Id__c);
                }
            }

            for(Decimal key : orderToKaIds.keySet()){
                if(kaIds.size() < 5){
                    for(Id value : orderToKaIds.get(key)){
                        kaIds.add(value);
                    }
                }
            }

            for(Knowledge__kav kav : [
                SELECT 
                    KnowledgeArticleId,
                    Title,
                    TB_Knowledge_Category__c
                FROM Knowledge__kav 
                WHERE KnowledgeArticleId IN: kaIds 
                AND IsLatestVersion = true 
                AND PublishStatus =: TB_kb_Constants.ONLINE_KAV_PUBLISH_STATUS 
                AND Language =: UserInfo.getLanguage()
                LIMIT 5
            ]){
                toReturn.add(
                    new SuggestedArticleWrapper(
                        kav.KnowledgeArticleId,
                        kav.TB_Knowledge_Category__c,
                        kav.Title
                    )
                );
            }
        }catch(Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_kb_SuggestedArticlesController.class.getName(),e.getStackTraceString(),knowledgeCategoryId));
        }
        return toReturn;
    }

    @AuraEnabled
    public static List<SuggestedArticleGroupWrapper> getSuggestedArticlesByContactGroups(Id contactId) {
        Id assignedToContactGroupRecordTypeId = getRecordTypeId(TB_kb_Constants.ASSIGNED_TO_CONTACT_GROUP_SUGGESTED_ARTICLE_GROUP_RT_DEVNAME);
        List<SuggestedArticleGroupWrapper> toReturn = new List<SuggestedArticleGroupWrapper>();
        try{
            List<String> contactGroupsAssignedToContact = getGroups(contactId);
            List<Id> suggestedArticleGroupIds = new List<Id>();
            Map<Id, String> articleGroupNameById = new Map<Id,String>();
            for(TB_JSON_Wrapper__c singleJsonWrapper : [
                    SELECT TB_Wrapper_Value__c
                    FROM TB_JSON_Wrapper__c
                    WHERE TB_Object_API_Name__c =: TB_kb_Constants.SUGGESTED_ARTICLE_GROUP_API_NAME
                    ORDER BY TB_Order__c
                ]) {
                TB_Suggested_Article_Group__c singleElement = (TB_Suggested_Article_Group__c) JSON.deserialize(singleJsonWrapper.TB_Wrapper_Value__c, TB_Suggested_Article_Group__c.class);
                if(singleElement.RecordTypeId == assignedToContactGroupRecordTypeId && contactGroupsAssignedToContact.contains(singleElement.TB_Contact_Group__c)){
                    String articleGroupName = UserInfo.getLanguage() == 'PL' ?
                        singleElement.TB_Suggested_Article_Group_Name_PL__c :
                        singleElement.TB_Suggested_Article_Group_Name_EN__c;
                    articleGroupNameById.put(singleElement.Id, articleGroupName);
                    suggestedArticleGroupIds.add(singleElement.Id);
                }
            }
            if(suggestedArticleGroupIds.size() > 0){
                Map<Id, Map<Decimal, List<String>>> kaIdsByOrderBySuggestedArticleGroupId = new Map<Id, Map<Decimal, List<String>>>();
                for(TB_JSON_Wrapper__c singleJsonWrapper : [
                    SELECT TB_Wrapper_Value__c
                    FROM TB_JSON_Wrapper__c
                    WHERE TB_Object_API_Name__c =: TB_kb_Constants.SUGGESTED_ARTICLE_GROUP_ELEMENT_API_NAME
                    ORDER BY TB_Order__c
                ]){
                    TB_Suggested_Article_Group_Element__c singleElement = (TB_Suggested_Article_Group_Element__c) JSON.deserialize(singleJsonWrapper.TB_Wrapper_Value__c, TB_Suggested_Article_Group_Element__c.class);
                    if(suggestedArticleGroupIds.contains(singleElement.TB_Suggested_Article_Group__c)){
                        if(kaIdsByOrderBySuggestedArticleGroupId.get(singleElement.TB_Suggested_Article_Group__c) == null){
                            kaIdsByOrderBySuggestedArticleGroupId.put(singleElement.TB_Suggested_Article_Group__c, new Map<Decimal, List<String>>{
                                singleElement.TB_Order__c => new List<String>{singleElement.TB_Article_Parent_Id__c}
                            });
                        }

                        else if(kaIdsByOrderBySuggestedArticleGroupId.get(singleElement.TB_Suggested_Article_Group__c).get(singleElement.TB_Order__c) != null){
                            kaIdsByOrderBySuggestedArticleGroupId.get(singleElement.TB_Suggested_Article_Group__c).get(singleElement.TB_Order__c).add(singleElement.TB_Article_Parent_Id__c);
                        }
                        else{
                            kaIdsByOrderBySuggestedArticleGroupId.get(singleElement.TB_Suggested_Article_Group__c).put(singleElement.TB_Order__c, new List<String>{singleElement.TB_Article_Parent_Id__c});
                        }
                            
                    }
                }
    
                Map<Id, List<String>> groupNamesByKaId = new Map<Id, List<String>>();
                Set<Id> kaIds = new Set<Id>();
                Integer articlesCounter = 0;
                for(Id sagId : kaIdsByOrderBySuggestedArticleGroupId.keySet()){
                    articlesCounter = 0;
                    for(Decimal order : kaIdsByOrderBySuggestedArticleGroupId.get(sagId).keySet()){
                        for(String kaId : kaIdsByOrderBySuggestedArticleGroupId.get(sagId).get(order)){
                            if(articlesCounter < 5){
                                articlesCounter++;
                                kaIds.add(kaId);
                                if(groupNamesByKaId.get(kaId) == null){
                                    groupNamesByKaId.put(kaId, new List<String>{articleGroupNameById.get(sagId)});
                                }
                                else{
                                    groupNamesByKaId.get(kaId).add(articleGroupNameById.get(sagId));
                                }
                            }
                        }
                    }
                }
                Map<String, List<SuggestedArticleWrapper>> articlesByNames = new Map<String, List<SuggestedArticleWrapper>>();
                for(Knowledge__kav kav : [
                    SELECT 
                        KnowledgeArticleId,
                        Title,
                        TB_Knowledge_Category__c
                    FROM Knowledge__kav 
                    WHERE KnowledgeArticleId IN: kaIds 
                    AND IsLatestVersion = true 
                    AND PublishStatus =: TB_kb_Constants.ONLINE_KAV_PUBLISH_STATUS 
                    AND Language =: UserInfo.getLanguage()
                ]){
                    SuggestedArticleWrapper elementToAdd = new SuggestedArticleWrapper(
                        kav.KnowledgeArticleId,
                        kav.TB_Knowledge_Category__c,
                        kav.Title
                    );
                    for(String groupName : groupNamesByKaId.get(kav.KnowledgeArticleId)){
                        if(articlesByNames.get(groupName) == null){
                            articlesByNames.put(groupName, new List<SuggestedArticleWrapper>{elementToAdd});
                        }
                        else if(articlesByNames.get(groupName).size() < 5){
                            articlesByNames.get(groupName).add(elementToAdd);
                        }
                    }
                }

                for(String name : articlesByNames.keySet()){
                    toReturn.add(new SuggestedArticleGroupWrapper(
                        name,
                        articlesByNames.get(name)
                    ));
                }
            }
        }catch(Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_kb_SuggestedArticlesController.class.getName(),e.getStackTraceString(), contactId));
        }
        return toReturn;
    }

    private static List<String> getGroups(Id contactId){
        List<String> contactGroupsAssignedToContact = new List<String>();
        Contact assignedContact = [
            SELECT
                TB_Alumnus_HE__c,
                TB_Alumnus_PG__c,
                TB_Alumnus_CRS__c,
                TB_Alumnus_PhD__c,
                TB_Ex_Student_HE__c,
                TB_Ex_Student_PhD__c,
                TB_Ex_Student_PG__c,
                TB_Ex_Student_CRS__c,
                TB_Applicant_CRS__c,
                TB_Applicant_HE__c,
                TB_Applicant_PG__c,
                TB_Applicant_PhD__c,
                TB_Student_PG__c,
                TB_Student_HE__c,
                TB_Student_CRS__c,
                TB_Student_PhD__c,
                TB_Didactic_Applicant_HE__c,
                TB_Didactic_Applicant_PG__c,
                TB_Administrative_Employee__c,
                TB_Didactic_Researcher_Employee__c,
                TB_Didactic_Employee_HE__c,
                TB_Didactic_Employee_PG__c,
                TB_Researcher_Employee__c,
                TB_Technical_Employee__c
            FROM Contact
            WHERE Id =: contactId
            LIMIT 1
        ];
        if(assignedContact.TB_Alumnus_HE__c || 
            assignedContact.TB_Ex_Student_HE__c || 
            assignedContact.TB_Student_HE__c)
                contactGroupsAssignedToContact.add(TB_kb_Constants.HIGHER_EDUCATION_CONTACT_GROUP_SUGGESTED_ARTICLE_GROUP);
        if(assignedContact.TB_Alumnus_PG__c || 
            assignedContact.TB_Ex_Student_PG__c || 
            assignedContact.TB_Student_PG__c)
                contactGroupsAssignedToContact.add(TB_kb_Constants.POST_GRADUATE_STUDIES_CONTACT_GROUP_SUGGESTED_ARTICLE_GROUP);
        if(assignedContact.TB_Alumnus_PhD__c || 
            assignedContact.TB_Ex_Student_PhD__c || 
            assignedContact.TB_Student_PhD__c)
                contactGroupsAssignedToContact.add(TB_kb_Constants.DOCTORAL_SCHOOL_CONTACT_GROUP_SUGGESTED_ARTICLE_GROUP);
        if(assignedContact.TB_Didactic_Applicant_HE__c || 
            assignedContact.TB_Didactic_Applicant_PG__c || 
            assignedContact.TB_Administrative_Employee__c || 
            assignedContact.TB_Didactic_Researcher_Employee__c || 
            assignedContact.TB_Didactic_Employee_HE__c || 
            assignedContact.TB_Didactic_Employee_PG__c || 
            assignedContact.TB_Researcher_Employee__c || 
            assignedContact.TB_Technical_Employee__c)
                contactGroupsAssignedToContact.add(TB_kb_Constants.FOR_EMPLOYEES_CONTACT_GROUP_SUGGESTED_ARTICLE_GROUP);
        if(assignedContact.TB_Student_CRS__c || 
            assignedContact.TB_Ex_Student_CRS__c ||
            assignedContact.TB_Alumnus_CRS__c ||
            assignedContact.TB_Applicant_CRS__c ||
            assignedContact.TB_Applicant_HE__c ||
            assignedContact.TB_Applicant_PG__c ||
            assignedContact.TB_Applicant_PhD__c ||
            contactGroupsAssignedToContact.size() == 0)
                contactGroupsAssignedToContact.add(TB_kb_Constants.ABOUT_SWPS_UNIVERSITY_CONTACT_GROUP_SUGGESTED_ARTICLE_GROUP);
        
        return contactGroupsAssignedToContact;
    }

    public class SuggestedArticleWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String knowledgeCategoryId;
        @AuraEnabled public String name;
        
        public SuggestedArticleWrapper (String id, String knowledgeCategoryId, String name) {
            this.id = id;
            this.knowledgeCategoryId = knowledgeCategoryId;
            this.name = name;
        }
    }

    public class SuggestedArticleGroupWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public List<SuggestedArticleWrapper> articles;
        
        public SuggestedArticleGroupWrapper (String name, List<SuggestedArticleWrapper> articles) {
            this.name = name;
            this.articles = articles;
        }
    }
}
global with sharing class TB_pdo_AchievementPopularizationService {

    @InvocableMethod(label='PDO get publisher points' callout=true)
    global static void updateAchievementWithPublisherPoints(List<PublisherAchievementLink> pdoParams) {
        String publisherName = pdoParams.get(0).publisher;
        try {
            String token = TB_pdo_PDORestWebService.getScienceCloudAccessToken();
            if (String.isNotEmpty(token)) {
                Integer points = getPublisherPoints(token, publisherName);
                update new TB_PDO__c(Id= pdoParams.get(0).pdoId, TB_Publisher_Points__c=points);
            }
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }

    private static Integer getPublisherPoints(String token, String publisherName) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        Integer publisherPoints;
        String query = EncodingUtil.urlEncode(publisherName, 'UTF-8');
        req.setEndpoint('callout:TB_Sciencecloud_pdo' +
        '/publishers?on_ministerial_list=true&query=' +
        query);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);
        HttpResponse resp = http.send(req);
        if (resp.getStatusCode() == TB_pdo_Constants.SUCCESS_CODE) {
            Object responseData = JSON.deserializeUntyped(resp.getBody());
            Map<String,Object> publisherData = (Map<String, Object>) responseData;
            List<Object> publishers = (List<Object>) publisherData.get('publishers');
            String name;
            for (Object publisher : publishers) {
                name = (String) ((Map<String,Object>) publisher).get('name');
                if (name.equals(publisherName)) {
                    publisherPoints = (Integer) ((Map<String,Object>) publisher).get('points');
                }
            }         
        }
        return publisherPoints;
    }

    global class PublisherAchievementLink {
        
        @InvocableVariable(required=true)
        global Id pdoId;
        
        @InvocableVariable(required=true)
        global String publisher;
        
    }
}
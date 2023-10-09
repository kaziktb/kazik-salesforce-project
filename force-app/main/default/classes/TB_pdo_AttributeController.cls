public with sharing class TB_pdo_AttributeController {
  @AuraEnabled(Cacheable=true)
  public static List<hed__Attribute__c> getAttributes(
    String recordTypeDevName,
    String discipline,
    String conId
  ) {
    List<hed__Attribute__c> attributes = [
      SELECT Id, Name, TB_Discipline__c, toLabel(TB_Discipline__c) disciplineLabel
      FROM hed__Attribute__c
      WHERE
        hed__Contact__c = :conId
        AND RecordType.DeveloperName = :recordTypeDevName
        AND hed__Attribute_Type__c = :discipline
        AND hed__Start_Date__c < :Date.today()
        AND (hed__End_Date__c > :Date.today()
        OR hed__End_Date__c = NULL)
      ORDER BY TB_Discipline_Order__c ASC
    ];
    return attributes;
  }
}
/**
 * Created by Adam Czeczuk on 15/09/2021.
 * Edited by Dawid Machon on 01/03/2023
 */

 global without sharing class TB_MCClient_v2 {
    
  @InvocableMethod(label='sendToMC_v2')
  public static void createDEEntry(List<WrapperClass> entryList) {
      switch on entryList[0].journey {
          when 'Admissions' {
              TB_MCAdmissions_v2_QueueableBatch batch = new TB_MCAdmissions_v2_QueueableBatch(entryList);
              if(!Test.isRunningTest()) Database.executeBatch(batch);
              }
      }
  }

  global class WrapperClass {
      @InvocableVariable
      global Id recordId;
      @InvocableVariable
      global String eventKey;
      @InvocableVariable
      global String journey;
  }
}
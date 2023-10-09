/**
 * Created by jowitakozlak on 22/06/2021.
 */

global with sharing class TB_SendMultipleMailWrapper {
    @InvocableVariable @AuraEnabled
    global List<TB_SendMailWrapper> sendMailWrappers;
}
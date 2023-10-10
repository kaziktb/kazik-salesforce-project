/**
 * Created by Norbert Rzepa on 09.01.2023.
 */

public with sharing class TB_vu_OperationTriggerHandler extends TB_TriggerHandler
{
    private static final String REG_EXP_ALL_HTML_TAGS = '(<.+?>)';
    private static final String REG_EXP_HTML_TEXT_FORMAT_TAGS = '((<|<\\/)(strong|em|u|strike|a)(( .*?>)|>))';
    private static final String REPLACEMENT_ALL_HTML_TAGS = ' ';
    private static final String REPLACEMENT_HTML_TEXT_FORMAT_TAGS = '';
    
    private List<TB_Operation__c> toProcess = (List<TB_Operation__c>)Trigger.new;
    private Map<Id,TB_Operation__c> oldMap = (Map<Id,TB_Operation__c>)Trigger.oldMap;
    
    public override void beforeInsert()
    {
        updateDescription();
    }
    
    public override void afterInsert()
    {
        saveApplicationPDF();
        shareOperations();
    }

    public override void beforeUpdate()
    {
        updateDescription();
    }
    
    public override void afterUpdate()
    {
        shareOperations();
    }

    private void updateDescription()
    {
        for(TB_Operation__c singleOperation : (List<TB_Operation__c>)Trigger.new)
        {
            if(Trigger.isInsert || (singleOperation.TB_Description_Rich_Text__c != ((TB_Operation__c)Trigger.oldMap.get(singleOperation.Id)).TB_Description_Rich_Text__c))
            {
                if(String.isNotBlank(singleOperation.TB_Description_Rich_Text__c))
                {
                    singleOperation.TB_Description__c = singleOperation.TB_Description_Rich_Text__c.replaceAll(REG_EXP_HTML_TEXT_FORMAT_TAGS, REPLACEMENT_HTML_TEXT_FORMAT_TAGS).replaceAll(REG_EXP_ALL_HTML_TAGS, REPLACEMENT_ALL_HTML_TAGS).normalizeSpace();
                }
                else
                {
                    singleOperation.TB_Description__c = '';
                }
            }
        }
    }
    
    private void saveApplicationPDF()
    {
        List<TB_Operation__c> operationsToProcess = new List<TB_Operation__c>();
        for(TB_Operation__c singleOperation : (List<TB_Operation__c>)Trigger.new)
        {
            if(singleOperation.TB_Initial__c && singleOperation.TB_Case__c != null)
            {
                operationsToProcess.add(singleOperation);
            }
        }
        if(!operationsToProcess.isEmpty())
        {
            TB_vu_ApplicationPreviewController.enqueuePDFGeneration(operationsToProcess);
        }
    }
    
    private void shareOperations()
    {
        Set<Id> caseIdsToShareOperations = new Set<Id>();
        for(TB_Operation__c operation : toProcess)
        {
            if(operation.TB_Case__c != null && (Trigger.isInsert || (Trigger.isUpdate && operation.TB_Decision_Maker__c != oldMap.get(operation.Id).TB_Decision_Maker__c)))
            {
                caseIdsToShareOperations.add(operation.TB_Case__c);
            }
        }
        TB_vu_OperationSharingService.shareOperationsByCaseIds(caseIdsToShareOperations);
    }
}
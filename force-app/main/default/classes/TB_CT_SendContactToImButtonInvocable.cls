public with sharing class TB_CT_SendContactToImButtonInvocable {
    @InvocableMethod(Label = 'TB CT Send Contact to Im')
    public static List<Output> sendtoim(List<Input> ids){
        String output;
        List<Output> outs = new List<Output>();
  
            for (Input inp : ids){
                Output out = new Output();
                out.info = TB_CT_IMIntegration.createOrUpdatePerson(inp.contactId,'PL',false);
                outs.add(out);
            }
  
        return outs;
    }

    public class Input {
        @InvocableVariable(required = true label ='Contact Id')
        public String contactId;
   
    }

    public class Output {
        @InvocableVariable(label='Response' required=false)
        public String info;
    }
}
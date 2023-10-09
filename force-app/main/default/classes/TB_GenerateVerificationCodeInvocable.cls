public without sharing class TB_GenerateVerificationCodeInvocable {

    @InvocableMethod(label='generateCode')
    public static List<Results> generateCode(List<GenerateCodeWrapperClasses> generateCodeWrapperClasses) {
        List<Results> output = new List<Results>();
        try {
            for(GenerateCodeWrapperClasses current : generateCodeWrapperClasses){
                output.add(generate(current));
            }
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_GenerateVerificationCodeInvocable.class);
        }
        return output;
    }

    private static Results generate(GenerateCodeWrapperClasses generateCodeWrapperClasses){
       Final String characters = generateCodeWrapperClasses.isStandard ? TB_Generated_verification__mdt.getInstance('Standard').Values__c : TB_Generated_verification__mdt.getInstance('Custom').Values__c;
        return new Results(
            generateRandomString(generateCodeWrapperClasses.sizeOfGeneratedCode,characters),generateCodeWrapperClasses.id 
            );
    }

    private static String generateRandomString(Integer len, String characters) {
        final String chars = characters;
        String randStr = '';
        while (randStr.length() < len) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public class GenerateCodeWrapperClasses  {
        @InvocableVariable(label='Size of generated Code' required=true)
        public Integer sizeOfGeneratedCode;
        @InvocableVariable(label='IsStandard' required=true)
        public Boolean isStandard;
        @InvocableVariable(label='Id' required=true)
        public String id;
    }   

    public class  Results {
        @InvocableVariable(label='Generated Number' required=true)
        public String generatedNumber;
        @InvocableVariable(label='Id' required=true)
        public String id;

        public Results (String generatedNumber, String id){
            this.generatedNumber = generatedNumber;
            this.id = id;
        }
    }
} 

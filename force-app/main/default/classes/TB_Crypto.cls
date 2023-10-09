public without sharing class TB_Crypto {


    public static String cryptLiteral(String metadataSetting, String literalTocrypt){
        TB_Crypto_setting__mdt setting = TB_Crypto_setting__mdt.getInstance(metadataSetting);
        List<TB_Crypto_Settings_Info__c> settingKey = [SELECT Id,Key_Value__c,Key_Name__c
                                                 FROM TB_Crypto_Settings_Info__c WHERE 
                                                 Key_Name__c = :setting.Key_Pointer__c OR 
                                                 Key_Name__c = :setting.DeveloperName limit 1];
        Blob key;
        if(settingKey.isEmpty()){
             key = Crypto.generateAesKey(Integer.valueOf(setting.Generate_AES_key_size__c));
             TB_Crypto_Settings_Info__c freshkey = new TB_Crypto_Settings_Info__c();
             freshkey.Key_Name__c = setting.DeveloperName;
             freshkey.Key_Value__c = EncodingUtil.base64Encode(key);
             insert freshkey;
        }
        else{
            key = EncodingUtil.base64Decode(settingKey.get(0).Key_Value__c);
        }

        Blob data = Blob.valueOf(literalTocrypt);
        Blob encrypted = Crypto.encryptWithManagedIV(setting.Algorithm_Name__c, key, data);
        return EncodingUtil.base64Encode(encrypted);
    }


    public static String decryptLiteral(String metadataSetting, String literalTodecrypt){
        TB_Crypto_setting__mdt setting = TB_Crypto_setting__mdt.getInstance(metadataSetting);
        List<TB_Crypto_Settings_Info__c> settingKey = [SELECT Id,Key_Value__c,Key_Name__c
                                                 FROM TB_Crypto_Settings_Info__c WHERE 
                                                 Key_Name__c = :setting.Key_Pointer__c OR 
                                                 Key_Name__c = :setting.DeveloperName limit 1];
        Blob key;
          if(settingKey.isEmpty()){
             throw new TB_Crypto_Exception('Missing key for: '+metadataSetting+'.  Generate new key(TB_Crypto_Settings_Info) for this Custom metadate type. ');
            }
             else{
               key = EncodingUtil.base64Decode(settingKey.get(0).Key_Value__c);
             }
            Blob decrypted = Crypto.decryptWithManagedIV(setting.Algorithm_Name__c, key, EncodingUtil.base64Decode(literalTodecrypt));
            return decrypted.toString();                                           
        }


      public class  TB_Crypto_Exception extends Exception{

      }
}

@isTest
public with sharing class TB_Crypto_Test {

    @isTest
    private static void cryptLiteralTest(){
       String output = 'Test Literal';
       String cryptedliteral = TB_Crypto.cryptLiteral('Application_Tracking_Settings', output);
       String decryptedLiteral = TB_Crypto.decryptLiteral('Application_Tracking_Settings', cryptedliteral);
       System.assertEquals(output, decryptedLiteral, 'these values should be equal after decrypt');
    }
        
}

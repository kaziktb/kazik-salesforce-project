public with sharing class DT_FlowGenerateUniqueToken {
    @InvocableMethod(label='Generate Hash')
    public static List<String> generate() {
        List<String> hashedValues = new List<String>();
        String randomNumber = '' + (100000 + Integer.valueOf(Math.random() * 999999));
        String baseToken = '' + System.now().getTime() + randomNumber;

        Blob valueBlob = Blob.valueOf(baseToken);
        Blob md5hash = Crypto.generateDigest('MD5', valueBlob);
        hashedValues.add(EncodingUtil.convertToHex(md5hash));
        System.debug('Tokens: ' + hashedValues);

        return hashedValues;
    }
}
public without sharing class TB_RandomDataUtils {

        public static String generateRandomText(Integer required_length) {
            final String chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz';
            String random_string = '';
            while (random_string.length() < required_length) {
                Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                random_string += chars.substring(index, index + 1);
            }
            return random_string;
        }
    
        public static String generateRandomSpecialCharacters(Integer required_length) {
            final String chars = '!#$%&\'()*+,-./:;<=>?@[\\]^_{}~';
            String random_string = '';
            while (random_string.length() < required_length) {
                Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                random_string += chars.substring(index, index + 1);
            }
            return random_string;
        }

        public static String generateRandomNumber(Integer required_length) {
            String random_number = String.valueOf(Math.abs(Crypto.getRandomLong()));
            return random_number.substring(0, required_length);
        }
    
        public static String generateUUID() {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            return (h.SubString(0,8)+ '' + h.SubString(8,12) + '' + h.SubString(12,16) + '' + h.SubString(16,20) + '' + h.substring(20));
        }
        private static List<Integer> createSetOfNumbers(Integer num){
            List<Integer> output = new List<Integer>();
            Integer max = num - 1;
            for(Integer x = 0 ; x < max ; x ++ ){
                output.add(x);
            }
            return output;
        }

        public static String generatePassword(Integer lengthOfLiteralString, Integer lengthOfNumeralString,Integer numberOfSpecialCharacters){
            String generatedLiteral = generateRandomText(lengthOfLiteralString) 
                                    + generateRandomNumber(lengthOfNumeralString)
                                    + generateRandomSpecialCharacters(numberOfSpecialCharacters);
            List<Integer> numbers_string_index = createSetOfNumbers(lengthOfLiteralString + lengthOfNumeralString + numberOfSpecialCharacters);
            String random_string = '';
            while (!numbers_string_index.isEmpty()) {
                Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), numbers_string_index.size());
                random_string += generatedLiteral.substring(numbers_string_index.get(index), numbers_string_index.get(index) + 1);
                numbers_string_index.remove(index);
            }
            return random_string;
        }
}

public with sharing class TB_PeselUtils {
    public static final Integer NO_OF_DIGITS_IN_PESEL = 11;
    public static final List<Integer> NUMBERS_TO_MULTIPLY = new List<Integer>{1, 3, 7, 9, 1, 3, 7, 9, 1, 3};

    @AuraEnabled
    public static PeselWrapper validatePeselFromParts(String pesel, Integer day, Integer month, Integer year, String salutation) {
        Date birthdate;
        if (year != null && month != null && day != null) {
            birthdate = Date.newInstance(year, month, day);
        }
        return validatePesel(pesel, birthdate, salutation);
    }

    @AuraEnabled
    public static PeselWrapper validatePesel(String pesel, Date birthDate, String salutation) {
        PeselWrapper peselWrapper = new PeselWrapper();
        if (String.isBlank(pesel) || birthDate == null || String.isBlank(salutation)) {
            peselWrapper.reason = 'PESEL.MISSING_PARAMETERS';
        } else if (!pesel.isNumeric()) {
            peselWrapper.reason = 'PESEL.NOT_NUMERIC';
        } else if (pesel.length() != NO_OF_DIGITS_IN_PESEL) {
            peselWrapper.reason = 'PESEL.INVALID_LENGTH';
        } else if (!isValidYear(pesel, birthDate)) {
            peselWrapper.reason = 'PESEL.INVALID_BIRTH_YEAR';
        } else if (!isValidMonth(pesel, birthDate)) {
            peselWrapper.reason = 'PESEL.INVALID_BIRTH_MONTH';
        } else if (!isValidDay(pesel, birthDate)) {
            peselWrapper.reason = 'PESEL.INVALID_BIRTH_DAY';
        } else if (!isValidGender(pesel, salutation)) {
            peselWrapper.reason = 'PESEL.INVALID_GENDER';
        } else if (!isValidControlNumber(pesel)) {
            peselWrapper.reason = 'PESEL.INVALID_CONTROL_NUMBER';
        }

        if (String.isNotBlank(peselWrapper.reason)) {
            peselWrapper.valid = false;
        }
        return peselWrapper;
    }

    private static Boolean isValidYear (String pesel, Date birthdate) {
        String peselYear = pesel.substring(0, 2);
        String expectedBirthYear = String.valueOf( birthdate.year()).substring(2, 4);
        return birthdate.year() > 1899 && peselYear == expectedBirthYear;
    }

    private static Boolean isValidMonth (String pesel, Date birthdate) {
        Integer expectedMonth = birthdate.year() >= 2000 ? birthdate.month() + 20 : birthdate.month();
        Integer peselMonth = Integer.valueOf(pesel.substring(2, 4));
        return expectedMonth == peselMonth;
    }

    private static Boolean isValidDay (String pesel, Date birthdate) {
        Integer expectedDate = Integer.valueOf(birthdate.day());
        Integer peselDate = Integer.valueOf(pesel.substring(4, 6));
        return expectedDate == peselDate;
    }

    private static Boolean isValidGender (String pesel, String salutation) {
        Integer peselGenderDigit = Integer.valueOf(pesel.substring(9, 10));
        Boolean isGenderValid = false;
        if (salutation.toLowerCase().contains('mr')) {
            isGenderValid = Math.mod(peselGenderDigit, 2) != 0;
        } else if (salutation.toLowerCase().contains('ms')) {
            isGenderValid = Math.mod(peselGenderDigit, 2) == 0;
        }
        return isGenderValid;
    }

    private static Boolean isValidControlNumber (String pesel) {
        Integer sum = 0;
        for (Integer i = 0; i < NUMBERS_TO_MULTIPLY.size(); i++) {
            sum += Integer.valueOf(pesel.substring(i, i + 1)) * NUMBERS_TO_MULTIPLY[i];
        }
        Integer controlNumber = 10 - Math.mod(sum, 10);
        if (controlNumber == 10) {
            controlNumber = 0;
        }
        return controlNumber == Integer.valueOf(pesel.substring(10, 11));
    }

    public class PeselWrapper {
        @AuraEnabled public Boolean valid;
        @AuraEnabled public String reason;

        public PeselWrapper() {
            valid = true;
            reason = '';
        }
    }
}
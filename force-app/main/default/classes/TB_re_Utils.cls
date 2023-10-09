/**
 * Created by jakubWrzodek on 12/01/23.
 */
public with sharing class TB_re_Utils {
    public class IncompleteDataCustomException extends Exception {}

    public static Id getRecordTypeId(
        String recordTypeName, 
        String sObjectTypeName
    ) {
        Id recordTypeId = getSObjectDescribe(sObjectTypeName).getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        return recordTypeId;
    }

    public static Boolean isObjectOfRecordType(
        SObject obj, 
        String recordTypeName, 
        String sObjectTypeName, 
        Boolean withFieldChecking
    ) {
        if (withFieldChecking && obj.get('recordTypeID') == null) {
            throw new IncompleteDataCustomException();
        }
        Id recordTypeId = getRecordTypeId(recordTypeName, sObjectTypeName);
        return obj.get('recordTypeID') == recordTypeId;
    }


    private static Schema.DescribeSObjectResult getSObjectDescribe(String sObjectType) {
        switch on sObjectType {
            when 'Contact' {
                return Schema.SObjectType.Contact;
            }	
            when 'User' {
                return Schema.SObjectType.User;
            }
            when else {
                return null;
            }
        }
    }

    public static Boolean isObjectOfRecordType(SObject obj, String recordTypeName, String sObjectTypeName) {
        return isObjectOfRecordType(obj, recordTypeName, sObjectTypeName, false);
    }

    public static Boolean isStudentContact(Contact contact) {
        return isObjectOfRecordType(contact, TB_re_Constants.CONTACT_STUDENT_RT, 'Contact');
    }

    public static Id getContactRecordTypeId(String recordTypeName) {
        return getRecordTypeId(recordTypeName, 'Contact');
    }

    public static List<Object> slice(List<Object> input, Integer startIndex, Integer endIndex)
    {
        List<Object> output = input.clone();
        for (Integer i = 0; i < startIndex; i++) {
            output.remove(0);
        }
        Integer elements = endIndex - startIndex;
        while (output.size() > elements) {
            output.remove(elements);
        }
        return output;
    }
}
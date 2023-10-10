/**
 * Created by jowitakozlak on 29/09/2021.
 */

public without sharing class TB_StringUtils {

    public static String stripPolishAccents(String textToNormalize){
        List<String> lettersToNormalize = textToNormalize.split('');
        String normalizedText = '';
        Map<String, String> polishToEnglishDictionary = new Map<String, String>{
            'Ą' => 'A', 'Ć' => 'C', 'Ę' => 'E', 'Ł' => 'L', 'Ń' => 'N', 'Ó' => 'O', 'Ś' => 'S', 'Ź' => 'Z', 'Ż' => 'Z',
            'ą' => 'a', 'ć' => 'c', 'ę' => 'e', 'ł' => 'l', 'ń' => 'n', 'ó' => 'o', 'ś' => 's', 'ź' => 'z', 'ż' => 'z'
        };

        for(String letterToNormalize : lettersToNormalize){
            String normalizedLetter = polishToEnglishDictionary.get(letterToNormalize);
            if(normalizedLetter != null){
                normalizedText += normalizedLetter;
            } else {
                normalizedText += letterToNormalize;
            }
        }
        return normalizedText;
    }

    public static Map<String, String> getMapFromPicklist(String objectAPIName, String fieldAPIName) {
        Map<String, String> valueToLabel = new Map<String, String>{};

        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>{objectAPIName});
        for (Schema.DescribeSobjectResult result : results) {
            for (Schema.PicklistEntry entry : result.fields.getMap().get(fieldAPIName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {valueToLabel.put(entry.getValue(), entry.getLabel());}
            }
        }

        return valueToLabel;
    }

    public static List<String> getPicklistValuesOrLabelsSortedByLabel(String objectAPIName, String fieldAPIName, String elementType) {
        List<String> values = new List<String>();
        List<String> labels = new List<String>();

        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>{objectAPIName});
        for (Schema.DescribeSobjectResult result : results) {
            for (Schema.PicklistEntry entry : result.fields.getMap().get(fieldAPIName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.add(entry.getValue());
                    labels.add(entry.getLabel());
                }
            }
        }

        for (Integer i = 1; i < labels.size(); i++) {
            String key = labels[i];
            String value = values[i];
            Integer j = i - 1;

            while (j >= 0 && labels[j] > key) {
                labels[j + 1] = labels[j];
                values[j+1] = values[j];
                j = j - 1;
            }
            labels[j + 1] = key;
            values[j + 1] = value;
        }

        if (elementType == 'values') {
            return values;
        } else {
            return labels;
        }
    }

    public static List<List<String>> getPolandOnTop(List<List<String>> valuesAndLabels) {

        List<String> newValues = new List<String>();
        List<String> newLabels = new List<String>();
        Integer indexToRemove = -1;
        indexToRemove = valuesAndLabels[0].indexOf('PL');
        if (indexToRemove < 0) {
            indexToRemove = valuesAndLabels[0].indexOf('+48_PL');
        }
        if (indexToRemove < 0) {
            indexToRemove = valuesAndLabels[0].indexOf('Poland');
        }
        if (indexToRemove >= 0) {
            newValues.add(valuesAndLabels[0].remove(indexToRemove));
            newLabels.add(valuesAndLabels[1].remove(indexToRemove));
        }
        List<List<String>> finalList = new List<List<String>>();
        newValues.addAll(valuesAndLabels[0]);
        finalList.add(newValues);
        newLabels.addAll(valuesAndLabels[1]);
        finalList.add(newLabels);

        return finalList;
    }

    @AuraEnabled
    public static String getPicklistByApiName(String objectApiName, String fieldApiName) {
        return JSON.serialize(getPicklistWrapperByApiName(objectApiName, fieldApiName));
    }

    public static PicklistWrapper getPicklistWrapperByApiName(String objectApiName, String fieldApiName) {
        List<String> labels = getPicklistValuesOrLabelsSortedByLabel(objectApiName, fieldApiName, 'labels');
        List<String> values = getPicklistValuesOrLabelsSortedByLabel(objectApiName, fieldApiName, 'values');
        List<List<String>> valuesAndLabelsPrioritized = getPolandOnTop(new List<List<String>>{values,labels});
        return new PicklistWrapper(valuesAndLabelsPrioritized);
    }

    public class PicklistWrapper {
        @AuraEnabled public List<String> choicesValues { get; set; }
        @AuraEnabled public List<String> choicesLabels { get; set; }

        public PicklistWrapper(List<List<String>> valuesAndLabelsPrioritized) {

            this.choicesValues = valuesAndLabelsPrioritized[0];
            this.choicesLabels = valuesAndLabelsPrioritized[1];
        }
    }

    //_re_?
    @AuraEnabled
    public static String getDependantPicklistByApiName(String objectApiName, String fieldApiName, String controllingValue) {
        List<String> labels = getPicklistValuesOrLabelsSortedByLabel(objectApiName, fieldApiName, 'labels');
        List<String> values = getPicklistValuesOrLabelsSortedByLabel(objectApiName, fieldApiName, 'values');
        List<List<String>> valuesAndLabelsPrioritized = getPolandOnTop(new List<List<String>>{values,labels});
        List<String> dependantValues = getDependentPicklistValues(objectApiName, fieldApiName, controllingValue);
        List<List<String>> dependantValuesAndLabelsPrioritized = new List<List<String>>{new List<String>(), new List<String>()};
        Integer i = 0;
        for (String value : valuesAndLabelsPrioritized[0]) {
            for (String dependantValue : dependantValues) {
                if (value == dependantValue) {
                    dependantValuesAndLabelsPrioritized[0].add(dependantValue);
                    dependantValuesAndLabelsPrioritized[1].add(valuesAndLabelsPrioritized[1][i]);
                }
            }
            i++;
        }
        PicklistWrapper picklistWrapper = new PicklistWrapper(dependantValuesAndLabelsPrioritized);
        return JSON.serialize(picklistWrapper);
    }

    public static List<String> getDependentPicklistValues(String objectApiName, String fieldApiName, String controllingValue) {
        Schema.SObjectField dependToken = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName);
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.SObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new List<String>();
        }

        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if (control.getType() != Schema.DisplayType.BOOLEAN) {
            controlEntries = control.getPicklistValues();
        }

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                        (controlEntries == null
                            ?   (Object) (index == 1)
                            :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
                        );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0) {
                        continue;
                    }
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getValue());
                }
            }
        }
        return dependentPicklistValues.get(controllingValue);
    }

}
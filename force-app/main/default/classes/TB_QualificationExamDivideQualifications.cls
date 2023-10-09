/**
 * Created by annaseveryna on 03/03/2022.
 */

public with sharing class TB_QualificationExamDivideQualifications {

    @InvocableMethod(Label='divideQualifications')
    public static List<FlowOutput> divideQualifications(List<TB_QualificationExamProtocolWrapper> wrappers) {
        List<FlowOutput> flowInputs = new List<FlowOutput>();
        for (TB_QualificationExamProtocolWrapper wrapper : wrappers) {
            FlowOutput input = new FlowOutput();
            Integer qualificationsSize = wrapper.qualifications.size();
            Integer counter = 1;
            for (Integer i = 0; i < qualificationsSize; i += TB_QualificationExamGeneratePdf.FILES_IN_PACKAGE_LIMIT) {
                input.qualificationIndexesToBeginWith.add(i);
                input.counters.add(counter);
                counter++;
            }
            input.numberOfPackages = input.qualificationIndexesToBeginWith.size();
            input.numberOfQualifications = wrapper.qualifications.size();
            input.filesInPackageLimit = TB_QualificationExamGeneratePdf.FILES_IN_PACKAGE_LIMIT;
            flowInputs.add(input);
        }
        return flowInputs;
    }

    public class FlowOutput {
        @InvocableVariable
        public List<Integer> qualificationIndexesToBeginWith = new List<Integer>();

        @InvocableVariable
        public List<Integer> counters = new List<Integer>();

        @InvocableVariable
        public Integer numberOfPackages;

        @InvocableVariable
        public Integer numberOfQualifications;

        @InvocableVariable
        public Integer filesInPackageLimit;
    }
}
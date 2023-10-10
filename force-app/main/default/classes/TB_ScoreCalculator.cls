public without sharing class TB_ScoreCalculator {
    @InvocableMethod(label='Computer Science High School Exam Scores')
    public static List<Decimal> calculateScores(List<String> applicationIds) {
        List<Decimal> calculatedScores = new List<Decimal>();
        try {
            Decimal math, ict, english;

            Map<ID, TB_Admissions_Dictionary__c> subjects = new Map<ID, TB_Admissions_Dictionary__c>([
                SELECT Id, Name
                FROM TB_Admissions_Dictionary__c
                WHERE Name IN ('informatyka', 'matematyka', 'język angielski')
            ]);
            List<TB_Experience_History__c> examsData = [
                SELECT Id, TB_Evaluation_Points__c, TB_HS_Exam_Subject__c
                FROM TB_Experience_History__c
                WHERE TB_Application__c = :applicationIds[0]
                AND TB_HS_Exam_Subject__c IN :subjects.keySet()
                AND TB_Active__c = TRUE
            ];
            Map<String, Decimal> examScores = new Map<String, Decimal>();
            for (TB_Experience_History__c examData : examsData) {
                examScores.put(subjects.get(examData.TB_HS_Exam_Subject__c).Name, examData.TB_Evaluation_Points__c);
            }

            if (examScores.containsKey('matematyka')) {
                math = examScores.get('matematyka');
            } else {
                math = 0.0;
            }
            if (examScores.containsKey('informatyka')) {
                ict = examScores.get('informatyka');
            } else {
                ict = 0.0;
            }
            if (examScores.containsKey('język angielski')) {
                english = examScores.get('język angielski');
            } else {
                english = 0.0;
            }

            if (math >= 40) {
                calculatedScores.add((math * 2.0) + ict + (english / 2.0));
            } else {
                calculatedScores.add(-1);
            }
        } catch (Exception e) {
            TB_LogUtils.registerLogFuture(
                e.getMessage(),
                TB_ScoreCalculator.class.getName()
            );
        }
        return calculatedScores;
    }
}
public with sharing class DT_InternshipApplicationHelper {
    public static void recalculateInternshipVacancies(List<DT_Internship_Application__c> newApps, Map<Id, DT_Internship_Application__c> id2OldApp) {
        Set<Id> internshipOfferIdsToRecalculate = new Set<Id>();

        for (DT_Internship_Application__c newApp : newApps) {
            if (newApp.DT_Internship__c != null
                && newApp.DT_Status__c == DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED
                && DT_Utils.isFieldChanged(id2OldApp.get(newApp.Id), newApp, DT_Internship_Application__c.DT_Status__c.getDescribe().name)
            ) {
                internshipOfferIdsToRecalculate.add(newApp.DT_Internship__c);
            }
        }

        updateVacancies(internshipOfferIdsToRecalculate);
    }

    public static void recalculateInternshipVacancies(List<DT_Internship_Application__c> oldApps) {
        Set<Id> internshipOfferIdsToRecalculate = new Set<Id>();

        for (DT_Internship_Application__c oldApp : oldApps) {
            if (oldApp.DT_Internship__c != null
                    && oldApp.DT_Status__c == DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED
            ) {
                internshipOfferIdsToRecalculate.add(oldApp.DT_Internship__c);
            }
        }

        updateVacancies(internshipOfferIdsToRecalculate);
    }

    private static void updateVacancies(Set<Id> internshipOfferIds) {
        List<DT_Internship__c> internshipOffersToRecalculateVacancies = [
                SELECT DT_Internships_Number__c,
                (SELECT Id FROM Internship_Applications__r WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED)
                FROM DT_Internship__c
                WHERE Id IN :internshipOfferIds
                AND DT_Internships_Number__c != NULL
        ];

        for (DT_Internship__c internshipOffer : internshipOffersToRecalculateVacancies) {
            internshipOffer.Vacancies__c = internshipOffer.DT_Internships_Number__c - internshipOffer.Internship_Applications__r.size();
        }

        update internshipOffersToRecalculateVacancies;
    }
}
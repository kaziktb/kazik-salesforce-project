/**
 * Created by adriangawryszewski on 12/16/21.
 */

public with sharing class TB_SWPSProxyModel {

    //Main Export class
    public class VDOExport {
        public String eventId;
        public String photo;
        public String photoName;
        public String candidateId;//
        public String applicationId;//
        public String applicationNumber;//
        public String IMId;//
        public Decimal globalId;
        public String VDOId;//
        public String contractorId;//
        public Integer processRecruitmentId;//
        public Integer specializationId;//
        public String firstName;//
        public String lastName;//
        public String secondName;//
        public String gender;//
        public String motherName;//
        public String fatherName;//
        public Date birthdate;//
        public String birthPlace;//
        public String countryOrigin;//
        public String citizenship;//
        public String familyName;//
        public String PESEL;//
        public String installmentSystem;//
        public String paymentCurrency;//
        public Datetime dateAdmission;//
        public Datetime dateRegistration;//
        public String subAccountPLN;//
        public String subAccountEUR;//
        public String emailStudent;//
        public String emailWorker;//
        public String emailPrivate;//
        public String preferredEmail;
        public String phonePrivate;//
        public String semesterName;//
        public Integer semester;//
        public String ICEPerson;//
        public String ICEPhone;//
        public String decisionBasis;//
        public String cityOrVillage;//
        public Date medicalExamination;
        public Identification identification;
        public Boolean polishCard;//
        public AddressCorrespondences addressCorrespondences;
        public AddressResidences addressResidences;
        public SchoolHigh schoolHigh;
        public List<schoolCollege> schoolCollege;
        public List<DifferencesProgram> differencesProgram;
        public Conditional conditional;
        public EnglishTest englishTest;
        public List<MarketingConsents> marketingConsents;
        public PhdSupervisor phdSupervisor;
        public Discount discount;
        public StudyAgreement studyAgreement;
        public String studyLevel;

    }

    public class Identification {
        Date releaseDate;
        String countryIssuance;
        String numberDocument;
        String issuingAuthority;
        Date termValidity;
        String typeDokument;

        public Identification(Date releaseDate, String countryIssuance, String numberDocument, String issuingAuthority,
                Date termValidity, String typeDokument) {
            this.releaseDate = releaseDate;
            this.countryIssuance = countryIssuance;
            this.numberDocument = numberDocument;
            this.issuingAuthority = issuingAuthority;
            this.termValidity = termValidity;
            this.typeDokument = typeDokument;
        }
    }

    public class AddressCorrespondences {
        String city;
        String state;
        String country;
        String postalCode;
        String street;

        public AddressCorrespondences(String city, String state, String country, String postalCode, String street) {
            this.city = city;
            this.state = state;
            this.country = country;
            this.postalCode = postalCode;
            this.street = street;
        }
    }

    public class AddressResidences {
        String city;
        String state;
        String country;
        String postalCode;
        String street;

        public AddressResidences(String city, String state, String country, String postalCode, String street) {
            this.city = city;
            this.state = state;
            this.country = country;
            this.postalCode = postalCode;
            this.street = street;
        }
    }

    public class SchoolHigh {
        String name;
        Date dataIssueCertificate;
        String placeCertificate;
        String numberCertificate;
        String regionalCommitteExamination;
        String city;
        String country;
        String typeCertificate;
        String internationalBaccalaureateCountry;

        public SchoolHigh(String name, Date dataIssueCertificate, String placeCertyficate, String numberCertificate,
                String regionalCommitteExamination, String city, String country, String typeCertificate, String internationalBaccalaureateCountry) {
            this.name = name;
            this.dataIssueCertificate = dataIssueCertificate;
            this.placeCertificate = placeCertyficate;
            this.numberCertificate = numberCertificate;
            this.regionalCommitteExamination = regionalCommitteExamination;
            this.city = city;
            this.country = country;
            this.typeCertificate = typeCertificate;
            this.internationalBaccalaureateCountry  = internationalBaccalaureateCountry;
        }
    }

    public class SchoolCollege {
        String name;
        String city;
        String nameDirection;
        String numberDiploma;
        Date dateDiploma;
        Date dateEndStudy;
        String professionalTitle;
        String country;

        public SchoolCollege(String name, String city, String nameDirection, String numberDiploma, Date dateDiploma,
                Date dateEndStudy, String profesionalTitle, String country) {
            this.name = name;
            this.city = city;
            this.nameDirection = nameDirection;
            this.numberDiploma = numberDiploma;
            this.dateDiploma = dateDiploma;
            this.dateEndStudy = dateEndStudy;
            this.professionalTitle = profesionalTitle;
            this.country = country;
        }
    }

    public class DifferencesProgram {
        String nameSubject;
        String nameSubjectSWPS;
        Integer hours;
        Integer ects;
        Integer yearExam;
        String rating;
        String nameUniversity;

        public DifferencesProgram(String nameSubject, String nameSubjectSWPS,
                Integer hours, Integer ECTS, Integer yearExam, String rating, String nameUniversity) {
            this.nameSubject = nameSubject;//TB_EXP_PD_Subject__c
            this.nameSubjectSWPS = nameSubjectSWPS;//TB_EXP_PD_Module_Name_PL__c
            this.hours = hours;
            this.ects = ECTS;
            this.yearExam = yearExam;
            this.rating = rating;
            this.nameUniversity = nameUniversity;
        }
    }

    public class Conditional {
        Boolean conditionalDecision;
        Boolean conditionalRecruitment;

        public Conditional(Boolean conditionalDecision, Boolean conditionalRecruitment) {
            this.conditionalDecision = conditionalDecision;
            this.conditionalRecruitment = conditionalRecruitment; 
        }
    }

    public class EnglishTest {
        Decimal points;
        String level;
        String profile;

        public EnglishTest(Decimal points, String level, String profile) {
            this.points = points;
            this.level = level;
            this.profile = profile;
        }
    }

    public class MarketingConsents {
        String consent;
        String value;
        String id;
        Date createDate;
        String consentPL;
        String consentEN;

        public MarketingConsents(String consent, String value, String id,
                Date createdDate, String consentPL, String consentEN) {
            this.consent = consent;
            this.value = value;
            this.id = id;
            this.createDate = createdDate;
            this.consentPL = consentPL;
            this.consentEN = consentEN;
        }
    }

    public class PhdSupervisor {
        String firstName;
        String lastName;
        String title;

        public PhdSupervisor(String firstName, String lastName, String title) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.title = title;
        }
    }

    public class Discount {
        String name;
        String type;
        String calculationType;
        String direction;
        Decimal amount;
        Decimal percentage;

        public Discount(String name, String type, String calculationType, String direction, Decimal amount, Decimal percentage) {
            this.name = name;
            this.type = type;
            this.calculationType = calculationType;
            this.direction = direction;
            this.amount = amount;
            this.percentage = percentage;
        }
    }
    public class StudyAgreement {
        String academicYear;
        String agreementType;
        Date agreementDate;
        String documentName;
        String file;

        public StudyAgreement(String academicYear, String agreementType, Date agreementDate, String documentName, String fileUUID) {
            this.academicYear = academicYear;
            this.agreementType = agreementType;
            this.agreementDate = agreementDate;
            this.documentName = documentName;
            this.file = fileUUID;
        }
    }

}

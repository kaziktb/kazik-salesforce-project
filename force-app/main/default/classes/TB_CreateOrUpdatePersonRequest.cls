public class TB_CreateOrUpdatePersonRequest {

   public String PersonId;
   public Integer ImPersonId;

   public String PESEL;
   public String Firstname;
   public String Lastname;
   public String OtherNames;
   public String Title;
   public Integer Gender;
   public String BirthDate;
   public String Citizenship;
   public String PrivateEmail;
   public String Telephone;

   public IdentityDocument IdentityDocument;
   public Role Role;

   public TB_CreateOrUpdatePersonRequest(){
        this.IdentityDocument = new IdentityDocument();
        this.Role = new Role();
   }

   public class IdentityDocument {
       public Integer DocumentType;
       public String Number0;
       public String Country;
   }

   public class Role {
       public String RoleId;
       public String RoleType;
       public String Location;
       public String Department;
       public String Position;
       public String EmploymentType;
       public String EmploymentCategory;
       public String EmploymentFrom;
       public String EmploymentTo;
   }
}

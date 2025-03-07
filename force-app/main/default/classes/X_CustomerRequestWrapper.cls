//UPDATE : non-mandatory fields commented by Pulkit
public class X_CustomerRequestWrapper {
	
    public class X_ApplicantDetailsJson {
        
        public Decimal EntityRoleID; //M
        public Integer Type; //M
        public String Code; //M
        public X_EntityName EntityName =new X_EntityName(); 
        public String TradingAs;//MN
        public X_EntityScope EntityScope = new X_EntityScope();
        public String PrimaryEntity;
        public X_EntityAddress EntityAddress = new X_EntityAddress();
        public String Telephone_1;
        public String Telephone_2;
        public String Fax;
        public String Mobile;
        public String Email;
        public String CurrencyCode;//M
        public Integer Status;//M
        public String DUNS;
        public String IndustryRefNumber;
        public String URL;
        public Integer FinancialLimit;
        public Integer BlockForPayment;
        public Integer RetentionPercent;
        public Integer DiscountPercent;
        public X_VAT VAT = new X_VAT();
    }
    public class X_EntityName {
        public String Title;
        public String FirstName;
        public String MiddleName;
        public String LastName;//M
        public String DisplayName;
    }
    public class X_EntityAddress {
        public Integer AddressId;//M
        public String AddressLine1;//M
        public String AddressLine2;
        public String AddressLine3;
        public String City;//MN
        public String CountryCode;//M
        public String StateCode;//M
        public String PostCode;//M
    }
    public class X_VAT {
        public String MemberState;//M
        public String VATType;//MN
        public String VATCode;//M
        public String VATRegistrationNo;//MN
    }
    public class X_EntityScope {
        public Integer ScopeDescriptor; //M
        public Object CompanyCode; 
        public Object SharedMasterGroupCode;
    } 
}
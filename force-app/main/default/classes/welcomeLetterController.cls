public class welcomeLetterController {
   
    public String bookId;
    public String applicantName {get; set;}
    public String applicantAddress {get; set;}
    public String applicantMobileNumber {get; set;}
    public String applicantEmail{get; set;}
    
    public Booking__c Customer {get; set;}
    public Date todayDate {get;set;}
    public Integer purchaseValue {get;set;}
    public Integer dldfeeswithoutfee {get;set;}
    public Integer total  {get;set;}
    
    public welcomeLetterController(){
        	todayDate = System.Today();
             if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '')
             bookId = ApexPages.currentPage().getParameters().get('id');
             if(bookId != null && bookId != ''){   
             Customer = [SELECT id, Name, Tower_Name__c,Unit__r.Name,Unit__r.Project__r.Name, Unit__r.Tower__r.Cluster__r.Name, Primary_Applicant_Name__c,Primary_Applicant_Email__c, PrimaryMobileNumber__c,                                                   
                        Agreement_Value__c,Registration_Amount_Paid__c, Primary_Applicant_Address__c,Project__r.Name, DLD_Fees__c  FROM Booking__c WHERE id = :bookId];  
              	 Decimal roundedDLD = Math.ceil(Customer.DLD_Fees__c);
                 dldfeeswithoutfee=Integer.ValueOf(roundedDLD)-1150;
                 purchaseValue = Math.round(Customer.Agreement_Value__c);
                 purchaseValue = Math.ceil(Customer.Agreement_Value__c).intValue();
                 total= Integer.ValueOf(Math.ceil(Customer.DLD_Fees__c));
             }
         // Retrieve the custom parameters
        applicantName = ApexPages.currentPage().getParameters().get('applicantName');
        applicantAddress = ApexPages.currentPage().getParameters().get('applicantAddress');
        applicantMobileNumber = ApexPages.currentPage().getParameters().get('applicantMobileNumber');
        applicantEmail = ApexPages.currentPage().getParameters().get('applicantEmail');
    }
}
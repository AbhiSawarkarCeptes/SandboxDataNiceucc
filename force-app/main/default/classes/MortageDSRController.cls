public class MortageDSRController {
    public Date demandDate{get; set;}
    public Booking__c booking{get; set;}
    public Mortgage__c mortgage{get; set;}
    public Id bookingId;
    public Id mortgageId;
    public Boolean mortgageContractApproved{get; set;}
    public Boolean customerDSRApproved{get; set;}
    public Set<string> towerexception = new Set<string>();
    public String chequeAmount{get; set;}
    public MortageDSRController(){
   
        bookingId = (Id) ApexPages.currentPage().getParameters().get('bookingId');
        mortgageId = (Id) ApexPages.currentPage().getParameters().get('mortgageId');
        //bookingId = 'a062o00002EBiRxAAL';
        //mortgageId = 'a255t000000GJNFAA4';
        demandDate = System.today();
        booking = [SELECT Id,Primary_Applicant_Name__c,Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Other_Applicants_Email__c,Opportunity__r.Primary_Email__c,
                            Opportunity__r.Permanent_Address__c,Primary_Applicant_Email__c, PrimaryMobileNumber__c,Unit__r.name,Unit__r.Tower__r.Name,PCC_Approved_By_Audit__c,Unit__r.Tower__r.RDS_Company_Code__r.Name,Unit__r.Tower__r.RDS_Company_Code__r.Account_Number_Flat_Cost__c,Unit__r.Tower__r.RDS_Company_Code__r.MICR_Code_Flat_Cost__c,Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c,Unit__r.Tower__r.RDS_Company_Code__r.Favouring__c,Unit__r.Tower__r.RDS_Company_Code__r.IBAN__c,Unit__r.Tower__r.Address__c, Unit__r.Project__r.Name, Unit__r.Chargeable_Area__c,
                            Booking_Date__c,Total_On_Account_Money_With_Registration__c, Agreement_Value__c,Purchase_Price_Only__c,Unit__r.Project__r.Address__c,SPA_Executed_Date__c,Tax_on_Purchase_Price__c,SPA_Issue_Date__c,Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c ,TotalAmountPaid__c,Paid_Percentage__c,Date_of_Signing_by_Sobha_Signatory__c
                            FROM Booking__c where   Id = :bookingId];
                                    
        mortgage = [Select Id,Status__c, Audit_Approved_Documents__c, Bank_Name__c , Cheque_Amount__c   From Mortgage__c where Id =:mortgageId];
        if (mortgage.Audit_Approved_Documents__c != null && mortgage.Audit_Approved_Documents__c != '') {
            List<String> approvedDocuments = mortgage.Audit_Approved_Documents__c.split(';');
            if (approvedDocuments != null && approvedDocuments.contains('Mortgage Contract Cheque')) {
                mortgageContractApproved = true;
            } else {
                mortgageContractApproved = false;
            }
            if (approvedDocuments != null && approvedDocuments.contains('Customer Signed DSR')) {
                customerDSRApproved = true;
            } else {
                customerDSRApproved = false;
            }
        } else {
            mortgageContractApproved = false;
            customerDSRApproved = false;
        }
        if (mortgage.Cheque_Amount__c != null) {
        	chequeAmount = mortgage.Cheque_Amount__c.format();
        }
        
    }
}
public class PCC {
    public Date demandDate{get; set;}
    public Booking__c booking{get; set;} 
    public Date topDate{get; set;} 
    public Decimal result{get; set;} 
    public List<ProcessInstance> PList{get; set;} 
    public Id bookingId ;
    public String currencyInWord {get;set;}
    public Set<string> towerexception = new Set<string>();
    public PCC(){
        bookingId = (Id) ApexPages.currentPage().getParameters().get('bookingId');
        demandDate = System.today();
        booking = [SELECT Id,Primary_Applicant_Name__c,Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Other_Applicants_Email__c,Opportunity__r.Primary_Email__c,
                            Opportunity__r.Permanent_Address__c,Primary_Applicant_Email__c, PrimaryMobileNumber__c,Unit__r.Name,Unit__r.Project_Property_Type__c,Unit__r.Tower__r.Name,PCC_Approved_By_Audit__c,Unit__r.Tower__r.RDS_Company_Code__r.Name,Unit__r.Tower__r.RDS_Company_Code__r.Account_Number_Flat_Cost__c,Unit__r.Tower__r.RDS_Company_Code__r.MICR_Code_Flat_Cost__c,Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c,Unit__r.Tower__r.RDS_Company_Code__r.Favouring__c,Unit__r.Tower__r.RDS_Company_Code__r.IBAN__c,Unit__r.Tower__r.Address__c, Unit__r.Project__r.Name, Unit__r.Chargeable_Area__c,
                            Booking_Date__c,Total_On_Account_Money_With_Registration__c, Agreement_Value__c,Purchase_Price_Only__c,Unit__r.Project__r.Address__c,SPA_Executed_Date__c,Tax_on_Purchase_Price__c,SPA_Issue_Date__c,Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c ,TotalAmountPaid__c,Paid_Percentage__c,Date_of_Signing_by_Sobha_Signatory__c
                            FROM Booking__c WHERE Id = :bookingId];

        PList = [ SELECT CompletedDate,CreatedById,CreatedDate,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,Id,IsDeleted,LastActorId,LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById,SystemModstamp,TargetObjectId FROM ProcessInstance WHERE TargetObjectId =:bookingId  ORDER BY CreatedDate DESC LIMIT 1 ];
        if(PList.size() > 0){
            topDate = date.newinstance(PList[0].LastModifiedDate.year(), PList[0].LastModifiedDate.month(), PList[0].LastModifiedDate.day());
        }
        result = booking.Agreement_Value__c.setScale(2);
        // currencyInWord = S_NumberToWord.convertNumbertoWords(result).remove('Rupees ');
        S_NumberToWord S_N = new S_NumberToWord();
        currencyInWord = S_NumberToWord.CurrencyToWordsFormatAED(result);
    }

}
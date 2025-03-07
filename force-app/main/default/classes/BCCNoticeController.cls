public class BCCNoticeController {
	public Id bookingId;
    public Booking__c b {get;set;}
    public string todaysDate {get;set;}
    
    public BCCNoticeController(){
        Date dToday = Date.today();
        todaysDate = Date.today().format();
        if(ApexPages.currentPage().getParameters().get('id') != null){
            bookingId = ApexPages.currentPage().getParameters().get('id');
        }
        if(bookingId != null){
            b = [select Id, Name, Unit__r.Name, Unit__r.Tower__r.Name, Unit__r.Tower__r.Cluster__r.Name,Unit__r.Project__r.Name, Discount_Offered__c,
                 Booking_Date__c, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Primary_Applicant_Address__c, Total_Balance_Amount_To_Be_Paid_On_Date__c, 
                 PrimaryMobileNumber__c, Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Other_Applicants_Email__c, Net_Amount_To_Be_Paid_After_Discount__c, 
                 Opportunity__r.Other_Applicant_Mobile_Number__c, Signed_Date__c, Total_On_Account_Money_With_Registration__c,
                 As_On_Date_Due_Amount__c, Milestone_Due_Date__c, Milestone_Due_Till_Date__c
                 from Booking__c where Id =: bookingId];
        }
    }
}
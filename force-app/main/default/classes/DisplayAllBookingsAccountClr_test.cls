@isTest
public class DisplayAllBookingsAccountClr_test {
    
    @testSetup
    static void setupTestData() {
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Unique_Customer_External_ID__c='1015001';
        insert acc;
        
        Applicant_Details__c ad= new Applicant_Details__c();
        ad.Name='Test applicant name';
        ad.Account__c=acc.Id;
        ad.Applicant_Number__c='Primary Applicant';
        insert ad;
        
        Opportunity opp = new  Opportunity();
        opp.Name='Test Opp';
        opp.CloseDate=Date.today();
        opp.StageName='StageName';
        insert opp;
        
        Payment_Plan__c pp1= new Payment_Plan__c();
        pp1.Name='Test payment plan';
        pp1.NoofMilestones__c=3;
        insert pp1;
        
        Quotation__c quot=new Quotation__c();
        quot.Opportunity__c=opp.Id;
        quot.Payment_Plan__c=pp1.Id;
        insert quot;
        
        Booking__c book= new   Booking__c();
        book.Quotation__c=quot.Id;
        book.Booking_Date__c=Date.today();
        book.Opportunity__c=opp.Id;
        insert book;
        
    }
    
    
    @isTest
    static void getApplicantDetails_test() {
        Account acc= [SELECT Id FROM Account LIMIT 1];
        DisplayAllBookingsOnAccountController.getApplicantDetails(acc.Id);
    }
    
    
    @isTest
    static void baseURL_test() {
         DisplayAllBookingsOnAccountController.baseURL();
    }
    
}
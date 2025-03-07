public class AccountUpdateChildUniqueId {
    
    @future
    public static void updateUniqueId(Set<Id> accountIds,Boolean isFromMerge) {
        
        System.debug('in queueable class udpating unique id');
        // Opportunity update
        updateOpportunityUniqueId(accountIds);
        
        //Booking Update
        updateBookingUniqueId(accountIds);
        
        //Booking Applicant
        updateApplicantUniqueId(accountIds, isFromMerge);
        
    }
    
    
    public static void updateOpportunityUniqueId(Set<Id> accountIds) {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        
        for(Opportunity oppRec : [SELECT Id,
                                  Unique_Customer_ID__c,
                                  Account.Unique_Customer_ID__c 
                                  FROM OPPORTUNITY 
                                  WHERE ACCOUNTID IN : accountIds]) {
                                      
                                      oppRec.Unique_Customer_ID__c =     oppRec.Account.Unique_Customer_ID__c;          
                                      lstOpportunity.add(oppRec);
                                  }
        
        if(lstOpportunity.size() > 0) {
            update lstOpportunity;
        }
    }
    
    public static void updateBookingUniqueId(Set<Id> accountIds) {
        List<Booking__c> lstBooking = new List<Booking__c>();
        
        
        for(Booking__c bookingRec : [SELECT Id,
                                     Unique_Customer_ID__c,
                                     Opportunity__r.Account.Unique_Customer_ID__c 
                                     FROM Booking__c 
                                     WHERE Opportunity__r.AccountId IN : accountIds]) {
                                         
                                         bookingRec.Unique_Customer_ID__c =     bookingRec.Opportunity__r.Account.Unique_Customer_ID__c;          
                                         lstBooking.add(bookingRec);
                                     }
        
        if(lstBooking.size() > 0) {
            update lstBooking;
        }
    }
    
    public static void updateApplicantUniqueId(Set<Id> accountIds,Boolean isFromMerge) {
        List<Applicant_Details__c> lstApplicant = new List<Applicant_Details__c>();
        System.debug('DEBUG: Applicant ->'+accountIds);
        
        for(Applicant_Details__c applicantRec : [SELECT Id,
                                                 Unique_Customer_ID__c,
                                                 Opportunity__r.Account.Unique_Customer_ID__c 
                                                 FROM Applicant_Details__c 
                                                 WHERE Opportunity__r.AccountId IN : accountIds]) {
                                                     
                                                     applicantRec.Unique_Customer_ID__c =     applicantRec.Opportunity__r.Account.Unique_Customer_ID__c;          
                                                     lstApplicant.add(applicantRec);
                                                 }
        System.debug('DEBUG: Applicant ->'+lstApplicant);
        System.debug('DEBUG: Applicant ->'+isFromMerge);
        if(lstApplicant.size() > 0 && isFromMerge) {
            	update lstApplicant;
        }
    }
}
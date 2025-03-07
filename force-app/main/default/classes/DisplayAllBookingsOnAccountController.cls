public with sharing class DisplayAllBookingsOnAccountController {
   
    @AuraEnabled(cacheable=true)
    public static List<Applicant_Details__c> getApplicantDetails(String accountId){

        List<Account> accList = new List<Account>();
        List<Applicant_Details__c> listApplicationDetail;

        accList = [Select Id, Unique_Customer_External_ID__c from Account where Id = :accountId Limit 1];
        if(accList!=null && accList.size()>0 && accList[0].Unique_Customer_External_ID__c!=null){
            try {
                listApplicationDetail = [Select Id, Name, Booking__c, Booking__r.Name, Booking__r.Opportunity__c,Booking__r.Opportunity__r.Name, Account__c,Account__r.Name, Applicant_Number__c from Applicant_Details__c where Account__r.Unique_Customer_External_ID__c =:accList[0].Unique_Customer_External_ID__c and Applicant_Number__c = 'Primary Applicant'];
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        if(listApplicationDetail!=null && listApplicationDetail.size()>0){
            return listApplicationDetail;
        }else{
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static String baseURL(){
        string urler = URL.getOrgDomainURL().toExternalForm();
        return (urler);
    }
}
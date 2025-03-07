public with sharing class BookingUtilityClass {
    public static String getEmailOfApplicants(String bookingId){
        //SOB-336 start
        string emailAddresses='';
        for(Applicant_Details__c ad : [select Name, Email_Address__c from Applicant_Details__c where Booking__c =: bookingId and Applicant_Number__c != 'Primary Applicant']){
            if(emailAddresses == ''){
                emailAddresses += ad.Email_Address__c;
            }else{
                emailAddresses += ','+ad.Email_Address__c;
            }
           
        }
        return emailAddresses;
        //SOB-336 end
    }
}
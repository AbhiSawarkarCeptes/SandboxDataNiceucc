/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CRMSiteVisitController {
    @AuraEnabled(cacheable = true)
    public static Booking__c getBookingData(String bookingId,String unitId){
        if(!string.isblank(bookingId)){
        //return [select id,Primary_Applicant_Address__c,PrimaryMobileNumber__c,Unit__c,Unit__r.Name, City__c,Applicant_Details__r.Subtype_Of_Applicant__c,Primary_Applicant_Name__c, Primary_Applicant_Email__c from Booking__c where id =:bookingId ];
        return [SELECT id,name,PrimaryMobileNumber__c,Primary_Applicant_Name__c,Nationality_2__c,ApplicantName__c,Primary_Applicant_Email__c,Status__c,Nationality__c,City__c,Primary_Applicant_Address__c,Project__c,CRM_Executive__c,Opportunity__r.Name,Project__r.name,Opportunity__c,Unit__c,Unit__r.Name FROM Booking__c WHERE Id =:bookingId];
        }else{
            return [SELECT id,name,PrimaryMobileNumber__c,Primary_Applicant_Name__c,Nationality_2__c,ApplicantName__c,Primary_Applicant_Email__c,Status__c,Nationality__c,City__c,Primary_Applicant_Address__c,Project__c,CRM_Executive__c,Opportunity__r.Name,Project__r.name,Opportunity__c,Unit__c,Unit__r.Name FROM Booking__c WHERE Status__c != 'Cancelled' AND Unit__c =:unitId];       
         }
    }
    /*@AuraEnabled(cacheable= true)  
    public static List<Applicant_Details__c> getUnitData(String unitId){
        //return [select id,Booking__c,Booking__r.Name,Booking__r.Primary_Applicant_Address__c,Booking__r.PrimaryMobileNumber__c,Name, Booking__r.City__c,Booking__r.Applicant_Details__r.Subtype_Of_Applicant__c,Booking__r.Primary_Applicant_Name__c, Booking__r.Primary_Applicant_Email__c from unit__c where id =:unitId ];
        return [select id,name,Email_Address__c,Unit__c,Booking__c,Booking__r.name,Unit__r.Name,City__c, Mailing_Address__c,Subtype_Of_Applicant__c,Mobile_Number__c from Applicant_Details__c where Unit__c =:unitId];
    }*/
    @AuraEnabled(cacheable = true)
    public static  id getRecordTypeId(String recordTypeName) {
        List<RecordType> rtList = [select id from RecordType where SobjectType = 'Customer_Registration__c' and DeveloperName = :recordTypeName];
       return  rtList[0].id ;
    }
}
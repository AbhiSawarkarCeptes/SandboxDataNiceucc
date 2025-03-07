/*********************************************************************
 * Class Name  :   CRMSiteVisitCopyController
 * Description :   Controller class for the createCRMSiteVisitFormCopy LWC component
 * Created Date:   06/12/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 06/12/2023
 *********************************************************************/
public class CRMSiteVisitCopyController {
    @AuraEnabled(cacheable = true)
    public static PropStrength__Application_Booking__c getBookingData(String bookingId,String propertyId){
        if(!string.isblank(bookingId)){
            return [SELECT id, name, PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Primary_Applicant_Name__c, PropStrength__Applicant_Mobile__c, PropStrength__Primary_Customer__r.PropStrength__Nationality__c, PropStrength__Applicant_Email__c, PropStrength__Applicant_Residence_Status__c, PropStrength__Status__c, PropStrength__Primary_Customer__r.MailingCity, PropStrength__Applicant_Address__c, PropStrength__Project__c, CRM_Executive__c, Project_Name__c, PropStrength__Property__c, House_Unit_No__c FROM PropStrength__Application_Booking__c WHERE Id =:bookingId];
        }else{
            return [SELECT id, name, PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Primary_Applicant_Name__c, PropStrength__Applicant_Mobile__c, PropStrength__Primary_Customer__r.PropStrength__Nationality__c, PropStrength__Applicant_Email__c, PropStrength__Applicant_Residence_Status__c, PropStrength__Status__c, PropStrength__Primary_Customer__r.MailingCity, PropStrength__Applicant_Address__c, PropStrength__Project__c, CRM_Executive__c, Project_Name__c, PropStrength__Property__c, House_Unit_No__c FROM PropStrength__Application_Booking__c WHERE PropStrength__Status__c != 'Booking_Cancelled' AND PropStrength__Property__c =:propertyId];       
        }
    }

    @AuraEnabled(cacheable = true)
    public static  id getRecordTypeId(String recordTypeName) {
        List<RecordType> rtList = [select id from RecordType where SobjectType = 'Customer_Registration__c' and DeveloperName = :recordTypeName];
        return  rtList[0].id ;
    }
}
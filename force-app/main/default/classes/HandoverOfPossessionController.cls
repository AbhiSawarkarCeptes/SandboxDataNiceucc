/*********************************************************************
 * Class Name  :   HandoverOfPossessionController
 * Description :   Helper Class of Handover_Of_Possession (VF Page)
 * Created Date:   08/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 08/02/2024
 *********************************************************************/
public class HandoverOfPossessionController {
    public PropStrength__Application_Booking__c booking {get;set;}
    public String recId;
    
    public HandoverOfPossessionController() {
        recId = ApexPages.currentPage().getParameters().get('id'); 
        booking = new PropStrength__Application_Booking__c();
        if(recId != null && recId != '') {
            booking = [SELECT Id, PropStrength__CP_Car_Parking_Name1__c, PropStrength__Primary_Customer__r.Passport_No__c, PropStrength__Primary_Customer__r.Passport_Expiry_Date__c, PropStrength__Primary_Customer__r.PropStrength__Nationality__c, PropStrength__Project__c, PropStrength__Property__r.PropStrength__Property_Name__c, PropStrength__Property__r.PropStrength__Completion_Certificate_Date__c, PropStrength__Project__r.Name, PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.MailingStreet, PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.MailingCity, PropStrength__Primary_Customer__r.MailingState, PropStrength__Primary_Customer__r.MailingCountry FROM PropStrength__Application_Booking__c WHERE Id = :recId];
        }
    }
}
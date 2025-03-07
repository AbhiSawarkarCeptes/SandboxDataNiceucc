public class HandoverWelcomeLetterPageController {
    public PropStrength__Transaction_Requests__c tr {get;set;}
    public String recId;
    
    public HandoverWelcomeLetterPageController() {
        recId = ApexPages.currentPage().getParameters().get('id'); 
        tr = new PropStrength__Transaction_Requests__c();
        if(recId != null && recId != '') {
            tr = [SELECT Id, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Passport_No__c, Completion_Notice_Sent_Date__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Completion_Certificate_Date__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingStreet, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCity, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingState, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCountry FROM PropStrength__Transaction_Requests__c WHERE Id = :recId];
        }
    }
}
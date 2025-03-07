public class CompletionNoticeBookingController {
    public PropStrength__Application_Booking__c tr {get;set;}
    public String recId;
    
    public CompletionNoticeBookingController() {
        recId = ApexPages.currentPage().getParameters().get('id'); 
        tr = new PropStrength__Application_Booking__c();
        if(recId != null && recId != '') {
            tr = [SELECT Id, PropStrength__Project__c, PropStrength__Property__r.PropStrength__Property_Name__c, PropStrength__Property__r.PropStrength__Completion_Certificate_Date__c, PropStrength__Project__r.Name, PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.MailingStreet, PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.MailingCity, PropStrength__Primary_Customer__r.MailingState, PropStrength__Primary_Customer__r.MailingCountry FROM PropStrength__Application_Booking__c WHERE Id = :recId];
        }
    }
}
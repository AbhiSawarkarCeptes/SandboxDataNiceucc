public class InstallmentNotificationController {
    public PropStrength__Received_Payment__c tr {get;set;}
    public Bank_GL__c bank {get;set;}
    public String recId;
    public List<PropStrength__Received_Payment__c> trList;
    
    public InstallmentNotificationController() {
        recId = ApexPages.currentPage().getParameters().get('id'); 
        tr = new PropStrength__Received_Payment__c();
        trList = new List<PropStrength__Received_Payment__c>();
        if(recId != null && recId != '') {
            trList = [SELECT Id, PropStrength__Amount_Due_Type__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingStreet, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCity, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingState, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCountry, PropStrength__Application_Booking__r.PropStrength__Booking_Date__c, PropStrength__Application_Booking__r.PropStrength__Super_Area__c, PropStrength__Application_Booking__r.PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Payment_Date__c, (SELECT Id, PropStrength__Charge_Name__c, PropStrength__Other_Charge_Amount__c, PropStrength__Other_Charge_Service_Tax__c FROM PropStrength__Other_Charge_Due_Partitions__r) FROM PropStrength__Received_Payment__c WHERE Id = :recId];
            if(!trList.isEmpty() && trList[0].PropStrength__Application_Booking__r.PropStrength__Project__c != null) {
                System.debug(trList[0].PropStrength__Application_Booking__r.PropStrength__Project__c);
                tr = trList[0];
                bank = [SELECT Id, (SELECT Id, Bank_Account_Type__c, Beneficiary__c, Account_Number__c, IBAN__c, Swift_Code__c, Bank_Name__c FROM Bank_GL__r WHERE Bank_Account_Type__c = 'Escrow Account' LIMIT 1) FROM PropStrength__Projects__c WHERE Id = :trList[0].PropStrength__Application_Booking__r.PropStrength__Project__c].Bank_GL__r[0];
            }
        }
    }
}
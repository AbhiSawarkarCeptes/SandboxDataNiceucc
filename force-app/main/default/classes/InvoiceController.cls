public class InvoiceController {
    public String ledgerId;
    public PropStrength__Broker_Ledger__c ledgerRec {get;set;}
    public Boolean showVatFields {get;set;}
    public InvoiceController() {
        ledgerId = ApexPages.currentPage().getParameters().get('id');
        ledgerRec = new PropStrength__Broker_Ledger__c();
        showVatFields = false;
        
        if(ledgerId != null && ledgerId != '') {
            
            
            ledgerRec = [SELECT Id, Unit_No__c,PropStrength__Broker_Payment_Milestone__c,Brokerage_Due_Percentage__c,
                         PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__c,PropStrength__Brokerage_Due_Rs__c,
                         PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__r.PropStrength__Primary_Applicant_Name__c,
                         PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__r.PropStrength__Project__c,
                         PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__r.PropStrength__Project__r.Name,
                         PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__r.PropStrength__Primary_Customer__c,
                         PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__r.Booked_Date__c,
                         PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__r.PropStrength__Revised_Total_Sales_Consideration__c,
                         PropStrength__Total_Brokerage_Due__c,PropStrength__Broker_Account__c, PropStrength__Service_Tax__c,
                         PropStrength__Broker_Account__r.Name_as_per_trade_license__c,PropStrength__Broker_Account__r.Mobile_No__c,
                         PropStrength__Broker_Account__r.Registration_Number__c,PropStrength__Broker_Account__r.BillingAddress,
                         PropStrength__Broker_Account__r.BillingStreet, PropStrength__Broker_Account__r.BillingState,
                         PropStrength__Broker_Account__r.BillingCity, PropStrength__Broker_Account__r.BillingCountry,
                         PropStrength__Broker_Account__r.BillingPostalCode
                         FROM PropStrength__Broker_Ledger__c WHERE Id = :ledgerId];
            if(ledgerRec != null && ledgerRec.PropStrength__Service_Tax__c != null && ledgerRec.PropStrength__Service_Tax__c > 0) {
                showVatFields = true;
            }
        }
    }
}
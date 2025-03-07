@isTest
public class CustomerOfferTriggerHelper_Test {
	@isTest
    static void testMethod1() {
        Customer_Offers__c c = new Customer_Offers__c();
        c.Offer_Name__c = 'Test';
        c.Offer_Description__c = 'Test';
        c.IsActive__c = true;
        insert c;
        c.IsActive__c = false;
        update c;
        
        Notification__c ntRec = new Notification__c();
        ntRec.Object_Type__c = 'Customer Offer';
        ntRec.CP_SC_ID__c = c.Id;
        insert ntRec;
    }
}
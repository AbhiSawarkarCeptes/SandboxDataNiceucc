@isTest
public class ChannelPartnerOfferTriggerHelper_Test {
	@isTest
    static void testMethod1() {
        Channel_Partner_Offers__c cp = new Channel_Partner_Offers__c();
        cp.Offer_Name__c = 'Test';
        cp.Offer_Description__c = 'Test';
        cp.IsActive__c = true;
        insert cp;
        cp.IsActive__c = false;
        update cp;
        
        Notification__c ntRec = new Notification__c();
        ntRec.Object_Type__c = 'Channel Partner Offer';
        ntRec.CP_SC_ID__c = cp.Id;
        insert ntRec;
    }
}
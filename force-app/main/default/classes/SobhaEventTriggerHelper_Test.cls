@isTest
public class SobhaEventTriggerHelper_Test {
	@isTest
    static void testMethod1() {
        Sobha_Event__c shobaEvt = new Sobha_Event__c();
        shobaEvt.Name = 'Shoba Event';
        shobaEvt.IsActive__c = true;
        insert shobaEvt;
        
        shobaEvt.IsActive__c = false;
        update shobaEvt;
        
        Notification__c ntRec = new Notification__c();
        ntRec.Object_Type__c = 'Gallery';
        ntRec.CP_SC_ID__c = shobaEvt.Id;
        insert ntRec;
    }
}
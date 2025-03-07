@istest
public class SBTRTriggerHandlerTest{
    @isTest
    private static void updateSBTR(){
        Test.startTest();
        Collection_Report__c cr = new Collection_Report__c();
        cr.Total_Amount__c = 909822.6;
        cr.Total_Paid_Amount__c = 913321;
        insert cr;
        Mobile_TestUtil.createBooking();
        Booking__c b = [Select id  From Booking__c limit 1];
        SBTR__c sbtrRec = new SBTR__c(Booking__c = b.Id);
        insert sbtrRec;

        sbtrRec.Booked_Date__c = System.today();
        sbtrRec.Collection_Report__c = cr.id;
        update sbtrRec;
        Test.stopTest();
    }
}
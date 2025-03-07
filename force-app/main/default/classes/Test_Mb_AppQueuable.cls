@isTest
public class Test_Mb_AppQueuable {
    
     @testSetup
    static void setupTestData() {
        Mobile_TestUtil.createBooking();
    }
    
    @isTest
    static void testGetBookingListWithRecords() { 
        
        List<Booking__c> book = [select id, name from Booking__c];
        List<string> lsstr= new List<string> ();
        for(Booking__c a: book){
   			lsstr.add(String.valueOf(a.Id));
		}
        Test.startTest();
        MobileAppQueuable queueableJob = new MobileAppQueuable(lsstr,'test@gmail.com','sent','type');
        System.enqueueJob(queueableJob);
        Test.stopTest();
    }

}
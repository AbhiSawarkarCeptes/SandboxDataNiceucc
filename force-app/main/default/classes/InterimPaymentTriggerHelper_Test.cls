@istest
public class InterimPaymentTriggerHelper_Test {

    @isTest
    static void testcreateInterimPaymentRecord(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.PropStrength__Country_Name__c ='India';
        insert proj;
        
        PropStrength__Application_Booking__c booking = new PropStrength__Application_Booking__c();
        booking.PropStrength__Project__c =  proj.id;
        booking.PropStrength__Booking_Date__c = system.today();
        insert booking;
        
        PropStrength__Interim_Payment__c ip = new PropStrength__Interim_Payment__c();
        ip.PropStrength__Application_Booking__c = booking.id;
        
        insert ip;
        
    }
}
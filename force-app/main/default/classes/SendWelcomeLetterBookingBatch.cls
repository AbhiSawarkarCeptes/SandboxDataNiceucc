//Test Class: SendWelcomeLetterBookingTest
public class SendWelcomeLetterBookingBatch implements Database.Batchable<SObject>, Database.Stateful {
    public String bookingIds = '';
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        // Query all Booking__c records qualified today
        String query = 'SELECT Id, Booking_Approver_Audit__c, Welcome_Mail_Sent_Date__c  ' +
            'FROM Booking__c '+
            'WHERE Qualification_Date__c > 2024-07-05 '+
            'AND Paid_Percentage__c >= 9.5 '+
            ' AND Booking_Approver_Audit__c = \'Accepted\' '+
            ' AND entity_name__c = \'Sobha LLC\' '+
            'AND Welcome_Mail_Sent_Date__c = NULL ' ;
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Booking__c> scope) {
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        system.debug('bookings: '+scope);
        System.debug(+'Size:'+scope.size());
        
        List<Id> bookings = new List<Id>();
        for (Booking__c booking : scope) {
            
            
            bookings.add(booking.id);
            bookingIds=bookingIds+booking.id+' ';
            
        }
          Bypass_Setting__c bypassSettings = Bypass_Setting__c.getInstance();
         if(!bypassSettings.Bypass_Booking_Welcome_Email__c){
       		 SendWelcomeLetterBooking.sendWelcomeLetter(bookings);
         }
        
    }
    
    public void finish(Database.BatchableContext bc) {
        Error_Log__c errLog = new Error_Log__c();
        errLog.Class__c = 'SendWelcomeLetterBookingBatch -- Success';
        errLog.Message__c = bookingIds ;
             Database.insert(errLog, false);
      
        
    }
}
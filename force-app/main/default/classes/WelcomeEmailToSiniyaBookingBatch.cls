//Test class: WelcomeEmailToSiniyaBookingTest
public class WelcomeEmailToSiniyaBookingBatch implements Database.Batchable<SObject>,Database.Stateful  {
    public String bookingIds = '';
     Error_Log__c errLog = new Error_Log__c();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        
        List<String> projectList = new List<String>();
        if (Label.Sobha_Siniya_ProjNames != null) {
            projectList = Label.Sobha_Siniya_ProjNames.split(',');
        }
        
        // Query all Booking__c records that qualify based on the criteria provided from project only Sobha Siniya Island
        
        query = 'SELECT Id,Name, Booking_Approver_Audit__c,Primary_Applicant_Email__c, Welcome_Mail_Sent_Date__c,'+
            'Unit__r.Tower__r.Project__r.Name , Unit__r.Name,Unit__r.Tower__r.Cluster__r.Name ' +
            'FROM Booking__c ' +
            'WHERE Qualification_Date__c >= 2024-10-28 '+
            'AND  Paid_Percentage__c >= 9.5 ' +
            'AND Booking_Approver_Audit__c = \'Accepted\' ' +
            'AND Welcome_Mail_Sent_Date__c = NULL ' +
            'AND Unit__r.Tower__r.Project__r.Name IN :projectList' ;
        
        system.debug('query:'+query);
        return Database.getQueryLocator(query);
    }
    
    // Process the records to send the emails to Owner 
    public void execute(Database.BatchableContext bc, List<Booking__c> scope) {
        system.debug('scope:'+scope);
        for (Booking__c booking : scope) {
            
            bookingIds=bookingIds+booking.id+' ';
        }
        Bypass_Setting__c bypassSettings = Bypass_Setting__c.getInstance();
        
        if(!bypassSettings.Bypass_SiniyaBooking_Welcome_Email__c){
            WelcomeEmailToSiniyaBooking.sendWelcomeLetter(scope);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
       
        errLog.Class__c = 'WelcomeEmailToSiniyaBookingBatch -- Success';
        errLog.Message__c = bookingIds ;
        System.debug('In finish'+errLog.Message__c);
        Database.insert (errLog);
        System.debug('In finish1'+errLog.Message__c);
        
    }
    
    
}
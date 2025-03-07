//Test Class: BookingFormDocuSignClientStatus_isTest
public with sharing class BookingFormDocuSignClientStatusEmail {
    
    @InvocableMethod
    public static void sendEmailMethod(List<String> bookingIds){
        String mySourceId = bookingIds[0];
        PrepareNSendEmail(mySourceId);
    }
    
    
    public static void PrepareNSendEmail(String mySourceId) {
        List <String> lststringtoaddress = new List<String>();
        List <String> lststringCCaddress = new List<String>();
        try{
            Booking__c booking = [Select id,Name,
                                  Sales_Manager__c,
                                  Sales_Managers__r.name,
                                  Sales_Managers__r.email,
                                  Sales_Head__c,
                                  Sales_Head__r.name,
                                  Sales_Head__r.email,
                                  Sales_Head__r.Manager.Email,
                                  Unit__r.Name,
                                  Project__r.Name
                                  From Booking__c
                                  where id=:mySourceId limit 1];
            
            booking.Current_Status__c  = 'Sent to Client';
            update booking;
            
            String body = '';
            if(booking.Project__r.Name == 'Sobha Siniya island') {
                 Shoba_Default_Settings__mdt siniyaSettings = [SELECT booking_cancellation_days__c 
                                                      FROM Shoba_Default_Settings__mdt 
                                                      WHERE QualifiedApiName = 'Sobha_Siniya_Island'
                                                      LIMIT 1];
                body =  'Dear Team ,<br/><br/>'+
                    'This is to inform you that the Booking form with Booking ID- '+ booking.Name +' for Unit # '+ booking.Unit__r.Name + ' has been sent to the client for DocuSign. '+
                    'Please coordinate with the client to sign the booking form at the earliest. '+
                    'Kindly check Salesforce for further status updates. <br/><br/>'+
                    '<i>Note: Non-submission of signed Booking form within '+siniyaSettings.booking_cancellation_days__c+ ' calendar days will lead to unit cancellation</i> <br/><br/>';
            }
            else {
                 Shoba_Default_Settings__mdt sobhaSettings = [SELECT booking_cancellation_days__c 
                                                     FROM Shoba_Default_Settings__mdt 
                                                     WHERE QualifiedApiName = 'Org_Defaults'
                                                     LIMIT 1];
                body =  'Dear Team ,<br/><br/>'+
                    'This is to inform you that the Booking form with Booking ID- '+ booking.Name +' for Unit # '+ booking.Unit__r.Name + ' has been sent to the client for DocuSign. '+
                    'Please coordinate with the client to sign the booking form at the earliest. '+
                    'Kindly check Salesforce for further status updates. <br/><br/>'+
                    '<i>Note: Non-submission of signed Booking form within '+sobhaSettings.booking_cancellation_days__c+' calendar days will lead to unit cancellation</i> <br/><br/>';
            }
            
            
            lststringtoaddress.add(booking.Sales_Managers__r.email);
            lststringtoaddress.add(booking.Sales_Head__r.email);
            if (booking.Sales_Head__r.Manager != null) {
                lststringCCaddress.add(booking.Sales_Head__r.Manager.Email);
            }
            lststringCCaddress.add('salesops@sobharealty.com');
                            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            String sub = 'DocuSign Unit #' + booking.Unit__r.Name+'- Booking ID #' +  booking.Name;
            email.setSubject(sub);        
            email.setToAddresses(lststringtoaddress);
            if (lststringCCaddress.size() > 0) {
                email.setCcAddresses(lststringCCaddress);
            }  
            
            email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
            system.debug('email:'+email);
            Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});
            
        }
        
        catch(Exception e) {
            Error_Log__c trackErrorRec = new Error_Log__c(Class__c = 'BookingFormDocuSignClientStatusEmail',Message__c = e.getmessage());
            database.insert(trackErrorRec, false);
            system.debug('~~~Catch Exception: '+e.getMessage());
            
        }
    }
    
    
}
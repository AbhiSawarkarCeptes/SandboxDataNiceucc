//Test class: WelcomeEmailToSiniyaBookingTest
public class WelcomeEmailToSiniyaBooking {
    public static void sendWelcomeLetter(List<Booking__c> bookings){
        // Process the records to send the emails to Owner 
        
        system.debug('bookings:'+bookings);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        OrgWideEmailAddress[] owea ;        
        
        
        owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'customercare@sobhasiniyaisland.com'];
        
        Contact dummyContact = new Contact(LastName = 'lastName', Email = 'email@email.com.invalid');
        insert dummyContact;
        try{
            List<String> EmailIds = New List<String>();
            
            map<Id, Booking__c> idToBookingMap = new map<Id, Booking__c>();
            
            
            Map<Id, Applicant_Details__c> applIdToApplicantMap = new Map<Id, Applicant_Details__c>();
            List<Id> bookIds = new List<Id>();
            //Create Booking Id with booking Map
            for(Booking__c book : bookings){
                system.debug('Book:'+book.Name+'-'+book.Unit__r.Tower__r.Project__r.Name);
                idToBookingMap.put(book.Id, book);
                bookIds.add(book.Id);
            }
            
            
            Set<Id> bookingIdsSet = new Set<Id>();
            List<Booking__c> bookingsUpdateList = new List<Booking__c>();
            for (Applicant_Details__c applicant : [
                SELECT Id, Email_Address__c, Booking__c, Name, Mailing_Address_Merge__c,Mobile_Number__c
                FROM Applicant_Details__c 
                WHERE Booking__c IN :bookIds ]) 
            {
                
                system.debug('applicant.Email_Address__c'+applicant.Email_Address__c);                                                                           
                
                
                String body =  'Dear Mr./Ms. ' + applicant.Name + ',<br/><br/>' +                        
                    'Greetings from <b>Sobha Al Siniya FZC!</b><br/><br/>' +
                    'Thank you for your purchase of Unit ' + idToBookingMap.get(applicant.Booking__c).Unit__r.Name + ' in project ' + idToBookingMap.get(applicant.Booking__c).Unit__r.Tower__r.Project__r.Name + '. ' +
                    'We are excited to start this journey with you and are committed to ensuring a smooth and successful onboarding process.<br/><br/>' +
                    'As the next step, our Customer Relations Team will reach out to you shortly to confirm your contact details and verify that all your information is up to date for future communications.<br/><br/>' +
                    'Should you need assistance, please do not hesitate to contact us at <u style="color:blue;">customercare@sobhasiniyaisland.com</u>. ' +
                    'Our office hours are from 9:00 a.m. to 6:30 p.m. Monday through Friday and 10:00 a.m. to 5:00 p.m. on Saturdays.<br/><br/>' +
                    'We look forward to providing you with exceptional service and ensuring your satisfaction throughout this journey.<br/><br/>' +
                    'Yours sincerely,<br/>' +
                    '<b>For Sobha Al Siniya FZC</b>'; 
                
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                
                email.setSubject('UNIT '+idToBookingMap.get(applicant.Booking__c).Unit__r.Name+ ' | '+ idToBookingMap.get(applicant.Booking__c).Unit__r.Tower__r.Cluster__r.Name + ' | ' + 'Welcome to Sobha Al Siniya FZC!');
                email.setToAddresses(new List<String>{ applicant.Email_Address__c }); 
                email.setBccAddresses(new List<String>{Label.SF_Notifications});
                
                
                
                
                email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
                email.setWhatId(applicant.Booking__c);
                system.debug('applicant.Booking__c'+applicant.Booking__c);
                email.setTargetObjectId(dummyContact.id);
                email.setTreatTargetObjectAsRecipient(false);
                email.setSaveAsActivity(true);
                
                if ( owea.size() > 0 ) {
                    system.debug('owea.get(0).Id'+owea.get(0).Id);
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                } 
                if(!bookingIdsSet.contains(applicant.Booking__c)){
                    Booking__c thisBooking = new Booking__c( Id = applicant.Booking__c);
                    thisBooking.Welcome_Mail_Sent_Date__c = System.Now();
                    bookingsUpdateList.add(thisBooking);
                    bookingIdsSet.add(thisBooking.Id);//using set, to avoid insertion of updatedduplicate bookings in the list
                } 
                
                emailsToSend.add(email);
            }  
            if(!emailsToSend.isEmpty())
            {
                System.debug('Sending emails started: ');
                system.debug('bookingsUpdateList:'+ bookingsUpdateList);
                List<Messaging.SendEmailResult> allEmailResult = Messaging.sendEmail(emailsToSend);
                update bookingsUpdateList;
                delete dummyContact;
            }
            
            
            
        }
        Catch(Exception e)
        {
            system.debug('something went wrong in execute');
            Error_Log__c log = new Error_Log__c();
            log.Class__c = 'SendWelcomeEmailsBatch -- Failure';
            log.Message__c ='In execute():'+e ;
            insert log;
        }
    }
    
}
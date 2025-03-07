//Test Class: SendWelcomeLetterBookingTest
public class SendWelcomeLetterBooking 
{
    @InvocableMethod(label = 'sendwelcomeletter')
    public static void sendWelcomeLetter(List<Id> bookIds){
        
        sendWelcomeLetterSyn(bookIds);
        
    }
    
    public static void sendWelcomeLetterSyn(List<Id> bookIds){
        
        try{
            List<String> EmailIds = New List<String>();
            map<Id, Blob> pdfMap = new map<Id, Blob>();
            map<Id, Booking__c> emailMap = new map<Id, Booking__c>();
            list<Id> docIds = new list<Id>();
            docIds.add(Label.Know_Your_Journey );
            //docIds.add(Label.Did_You_Know);
            List<ContentVersion> cvList = [SELECT Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId in :docIds AND IsLatest = true];
            list<Blob> fileData = new list<Blob>();
            if(!test.isRunningTest()){
                for(ContentVersion cv :cvList){
                    Blob b;
                    b=cv.VersionData;
                    fileData.add(b) ;
                }
            }
            else{
                Blob fileData1 = blob.valueOf('Test Content');
                fileData.add(fileData1);
            }
            
            // Query all related Applicant_Details__c records for the given bookings
            Map<Id, Applicant_Details__c> bookingToApplicantsMap = new Map<Id, Applicant_Details__c>();
            for(Booking__c book : [SELECT id, Name, Tower_Name__c,Unit__r.Name, Primary_Applicant_Name__c,Primary_Applicant_Email__c, 
                                   PrimaryMobileNumber__c,Unit__r.Tower__r.Cluster__r.Name, Agreement_Value__c,Registration_Amount_Paid__c, 
                                   Primary_Applicant_Address__c, Project__r.Name  FROM Booking__c WHERE id in :bookIds]){
                                       /* PageReference ref = page.welcomeletterpage;
                                    //ref.getParameters().put('id',bookIds[0]); 
                                    ref.getParameters().put('id',book.Id); 
                                    ref.setRedirect(true);
                                    Blob b;
                                    if(!test.isRunningTest())
                                    {
                                    b=ref.getContentAsPDF();
                                    }
                                    else
                                    {
                                    b = blob.valueOf('Test');
                                    }
                                    pdfMap.put(book.Id, b);*/
                                       system.debug('Inside for:'+book.Unit__r.Tower__r.Cluster__r.Name);
                                       emailMap.put(book.Id, book);
                                   }
            
            for (Applicant_Details__c applicant : [
                SELECT Id, Email_Address__c, Booking__c, Name, Mailing_Address_Merge__c,Mobile_Number__c
                FROM Applicant_Details__c 
                WHERE Booking__c IN :bookIds
            ]) {
                bookingToApplicantsMap.put(applicant.Id, applicant);
                PageReference ref = page.welcomeletterpage;
                
                ref.getParameters().put('id',applicant.Booking__c); 
                ref.getParameters().put('applicantName',applicant.Name); 
                ref.getParameters().put('applicantAddress',applicant.Mailing_Address_Merge__c); 
                ref.getParameters().put('applicantMobileNumber',applicant.Mobile_Number__c); 
                ref.getParameters().put('applicantEmail',applicant.Email_Address__c);
                ref.setRedirect(true);
                Blob b;
                if(!test.isRunningTest())
                {
                    b=ref.getContentAsPDF();
                }
                else
                {
                    b = blob.valueOf('Test');
                }
                pdfMap.put(applicant.Id, b);
            }
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = : Label.SobhaHelpdesk];
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            Contact dummyContact = new Contact(LastName = 'lastName', Email = 'email@email.com.invalid');
            insert dummyContact;
            Set<Id> bookingIdsSet = new Set<Id>();
            List<Booking__c> bookingsUpdateList = new List<Booking__c>();
            for(Id ids : pdfMap.keySet())
            {
                
                Applicant_Details__c applicant = bookingToApplicantsMap.get(ids);
                String bookingId = emailMap.get(applicant.Booking__c).id;
                system.debug('tower:'+emailMap.get(applicant.Booking__c).Unit__r.Tower__r.Cluster__r.Name);
                
                String body =  'Dear ' +applicant.Name+',<br/><br/>' +                        
                    'Greetings from Sobha Realty! ' +'<br/><br/>'+
                    'Thank you for your purchase in our prestigious project, '+ emailMap.get(applicant.Booking__c).Unit__r.Tower__r.Cluster__r.Name+'. '+
                    'We are excited to embark on this journey together and to ensure a smooth and successful onboarding process, we have outlined a roadmap for your journey. <br/><br/>'+
                    'As a next step, you would be receiving a call from our Customer Relationship Team to validate your contact details. This will help ensure that your details remain current for any future communications. <br/><br/>'+
                    'Attached to the email, you will find: <br/>'+
                    '<ul><li>Know Your Journey: This resource would provide valuable insights and guidance to enhance your experience with Sobha Realty</li>'+
                    '<li>Pre-Registration Notice: To register the Unit(s) with the DLD, you are requested to make the payment of the registration fee as per the notice. (<i>If you have already completed the payment, please disregard the notice</i>)</li></ul>'+
                    'For any assistance, please feel free to contact us on 800 SOBHA (76242) or write to us at helpdesk@sobharealty.com. Our office working hours are from 9:00 a.m. to 6:30 p.m. from Monday to Friday, and on Saturdays, we are available from 10:00 a.m. to 5:00 p.m.<br/><br/>'+
                    'We are committed to deliver exceptional service, and our team will ensure your satisfaction throughout this exciting journey.<br/><br/>'+
                    
                    'Yours sincerely, <br/>'+
                    '<b>For Sobha L.L.C.</b>';
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setFileName('Pre-Registration Notice.pdf');
                efa1.setBody(pdfMap.get(ids));
                List<Messaging.EmailFileAttachment> efa2list = new List<Messaging.EmailFileAttachment>();
                Integer i=0;
                if(!test.isRunningTest())
                {
                    for(ContentVersion cv :cvList)
                    {
                        Messaging.EmailFileAttachment ef = new Messaging.EmailFileAttachment();
                        ef.setFilename(cv.title+'.'+cv.FileExtension);
                        ef.setBody(fileData[i]);
                        efa2list.add(ef);
                        i=i+1;
                    }   
                }
                else
                {
                    Messaging.EmailFileAttachment ef2 = new Messaging.EmailFileAttachment();
                    ef2.setFilename('Test.pdf');
                    ef2.setBody(fileData[0]);
                    efa2list.add(ef2);
                }
                efa2list.add(efa1);
                email.setSubject('UNIT '+emailMap.get(applicant.Booking__c).Unit__r.Name+ ' | '+ emailMap.get(applicant.Booking__c).Unit__r.Tower__r.Cluster__r.Name + ' | ' + 'Welcome to Sobha Realty');
               email.setToAddresses(new List<String>{ applicant.Email_Address__c });
                //email.setToAddresses(new List<String>{ 'mohammed.mujthaba.c@sobharealty.com' });
               // email.setToAddresses(new List<String>{ 'shravani.phadke@ceptes.onmicrosoft.com' });
                
                email.setBccAddresses(new List<String>{Label.SF_Notifications});
                email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
                email.setFileAttachments(efa2list);
               //	email.setWhatId(bookIds[0]);
                email.setWhatId(applicant.Booking__c);
                email.setTargetObjectId(dummyContact.id);
                email.setTreatTargetObjectAsRecipient(false);
                email.setSaveAsActivity(true);
                
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                //Booking__c thisBooking = new Booking__c( Id = bookIds[0]);
                
                
                Booking__c thisBooking = new Booking__c( Id = bookingId);
                thisBooking.Welcome_Mail_Sent_Date__c = System.Now();
                if(!bookingIdsSet.contains(thisBooking.Id)){
                    
                    bookingsUpdateList.add(thisBooking);
                    bookingIdsSet.add(thisBooking.Id);
                    system.debug('bookingsUpdateList:'+ bookingsUpdateList);
                }
                
                emailsToSend.add(email);
                
                
                
            }  
            if(!emailsToSend.isEmpty())
            {
                System.debug('Sending emails started: ');
                List<Messaging.SendEmailResult> allEmailResult = Messaging.sendEmail(emailsToSend);
                update bookingsUpdateList;
                delete dummyContact;
            }
            
            
            
        }
        Catch(Exception e)
        {
            system.debug('something went wrong in future method sendwelcomelettterSsyn');
            Error_Log__c log = new Error_Log__c();
            log.Class__c = 'SendWelcomeLetterBooking -- Failure';
            log.Message__c ='In sendWelcomeLettterSyn():'+e ;
            insert log;
        }
    }
    
}
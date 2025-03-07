public class SendCompletionnoticebatch implements Database.Batchable<sObject>,Database.stateful {
    
    public string towerValue;
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date CompletionDate  = date.valueOf(CompletionNoticeDate__mdt.getInstance('CompletionDate').completionDate__c);
        towerValue = TowerName__mdt.getInstance('Tower').TowerName__c;
        if(test.isRunningTest()){
            towerValue = 'Cluster 1-Tower X';
        }
        String query = 'select id,Tower_Name__c,Primary_Applicant_Name__c,Cluster__c, Handover_Date__c, Dewa_Number__c, Unit__c, Primary_Applicant_Email__c,Unit__r.Name, Owner.Name,Owner.Email,Unit__r.Tower__r.Name,Project__r.name, Unit__r.Tower__r.RDS_Company_Code__r.Name, Unit__r.Tower__r.Date_of_Completion__c,Opportunity__c, Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Primary_Name__c, Opportunity__r.Permanent_Address__c, Opportunity__r.Primary_Phone__c, Opportunity__r.Primary_Email__c  from Booking__c where  ';
        String runPerBooking = RunHandover_BookingID__mdt.getInstance('bookingName').RunPerBooking__c;
        if(runPerBooking <> null && !test.isRunningTest()){
            List<String> runperbookingList = runPerBooking.split(';');
            query += 'name in :runperbookingList '; 
        } else{
            query += ' Unit__r.Tower__r.Date_of_Completion__c = :CompletionDate and Tower_Name__c = :towerValue and Status__c = \'Processed\' and Current_Status__c = \'Audit Accepted\'';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Booking__c> bookingList){
        system.debug('bookingList' + bookingList);
        List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: system.label.completionNoticeSender];
        if(bookingList.size() > 0){
            for(Booking__c book : bookingList){
                Blob b;
                PageReference pref = new PageReference('/apex/CompletionNoticevfpage');
                pref.getParameters().put('Id', book.Opportunity__c);
                if(!Test.isRunningTest()){
                    b = pref.getContent();  
                } else {
                    b = Blob.valueOf('Test123');
                }                           
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(b);
                attach.setFileName('CompletionNotice.pdf');
                fileAttachments.add(attach);
                
                List<contentversion> fillst1 = [ SELECT title, PathOnClient, FileType, versiondata FROM contentversion where title = 'Sobha Hartland Waves Grande DM Completion Certificate' LIMIT 1];
                system.debug(fillst1);
                for(contentversion ct1 : fillst1){
                    Messaging.EmailFileAttachment tempaatach1 = new Messaging.EmailFileAttachment();
                    tempaatach1.setBody(fillst1[0].versiondata);
                    tempaatach1.setContentType('application/pdf');
                    tempaatach1.setFileName(fillst1[0].title+'.pdf');  
                    fileAttachments.add(tempaatach1);
                }  
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                email.setSubject('Sobha Hartland Waves Grande - Completion Notice for '  + book.Unit__r.Name);
                List <String> lststringtoaddress = new List<String>();
                List <String> lstStringccaddress = new List <String>();
                
                //Integer d = book.Handover_Date__c.day();
                //Integer mo = book.Handover_Date__c.month();
                //Integer yr = book.Handover_Date__c.year();
                //Datetime dt = DateTime.newInstance(yr, mo, d);
                //String handoverdate = dt.format('dd MMMM yyyy');
                //String Cluster = book.Cluster__c;
                Date CurrentDate = system.today().addDays(-1);
                string feb9th = CurrentDate.format();
                
                
                String body =  'Dear ' + book.Primary_Applicant_Name__c+ ',<br/><br/>' +                        
                    /*   'Please find attached SOA.<br/><br/>'+ */
                    'Greetings! <br/><br/>'+
                    'We thank you for your purchase of the above Property. We are pleased to inform you that we have received the Building Completion Certificate and the Completion Date of your Property is 25 August 2023. Please find attached the Building Completion Certificate and the Completion notice for your reference. <br/><br/>'+
                    'A notification regarding the instalment payments for your unit will be sent shortly(If applicable). <br/><br/>'+
                    'Further, we will be contacting you shortly to schedule the Home Orientation/Inspection for your Property.<br/><br/>'+
                    'Should you require any further assistance in this regard, feel free to contact us on +971 4 368 7845 or write to us at <a href="helpdesk@sobharealty.com"> helpdesk@sobharealty.com </a><br/><br/>'+
                    
                    
                    
                    'Thanks and regards,<br/>'+
                    'CRM Team<br/>';
                    
                
                lststringtoaddress.add(book.Primary_Applicant_Email__c); //Commented to block direct communication with client and added booking owner  
                lstStringccaddress.add('helpdesk@sobharealty.com');
                lstStringccaddress.add('sfnotifications@sobharealty.com');
                
                if(owea.size() > 0){
                    email.setOrgWideEmailAddressId( owea.get(0).Id);
                    
                }              
                
                //if(book.Owner.Email != null && book.Owner.Email != '')
                //lstStringccaddress.add(book.Owner.Email);
                
                String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(book.id);
                if(!string.isblank(emailAddressFromBooking)){
                    for(String s : emailAddressFromBooking.split(',')){
                        if(!s.containsIgnoreCase('null')){
                            lststringtoaddress.add(s);
                        }
                    }
                }
                
                email.setToAddresses(lststringtoaddress);
                email.setccAddresses(lstStringccaddress);
                email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
                email.setFileAttachments(fileAttachments);    
                mailsList.add(email);       
            }
            Messaging.sendEmail(mailsList);
            
            
        } 
    }   
    
    public void finish(Database.BatchableContext BC){
        
    }
}
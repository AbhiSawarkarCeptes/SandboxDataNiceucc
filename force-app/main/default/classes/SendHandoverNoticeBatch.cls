public class SendHandoverNoticeBatch implements Database.Batchable<sObject>,Database.stateful {
    public Integer successRec = 0; 
    public Integer failedRec = 0; 
    public Integer totalRec = 0;
    String pdfBody = '';
    public string towerValue;
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date handoverDate  = date.valueOf(handoverDate__mdt.getInstance('handoverDate').handoverDate__c);
        towerValue = TowerName__mdt.getInstance('Tower').TowerName__c;
        if(test.isRunningTest()){
            towerValue = 'Cluster 1-Tower X';
        }
        String query = 'select id,Tower_Name__c,Cluster__c, Handover_Date__c, Dewa_Number__c, Unit__c, Primary_Applicant_Email__c,Unit__r.Name, Owner.Name,Owner.Email,Unit__r.Tower__r.Name,Project__r.name, Unit__r.Tower__r.RDS_Company_Code__r.Name, Unit__r.Tower__r.Date_of_Completion__c,Opportunity__c, Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Primary_Name__c, Opportunity__r.Permanent_Address__c, Opportunity__r.Primary_Phone__c, Opportunity__r.Primary_Email__c,Opportunity__r.AccountId  from Booking__c where  ';
        String runPerBooking = RunHandover_BookingID__mdt.getInstance('bookingName').RunPerBooking__c;
        if(runPerBooking <> null && !test.isRunningTest()){
            List<String> runperbookingList = runPerBooking.split(';');
            query += 'name in :runperbookingList ';
        } else{
            query += ' Handover_Date__c = :handoverDate and Tower_Name__c = :towerValue ';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Booking__c> bookingList){
        system.debug('bookingList' + bookingList);
        List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: system.label.handoverNoticeSender];
        if(bookingList.size() > 0){
            for(Booking__c book : bookingList){
                Blob b;
                PageReference pref = new PageReference('/apex/HandoverNoticeVFpage');
                pref.getParameters().put('Id', book.Opportunity__c);
                if(!Test.isRunningTest()){
                    b = pref.getContent();  
                } else {
                    b = Blob.valueOf('Test123');
                }                           
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(b);
                attach.setFileName('Handover Notice.pdf');
                fileAttachments.add(attach);
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                
                List <String> lststringtoaddress = new List<String>();
                List <String> lstStringccaddress = new List <String>();
                
                EmailTemplate emailTemplate =[Select Id,Subject,Description,
                                              HtmlValue,DeveloperName,Body
                                              from EmailTemplate where name =
                                              'HandoverNoticeEmailTemplate'];
                
                lststringtoaddress.add(book.Primary_Applicant_Email__c); //Commented to block direct communication with client and added booking owner  
               // lstStringccaddress.add('helpdesk@sobharealty.com');
               String handOverNoticeCCList = System.Label.HandOverNoticeCCList;
              // lstStringccaddress.add(HandOverNoticeCCList);
                
                if(owea.size() > 0){
                    email.setOrgWideEmailAddressId( owea.get(0).Id);
                }              
                email.setTemplateID(emailTemplate.Id);
                email.setWhatId(book.Id);
                email.setTargetObjectId(System.Label.HandoverContactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setSaveAsActivity(false);
                String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(book.id);
                if(!string.isblank(emailAddressFromBooking)){
                    for(String s : emailAddressFromBooking.split(',')){
                        if(!s.containsIgnoreCase('null')){
                            lststringtoaddress.add(s);
                        }
                    }
                }
                
               // String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(book.id);
                if(!string.isblank(handOverNoticeCCList)){
                    for(String s : handOverNoticeCCList.split(',')){
                        if(!s.containsIgnoreCase('null')){
                            lstStringccaddress.add(s);
                        }
                    }
                }
                //SOB-336 end
                email.setToAddresses(lststringtoaddress);
                email.setccAddresses(lstStringccaddress);
                email.setFileAttachments(fileAttachments);    
                mailsList.add(email);       
            }
            Messaging.sendEmail(mailsList);
            
        }
    }   
    
    public void finish(Database.BatchableContext BC){
        
    }
}
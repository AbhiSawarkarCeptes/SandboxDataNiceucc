global class OnedaybeforeEmailReminder implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    date todayDate = system.today();
    global Database.QueryLocator start(Database.BatchableContext bi){
        system.debug('===todayDate ==='+todayDate);
        return Database.getQueryLocator([SELECT id,Slot_Scheduled_Date__c,Previous_Slot_Date__c FROM PropStrength__Application_Booking__c WHERE  Previous_Slot_Date__c != null AND Previous_Slot_Date__c =: todayDate]); // 
    }
    global void execute(Database.BatchableContext bi, List<PropStrength__Application_Booking__c> scope){
        try{
            System.debug('====todayDate===='+todayDate);
            System.debug('====scope===='+scope);
            set<id> bookID = new set<id>();  
            if(scope != null && !scope.isEmpty()) {
                for(PropStrength__Application_Booking__c book: scope){
                    bookID.add(book.id);
                }
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if( !test.isrunningtest())
                    owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

                List<EmailTemplate> templatelist ;
                Id TempId;
                String searchTxt = 'Reminder_email_template';
                templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
                if(!templatelist.isEmpty()) {
                    TempId = templatelist[0].id;
                }
                    
                List<PropStrength__Application_Booking__c> bookList = [SELECT Id,PropStrength__Primary_Customer__c, DLD_Reminder_Count__c, PropStrength__Primary_Customer__r.Email FROM PropStrength__Application_Booking__c WHERE Id IN :bookID];
                if(!bookList.isEmpty()){
                    List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
                    for(PropStrength__Application_Booking__c booking : bookList) {
                        if(booking.PropStrength__Primary_Customer__c != null ) {
                            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                            
                            if (owea.size() > 0) {
                                emails.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            
                            emails.setWhatId(booking.Id);
                            emails.setToAddresses( new String[] {booking.PropStrength__Primary_Customer__r.Email} ); 
                            emails.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
                            emails.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                            emails.setTemplateId(TempId);
                            emails.setSaveAsActivity(true); 
                            emails.setTargetObjectId(booking.PropStrength__Primary_Customer__c);
                            emails.setTreatTargetObjectAsRecipient(false); 
                            emaillist.add(emails);

                        }
                    }

                    try{
                        if(emaillist != null && emaillist.size()>0 ) {
                            Messaging.sendEmail(emaillist);

                        }
                    } catch(Exception ex){
                        system.debug('===========Exception ============'+ex.getmessage());
                        system.debug('===========Exception ============'+ex.getlinenumber());
                    }
                }
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    global void finish(Database.BatchableContext bi){  
    
    }
}
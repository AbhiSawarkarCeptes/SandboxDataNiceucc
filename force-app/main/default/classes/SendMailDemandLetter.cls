public class SendMailDemandLetter implements Database.Batchable<SObject>, Database.Stateful {
    public Set<Id> incId;
    public Map<Id, PropStrength__Application_Booking__c> bookMap;

    public SendMailDemandLetter(Set<Id> ids, Map<Id, PropStrength__Application_Booking__c> bMap) {
        incId = ids;
        bookMap = bMap;
    }

    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, PropStrength__Application_Booking__c, PropStrength__Amount_Due_Type__c, PropStrength__Amount__c, PropStrength__Actual_Payment_Date__c FROM PropStrength__Received_Payment__c WHERE Id IN :incId';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<PropStrength__Received_Payment__c> incPayRec) {
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        for(PropStrength__Received_Payment__c incDue : incPayRec) {
            for(PropStrength__Applicant_Detail__c appDet : bookMap.get(incDue.PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r) {
                System.debug('/apex/TransferChargeNotice?id='+incDue.Id);
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String frmsrc = '/apex/TransferChargeNotice?id='+incDue.Id;
                PageReference p1 = new PageReference(frmsrc);
                blob content;
                if(Test.isRunningTest()) { 
                    content = blob.valueOf('Unit.Test');
                } else {
                    content = p1.getContentAsPDF();
                }
                System.debug(content);
                System.debug('======>'+incDue.PropStrength__Actual_Payment_Date__c);
                mail.setSubject(' Important: '+incDue.PropStrength__Amount_Due_Type__c+' Demand Letter for Your Property');
                mail.setplaintextbody('Dear '+appDet.PropStrength__Applicant_Acc__r.Name+',\n\n\nWarm greetings from Sobha LLC!\n\nWe hope this email finds you well. We are writing to provide you with the latest update regarding your property. Attached to this email, please find the '+incDue.PropStrength__Amount_Due_Type__c+' Demand Letter containing essential details for your reference.\n\n\nDemand Details:\n\nCharges: '+incDue.PropStrength__Amount_Due_Type__c+'\nAmount: '+incDue.PropStrength__Amount__c+'\nDue Date: '+incDue.PropStrength__Actual_Payment_Date__c.format()+'\n\nYour prompt attention to this matter would be greatly appreciated. Kindly arrange for the payment of the aforementioned demand charges by the due date to ensure a seamless process.\n\nShould you have any questions or require further assistance, please feel free to reach out to our dedicated customer support team. We are here to assist you every step of the way.\n\nThank you for your continued trust in Sobha LLC. We look forward to serving you with excellence.\n\n\nBest Regards,\nSobha LLC');
                mail.setToAddresses(new List<String>{appDet.PropStrength__Applicant_Acc__r.Email});
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setFileName('Transfer Charge Notice.pdf');
                efa1.setBody(content);   
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                System.debug(mail);
                emailList.add(mail);
                
                System.debug(emailList);
                try{
                    if(emailList != null && emailList.size()>0 ) {
                        System.debug(emailList);
                        Messaging.sendEmail(emailList);
                        EmailMessage newEmail = new EmailMessage();
                        newEmail.ToAddress = appDet.PropStrength__Applicant_Acc__r.Email;
                        newEmail.Subject = mail.getSubject();
                        newEmail.TextBody = mail.getPlainTextBody();
                        newEmail.RelatedToId = incDue.Id;
                        newEmail.Status = '3';
                        insert newEmail;
                    }
                }catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext context) {}
}
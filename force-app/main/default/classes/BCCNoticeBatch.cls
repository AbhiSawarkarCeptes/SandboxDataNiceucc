global class BCCNoticeBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Primary_Applicant_Name__c,Primary_Applicant_Email__c,Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Other_Applicants_Email__c,Unit__r.Name FROM Booking__c WHERE Status__c != \'Cancelled\' AND Unit__r.Tower__r.Cluster__r.Name = \'Waves\' AND Unit__r.Send_BCC__c = true AND BCC_Notice_Sent__c = false';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Booking__c> bookingList) {
        list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();
        for(Booking__c b : bookingList){
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage(); 
            List<String> sendTo = new List<String>();
            
            if(b.Primary_Applicant_Email__c != null && b.Primary_Applicant_Email__c != '')
                sendTo.add(b.Primary_Applicant_Email__c);
            
            string otherApplicantName='';
            if(b.Opportunity__r.Other_Applicants_Name__c != null && b.Opportunity__r.Other_Applicants_Name__c != '')
                otherApplicantName=b.Opportunity__r.Other_Applicants_Name__c;
            
            string otherApplicantEmail='';
            if(b.Opportunity__r.Other_Applicants_Email__c != null && b.Opportunity__r.Other_Applicants_Email__c != ''){
                otherApplicantEmail=b.Opportunity__r.Other_Applicants_Email__c;
                otherApplicantEmail = otherApplicantEmail.trim();
                otherApplicantEmail = otherApplicantEmail.removeEnd(',');
                sendTo.addAll(otherApplicantEmail.split(','));
            }
            
            list<string> ccEmailAddress = new list<string>();
            ccEmailAddress.add('helpdesk@sobharealty.com');
            if(System.label.SobhaCollectionTeamMe != null)ccEmailAddress.add(System.label.SobhaCollectionTeamMe);
            
            string body='Dear ' + b.Primary_Applicant_Name__c + ', '+ otherApplicantName +'<br/><br/>'+
                'We are delighted to announce that your apartment, <b>'+b.Unit__r.Name+'</b> in Waves is expected to receive the building completion certificate in January 2023, well in advance of the original date of September 2023.<br/><br/>'+
                'We have another good news for you. As an appreciation for your investment, we have an exciting discount offer that you can avail over and above the benefits of early completion. Details of the offer are mentioned in the attached notice.<br/><br/>'+
                'If you are interested in availing the offer, you may contact our collections representative or email to customer helpdesk. Email IDs are given below for your reference.<br/>'+
                'ali.shaikh@sobharealty.com<br/>'+
                'helpdesk@sobharealty.com<br/><br/>'+
                'Yours Sincerely,<br/>'+
                'CRM & Collections<br/>'+
                'SOBHA Realty';
            mail.setSubject('Advance notice for Building Completion Certificate (BCC) of Waves');
            mail.setHtmlBody(body);
            mail.setToAddresses(sendTo);
            mail.setCcAddresses(ccEmailAddress);
            
            List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
            
            PageReference prefLetter = new PageReference('/apex/BCCNotice');
            prefLetter.getParameters().put('id', b.Id);
            Blob blbLetter;
            if(!Test.isRunningTest()){
                blbLetter = prefLetter.getContent();   
            } else {
                blbLetter = Blob.valueOf('TestBCCNotice');
            }
            
            Messaging.EmailFileAttachment attachLetter = new Messaging.EmailFileAttachment();                                
            attachLetter.setBody(blbLetter);
            attachLetter.setFileName('Waves Advance BCC Notice.pdf');
            attList.add(attachLetter);
            
            mail.setFileAttachments(attList);  
            
            if(sendTo.size()>0)
                mails.add(mail);
            b.BCC_Notice_Sent__c = true;
        }
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
        if(bookingList.size()>0){
            BookingApprovalCommentHandler.afterTriggerBookingFirstRun = false;
            Database.update(bookingList,false);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
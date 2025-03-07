global class BCCNotificationBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Primary_Applicant_Name__c,Primary_Applicant_Email__c,Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Other_Applicants_Email__c,Unit__r.Name FROM Booking__c WHERE Status__c != \'Cancelled\' AND Unit__r.Tower__r.Cluster__r.Name = \'Sobha Creek Vistas Reserve\' AND Unit__r.Send_BCC__c = true';
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
            ccEmailAddress.add(System.label.SobhaHelpdesk);
            
            string body='Dear ' + b.Primary_Applicant_Name__c + ', '+ otherApplicantName +'<br/><br/>'+
                'Greetings from Sobha Realty! <br/><br/>'+
                'We are delighted to inform you that we anticipate receiving the Building Completion Certificate (<b>"BCC"</b>) for the Sobha Creek Vistas Reserve (Project ID – 2178) project  ("Project") by <b>15th November 2022</b>.<br/><br/>'+
                'Once the BCC is received, we shall commence dispatching the Completion Notice and Handover Notice (together referred to as <b>"Notices"</b>) for the units in the said Project.<br/><br/>'+
                'On receiving the Notices, we shall proceed with the home orientation process for your respective unit. We shall reach out to you to schedule the appointment for home orientation/inspection of your unit and would request you to plan your visit for the said purpose only after receiving confirmed dates and correspondence from our end. If for any reason, you are unavailable to perform home orientation at the proposed date of appointment, you have an option to appoint any individual having valid authorization to conclude the home orientation process. In case of an attorney being appointed (via authorization letter or Power of Attorney), the attorney must carry an authorization instrument (in original) issued by the owner(s) of the unit along with valid personal identification documents.<br/><br/>'+
                'A separate notification regarding the instalment payments (as applicable) for your unit will be sent shortly by the collections team, request you to please clear the dues at the earliest.<br/><br/>'+
                'Should you require any further details, please feel free to contact us on '+System.label.SobhaHelpdesk+' or +971 4 3687845.<br/><br/>'+
                'Best Regards,<br/>'+
                'CRM Team<br/>'+
                'Sobha LLC';
            mail.setSubject('Sobha Creek Vistas Reserve, Unit No. '+b.Unit__r.Name+' - Advance Notification for Building Completion Certificate (BCC)');
            mail.setHtmlBody(body);
            mail.setToAddresses(sendTo);
            mail.setCcAddresses(ccEmailAddress);
            if(sendTo.size()>0)
                mails.add(mail);
        }
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
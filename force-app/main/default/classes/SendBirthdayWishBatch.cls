public class SendBirthdayWishBatch implements Schedulable {
    public void execute(SchedulableContext sc) {
        
        list<Applicant_Details__c> applicantList = [select Id,Name,Email_Address__c 
                                                    from Applicant_Details__c 
                                                    where Birthday_Date__c = TODAY AND 
                                                    Applicant_Number__c = 'Primary Applicant' AND 
                                                    Email_Address__c != null];
        
        list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();
        EmailTemplate template = [Select Id, DeveloperName, Htmlvalue, Body, Subject from EmailTemplate Where DeveloperName = 'Birthday_Wishes'];
        
        Set<String> sentEmailAddressSet = new Set<String>();
        for(Applicant_Details__c applicant : applicantList){
            if(!sentEmailAddressSet.contains(applicant.Email_Address__c)) {
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage(); 
                string emailBody = template.Htmlvalue;
                emailBody = emailBody.replace('#APPLICANT_NAME#', applicant.Name);
                mail.setToAddresses(new List<string> {applicant.Email_Address__c});
                mail.setHtmlBody(emailBody);
                mail.saveAsActivity = false;
                mail.setSubject(template.Subject);
                mails.add(mail);
                sentEmailAddressSet.add(applicant.Email_Address__c);
            }
        }
        
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
    }
}
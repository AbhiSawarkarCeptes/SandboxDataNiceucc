public class EnquiryNurturingController {    
    @AuraEnabled
    public static string loadEmailTemplate(String dayTrackingId) {
        List<Attempt_Tracking__c> attemptList = new List<Attempt_Tracking__c>();
        List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
        String templateName = '';
        String emailBody = '';
        attemptList = [SELECT Id, Status__c, Day_Tracking__r.Name, 
                        Attempted_By__r.Name 
                        FROM Attempt_Tracking__c 
                        WHERE Day_Tracking__c =: dayTrackingId AND 
                            Name = 'Email' LIMIT 1];
        if(!attemptList.isEmpty() && attemptList.size()>0) {
            templateName = attemptList[0].Day_Tracking__r.Name;
            templateName = templateName.replace(' ','_');
            templateName = 'Enquiry_Follow_up_Email_Customer_' + templateName;
        }
        if(!String.isBlank(templateName)) {
            emailTemplate = [SELECT Id, Subject, Description, HtmlValue, 
                                DeveloperName, Body 
                                FROM EmailTemplate 
                                WHERE DeveloperName =: templateName LIMIT 1];
        }
        if(!emailTemplate.isEmpty() && emailTemplate.size()>0 && 
            !attemptList.isEmpty() && attemptList.size()>0) {
            emailBody = emailTemplate[0].Body;
            emailBody = emailBody.replace('#AGENT_NAME#', UserInfo.getName());
        }
        return emailBody;
    }
    @AuraEnabled
    public static void sendEmailToCustomer(string dayTrackingId) {
        List<Attempt_Tracking__c> attemptList = new List<Attempt_Tracking__c>();
        List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
        String templateName = '';
        attemptList = [SELECT Id, Status__c, Day_Tracking__r.Enquiry__r.PropStrength__Email_Address__c, 
                       Day_Tracking__r.Enquiry__r.PropStrength__Primary_Contact__r.email,
                        Day_Tracking__r.Name, Attempted_By__r.Name 
                        FROM Attempt_Tracking__c 
                        WHERE Day_Tracking__c =: dayTrackingId AND 
                            Name = 'Email' LIMIT 1];
        if(!attemptList.isEmpty() && attemptList.size()>0) {
            templateName = attemptList[0].Day_Tracking__r.Name;
            templateName = templateName.replace(' ','_');
            templateName = 'Enquiry_Follow_up_Email_Customer_' + templateName;
        }
        System.debug('templateName/***--'+templateName);
        if(!String.isBlank(templateName)) {
            emailTemplate = [SELECT Id, Subject, Description, HtmlValue, 
                                DeveloperName, Body 
                                FROM EmailTemplate 
                                WHERE DeveloperName =: templateName LIMIT 1];
        }
        if(!emailTemplate.isEmpty() && emailTemplate.size()>0 && 
            emailTemplate[0].Subject != null && 
            !attemptList.isEmpty() && attemptList.size()>0 && 
            attemptList[0].Day_Tracking__r.Enquiry__r.PropStrength__Email_Address__c != null) { 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {attemptList[0].Day_Tracking__r.Enquiry__r.PropStrength__Primary_Contact__r.email};
            mail.setToAddresses(toAddresses);
            mail.setSubject(emailTemplate[0].Subject);
            String emailBody = emailTemplate[0].HtmlValue;
            emailBody = emailBody.replace('#AGENT_NAME#', UserInfo.getName());
            mail.setHtmlBody(emailBody);
            mail.setReplyTo(UserInfo.getUserEmail());
            mail.setSenderDisplayName(UserInfo.getName()); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            attemptList[0].Status__c = 'No Contact - Follow-up';
            update attemptList[0];
        }
    }
}
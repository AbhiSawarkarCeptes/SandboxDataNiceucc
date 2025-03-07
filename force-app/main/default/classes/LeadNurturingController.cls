public class LeadNurturingController {    
    public static map<string,string> getLeadNurturingConfigs(){
        map<string,string> leadNurturingConfigs = new map<string,string>();
        for(Lead_Nurturing__mdt config : [select Id,DeveloperName,Value__c from Lead_Nurturing__mdt]){
            leadNurturingConfigs.put(config.DeveloperName, config.Value__c);
        }
        return leadNurturingConfigs;
    }
    
    @AuraEnabled
    public static string loadEmailTemplate(string dayTrackingId){
        list<Attempt_Tracking__c> aT = [select Id, Status__c, Day_Tracking__r.Lead__r.Email,Day_Tracking__r.Name, Attempted_By__r.Name from Attempt_Tracking__c where Day_Tracking__c=:dayTrackingId and Name = 'Email' limit 1];
        
        String usrName = [select id, name from User where  username=:UserInfo.getUserName()].name;
        if(aT.size()>0){
            string templateName = aT[0].Day_Tracking__r.Name;
            templateName = templateName.replace(' ','_');
            templateName = 'Lead_Follow_up_Email_Customer_'+templateName;
            list<EmailTemplate> emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: templateName Limit 1]; 
            
            if(emailTemplate.size()>0){
                string emailBody = emailTemplate[0].Body;
                emailBody=emailBody.replace('#AGENT_NAME#',usrName);
                return emailBody;
            }
        }
        return '';
    }
    
    @AuraEnabled
    public static void sendEmailToCustomer(string dayTrackingId){
        list<Attempt_Tracking__c> aT = [select Id, Status__c, Day_Tracking__r.Lead__r.Email,Day_Tracking__r.Name, Attempted_By__r.Name from Attempt_Tracking__c where Day_Tracking__c=:dayTrackingId and Name = 'Email' limit 1];
        if(aT.size()>0){
            string templateName = aT[0].Day_Tracking__r.Name;
            templateName = templateName.replace(' ','_');
            templateName = 'Lead_Follow_up_Email_Customer_'+templateName;
            list<EmailTemplate> emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: templateName Limit 1]; 
            String usrName = [select id, name from User where  username=:UserInfo.getUserName()].name;
            
            if(emailTemplate.size()>0){ 
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {aT[0].Day_Tracking__r.Lead__r.Email};
                    mail.setToAddresses(toAddresses);
                mail.setSubject(emailTemplate[0].Subject);
                string emailBody = emailTemplate[0].HtmlValue;
                emailBody=emailBody.replace('#AGENT_NAME#',usrName);
                mail.setHtmlBody(emailBody);
                mail.setReplyTo(UserInfo.getUserEmail());
                mail.setSenderDisplayName(UserInfo.getName()); 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
            aT[0].Status__c = 'No Contact - Follow-up';
            update aT[0];
        }
    }
}
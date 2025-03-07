public class ChannelOpetaionAgencyAgreementBatch implements Database.Batchable<Sobject>, Schedulable{
    String thirtyDayAlert = 'Channel_Operation_30_Days_Email_Alert';
    String fifteenDayAlert = 'Channel_Operation_15_Days_Email_Alert';
    String zeroDayAlert = 'Channel_Operation_0_Days_Email_Alert';
    List<String> EmailTemplatesList = new List<String>{thirtyDayAlert, fifteenDayAlert, zeroDayAlert};
        
    public void execute(SchedulableContext sc){
        ChannelOpetaionAgencyAgreementBatch test = new ChannelOpetaionAgencyAgreementBatch();
        Database.executeBatch(test);
    }  
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<Date> dates = new List<Date>{System.today(), System.today().addDays(15), System.today().addDays(30)};
        String query = 'Select Id, Name, Expiry_Date__c, Email_ID_1__c, Email_ID_2__c, Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.Name, Channel_Relationship_Manager__r.Email from Channel_Partner__c Where Expiry_Date__c IN: dates';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope){
        Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
        Map<String, List<Channel_Partner__c>> messageList = new Map<String, List<Channel_Partner__c>>();
        List<Messaging.Email> emails = new List<Messaging.Email>();
        for(EmailTemplate email : [Select Id, DeveloperName, Htmlvalue, Body, Subject from EmailTemplate Where DeveloperName IN: EmailTemplatesList]){
            emailTemplateMap.put(email.DeveloperName, email);
        }
        for(Sobject obj : scope){
            Channel_Partner__c channel = (Channel_Partner__c) obj;
            String emailAlert = '';
            if(channel.Expiry_Date__c == System.today()){
				emailAlert = zeroDayAlert;
            }else if(channel.Expiry_Date__c == System.today().addDays(15)){
                emailAlert = fifteenDayAlert;
            }else if(channel.Expiry_Date__c == System.today().addDays(30)){
                emailAlert = thirtyDayAlert;
            }
            
            if(!messageList.containsKey(emailAlert)){
                messageList.put(emailAlert, new List<Channel_Partner__c>{channel});
            }else{
                messageList.get(emailAlert).add(channel);
            }         
        }
        
        for(String key : messageList.keySet()){
            if(String.isNotBlank(key)){
                for(Channel_Partner__c channel : messageList.get(key)){
                    List<String> toAddresses = new List<String>{channel.Channel_Relationship_Manager__r.Email};
                    String emailString = channel.Email_ID_1__c != null ? channel.Email_ID_1__c : '';
                    if(channel.Email_ID_2__c != null){
                        toAddresses.add(channel.Email_ID_2__c);
                        if(emailString.length() > 0){
                            toAddresses.add(channel.Email_ID_1__c);
                            emailString = emailString + ',' + channel.Email_ID_2__c;
                        }else{
                            emailString = channel.Email_ID_2__c;
                        }
                    }
                    String htmlValue = emailTemplateMap.get(key).HtmlValue;
                    htmlValue = htmlValue.replace('{!User.Name}', channel.Channel_Relationship_Manager__r.Name);
                    htmlValue = htmlValue.replace('{!User.Email}', channel.Channel_Relationship_Manager__r.Email);
                    htmlValue = htmlValue.replace('{!Channel_Partner__c.Name}', channel.Name);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailmessage();
                    message.setToAddresses(toAddresses);
                    message.setHtmlBody(htmlValue);
                    message.saveAsActivity = false;
                    message.setSubject(emailTemplateMap.get(key).subject);
                    emails.add(message);
                }
            }
        }
        
        Messaging.sendEmail(emails);
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}
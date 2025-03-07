/*********************************************************************
* Class Name  :   Expiry30Or60NotificationBatch
* Description :   Batch class for send expiry notification mail before 15 or 30 days
* Created Date:   10/07/2024
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Nishank Manwani
Last Modified By :   Nishank Manwani 10/07/2024
*********************************************************************/
public class Expiry30Or60NotificationBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date todayPlus15 = System.today().addDays(15);
        Date todayPlus30 = System.today().addDays(30);
        
        String query = 'SELECT Id, Name, PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c, ' +
            'PropStrength__Primary_Customer__r.Passport_Expiry_Date__c, ' +
            'PropStrength__Primary_Customer__r.Visa_Expiry_Date__c, ' +
            'PropStrength__Primary_Customer__r.Email, ' +
            'PropStrength__Primary_Customer__c ' +
            'FROM PropStrength__Application_Booking__c ' +
            'WHERE PropStrength__Primary_Customer__r.Email != null ' +
            'AND (PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c = :todayPlus15 ' +
            'OR PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c = :todayPlus30 ' +
            'OR PropStrength__Primary_Customer__r.Passport_Expiry_Date__c = :todayPlus15 ' +
            'OR PropStrength__Primary_Customer__r.Passport_Expiry_Date__c = :todayPlus30 ' +
            'OR PropStrength__Primary_Customer__r.Visa_Expiry_Date__c = :todayPlus15 ' +
            'OR PropStrength__Primary_Customer__r.Visa_Expiry_Date__c = :todayPlus30)';
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext context) {
        Expiry30Or60NotificationBatch batch = new Expiry30Or60NotificationBatch();
        Database.executeBatch(batch);
    }
    
    public void execute(Database.BatchableContext BC, List<PropStrength__Application_Booking__c> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Expiry30Or60Notification' LIMIT 1];
        
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if(!test.isrunningtest()) {
            owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'helpdesk@sobharealty.com' limit 1];
        }
        
        for(PropStrength__Application_Booking__c record : scope) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            mail.setTemplateId(template.Id);
            mail.setTargetObjectId(record.PropStrength__Primary_Customer__c); 
            mail.setTreatTargetObjectAsRecipient(False);
            mail.setWhatId(record.Id); 
            mail.setToAddresses(new List<String>{record.PropStrength__Primary_Customer__r.Email});
            mail.setSaveAsActivity(true);
            emails.add(mail);
        }
        
        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public void finish(Database.BatchableContext context) {
        String cronExp = '0 0 0 * * ?';
        //System.schedule('Scheduled_Enquiry_Batch_Job'+System.now().addDays(Integer.valueof((Math.random() * 100))), cronExp, new Expiry30Or60NotificationBatch());
    }
}
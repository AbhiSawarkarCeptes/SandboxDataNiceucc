global class SendBirthDayMailBatch implements Database.Batchable <sObject>, Schedulable {
    
    global List<PropStrength__Applicant_Detail__c> start(Database.BatchableContext BC) {
        List<PropStrength__Applicant_Detail__c> appDetList = new List<PropStrength__Applicant_Detail__c>();
        appDetList = [SELECT Id, PropStrength__Application__r.PropStrength__Active__c, PropStrength__Customer_Name__c, PropStrength__Applicant_Acc__r.Birthdate, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__r.PropStrength__Active__c = TRUE];
        return appDetList;
    }

    public void execute(SchedulableContext context) {
        SendBirthDayMailBatch batch = new SendBirthDayMailBatch();
        Database.executeBatch(batch);
    }

    global void execute(Database.BatchableContext BC, List<PropStrength__Applicant_Detail__c> scope) {
        System.debug('Scope::&&&&');
        System.debug(scope);

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> toAddressEmails = new List<String>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        //List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'loyalty@sobharealty.com'];
        List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Send Birthday Wish' limit 1];
        for(PropStrength__Applicant_Detail__c appDet : scope) {
            if(appDet.PropStrength__Applicant_Email__c != null && appDet.PropStrength__Applicant_Acc__r.Birthdate != null && appDet.PropStrength__Applicant_Acc__r.Birthdate.day() == System.Today().day() && appDet.PropStrength__Applicant_Acc__r.Birthdate.month() == System.Today().month()) {
                
                if(!toAddressEmails.contains(appDet.PropStrength__Applicant_Email__c)) {
                    toAddressEmails.add(appDet.PropStrength__Applicant_Email__c);            
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddressEmails);
                    mail.setWhatId(appDet.Id);
                    if(templatelist.size() > 0)
                    	mail.setTemplateId(templatelist[0].Id);
                    // if(owea.size() > 0) {
                    // //    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    // }
                    if (owea.size() > 0) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    mail.setTargetObjectId(appDet.PropStrength__Applicant_Acc__r.Id);
                    mail.setSaveAsActivity(true);
                    emailList.add(mail);
                }
            }
        }
        if(emailList != null && emailList.size()>0 ) {
            System.debug(emailList);
            Messaging.sendEmail(emailList);
        }
    }

    global void finish(Database.BatchableContext BC) {
        //System.schedule('SendBirthDayMailBatch_Hourly'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 * * * ?', new SendBirthDayMailBatch() );
    }
}
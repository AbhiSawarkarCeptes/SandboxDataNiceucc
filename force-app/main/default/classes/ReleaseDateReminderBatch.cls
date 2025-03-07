global class ReleaseDateReminderBatch implements Database.Batchable<sObject>,Database.stateful, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date d=System.today().addDays(2);
        String query='SELECT Id,Name,Release_Date__c,Release_Date_Sent__c FROM PropStrength__Advertisement__c WHERE Release_Date_Sent__c = false AND Release_Date__c =:d';
        return Database.getQueryLocator(query);
    }
    public void execute(SchedulableContext sc){
        ReleaseDateReminderBatch test = new ReleaseDateReminderBatch();
        Database.executeBatch(test);
    } 
    global void execute(Database.BatchableContext BC, List<PropStrength__Advertisement__c> recList) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress=new List<String>();
        Set<Id> userId=new Set<Id>();
        List<PropStrength__Advertisement__c> updateList=new List<PropStrength__Advertisement__c>();
        Group gp=[SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = 'Marketing_Group'];
        for(GroupMember grp:gp.GroupMembers){
            userId.add(grp.UserOrGroupId);
        }
        System.debug(userId);
        for(User userInfo : [SELECT Id,Email FROM USER WHERE Id IN :userId]){
            toAddress.add(userInfo.Email);
        }
        System.debug(toAddress);
        for(PropStrength__Advertisement__c adv:recList){
            adv.Release_Date_Sent__c=true;
            updateList.add(adv);
            Date da=adv.Release_Date__c;
            String relDate=da.day()+ '-'  +da.month() + '-' +da.year();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddress);
            email.setSubject('Release Date Reminder');
            String currentLink=URL.getSalesforceBaseUrl().toExternalForm();
            String link=currentLink+'/'+adv.Id;
            String body='Hello Team , \n \n This is just a friendly reminder about the upcoming release date for '+adv.Name +'. The release is scheduled for '+relDate+'. \n \n To access more information about this advertisement, including the record and any associated details, please click on the following link: '+link+'. \n \n Thank you for your attention, and we look forward to the successful launch of '+adv.Name +'. \n \n Best regards, \n\n Sobha Realty';
            email.setPlainTextBody(body);
            mails.add(email);
        }
        if(mails.size() > 0){
            List<Messaging.SendEmailResult> mrs= Messaging.sendEmail(mails);
        }
        if(updateList.size() > 0){
            update updateList;
        }

    }

    global void finish(Database.BatchableContext BC) {
        
    }
}
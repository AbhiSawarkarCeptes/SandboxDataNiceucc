public class StandLeadNotificationBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, createdById From Stand_Lead__c a Where createdDate = TODAY AND HOUR_IN_DAY(createdDate) > 1';
        return Database.getQueryLocator(query);
    }
  
    public void execute(Database.BatchableContext BC, List<sObject> scope){

        Map<Id,Integer> promotersToLeadMap = new Map<Id,Integer>();
        Map<Id,String> userIdToNameMap = new Map<id,String>();
        List<Id> userIds = new List<Id>();

        Shoba_Default_Settings__mdt sobhametadata = [SELECT Mall_Stand_Manager_Id__c,
                                                     QualifiedApiName
                                                     FROM Shoba_Default_Settings__mdt 
                                                     WHERE QualifiedApiName = 'Org_Defaults'
                                                     LIMIT 1];
        String standManagerId = sobhametadata.Mall_Stand_Manager_Id__c;

        User standManager = [Select id,name,email From User where id=:standManagerId];
        System.debug('standManager : '+standManager);


        for (sObject sl:scope) {
            Stand_Lead__c s = (Stand_Lead__c)sl;
            if (s.createdById != null) {
                userIds.add(s.createdById);
                if (promotersToLeadMap.containsKey(s.createdById)) {
                    Integer leadsCreated = promotersToLeadMap.get(s.createdById);
                    promotersToLeadMap.put(s.createdById, leadsCreated + 1);
                } else {
                    promotersToLeadMap.put(s.createdById,1);
                }
            }
        }
        System.debug('promotersToLeadMap : '+promotersToLeadMap);

        if (userIds.size() > 0) {
            List<User> users = [Select id,Name From User where id=:userIds];
            for (User u:users) {
                userIdToNameMap.put(u.Id,u.name);
            }
        }
        System.debug('userIdToNameMap : '+userIdToNameMap);

        String htmlBody = 'Hi <br><br> <p>Please find the summary of leads created in last one hour. <br><br><br>';

        //open table..
        htmlBody += '<table border="1" style="border-collapse: collapse"><tr><th>Promoter</th><th>Stand Lead Count</th></tr>';

        //iterate over list and output columns/data into table rows...
        for(Id l: promotersToLeadMap.keySet()){
            Integer leadCount = promotersToLeadMap.get(l); 
            String promoterName = userIdToNameMap.get(l);

            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + promoterName + '</td><td style="text-align: center; vertical-align: middle;">' + leadCount + '</td></tr>';

        }

        //close table...
        htmlBody += '</table>';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {standManager.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Stand Mall Lead report for last one hour');
        mail.setHtmlBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  
    public void finish(Database.BatchableContext BC){
    }
}
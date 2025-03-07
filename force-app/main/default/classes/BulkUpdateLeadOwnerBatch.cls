global class BulkUpdateLeadOwnerBatch implements Database.Batchable<sObject> {
    global list<Lead> leads;
    global Id assignTo;
    global BulkUpdateLeadOwnerBatch(list<Lead> leads, Id assignTo){
        this.leads = leads;
        this.assignTo = assignTo;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id,Last_Call_Attempt_Status__c from Lead where Id IN : leads';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        for(Lead l : leadList){
            l.OwnerId = assignTo;
            l.Presales_Agent__c = assignTo;
            if(l.Last_Call_Attempt_Status__c=='No Contact' || l.Last_Call_Attempt_Status__c=='Recycled Lead'){
                l.Last_Call_Attempt_Status__c = 'Recycled Lead';
            } else {
                l.Last_Call_Attempt_Status__c  = 'Not Actioned - No Shuffle';
            }
            l.is_serviced__c = false;
        }
        try{
            LeadAutoReassignController.skipDuplicateLeadLogic = true;
            Database.update(leadList,false);
        }catch(Exception e){}
    }   
    
    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Bulk Lead Owner Update Completed');
        mail.setPlainTextBody('The Bulk Lead Owner Update Job Completed.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
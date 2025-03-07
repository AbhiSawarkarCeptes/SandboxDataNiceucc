global class UnitUpdateBatch implements Database.Batchable <sObject>, Schedulable{
      List <Unit__c> unitToBeUpdated = new List <Unit__c>();       
        
       global Database.QueryLocator start(Database.BatchableContext BC) {
        
       return Database.getQueryLocator([SELECT Charge_1_Amount__c, Charge_2_Amount__c, Charge_3_Amount__c, Charge_4_Amount__c, Charge_5_Amount__c, Charge_6_Amount__c, Charge_7_Amount__c,
                                        Charge_1_Bucket__c, Charge_2_Bucket__c, Charge_3_Bucket__c, Charge_4_Bucket__c, Charge_5_Bucket__c, Charge_6_Bucket__c, Charge_7_Bucket__c,
                                        Puchase_Price__c FROM Unit__c]);       
       }        
        
        global void execute (Database.BatchableContext BC, List <Unit__c> uList){
        for(Unit__c u: uList){
            u.Puchase_Price__c = 0;
            if(String.isNotBlank(u.Charge_1_Bucket__c) && u.Charge_1_Bucket__c != null && u.Charge_1_Bucket__c.containsIgnoreCase('Agreement Value'))
                u.Puchase_Price__c  += u.Charge_1_Amount__c;
            if(String.isNotBlank(u.Charge_2_Bucket__c) && u.Charge_2_Bucket__c != null && u.Charge_2_Bucket__c.containsIgnoreCase('Agreement Value'))
                u.Puchase_Price__c  += u.Charge_2_Amount__c;
            if(String.isNotBlank(u.Charge_3_Bucket__c) && u.Charge_3_Bucket__c != null && u.Charge_3_Bucket__c.containsIgnoreCase('Agreement Value'))
                u.Puchase_Price__c += u.Charge_3_Amount__c;
            if(String.isNotBlank(u.Charge_4_Bucket__c) && u.Charge_4_Bucket__c != null && u.Charge_4_Bucket__c.containsIgnoreCase('Agreement Value'))
                u.Puchase_Price__c += u.Charge_4_Amount__c;
            if(String.isNotBlank(u.Charge_5_Bucket__c) && u.Charge_5_Bucket__c != null && u.Charge_5_Bucket__c.containsIgnoreCase('Agreement Value'))
                u.Puchase_Price__c += u.Charge_5_Amount__c;
            if(String.isNotBlank(u.Charge_6_Bucket__c) && u.Charge_6_Bucket__c != null && u.Charge_6_Bucket__c.containsIgnoreCase('Agreement Value'))
                u.Puchase_Price__c += u.Charge_6_Amount__c;
            if(String.isNotBlank(u.Charge_7_Bucket__c) && u.Charge_7_Bucket__c != null && u.Charge_7_Bucket__c.containsIgnoreCase('Agreement Value'))
                u.Puchase_Price__c += u.Charge_7_Amount__c;
            unitToBeUpdated.add(u);
        }
        if(unitToBeUpdated != null && unitToBeUpdated.size() > 0)
            update unitToBeUpdated;            
        }
               
        global void finish (Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];

          //Send an email to the User after your batch completes
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'neha.pandey@stetig.in'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Unit Purchase Price updated ' + a.Status);
            mail.setPlainTextBody('The batch Apex job to update unit Purchase Price has processed ' + a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }  
        
        global void execute(SchedulableContext sc) {
          UnitUpdateBatch u = new UnitUpdateBatch (); 
          Database.executebatch(u, 200);
     }      
}
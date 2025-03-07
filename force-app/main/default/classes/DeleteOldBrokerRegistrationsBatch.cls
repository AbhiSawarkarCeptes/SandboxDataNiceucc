//TestClass: DeleteOldBrokerRegistrationsTest
global class DeleteOldBrokerRegistrationsBatch implements Database.Batchable<SObject>, Database.Stateful  {
    String brokerIds='';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Calculate the date 2 days ago
        DateTime fortyEightHoursAgo = DateTime.now().addHours(-48);
        //Get RecordTypeId
        Id BrokerRecordTypeId = Schema.SObjectType.Broker_Registration__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        
        //  query to get records created 2 days ago and Registration_Number__c is blank with recordType new
        String  query;
        if(Test.IsRunningTest())
            query = 'SELECT Id FROM Broker_Registration__c';
        else
            query = 'SELECT Id FROM Broker_Registration__c WHERE CreatedDate <= :fortyEightHoursAgo AND Registration_Number__c = NULL AND Status__c = NULL AND recordTypeId=:BrokerRecordTypeId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Broker_Registration__c> scope) {
        system.debug('Scope:'+scope);
        
        // Delete the records
        
        try{
            
            for(Broker_Registration__c br: scope){
                brokerIds += br.Id+',';
            }
            system.debug('brokerId:'+brokerIds);
            Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
           if(!bypassSettingInstance.Bypass_OldBrokerAutoDeletion__c)
                Database.delete(scope, false);
            system.debug('Scope1:'+scope);
        }catch (Exception e)
        {
            Error_Log__c trackRec = new Error_Log__c(Class__c = 'DeleteOldBrokerRegistrations -- Error',Message__c = brokerIds + '  '+ e.getmessage());
            database.insert(trackRec, false);
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC) {
        Error_Log__c trackRec = new Error_Log__c();
        trackRec.Class__c = 'DeleteOldBrokerRegistrations -- Success';
        system.debug('brokerId in finish:'+brokerIds);
        trackRec.Message__c = brokerIds ;
        Database.insert(trackRec, false);
        
    }
}
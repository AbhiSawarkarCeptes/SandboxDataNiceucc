/* Helper Class for BrokerRegistrationTrgHandler */
public class BrokerRegistrationTrgHelper {

    public static String CLASS_NAME = 'brokerRegistrationTrgHelper';

     /* All Docs uploaded actions */
    Public static void handleAllDocsUploadEvent(List<Broker_Registration__c> brokerRegUpdates) {
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Broker_Registration__c> brokerRegFlagUpdates = new List<Broker_Registration__c>();
        Map<String,String> brEmailRecipientMap = new Map<String,String>();
        List<Error_Log__c> errorLogs = new List<Error_Log__c>();
        
        for (Broker_Registration__c brokerReg : brokerRegUpdates) {
            system.debug('inside for line22'+brokerReg.crmOps__r.Email);
            Broker_Registration__c brokerToUpdate = new Broker_Registration__c(Id = brokerReg.Id);
            brokerToUpdate.Status__c = 'All missing documents uploaded';
            brokerRegFlagUpdates.add(brokerToUpdate);
            brEmailRecipientMap.put(brokerReg.Id, brokerReg.crmOps__c != NULL ? brokerReg.crmOps__r.Email : 'NA' );
            
        }
        
        Database.SaveResult[] flagStampStatus = Database.update(brokerRegFlagUpdates, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : flagStampStatus) {
            
            if (sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    Error_Log__c thisError = new Error_Log__c(Class__c = CLASS_NAME, Message__c = err.getStatusCode() + ': ' + err.getMessage());
                    errorLogs.add(thisError);
                }
            }
        }
        
        if(errorLogs.size() > 0) {
            Database.insert(errorLogs, FALSE);
        }
    }
    
   
}
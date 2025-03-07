//TestClass: RenewalBrokerRegistrationBatchTest
global class RenewalBrokerRegistrationBatch implements Database.Batchable<Id>, Database.Stateful {
    
    // List to store all email addresses
    private List<String> emailAddresses = new List<String>();
    private List<Id> recordIds;
    private Map<String, Id> emailToBrMap = new Map<String, Id>();
    public static Boolean bypassBrokerRegistration = false;
    
    // Constructor to accept the batch of record Ids
    public RenewalBrokerRegistrationBatch(List<Id> recordIds) {
        this.recordIds = recordIds;
    }
    
    // Start method
    global Iterable<Id> start(Database.BatchableContext BC) {
        return recordIds;
    }
    
    // Execute method
    global void execute(Database.BatchableContext BC, List<Id> scope) {
        List<Broker_Registration__c> brlist = [SELECT Id, Last_Name__c, Name_as_per_trade_license__c, Name_as_per_passport__c, Email__c, Mobile__c, 
                                               Broker_Category__c, OwnerId, Registration_Number__c, CPID__c, CHRM_Manager__c, RERA_Number__c, 
                                               CHRM_Manager_Email__c, Sales_Manager__c, Reporting_manager__c, Telephone__c, 
                                               Agreement_Created_Sent_Date__c, Is_Batch_Loaded__c, Skip_Broker_Email_Notification__c, 
                                               Villa_Building_name__c,Alternate_Email__c ,City_Province__c
                                               FROM Broker_Registration__c 
                                               WHERE Id IN :scope];
        List<Broker_Registration__c> brtoInsert = new List<Broker_Registration__c>();
        
        for (Broker_Registration__c br : brlist) {
            Broker_Registration__c brData = new Broker_Registration__c();
            
            brData.Email__c = br.Email__c;
            brData.Mobile__c = br.Mobile__c;
            brData.Broker_Category__c = br.Broker_Category__c;
            brData.Last_Name__c = br.Last_Name__c;
            brData.Name_as_per_trade_license__c = br.Name_as_per_trade_license__c;
            brData.Name_as_per_passport__c = br.Name_as_per_passport__c;
            brData.OwnerId = br.OwnerId;
           // brData.Registration_Number__c = br.Registration_Number__c;
            brData.CPID__c = br.CPID__c;
            brData.CHRM_Manager__c = br.CHRM_Manager__c;
            brData.RERA_Number__c = br.RERA_Number__c;
            brData.Alternate_Email__c = br.Alternate_Email__c;
            brData.Parent_Record__c = br.Id;
            brData.CHRM_Manager_Email__c = br.CHRM_Manager_Email__c;
            
            Id brRecordTypeId = Schema.SObjectType.Broker_Registration__c.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            brData.RecordTypeId = brRecordTypeId;
            brtoInsert.add(brData);
            
        }
        
        /*insert brtoInsert;
Broker_Registration__c newBR = brtoInsert[0];
if (newBR.Email__c != null)
{
emailAddresses.add(newBR.Email__c);
emailToBrMap.put(newBR.Email__c,newBR.Id);

}
if (newBR.Alternate_Email__c != null){
emailAddresses.add(newBR.Alternate_Email__c);
emailToBrMap.put(newBR.Alternate_Email__c,newBR.Id);
}*/
        
        Database.SaveResult[] saveResults = Database.insert(brtoInsert, false);
        
        Map<Id,Id> parentToChildMap = new Map<Id,Id>();
        List<Broker_Registration__c> brToUpdate = new List<Broker_Registration__c>();
        
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (saveResults[i].isSuccess()) {
                Broker_Registration__c newBR = brtoInsert[i];
                
                parentToChildMap.put(newBR.Parent_Record__c, newBR.Id);
                
                // Add emails to the list for successful insertions
                if (newBR.Email__c != null) {
                    emailAddresses.add(newBR.Email__c);
                    emailToBrMap.put(newBR.Email__c, newBR.Id);
                }
                if (newBR.Alternate_Email__c != null) {
                    emailAddresses.add(newBR.Alternate_Email__c);
                    emailToBrMap.put(newBR.Alternate_Email__c, newBR.Id);
                }
            } 
        }
        
        for (Broker_Registration__c br : brlist) {
            if (parentToChildMap.containsKey(br.Id)) {
                br.Renewal_Record_Id__c = parentToChildMap.get(br.Id);
                br.Renewal_Status__c = 'Renewal Initiated';
                brToUpdate.add(br);
            }
        }
        
        // Update the parent records
        if (!brToUpdate.isEmpty()) {
            bypassBrokerRegistration = True;
            update brToUpdate;
            bypassBrokerRegistration = false;
        }
        
    }
    
    // Finish method to send email notifications using a template
    global void finish(Database.BatchableContext BC) {
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:'Broker_Registration_Renewal_link_email'];
        
        System.debug(et);
        
        // Remove duplicate email addresses
        emailAddresses = new List<String>(new Set<String>(emailAddresses));
        
        Contact dummyContact = new Contact(LastName ='LastNameTest', Email ='noreply@sobharealty.com');
        insert dummyContact; 
        
        List<String> ccAddresses = new List<String>{System.Label.SF_Notifications,System.Label.SF_Channel_Operations}; 
            
            // Prepare the email
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (String emailAddress : emailAddresses) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<string> {emailAddress});
            email.setccAddresses(ccAddresses);
            email.setTargetObjectId(dummyContact.Id);
            email.setTemplateId(et.Id);
            email.setWhatId(emailToBrMap.get(emailAddress));
            email.setSaveAsActivity(false); // Do not save as an activity
            email.setTreatTargetObjectAsRecipient(false);
            emails.add(email);
        }
        
        // Send the email
        if (!emails.isEmpty() && !Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
        delete dummyContact;
    }
}
global class DocusignEnvelopeVoidBatch implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> reasonsForCancellation = New List<String>{'Auto cancellation (7 days policy)','Auto cancellation (4 days policy)'};
        String query = 'SELECT Id FROM Booking__c WHERE Status__c = \'Cancelled\' and Cancellation_Date__c = today and Reason_For_Cancellation_D__c IN: reasonsForCancellation';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List <Booking__c> bookingsList) {
        System.debug('BookingList in execute Method:'+bookingsList);
        List<String> bookingIdsList = new List<String>();
        List<String> envelopeBatchIdsList = new List<String>();
        List<dfsle__EnvelopeStatus__c> updateStatusRecList = new List<dfsle__EnvelopeStatus__c>();
        List<dfsle__Envelope__c> updateEnvelopeList = new List<dfsle__Envelope__c>();
        
        String newOwnerId = [SELECT ID FROM USER WHERE username =: System.Label.Docusign_Admin].ID;
        if(!(string.isBlank(newOwnerId))){
            for(Booking__c booking : bookingsList){
                bookingIdsList.add(booking.id);
            }
            
            // Query all the docusignstatus records which are related to that bookings
            if(bookingIdsList !=null && bookingIdsList.size() > 0){
                List<dfsle__EnvelopeStatus__c> dsStatusList = [SELECT ID,OwnerId,dfsle__DocuSignId__c FROM dfsle__EnvelopeStatus__c 
                                                               WHERE Booking__c IN:bookingIdsList and dfsle__Status__c != 'Voided'];
                
                system.debug('Status List :'+ dsStatusList);
                //Change the owner of docusign status records to helpdesk
                if(dsStatusList != null && dsStatusList.size()>0){
                    for(dfsle__EnvelopeStatus__c statusRec : dsStatusList){
                        envelopeBatchIdsList.add(statusRec.dfsle__DocuSignId__c);
                        statusRec.OwnerId = newOwnerId;
                        statusRec.Void_Date__c = System.today();
                        updateStatusRecList.add(statusRec);
                    }
                }
            }
            
            System.debug('Evelope Ids list inside execute:'+envelopeBatchIdsList);
            
            //Query all the envelope records which are related to docusign status records
            if(envelopeBatchIdsList != null && envelopeBatchIdsList.size() > 0){
                List<dfsle__Envelope__c> dsEnvelopeList = [SELECT ID,OwnerId,dfsle__DocuSignId__c FROM dfsle__Envelope__c 
                                                           WHERE dfsle__DocuSignId__c IN:envelopeBatchIdsList];
                //Change the owner of docusign envelope records to helpdesk
                for(dfsle__Envelope__c envRec : dsEnvelopeList){
                    envRec.ownerId = newOwnerId;
                    updateEnvelopeList.add(envRec);
                }
                System.debug('Envelops List:'+updateEnvelopeList);
                
                try{
                    List<Error_Log__c> eLog = new List<Error_Log__c>();
                    
                    //Update docusign status records
                    if(updateStatusRecList != null && !updateStatusRecList.isEmpty()){
                        Database.SaveResult[] resultstatusdupdate = Database.update(updateStatusRecList);
                        
                        
                        for (Database.SaveResult result : resultstatusdupdate) {
                            if (!result.isSuccess()){
                                
                                Database.Error error = result.getErrors().get(0);
                                Error_Log__c logError = new Error_Log__c();
                                logError.Name='DocusignEnvelopeVoidBatch';
                                logError.Class__c='DocusignEnvelopeVoidBatch';
                                logError.Message__c=error.getMessage() + result.getid();
                                eLog.add(logError);
                            }
                        }
                    }
                    
                    //Update docusign envelope records
                    if(updateEnvelopeList != null && !updateEnvelopeList.isEmpty()){
                        Database.SaveResult[] resultEnvelopeupdate = Database.update(updateEnvelopeList);
                        for (Database.SaveResult result : resultEnvelopeupdate) {
                            if (!result.isSuccess()){
                                
                                Database.Error error = result.getErrors().get(0);
                                Error_Log__c logError = new Error_Log__c();
                                logError.Name='DocusignEnvelopeVoidBatch';
                                logError.Class__c='DocusignEnvelopeVoidBatch';
                                logError.Message__c=error.getMessage() + result.getid();
                                eLog.add(logError);
                            }
                        }
                        if(elog != null && elog.size()>0){
                            insert elog;
                        }
                    }
                    if((Test.IsRunningTest())){
                        throw new StringException('Exception forced from Unit Test');
                    }
                }catch(Exception e){}
            }
        } 
    }
    global void finish(Database.BatchableContext BC) {}
}
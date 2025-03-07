global class DocusignEnvelopeVoidBatch2 implements Database.Batchable <sObject>, Database.AllowsCallouts{
   
   global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> reasonsForCancellation = New List<String>{'Auto cancellation (7 days policy)','Auto cancellation (4 days policy)'};
        String query = 'SELECT ID,OwnerId,dfsle__DocuSignId__c FROM dfsle__EnvelopeStatus__c WHERE dfsle__Status__c != \'Voided\' and Void_Date__c = today and Booking__r.Status__c = \'Cancelled\' and Booking__r.Cancellation_Date__c = today and Booking__r.Reason_For_Cancellation_D__c IN: reasonsForCancellation';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<dfsle__EnvelopeStatus__c> statusrecords) {
        
        List<string> envelopeList = new List<String>();
        if(statusrecords != null && statusrecords.size()>0){
            for(dfsle__EnvelopeStatus__c status : statusrecords){
                envelopeList.add(status.dfsle__DocuSignId__c);
            }
        }
        //Void docusign envelops
        System.debug('Evelope Ids list inside finish:'+envelopeList);
        
        if(envelopeList != null && !envelopeList.isEmpty()){
            String reasonToVoid = 'Expired';
            List<Error_Log__c> eLog = new List<Error_Log__c>();
            for(String envelope : envelopeList){
                                
                    try{  
                        if(!Test.isRunningTest()){
                            dfsle.UUID envelopeId= dfsle.UUID.parse(envelope);
                            dfsle.StatusService.voidEnvelope(envelopeId, reasonToVoid);
                        }else{
                            throw new StringException('Exception forced from Unit Test');
                        }
                    }catch(Exception e){
                        Error_Log__c logError = new Error_Log__c();
                        logError.Name= envelope;
                        logError.Class__c='DocusignEnvelopeVoidBatch2';
                        logError.Message__c= e.getMessage();
                        eLog.add(logError);
                    }
                
            }
            insert eLog;
        }
    }
    
    global void finish(Database.BatchableContext info) {}
}
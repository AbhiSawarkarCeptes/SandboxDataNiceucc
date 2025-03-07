public class LegacyBookingTranRequestBatch implements Database.Batchable<sObject>,Database.Stateful
{
    public Set<Id> tranRequestIds; 
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
       tranRequestIds= New Set<Id>();
       String query='Select Id, Name, dfsle__Status__c, dfsle__SourceId__c, dfsle__DocuSignId__c, Booking__c , Application_Booking__c, Envelope_Type__c  from dfsle__EnvelopeStatus__c  where Transaction_Request__c=null and Booking__c<>null and Envelope_Type__c=\'SPA\'';
       //String query='Select Id, Name, dfsle__Status__c, dfsle__SourceId__c, dfsle__DocuSignId__c, Booking__c , Application_Booking__c, Envelope_Type__c  from dfsle__EnvelopeStatus__c  where Transaction_Request__c=null and Booking__c<>null and Envelope_Type__c=\'SPA\' and Booking__c in (\'a062o00001pev5eAAA\',\'a067S000003K8QRQA0\',\'a067S000000WKvAQAW\',\'a067S000003EMvYQAW\',\'a06TX000005ClgFYAS\') Order By Name';
       return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<dfsle__EnvelopeStatus__c> docuSignEnvelopList)
    {
       Set<Id> legacyIds = New Set<Id>();
       Map<String, Id> legacyMap = New Map<String, Id>();
        List<PropStrength__Transaction_Requests__c> requestList = New List<PropStrength__Transaction_Requests__c>();
       for(dfsle__EnvelopeStatus__c des1 : docuSignEnvelopList)   
        {
           if(des1.Booking__c <> null)
           {
              legacyIds.add(des1.Booking__c);
           }
        }
       if(!legacyIds.isEmpty())
       {
          for (PropStrength__Application_Booking__c  newrecord : [Select Id,Legacy_Booking_Id__c from PropStrength__Application_Booking__c where Legacy_Booking_Id__c in :legacyIds])
       		{
                legacyMap.put(newrecord.Legacy_Booking_Id__c, newrecord.Id); 
       		}
       }
       for(dfsle__EnvelopeStatus__c des2 : docuSignEnvelopList)   
        {
            System.debug('Hitesh: '+des2.Name);
            PropStrength__Transaction_Requests__c newTransreq = new PropStrength__Transaction_Requests__c();
            newTransreq.RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
            //Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
            newTransreq.PropStrength__Application_Booking__c=legacyMap.get(des2.Booking__c);
            newTransreq.DocuSign_Status__c=des2.Id;
            if(des2.dfsle__Status__c=='Completed')
            {
              newTransreq.PropStrength__Status__c='SPA Executed';  
            }
            else
            If(des2.dfsle__Status__c=='Sent')
            {
              newTransreq.PropStrength__Status__c='SPA Sent to customer for Digital Signature';  
            }
            else
            {
              newTransreq.PropStrength__Status__c='Voided';   
            }
            requestList.add(newTransreq);
        }
        if(!requestList.isEmpty())
        {
            //insert requestList;
            Database.SaveResult[] results = Database.insert(requestList, true);
            // Iterate through each returned result
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess())
                {
                    System.debug('Successfully inserted Transaction Requests. TransReq ID: ' + sr.getId());
                    tranRequestIds.add(sr.getId());
                }
                else{
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
      
    }
    public void finish(Database.BatchableContext BC)
    {
      System.debug('Finishes Transaction Request Creation and calling next Batch');
       if(!tranRequestIds.isEmpty())
       {
           database.executebatch(New LegacyTransReqDocuSignBatch(tranRequestIds));

       }
    }
}
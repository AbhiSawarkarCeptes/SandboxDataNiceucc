public class LegacyTransReqDocuSignBatch implements Database.Batchable<sObject>
{
    Set<Id> transIds= new Set<Id>();
    public LegacyTransReqDocuSignBatch(Set<Id> Ids)
    {
        this.transIds=Ids;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
       System.debug('LegacyTransReqDocuSignBatch - Start Menthod');
       String query='Select Id, DocuSign_Status__c, DocuSign_Status__r.Name, DocuSign_Status__r.dfsle__Status__c, DocuSign_Status__r.dfsle__SourceId__c, DocuSign_Status__r.dfsle__DocuSignId__c, DocuSign_Status__r.Booking__c , PropStrength__Application_Booking__c , DocuSign_Status__r.Envelope_Type__c  from PropStrength__Transaction_Requests__c  where PropStrength__Application_Booking__c <> null and DocuSign_Status__c <> null and RecordType.Name=\'SPA Process\' and Id in :transIds order by DocuSign_Status__r.Name';
       return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<PropStrength__Transaction_Requests__c> transReqList)
    {
        System.debug('LegacyTransReqDocuSignBatch - Execute Menthod');
        Map<String, Id> envelopTranMap = New Map<String, Id>();
        List<dfsle__Envelope__c> migrateEnvelopList = new List<dfsle__Envelope__c>();
        List<dfsle__EnvelopeStatus__c> migrateLegacyList = new List<dfsle__EnvelopeStatus__c>();
        List<Docusign_Recipient_Status_Sobha__c> migrateDRSSList = new List<Docusign_Recipient_Status_Sobha__c>();
        Map<String, Id> legacyMap = New Map<String, Id>();
        Map<String,Id> tranDocuStatMap = New Map<String,Id>();
        for(PropStrength__Transaction_Requests__c tra : transReqList)   
        {
           if(tra.DocuSign_Status__r.Booking__c <> null)
           {
              System.debug('Legacy Booking Id- '+tra.DocuSign_Status__r.Booking__c);
              System.debug(tra.DocuSign_Status__r.dfsle__DocuSignId__c);
              tranDocuStatMap.Put(tra.DocuSign_Status__r.Name, tra.Id);
              envelopTranMap.Put(tra.DocuSign_Status__r.dfsle__DocuSignId__c, tra.Id);
              legacyMap.put(tra.DocuSign_Status__r.Booking__c, tra.Id);
           }
        }
       
       if(!envelopTranMap.isEmpty())
       {
         for(dfsle__Envelope__c envlp : [Select Id, dfsle__SourceId__c,dfsle__DocuSignId__c  from dfsle__Envelope__c where dfsle__DocuSignId__c in :envelopTranMap.KeySet()])
         {
           System.debug('Hitesh Preparing to Update Envelops- '+envlp.dfsle__SourceId__c);
           envlp.dfsle__SourceId__c=envelopTranMap.get(envlp.dfsle__DocuSignId__c);
           migrateEnvelopList.add(envlp);
         }
       }
       if(!migrateEnvelopList.isEmpty())
       {
          System.debug('Hitesh Update Envelop');
          Update migrateEnvelopList; 
       }
        
       if(!legacyMap.isEmpty())
       {
           for(dfsle__EnvelopeStatus__c des2 : [Select Id, Name, Transaction_Request__c, dfsle__SourceId__c, Booking__c from dfsle__EnvelopeStatus__c where Name in :tranDocuStatMap.keySet()])
           {
            if(des2.Booking__c <> null)
            {
                System.debug('Hitesh Preparing to Update docuSign Status-'+legacyMap.get(des2.Booking__c));
                Id newRecordId=tranDocuStatMap.get(des2.Name);
                des2.Transaction_Request__c =newRecordId;
                des2.dfsle__SourceId__c=String.valueof(newRecordId);
            	migrateLegacyList.add(des2);
            }
           }
       }
        If(!migrateLegacyList.isEmpty())
        {
            System.debug('Hitesh Update docusign status');
            update migrateLegacyList;
        }
            
        if(!legacyMap.isEmpty())
        {
            for(Docusign_Recipient_Status_Sobha__c drss : [Select Id, Transaction_Request__c, Booking__c from Docusign_Recipient_Status_Sobha__c where Booking__c in :legacyMap.keySet()])
          		{
                    System.debug('Hitesh preparing to Update docuSign sobha records');
            		drss.Transaction_Request__c=legacyMap.get(drss.Booking__c);
            		migrateDRSSList.add(drss);  
          		}
        }
        If(!migrateDRSSList.isEmpty())
        {
            System.debug('Hitesh Update docuSign sobha records');
            update migrateDRSSList;
        }
    }
    
    public void finish(Database.BatchableContext BC)
    {
      System.debug('LegacyTransReqDocuSignBatch - Finish Menthod');  
    }

}
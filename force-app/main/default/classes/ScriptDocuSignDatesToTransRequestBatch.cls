public class ScriptDocuSignDatesToTransRequestBatch implements Database.Batchable<sObject> 
{
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        System.debug('ScriptDocuSignDatesToTransRequestBatch - Start Menthod');
        //String query='SELECT Id, DocuSign_Status__c, DocuSign_Status__r.dfsle__Completed__c, DocuSign_Status__r.dfsle__Sent__c, DocuSign_Status__r.dfsle__Status__c, SPA_Sent_to_Customer_for_Digi_Sign_Date__c, SPA_Sent_for_Audit_Verification_Date__c, SPA_Verified_by_Audit_Date__c, SPA_Signed_by_Authorised_Signatory_Date__c, SPA_Execution_Date__c from PropStrength__Transaction_Requests__c where DocuSign_Status__c <> null and Id IN (\'a6dba0000000yU2\',\'a6dba0000000yU3\',\'a6dba0000000yU1\')';
        String query='SELECT Id, DocuSign_Status__c, DocuSign_Status__r.dfsle__Completed__c, DocuSign_Status__r.dfsle__Sent__c, DocuSign_Status__r.dfsle__Status__c, SPA_Sent_to_Customer_for_Digi_Sign_Date__c, SPA_Sent_for_Audit_Verification_Date__c, SPA_Verified_by_Audit_Date__c, SPA_Signed_by_Authorised_Signatory_Date__c, SPA_Execution_Date__c from PropStrength__Transaction_Requests__c where DocuSign_Status__c <> null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<PropStrength__Transaction_Requests__c> transReqList) 
    {
        System.debug('ScriptDocuSignDatesToTransRequestBatch - Execute Menthod');
        List<PropStrength__Transaction_Requests__c> updateTranReqList = New List<PropStrength__Transaction_Requests__c>();
        Map<Id, List<dfsle__RecipientStatus__c>> transDocRecStatusMap = New Map<Id, List<dfsle__RecipientStatus__c>>();
        Map<Id, PropStrength__Transaction_Requests__c> transReqMap = new Map<Id, PropStrength__Transaction_Requests__c>(transReqList);
        //dfsle__EnvelopeStatus__c(dfsle__Sent__c)
        for(dfsle__RecipientStatus__c recStatus : [Select Id, Name, dfsle__Status__c,dfsle__EnvelopeStatus__r.Transaction_Request__c, dfsle__EnvelopeStatus__r.dfsle__Status__c,dfsle__Email__c, dfsle__EnvelopeStatus__c, dfsle__EnvelopeStatus__r.dfsle__Sent__c,dfsle__EnvelopeStatus__r.dfsle__Completed__c,dfsle__Sent__c,dfsle__Completed__c from dfsle__RecipientStatus__c where dfsle__EnvelopeStatus__r.Transaction_Request__c in :transReqMap.KeySet()])
        {
            if(transDocRecStatusMap.containsKey(recStatus.dfsle__EnvelopeStatus__c)) {
                List<dfsle__RecipientStatus__c> docRecStaList = transDocRecStatusMap.get(recStatus.dfsle__EnvelopeStatus__c);
                docRecStaList.add(recStatus);
                transDocRecStatusMap.put(recStatus.dfsle__EnvelopeStatus__c, docRecStaList);
                } else {
                    transDocRecStatusMap.put(recStatus.dfsle__EnvelopeStatus__c, new List<dfsle__RecipientStatus__c> {recStatus});
                }
        }
        for(PropStrength__Transaction_Requests__c pTranReq : transReqList)
        {
            if(transDocRecStatusMap.containsKey(pTranReq.DocuSign_Status__c)) 
            {
               pTranReq.SPA_Sent_to_Customer_for_Digi_Sign_Date__c=pTranReq.DocuSign_Status__r.dfsle__Sent__c;
               If(pTranReq.DocuSign_Status__r.dfsle__Status__c=='Completed')
               {
                pTranReq.SPA_Execution_Date__c= pTranReq.DocuSign_Status__r.dfsle__Completed__c;
               }
               for(dfsle__RecipientStatus__c recSta : transDocRecStatusMap.get(pTranReq.DocuSign_Status__c))
               {
                   If(recSta.Name=='Audit Team')
                   {
                       pTranReq.SPA_Sent_for_Audit_Verification_Date__c=recSta.dfsle__Sent__c;
                       pTranReq.SPA_Verified_by_Audit_Date__c=recSta.dfsle__Completed__c;
                   }
                   If(recSta.Name=='Anuj Jain' && recSta.dfsle__Status__c=='Completed')
                   {
                       pTranReq.SPA_Signed_by_Authorised_Signatory_Date__c=recSta.dfsle__Completed__c;
                   } 
               }
              updateTranReqList.add(pTranReq);
            } 
        }
        If(!updateTranReqList.isEmpty())
        {
            Update updateTranReqList;
        }
    }
    public void finish(Database.BatchableContext BC) 
    {
        System.debug('ScriptDocuSignDatesToTransRequestBatch - Finish Menthod');  
    }
}
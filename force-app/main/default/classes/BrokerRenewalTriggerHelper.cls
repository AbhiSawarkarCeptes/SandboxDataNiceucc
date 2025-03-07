public without sharing class BrokerRenewalTriggerHelper {
    public static void sendNocForFinalSignature(List<Broker_Renewal__c> renewList, Map<Id, Broker_Renewal__c> oldRenewMap) {
        for(Broker_Renewal__c renewRec : renewList) {
            if( (renewRec.Broker_Approval_Status__c == 'Pending with Ashish Parakh/ Sent for final signatures' || 
               renewRec.Broker_Approval_Status__c == 'Sent for Final Signatures' )&& renewRec.Broker_Approval_Status__c != oldRenewMap.get(renewRec.Id).Broker_Approval_Status__c) {
                BrokerRenewalNocDocusignHandler.forForSigningFuture(renewRec.Id);
            }
        }
    }
    
    public static void sendNocForAuditApprovalProcess(List<Broker_Renewal__c> renewList, Map<Id, Broker_Renewal__c> oldRenewMap) {
        List<Broker_Renewal__c> renewListForApproval = new List<Broker_Renewal__c>();
        for(Broker_Renewal__c renewRec : renewList) {
            if(renewRec.NOC_Generated__c && renewRec.Broker_Approval_Status__c == 'NOC Generated' && renewRec.Broker_Approval_Status__c != oldRenewMap.get(renewRec.Id).Broker_Approval_Status__c) {
                renewListForApproval.add(renewRec);
            }
        }
        if(!renewListForApproval.isEmpty()) {
            for(Broker_Renewal__c rec : renewListForApproval) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('NOC for audit approval when NOC Pending with Audit');
                req1.setObjectId(rec.Id);
                req1.setSubmitterId(rec.ownerId);
                req1.setProcessDefinitionNameOrId('NOC_Audit_Approval1');
                req1.setSkipEntryCriteria(false);  
                // Line commented By Gourav Gour 8/8/2024 
              //  Approval.ProcessResult result = Approval.process(req1);
            }
        }
    }
    //Added by Gourav gour on 24/05/2024 to update status as per checkboxes
    public static void updateStatus(List<Broker_Renewal__c> renewList, Map<Id, Broker_Renewal__c> oldRenewMap) {
        for(Broker_Renewal__c renew : renewList) {
            if(renew.All_Documents_Uploaded__c && renew.All_Documents_Uploaded__c != oldRenewMap.get(renew.Id).All_Documents_Uploaded__c) {
                renew.Broker_Approval_Status__c = 'All Missing Documents Uploaded';
            }
            if(renew.All_Mandatory_Documents__c && renew.All_Mandatory_Documents__c != oldRenewMap.get(renew.Id).All_Mandatory_Documents__c) {
                //renew.Broker_Approval_Status__c = 'Agreement Is in process';
            }
        }
    }
}
public with sharing class BrokerLedgerDocusignUtilClone  {
    
    public static PropStrength__Broker_Ledger__c getLedger(Id ledgerId) {
        PropStrength__Broker_Ledger__c ledger = [Select id,PropStrength__Broker_Account__c,PropStrength__Broker_Account__r.Email_ID_1__c ,
                                                 PropStrength__Broker_Account__r.Name,Unit_No__c,Channel_Relationship_Manager__c,
                                                 Brokerage_Due_Percentage__c
                                                 FROM PropStrength__Broker_Ledger__c 
                                                 WHERE id=:ledgerId LIMIT 1];
        return ledger;
    }
    
    
    public static void docusignPostProcessing(String envelopeId, 
                                              Id ledgerId, 
                                              Id myDocumentId, 
                                              Map<String,String> emailToRoleMap) {
                                                  
                                                  List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c
                                                                                                       From dfsle__EnvelopeStatus__c
                                                                                                       Where dfsle__DocuSignId__c=:envelopeId];
                                                  
                                                  if (docusignStatusList.size() > 0) {
                                                      dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
                                                      ds.Envelope_Type__c = 'Invoice';
                                                      ds.Broker_Ledger__c = ledgerId;
                                                      update ds;
                                                      
                                                      List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
                                                      List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__RoutingOrder__c,Broker_Account__c,
                                                                                                                     dfsle__Email__c,Envelope_Type__c,
                                                                                                                     Envelope_Recipient_Type__c 
                                                                                                                     From dfsle__RecipientStatus__c
                                                                                                                     Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];
                                                      
                                                      Integer i = 1;
                                                      for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) {
                                                          String drsKey=rs.dfsle__Email__c+'_'+rs.dfsle__RoutingOrder__c;
                                                          System.debug('key is:====> '+drsKey);
                                                          
                                                          if (emailToRoleMap.containsKey(drsKey)) {
                                                              rs.Broker_Ledger__c = ledgerId; 
                                                              rs.Envelope_Recipient_Type__c = emailToRoleMap.get(drsKey);
                                                              rs.Envelope_Type__c = 'Invoice';
                                                              System.debug('Standard DRS records for Booking: '+rs);
                                                              rsToUpdateList.add(rs);
                                                          }
                                                          i += 1;
                                                      }                                                       
                                                      update rsToUpdateList;
                                                      system.debug(rsToUpdateList);
                                                  }
                                              }
}
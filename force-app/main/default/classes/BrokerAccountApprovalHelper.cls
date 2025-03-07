/*********************************************************************
 * Trigger Name  :   BrokerAccountApprovalHelper
 * Created Date:    30/05/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :  Gourav Gour 30/05/2024
 *********************************************************************/
public class BrokerAccountApprovalHelper {
    public static void updateFieldOnBroker(List<Broker_Account_Approval_History__c> triggerNewList, Map<Id, Broker_Account_Approval_History__c> oldMapData){
        try{
            Map<Id, Account> brokerUpdateMap = new Map<Id, Account>();
            for(Broker_Account_Approval_History__c brar: triggerNewList){
                if(brar.Status__c == 'Completed' && brar.Status__c != oldMapData.get(brar.Id).Status__c){
                   if(brokerUpdateMap.containsKey(brar.Broker_Account__c)){
                       Account tempBr = brokerUpdateMap.get(brar.Broker_Account__c);
                       tempBr.put(brar.API_Name__c, brar.New_Value__c);
                       brokerUpdateMap.put(brar.Broker_Account__c, tempBr);
                   } else {
                       Account breg = new Account(); 
                   	   breg.put(brar.API_Name__c, brar.New_Value__c);
                       breg.put('Id', brar.Broker_Account__c);
                       brokerUpdateMap.put(brar.Broker_Account__c, breg);
                   }
                }
            }
            if(brokerUpdateMap.values().size()>0){
                update brokerUpdateMap.values();
            }
        }  catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}
public class BrokerRegFieldUpdateReqController {
    
	@AuraEnabled
    public static List<Broker_Registration_Field_Update_Request__mdt> getCustomeMetadatConfig(String fieldUpdateType){
        return [Select id, MasterLabel, API_Name__c, Field_Type__c from Broker_Registration_Field_Update_Request__mdt where Update_Type__c=:fieldUpdateType];
    }

    @AuraEnabled
    public static List<Broker_Registration_Field_Upd_Request2__mdt> getCustomeMetadatConfigAcc(String fieldUpdateType){
        return [Select id, MasterLabel, API_Name__c, Field_Type__c from Broker_Registration_Field_Upd_Request2__mdt where Update_Type__c=:fieldUpdateType];
    }

    @AuraEnabled
    public static String getAccountId(String recId){
        return [Select id, Broker_Account__c from Broker_Registration__c where Id=:recId].Broker_Account__c;
    }
    
    @AuraEnabled
    public static List<Broker_Registration_Approval_Request__c> insertRequestData(List<Broker_Registration_Approval_Request__c> insertList){
        try{insert insertList;Broker_Registration__c breg = new Broker_Registration__c();breg.Id = insertList[0].Broker_Registration__c;breg.Field_Update_Request_Status__c = 'Pending With CHRM OPS Manager';breg.Field_Update_Requested_By__c = UserInfo.getUserId();breg.Field_Update_Type__c = insertList[0].Field_Update_Type__c;update breg;Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();req.setComments('Please Approve Field Update Approval Request.');req.setNextApproverIds(new Id[] {UserInfo.getUserId()});Approval.ProcessResult result = Approval.process(req);return insertList;} catch (Exception e) {System.debug(e.getMessage());System.debug(e.getStackTraceString());    throw new AuraHandledException(e.getMessage());}
    }
    
    public static void updateFieldOnBroker(List<Broker_Registration_Approval_Request__c> triggerNewList){
        try{Map<Id, Broker_Registration__c> brokerUpdateMap = new Map<Id, Broker_Registration__c>();for(Broker_Registration_Approval_Request__c brar: triggerNewList){if(brar.Status__c=='Completed'){if(brokerUpdateMap.containsKey(brar.Broker_Registration__c)){Broker_Registration__c tempBr = brokerUpdateMap.get(brar.Broker_Registration__c);tempBr.put(brar.API_Name__c, brar.New_Value__c);brokerUpdateMap.put(brar.Broker_Registration__c, tempBr);} else {Broker_Registration__c breg = new Broker_Registration__c(); breg.put(brar.API_Name__c, brar.New_Value__c);breg.put('Id', brar.Broker_Registration__c);brokerUpdateMap.put(brar.Broker_Registration__c, breg);}}}List<Broker_Registration__c> brokerToUpdate = brokerUpdateMap.values();if(brokerToUpdate.size()>0){update brokerToUpdate;}
        }  catch (Exception e) {System.debug(e.getMessage());}
    }

    public static void updateFieldOnBrokerAccount(List<Broker_Registration_Approval_Request__c> triggerNewList, Map<Id, Broker_Registration_Approval_Request__c> newTrgMap){
        try{triggerNewList = [SELECT Id, Broker_Account__c, API_Name__c, New_Value__c, Status__c FROM Broker_Registration_Approval_Request__c WHERE Id IN :newTrgMap.keySet()];Map<Id, Account> brokerUpdateMap = new Map<Id, Account>();for(Broker_Registration_Approval_Request__c brar: triggerNewList){if(brar.Status__c=='Completed'){if(brokerUpdateMap.containsKey(brar.Broker_Account__c)){Account tempBr = brokerUpdateMap.get(brar.Broker_Account__c);tempBr.put(brar.API_Name__c, brar.New_Value__c);brokerUpdateMap.put(brar.Broker_Account__c, tempBr);} else {Account breg = new Account(); breg.put(brar.API_Name__c, brar.New_Value__c);breg.put('Id', brar.Broker_Account__c);brokerUpdateMap.put(brar.Broker_Account__c, breg);}}}
			List<Account> brokerToUpdate = brokerUpdateMap.values();if(brokerToUpdate.size()>0){update brokerToUpdate;}}  catch (Exception e) {System.debug(e.getMessage());
        }
    }
}
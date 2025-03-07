public with sharing class BrokerAccountFieldUpdateReqController {
    @AuraEnabled
    public static List<Broker_Account_Field_Update__mdt> getCustomeMetadatConfig(String fieldUpdateType){
        return [SELECT Id, MasterLabel, API_Name__c, Field_Type__c FROM Broker_Account_Field_Update__mdt WHERE Update_Type__c=:fieldUpdateType];
    }
    
    @AuraEnabled
    public static List<Broker_Account_Approval_History__c> insertRequestData(List<Broker_Account_Approval_History__c> insertList){
        try{
            insert insertList;
            Account breg = new Account();
            breg.Id = insertList[0].Broker_Account__c;
            breg.Field_Update_Request_Status__c = 'Pending With CHRM OPS Manager';
            breg.Field_Update_Requested_By__c = UserInfo.getUserId();
            breg.Field_Update_Type__c = insertList[0].Field_Update_Type__c;
            update breg;
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setProcessDefinitionNameOrId('Broker_Registration_Field_Update_Request');
            req.setSkipEntryCriteria(false);
            req.setComments('Please Approve Field Update Approval Request.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(insertList[0].Broker_Account__c);
            Approval.ProcessResult result = Approval.process(req);
            
            return insertList;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}
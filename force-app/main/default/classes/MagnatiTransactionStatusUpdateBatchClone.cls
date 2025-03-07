/*********************************************************************
 * Class Name  :   MagnatiTransactionStatusUpdateBatchClone
 * Description :   Update CCAveune payment to Magnati Payment - Batch class for Retry Mechanism
 * Created Date:   17/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 17/01/2024
 *********************************************************************/
public with sharing class MagnatiTransactionStatusUpdateBatchClone implements Database.Batchable<SObject>, Database.Stateful{
    public Static String updatedFrom = 'Update Status';
    private Integer timeDelay = 0;
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id FROM Payment_Request_Wrapper__c WHERE Is_Make_Payment_Clicked__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Payment_Request_Wrapper__c> wrapperList) {
        try{
            updatedFrom = 'Retry batch';
            updatePaymentStatus(wrapperList[0].Id);
        } catch (Exception ex){
            Error_Log__c log = new Error_Log__c();
            log.Class__c = 'MagnatiTransactionStatusUpdateBatchClone';
            log.Name = 'Error is get payment status batch';
            log.Message__c = ex.getMessage();
            insert log;
        }
    }

    public void finish(Database.BatchableContext context) {

    }

    //Added by Nishank Manwani on 17/01/2024 to Get History List for Status Fetch and Update Status
    public void updatePaymentStatus(String prwId){
        List<Magnati_Transaction_History__c> historyList = new List<Magnati_Transaction_History__c>();
        historyList = [SELECT Id, TransactionID__c, Payment_Request_Wrapper__r.Email__c,
                              Payment_Request_Wrapper__r.Customer_Name__c, Payment_Request_Wrapper__r.Mobile_Number__c
                       FROM Magnati_Transaction_History__c
                       WHERE Payment_Request_Wrapper__c = :prwId AND Status_Fetched__c = false
                       ORDER BY CreatedDate DESC];
        if(!historyList.isEmpty()){
            MagnatiTransactionStatusUpdQueuableCopy queueableInstance = new MagnatiTransactionStatusUpdQueuableCopy(0, prwId, historyList, updatedFrom);
            System.enqueueJob(queueableInstance, this.timeDelay);
            this.timeDelay = this.timeDelay + 1;
        } else {
            List<Payment_Request__c> requestList = new List<Payment_Request__c>();
            requestList = [SELECT Id, Payment_Link_Status__c, Payment_Request_Wrapper__r.Payment_Link_Expiry__c
                           FROM Payment_Request__c WHERE Payment_Request_Wrapper__c = :prwId];
            for(Payment_Request__c requestInst :requestList){
                if(requestInst.Payment_Link_Status__c == 'Active' && requestInst.Payment_Request_Wrapper__r.Payment_Link_Expiry__c < System.now()){
                    requestInst.Payment_Link_Status__c = 'Expired';
                }
            }
            update requestList;
            Payment_Request_Wrapper__c wrapperInst = new Payment_Request_Wrapper__c();
            wrapperInst.Id = prwId;
            Integer count = [SELECT COUNT() FROM Magnati_Transaction_History__c WHERE Payment_Request_Wrapper__c = :prwId AND Status_Fetched__c = false];
            wrapperInst.Is_Make_Payment_Clicked__c = count > 0 ? true : false;
            update wrapperInst;
        }
    }
}
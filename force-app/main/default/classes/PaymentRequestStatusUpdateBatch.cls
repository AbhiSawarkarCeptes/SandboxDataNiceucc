global class PaymentRequestStatusUpdateBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts  {
    
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new PaymentRequestStatusUpdateBatch(), 1);
    }
    
    global Database.Querylocator start(Database.BatchableContext bc){
       
        String soqlQuery = 'Select Id from Payment_Request__c Where createddate = today and Payment_Status__c = null and Payment_Request_Wrapper__r.Payment_Order_Number__c != null';
        System.debug('>>>> soqlQuery ' + soqlQuery);
        return Database.getQuerylocator(soqlQuery);
    } 
    
    global void execute(Database.BatchableContext bc, List<Payment_Request__c> scope){
        PaymentPublicPageController.getCCAvenuePaymentStatus(scope[0].Id);
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
}
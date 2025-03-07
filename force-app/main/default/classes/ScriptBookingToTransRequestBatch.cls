public class ScriptBookingToTransRequestBatch implements Database.Batchable<sObject>
{
     public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        System.debug('ScriptBookingToTransRequestBatch - Start Menthod');
        String query='Select Id, Name, SPA_Executed_Date__c, SPA_Addendum_Executed_Date__c, SPA_Addendum_Sent_Date__c, SPA_Addendum_Sent_to_Audit_Date__c, SPA_Issue_Date__c, SPA_Receive_Date__c, SPA_Sent_Date__c, SPA_Sent_to_Audit_Date__c, SPA_signed_by_Seller_date__c,SPA_Sent_Through__c, SPA_Courier_Tracking_No__c, SPA_Addendum_Status__c, SPA_Remarks__c, SPA_Audit_rejection_comments__c,Received_SPA_Particular_sent_recev_date__c, Executed_Copy_Sent_Date__c, Executed_Copy_Sent_Through__c,Executed_Copy_Courier_Tracking_No__c, SPA_Particulars__c, Stage_Of_SPA_Execution__c, SPA_Executed__c from Booking__c';
        //String query='Select Id, Name, SPA_Executed_Date__c, SPA_Addendum_Executed_Date__c, SPA_Addendum_Sent_Date__c, SPA_Addendum_Sent_to_Audit_Date__c, SPA_Issue_Date__c, SPA_Receive_Date__c, SPA_Sent_Date__c, SPA_Sent_to_Audit_Date__c, SPA_signed_by_Seller_date__c,SPA_Sent_Through__c, SPA_Courier_Tracking_No__c, SPA_Addendum_Status__c, SPA_Remarks__c, SPA_Audit_rejection_comments__c,Received_SPA_Particular_sent_recev_date__c, Executed_Copy_Sent_Date__c, Executed_Copy_Sent_Through__c,Executed_Copy_Courier_Tracking_No__c, SPA_Particulars__c, Stage_Of_SPA_Execution__c, SPA_Executed__c from Booking__c where Id in (\'a062o00001pev5eAAA\',\'a067S000003K8QRQA0\',\'a067S000000WKvAQAW\',\'a067S000003EMvYQAW\',\'a06TX000005ClgFYAS\')';																				
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Booking__c> legaBookList) 
    {
       System.debug('ScriptBookingToTransRequestBatch - Execute Menthod');
       List<Id> legBookId = New List<Id>();
       Map<Id, Booking__c> legBookMap = New Map<Id, Booking__c>(legaBookList);
       List<PropStrength__Transaction_Requests__c> updateTranReqLst = new List<PropStrength__Transaction_Requests__c>();
       If(!legBookMap.isEmpty())
       {
           for(PropStrength__Transaction_Requests__c prTranRequest : [Select Id, Name, PropStrength__Application_Booking__r.Legacy_Booking_Id__c, 
                                      PropStrength__Application_Booking_Id__c, SPA_Execution_Date__c, SPA_Addendum_Executed_Date__c, SPA_Addendum_Sent_Date__c, 
                                      SPA_Addendum_Sent_to_Audit_Date__c, SPA_Issue_Date__c, SPA_Receive_Date__c, SPA_Sent_to_Customer_for_Digi_Sign_Date__c, 
                                      SPA_Sent_for_Audit_Verification_Date__c, SPA_Signed_by_Authorised_Signatory_Date__c, SPA_Sent_Through__c, 
                                      SPA_Courier_Tracking_No__c, SPA_Addendum_Status__c, SPA_Remarks__c from PropStrength__Transaction_Requests__c 
                                      where PropStrength__Application_Booking__r.Legacy_Booking_Id__c in :legBookMap.keySet() order by Name desc])
           {
              If(legBookId.contains(prTranRequest.PropStrength__Application_Booking__r.Legacy_Booking_Id__c))
              {
                  system.debug('Already populated');
              }
               else
               {
                  legBookId.add(prTranRequest.PropStrength__Application_Booking__r.Legacy_Booking_Id__c);
                  Booking__c legBook=legBookMap.get(prTranRequest.PropStrength__Application_Booking__r.Legacy_Booking_Id__c);
                  prTranRequest.SPA_Execution_Date__c=legBook.SPA_Executed_Date__c;
                  prTranRequest.SPA_Addendum_Executed_Date__c=legBook.SPA_Addendum_Executed_Date__c;
                  prTranRequest.SPA_Addendum_Sent_Date__c=legBook.SPA_Addendum_Sent_Date__c;
                  prTranRequest.SPA_Addendum_Sent_to_Audit_Date__c=legBook.SPA_Addendum_Sent_to_Audit_Date__c;
                  prTranRequest.SPA_Issue_Date__c=legBook.SPA_Issue_Date__c;
                  prTranRequest.SPA_Receive_Date__c=legBook.SPA_Receive_Date__c;
                  prTranRequest.SPA_Sent_to_Customer_for_Digi_Sign_Date__c=legBook.SPA_Sent_Date__c;
                  prTranRequest.SPA_Sent_for_Audit_Verification_Date__c=legBook.SPA_Sent_to_Audit_Date__c;
                  prTranRequest.SPA_Signed_by_Authorised_Signatory_Date__c=legBook.SPA_signed_by_Seller_date__c;
                  prTranRequest.SPA_Sent_Through__c=legBook.SPA_Sent_Through__c;
                  prTranRequest.SPA_Courier_Tracking_No__c=legBook.SPA_Courier_Tracking_No__c;
                  prTranRequest.SPA_Addendum_Status__c=legBook.SPA_Addendum_Status__c;
                  prTranRequest.SPA_Remarks__c=legBook.SPA_Remarks__c;
                  prTranRequest.Received_SPA_Particular_sent_recev_date__c=legBook.Received_SPA_Particular_sent_recev_date__c;
                  prTranRequest.Executed_Copy_Sent_Date__c=legBook.Executed_Copy_Sent_Date__c;
                  prTranRequest.Executed_Copy_Sent_Through__c=legBook.Executed_Copy_Sent_Through__c;
                  prTranRequest.Executed_Copy_Courier_Tracking_No__c=legBook.Executed_Copy_Courier_Tracking_No__c;
                  prTranRequest.SPA_Particulars__c=legBook.SPA_Particulars__c;
                  prTranRequest.Stage_Of_SPA_Execution__c=legBook.Stage_Of_SPA_Execution__c;
                  prTranRequest.PropStrength__Status__c=legBook.SPA_Executed__c;

                  updateTranReqLst.add(prTranRequest);
               }
           }
       }
        if(!updateTranReqLst.isEmpty())
        {
            Database.SaveResult[] results = Database.update(updateTranReqLst, true);
            // Iterate through each returned result
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess())
                {
                    System.debug('Successfully Updated Transaction Request. Record ID: ' + sr.getId());
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
        System.debug('ScriptBookingToTransRequestBatch - Finish Menthod');  
    }
}
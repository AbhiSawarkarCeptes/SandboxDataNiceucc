public class ScriptBookingToApplicantBookingBatch implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        System.debug('ScriptBookingToApplicantBookingBatch - Start Menthod');
        String query='Select Id, Name, Legacy_Booking_Id__c, SPA_Status__c, SPA_Execution_Date__c, SPA_Particulars__c, SPA_Sent_to_Audit_Date__c, SPA_Issue_Date__c, SPA_Sent_Date__c, SPA_Sent_Through__c, SPA_Courier_Tracking_No__c, SPA_Receive_Date__c, Stage_Of_SPA_Execution__c, SPA_Audit_rejection_comments__c, SPA_signed_by_Seller_date__c, Executed_Copy_Sent_Through__c, Executed_Copy_Sent_Date__c, Executed_Copy_Courier_Tracking_No__c, SPA_Remarks__c, SPA_Addendum_Sent_Date__c, SPA_Addendum_Executed_Date__c, SPA_Addendum_Sent_to_Audit_Date__c, SPA_Addendum_Status__c from PropStrength__Application_Booking__c where Legacy_Booking_Id__c <> null';
        //String query='Select Id, Name, Legacy_Booking_Id__c, SPA_Status__c, SPA_Execution_Date__c, SPA_Particulars__c, SPA_Sent_to_Audit_Date__c, SPA_Issue_Date__c, SPA_Sent_Date__c, SPA_Sent_Through__c, SPA_Courier_Tracking_No__c, SPA_Receive_Date__c, Stage_Of_SPA_Execution__c, SPA_Audit_rejection_comments__c, SPA_signed_by_Seller_date__c, Executed_Copy_Sent_Through__c, Executed_Copy_Sent_Date__c, Executed_Copy_Courier_Tracking_No__c, SPA_Remarks__c, SPA_Addendum_Sent_Date__c, SPA_Addendum_Executed_Date__c, SPA_Addendum_Sent_to_Audit_Date__c, SPA_Addendum_Status__c from PropStrength__Application_Booking__c where Legacy_Booking_Id__c <> null and Legacy_Booking_Id__c in (\'a062o00001pev5eAAA\',\'a067S000003K8QRQA0\',\'a067S000000WKvAQAW\',\'a067S000003EMvYQAW\',\'a06TX000005ClgFYAS\')';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<PropStrength__Application_Booking__c> appliBookList) 
    {
        System.debug('ScriptBookingToApplicantBookingBatch - Execute Menthod');
        List<PropStrength__Application_Booking__c> updateAppBookLst = new List<PropStrength__Application_Booking__c>();
        Map<Id, Booking__c> legBookMap = New Map<Id, Booking__c>();
        Set<Id> legBookLst = New Set<Id>();
        for(PropStrength__Application_Booking__c appBook :appliBookList)
        {
          legBookLst.add(appBook.Legacy_Booking_Id__c); 
        }
        if(!legBookLst.isEmpty())
        {
           legBookMap = new Map<Id, Booking__c>([Select Id, Name,SPA_Executed__c,SPA_Executed_Date__c,SPA_Particulars__c,SPA_Sent_to_Audit_Date__c,SPA_Issue_Date__c,SPA_Sent_Date__c,SPA_Sent_Through__c,SPA_Courier_Tracking_No__c,SPA_Receive_Date__c,Stage_Of_SPA_Execution__c,SPA_Audit_rejection_comments__c,SPA_signed_by_Seller_date__c,Executed_Copy_Sent_Through__c,Executed_Copy_Sent_Date__c,Executed_Copy_Courier_Tracking_No__c,SPA_Remarks__c,SPA_Addendum_Sent_Date__c,SPA_Addendum_Executed_Date__c,SPA_Addendum_Sent_to_Audit_Date__c,SPA_Addendum_Status__c from Booking__c where Id in :legBookLst]); 
        }
        if(!legBookMap.isEmpty())
        {
            for(PropStrength__Application_Booking__c appBook :appliBookList)
            {
              If(legBookMap.ContainsKey(appBook.Legacy_Booking_Id__c))
              {
                Booking__c lBook=legBookMap.get(appBook.Legacy_Booking_Id__c);
                appBook.SPA_Status__c=lBook.SPA_Executed__c;
                appBook.SPA_Execution_Date__c=lBook.SPA_Executed_Date__c;
                appBook.SPA_Particulars__c=lBook.SPA_Particulars__c;
                appBook.SPA_Sent_to_Audit_Date__c=lBook.SPA_Sent_to_Audit_Date__c;
                appBook.SPA_Issue_Date__c=lBook.SPA_Issue_Date__c;
                appBook.SPA_Sent_Date__c=lBook.SPA_Sent_Date__c;
                appBook.SPA_Sent_Through__c=lBook.SPA_Sent_Through__c;
                appBook.SPA_Courier_Tracking_No__c=lBook.SPA_Courier_Tracking_No__c;
                appBook.SPA_Receive_Date__c=lBook.SPA_Receive_Date__c;
                appBook.Stage_Of_SPA_Execution__c=lBook.Stage_Of_SPA_Execution__c;
                appBook.SPA_Audit_rejection_comments__c=lBook.SPA_Audit_rejection_comments__c;
                appBook.SPA_signed_by_Seller_date__c=lBook.SPA_signed_by_Seller_date__c;
                appBook.Executed_Copy_Sent_Through__c=lBook.Executed_Copy_Sent_Through__c;
                appBook.Executed_Copy_Sent_Date__c=lBook.Executed_Copy_Sent_Date__c;
                appBook.Executed_Copy_Courier_Tracking_No__c=lBook.Executed_Copy_Courier_Tracking_No__c;
                appBook.SPA_Remarks__c=lBook.SPA_Remarks__c;
                appBook.SPA_Addendum_Sent_Date__c=lBook.SPA_Addendum_Sent_Date__c;
                appBook.SPA_Addendum_Executed_Date__c=lBook.SPA_Addendum_Executed_Date__c;
                appBook.SPA_Addendum_Sent_to_Audit_Date__c=lBook.SPA_Addendum_Sent_to_Audit_Date__c;
                appBook.SPA_Addendum_Status__c=lBook.SPA_Addendum_Status__c;
                  
                updateAppBookLst.add(appBook);
              } 
            }
        }
        if(!updateAppBookLst.isEmpty())
        {
            Database.SaveResult[] results = Database.update(updateAppBookLst, true);
            // Iterate through each returned result
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess())
                {
                    System.debug('Successfully Updated Applicant/Booking. Applicant/Booking ID: ' + sr.getId());
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
        System.debug('ScriptBookingToApplicantBookingBatch - Finish Menthod');  
    }
}
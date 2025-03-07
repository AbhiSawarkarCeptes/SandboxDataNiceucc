global class UpdateMilestoneDueTillDateOnBookingBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Booking__c WHERE Status__c != \'Cancelled\' AND Current_Status__c = \'Audit Accepted\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Booking__c> bookingList) {
        list<Payment_Milestones__c> pmList = [SELECT Id, Total_Installment__c,Total_Installment_New__c, Quotation__r.Booking__c FROM Payment_Milestones__c 
                                              WHERE Quotation__c != null 
                                              AND Quotation__r.Booking__c != null 
                                              AND Milestone_Due_Date__c != null 
                                              AND Milestone_Due_Date__c <= today 
                                              AND Quotation__r.Booking__c IN: bookingList];
        
        list<Booking__c> bookingToUpdate = new list<Booking__c>();
        map<string,Long> bookingIdToMilestoneDue = new map<string,Long>();
        
        for(Payment_Milestones__c pm : pmList){
            if(bookingIdToMilestoneDue.containsKey(pm.Quotation__r.Booking__c)){
                long dueAmt = bookingIdToMilestoneDue.get(pm.Quotation__r.Booking__c);
                dueAmt = dueAmt + (long)pm.Total_Installment_New__c;
                bookingIdToMilestoneDue.put(pm.Quotation__r.Booking__c,dueAmt);
            }
            else{
                bookingIdToMilestoneDue.put(pm.Quotation__r.Booking__c,(long)pm.Total_Installment_New__c);
            }
        }
        
        for(string bookingId : bookingIdToMilestoneDue.keySet()){
            bookingToUpdate.add(new Booking__c(Id=bookingId,Milestone_Due_Till_Date__c=bookingIdToMilestoneDue.get(bookingId)));
        }
        
        if(bookingToUpdate.size()>0){
            BookingApprovalCommentHandler.afterTriggerBookingFirstRun = false;
            Database.update(bookingToUpdate,false);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}
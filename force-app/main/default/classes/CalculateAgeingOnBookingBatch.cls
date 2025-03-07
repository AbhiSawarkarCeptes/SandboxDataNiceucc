global class CalculateAgeingOnBookingBatch implements Database.Batchable<sObject> {
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Booking__c WHERE Status__c != \'Cancelled\' AND Current_Status__c = \'Audit Accepted\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Booking__c> bookingList) {
        
        list<Payment_Milestones__c> pmList = [SELECT Id, Total_Installment__c,Total_Installment_New__c, Quotation__r.Booking__c, Milestone_Due_Date__c 
                                              FROM Payment_Milestones__c 
                                              WHERE Quotation__c != null 
                                              AND Quotation__r.Booking__c != null 
                                              AND Milestone_Due_Date__c != null 
                                              AND Milestone_Due_Date__c <= today 
                                              AND Quotation__r.Booking__c IN: bookingList 
                                              Order By Milestone_Due_Date__c ASC];
        
        list<Booking__c> bookingToUpdate = new list<Booking__c>();
        map<string, list<Payment_Milestones__c>> bookingToPM = new map<string, list<Payment_Milestones__c>>();
        
        for(Payment_Milestones__c pm : pmList){
            if(bookingToPM.containsKey(pm.Quotation__r.Booking__c)){
                list<Payment_Milestones__c> pms = bookingToPM.get(pm.Quotation__r.Booking__c);
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
            else{
                list<Payment_Milestones__c> pms = new list<Payment_Milestones__c>();
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
        }
        
        map<string,Booking__c> bookingIdToBooking = new map<string,Booking__c>();
        for(Booking__c b : [select Id, Total_On_Account_Money_With_Registration__c from Booking__c where Id IN: bookingToPM.keySet()]){
            bookingIdToBooking.put(b.id,b);
        }
        
        double remaining = 0;
        Boolean milestoneHit = false;
        integer diffDays = 0;
        for(string booking : bookingToPM.keySet()){
            Booking__c bk = bookingIdToBooking.get(booking);
            if(bk.Total_On_Account_Money_With_Registration__c != null){
            remaining = (double)bk.Total_On_Account_Money_With_Registration__c;
            }else{
                remaining = 0;
            }
            diffDays = 0;
            milestoneHit = false;
            for(Payment_Milestones__c pm : bookingToPM.get(booking)){
                if(pm != null && pm.Total_Installment_New__c !=null){
                remaining = remaining - (double)pm.Total_Installment_New__c;
                if (remaining < 0) {
                    double per = (double)((remaining*100*(-1))/(double)pm.Total_Installment_New__c);
                    if(per >= 20){
                        Date milestoneDate = pm.Milestone_Due_Date__c;
                        Date startDate = Date.today();
                        diffDays = milestoneDate.daysBetween(startDate);
                        bookingToUpdate.add(new Booking__c(Id=booking,Ageing_days__c=diffDays,Ageing_Date__c=milestoneDate));
                        milestoneHit = true;
                    }
                }
                if(milestoneHit) break;
                }
            }
        }
        if(bookingToUpdate.size()>0){
            BookingApprovalCommentHandler.afterTriggerBookingFirstRun = false;
            Database.update(bookingToUpdate,false);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
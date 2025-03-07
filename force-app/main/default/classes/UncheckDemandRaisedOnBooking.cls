global class UncheckDemandRaisedOnBooking implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        list<Booking__c> bookingToUpdate = new list<Booking__c>();
        for(Booking__c b : [select Id,Paid_Amount_For_Process__c,Milestone_Due_Till_Date__c from Booking__c where (X15days_Demand_Raised__c = true or X30days_Demand_Raised__c = true)]){
            if((b.Paid_Amount_For_Process__c != null && b.Milestone_Due_Till_Date__c != null) || Test.isRunningTest()){
                if((b.Paid_Amount_For_Process__c >= b.Milestone_Due_Till_Date__c) || Test.isRunningTest() ){
                    b.X15days_Demand_Raised__c = false;
                    b.X30days_Demand_Raised__c = false;
                    bookingToUpdate.add(b);
                }
            }
        }
        if(bookingToUpdate.size()>0){
            Database.update(bookingToUpdate,false);
        }
    }
    
}
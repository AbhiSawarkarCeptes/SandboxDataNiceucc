global class RaiseDemandTrackerSchedular implements Schedulable {
    public void execute(SchedulableContext sc) {
        list<Raise_Demand_Tracker__c> trackerList = new list<Raise_Demand_Tracker__c>();
        String query = 'Select Id, Quotation__r.Unit__c, Quotation__r.Booking__c ' +
            ' from Payment_Milestones__c ' +
            ' where Quotation__c != null ' +
            ' and Quotation__r.Unit__c != null ' +
            ' and Quotation__r.Booking__c != null ' +
            ' and Quotation__r.Booking__r.Current_Status__c = \'Audit Accepted\' ' +
            ' and Quotation__r.Booking__r.Status__c = \'Processed\' '+
            ' and Quotation__r.Booking__r.Stage_of_Booking__c != \'EOI\' '+
            ' and is_demand_raised__c = false '+  
            ' and Quotation__r.Booking__r.Under_cancellation__c = false '+  
            ' and Raise_Demand_Tracker_Created__c = false '+
            ' and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:25';
        list<Payment_Milestones__c> pmList = Database.query(query);
        Map<String, String> Qoutation_PM_Map = new Map<String, String>();
        Map<String, String> ValidQuotation_Map = new Map<String, String>();
        for (Payment_Milestones__c pm : pmList) {
            Qoutation_PM_Map.put(pm.Id,pm.Quotation__c);
        }
        
        System.debug(' Qoutation_PM_Map -> '+Qoutation_PM_Map);
        System.debug(' Qoutation_PM_Map -> '+Qoutation_PM_Map.size());
        for (Booking__c booking : [ SELECT Id,Name,Quotation__c,Unit__r.Name,Unit__r.Tower__r.Name FROM Booking__c WHERE Quotation__c IN : Qoutation_PM_Map.values() AND Unit__r.Tower__r.ByPass_Demand_Generation__c = False ]) {
            ValidQuotation_Map.put(booking.Id,booking.Quotation__c);
        }
        for(Payment_Milestones__c pm : pmList){
            Raise_Demand_Tracker__c tracker = new Raise_Demand_Tracker__c();
            tracker.Booking__c = pm.Quotation__r.Booking__c;
            tracker.Payment_Milestones__c = pm.Id;
            tracker.Raise_Demand_Date__c = System.today();
            if(ValidQuotation_Map.values().contains(pm.Quotation__c)){
                trackerList.add(tracker);
                pm.Raise_Demand_Tracker_Created__c = true;
            }
        }
        System.debug(' ValidQuotation_Map -> '+ValidQuotation_Map);
        System.debug(' ValidQuotation_Map -> '+ValidQuotation_Map.size());
        if(trackerList.size()>0)
            Database.insert(trackerList,false);
        if(pmList.size()>0)
            Database.update(pmList,false);
    }
}
public class RaisePPDBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext context) {
        Date todayDate = System.Today();
        String query = 'SELECT Id, Do_Not_Raise_Demand__c, PropStrength__Milestone__r.Milestone_Completion_Approved_On__c FROM PropStrength__Payment_Plan_Details__c WHERE PropStrength__Is_Milestone_Completed__c = FALSE AND PropStrength__Approval_Status__c != \'Approved\' AND PropStrength__Is_reversed__c = FALSE AND PropStrength__Payment_Due_Date__c <= :todayDate AND PropStrength__Milestone__r.PropStrength__Milestone_Type__c = \'Construction Linked\' AND PropStrength__Milestone__r.PropStrength__Status__c = \'Completed\' AND PropStrength__Milestone__r.Milestone_Completion_Approved_On__c != null AND PropStrength__Application_Booking__r.PropStrength__Status__c =\'Audit Approved\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext context) {
        RaisePPDBatch batch = new RaisePPDBatch();
        Database.executeBatch(batch);
    }
    
    public void execute(Database.BatchableContext context, List<PropStrength__Payment_Plan_Details__c> scope) {
        if(!scope.isEmpty()) {
            System.debug(scope);
            List<PropStrength__Payment_Plan_Details__c> updatePpdList = new List<PropStrength__Payment_Plan_Details__c>();
            for(PropStrength__Payment_Plan_Details__c ppd : scope) {
                if(!ppd.Do_Not_Raise_Demand__c) {
                    updatePpdList.add(new PropStrength__Payment_Plan_Details__c(Id=ppd.Id, Is_Demand_Due__c = TRUE, CLP_Milestone_Raised__c = TRUE, PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Approval_Status__c = 'Approved'));
                } else if(ppd.Do_Not_Raise_Demand__c) {
                    updatePpdList.add(new PropStrength__Payment_Plan_Details__c(Id=ppd.Id, Is_Demand_Due__c = TRUE));
                }
            }
            System.debug('updatePpdList***'+updatePpdList);
            if(!updatePpdList.isEmpty()) {
                update updatePpdList;
            }
        }
    }
    
    public void finish(Database.BatchableContext context) {
        //System.schedule('Scheduled_PPD_Batch_Job'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 12 * * ?', new RaisePPDBatch());
    }
}
global class PPDInterestBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,Name,PropStrength__Rate_of_Interest__c,Recurring_Interest_Till_date__c,
                                         Interest_Ageing__c,PropStrength__Final_Payment_Date__c,PropStrength__Balance__c, 
                                         PropStrength__Application_Booking__r.Mortgage_Case__c, PropStrength__Application_Booking__r.PCC_Document_Approved__c,
                                         PropStrength__Application_Booking__r.Title_Deed_Transfer_Executed__c
                                         FROM PropStrength__Payment_Plan_Details__c
                                         WHERE PropStrength__Application_Booking__r.PropStrength__Active__c = true AND
                                         PropStrength__Application_Booking__c != null AND
                                         (PropStrength__Application_Booking__r.Mortgage_Case__c = false AND PropStrength__Application_Booking__r.PCC_Document_Approved__c = false AND
                                         PropStrength__Application_Booking__r.Title_Deed_Transfer_Executed__c = false) AND
                                         PropStrength__Is_Milestone_Completed__c =: true AND
                                         PropStrength__Approval_Status__c =: 'Approved' AND 
                                         PropStrength__Balance__c > 10000 AND
                                         Interest_Ageing__c > 0]);
        
    }
    global void execute(Database.BatchableContext BC, List<PropStrength__Payment_Plan_Details__c> scope) {
        List<PropStrength__Payment_Plan_Details__c> updatePPDList = new List<PropStrength__Payment_Plan_Details__c>();
        for(PropStrength__Payment_Plan_Details__c ppd : scope) {
            PropStrength__Payment_Plan_Details__c onePPD = new PropStrength__Payment_Plan_Details__c();
            onePPD.Id = ppd.Id;
            System.debug('ppdId>>>>'+ppd.Id);
            System.debug('ppdId*****'+ppd.Recurring_Interest_Till_date__c+'----'+ppd.PropStrength__Balance__c+'***'+ppd.PropStrength__Rate_of_Interest__c+'***'+Integer.valueOf(Date.daysInMonth(Date.today().year(), Date.today().month())));
            onePPD.Recurring_Interest_Till_date__c = (ppd.Recurring_Interest_Till_date__c != null ? ppd.Recurring_Interest_Till_date__c : 0) +
                                                        (((ppd.PropStrength__Balance__c != null ? ppd.PropStrength__Balance__c : 0) +
                                                          (ppd.Recurring_Interest_Till_date__c != null ? ppd.Recurring_Interest_Till_date__c : 0)) *
                                                         (((ppd.PropStrength__Rate_of_Interest__c != null ? ppd.PropStrength__Rate_of_Interest__c : 0) /
                                                           100) / Integer.valueOf(Date.daysInMonth(Date.today().year(), Date.today().month()))));
            System.debug(onePPD.Recurring_Interest_Till_date__c+'//////ppdId>>>>'+ppd.Id);
            updatePPDList.add(onePPD);
        }
        if(!updatePPDList.isEmpty()) {
            List<Database.SaveResult> updateResults = Database.update(updatePPDList, false);
            system.debug('updateResults::'+updateResults);
            
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}
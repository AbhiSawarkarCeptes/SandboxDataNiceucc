public class LatePaymentFeeBatch implements DataBase.batchable <SObject>,Schedulable {
    public Database.querylocator start(DataBase.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Total_Recurring_Interest_Till_Date__c, Total_Interest_Due_Till_Date__c, Do_Not_Raise_Demand__c
                                        , PropStrength__Project__c, PropStrength__Project__r.Do_Not_Raise_Demand__c, 
                                        (SELECT Id FROM PropStrength__Payments_Cheques__r WHERE RecordType.Name = 'Income Charge Due' AND PropStrength__Amount_Due_Type__c = 'Late Payment Fee') 
                                        FROM PropStrength__Application_Booking__c 
                                        WHERE (PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c = false AND Mortgage_Case__c = false AND PCC_Document_Approved__c = false AND Title_Deed_Transfer_Executed__c = false )]);
    }
    
    public void execute(SchedulableContext context) {
        LatePaymentFeeBatch batch = new LatePaymentFeeBatch();
        Database.executeBatch(batch);
    }
    
    public void execute(DataBase.BatchableContext BC,List<PropStrength__Application_Booking__c> scope){
        Decimal totRecIntTillDt;
        Decimal totIntDueTillDt;

        Id incChrgeDueRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        List<PropStrength__Received_Payment__c> createIncChrgeDueRecs = new List<PropStrength__Received_Payment__c>();
        List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();

        for(PropStrength__Application_Booking__c book : scope) {
            if(book.Total_Interest_Due_Till_Date__c!= null) {
                totIntDueTillDt = book.Total_Interest_Due_Till_Date__c;
            } else {
                totIntDueTillDt = 0;
            }

            if(book.Total_Recurring_Interest_Till_Date__c != null) {
                totRecIntTillDt = book.Total_Recurring_Interest_Till_Date__c;
            } else { 
                totRecIntTillDt = 0;
            }

            if(totRecIntTillDt > totIntDueTillDt) {
                if(book.PropStrength__Payments_Cheques__r.size() < 2) {
                    if(book.PropStrength__Payments_Cheques__r.size() < 1) {
                        updateBookList.add(new PropStrength__Application_Booking__c(Id = book.Id, Income_Charge_Due_Creation_Date__c = System.Today().addDays(15), X15_days_LP_demand_raised__c = System.now()));
                    } else if(book.PropStrength__Payments_Cheques__r.size() < 2) {
                        updateBookList.add(new PropStrength__Application_Booking__c(Id = book.Id, X30_days_LP_demand_raised__c = System.now()));
                    }
                    
                    createIncChrgeDueRecs.add(new PropStrength__Received_Payment__c(PropStrength__Amount__c = totRecIntTillDt - totIntDueTillDt, PropStrength__Application_Booking__c = book.Id, PropStrength__Amount_Due_Type__c = 'Late Payment Fee', RecordTypeId = incChrgeDueRT, PropStrength__Payment_Date__c = System.Today(), PropStrength__Demand_Generation_Date__c = System.Today(), PropStrength__Billing_Date__c = System.Today(), PropStrength__Actual_Payment_Date__c = System.Today().addDays(15), PropStrength__Demand_Status__c = 'Demand Generated', PropStrength__Demand_Generated__c = TRUE, PropStrength__Demand_Email_Sent__c = TRUE));  
                }
            }
        }

        if(!createIncChrgeDueRecs.isEmpty()) {
            insert createIncChrgeDueRecs;

            if(!updateBookList.isEmpty()) {
                update updateBookList;
            }

            Set<Id> payIdset = new Set<Id>();

            for(PropStrength__Received_Payment__c pay : createIncChrgeDueRecs) {
                payIdset.add(pay.Id);
            }

            SendLatePaymentFee emailJob = new SendLatePaymentFee(payIdset);
            System.enqueueJob(emailJob);
        }
    }

    public void finish(DataBase.BatchableContext BC){
        System.schedule('LatePaymentFeeBatch15Days'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 1,16 * * ?', new LatePaymentFeeBatch() );
    }
}
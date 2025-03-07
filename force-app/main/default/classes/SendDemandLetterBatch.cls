public class SendDemandLetterBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    public Set<Id> incId = new Set<Id>();
    public Map<Id, PropStrength__Application_Booking__c> bookMap;
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Handover_Notice_Sent_Date__c, Handover_Completed_Date__c, Upkeep_Charges__c, Refurbishment_Charges_Batch__c, PropStrength__Application_Booking__r.PropStrength__Property_Type__r.Upkeep_Charge_Amount_Per_Month__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Category__c, PropStrength__Application_Booking__r.PropStrength__Property_Type__r.Refurbishment_Charge_Amount_Per_Month__c FROM PropStrength__Transaction_Requests__c WHERE Handover_Notice_Sent_Date__c != null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext context) {
        SendDemandLetterBatch batch = new SendDemandLetterBatch();
        Database.executeBatch(batch);
    }
    
    public void execute(Database.BatchableContext context, List<PropStrength__Transaction_Requests__c> scope) {
        System.debug('scope*****'+scope);
        if(!scope.isEmpty()) {
            Id incChrDueId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
            List<PropStrength__Received_Payment__c> createIncChrgDue = new List<PropStrength__Received_Payment__c>();
            List<PropStrength__Transaction_Requests__c> updateTrList = new List<PropStrength__Transaction_Requests__c>();
            List<PropStrength__Transaction_Requests__c> updateTrListRefur = new List<PropStrength__Transaction_Requests__c>();
            List<String> toAddresses= new List<String>();
            Set<Id> bookingId = new Set<Id>();
            
            for(PropStrength__Transaction_Requests__c tr: scope) {
                if(tr.Upkeep_Charges__c == null) {
                    tr.Upkeep_Charges__c = 1;
                }
                if(tr.Refurbishment_Charges_Batch__c == null) {
                    tr.Refurbishment_Charges_Batch__c = 0;
                }
                if(tr.Handover_Completed_Date__c == null && (tr.Handover_Notice_Sent_Date__c.daysBetween(System.Today()) > (tr.Upkeep_Charges__c * 30))) {
                    createIncChrgDue.add(new PropStrength__Received_Payment__c(RecordTypeId=incChrDueId, PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c, PropStrength__Amount_Due_Type__c='Upkeep Charges', PropStrength__Amount__c=tr.PropStrength__Application_Booking__r.PropStrength__Property_Type__r.Upkeep_Charge_Amount_Per_Month__c, PropStrength__Payment_Date__c=System.Today(), PropStrength__Actual_Payment_Date__c=System.Today().addDays(15), PropStrength__Demand_Email_Sent__c=TRUE, PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c = 'Demand Generated', PropStrength__Demand_Generated_By__c = UserInfo.getUserId(), PropStrength__Demand_Generated__c = TRUE));
                    updateTrList.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Upkeep_Charges__c=tr.Upkeep_Charges__c+1));
                    bookingId.add(tr.PropStrength__Application_Booking__c);
                }
                if(tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Category__c == 'Villas') {
                    if(tr.Refurbishment_Charges_Batch__c == 0 && tr.Handover_Completed_Date__c == null && (tr.Handover_Notice_Sent_Date__c.daysBetween(System.Today()) > 90)) {
                        createIncChrgDue.add(new PropStrength__Received_Payment__c(RecordTypeId=incChrDueId, PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c, PropStrength__Amount_Due_Type__c='Refurbishment Charges', PropStrength__Amount__c=tr.PropStrength__Application_Booking__r.PropStrength__Property_Type__r.Refurbishment_Charge_Amount_Per_Month__c, PropStrength__Payment_Date__c=System.Today(), PropStrength__Actual_Payment_Date__c=System.Today().addDays(15), PropStrength__Demand_Email_Sent__c=TRUE, PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c = 'Demand Generated', PropStrength__Demand_Generated_By__c = UserInfo.getUserId(), PropStrength__Demand_Generated__c = TRUE));
                        updateTrListRefur.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Refurbishment_Charges_Batch__c=tr.Refurbishment_Charges_Batch__c+1));
                        bookingId.add(tr.PropStrength__Application_Booking__c);
                    } else if(tr.Refurbishment_Charges_Batch__c != 0 && tr.Handover_Completed_Date__c == null && (tr.Handover_Notice_Sent_Date__c.daysBetween(System.Today()) > ((tr.Refurbishment_Charges_Batch__c * 30)+90))) {
                        createIncChrgDue.add(new PropStrength__Received_Payment__c(RecordTypeId=incChrDueId, PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c, PropStrength__Amount_Due_Type__c='Refurbishment Charges', PropStrength__Amount__c=tr.PropStrength__Application_Booking__r.PropStrength__Property_Type__r.Refurbishment_Charge_Amount_Per_Month__c, PropStrength__Payment_Date__c=System.Today(), PropStrength__Actual_Payment_Date__c=System.Today().addDays(15), PropStrength__Demand_Email_Sent__c=TRUE, PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c = 'Demand Generated', PropStrength__Demand_Generated_By__c = UserInfo.getUserId(), PropStrength__Demand_Generated__c = TRUE));
                        updateTrListRefur.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Refurbishment_Charges_Batch__c=tr.Refurbishment_Charges_Batch__c+1));
                        bookingId.add(tr.PropStrength__Application_Booking__c);
                    }
                } else {
                    if(tr.Refurbishment_Charges_Batch__c == 0 && tr.Handover_Completed_Date__c == null && (tr.Handover_Notice_Sent_Date__c.daysBetween(System.Today()) > 365)) {
                        createIncChrgDue.add(new PropStrength__Received_Payment__c(RecordTypeId=incChrDueId, PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c, PropStrength__Amount_Due_Type__c='Refurbishment Charges', PropStrength__Amount__c=tr.PropStrength__Application_Booking__r.PropStrength__Property_Type__r.Refurbishment_Charge_Amount_Per_Month__c, PropStrength__Payment_Date__c=System.Today(), PropStrength__Actual_Payment_Date__c=System.Today().addDays(15), PropStrength__Demand_Email_Sent__c=TRUE, PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c = 'Demand Generated', PropStrength__Demand_Generated_By__c = UserInfo.getUserId(), PropStrength__Demand_Generated__c = TRUE));
                        updateTrListRefur.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Refurbishment_Charges_Batch__c=tr.Refurbishment_Charges_Batch__c+1));
                        bookingId.add(tr.PropStrength__Application_Booking__c);
                    } else if(tr.Refurbishment_Charges_Batch__c != 0 && tr.Handover_Completed_Date__c == null && (tr.Handover_Notice_Sent_Date__c.daysBetween(System.Today()) > ((tr.Refurbishment_Charges_Batch__c * 30)+365))) {
                        createIncChrgDue.add(new PropStrength__Received_Payment__c(RecordTypeId=incChrDueId, PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c, PropStrength__Amount_Due_Type__c='Refurbishment Charges', PropStrength__Amount__c=tr.PropStrength__Application_Booking__r.PropStrength__Property_Type__r.Refurbishment_Charge_Amount_Per_Month__c, PropStrength__Payment_Date__c=System.Today(), PropStrength__Actual_Payment_Date__c=System.Today().addDays(15), PropStrength__Demand_Email_Sent__c=TRUE, PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c = 'Demand Generated', PropStrength__Demand_Generated_By__c = UserInfo.getUserId(), PropStrength__Demand_Generated__c = TRUE));
                        updateTrListRefur.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Refurbishment_Charges_Batch__c=tr.Refurbishment_Charges_Batch__c+1));
                        bookingId.add(tr.PropStrength__Application_Booking__c);
                    }
                }
            }
            
            
            if(!bookingId.isEmpty()) {
                bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Applicant_Acc__r.Email, PropStrength__Applicant_Acc__r.Name FROM PropStrength__Applicant_Details__r) FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]);
                System.debug('updateTrList****'+updateTrList);
                System.debug('bookMap****'+bookMap);
                if(!updateTrList.isEmpty()) {
                    update updateTrList;
                }
                System.debug('updateTrListRefur****'+updateTrListRefur);
                if(!updateTrListRefur.isEmpty()) {
                    update updateTrListRefur;
                }
                if(!createIncChrgDue.isEmpty()) {
                    insert createIncChrgDue;
                    for(PropStrength__Received_Payment__c incDue : createIncChrgDue) {
                        incId.add(incDue.Id);
                    }
                    System.debug('incId***'+incId);
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext context) {
        if(!incId.isEmpty()) {
            SendMailDemandLetter batch = new SendMailDemandLetter(incId, bookMap);
            Database.executeBatch(batch);
        }
        //Integer minutesDelay = 1;
        //Datetime futureTime = Datetime.now().addMinutes(minutesDelay);
        //String cronExp = '0 ' + futureTime.minute() + ' ' + futureTime.hour() + ' ' + futureTime.day() + ' ' + futureTime.month() + ' ? ' + futureTime.year();        
        //System.schedule('Scheduled_TR_Batch_Job'+System.now().addDays(Integer.valueof((Math.random() * 100))), cronExp, new SendDemandLetterBatch());
        
        System.schedule('Scheduled_TR_Batch_Job'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 12 * * ?', new SendDemandLetterBatch());
    }
}
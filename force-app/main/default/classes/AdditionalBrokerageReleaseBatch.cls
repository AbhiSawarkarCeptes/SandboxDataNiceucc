/*********************************************************************
 * Class Name  :   AdditionalBrokerageReleaseBatch
 * Description :   Batch class for create BPM and Broker Ledger record for Booking , which run everyday
 * Created Date:   10/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 11/01/2024
 *********************************************************************/
public class AdditionalBrokerageReleaseBatch implements DataBase.batchable <SObject>,Schedulable{
    
    public Database.querylocator start(DataBase.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, PropStrength__Brokerage_Scheme__c, PropStrength__Additional_Brokerage_Type__c, 
                                        PropStrength__Additional_Brokerage__c, PropStrength__Type__c, PropStrength__Active__c, 
                                        PropStrength__Effective_Start_Date__c, PropStrength__Effective_end_Date__c, 
                                        PropStrength__Range_From__c, PropStrength__Range_To__c 
                                        FROM PropStrength__Additional_Brokerage_Slab__c
                                        WHERE PropStrength__Effective_end_Date__c != null AND 
                                        PropStrength__Effective_end_Date__c <= YESTERDAY AND PropStrength__Active__c = TRUE AND 
                                        PropStrength__Brokerage_Scheme__c != null AND PropStrength__Effective_Start_Date__c != null AND 
                                        PropStrength__Range_To__c != null AND PropStrength__Range_From__c != null]);
    }
    
    public void execute(SchedulableContext context) {
        AdditionalBrokerageReleaseBatch batch = new AdditionalBrokerageReleaseBatch();
        Database.executeBatch(batch);
    }
    
    public void execute(DataBase.BatchableContext BC,List<PropStrength__Additional_Brokerage_Slab__c> scope){
        if(!scope.isEmpty()) {
            Set<Id> brkSchemeIDs = new Set<Id>();

            for(PropStrength__Additional_Brokerage_Slab__c addBrkSlb : scope) {
                if(addBrkSlb.PropStrength__Brokerage_Scheme__c != null) {
                    brkSchemeIDs.add(addBrkSlb.PropStrength__Brokerage_Scheme__c);
                }
            }

            System.debug('brkSchemeIDs****');
            System.debug(brkSchemeIDs);

            if(!brkSchemeIDs.isEmpty()) {
                Map<Id, List<PropStrength__Application_Booking__c>> brkAccAppBookMap = new Map<Id, List<PropStrength__Application_Booking__c>>();

                List<PropStrength__Brokerage_Scheme__c> brkSchemeList = ([SELECT ID, (SELECT Id, PropStrength__Booking_Date__c, PropStrength__Broker_Account__c, 
                                                                        PropStrength__Brokerage_Scheme__c, PropStrength__Revised_Total_Sales_Consideration__c, 
                                                                        PropStrength__Status__c, PropStrength__Total_Paid_Percent__c, Oqood_Fees_Received__c,
                                                                        SPA_Executed__c, SPA_Execution_Date__c 
                                                                        FROM PropStrength__Applications_Bookings__r
                                                                        WHERE PropStrength__Active__c = TRUE AND PropStrength__Booking_Date__c != null 
                                                                        AND PropStrength__Broker_Account__c != null AND PropStrength__Additional_Margin_Released__c = FALSE)
                                                            FROM PropStrength__Brokerage_Scheme__c
                                                            WHERE Id IN :brkSchemeIDs]);

                System.debug('brkSchemeList****');
                System.debug(brkSchemeList);
                
                for (PropStrength__Additional_Brokerage_Slab__c addBrkSlb : scope) {
                    if(addBrkSlb.PropStrength__Brokerage_Scheme__c != null) {
                        for(PropStrength__Brokerage_Scheme__c brkScheme : brkSchemeList) {
                            if(addBrkSlb.PropStrength__Brokerage_Scheme__c == brkScheme.Id) {
                                if(!brkScheme.PropStrength__Applications_Bookings__r.isEmpty()) {
                                    for(PropStrength__Application_Booking__c booking : brkScheme.PropStrength__Applications_Bookings__r) {
                                        if (isDateInRange(booking.PropStrength__Booking_Date__c, addBrkSlb.PropStrength__Effective_Start_Date__c, addBrkSlb.PropStrength__Effective_end_Date__c)) {
                                            if(brkAccAppBookMap.containsKey(booking.PropStrength__Broker_Account__c)) {
                                                if(!brkAccAppBookMap.get(booking.PropStrength__Broker_Account__c).contains(booking)) {
                                                    brkAccAppBookMap.get(booking.PropStrength__Broker_Account__c).add(booking);
                                                }
                                            } else {
                                                brkAccAppBookMap.put(booking.PropStrength__Broker_Account__c, new List<PropStrength__Application_Booking__c>{booking});
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                System.debug('brkAccAppBookMap****');
                System.debug(brkAccAppBookMap);

                if(!brkAccAppBookMap.isEmpty()) {
                    Set<PropStrength__Application_Booking__c> bookingsEligibleForBPMCreation = new Set<PropStrength__Application_Booking__c>();
                    Map<Id, Id> bookingSlabMap = new Map<Id, Id>();

                    for(Id brkAccId : brkAccAppBookMap.keySet()) {
                        for (PropStrength__Additional_Brokerage_Slab__c addBrkSlb : scope) {
                            Decimal totalAmount = 0;
                            Decimal totalUnitCount = 0;
                            for(PropStrength__Application_Booking__c booking : brkAccAppBookMap.get(brkAccId)) {
                                if(addBrkSlb.PropStrength__Brokerage_Scheme__c == booking.PropStrength__Brokerage_Scheme__c && booking.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                    totalAmount += booking.PropStrength__Revised_Total_Sales_Consideration__c;
                                    totalUnitCount += 1;
                                }
                            }

                            System.debug('addBrkSlb.PropStrength__Type__c==='+addBrkSlb.PropStrength__Type__c);
                            System.debug('addBrkSlb.PropStrength__Range_From__c==='+addBrkSlb.PropStrength__Range_From__c);
                            System.debug('addBrkSlb.PropStrength__Range_To__c==='+addBrkSlb.PropStrength__Range_To__c);
                            if(addBrkSlb.PropStrength__Type__c == 'Amount') {
                                System.debug('totalAmount==='+totalAmount);
                                System.debug('addBrkSlb.PropStrength__Brokerage_Scheme__c in amt==='+addBrkSlb.PropStrength__Brokerage_Scheme__c);
                                if(addBrkSlb.PropStrength__Range_From__c <= totalAmount && totalAmount <= addBrkSlb.PropStrength__Range_To__c) {
                                    System.debug('in amt');
                                    for(PropStrength__Application_Booking__c booking : brkAccAppBookMap.get(brkAccId)) {
                                        if(addBrkSlb.PropStrength__Brokerage_Scheme__c == booking.PropStrength__Brokerage_Scheme__c) {
                                            System.debug('in cond1');
                                            bookingsEligibleForBPMCreation.add(booking);
                                            bookingSlabMap.put(booking.Id, addBrkSlb.Id);
                                        }
                                    }
                                }
                                System.debug('bookingsEligibleForBPMCreation in total amt****');
                                System.debug(bookingsEligibleForBPMCreation);
                                System.debug(bookingsEligibleForBPMCreation.size());
                            } else if(addBrkSlb.PropStrength__Type__c == 'Unit Count') {
                                System.debug('totalUnitCount==='+totalUnitCount);
                                System.debug('addBrkSlb.PropStrength__Brokerage_Scheme__c in count==='+addBrkSlb.PropStrength__Brokerage_Scheme__c);
                                if(addBrkSlb.PropStrength__Range_From__c <= totalUnitCount && totalUnitCount <= addBrkSlb.PropStrength__Range_To__c) {
                                    System.debug('in count');
                                    for(PropStrength__Application_Booking__c booking : brkAccAppBookMap.get(brkAccId)) {
                                        if(addBrkSlb.PropStrength__Brokerage_Scheme__c == booking.PropStrength__Brokerage_Scheme__c) {
                                            System.debug('in cond2');
                                            bookingsEligibleForBPMCreation.add(booking);
                                            bookingSlabMap.put(booking.Id, addBrkSlb.Id);
                                        }
                                    }
                                    System.debug('bookingsEligibleForBPMCreation in count****');
                                    System.debug(bookingsEligibleForBPMCreation);
                                    System.debug(bookingsEligibleForBPMCreation.size());
                                }
                            }
                        }
                    }

                    System.debug('bookingsEligibleForBPMCreation****');
                    System.debug(bookingsEligibleForBPMCreation);
                    System.debug(bookingsEligibleForBPMCreation.size());

                    System.debug('bookingSlabMap****');
                    System.debug(bookingSlabMap);
                    System.debug(bookingSlabMap.size());

                    if(!bookingsEligibleForBPMCreation.isEmpty()) {
                        Set<Id> bookId = new Set<Id>();
                        for(PropStrength__Application_Booking__c booking : bookingsEligibleForBPMCreation) {
                            bookId.add(booking.Id);
                        }

                        List<PropStrength__Application_Booking__c> bookingRecs = [SELECT Id, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Total_Service_Tax_due_on_Booking__c, 
                                                                        (SELECT Id, Amount_Interim__c FROM Interim_Payments__r WHERE Receipt_Reversed_Interim__c = FALSE AND 
                                                                        Cheque_Bounced_Interim__c = FALSE AND Amount_Type__c = 'Installment') 
                                                                        FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];

                        Map<Id, Decimal> mapBookingPercentage = new Map<Id, Decimal>();

                        for(PropStrength__Application_Booking__c booking : bookingRecs) {
                            if(!booking.Interim_Payments__r.isEmpty()) {
                                Decimal totAmt = 0;
                                for(Interim_Payments__c ipRec : booking.Interim_Payments__r) {
                                    if(ipRec.Amount_Interim__c != null) {
                                        totAmt += ipRec.Amount_Interim__c;
                                    }
                                }

                                if(booking.PropStrength__Revised_Total_Sales_Consideration__c != null && booking.PropStrength__Total_Service_Tax_due_on_Booking__c != null) {
                                    Decimal percentageVal = (totAmt / (booking.PropStrength__Revised_Total_Sales_Consideration__c - booking.PropStrength__Total_Service_Tax_due_on_Booking__c)) * 100;
                                    mapBookingPercentage.put(booking.Id, percentageVal);
                                }
                            }
                        }

                        System.debug('mapBookingPercentage****');
                        System.debug(mapBookingPercentage);


                        List<PropStrength__Broker_Payment_Milestone__c> createBPMList = new List<PropStrength__Broker_Payment_Milestone__c>();
                        List<PropStrength__Application_Booking__c> updateBookingList = new List<PropStrength__Application_Booking__c>();
                        for(PropStrength__Application_Booking__c booking : bookingsEligibleForBPMCreation) {
                            //if(mapBookingPercentage.containsKey(booking.Id) && mapBookingPercentage.get(booking.Id) >= 10) {
                                Decimal amt;
                                for (PropStrength__Additional_Brokerage_Slab__c slab : scope) {
                                    if(bookingSlabMap.get(booking.Id) == slab.Id && slab.PropStrength__Brokerage_Scheme__c != null && booking.PropStrength__Brokerage_Scheme__c == slab.PropStrength__Brokerage_Scheme__c) {
                                        if(slab.PropStrength__Additional_Brokerage_Type__c == '%' && slab.PropStrength__Additional_Brokerage__c != null) {
                                            amt = (booking.PropStrength__Revised_Total_Sales_Consideration__c * slab.PropStrength__Additional_Brokerage__c) / 100;
                                        } else if(slab.PropStrength__Additional_Brokerage_Type__c == 'Amount' && slab.PropStrength__Additional_Brokerage__c != null) {
                                            amt = slab.PropStrength__Additional_Brokerage__c;
                                        }
                                    }
                                }

                                System.debug('amt****');
                                System.debug(amt);

                                createBPMList.add(new PropStrength__Broker_Payment_Milestone__c(PropStrength__Booking_ID__c = booking.Id, PropStrength__Brokerage_Type__c = 'Additional Brokerage', PropStrength__Brokerage_Due__c =  100, PropStrength__Brokerage_Due_Rs__c = amt, PropStrength__Active__c = TRUE));
                                updateBookingList.add(new PropStrength__Application_Booking__c(Id = booking.Id, PropStrength__Additional_Margin_Released__c = true));
                            //}
                        }

                        System.debug('createBPMList****');
                        System.debug(createBPMList);
                        System.debug(createBPMList.size());

                        if(!createBPMList.isEmpty()) {
                            insert createBPMList;

                            Set<Id> bpmIds = new Set<Id>();
                            for(PropStrength__Broker_Payment_Milestone__c bpm : createBPMList) {
                                bpmIds.add(bpm.Id);
                            }

                            createBPMList = [SELECT Id, PropStrength__Booking_ID__c, PropStrength__Brokerage_Type__c, PropStrength__Brokerage_Due__c, PropStrength__Brokerage_Due_Rs__c, PropStrength__Active__c, PropStrength__Broker_Service_Tax__c FROM PropStrength__Broker_Payment_Milestone__c WHERE Id IN :bpmIds];

                            List<PropStrength__Broker_Payment_Milestone__c> updateBpmList = new List<PropStrength__Broker_Payment_Milestone__c>();
                            List<PropStrength__Broker_Ledger__c> bpmLedgerList = new List<PropStrength__Broker_Ledger__c>();

                            Id bpmLedgerDueId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();

                            for(PropStrength__Application_Booking__c booking : bookingsEligibleForBPMCreation) {
                                if(booking.PropStrength__Total_Paid_Percent__c >= 10 && booking.Oqood_Fees_Received__c && booking.SPA_Executed__c && booking.PropStrength__Status__c == 'Audit Approved' && booking.SPA_Execution_Date__c != null) {
                                    for(PropStrength__Broker_Payment_Milestone__c bpm : createBPMList) {
                                        if(bpm.PropStrength__Booking_ID__c == booking.Id) {
                                            bpmLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c=booking.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c=bpm.Id, PropStrength__Active__c= TRUE, PropStrength__Brokerage_Due_Rs__c=bpm.PropStrength__Brokerage_Due_Rs__c, RecordTypeId=bpmLedgerDueId, PropStrength__Brokerage_Type__c = 'Additional', PropStrength__Service_Tax__c = bpm.PropStrength__Broker_Service_Tax__c));
                                            updateBpmList.add(new PropStrength__Broker_Payment_Milestone__c(Id = bpm.Id, PropStrength__Due_Date__c = System.Today(), PropStrength__Is_Paid__c = TRUE));
                                        }
                                    }
                                }
                            }

                            System.debug('bpmLedgerList****');
                            System.debug(bpmLedgerList);
                            System.debug(bpmLedgerList.size());

                            System.debug('updateBpmList****');
                            System.debug(updateBpmList);
                            System.debug(updateBpmList.size());

                            System.debug('updateBookingList****');
                            System.debug(updateBookingList);
                            System.debug(updateBookingList.size());

                            if(!bpmLedgerList.isEmpty()) {
                                insert bpmLedgerList;
                            }
                            if(!updateBpmList.isEmpty()) {
                                update updateBpmList;
                            }
                            if(!updateBookingList.isEmpty()) {
                                update updateBookingList;
                            }
                        }
                    }
                }
            }
        }
    }

    private Boolean isDateInRange(Date targetDate, Date startDate, Date endDate) {
        return targetDate >= startDate && targetDate <= endDate;
    }
    
    public void finish(DataBase.BatchableContext BC){
        System.schedule('AdditionalBrokerageReleaseBatch_Daily'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 0 ? * *', new AdditionalBrokerageReleaseBatch() );
    }
}
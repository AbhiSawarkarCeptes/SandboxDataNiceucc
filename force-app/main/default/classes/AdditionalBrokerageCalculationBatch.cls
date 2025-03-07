public class AdditionalBrokerageCalculationBatch implements DataBase.batchable <SObject>{
    public Database.querylocator start(DataBase.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, PropStrength__Broker_Account__c, Booked_Date__c, PropStrength__Brokerage_Scheme__c,PropStrength__Property_Type__r.PropStrength__Property_Type__c,
                                         PropStrength__Revised_Total_Sales_Consideration__c,Total_Payment_Receive_Percent__c,PropStrength__Brokerage_BSP__c,PropStrength__Brokerage_On_Other_Charges__c,PropStrength__Super_Area__c,
                                         PropStrength__Brokerage_Scheme__r.name, PropStrength__Brokerage_Scheme__r.PropStrength__Start_Date__c,
                                         (SELECT Id,PropStrength__Amount__c from PropStrength__Other_Charges_Opted__r WHERE PropStrength__Other_Charges__r.PropStrength__Brokerage_Applicable__c = true),
                                         PropStrength__Brokerage_Scheme__r.PropStrength__End_Date__c,PropStrength__Brokerage_Scheme__r.Percentage_of_POP_Received_Date__c
                                         FROM PropStrength__Application_Booking__c WHERE PropStrength__Booking_Through__c = 'Broker' and PropStrength__Active__c = true and PropStrength__Broker_Account__c != null AND
                                         PropStrength__Brokerage_Release_Schedule__c != null and PropStrength__Booking_Date__c != null and PropStrength__Broker_Account__r.Expiry_Date__c >= TODAY
                                         AND PropStrength__Property__c != null AND PropStrength__Brokerage_Scheme__c != null AND Cancellation_Requested__c = false AND Booked_Date__c != null 
                                        ]);
    }
    
    public void execute(DataBase.BatchableContext BC,List<PropStrength__Application_Booking__c> bookingsList){
        Map<Id, List<PropStrength__Additional_Brokerage_Slab__c>> mapSchemeAndAdditionalSlab = new Map<Id, List<PropStrength__Additional_Brokerage_Slab__c>>();
        Map<String, List<PropStrength__Application_Booking__c>> mapOfAccountAndBookingCount = new map<String, List<PropStrength__Application_Booking__c>>();
        Map<String, Decimal> mapOfAccountAndBookingAmount = new Map<String, Decimal>();
        SET<Id> setOfScheme = new SET<Id>();
        List<PropStrength__Application_Booking__c> bookingFilterRecords  = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Application_Booking__c booking: bookingsList){
            if(booking.PropStrength__Broker_Account__c != null &&
                booking.Booked_Date__c >= booking.PropStrength__Brokerage_Scheme__r.PropStrength__Start_Date__c &&
            booking.Booked_Date__c <= booking.PropStrength__Brokerage_Scheme__r.PropStrength__End_Date__c) {
                System.debug('test123');
                bookingFilterRecords.add(booking);
                setOfScheme.add(booking.PropStrength__Brokerage_Scheme__c);
                if(booking.Total_Payment_Receive_Percent__c >= booking.PropStrength__Brokerage_Scheme__r.Percentage_of_POP_Received_Date__c ){
                    System.debug('----test456');
                    if(!mapOfAccountAndBookingCount.containskey(booking.PropStrength__Broker_Account__c+''+booking.PropStrength__Property_Type__r.PropStrength__Property_Type__c)){
                        mapOfAccountAndBookingCount.put(booking.PropStrength__Broker_Account__c+''+booking.PropStrength__Property_Type__r.PropStrength__Property_Type__c, new List<PropStrength__Application_Booking__c>{booking});
                    }
                    else
                        mapOfAccountAndBookingCount.get(booking.PropStrength__Broker_Account__c+''+booking.PropStrength__Property_Type__r.PropStrength__Property_Type__c).add(booking);
                    if(!mapOfAccountAndBookingAmount.containskey(booking.PropStrength__Broker_Account__c+''+booking.PropStrength__Property_Type__r.PropStrength__Property_Type__c)){
                        mapOfAccountAndBookingAmount.put(booking.PropStrength__Broker_Account__c+''+booking.PropStrength__Property_Type__r.PropStrength__Property_Type__c, booking.PropStrength__Revised_Total_Sales_Consideration__c);
                    }
                    else
                        mapOfAccountAndBookingAmount.put(booking.PropStrength__Broker_Account__c+''+booking.PropStrength__Property_Type__r.PropStrength__Property_Type__c, mapOfAccountAndBookingAmount.get(booking.PropStrength__Broker_Account__c+''+booking.PropStrength__Property_Type__r.PropStrength__Property_Type__c) + booking.PropStrength__Revised_Total_Sales_Consideration__c);
                    System.debug('bookingFilterRecords**-12233-'+mapOfAccountAndBookingCount.get(booking.PropStrength__Broker_Account__c+''+booking.PropStrength__Property_Type__r.PropStrength__Property_Type__c).size());
                }
                //System.debug('bookingFilterRecords**--'+mapOfAccountAndBookingCount.get(booking.PropStrength__Broker_Account__c+''+booking.PropStrength__Property_Type__r.PropStrength__Property_Type__c).size());
            }
        }
        System.debug('bookingFilterRecords**--'+bookingFilterRecords);
        System.debug('setOfScheme**--'+setOfScheme);
        System.debug(mapOfAccountAndBookingCount.size()+'---mapOfAccountAndBookingCount**--'+mapOfAccountAndBookingCount);
        System.debug('mapOfAccountAndBookingAmount**--'+mapOfAccountAndBookingAmount);
        Map<Id,PropStrength__Brokerage_Scheme__c> mapOfbrokerageSlab = new  Map<Id,PropStrength__Brokerage_Scheme__c>([SELECT id, (SELECT id, PropStrength__Additional_Brokerage__c, 
                                                                                                                                   PropStrength__Brokerage_Scheme__c,
                                                                                                                                   PropStrength__Effective_end_Date__c, PropStrength__Effective_Start_Date__c,
                                                                                                                                   PropStrength__Property_Type__c, PropStrength__Range_From__c,
                                                                                                                                   PropStrength__Range_To__c, PropStrength__Type__c                                                                        
                                                                                                                                   FROM PropStrength__Additional_Brokerage_Slabs__r 
                                                                                                                                   WHERE PropStrength__Active__c = TRUE 
                                                                                                                                   AND PropStrength__Effective_end_Date__c != null 
                                                                                                                                   AND PropStrength__Effective_Start_Date__c != null) 
                                                                                                                        FROM PropStrength__Brokerage_Scheme__c WHERE Id IN: setOfScheme]);
        System.debug(mapOfbrokerageSlab.size()+'--mapOfbrokerageSlab--'+mapOfbrokerageSlab);
        List<PropStrength__Application_Booking__c> updateBookingRecords  = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Application_Booking__c booking: bookingFilterRecords){
            Decimal sumOfOtherChargeAmt = 0;
            for(PropStrength__Other_Charges_Opted__c optdRec : booking.PropStrength__Other_Charges_Opted__r){
                sumOfOtherChargeAmt += optdRec.PropStrength__Amount__c != null ? optdRec.PropStrength__Amount__c : 0 ;
            }
            System.debug('--sumOfOtherChargeAmt--'+sumOfOtherChargeAmt);
            Decimal calculatePerValue = (booking.PropStrength__Brokerage_BSP__c + sumOfOtherChargeAmt + booking.PropStrength__Brokerage_On_Other_Charges__c) * booking.PropStrength__Super_Area__c;
            System.debug('--calculatePerValue--'+calculatePerValue);
            for(PropStrength__Additional_Brokerage_Slab__c slabRec : mapOfbrokerageSlab.get(booking.PropStrength__Brokerage_Scheme__c).PropStrength__Additional_Brokerage_Slabs__r){
                if(booking.Booked_Date__c >= slabRec.PropStrength__Effective_Start_Date__c 
                    && booking.Booked_Date__c <= slabRec.PropStrength__Effective_end_Date__c) {
                    Decimal totalCount = 0;
                    Decimal totalAmount = 0;
                    for(String propType : slabRec.PropStrength__Property_Type__c.split(';')){
                        if(mapOfAccountAndBookingCount.containskey(booking.PropStrength__Broker_Account__c+''+propType))
                            totalCount += mapOfAccountAndBookingCount.get(booking.PropStrength__Broker_Account__c+''+propType).size();
                        if(mapOfAccountAndBookingAmount.containskey(booking.PropStrength__Broker_Account__c+''+propType))
                            totalAmount += mapOfAccountAndBookingAmount.get(booking.PropStrength__Broker_Account__c+''+propType);
                    }
                    System.debug(totalCount+'--totalCount*----'+totalAmount+'--'+slabRec.PropStrength__Range_To__c+'**'+slabRec.PropStrength__Range_From__c);
                    System.debug(totalCount+'--totalAmount*----'+totalAmount+'--'+slabRec.PropStrength__Type__c+'**'+slabRec.PropStrength__Range_To__c + '***'+ slabRec.PropStrength__Range_From__c);
                    if(totalCount > 0 && slabRec.PropStrength__Type__c == 'Unit Count'  && totalCount <= slabRec.PropStrength__Range_To__c
                    && totalCount >= slabRec.PropStrength__Range_From__c) {
                        booking.Additional_Brokerage_Amount__c = (calculatePerValue * slabRec.PropStrength__Additional_Brokerage__c) / 100;
                        booking.Additional_Brokerage__c = slabRec.PropStrength__Additional_Brokerage__c;
                        updateBookingRecords.add(booking);
                        break;
                    }
                    else if( totalAmount > 0 && slabRec.PropStrength__Type__c == 'Amount'
                        && totalAmount <= slabRec.PropStrength__Range_To__c
                        && totalAmount >= slabRec.PropStrength__Range_From__c) {
                        booking.Additional_Brokerage_Amount__c = (calculatePerValue * slabRec.PropStrength__Additional_Brokerage__c) / 100;
                        booking.Additional_Brokerage__c = slabRec.PropStrength__Additional_Brokerage__c;
                        updateBookingRecords.add(booking);
                        break;
                    }
                }
            }
        }
        System.debug('updateBookingRecords*---'+updateBookingRecords);
        if(updateBookingRecords.size() > 0){
            update updateBookingRecords;
        }
    }
    public void finish(DataBase.BatchableContext BC){
        
    }
    
}
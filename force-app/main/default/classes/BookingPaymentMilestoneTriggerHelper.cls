public class BookingPaymentMilestoneTriggerHelper {
    public static void updateCGST(List<PropStrength__Broker_Payment_Milestone__c> bpmList) {
        Set<Id> bookId = new Set<Id>();
        for(PropStrength__Broker_Payment_Milestone__c bpm : bpmList) {
            if(bpm.PropStrength__Brokerage_Due_Rs__c != null && bpm.PropStrength__Booking_ID__c != null) {
                bookId.add(bpm.PropStrength__Booking_ID__c);
            }
        }
        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookingBrokerScheMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Broker_Account__c, PropStrength__Brokerage_Release_Schedule__c, PropStrength__Broker_Account__r.VAT_Registration_Status__c, PropStrength__Broker_Account__r.VAT_Applicable_From__c, PropStrength__Total_Brokerage_Payable__c, PropStrength__Primary_Customer__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            for(PropStrength__Broker_Payment_Milestone__c bpm : bpmList) {
                System.debug(System.Today()+'**---'+bookingBrokerScheMap.get(bpm.PropStrength__Booking_ID__c).PropStrength__Broker_Account__r.VAT_Applicable_From__c);
                if(bpm.PropStrength__Brokerage_Due_Rs__c != null && bpm.PropStrength__Booking_ID__c != null) {
                    //Added by Deepak for VAT_Applicable_From__c check and Updated VAT Registration Status__c picklist value 'Register' to 'Yes' on 21-Aug-2024 as per Sushil's discussion
                    if(bookingBrokerScheMap.get(bpm.PropStrength__Booking_ID__c).PropStrength__Broker_Account__r.VAT_Registration_Status__c == 'Yes' &&
                       (bookingBrokerScheMap.get(bpm.PropStrength__Booking_ID__c).PropStrength__Broker_Account__r.VAT_Applicable_From__c == null || 
                       (bookingBrokerScheMap.get(bpm.PropStrength__Booking_ID__c).PropStrength__Broker_Account__r.VAT_Applicable_From__c != null &&  
                        bookingBrokerScheMap.get(bpm.PropStrength__Booking_ID__c).PropStrength__Broker_Account__r.VAT_Applicable_From__c <= System.Today()) ) ) {
                        bpm.PropStrength__Broker_Service_Tax__c = bpm.PropStrength__Brokerage_Due_Rs__c * 0.05;
                        System.debug('tes----'+bpm.PropStrength__Broker_Service_Tax__c);
                    }
                }
            }
        }
    }
    
   /* public static void createLadger(List<PropStrength__Broker_Payment_Milestone__c> bpmList) {
        Set<Id> bpmId = new Set<Id>();
        Id BrokerageDueId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();
        for(PropStrength__Broker_Payment_Milestone__c bpm : bpmList) {
            if(bpm.Differentiate_Brokerage__c == true){
                bpmId.add(bpm.Id);
            }
        }
        if(bpmId.size() > 0){
            List<PropStrength__Broker_Payment_Milestone__c> bpmListRec = [SELECT id,PropStrength__Booking_ID__r.PropStrength__Broker_Account__c,PropStrength__Brokerage_Due_Rs__c,
                                                                          PropStrength__Booking_ID__r.PropStrength__Property__r.PropStrength__Property_Name__c,
                                                                          PropStrength__Booking_ID__r.Name, PropStrength__Broker_Service_Tax__c
                                                                          from PropStrength__Broker_Payment_Milestone__c WHERE Id IN:bpmId];
            List<PropStrength__Broker_Ledger__c> listOfBrokerLadgerRec = new List<PropStrength__Broker_Ledger__c>();
            for(PropStrength__Broker_Payment_Milestone__c bpm : bpmListRec) {
                PropStrength__Broker_Ledger__c BrokerLadgerRec = new PropStrength__Broker_Ledger__c();
                BrokerLadgerRec.RecordTypeId = BrokerageDueId;
                BrokerLadgerRec.PropStrength__Broker_Account__c = bpm.PropStrength__Booking_ID__r.PropStrength__Broker_Account__c;
                BrokerLadgerRec.PropStrength__Broker_Payment_Milestone__c = bpm.Id;
                BrokerLadgerRec.PropStrength__Booking_ID__c = bpm.PropStrength__Booking_ID__r.Name;
                //BrokerLadgerRec.CurrencyIsoCode = 'AED';
                BrokerLadgerRec.PropStrength__Brokerage_Type__c = 'Standard';
                BrokerLadgerRec.PropStrength__Brokerage_Due_Rs__c = bpm.PropStrength__Brokerage_Due_Rs__c;
                BrokerLadgerRec.PropStrength__Approval_Status__c = 'New';
                BrokerLadgerRec.PropStrength__Service_Tax__c = bpm.PropStrength__Broker_Service_Tax__c;
                listOfBrokerLadgerRec.add(BrokerLadgerRec);            
            }
            if(listOfBrokerLadgerRec.size() > 0)
                insert listOfBrokerLadgerRec;
        }
    }*/
}
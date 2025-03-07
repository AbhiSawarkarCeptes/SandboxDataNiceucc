public class CreateDifferentialBPMBatch implements DataBase.batchable <SObject> {
    
    
    public Database.querylocator start(DataBase.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,PropStrength__Booking_Through__c,Sobha_Connect_Verified__c,PropStrength__Broker_Account__c,
                                         PropStrength__Brokerage_Release_Schedule__c, PropStrength__Broker_Account__r.Expiry_Date__c, PropStrength__Property__r.PropStrength__Tower__r.UnRegister_Project__c,
                                         PropStrength__Broker_Account__r.PropStrength__Broker_Type__c,DLD_Fees_Received__c,DLD_Fees_Due__c,SPA_Executed__c,Differentiate_Brokerage_on_Other_Charge__c,
                                         Booking_Form_Executed__c,X10_Payment_Received_Date__c,Total_Payment_Receive_Percent__c,Booking_Form_Verified__c,Differentiate_Brokerage_on_BSP__c,
                                         (SELECT Id, PropStrength__Amount_Paid_By_Customer__c, PropStrength__Brokerage_Type__c, PropStrength__Is_Paid__c, PropStrength__Due_Date__c, 
                                          PropStrength__Brokerage_Due_Rs__c, PropStrength__Broker_Service_Tax__c, Booking_Form_Audit_Approved__c, DLD_Fee_Received__c, SPA_Executed__c,
                                          Order__c, PropStrength__Active__c, BrokRelLineItem_Name__c,Differentiate_Brokerage__c
                                          FROM PropStrength__Broker_Payment_Milestones__r WHERE PropStrength__Active__c = true
                                          ORDER BY Order__c)                                         
                                         from PropStrength__Application_Booking__c 
                                         where PropStrength__Booking_Through__c = 'Broker' and PropStrength__Active__c = true and PropStrength__Broker_Account__c != null AND
                                         PropStrength__Brokerage_Release_Schedule__c != null and PropStrength__Booking_Date__c != null and PropStrength__Broker_Account__r.Expiry_Date__c >= TODAY
                                         AND PropStrength__Property__c != null AND PropStrength__Brokerage_Scheme__c != null AND Cancellation_Requested__c = false AND 
                                         (PropStrength__Differential_Brokerage_On_Other_Charges__c != null OR PropStrength__Differential_Brokerage_On_BSP__c != null) AND Booked_Date__c != null
                                         
                                        ]);       
    }
    
    public void execute(DataBase.BatchableContext BC,List<PropStrength__Application_Booking__c> newList){
        system.debug(' CreateDifferentialBPMBatch executed');
        Set<Id> bookId = new Set<Id>();
        Set<Id> brokSchedId = new Set<Id>();  
        boolean flag = false;
        Map<String,Boolean> mapOfFliterBooking = new Map<String,Boolean>();
        List<PropStrength__Broker_Payment_Milestone__c> listOfBPM = new List<PropStrength__Broker_Payment_Milestone__c>();
        for(PropStrength__Application_Booking__c book : newList) { 
            for(PropStrength__Broker_Payment_Milestone__c bpm :  book.PropStrength__Broker_Payment_Milestones__r){
                mapOfFliterBooking.put(book.Id, true);
                if(bpm.Differentiate_Brokerage__c){
                    mapOfFliterBooking.put(book.Id, false);
                    break;
                }                
            }
        }
        system.debug('mapOfFliterBooking ++++'+mapOfFliterBooking);
        Map<Id,PropStrength__Application_Booking__c> listOfBookingRecAnd = new Map<Id,PropStrength__Application_Booking__c>([SELECT Id,
                                                                                                                             (SELECT Id,PropStrength__Amount_Paid_By_Customer__c,PropStrength__Brokerage_Due__c 
                                                                                                                              from PropStrength__Broker_Payment_Milestones__r WHERE PropStrength__Active__c = true ORDER BY Createddate DESC limit 1)
                                                                                                                             from PropStrength__Application_Booking__c WHERE Id IN : mapOfFliterBooking.keySet() ]);
        system.debug('listOfBookingRecAnd ++++'+listOfBookingRecAnd);
        for(PropStrength__Application_Booking__c book : newList) { 
            if(mapOfFliterBooking.get(book.id)){
                bookId.add(book.id);
                PropStrength__Broker_Payment_Milestone__c BPMRec = new PropStrength__Broker_Payment_Milestone__c();
                BPMRec.PropStrength__Booking_ID__c = book.Id;
                BPMRec.PropStrength__Brokerage_Type__c = 'Standard';
                BPMRec.PropStrength__Brokerage_Due_Rs__c = ( book.Differentiate_Brokerage_on_Other_Charge__c != null ? book.Differentiate_Brokerage_on_Other_Charge__c : 0) +
                                                           ( book.Differentiate_Brokerage_on_BSP__c != null ? book.Differentiate_Brokerage_on_BSP__c : 0 );
                BPMRec.PropStrength__Active__c = true;
                BPMRec.Differentiate_Brokerage__c = true;
                if(listOfBookingRecAnd.get(book.id).PropStrength__Broker_Payment_Milestones__r.size() > 0 ){
                    BPMRec.PropStrength__Amount_Paid_By_Customer__c = listOfBookingRecAnd.get(book.id).PropStrength__Broker_Payment_Milestones__r[0].PropStrength__Amount_Paid_By_Customer__c;
                    BPMRec.PropStrength__Brokerage_Due__c = listOfBookingRecAnd.get(book.id).PropStrength__Broker_Payment_Milestones__r[0].PropStrength__Brokerage_Due__c;
                }
                listOfBPM.add(BPMRec);
            }
        }
        
        system.debug(' bookId executed'+bookId);
        system.debug(' brokSchedId executed'+brokSchedId);
        if(!listOfBPM.isEmpty()) {
            insert listOfBPM;
            Id BrokerageDueId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();
            Map<Id, PropStrength__Application_Booking__c> bookBPMMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Status__c, DLD_Fees_Due__c,X10_Payment_Received_Date__c,X20_Payment_Received_Date__c,  Booking_Form_Verified__c,PropStrength__Property__r.PropStrength__Tower__r.UnRegister_Project__c,
                                                                                                                          DLD_Fees_Received__c, Booking_Form_Executed__c, PropStrength__Total_Paid_Percent__c, Oqood_Fees_Received__c, SPA_Executed__c, X9_5_Payment_Received_Date__c,
                                                                                                                          SPA_Execution_Date__c, PropStrength__Broker_Account__c, PropStrength__Project__r.RERA_Registered__c,Total_Payment_Receive_Percent__c,PropStrength__Tower__c,
                                                                                                                          (SELECT id,PropStrength__Booking_ID__r.PropStrength__Broker_Account__c,PropStrength__Brokerage_Due_Rs__c,
                                                                                                                           PropStrength__Booking_ID__r.PropStrength__Property__r.PropStrength__Property_Name__c,
                                                                                                                           PropStrength__Booking_ID__r.Name, PropStrength__Broker_Service_Tax__c
                                                                                                                           FROM PropStrength__Broker_Payment_Milestones__r WHERE PropStrength__Active__c = true AND PropStrength__Is_Paid__c = FALSE AND PropStrength__Due_Date__c = null AND Differentiate_Brokerage__c = true ORDER BY Order__c)
                                                                                                                          FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            
            system.debug('bookBPMMap ++'+bookBPMMap);
            List<PropStrength__Broker_Ledger__c> listOfBrokerLadgerRec = new List<PropStrength__Broker_Ledger__c>();
            for(PropStrength__Application_Booking__c book : bookBPMMap.values()) {
                for(PropStrength__Broker_Payment_Milestone__c bpm : book.PropStrength__Broker_Payment_Milestones__r) {
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
                
            }
            if(listOfBrokerLadgerRec.size() > 0)
                insert listOfBrokerLadgerRec;
            
        }            
    }
    
    public void finish(DataBase.BatchableContext BC){
        //   System.schedule('CreateBpmAndAdditionalBrokerage_Daily'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 0 ? * *', new CreateBpmAndAdditionalBrokerage() );
    }
    
}
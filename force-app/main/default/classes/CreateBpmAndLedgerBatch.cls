public class CreateBpmAndLedgerBatch implements DataBase.batchable <SObject> {
    
    
    public Database.querylocator start(DataBase.BatchableContext BC){
            return Database.getQueryLocator([SELECT Id,PropStrength__Booking_Through__c,Sobha_Connect_Verified__c,PropStrength__Broker_Account__c,
                                             PropStrength__Brokerage_Release_Schedule__c, PropStrength__Broker_Account__r.Expiry_Date__c, PropStrength__Property__r.PropStrength__Tower__r.UnRegister_Project__c,
                                             PropStrength__Broker_Account__r.PropStrength__Broker_Type__c,DLD_Fees_Received__c,DLD_Fees_Due__c,SPA_Executed__c,
                                             Booking_Form_Executed__c,X10_Payment_Received_Date__c,Total_Payment_Receive_Percent__c,Booking_Form_Verified__c,
                                             (SELECT Id, PropStrength__Amount_Paid_By_Customer__c, PropStrength__Brokerage_Type__c, PropStrength__Is_Paid__c, PropStrength__Due_Date__c, 
                                              PropStrength__Brokerage_Due_Rs__c, PropStrength__Broker_Service_Tax__c, Booking_Form_Audit_Approved__c, DLD_Fee_Received__c, SPA_Executed__c,
                                              Order__c, PropStrength__Active__c, BrokRelLineItem_Name__c
                                              FROM PropStrength__Broker_Payment_Milestones__r WHERE PropStrength__Active__c = true  
                                              ORDER BY Order__c),
                                             (SELECT Id from PropStrength__Payments_Cheques__r WHERE PropStrength__Amount_Due_Type__c ='DLD Fees' AND PropStrength__Balance__c = 0 limit 1)
                                             from PropStrength__Application_Booking__c 
                                             where PropStrength__Booking_Through__c = 'Broker' and PropStrength__Active__c = true and PropStrength__Broker_Account__c != null AND
                                             PropStrength__Brokerage_Release_Schedule__c != null and PropStrength__Booking_Date__c != null and PropStrength__Broker_Account__r.Expiry_Date__c >= TODAY
                                             AND PropStrength__Property__c != null AND PropStrength__Brokerage_Scheme__c != null AND Cancellation_Requested__c = false AND Booked_Date__c != null
                                            ]);     
    }
    
    public void execute(DataBase.BatchableContext BC,List<PropStrength__Application_Booking__c> newList){
        system.debug(' CreateBpmAndLedgerBatch executed');
        Set<Id> bookId = new Set<Id>();
        Set<Id> brokSchedId = new Set<Id>();  
        Set<String> setOfUniqBPMFilter = new Set<String>();  
        Set<Id> setOfUniq = new Set<Id>();  
        for(PropStrength__Application_Booking__c book : newList) {
            for(PropStrength__Broker_Payment_Milestone__c bpm : book.PropStrength__Broker_Payment_Milestones__r) {
                setOfUniqBPMFilter.add(book.Id+''+bpm.BrokRelLineItem_Name__c);
            }
            if(book.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c != null && book.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c =='Sobha Connect'){
                if(book.Sobha_Connect_Verified__c != null && book.Sobha_Connect_Verified__c == 'Verified'){
                    bookId.add(book.Id);
                    brokSchedId.add(book.PropStrength__Brokerage_Release_Schedule__c);
                }
            }
            else{
                bookId.add(book.Id);
                brokSchedId.add(book.PropStrength__Brokerage_Release_Schedule__c);
            }
        }
        system.debug(' bookId executed'+bookId);
        system.debug(' brokSchedId executed'+brokSchedId);
        system.debug(' brokSchedId executed--'+setOfUniqBPMFilter);
        if(!bookId.isEmpty() && !brokSchedId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookingBrokerScheMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Broker_Account__c, Total_Payment_Receive_Percent__c,
                                                                                                                                    PropStrength__Brokerage_Release_Schedule__c, PropStrength__Broker_Account__r.VAT_Registration_Status__c, 
                                                                                                                                    PropStrength__Broker_Account__r.VAT_Applicable_From__c, PropStrength__Brokerage_Payable__c, PropStrength__Primary_Customer__c 
                                                                                                                                    FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            Map<Id, PropStrength__Brokerage_Payment_Plan__c> brokScheBrokLineMap = new Map<Id, PropStrength__Brokerage_Payment_Plan__c>([SELECT Id, (SELECT Id, PropStrength__Brokerage_Due__c, name,BRS_Line_Item_Number__c,
                                                                                                                                                     PropStrength__Brokerage_Schedule_Type__c, PropStrength__Amount_Paid_By_Customer__c, 
                                                                                                                                                     PropStrength__Brokerage_Schedule_Name__c,Booking_Form_Audit_Approved__c, DLD_Fee_Received__c, SPA_Executed__c, 
                                                                                                                                                     Order__c   FROM PropStrength__Brokerage_Release_Schedule_Line_Items__r ORDER BY Order__c) 
                                                                                                                                         FROM PropStrength__Brokerage_Payment_Plan__c WHERE Id IN :brokSchedId]);
            List<PropStrength__Broker_Payment_Milestone__c> brokPliCreate = new List<PropStrength__Broker_Payment_Milestone__c>();
            system.debug(' CreateBpmAndLedgerBatch bookingBrokerScheMap'+bookingBrokerScheMap);
            system.debug(' CreateBpmAndLedgerBatch brokScheBrokLineMap'+brokScheBrokLineMap);
            
            if(!bookingBrokerScheMap.isEmpty() && !brokScheBrokLineMap.isEmpty()) {
                for(PropStrength__Application_Booking__c book : newList) {
                    if(bookingBrokerScheMap.containsKey(book.Id) && bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Release_Schedule__c != null && brokScheBrokLineMap.containsKey(bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Release_Schedule__c)) {
                        List<PropStrength__Brokerage_Release_Schedule_Line_Item__c> brokRelLineItem = brokScheBrokLineMap.get(bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Release_Schedule__c).PropStrength__Brokerage_Release_Schedule_Line_Items__r;                            
                        if(!brokRelLineItem.isEmpty()) {
                            system.debug(' brokRelLineItem ++'+brokRelLineItem);
                            for(PropStrength__Brokerage_Release_Schedule_Line_Item__c bli : brokRelLineItem) {
                                if(bli.BRS_Line_Item_Number__c != null && !setOfUniqBPMFilter.contains(book.Id+''+bli.BRS_Line_Item_Number__c)){                                        
                                    if(bli.PropStrength__Brokerage_Schedule_Type__c != null && bli.PropStrength__Brokerage_Schedule_Type__c == 'Standard' && bli.PropStrength__Brokerage_Due__c != null && bli.PropStrength__Amount_Paid_By_Customer__c != null) {
                                        Decimal cgst = 0.00;
                                        //Added by Deepak for VAT_Applicable_From__c check and Updated VAT Registration Status__c picklist value 'Register' to 'Yes' on 21-Aug-2024 as per Sushil's discussion
                                        if(bookingBrokerScheMap.get(book.Id).PropStrength__Broker_Account__r.VAT_Registration_Status__c != null && bookingBrokerScheMap.get(book.Id).PropStrength__Broker_Account__r.VAT_Registration_Status__c == 'Yes' && bookingBrokerScheMap.get(book.Id).PropStrength__Broker_Account__r.VAT_Applicable_From__c != null && bookingBrokerScheMap.get(book.Id).PropStrength__Broker_Account__r.VAT_Applicable_From__c >= System.Today()) {
                                            cgst = ((bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Payable__c * bli.PropStrength__Brokerage_Due__c)/100) * 0.05;
                                        }
                                        Map<String, String> checkMap = new Map<String, String>();
                                        if(bli.PropStrength__Amount_Paid_By_Customer__c != null) {
                                            if(book.Total_Payment_Receive_Percent__c != null && book.Total_Payment_Receive_Percent__c >= bli.PropStrength__Amount_Paid_By_Customer__c) {
                                                checkMap.put('PropStrength__Amount_check_Paid_By_Customer__c', 'true');
                                            } else {
                                                checkMap.put('PropStrength__Amount_check_Paid_By_Customer__c', 'false');
                                            }
                                        }
                                        if(bli.DLD_Fee_Received__c != null && bli.DLD_Fee_Received__c) {
                                            if(book.PropStrength__Payments_Cheques__r !=  null && book.PropStrength__Payments_Cheques__r.size() > 0) {
                                                checkMap.put('DLD_Fee_Received__c', 'true');
                                            } else {
                                                checkMap.put('DLD_Fee_Received__c', 'false');
                                            }
                                        }
                                        if(bli.Booking_Form_Audit_Approved__c != null && bli.Booking_Form_Audit_Approved__c ) {
                                            if(book.Booking_Form_Verified__c != null && book.Booking_Form_Verified__c) {
                                                checkMap.put('Booking_Form_Audit_Approved__c', 'true');
                                            } else {
                                                checkMap.put('Booking_Form_Audit_Approved__c', 'false');
                                            }
                                        }
                                        if(bli.SPA_Executed__c !=null && bli.SPA_Executed__c == true && book.PropStrength__Property__r.PropStrength__Tower__r!= null && book.PropStrength__Property__r.PropStrength__Tower__r.UnRegister_Project__c != null &&  book.PropStrength__Property__r.PropStrength__Tower__r.UnRegister_Project__c == false  ) {
                                            if(book.SPA_Executed__c  != null && book.SPA_Executed__c && bli.SPA_Executed__c) {
                                                checkMap.put('SPA_Executed__c', 'true');
                                            } else {
                                                checkMap.put('SPA_Executed__c', 'false');
                                            }
                                        }
                                        
                                        
                                        system.debug(bli.Id+'--checkMap ++'+checkMap);                                    
                                        if(!checkMap.isEmpty() && !checkMap.values().contains('false')) {                                                
                                            brokPliCreate.add(new PropStrength__Broker_Payment_Milestone__c(Booking_Form_Audit_Approved__c = bli.Booking_Form_Audit_Approved__c, 
                                                                                                            DLD_Fee_Received__c = bli.DLD_Fee_Received__c, SPA_Executed__c = bli.SPA_Executed__c, 
                                                                                                            Order__c = bli.Order__c, 
                                                                                                            BrokRelLineItem_Name__c = bli.BRS_Line_Item_Number__c,
                                                                                                            PropStrength__Applicant_Name__c=bookingBrokerScheMap.get(book.Id).PropStrength__Primary_Customer__c, 
                                                                                                            PropStrength__Booking_ID__c=book.Id, PropStrength__Brokerage_Type__c = bli.PropStrength__Brokerage_Schedule_Type__c, 
                                                                                                            PropStrength__Amount_Paid_By_Customer__c = bli.PropStrength__Amount_Paid_By_Customer__c, 
                                                                                                            PropStrength__Brokerage_Due__c = bli.PropStrength__Brokerage_Due__c, PropStrength__Active__c = TRUE, 
                                                                                                            PropStrength__Brokerage_Due_Rs__c = (bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Payable__c * bli.PropStrength__Brokerage_Due__c)/100 ,
                                                                                                            PropStrength__Broker_Service_Tax__c = 0));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
            if(!brokPliCreate.isEmpty()) {                
                try {
                    insert brokPliCreate;
                    List<PropStrength__Broker_Payment_Milestone__c> updateBPM = new LIst<PropStrength__Broker_Payment_Milestone__c>();
                    system.debug(' values inserted '+brokScheBrokLineMap);
                    List<PropStrength__Broker_Ledger__c> listOfBrokerLadgerRec = new List<PropStrength__Broker_Ledger__c>();
                    Id BrokerageDueId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();                    
                    
                    // spa conditions one 
                    Set<Id> bookIds = new Set<Id>();
                    for(PropStrength__Application_Booking__c book : newList) {                      
                        bookIds.add(book.Id);                            
                    }
                    
                    system.debug('bookIds ++'+bookIds);
                    
                    if(!bookIds.isEmpty()) {
                        Map<Id, PropStrength__Application_Booking__c> bookBPMMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Status__c, DLD_Fees_Due__c,X10_Payment_Received_Date__c,X20_Payment_Received_Date__c,  Booking_Form_Verified__c,PropStrength__Property__r.PropStrength__Tower__r.UnRegister_Project__c,
                                                                                                                                      DLD_Fees_Received__c, Booking_Form_Executed__c, PropStrength__Total_Paid_Percent__c, Oqood_Fees_Received__c, SPA_Executed__c, X9_5_Payment_Received_Date__c,
                                                                                                                                      SPA_Execution_Date__c, PropStrength__Broker_Account__c, PropStrength__Project__r.RERA_Registered__c,Total_Payment_Receive_Percent__c,PropStrength__Tower__c,
                                                                                                                                      (SELECT Id, PropStrength__Amount_Paid_By_Customer__c, PropStrength__Brokerage_Type__c, PropStrength__Is_Paid__c, PropStrength__Due_Date__c, BrokRelLineItem_Name__c,
                                                                                                                                       PropStrength__Brokerage_Due_Rs__c, PropStrength__Broker_Service_Tax__c, Booking_Form_Audit_Approved__c, DLD_Fee_Received__c, SPA_Executed__c,
                                                                                                                                       Order__c, PropStrength__Active__c
                                                                                                                                       FROM PropStrength__Broker_Payment_Milestones__r WHERE PropStrength__Active__c = true AND PropStrength__Is_Paid__c = FALSE AND PropStrength__Due_Date__c = null ORDER BY Order__c),
                                                                                                                                      (SELECT Id from PropStrength__Payments_Cheques__r WHERE PropStrength__Amount_Due_Type__c ='DLD Fees' AND PropStrength__Balance__c = 0 limit 1)
                                                                                                                                      FROM PropStrength__Application_Booking__c WHERE Id IN :bookIds]);
                        
                        system.debug('bookBPMMap ++'+bookBPMMap);
                        for(PropStrength__Application_Booking__c book : bookBPMMap.values()) {
                            for(PropStrength__Broker_Payment_Milestone__c bpm : book.PropStrength__Broker_Payment_Milestones__r) {
                                if(bpm.BrokRelLineItem_Name__c != null && !setOfUniqBPMFilter.contains(book.Id+''+bpm.BrokRelLineItem_Name__c)){
                                    Map<String, String> checkMap = new Map<String, String>();
                                    
                                    if(bpm.PropStrength__Amount_Paid_By_Customer__c != null) {
                                        if(book.Total_Payment_Receive_Percent__c !=  null && book.Total_Payment_Receive_Percent__c >= bpm.PropStrength__Amount_Paid_By_Customer__c) {
                                            checkMap.put('PropStrength__Amount_check_Paid_By_Customer__c', 'true');
                                        } else {
                                            checkMap.put('PropStrength__Amount_check_Paid_By_Customer__c', 'false');
                                        }
                                    }
                                    if(bpm.DLD_Fee_Received__c != null && bpm.DLD_Fee_Received__c) {
                                        if(book.PropStrength__Payments_Cheques__r != null && book.PropStrength__Payments_Cheques__r.size() > 0) {
                                            checkMap.put('DLD_Fee_Received__c', 'true');
                                        } else {
                                            checkMap.put('DLD_Fee_Received__c', 'false');
                                        }
                                    }
                                    if(bpm.Booking_Form_Audit_Approved__c != null && bpm.Booking_Form_Audit_Approved__c ) {
                                        if(book.Booking_Form_Verified__c != null && book.Booking_Form_Verified__c) {
                                            checkMap.put('Booking_Form_Audit_Approved__c', 'true');
                                        } else {
                                            checkMap.put('Booking_Form_Audit_Approved__c', 'false');
                                        }
                                    }
                                    if(bpm.SPA_Executed__c != null && bpm.SPA_Executed__c == true && book.PropStrength__Property__r.PropStrength__Tower__r != null&& book.PropStrength__Property__r.PropStrength__Tower__r.UnRegister_Project__c != null &&book.PropStrength__Property__r.PropStrength__Tower__r.UnRegister_Project__c == false  ) {
                                        if(book.SPA_Executed__c != null && book.SPA_Executed__c && bpm.SPA_Executed__c) {
                                            checkMap.put('SPA_Executed__c', 'true');
                                        } else {
                                            checkMap.put('SPA_Executed__c', 'false');
                                        }
                                    }
                                                                  
                                    system.debug('checkMap ++'+checkMap);                           
                                    if(!checkMap.isEmpty() && !checkMap.values().contains('false')) {
                                        bpm.PropStrength__Is_Paid__c = True;
                                        bpm.PropStrength__Due_Date__c = System.today();
                                        updateBPM.add(bpm);
                                        listOfBrokerLadgerRec.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c = book.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c= bpm.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Due_Rs__c = bpm.PropStrength__Brokerage_Due_Rs__c, PropStrength__Service_Tax__c = bpm.PropStrength__Broker_Service_Tax__c, RecordTypeId = BrokerageDueId, PropStrength__Brokerage_Type__c = 'Standard',  PropStrength__Amount_Due_Type__c = 'Against Invoice'));
                                    }
                                }
                            }
                        }                        
                    }            
                    if(listOfBrokerLadgerRec.size() > 0){
                        insert listOfBrokerLadgerRec; 
                        if(updateBPM.size() > 0)
                            update updateBPM;
                    }
                }
                Catch(Exception e){
                    System.debug('--------------Exception in creating bpm --------------------'+ e.getMessage());
                    System.debug('--------------Exception in creating bpm and ledger Line Number::'+ e.getLineNumber());
                }
            }
            
        }
    }
    
    public void finish(DataBase.BatchableContext BC){
        //   System.schedule('CreateBpmAndLedgerBatch_Daily'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 0 ? * *', new CreateBpmAndLedgerBatch() );
    }
}
public class TrackPaymentMilestoneController {
    public static boolean fromTPMDemandHandler = false;
    public static void generateTPM(List<Receipt__c> receiptList){
        
        Map<Id,List<Demand__c>> demandMap = new Map<Id,List<Demand__c>>(); 
        set<Id> bookingIdsSet = new set<Id>();
        set<Id> newReceiptsIdSet = new Set<Id>();
        Map<Id,List<Receipt__c>> newReceiptMap = new Map<Id,List<Receipt__c>>();
        Map<Id,Decimal> totalReceiptAmount = new Map<Id,Decimal>();
        List<String> bookingIdsList = new List<String>();
        Map<string,Demandwrapper> updateDemandMap = new Map<string,Demandwrapper>();
        List<Demand__c> updateDemandList = new List<Demand__c>();
        List<string> bidsList = new List<String>();
        List<string> newridsList = new List<string>();
        system.debug('I am new receipts:'+receiptList);
        
        for(Receipt__c receiptData : receiptList){
            bidsList.add(receiptData.Booking__c);
            newridsList.add(receiptData.id);
        }
        Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];
        if(tpmMetaData.active__c == true){
        List<Receipt__c> nReceiptList = [SELECT ID,amount_rs__c,booking__c,demand__c,Other_Charges_Type__c,booking__r.quotation__c 
                                         from receipt__c 
                                         where booking__r.createdDate >: tpmMetaData.Booking_Created_Date__c
                                         and booking__c IN : bidsList and Receipt_Status__c = 'Cleared' 
                                         and Registration_Collection_Control_Report__c = 0 and id IN : newridsList
                                         and Other_Charges_Type__c = null ORDER BY CreatedDate ASC
                                        ];
        for(Receipt__c receiptData : nReceiptList){
            
            bookingIdsSet.add(receiptData.booking__c);
            newReceiptsIdSet.add(receiptdata.Id);
            
            if(newReceiptMap.containsKey(receiptData.booking__c) && newReceiptMap.get(receiptData.booking__c) != null) {
                List<Receipt__c> lst_Recept = newReceiptMap.get(receiptData.booking__c);
                if(receiptData.Other_Charges_Type__c == null)
                lst_Recept.add(receiptData);
                newReceiptMap.put(receiptData.booking__c,lst_Recept); 
            }   
            else {
                if(receiptData.Other_Charges_Type__c == null)
                newReceiptMap.put(receiptData.booking__c, new List<Receipt__c> {receiptData});
            }     
        }
        
        //Get related receipts per booking and calculate total amount paid 
        for(Receipt__c receiptData : [SELECT ID,Amount_Rs__c,Booking__c FROM RECEIPT__C WHERE Id not IN : newReceiptsIdSet AND Booking__c IN : bookingIdsSet AND Receipt_Status__c = 'Cleared' and Registration_Collection_Control_Report__c = 0 and Other_Charges_Type__c = null ORDER BY CreatedDate ASC]){
            bookingIdsSet.add(receiptData.booking__c);
            
            if(totalReceiptAmount.containsKey(receiptData.booking__c) && totalReceiptAmount.get(receiptData.booking__c) != null) {
                if(receiptData.Amount_Rs__c != null){
                    Decimal totalAmount = totalReceiptAmount.get(receiptData.booking__c) + receiptData.Amount_Rs__c;   
                    totalReceiptAmount.put(receiptData.booking__c,totalAmount); 
                }
            }else {
                if(receiptData.Amount_Rs__c != null)
                    totalReceiptAmount.put(receiptData.booking__c, receiptData.Amount_Rs__c);
            }        
        }
        
        List<Demand__c> demandsList = new List<Demand__c>();
        Map<Id,List<demandWrapper>> unPaidDemandsMap = new Map<Id,List<demandWrapper>>();
        Map<Id,ReceiptWrapper> receiptWrap = new Map<Id,ReceiptWrapper>();
        List<Track_PaymentMilestone__c> tpmList = new List<Track_PaymentMilestone__c>();
        Map<Id,Decimal> bookingIdToTotalAmountDemanded = new Map<Id,Decimal>();
        
        demandsList = [SELECT ID,Booking__c,Total_Amount_with_Tax_Demanded__c,Payment_Milestones__c,Total_Paid_Amount__c  
                       FROM Demand__c WHERE Booking__c IN : bookingIdsSet and Other_Charges_Type__c = null and
                       Milestone_Name__c != 'Debit note for DLD Charges'
                       ORDER BY CreatedDate ASC];
        
        //Get related demands per booking
        for(Demand__c demand : demandsList){
            if(demandMap.containsKey(demand.booking__c) && demandMap.get(demand.booking__c) != null) {
                List<Demand__c> lst_Demand = demandMap.get(demand.booking__c);
                lst_Demand.add(demand);
                demandMap.put(demand.booking__c,lst_Demand); 
            }   
            else {
                demandMap.put(demand.booking__c, new List<Demand__c> {demand});
            }
            
            if(bookingIdToTotalAmountDemanded.containsKey(demand.booking__c) && bookingIdToTotalAmountDemanded.get(demand.booking__c) != null) {
                if(demand.Total_Amount_with_Tax_Demanded__c != null){
                    Decimal totalAmount = bookingIdToTotalAmountDemanded.get(demand.booking__c) + demand.Total_Amount_with_Tax_Demanded__c;   
                    bookingIdToTotalAmountDemanded.put(demand.booking__c,totalAmount); 
                }
            }   
            else {
                if(demand.Total_Amount_with_Tax_Demanded__c != null)
                    bookingIdToTotalAmountDemanded.put(demand.booking__c, demand.Total_Amount_with_Tax_Demanded__c);
            }
        }
        system.debug('I am in demandedmount:'+bookingIdToTotalAmountDemanded);
        List<Track_PaymentMilestone__c> tpmData = new List<Track_PaymentMilestone__c>();
        tpmData = [SELECT Id, Demand_Amount__c,Booking__c,Amount_Utilized_In_PaymentMilestone__c,
                   receipt__c,Payment_Milestone__c,Demand__c,Track_PaymentMilestone__c
                   FROM Track_PaymentMilestone__c 
                   WHERE booking__c IN : bookingIdsSet and Status__c != 'Reversed'
                   order by CreatedDate Asc];
        Map<string,List<Track_PaymentMilestone__c>> tpmMap = new Map<String, List<Track_PaymentMilestone__c>>();
        for(Track_PaymentMilestone__c tpm : tpmData){
            if(tpmMap.containsKey(tpm.Booking__c) && tpmMap.get(tpm.Booking__c) != null) {
                List<Track_PaymentMilestone__c> lst_tpm = tpmMap.get(tpm.Booking__c);
                lst_tpm.add(tpm);
                tpmMap.put(tpm.Booking__c,lst_tpm); 
            }   
            else {
                tpmMap.put(tpm.Booking__c, new List<Track_PaymentMilestone__c> {tpm});
            } 
        }
        
        for(Id bookingId : bookingIdsSet){
           
            if(demandMap.containsKey(bookingId) && demandMap.get(bookingId) != null){
                
                List<Demand__c> demandsInBookingList = demandMap.get(bookingId);
                Decimal totalDemandedAmount = 0;
                Decimal totalPaidAmount = 0;
                Integer count = 0;
                for(Demand__c demandData : demandsInBookingList){
                    Decimal pendingAmount = demandData.Total_Amount_with_Tax_Demanded__c - 
                        (demandData.Total_Paid_Amount__c != null ? demandData.Total_Paid_Amount__c : 0);
                    Decimal paidAmount = (demandData.Total_Paid_Amount__c != null ? demandData.Total_Paid_Amount__c : 0);
                    totalDemandedAmount = demandData.Total_Amount_with_Tax_Demanded__c + totalDemandedAmount;
                    system.debug('I am in demand:'+demandData);
                    system.debug('I am in totalDemandedAmount:'+totalDemandedAmount);
                    if(totalReceiptAmount.containsKey(bookingId) && totalReceiptAmount.get(bookingId) != null){
                        totalPaidAmount = totalReceiptAmount.get(bookingId);
                    }
                    if(totalDemandedAmount > totalPaidAmount){
                        count = count + 1;
                            if(unPaidDemandsMap.containsKey(demandData.booking__c) && unPaidDemandsMap.get(demandData.booking__c) != null) {
                                List<demandWrapper> lstDemand = unPaidDemandsMap.get(demandData.booking__c);
                                DemandWrapper dwobj = new DemandWrapper();
                            	dwobj.DemandId = demandData.id;
                            	dwobj.totalAmountDemanded = demandData.Total_Amount_with_Tax_Demanded__c;
                                if(count == 1){ 
                            		dwobj.unpaidAmount = totalDemandedAmount - totalPaidAmount;
                                }else{
                                	dwobj.unpaidAmount = demandData.Total_Amount_with_Tax_Demanded__c;
                                }    
                                system.debug('i am unpaidamount 124'+dwobj.unpaidAmount);
                                dwobj.paidAmount = paidAmount;
                            	dwobj.paymentMilestone = demandData.Payment_Milestones__c;
                                lstDemand.add(dwobj);
                                unPaidDemandsMap.put(demandData.booking__c,lstDemand);
                                system.debug('I am in unPaidDemandsMap 138:'+unPaidDemandsMap);
                            }else {
                                 DemandWrapper dw = new DemandWrapper();
                            	 dw.DemandId = demandData.id;
                            	 dw.totalAmountDemanded = demandData.Total_Amount_with_Tax_Demanded__c;
                                 if(count == 1){ 
                            		dw.unpaidAmount = totalDemandedAmount - totalPaidAmount;
                                 }else{
                                	dw.unpaidAmount = demandData.Total_Amount_with_Tax_Demanded__c;
                                 }
                                 system.debug('i am unpaidamount 135'+dw.unpaidAmount);
                                 dw.paidAmount = paidAmount;
                            	 dw.paymentMilestone = demandData.Payment_Milestones__c;
                            	 list<demandWrapper> dList = new List<demandWrapper>();
                            	 dList.add(dw);
                                unPaidDemandsMap.put(demandData.booking__c,dlist);
                                system.debug('I am in unPaidDemandsMap 149:'+unPaidDemandsMap);
                            }
						} 
                }
            }
        }
        
        // Create TrackPaymentMilestone
        for(Id booking : bookingIdsSet){
            system.debug('I am in create trackpayment milestone');
            
            list<Track_PaymentMilestone__c> bookingtpmList = tpmMap.get(booking);
            if(newReceiptMap.containsKey(booking) && newReceiptMap.get(booking) != null){
                List<Receipt__c> receipts = newReceiptMap.get(booking);
                if(unPaidDemandsMap.containsKey(booking) && unPaidDemandsMap.get(booking) != null){
                    List<demandWrapper> demands = unPaidDemandsMap.get(booking);
                    
                    for(demandWrapper demand : demands){
                        Decimal demandedAmount = demand.unpaidAmount;
                        demand.paidAmount = 0;
                        system.debug('I am in 166:'+demand +'demandedAmount:'+demandedAmount);
                        system.debug('I am in demand 171:'+demand);
                        for(Receipt__c recept : receipts){
                           
                            Decimal utilizedReceiptAmount = 0;
                            Decimal remainingAmount = 0;
                            boolean tpmExist = false;
                            system.debug('I am in 172:'+recept );
                            if(demandedAmount > 0){
                                if(receiptWrap.containsKey(recept.id) && receiptWrap.get(recept.id).completelyUsed != true || !(receiptWrap.containsKey(recept.id))){
                                    
                                    if(receiptWrap.containsKey(recept.id) && receiptWrap.get(recept.id) != null) {
                                        ReceiptWrapper rw = receiptWrap.get(recept.id);
                                        Decimal usedAmount =  0;
										Decimal balanceAmount = recept.Amount_Rs__c - rw.utilizedAmount;
                                        
                                        demandedAmount = demandedAmount > balanceAmount ? 
                                               demandedAmount - balanceAmount : 0;
											   
										// calculate how much amount used from receipt
                                           if(demand.unpaidAmount >= balanceAmount){
                                               rw.utilizedAmount = rw.utilizedAmount + balanceAmount ;  
                                               utilizedReceiptAmount = balanceAmount;
                                               remainingAmount = 0;
                                               demand.unpaidAmount = demand.unpaidAmount - utilizedReceiptAmount;
                                               demand.paidAmount = demand.paidAmount + utilizedReceiptAmount;
                                               rw.completelyUsed = true;
                                           }else {
                                               rw.utilizedAmount =  rw.utilizedAmount + demand.unpaidAmount;   
                                               utilizedReceiptAmount = demand.unpaidAmount;
                                               remainingAmount = balanceAmount - demand.unpaidAmount;
                                               demand.unpaidAmount = 0;
                                               demand.paidAmount = demand.paidAmount + utilizedReceiptAmount;
                                           }	   
									
                                        system.debug('I am used amount:'+usedAMount+'rw.utilizedamount:'+rw.utilizedAmount+' remainingAmount'+ remainingAmount);
                                        system.debug(' recept.Amount_Rs__c:'+ recept.Amount_Rs__c+'demand.unpaidAMount:'+demand.unpaidAMount);
										 
                                        receiptWrap.put(recept.id,rw); 
                                        updateDemandMap.put(demand.demandId,demand);
                                        system.debug('I am receiptwrap 196:'+rw);
                                        system.debug('I am demandwrap :'+demand);
                                    }   
                                    else {
									 demandedAmount = demandedAmount > recept.Amount_Rs__c ? 
                                               demandedAmount - recept.Amount_Rs__c : 0;
                                        ReceiptWrapper rwrap = new ReceiptWrapper();
                                        rwrap.receiptId = recept.id;
                                        rwrap.totalAmount = recept.Amount_Rs__c;
                                        rWrap.booking = recept.Booking__c;
                                        rWrap.quotation = recept.booking__r.quotation__c;
                                        if(demand.unpaidAmount >= recept.Amount_Rs__c){
                                               rwrap.utilizedAmount = recept.Amount_Rs__c;
                                               utilizedReceiptAmount = recept.Amount_Rs__c;
                                               remainingAmount = 0;
                                               demand.unpaidAmount = demand.unpaidAmount - utilizedReceiptAmount;
                                               demand.paidAmount = demand.paidAmount + utilizedReceiptAmount;
                                               rwrap.completelyUsed = true;
                                           }else{
                                               rwrap.utilizedAmount = demand.unpaidAmount;
                                               utilizedReceiptAmount = demand.unpaidAmount;
                                               remainingAmount = recept.Amount_Rs__c - demand.unpaidAmount;
                                               demand.unpaidAmount = 0;
                                               demand.paidAmount = demand.paidAmount + utilizedReceiptAmount;
                                           }
                                        receiptWrap.put(recept.id, rwrap);
                                        updateDemandMap.put(demand.demandId,demand);
                                        system.debug('I am receiptwrap :'+rwrap);
                                        system.debug('I am demandwrap :'+demand);
                                    }
                                    if(bookingtpmList != null && !bookingtpmList.isEmpty()){
                                        system.debug('I am bookingtpmlist:'+bookingtpmlist);
                                    for(Track_PaymentMilestone__c tpmrecord : bookingtpmList){
                                        if(tpmrecord.Booking__c == recept.Booking__c &&
                                    		tpmrecord.Demand__c == demand.demandid &&
                                    		tpmrecord.Receipt__c == recept.id &&
                                           	tpmrecord.Payment_Milestone__c == demand.paymentMilestone &&
                                          	!tpmList.contains(tpmrecord)){
                                               tpmExist = true;
                                                system.debug('I am tpmrecord in if:'+ tpmrecord);
                                           }
                                    }
                                    }
                                    if(tpmList != null && !tpmList.isEmpty()){
                                        system.debug('I am tpmList:'+tpmList);
                                    for(Track_PaymentMilestone__c trecord : tpmList){
                                        if(trecord.Booking__c == recept.Booking__c &&
                                    		trecord.Demand__c == demand.demandid &&
                                    		trecord.Receipt__c == recept.id &&
                                           	trecord.Payment_Milestone__c == demand.paymentMilestone
                                          	){
                                               tpmExist = true;
                                                system.debug('I am trecord in if:'+ trecord);
                                           }
                                    }
                                    }
                                    Track_PaymentMilestone__c tpm = new Track_PaymentMilestone__c();
                                    tpm.Booking__c = recept.Booking__c;
                                    tpm.Demand__c = demand.demandid;
                                    tpm.Receipt__c = recept.id;
                                    tpm.Payment_Milestone__c = demand.paymentMilestone;
                                    tpm.Utilized_Receipt_Amount__c = utilizedReceiptAmount;
                                    tpm.Remaining_Receipt_Amount__c = remainingAmount;
                                    if(remainingAmount > 0)
                                        tpm.Advance_Payment_Demand__c = true;
                                    if(tpmExist == false)
                                    	tpmList.add(tpm);
                                    system.debug('i am tpm:'+tpm);
                                }
                            }
                        }
                    }
                    
                    //update demand
                    for(DemandWrapper dWrap : updateDemandMap.values()){
                    	Demand__c d = new Demand__c();
                        d.id = dWrap.DemandId;
                    	d.Total_Paid_Amount__c = dWrap.paidAmount;
                    	updateDemandList.add(d);
                    	system.debug('I am demand:'+d);
                    }	
                    
                    //New Demand Creation on Advancepayment
                   System.debug('I am receiptWrap:'+receiptwrap);
                    for(ReceiptWrapper rWrap : receiptWrap.values()){
                        if(rWrap.utilizedAmount < rWrap.totalAmount && rWrap.completelyUsed == false){
                            if(!(bookingIdsList.contains(rwrap.booking))){
                            bookingIdsList.add(rWrap.booking);
                            }
                           
                        }System.debug('I am bookingIdsList:'+bookingIdsList);
                           
                        }                    
                   
                }else{
                   
                    for(Receipt__c recept : receipts){
                        if(!(bookingIdsList.contains(recept.booking__c))){
                            bookingIdsList.add(recept.booking__c);
                            System.debug('I am bookingIdsList1:'+bookingIdsList);
                        }
                    } 
                }
            }
        }
        
         system.debug('fromTPMDemandHandler' +fromTPMDemandHandler);
         if(fromTPMDemandHandler == false){
             if(bookingIdsList != null && !bookingIdsList.isEmpty()){
        		PaymentMilestoneController.updateAdvanceAmountInPM(bookingIdsList);
             }
         }
        
        if(tpmList != null && !tpmList.isEmpty()){
            Database.SaveResult[] resultLstPM = Database.Insert(tpmList);
        }
         if(updateDemandList != null && !updateDemandList.isEmpty()){
            Database.SaveResult[] resultdemandupdate = Database.update(updateDemandList);
        }
        }
    }
    
    public static void cancelTPM(List<string> inputReceiptsList){
        List<Track_PaymentMilestone__c> tpmList = new List<Track_PaymentMilestone__c>();
        List<Track_PaymentMilestone__c> updatetpmList = new List<Track_PaymentMilestone__c>();
        List<string> demandList = new List<string>();
        List<string> bookingPMList = new List<String>();
        List<Demand__c> updateDemandList = new List<Demand__c>();
        
         Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];
        if(tpmMetaData.active__c == true){
        tpmList = [select ID,status__c,Utilized_Receipt_Amount__c,booking__c,demand__c from Track_PaymentMilestone__c where 
                   Receipt__c IN : inputReceiptsList and Status__c != 'Reversed' and
                   booking__r.createdDate >: tpmMetaData.Booking_Created_Date__c
                  ];
        
        for(Track_PaymentMilestone__c tpm : tpmList){
            tpm.Status__c = 'Reversed';
            updatetpmList.add(tpm); 
            if(!demandList.contains(tpm.Demand__c)){
            	demandList.add(tpm.Demand__c);
            }
        }
        
        List<String> updatePMList = new List<string>();
        List<demand__c> getDemandList = [select id,Demand_Status__c,Total_Paid_Amount__c,AdvancePayment__c,Booking__c,
                                         Payment_Milestones__c from demand__c where id IN : demandList];
        for(Demand__c d : getDemandList){
            if(!(bookingPMList.contains(d.booking__c))){
            	bookingPMList.add(d.booking__c);
            }
            if(d.AdvancePayment__c == true){
            	//d.Demand_Status__c = 'Reversed';
                d.Total_Paid_Amount__c = 0;
            	updateDemandList.add(d);
                updatePMList.add(d.Payment_Milestones__c);
            }else{
                Decimal paidAmount = (d.Total_Paid_Amount__c != null ? d.Total_Paid_Amount__c : 0);
                for(Track_PaymentMilestone__c tpm : tpmList){ 
                    if(tpm.Demand__c == d.id){
                        if(paidAmount >= tpm.Utilized_Receipt_Amount__c){
                    		paidAmount = paidAmount - tpm.Utilized_Receipt_Amount__c;
                            d.Total_Paid_Amount__c = paidAmount;
            				updateDemandList.add(d);
                        }
                    }
                }
            }
        }
        
        if(updatetpmList.size() > 0) {
        	List<Database.SaveResult> results = Database.update(updatetpmList, false);
        }
        if(updateDemandList.size() > 0) {
        	List<Database.SaveResult> results = Database.update(updateDemandList, false);
        }
        if(updatePMList.size() > 0) {
        	paymentMilestoneController.cancelAdvancePM(updatePMList);
        }
        if(bookingPMList.size() > 0) {
        	paymentMilestoneController.updateAdvanceAmountInPM(bookingPMList);
        }
        }
    }
    
    public static void preRegistrationTPM(List<Receipt__c> inputReceiptsList){
        List<String> bookingidsList = new List<String>();
        List<Track_PaymentMilestone__c> createtpm = new List<Track_PaymentMilestone__c>();
        List<string> bidsList = new List<string>();
        List<string> nridsList = new List<string>();
        for(Receipt__c receiptData : inputReceiptsList){
            bidsList.add(receiptData.Booking__c);
            nridsList.add(receiptData.id);
        }
        Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];
        List<Receipt__c> nReceiptList = [SELECT ID,amount_rs__c,booking__c,demand__c from receipt__c 
                                         where booking__r.createdDate >: tpmMetaData.Booking_Created_Date__c
                                         and booking__c IN : bidsList and Receipt_Status__c = 'Cleared' 
                                         and id IN : nridsList
                                         ORDER BY CreatedDate ASC
                                        ];
        if(tpmMetaData.active__c == true){
        for(Receipt__c receipt : nReceiptList){
            bookingidsList.add(receipt.booking__c);
        }
        List<Demand__c> demandsList = [select id,booking__c FROM Demand__c 
                                       WHERE  Booking__c IN : bookingidsList and Milestone_Name__c = 'Debit note for DLD Charges'];
        List<Track_PaymentMilestone__c> tpList = [select id,receipt__c,Demand__c,Booking__c FROM Track_PaymentMilestone__c where 
                                                 booking__c IN : bookingidsList];
        for(Receipt__c recpt : nReceiptList){
            for(Demand__c demand : demandsList){
                if(recpt.booking__c == demand.booking__c){
                    Track_PaymentMilestone__c tpm = new Track_PaymentMilestone__c();
                    tpm.Booking__c = recpt.Booking__c;
                    tpm.Demand__c = demand.id;
                    tpm.Receipt__c = recpt.id;
                    tpm.Utilized_Receipt_Amount__c = recpt.Amount_Rs__c;
                    tpm.Remaining_Receipt_Amount__c = 0;
                    createtpm.add(tpm);
                }
            }
        }
         if(createtpm.size() > 0) {
        	List<Database.SaveResult> results = Database.insert(createtpm, false);
        }
        }
    }
    
    Public Class ReceiptWrapper {
        
        Public String receiptId = '';
        Public Decimal totalAmount = 0;
        Public Decimal utilizedAmount = 0;
        Public Boolean completelyUsed = false;
        public String quotation = '';
        public string booking = '';
        
    }
    
    Public Class DemandWrapper {
        
        Public String DemandId = '';
        Public Decimal totalAmountDemanded = 0;
        Public Decimal unpaidAmount = 0;
        Public Decimal paidAmount = 0;
        public String paymentMilestone = '';
    }
    
    @future
    public static void markAdvancePaymentOnPaymentRequest(map<string,string> bookingToPaymentRequestId){
         Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];
        map<string,Payment_Request__c> bookingIdToPaymentRequest = new map<string,Payment_Request__c>();
        if(tpmMetaData.active__c == true){
        for(Payment_Request__c pr : [select Id, Towards_Unit_Price_Amount__c, Booking__c from Payment_Request__c 
                                     where Booking__c IN : bookingToPaymentRequestId.keySet() and 
                                     Booking__r.createdDate >: tpmMetaData.Booking_Created_Date__c 
                                     order by createddate desc]){
            if(!bookingIdToPaymentRequest.containsKey(pr.Booking__c)){
                bookingIdToPaymentRequest.put(pr.Booking__c,pr);
            }
        }
        list<Payment_Request__c> prToUpdate = new list<Payment_Request__c>();
        for(Booking__c b : [select Id, Due_Payments__c from Booking__c where Id IN : bookingToPaymentRequestId.keySet() and createdDate >: tpmMetaData.Booking_Created_Date__c]){
            Payment_Request__c pr = bookingIdToPaymentRequest.get(b.Id);
            if(pr.Towards_Unit_Price_Amount__c > b.Due_Payments__c){
                pr.Advance_Payment__c = true;
                prToUpdate.add(pr);
            }
        }
        if(prToUpdate.size() > 0){
            try{
                update prToUpdate;
            }
            catch(Exception e){
                
            }
        }
        }
    }
    
}
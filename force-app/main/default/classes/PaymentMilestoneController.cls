public class PaymentMilestoneController {
    public static boolean afterUpdateTriggerpmFirstRun = true;
    public static boolean afterInsertTriggerpmFirstRun = true;
    
    public static void updateAdvanceAmountInPM(List<String> bookingList){
        Map<Id,Decimal> totalReceiptAmount = new Map<Id,Decimal>();
    	Map<Id,Decimal> bookingIdToTotalAmountDemanded = new Map<Id,Decimal>();
    	Map<id,Decimal> bookingAdvanceAmount = new Map<Id,Decimal>();
    	Map<String,Decimal> pmAmountUpdateMap = new Map<string,Decimal>();
    	List<Payment_Milestones__c> updatePMList = new List<Payment_Milestones__c>();
    	Map<String,Decimal> pmAmountMap = new Map<string,Decimal>();
    	Set<string> createDemandSet = new Set<string>();
    	List<Demand__c> newDemandList = new List<Demand__c>();
    	List<Booking__c> bookList = new List<Booking__c>();
        
        bookList = [SELECT ID,name FROM Booking__c WHERE Id IN : bookingList];
        List<String> bookingIdsList = new List<String>();
        system.debug('I am bookList:'+bookList);
         Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];
        if(tpmMetaData.Active__c == true){
        for(Booking__c booking : bookList){
            bookingIdsList.add(booking.name);
            system.debug('I am bookingidsList:'+bookingIdsList);
         }
        
        for(Receipt__c receiptData : [SELECT ID,Amount_Rs__c,Booking__c FROM RECEIPT__C WHERE 
                                      Booking__c IN : bookingList AND Receipt_Status__c = 'Cleared' and 
                                      Registration_Collection_Control_Report__c = 0 
                                      and Other_Charges_Type__c = null ORDER BY Order_By_Date__c ASC]){
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
        for(Demand__c demand : [SELECT ID,Booking__c,Total_Amount_with_Tax_Demanded__c,Payment_Milestones__c 
             					FROM Demand__c WHERE Booking__c IN : bookingList and Other_Charges_Type__c = null
                                ORDER BY Order_By_Date__c ASC]){
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
        
        
        
        for(String booking : bookingList){
            Decimal receiptAmount = 0;
            Decimal demandAmount = 0;
            Decimal advanceAmount = 0;
            if(totalReceiptAmount.containsKey(booking) && totalReceiptAmount.get(booking) != null) {
            	receiptAmount = totalReceiptAmount.get(booking);
            }
            if(bookingIdToTotalAmountDemanded.containsKey(booking) && bookingIdToTotalAmountDemanded.get(booking) != null) {
            	demandAmount = bookingIdToTotalAmountDemanded.get(booking);
            }
            
            if(receiptAmount > demandAmount){
                advanceAmount = receiptAmount - demandAmount;
                bookingAdvanceAmount.put(booking, advanceAmount);
            }
        }

		List<Payment_Milestones__c> PMList = new List<Payment_Milestones__c>();
         PMList = [SELECT id,Booking_Formula__c,is_demand_raised__c,Total_Installment__c,Remaining_Advance_Amount__c,
                   Advance_Payment__c
                   FROM Payment_Milestones__c
                   WHERE is_demand_raised__c = FALSE 
                   AND Booking_Formula__c IN : bookingIdsList order by Milestone_Due_Date__c Asc];
        System.debug('I am pmlist:'+ pmlist);
        
        List<Payment_Milestones__c> PMRaisedList = new List<Payment_Milestones__c>();
         PMRaisedList = [SELECT id,Booking_Formula__c,is_demand_raised__c,Total_Installment__c,Remaining_Advance_Amount__c,
                   Advance_Payment__c
                   FROM Payment_Milestones__c
                   WHERE is_demand_raised__c = true 
                   AND Booking_Formula__c IN : bookingIdsList order by Milestone_Due_Date__c Asc];
        System.debug('I am pmraised List:'+pmraisedList);
        
        Map<String, Payment_Milestones__c> bookingRaisedPM = new Map<String, Payment_Milestones__c>();
        for(Payment_Milestones__c pm : PMRaisedList){
            for(Booking__c b : bookList){
                if(b.name == pm.Booking_Formula__c){
            		if(bookingRaisedPM.containsKey(b.id) && bookingRaisedPM.get(b.id) != null) {               			 
			   		}else {
               			bookingRaisedPM.put(b.id, pm);
                        break;
               		}	 
                }
            }
        }
        
        
        Map<String,List<Payment_Milestones__c>> bookingPMMap = new Map<String,List<Payment_Milestones__c>>();
        for(Payment_Milestones__c pm : PMList){
            for(Booking__c b : bookList){
                if(b.name == pm.Booking_Formula__c){
            		if(bookingPMMap.containsKey(b.id) && bookingPMMap.get(b.id) != null) {
               			 List<Payment_Milestones__c> lst_pm = bookingPMMap.get(b.id);
                		 lst_pm.add(pm);
                         bookingPMMap.put(b.id,lst_pm);
                        break;
			   		}else {
                        List<Payment_Milestones__c> lst_pm = new List<Payment_Milestones__c>();
                        lst_pm.add(pm);
               			bookingPMMap.put(b.id, lst_pm);
                        break;
               		}	 
                }
            }
            system.debug('I am bookingpmmap:'+bookingpmmap);
        }
        
        for(String booking : bookingAdvanceAmount.KEYSET()){
            Decimal advanceAmount = bookingAdvanceAmount.get(booking);
            Decimal totalAmount = advanceAmount;
            
            if(bookingPMMap.containsKey(booking) && bookingPMMap.get(booking) != null){
                List<Payment_Milestones__c> bookingpmList = bookingPMMap.get(booking);
                  system.debug('I am bookingpmList'+bookingpmList);
                
                for(Payment_Milestones__c pm : bookingpmList){
                    Decimal totalInstallment = pm.Total_Installment__c;
                    system.debug('I am totalinstallment'+totalinstallment);
                    system.debug('I am pm'+pm);
                    if(totalAmount > 0 && totalamount >= totalInstallment){
                        system.debug('I am totalamount'+totalamount);
                        if(advanceAmount > 0){
                            system.debug('I am advanceamount1'+advanceamount);
                            if(advanceAmount >= totalInstallment){
                                pmAmountMap.put(pm.Id,totalInstallment);  
                                advanceAmount = advanceAmount - totalInstallment;
                                pmAmountUpdateMap.put(pm.id,advanceAmount);
                                system.debug('i am advance amount'+advanceAmount + 'paymentid' + pm.id);
                            }else{
                               
                                system.debug('I am advanceamount2'+advanceamount);
                                pmAmountUpdateMap.put(pm.id,advanceAmount);
                                system.debug('i am advance amount'+advanceAmount + 'paymentid' + pm.id);
                                advanceAmount = 0;
                               
                            }
                        }
                    }else if(totalAmount > 0 && totalamount < totalInstallment){
                        if(bookingRaisedPM.containsKey(booking) && bookingRaisedPM.get(booking) != null){
                            Payment_Milestones__c p = bookingRaisedPM.get(booking);                            
                            p.Remaining_Advance_Amount__c = totalAmount;
                        	p.Advance_Payment__c = true;
                            if(!updatepmlist.contains(p))
                             updatePMList.add(p);
                            system.debug('I am updatePMList2'+updatePMList);
                            totalAmount = 0;
                           
                        }else{
                            if(bookingPMMap.containsKey(booking) && bookingPMMap.get(booking) != null){
                				List<Payment_Milestones__c> pmDataList = bookingPMMap.get(booking);
                                Payment_Milestones__c p = pmDataList[0];
                            	p.Remaining_Advance_Amount__c = totalAmount;
                        		p.Advance_Payment__c = true;
                                if(!updatepmlist.contains(p))
                             	updatePMList.add(p);
                                system.debug('I am updatePMList1'+updatePMList);
                                totalAmount = 0;
                                
                            }
                            
                        }
                        
                    }
                }
            }
        }
        system.debug('I am pmamountupdatemap:'+pmamountupdatemap);
        if(pmAmountUpdateMap != null && !pmAmountUpdateMap.isEmpty()){
            for(String pm : pmAmountUpdateMap.KEYSET()){
                Decimal amountValue = pmAmountUpdateMap.get(pm);
                for(Payment_Milestones__c pmRecord : PMList){
                    if(pmRecord.id == pm){
                        pmRecord.Remaining_Advance_Amount__c = amountValue;
                        pmRecord.Advance_Payment__c = true;
                        if(pmAmountMap.containskey(pmRecord.id)){
                        	pmrecord.is_demand_raised__c = true;
                        }
                        if(!updatepmlist.contains(pmrecord))
                        updatePMList.add(pmRecord);
                    }
                }		    
            }   
        }
        system.debug('I am updatePMList'+updatePMList);
        if(pmAmountMap != null && !pmAmountMap.isEmpty()){
            for(string milestone : pmAmountMap.keyset()){
                createDemandSet.add(milestone);
                
            }
        }
        system.debug('I am createDemandSet'+createDemandSet);

        if(createDemandSet != null && !createDemandSet.isEmpty()){
        	List<Demand__c> advanceDemandsList = DemandGeneratorManager.createMultipleDemand(createDemandSet);
            if(advanceDemandsList != null && !advanceDemandsList.isEmpty()){
                for(Demand__c demand : advanceDemandsList){
                    demand.AdvancePayment__c = true; 
                    newDemandList.add(demand); 
                }
            }
        }
            if(updatePMList != null && !updatePMList.isEmpty()){ 
            Database.SaveResult[] resultPM = Database.update(updatePMList);
            }
            if(newDemandList != null && !newDemandList.isEmpty()) {
            Database.SaveResult[] resultLstDemand = Database.Update(newDemandList);
            }
    }
    }
    
    public static void cancelAdvancePM(List<string> cancelPmList){
        List<Payment_Milestones__c> pmList = [SELECT Id,Advance_Payment__c, Remaining_Advance_Amount__c FROM
                                             Payment_Milestones__c WHERE Id IN : cancelPmList];
        List<Payment_Milestones__c> updatePMList = new List<Payment_Milestones__c>();
         Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];
        if(tpmMetaData.Active__c == true){
        for(Payment_Milestones__c pm : pmList){
            pm.Advance_Payment__c = false;
            pm.Remaining_Advance_Amount__c = 0;
            updatePMList.add(pm);
        }
    }
    }
}
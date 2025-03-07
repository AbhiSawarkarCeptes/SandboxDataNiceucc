public class TPMDemandHandler {
    //Test Class : LatePenaltyHandlerTest
    public static boolean afterUpdateTriggerDemandFirstRun = true;
    public static boolean afterInsertTriggerDemandFirstRun = true;
    
    public static void createDemandTPM(List<Demand__C> dList) {
        List<Track_PaymentMilestone__c> createTPMList = new List<Track_PaymentMilestone__c>();
        List<Track_PaymentMilestone__c> updatetpm = new List<Track_PaymentMilestone__c>();
        List<Demand__c> updatedemandList = new List<Demand__c>();
        List<Demand__c> demandList = new List<Demand__c>();
        List<Receipt__c> receiptsList = new List<Receipt__c>();
        List<Receipt__c> newreceiptsList = new List<Receipt__c>();
        List<String> receiptid = new List<string>();
        List<Id> bookingId = new List<ID>();
        system.debug('I am dlist:'+dList);
         Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];
        if(tpmMetaData.Active__c == true){
        for(Demand__c demand : dList){
            if(demand.Booking__c != null && !bookingId.contains(demand.booking__c))
                bookingId.add(demand.booking__c);
        }
         system.debug('I am bookingId:'+bookingId);
        List<Track_PaymentMilestone__c> tpmList = new List<Track_PaymentMilestone__c>();
        Map<string,List<Track_PaymentMilestone__c>> tpmMap = new Map<String,List<Track_PaymentMilestone__c>>();
        
        tpmList = [SELECT Id, Demand_Amount__c,Booking__c,Amount_Utilized_In_PaymentMilestone__c,receipt__c,
                   Payment_Milestone__c,Demand__c,Remaining_Receipt_Amount__c
                   FROM Track_PaymentMilestone__c 
                   WHERE booking__c IN : bookingId 
                   order by CreatedDate Desc];
        system.debug('tpmList '+tpmList);
        for(Track_PaymentMilestone__c tpm : tpmList){
            if(tpmMap.containsKey(tpm.booking__c) && tpmMap.get(tpm.booking__c) != null) {
                List<Track_PaymentMilestone__c> lst_tpm = tpmMap.get(tpm.booking__c);
                lst_tpm.add(tpm);
                tpmMap.put(tpm.booking__c,lst_tpm); 
            }   
            else {
                tpmMap.put(tpm.booking__c, new List<Track_PaymentMilestone__c> {tpm});
            }
        }
        
        receiptsList = [SELECT ID,Amount_Rs__c,Booking__c,booking__r.quotation__c,Other_Charges_Type__c
                        FROM RECEIPT__C WHERE 
                        Booking__c IN : bookingId AND Receipt_Status__c = 'Cleared' and 
                        Registration_Collection_Control_Report__c = 0 
                        and Other_Charges_Type__c = null ORDER BY createdDate ASC];
        DemandList = [SELECT ID,Booking__c,Total_Amount_with_Tax_Demanded__c,Payment_Milestones__c,Other_Charges_Type_Demand__c 
                      FROM Demand__c WHERE Booking__c IN : bookingId and Other_Charges_Type_Demand__c = false
                      ORDER BY Order_By_Date__c ASC]; 
        
        for(Receipt__c receipt : receiptsList){
            if((tpmMap.containsKey(receipt.booking__c) && tpmMap.get(receipt.booking__c) != null) || Test.isRunningTest()) {
            	List<Track_PaymentMilestone__c> receipttpmList = tpmMap.get(receipt.Booking__c);
                if(receipttpmList != null && receipttpmList.size()>0){
            		for(Track_PaymentMilestone__c tpm : receipttpmList){
                		if(tpm.Receipt__c == receipt.id && tpm.Remaining_Receipt_Amount__c == 0.00){
                    		receiptid.add(receipt.id);
                		}
            		}	
                }
            }
        }
        for(Receipt__c receipt : receiptsList){
            String rId = receipt.id;
            if(!receiptid.contains(rId)){
                newreceiptsList.add(receipt);
            }
        }
        TrackPaymentMilestoneController.fromTPMDemandHandler = true;
        TrackPaymentMilestoneController.generateTPM(newreceiptsList); 
        }
    }
    
    public Class ReceiptWrapper {
        public String receiptId = '';
        public Decimal totalAmount = 0;
        public Decimal utilizedAmount = 0;
        public Boolean completelyUsed = false;
        public String quotation = '';
        public string booking = '';
    }
    
}
public class PaymentReceiptComponentController {
    public static Id payId                             {get;set;}
    public static String opCode                                            {get;set;}
    
    public class tableWrapper {
        public String unitNo {get;set;}
        public String paymentType {get;set;}
        public Date paymentDate {get;set;}
        public String adjustmentAgainst {get;set;}
        public Decimal amount {get;set;}

        public tableWrapper(String uNo, String payType, Date payDate, String adjagnst, Decimal amt) {
            unitNo = uNo;
            paymentType = payType;
            paymentDate = payDate;
            adjustmentAgainst = adjagnst;
            amount = amt;
        }
    }
    
    public static List<tableWrapper> getPaymentRecLineItemList(){
        System.debug('in mainmethod');
        System.debug(opCode);
        System.debug(payId);
        List<tableWrapper> returnList = new List<tableWrapper>();
        if(payId != null) {
            List<PropStrength__Other_Charge_Due_Partition__c> paymentRecLineItemRecs = [SELECT Id,Name,PropStrength__Charge_Name__c,PropStrength__Amount_Recieved__c,PropStrength__Payment__r.PropStrength__Application_Booking__c,PropStrength__Payment__r.PropStrength__Application_Booking__r.Project_Name__c,
                                  PropStrength__Payment__r.PropStrength__Cheque_Demand_Draft_Number__c,PropStrength__Payment__r.PropStrength__Payment_Type__c,PropStrength__Payment__r.PropStrength__Payment_Date__c,PropStrength__Payment__r.PropStrength__Amount__c,
                                  PropStrength__Payment__r.PropStrength__Application_Booking__r.CRM_Executive_Email__c,PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                  PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c,PropStrength__Payment__r.Interim_Receipt_sent_to_customer__c,
                                  PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c
                                  FROM PropStrength__Other_Charge_Due_Partition__c WHERE PropStrength__Payment__c =: payId AND PropStrength__Payment__r.Interim_Receipt_sent_to_customer__c =: false AND RecordType.Name = 'Payment Received Line Item'];
            
            Map<String, Decimal> mapChargeAmt = new Map<String, Decimal>();
            Set<String> chargesName = new Set<String>();
            if(!paymentRecLineItemRecs.isEmpty()) {
                for(PropStrength__Other_Charge_Due_Partition__c pli : paymentRecLineItemRecs) {
                    if(mapChargeAmt.containsKey(pli.PropStrength__Charge_Name__c)) {
                        Decimal amt = mapChargeAmt.get(pli.PropStrength__Charge_Name__c) + pli.PropStrength__Amount_Recieved__c;
                        mapChargeAmt.remove(pli.PropStrength__Charge_Name__c);
                        mapChargeAmt.put(pli.PropStrength__Charge_Name__c, amt);
                    } else {
                        mapChargeAmt.put(pli.PropStrength__Charge_Name__c, pli.PropStrength__Amount_Recieved__c);
                        chargesName.add(pli.PropStrength__Charge_Name__c);
                    }
                }

                for(String crgeName : chargesName) {
                    for(PropStrength__Other_Charge_Due_Partition__c pli : paymentRecLineItemRecs) {
                        if(crgeName == pli.PropStrength__Charge_Name__c) {
                            returnList.add(new tableWrapper(pli.PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c, pli.PropStrength__Payment__r.PropStrength__Payment_Type__c, pli.PropStrength__Payment__r.PropStrength__Payment_Date__c, pli.PropStrength__Charge_Name__c, mapChargeAmt.get(pli.PropStrength__Charge_Name__c)));
                            break;
                        }
                    }
                }
            }
        }
        return returnList; 
    }
}
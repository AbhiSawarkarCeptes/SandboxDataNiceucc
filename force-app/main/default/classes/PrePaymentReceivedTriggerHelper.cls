/*********************************************************************
* Class Name  :   PrePaymentReceivedTriggerHelper
* Description :   Helper class for the PrePaymentReceivedTrigger
* Created Date:   05/06/2022
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 30/06/2022
*********************************************************************/
public class PrePaymentReceivedTriggerHelper {
    //Added by Deepak sharma on 05 June 2023 to update Offer Valid Till Field on Offer Record
    //Last Modified by Deepak on 18 October 2023 to update Offer valid till date as per tower multiple hold duration
    public static void updateOfferValidTill(List<PropStrength__PrePayment_Received__c> prePaymentRecList, Map<Id, PropStrength__PrePayment_Received__c> newRecMap) {
        Set<Id> offerIds = new Set<Id>();
        for(PropStrength__PrePayment_Received__c prePay: prePaymentRecList) {
            if(prePay.PropStrength__Offer__c != null) {
                offerIds.add(prePay.PropStrength__Offer__c);                
            }
        }
        
        if(!offerIds.isEmpty()) {
            Map<Id, PropStrength__Offer__c> offerMap = new Map<Id, PropStrength__Offer__c>([SELECT Id, Hold_Amount__c, Total_Pre_Payment_Received__c, Payment_Method__c, PropStrength__Property__r.PropStrength__Tower__r.Payment_Method_Single_Hold_Duration__c, PropStrength__Property__r.PropStrength__Tower__r.Payment_Method_Multiple_Hold_Duration__c, PropStrength__Project__r.Payment_Method_Single_Hold_Duration__c, PropStrength__Project__r.Payment_Method_Multiple_Hold_Duration__c, (SELECT Id, PropStrength__Amount__c, Approval_Status__c FROM PropStrength__PrePayment_Received__r WHERE Id NOT IN :newRecMap.keySet()) FROM PropStrength__Offer__c WHERE Id IN :offerIds]);
            List<PropStrength__Offer__c> offerUpdateList = new List<PropStrength__Offer__c>();
            
            if(!offerMap.isEmpty()) {
                for(PropStrength__PrePayment_Received__c prePay: prePaymentRecList) {
                    if(prePay.PropStrength__Offer__c != null && offerMap.containsKey(prePay.PropStrength__Offer__c)) {
                        Decimal cmp = offerMap.get(prePay.PropStrength__Offer__c).Total_Pre_Payment_Received__c != null ? offerMap.get(prePay.PropStrength__Offer__c).Total_Pre_Payment_Received__c : 0.00;
                        if(offerMap.get(prePay.PropStrength__Offer__c).Hold_Amount__c > cmp && offerMap.get(prePay.PropStrength__Offer__c).Payment_Method__c == 'Multiple') {
                            if(prePay.PropStrength__Amount__c != null && prePay.PropStrength__Amount__c < 10000) {
                                Decimal daysOffer;
                                if(offerMap.get(prePay.PropStrength__Offer__c).PropStrength__Property__r.PropStrength__Tower__r.Payment_Method_Multiple_Hold_Duration__c != null) {
                                    daysOffer = offerMap.get(prePay.PropStrength__Offer__c).PropStrength__Property__r.PropStrength__Tower__r.Payment_Method_Multiple_Hold_Duration__c;
                                } else if(offerMap.get(prePay.PropStrength__Offer__c).PropStrength__Project__r.Payment_Method_Multiple_Hold_Duration__c != null) {
                                    daysOffer = offerMap.get(prePay.PropStrength__Offer__c).PropStrength__Project__r.Payment_Method_Multiple_Hold_Duration__c;
                                }
                                offerUpdateList.add(new PropStrength__Offer__c(Id = prePay.PropStrength__Offer__c, Offer_Valid_Till__c = daysOffer!=null?prePay.CreatedDate.addHours(Integer.valueOf(daysOffer)):null));
                            } else if(prePay.PropStrength__Amount__c != null && prePay.PropStrength__Amount__c >= 10000) {
                                if(!offerMap.get(prePay.PropStrength__Offer__c).PropStrength__PrePayment_Received__r.isEmpty()) {
                                    Boolean flag = FALSE;
                                    for(PropStrength__PrePayment_Received__c pre : offerMap.get(prePay.PropStrength__Offer__c).PropStrength__PrePayment_Received__r) {
                                        if(pre.Id != prePay.Id && pre.PropStrength__Amount__c >= 10000 && pre.Approval_Status__c == 'Rejected') {
                                            flag = TRUE;break;
                                        }
                                    }
                                    if(flag) {
                                        offerUpdateList.add(new PropStrength__Offer__c(Id = prePay.PropStrength__Offer__c, Offer_Valid_Till__c = prePay.CreatedDate.addHours(48)));
                                    } else {
                                        Decimal daysOffer;
                                        if(offerMap.get(prePay.PropStrength__Offer__c).PropStrength__Property__r.PropStrength__Tower__r.Payment_Method_Multiple_Hold_Duration__c != null) {
                                            daysOffer = offerMap.get(prePay.PropStrength__Offer__c).PropStrength__Property__r.PropStrength__Tower__r.Payment_Method_Multiple_Hold_Duration__c;
                                        } else if(offerMap.get(prePay.PropStrength__Offer__c).PropStrength__Project__r.Payment_Method_Multiple_Hold_Duration__c != null) {
                                            daysOffer = offerMap.get(prePay.PropStrength__Offer__c).PropStrength__Project__r.Payment_Method_Multiple_Hold_Duration__c;
                                        }
                                        offerUpdateList.add(new PropStrength__Offer__c(Id = prePay.PropStrength__Offer__c, Offer_Valid_Till__c = daysOffer!=null?prePay.CreatedDate.addHours(Integer.valueOf(daysOffer)):null));
                                    }
                                } else {
                                    offerUpdateList.add(new PropStrength__Offer__c(Id = prePay.PropStrength__Offer__c, Offer_Valid_Till__c = prePay.CreatedDate.addHours(48)));
                                }
                            }
                        }  
                    }
                }
                
                if(!offerUpdateList.isEmpty()) {
                    update offerUpdateList;
                }
            }
        }
    }
    
    //Added by Deepak sharma on 05 June 2023 to update Total Pre-Payment Received Field on Offer Record
    public static void updateTotalPrePaymentReceivedOffer(List<PropStrength__PrePayment_Received__c> prePaymentRecList, Map<Id, PropStrength__PrePayment_Received__c> prePaymentOldMap) {
        Set<Id> offerIds = new Set<Id>();
        for(PropStrength__PrePayment_Received__c prePay: prePaymentRecList) {
            if(prePay.PropStrength__Offer__c != null) {
                offerIds.add(prePay.PropStrength__Offer__c);                
            }
        }
        
        if(!offerIds.isEmpty()) {
            Map<Id, PropStrength__Offer__c> offerMap = new Map<Id, PropStrength__Offer__c>([SELECT Id, Total_Pre_Payment_Received__c FROM PropStrength__Offer__c WHERE Id IN :offerIds]);
            List<PropStrength__Offer__c> offerUpdateList = new List<PropStrength__Offer__c>();
            Map<Id, Decimal> offerAmount =  new Map<Id, Decimal>();
            
            for(PropStrength__PrePayment_Received__c prePay: prePaymentRecList) {
                if(prePay.Approval_Status__c == 'Approved' && prePay.Approval_Status__c != prePaymentOldMap.get(prePay.Id).Approval_Status__c) {
                    Decimal amount = prePay.PropStrength__Amount__c;
                    if(offerAmount.containsKey(prePay.PropStrength__Offer__c)) {
                        amount += offerAmount.get(prePay.PropStrength__Offer__c);
                    }
                    offerAmount.put(prePay.PropStrength__Offer__c, amount);
                }
            }
            
            if(!offerAmount.isEmpty()) {
                for(Id keyId: offerAmount.keySet()) {
                    if(offerMap.containsKey(keyId) && offerAmount.containsKey(keyId)) {
                        offerUpdateList.add(new PropStrength__Offer__c(Id= keyId, Total_Pre_Payment_Received__c = (offerMap.get(keyId).Total_Pre_Payment_Received__c != null ? offerMap.get(keyId).Total_Pre_Payment_Received__c : 0.00) + offerAmount.get(keyId)));
                    }
                }
                
                if(!offerUpdateList.isEmpty()) {
                    update offerUpdateList;
                }
            }
        }
    }

    //Added by Deepak sharma on 29 June 2023 to check total count of Pre payment record on offer as per single and multiple
    public static void checkCountOfPrePay(List<PropStrength__PrePayment_Received__c> prePaymentRecList) {
        Set<Id> offIds = new Set<Id>();

        for(PropStrength__PrePayment_Received__c prePay : prePaymentRecList) {
            if(prePay.PropStrength__Offer__c != null) {
                offIds.add(prePay.PropStrength__Offer__c);
            }
        }

        if(!offIds.isEmpty()) {
            Map<Id, PropStrength__Offer__c> offMap = new Map<Id, PropStrength__Offer__c>([SELECT Id, Name, Payment_Method__c, (SELECT Id FROM PropStrength__PrePayment_Received__r) FROM PropStrength__Offer__c WHERE Id IN :offIds]);
            if(!offMap.isEmpty()) {
                for(PropStrength__PrePayment_Received__c prePay : prePaymentRecList) {
                    if(prePay.PropStrength__Offer__c != null && offMap.containsKey(prePay.PropStrength__Offer__c)) {
                        if(offMap.get(prePay.PropStrength__Offer__c).Payment_Method__c == 'Single' && offMap.get(prePay.PropStrength__Offer__c).PropStrength__PrePayment_Received__r.size() >= 1) {
                            prePay.addError('More than one Payment is not allowed for the ' + offMap.get(prePay.PropStrength__Offer__c).Name);
                        } else if(offMap.get(prePay.PropStrength__Offer__c).Payment_Method__c == 'Multiple' && prePay.PropStrength__Payment_Mode__c != 'Credit Card' && prePay.PropStrength__Payment_Mode__c != 'Website' && offMap.get(prePay.PropStrength__Offer__c).PropStrength__PrePayment_Received__r.size() >= 2) {
                            prePay.addError('More than two Payment is not allowed for the ' + offMap.get(prePay.PropStrength__Offer__c).Name);
                        } else if(offMap.get(prePay.PropStrength__Offer__c).Payment_Method__c == 'Multiple' && (prePay.PropStrength__Payment_Mode__c == 'Credit Card' || prePay.PropStrength__Payment_Mode__c == 'Website') && offMap.get(prePay.PropStrength__Offer__c).PropStrength__PrePayment_Received__r.size() >= 3) {
                            prePay.addError('More than three Payment is not allowed for the ' + offMap.get(prePay.PropStrength__Offer__c).Name);
                        }
                    }
                }
            }
        }
    }

    //Added by Deepak sharma on 30 June 2023 to update cheque number of Pre payment record on the basis of payment mode on insert
    public static void updateChequeNumber(List<PropStrength__PrePayment_Received__c> prePaymentRecList) {
        for(PropStrength__PrePayment_Received__c prePay : prePaymentRecList) {
            if(prePay.PropStrength__Payment_Mode__c == 'Cheque' || prePay.PropStrength__Payment_Mode__c == 'CDM-Cheque') {
                prePay.PropStrength__Cheque_Demand_Draft_No__c = prePay.Instrument_Number__c != null ? prePay.Instrument_Number__c : '';
            }
        }
    }

    //Added by Deepak sharma on 30 June 2023 to update cheque number of Pre payment record on the basis of payment mode on update
    public static void updateChequeNumberOnUpdate(List<PropStrength__PrePayment_Received__c> prePaymentRecList, Map<Id, PropStrength__PrePayment_Received__c> prePaymentOldMap) {
        for(PropStrength__PrePayment_Received__c prePay : prePaymentRecList) {
            if(prePay.PropStrength__Payment_Mode__c != prePaymentOldMap.get(prePay.Id).PropStrength__Payment_Mode__c && (prePay.PropStrength__Payment_Mode__c == 'Cheque' || prePay.PropStrength__Payment_Mode__c == 'CDM-Cheque')) {
                prePay.PropStrength__Cheque_Demand_Draft_No__c = prePay.Instrument_Number__c != null ? prePay.Instrument_Number__c : '';
            }
        }
    }
}
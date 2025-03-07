/*********************************************************************
 * Class Name  :   BrokerPayoutLWCController
 * Description :   Helper Class For BrokerPayoutLWC (LWC Component)
 * Created Date:   02/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 03/01/2024
 *********************************************************************/
public class BrokerPayoutLWCController {
    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> accountName(String searchKeyWrd) {
        List<AccountWrapper> wrapperList = new List<AccountWrapper>();
        Set<Id> preventAccountDupli = new Set<Id>();
        List<PropStrength__Broker_Ledger__c> brokerLedgerList = new List<PropStrength__Broker_Ledger__c>();
        if(searchKeyWrd != '') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            brokerLedgerList =  [SELECT PropStrength__Broker_Account__c, PropStrength__Broker_Account__r.Name, Id FROM PropStrength__Broker_Ledger__c WHERE PropStrength__Broker_Account__r.Name LIKE :searchKeyWrd];
        } else {
            brokerLedgerList =  [SELECT PropStrength__Broker_Account__c, PropStrength__Broker_Account__r.Name, Id FROM PropStrength__Broker_Ledger__c WHERE PropStrength__Broker_Account__C != NULL];
        }
        for(PropStrength__Broker_Ledger__c rec : brokerLedgerList) {
            if(!preventAccountDupli.contains(rec.PropStrength__Broker_Account__c)) {
                wrapperList.add(new AccountWrapper(rec.PropStrength__Broker_Account__c, rec.PropStrength__Broker_Account__r.Name));
            }
            preventAccountDupli.add(rec.PropStrength__Broker_Account__c);
        }
        return wrapperList;
    }

    public class AccountWrapper {
        @AuraEnabled public Id recId;
        @AuraEnabled public String recName;
        public AccountWrapper(Id recId, String recName) {
            this.recId = recId;
            this.recName = recName;
        }
    }

    @AuraEnabled(cacheable=false)
    public static Account  getAccountDetails(Id accountId) {
        return [SELECT Id, Name, RecordType.Name, PropStrength__Broker_Type__c, Registration_Passport_Number__c, TRN_Number__c, 
                (SELECT Id, Name, PropStrength__Broker_Payment_Milestone__c, 
                PropStrength__Broker_Payment_Milestone__r.Name,PropStrength__Broker_Payment_Milestone__r.App_Booking_Name__c,
                PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Due_With_Service_Tax__c, 
                PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Paid__c, 
                PropStrength__Brokerage_Type__c, PropStrength__Total_Brokerage_Due__c, RecordType.Name 
                FROM PropStrength__Broker_Ledgers__r 
                WHERE RecordType.Name = 'Brokerage Due' AND PropStrength__Broker_Payment_Milestone__c != Null AND PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__r.PropStrength__Active__c = true
                  AND PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__r.PropStrength__Status__c != 'Booking_Cancelled' 
                 AND PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__r.PropStrength__Status__c != 'Booking Reallocated') 
                FROM Account WHERE Id =: accountId];
    }

    @AuraEnabled(cacheable=false)
    public static string saveTheLedgers(String draftValueList){
        try {
            List<Object> listOfObjects = (List<Object>) JSON.deserializeUntyped(draftValueList);
            Set<Id> brokerLedgerId = new Set<Id>();
            for (Object obj : listOfObjects) {
                Map<String, Object> map1 = (Map<String, Object>) obj;
                brokerLedgerId.add(((String)map1.get('id')));
            }

            List<PropStrength__Broker_Ledger__c> brkLedgerList = new List<PropStrength__Broker_Ledger__c>();
            
            if(!brokerLedgerId.isEmpty()) {
                Id brkLedgerRecordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
                Map<Id, PropStrength__Broker_Ledger__c> brokerLedgersMap = new Map<Id, PropStrength__Broker_Ledger__c>([SELECT Id, PropStrength__Broker_Payment_Milestone__c, PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Due_With_Service_Tax__c, PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Paid__c FROM PropStrength__Broker_Ledger__c WHERE Id IN :brokerLedgerId]);
                
                Map<Id, Decimal> brkMilePay = new Map<Id, Decimal>();

                for (Object obj : listOfObjects) {
                    Map<String, Object> map1 = (Map<String, Object>) obj;
                    Id brkLedId = (String)map1.get('id');
                    String paidAmountStr = (String)map1.get('PropStrength__Paid_Amount__c');
                    Decimal paidAmount = Decimal.valueOf(paidAmountStr == null ? '0' : paidAmountStr);
                    if(brkMilePay.containsKey(brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__c)) {
                        Decimal updatePA = brkMilePay.get(brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__c) + paidAmount;
                        brkMilePay.remove(brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__c);
                        brkMilePay.put(brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__c, updatePA); 
                    } else {
                        brkMilePay.put(brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__c, paidAmount + (brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Paid__c != null ? brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Paid__c : 0));
                    }
                }

                System.debug('brkMilePay***');
                System.debug(brkMilePay);

                for (Object obj : listOfObjects) {
                    Map<String, Object> map1 = (Map<String, Object>) obj;
                    Id brkLedId = (String)map1.get('id');
                    String dateInputFld = (String)map1.get('PropStrength__Date__c');
                    dateInputFld = dateInputFld.substring(0, dateInputFld.indexOf('.'));
                    dateInputFld += 'Z';
                    Datetime dt = Datetime.newInstanceGmt(
                        Integer.valueOf(dateInputFld.substring(0, 4)), 
                        Integer.valueOf(dateInputFld.substring(5, 7)), 
                        Integer.valueOf(dateInputFld.substring(8, 10)),
                        Integer.valueOf(dateInputFld.substring(11, 13)),
                        Integer.valueOf(dateInputFld.substring(14, 16)),
                        Integer.valueOf(dateInputFld.substring(17, 19)) 
                    );

                    String paidAmountStr = (String)map1.get('PropStrength__Paid_Amount__c');
                    Decimal paidAmount = Decimal.valueOf(paidAmountStr);

                    Decimal totPaidAmt = brkMilePay.get(brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__c);
                    System.debug('map1.get(PropStrength__Broker_Payment_Mode__c)---'+map1.get('PropStrength__Broker_Payment_Mode__c'));
                    System.debug('map1.get(PropStrength__Check_No__c)---'+map1.get('PropStrength__Check_No__c'));
                    brkLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Running_Amount__c = brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Due_With_Service_Tax__c - totPaidAmt, 
                                                                         PropStrength__Broker_Account__c = brokerLedgersMap.get(brkLedId).PropStrength__Broker_Account__c, 
                                                                         RecordTypeId = brkLedgerRecordTypeId, 
                                                                         PropStrength__Broker_Payment_Type__c = 'Against Installment', 
                                                                         PropStrength__Broker_Payment_Mode__c = (String)map1.get('PropStrength__Broker_Payment_Mode__c'), 
                                                                         PropStrength__Date__c = dt.date(), 
                                                                         PropStrength__Paid_Amount__c = paidAmount, 
                                                                         Remarks1__c = (String)map1.get('Remarks__c'),
                                                                         Status__c = (String)map1.get('Status__c'),
                                                                         PropStrength__Check_No__c = (String)map1.get('PropStrength__Check_No__c'), 
                                                                         PropStrength__Broker_Payment_Milestone__c = brokerLedgersMap.get(brkLedId).PropStrength__Broker_Payment_Milestone__c));
                }
            }
            if(!brkLedgerList.isEmpty()) {
                try{
                    for(PropStrength__Broker_Ledger__c bl : brkLedgerList) {
                        System.debug('bl.PropStrength__Check_No__c*---'+bl.PropStrength__Check_No__c);
                        bl.PropStrength__Cheque_No__c = bl.PropStrength__Check_No__c;
                        //BrokerPayoutLWCController.insertRecord(bl.PropStrength__Running_Amount__c, bl.PropStrength__Broker_Account__c, bl.RecordTypeId, bl.PropStrength__Broker_Payment_Type__c, bl.PropStrength__Broker_Payment_Mode__c, bl.PropStrength__Date__c, bl.PropStrength__Paid_Amount__c, bl.PropStrength__Check_No__c, bl.PropStrength__Broker_Payment_Milestone__c);
                    }
                    insert brkLedgerList;
                    return 'Success';
                } catch(Exception e) {
                    return e.getMessage();
                }
            } else {
                return 'Fail';
            }
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @Future(callout=true)
    public static void insertRecord(Decimal runningAmt, Id brkAcc, Id recType, String payType, String payMode, Date dt, Decimal paidAmt, String checkNo, Id brkMSId) {
        PropStrength__Broker_Ledger__c brokerLedgerRecord = (new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c = brkAcc, RecordTypeId = recType, PropStrength__Broker_Payment_Type__c = payType, PropStrength__Broker_Payment_Mode__c = payMode, PropStrength__Date__c = dt, PropStrength__Paid_Amount__c = paidAmt, PropStrength__Cheque_No__c = checkNo, PropStrength__Broker_Payment_Milestone__c = brkMSId));
        insert brokerLedgerRecord; 
    }

    @AuraEnabled
    public static List<String> searchPLValues(){
        try {
            List<String> picklistValues = new List<String>();
            SObjectType sObjectType = Schema.getGlobalDescribe().get('PropStrength__Broker_Ledger__c');

            if (sObjectType != null) {
                SObjectField sObjectField = sObjectType.getDescribe().fields.getMap().get('PropStrength__Broker_Payment_Mode__c');

                if (sObjectField != null) {
                    List<Schema.PicklistEntry> picklistEntries = sObjectField.getDescribe().getPicklistValues();

                    for (Schema.PicklistEntry entry : picklistEntries) {
                        picklistValues.add(entry.getLabel());
                    }
                }
            }

            return picklistValues;
        } catch (Exception e) {
            return new List<String>{e.getMessage()};
        }
    }
}
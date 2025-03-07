/*********************************************************************
 * Class Name  :   PrePaymentReceivedTrigger
 * Description :   Trigger on PropStrength__PrePayment_Received__c
 * Created Date:   05/06/2022
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Deepak Sharma
    Last Modified By :   Deepak Sharma 30/06/2022
 *********************************************************************/
trigger PrePaymentReceivedTrigger on PropStrength__PrePayment_Received__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            PrePaymentReceivedTriggerHelper.checkCountOfPrePay(Trigger.new);
            PrePaymentReceivedTriggerHelper.updateChequeNumber(Trigger.new);
        }
        if(Trigger.isUpdate) {
            PrePaymentReceivedTriggerHelper.updateChequeNumberOnUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            PrePaymentReceivedTriggerHelper.updateOfferValidTill(Trigger.new, Trigger.newMap);
        }
        if(Trigger.isUpdate) {
            PrePaymentReceivedTriggerHelper.updateTotalPrePaymentReceivedOffer(Trigger.new, Trigger.oldMap);
        }
    }
}
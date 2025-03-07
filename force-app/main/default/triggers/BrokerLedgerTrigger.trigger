/*********************************************************************
 * Class Name  :   BrokerLedgerTrigger
 * Description :   Trigger on PropStrength__Broker_Ledger__c
 * Created Date:   27/11/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Deepak Sharma
    Last Modified By :   Deepak Sharma 27/11/2023
 *********************************************************************/
trigger BrokerLedgerTrigger on PropStrength__Broker_Ledger__c (after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUndelete) {
            BrokerLedgerTriggerController.maintainRollUpOnBrokerPaymentMS(Trigger.new, Trigger.newMap, '');
        }
        if(Trigger.isUpdate) {
            BrokerLedgerTriggerController.maintainRollUpOnBrokerPaymentMS(Trigger.new, Trigger.oldMap, 'Update');
            BrokerLedgerTriggerController.callApprovalProcessOnUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete) {
            BrokerLedgerTriggerController.maintainRollUpOnBrokerPaymentMS(Trigger.old, Trigger.oldMap, '');
        }
        if(Trigger.isInsert) {
            BrokerLedgerTriggerController.callApprovalProcessOnInsert(Trigger.new);
        }
    }
}
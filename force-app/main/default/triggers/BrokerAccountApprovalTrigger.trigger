/*********************************************************************
 * Trigger Name  :   BrokerAccountApprovalTrigger
 * Created Date:    30/05/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :  Gourav Gour 30/05/2024
 *********************************************************************/
trigger BrokerAccountApprovalTrigger on Broker_Account_Approval_History__c (before insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            BrokerAccountApprovalHelper.updateFieldOnBroker(Trigger.new, Trigger.oldMap);
        }
    }
}
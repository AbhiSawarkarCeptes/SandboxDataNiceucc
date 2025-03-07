/*********************************************************************
 * Trigger Name  :   PaymentPlanTrigger
 * Created Date:   27/12/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 27/12/2023
 *********************************************************************/
trigger PaymentPlanTrigger on PropStrength__Payment_Plan__c (before insert, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            PaymentPlanTriggerHelper.fillCheckValidTill(Trigger.new);
        }
    }
}
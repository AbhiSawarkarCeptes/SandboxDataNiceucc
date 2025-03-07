/*********************************************************************
 * Trigger Name  :   BrokerageSchemeTrigger
 * Created Date:   27/12/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 27/12/2023
 *********************************************************************/
trigger BrokerageSchemeTrigger on PropStrength__Brokerage_Scheme__c (before insert, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            BrokerageSchemeTriggerHelper.fillCheckEndDate(Trigger.new);
        }
    }
}
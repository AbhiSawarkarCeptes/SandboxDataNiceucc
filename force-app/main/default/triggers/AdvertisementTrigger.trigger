/*********************************************************************
 * Class Name  :   AdvertisementTrigger
 * Description :   AdvertisementTrigger on PropStrength__Advertisement__c
 * Created Date:   20/06/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 21/06/2023
 *********************************************************************/
trigger AdvertisementTrigger on PropStrength__Advertisement__c (before insert, after update, after delete, after undelete, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            AdvertisementTriggerHelper.showErrorAmtCheck(Trigger.new);
        }
        if(Trigger.isUpdate) {
            AdvertisementTriggerHelper.showErrorAmtCheckOnUpd(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            AdvertisementTriggerHelper.updateCountOnMarketChannel(Trigger.new, Trigger.oldMap);
            // AdvertisementTriggerHelper.updateTotalBudgetCost(Trigger.new, Trigger.oldMap);
            AdvertisementTriggerHelper.updateBudgetedCost(Trigger.new, Trigger.oldMap);        //Added by Amrit Sharma 09/08/2023 (Update BudgetedCost field on Marketing Channel)
        }
        if(Trigger.isUndelete) {
            AdvertisementTriggerHelper.showErrorAmtCheck(Trigger.new);
        }

        if(Trigger.isDelete) {
            AdvertisementTriggerHelper.totalBudgetCost(Trigger.old);
        }
    }
}
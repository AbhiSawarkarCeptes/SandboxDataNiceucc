trigger BRC_PR_AllocationTrigger on BRC_PR_Allocation__c (before insert,before update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            BRC_PR_AllocationTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            for(BRC_PR_Allocation__c bpa : Trigger.new){
                if(
                    Trigger.oldMap.get(bpa.Id).Deallocated__c
                    || (!FeatureManagement.checkPermission('Allow_BRC_PR_Untagging') && !UserInfo.getProfileId().contains('00e1t000001CBXG'))
                ){
                    bpa.addError('BRC-PR Allocations cannot be edited!');
                }
                
            }
        }
    }
    
}
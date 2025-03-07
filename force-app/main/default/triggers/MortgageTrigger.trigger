/* Bypass Framework Enabled */
trigger MortgageTrigger on Mortgage__c (before update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    
    List<Mortgage__c> mortgageList = New List <Mortgage__c>();
    List<Id> mIds = new List<Id>();
    List<Id> mIdsToCheck = new List<Id>();
    List<Mortgage__c> mForValidationCheck = new List<Mortgage__c>();
    for(Mortgage__c m : trigger.new){
        if(trigger.oldmap.get(m.Id).Status__c != m.Status__c){
            mIds.add(m.Id);
            mIdsToCheck.add(m.Id);
            mForValidationCheck.add(m);
        }
    }
    
    if(!System.isFuture() && !System.isBatch()){
        MortgageTriggerClass.checkApprovalValidation(mForValidationCheck);
        MortgageTriggerClass.updateComments(mIds,mIdsToCheck);
    }
    
}
trigger MarketingChannelTrigger on Marketing_Channel__c (before insert, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            MarketingChannelTriggerHelper.showErrorAmtCheck(Trigger.new);
        }
        if(Trigger.isUpdate) {
            MarketingChannelTriggerHelper.showErrorAmtCheckOnUpd(Trigger.new, Trigger.oldMap);
        }
    }
}
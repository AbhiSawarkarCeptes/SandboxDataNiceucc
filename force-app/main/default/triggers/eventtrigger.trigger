/* Bypass Framework Enabled */
trigger eventtrigger on Events__c (after insert,after update,before insert,before update) {

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    switch on  Trigger.operationType {
        when AFTER_INSERT {
            eventtrgrhandler.afterinsert();

        }
        when BEFORE_INSERT{
            eventtrgrhandler.beforeinsert(trigger.new, trigger.oldMap);
            eventtrgrhandler.eventEndDateValidation(trigger.new, null);
            eventtrgrhandler.calculateSalesForCurrentAndLastYear(trigger.new, null);
            eventtrgrhandler.calculateNoOfSites(trigger.new,null);
        }
        when BEFORE_UPDATE{
            eventtrgrhandler.beforeinsert(trigger.new, trigger.oldMap);
            eventtrgrhandler.eventApprovalValidation(trigger.new, trigger.oldMap);
            eventtrgrhandler.eventStatusUpdate(trigger.new, trigger.oldMap);
            eventtrgrhandler.eventEndDateValidation(trigger.new, trigger.oldMap);
            eventtrgrhandler.calculateSalesForCurrentAndLastYear(trigger.new, trigger.oldMap);
            eventtrgrhandler.calculateNoOfSites(trigger.new, trigger.oldMap);
            eventtrgrhandler.updateOldDateValues(trigger.new, trigger.oldMap);
            eventtrgrhandler.validateVideoShootAttachments(trigger.new, trigger.oldMap);
        }
        when AFTER_UPDATE {
            eventtrgrhandler.afterinsert();
            
            eventtrgrhandler.sendEmailForDigitalShow(trigger.new, trigger.oldMap);
            eventtrgrhandler.shareEventOnApproval(trigger.new, trigger.oldMap);
            
            eventtrgrhandler.sendEmailToDevelopmentTeamForVideoShoot(trigger.new, trigger.oldMap);
            
        }
    }
}
/* Bypass Framework Enabled */
trigger SendSMSTrigger on SMS_Schedule_SMS_c__c (after Insert) 
{     
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    set<Id> smsIds = new set<Id>();
    system.debug('trigger execution begins');
    for(SMS_Schedule_SMS_c__c smsList : trigger.new)
    {
        if(smsList.Id != null && smsList.Sender_Mobile__c != null )
        {
            smsIds.add(smsList.Id);   
            system.debug('sms list id >>>' +smsList.Id);  
            system.debug('Sender mobile>> '+smsList.Sender_Mobile__c);                       
        }  
    }         
    if(trigger.isAfter && trigger.isInsert)
    {    
        
        SMSFutureHandler.outboundSMS(smsIds);
        
    }  
}
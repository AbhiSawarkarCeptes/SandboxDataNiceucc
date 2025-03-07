/* Bypass Framework Enabled */
trigger Customer_Registrationtrgr on Customer_Registration__c (before insert,before update,after insert, after update) {
   
    String dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    dummy = 'dummy';
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    if(trigger.isInsert && trigger.isAfter){
        for(Customer_Registration__c cr :trigger.new){
            if((cr.Token__c == null || cr.Token__c == '') && Integration_Info__c.getValues('Token API') != null && Integration_Info__c.getValues('Token API').Active__c && (cr.Vertical__c == 'CRM' || cr.Vertical__c == 'Collection')){
                customerregistrationhandler.sendToTokenAPI(cr.Id);
            }
        }
    }
    switch on  Trigger.operationType {
        when AFTER_INSERT,AFTER_UPDATE {
            customerregistrationhandler.afterinsert();
        }
        when BEFORE_INSERT {
            customerregistrationhandler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            customerregistrationhandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        when AFTER_DELETE {
            
        }
    }
    
    if(Trigger.isUpdate && Trigger.isAfter) {
        customerRegistrationNotifier.sendNotification(Trigger.new, Trigger.oldMap);
    }
}
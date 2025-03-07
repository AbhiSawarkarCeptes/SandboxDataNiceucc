/* Bypass Framework Enabled */
trigger BrokerRegFieldUpdateTrigger on Broker_Registration_Approval_Request__c (after insert,after update,before insert,before update) {

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
    switch on  Trigger.operationType {
        when AFTER_UPDATE {
            BrokerRegFieldUpdateReqController.updateFieldOnBroker(Trigger.new);
        }
    }

}
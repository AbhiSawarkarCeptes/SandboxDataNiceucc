/* Dual Bypass Framework Enabled */
trigger brokerRegistrationTrigger on Broker_Registration__c (after insert,after update,before insert,before update) {
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
    if( bypassSettingInstance.Bypass_Backend_Automations__c || bypassSettingInstance.Bypass_Broker_Reg_Trigger__c || ApexBypassUtility.bypass_Broker_Reg_Trigger){
        return;
    }
    
    SWITCH ON Trigger.operationType {
        
        WHEN BEFORE_INSERT{
            Map<ID,Broker_Registration__c> tempEmptyMap = new Map<ID,Broker_Registration__c>();
            brokerRegistrationTrghandler.beforeinsert(Trigger.new, tempEmptyMap);
                        
            /******************************************************************************************************************
            Method  : processBrokerRegFieldsBeforeSave
            Purpose : NICE - Apex class handler method for before insert, encrypts mobile numbers & emails if they are provided.
            Author  : Artee Varma
            ******************************************************************************************************************/
            
            brokerRegistrationTrghandler.processBrokerRegFieldsBeforeSave(trigger.new);
        }
        WHEN BEFORE_UPDATE{
            brokerRegistrationTrghandler.beforeupdate(Trigger.new, trigger.oldMap);
                                    
            /******************************************************************************************************************
            Method  : processBrokerRegFieldsBeforeUpdate
            Purpose : NICE - Apex class handler method for before update, encrypts mobile numbers & emails if they are provided.
            Author  : Artee Varma
            ******************************************************************************************************************/
            
            brokerRegistrationTrghandler.processBrokerRegFieldsBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        WHEN AFTER_INSERT{
            /* For future */
        }
        WHEN AFTER_UPDATE {
            brokerRegistrationTrghandler.sendAgreementForCHRMOpsApproval(trigger.new, trigger.oldMap);
            brokerRegistrationTrghandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }   
}
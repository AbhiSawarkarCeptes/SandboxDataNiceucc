trigger StandLeadTrigger on Stand_Lead__c (before insert, after insert, before update,after update) {

    
  
    if (Trigger.isBefore && Trigger.isInsert) {
        StandLeadTriggerHandler.beforeInsert();
    }
   
    if (Trigger.isAfter && Trigger.isInsert) {
        StandLeadTriggerHandler.afterInsert();
    }
   
}
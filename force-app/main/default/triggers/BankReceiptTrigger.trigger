trigger BankReceiptTrigger on Bank_Receipt__c (before insert,after insert) {
	
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            BankReceiptTriggerHandler.beforeInsert(Trigger.new);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            X_XSD_Util.processInit(Trigger.oldMap,Trigger.newMap);//SOB-2137
        }
    }
    
}
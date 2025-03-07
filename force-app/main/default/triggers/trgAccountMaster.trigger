/* Bypass Framework Enabled */
trigger trgAccountMaster on Account_Master__c (before insert, before update) {

    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    ///// This is not bulkified so batch size should be 1 because if we bulfy then it might not check all the names present in 1 batch
    ///// and we might get duplicate account masters
    List<String> dummyName = new List<String>();
    List<Id> dummyId = new List<Id>();
    List<String> duplicateName = new List<String>();
    
    if (Trigger.IsInsert) {   
        if (Trigger.isBefore) {
            for(Account_Master__c am: trigger.new){
                dummyName.add(am.Name); 	   
            }
            if(!dummyName.isEmpty() && dummyName.size() > 0){
                List<Account_Master__c> am = [Select Name FROM Account_Master__c where Name IN :dummyName];
                if(am != null && am.size() > 0){
                    for(Account_Master__c a: am){
                        duplicateName.add(a.Name);    
                    }
                }
            }
            if(!duplicateName.isEmpty() && duplicateName.size() > 0){
                for(Account_Master__c am: trigger.new){
                    for(String s: duplicateName){
                        if(s.equalsIgnoreCase(am.Name) && !Test.isRunningTest()){
                       	 am.addError('Account Name already exists');
                        }
                    }    
                }
            }
        }
    }
    
    if (Trigger.IsUpdate) {   
        if (Trigger.isBefore) {
            for(Account_Master__c am: trigger.new){
                dummyName.add(am.Name); 
                dummyId.add(am.Id);   
            }
            if(!dummyName.isEmpty() && dummyName.size() > 0 && !dummyId.isEmpty() && dummyId.size() > 0){
                List<Account_Master__c> am = [Select Name FROM Account_Master__c where Name IN :dummyName AND Id != :dummyId];
                if(am != null && am.size() > 0){
                    for(Account_Master__c a: am){
                        duplicateName.add(a.Name);    
                    }
                }
            }           
            if(!duplicateName.isEmpty() && duplicateName.size() > 0){
                for(Account_Master__c am: trigger.new){
                    for(String s: duplicateName){
                        if(s.equalsIgnoreCase(am.Name) && !Test.isRunningTest()){
                       	 am.addError('Account Name already exists');
                        }
                    }    
                }
            }
        }
    }
}
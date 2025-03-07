/* Bypass Framework Enabled */
trigger Validationfortimeslot on Time_Slot_For_Handover__c (before Update, before insert) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    system.debug('enter'+ '');
    if(Trigger.isUpdate){               
        List<Time_Slot_For_Handover__c> tslist = New List<Time_Slot_For_Handover__c>();
        Map<string,Time_Slot_For_Handover__c> tsMap= new Map<string,Time_Slot_For_Handover__c>();
        Set<string> enameSet =new set<string>();
        Set<String> timeSet =new set<string>();
        set<date> dateSet =new set<date>();    
        Set<string> statusset = new Set<string>();
        for(Time_Slot_For_Handover__c ts :Trigger.newmap.values()){
            if(ts.CRM_Excutive__c!=null){
                enameSet.add(ts.CRM_Excutive__c); 
                }
            if(ts.Timings__c!=null||ts.Timings__c!=''){
                timeSet.add(ts.Timings__c); 
            } 
            if(ts.Scheduled_Date__c!=null){
                dateSet.add(ts.Scheduled_Date__c); 
             }
             if(ts.Status__c =='Confirmed'){
                statusset .add(ts.Status__c); 
             }
            system.debug('CRM Excutive name' + enameset);            
            system.debug('Timing' + timeset);
            system.debug('date' + dateset);
        }
        
        for(Time_Slot_For_Handover__c ts:[Select id,Name,CRM_Excutive__c,Timings__c,Scheduled_Date__c,
                                          Booking__r.Primary_Applicant_Name__c,Booking__c,Booking__r.name from Time_Slot_For_Handover__c
                                          where   CRM_Excutive__c IN :enameset and Timings__c IN :timeset and          
                                          Scheduled_Date__c IN :dateset and Status__c = 'Confirmed' AND ID NOT IN :Trigger.New])
        {
            string key = ts.CRM_Excutive__c + ts.Scheduled_Date__c + ts.Timings__c;            
            tsMap.put(key,ts);
            system.debug('Key' + key);
            
        }
        
        for(Time_Slot_For_Handover__c ts :Trigger.newmap.values()){
            string key = ts.CRM_Excutive__c + ts.Scheduled_Date__c + ts.Timings__c;
            if(tsMap.containsKey(key) && ts.Multiple_Units__c == False)
            {
                ts.adderror('please change the slot, the slot is already blocked for you for '+tsmap.get(key).Booking__r.name);
                
            }
            
        }
        
    }   
    
   /* if(Trigger.isBefore){
        for(Time_Slot_For_Handover__c slot : Trigger.new){
            if(Trigger.isInsert || slot.Email__c != Trigger.oldMap.get(slot.Id).Email__c){
                slot.Encrypted_Email__c = EncryptionUtility.encryptText(String.valueOf(slot.Email__c));
            }
        }
    } */
    
}
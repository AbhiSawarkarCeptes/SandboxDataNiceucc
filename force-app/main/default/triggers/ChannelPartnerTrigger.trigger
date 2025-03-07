/* Bypass Framework Enabled */
trigger ChannelPartnerTrigger on Channel_Partner__c(After Insert, After Delete, After Update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    if (Trigger.IsUpdate) {   
        if (Trigger.isAfter) {
            for(Channel_Partner__c ch : trigger.new){
                system.debug('Line 11 erlier'+trigger.oldMap.get(ch.id).Sales_Manager__c+'Now'+ch.Sales_Manager__c);
                //Add new share if field has changed
                if(ch.Sales_Manager__c != trigger.oldMap.get(ch.id).Sales_Manager__c){
                    system.debug('Line 14 erlier'+trigger.oldMap.get(ch.id).Sales_Manager__c+'Now'+ch.Sales_Manager__c);
                    if(ch.Sales_Manager__c != Null){
                        Channel_Partner__Share  aShare = New Channel_Partner__Share ();
                        
                        aShare.UserOrGroupID = ch.Sales_Manager__c;
                        aShare.ParentID = ch.Id;
                        aShare.AccessLevel = 'Read';
                        aShare.RowCause = 'Manual';
                        
                        Insert aShare;
                    }
                    //Delete old share
                    if(ch.Sales_Manager__c != trigger.oldMap.get(ch.id).Sales_Manager__c){
                        
                        for(Channel_Partner__c  chsr : trigger.old){
                            Channel_Partner__Share  [] ChShare = [Select ID, RowCause From Channel_Partner__Share  Where UserOrGroupID = :chsr.Sales_Manager__c Limit 1];
                            if(!ChShare.isEmpty())
                                if(ChShare [0].RowCause == 'Manual')
                                delete ChShare ;
                        }
                    }
                }
            }
        }
    }
    if (Trigger.IsInsert) {   
        if (Trigger.isAfter) {
            for(Channel_Partner__c ch : trigger.new){
                Channel_Partner__Share  aShare = New Channel_Partner__Share ();
                if(ch.Sales_Manager__c != Null){
                    aShare.UserOrGroupID = ch.Sales_Manager__c;
                    aShare.ParentID = ch.Id;
                    aShare.AccessLevel = 'Read';
                    aShare.RowCause = 'Manual';
                    system.debug('ch.Id :: '+ch.Id);
                    try{
                        Insert aShare;
                    }Catch(Exception e){
                        system.debug('Exception ::'+e);
                    }                
                }
            }
        }
    }
}
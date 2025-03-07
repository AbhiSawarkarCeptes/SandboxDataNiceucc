/* Bypass Framework Enabled */
trigger FetchCDR_Account on Account (After Update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        if(Trigger.isAfter) {
            if(Trigger.isUpdate) {
                User u = [SELECT Id, Name, BitVoice_Agent_Ext__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
                if(u.Profile.Name == 'Presales') {
                    for(Account a : Trigger.New) {
                        if(! ClickToDial.SetOfAfterIDs.contains(a.Id)) {
                            if(a.Primary_Number__c != null) {
                                ClickToDial.fetchCRD(a.Id, a.Primary_Number__c);
                            }else {
                                ClickToDial.fetchCRD(a.Id, a.Primary_Number_Formula__c);
                            }
                            ClickToDial.SetOfAfterIDs.add(a.Id);
                        }
                    }
                }
            }
        }
    }
}
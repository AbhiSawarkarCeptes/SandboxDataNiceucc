trigger AutoPopulateNumbers on Lead (Before Insert, Before Update, After Insert, After Update)  {
 /*   if(Trigger.isBefore) {  
        if(Trigger.isInsert) {
            User u = [SELECT Id, Name, BitVoice_Agent_Ext__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            if(u.Profile.Name == 'Presales') {
                List<Incoming_Call__c> ins = [SELECT Id, Agent_Extension__c, Phone_Number__c, UID__c, countryCode__c FROM Incoming_Call__c WHERE Agent_Extension__c =: u.BitVoice_Agent_Ext__c AND CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 1];
                Set<String> phoneNumbers = new Set<String>();
                for(Incoming_Call__c i : ins) {
                    phoneNumbers.add(ParseNumber.fetchNumber(i.Phone_Number__c));
                }
                List<Lead> leadList = [SELECT Id FROM Lead WHERE MobilePhone IN: phoneNumbers OR Primary_Number__c IN: phoneNumbers OR Primary_Number_Formula__c IN: phoneNumbers];
                for(Lead ld : Trigger.New) {
                    ld.MobilePhone = ParseNumber.fetchNumber(ld.MobilePhone);
                    if(ld.OwnerId == u.Id) {
                        for(Incoming_Call__c ino : ins) {
                            if(ino.Agent_Extension__c == u.BitVoice_Agent_Ext__c) {
                                String fullNumber = ParseNumber.fetchNumber(ino.Phone_Number__c);
                                if((ld.MobilePhone != fullNumber) && (ld.Primary_Number__c != fullNumber) && (ld.Primary_Number_Formula__c != fullNumber) && leadList.size()<1) {
                                    if((ld.MobilePhone != fullNumber) || (ld.Primary_Number__c != fullNumber) || (ld.Primary_Number_Formula__c != fullNumber)) {
                                        String countryCode = ParseNumber.fetchNumber(ino.countryCode__c);
                                        
                                        if(ino.Phone_Number__c.startsWith('971')) {
                                            ld.Primary_Number__c = '0'+ino.Phone_Number__c.subString(3, ino.Phone_Number__c.length());
                                        }else if(ino.Phone_Number__c.startsWith('0')) {
                                            ld.Primary_Number__c = ino.Phone_Number__c;
                                        }else {
                                            ld.Primary_Number__c = '00'+ino.Phone_Number__c;
                                        }
                                        
                                        ld.Primary_Number__c = ino.Phone_Number__c;
                                        
                                        if(countryCode == '' || countryCode == '0') {
                                            ld.RDS_Country_Code__c = '+971';
                                        }else {
                                            ld.RDS_Country_Code__c = '+'+countryCode;
                                        }
                                        ld.MobilePhone = fullNumber.replace(countryCode, '');
                                        //ld.First_Call_Attempted_By__c = u.Name;
                                        //ld.First_Call_Attempt_Date__c = System.Now(); 
                                        //ld.Is_Serviced__c = true;
                                        ld.Current_UID__c = ino.UID__c;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if(Trigger.isUpdate) {
            User u = [SELECT Id, Name, BitVoice_Agent_Ext__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            for(Lead ld : Trigger.New) {
               if(Trigger.OldMap.get(ld.Id).MobilePhone != Trigger.NewMap.get(ld.Id).MobilePhone) { 
                    ld.MobilePhone = ParseNumber.fetchNumber(ld.MobilePhone);
                    ld.Primary_Number__c = '0'+ParseNumber.fetchNumber(ld.MobilePhone);
               }
            }
            if(u.Profile.Name == 'Presales') {
                for(Lead ld : Trigger.New) {  
                    if((! ClickToDial.SetOfBeforeIDs.contains(ld.Id))) {
                        if(ld.OwnerId == u.Id) {
                            //ld.Last_Call_Attempted_By__c = u.Name;
                            //ld.Last_Call_Attempt_Date__c = System.Now();
                        }
                        //=====Change Ownewr if Digital Incoming-Calls======
                            Lead l = [SELECT Owner.Alias FROM Lead WHERE Id =: ld.Id];
                            if(l.Owner.Alias == 'dinco') {
                            system.debug('==== match with dinco ====');
                                ld.OwnerId = u.Id;
                            }
                        //==================================================
                        //=============Check for Auto Retire================
                            
                           if(ld.Last_Call_Attempt_Status__c == 'No Contact'){
                                if(ld.bitVoice_Count__c == 0) {
                                    ld.bitVoice_Count__c = 1;
                                }else {
                                    ld.bitVoice_Count__c = Ld.bitVoice_Count__c + 1;
                                }
                           }else {
                               ld.bitVoice_Count__c = 0;  
                           }
                           
                        //==================================================
                        ClickToDial.SetOfBeforeIDs.add(ld.Id);
                    }
                    //==================Auto Retire===================
                        Map<String,Auto_Retire_Status__c> stat = Auto_Retire_Status__c.getAll();
                        if(ld.bitVoice_Count__c > 6 || stat.keySet().contains(ld.Last_Call_Attempt_Status__c)) {
                            ld.Status= 'Lost';
                            ld.Reason_For_Lost__c = 'Non contactable';
                        }
                    //================================================
                    //===============Auto Retire If Not Interested=================
                        if(ld.Last_Call_Attempt_Status__c == 'Not Interested') {
                           ld.Status= 'Lost';
                           ld.Reason_For_Lost__c = 'Not Interested';
                        }
                   //==============================================================
                   
                   //======Process Builder - Update Web Language and Promoters on Lead=======
                       ld.Promoters__c = u.Id;
                       ld.Website_Language__c = ld.Preferred_Language_Promoters__c;
                   //========================================================================
                }
            }
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            if(checkRecursive.runOnce()) { //===24.07.2019===
                User u = [SELECT Id, Name, BitVoice_Agent_Ext__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
                if(u.Profile.Name == 'Presales') {  // u.Profile.Name == 'System Administrator' --------> To Remove
                    Set<ID> leadIdSet = new Set<ID>();
                    for(Lead l : Trigger.New) {
                        if(! ClickToDial.SetOfAfterIDs.contains(l.Id)) {
                            if(!l.isConverted) {
                                if(l.Primary_Number__c != null) {
                                    ClickToDial.fetchCRD(l.Id, l.Primary_Number__c);
                                }else {
                                    ClickToDial.fetchCRD(l.Id, l.Primary_Number_Formula__c);
                                }
                                
                                ClickToDial.SetOfAfterIDs.add(l.Id);
                                
                                //===========Auto-Convert Leads==============
                                    Map<String, Lead_Auto_Convert_Status__c> allStatus = Lead_Auto_Convert_Status__c.getAll();
                                    if((Trigger.OldMap.get(l.Id).Last_Call_Attempt_Status__c != Trigger.newMap.get(l.Id).Last_Call_Attempt_Status__c) && allStatus.keySet().contains(l.Last_Call_Attempt_Status__c.toLowerCase())) {
                                        ClickToDial.autoConvertLead(l.Id);
                                    }
                                //===========================================
                            }
                        }
                        
                        //===========Followup Calls===========
                            Map<String, Lead_Followup_Status__c> leadFollowupStatus = Lead_Followup_Status__c.getAll();
                            if(Trigger.OldMap.get(l.Id).Latest_Next_Action_Date__c != Trigger.newMap.get(l.Id).Latest_Next_Action_Date__c && leadFollowupStatus.keySet().contains(l.Last_Call_Attempt_Status__c)) {
                                ProcessMissedCallsSchedular.callBack(l.Id);
                            }
                        //====================================
                        
                        //===========Clear Callback===========
                            if(((Trigger.OldMap.get(l.Id).Status != Trigger.newMap.get(l.Id).Status) && (l.Status == 'Lost')) || l.isConverted) {
                                ProcessMissedCallsSchedular.clearCallBack(l.Primary_Number_Formula__c);
                            }
                        //====================================        
                    }
                }
            }
        }
        if(Trigger.isInsert) {
            User u = [SELECT Id, Name, BitVoice_Agent_Ext__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            if(u.Profile.Name == 'Presales') {
                List<Incoming_Call__c> ins = [SELECT Id, Agent_Extension__c, Phone_Number__c, UID__c, countryCode__c FROM Incoming_Call__c WHERE Agent_Extension__c =: u.BitVoice_Agent_Ext__c AND CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 1];
                delete ins;
            }
        }
    }*/
}
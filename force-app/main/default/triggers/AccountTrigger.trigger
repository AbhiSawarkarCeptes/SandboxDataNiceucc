/* Bypass Framework Enabled */
trigger AccountTrigger on Account(before Insert, after Insert, before update, after update) {
    //Just wanted to bypass trigger for legacy update.
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
    if(bypassSettingInstance.Bypass_All__c || bypassSettingInstance.Bypass_All_Triggers__c || bypassSettingInstance.Bypass_Account_Trigger__c){ 
        System.debug('Inside ByPass Setting Triggered ->'+bypassSettingInstance); 
        
        // Purpose : NICE - Apex class handler method for before insert/update, encrypts mobile numbers & emails if they are provided.
        // Ensure critical handler methods are still called
        // added by Artee on 17-01-2025
        if (Trigger.isInsert && Trigger.isBefore) {
            AccountTriggerHandler.processAccountFieldsBeforeSave(Trigger.new);
        }
        if (Trigger.isUpdate && Trigger.isBefore) {
            AccountTriggerHandler.processAccountFieldsBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        // added by Artee on 17-01-2025
        
        return; 
    }
    
    if(PopulateUniqueIdOnAcc.oneTimePopulateUniqueId) {
        return;
    }
    
    if(Trigger.isUpdate && Trigger.isAfter) {
        //if(!AccountTriggerHandler.isRecordUpdated) {
        System.debug('Unique Id DEBUG calling future method');
        AccountTriggerHandler.isRecordUpdated = true;
        AccountTriggerHandler.updateChildRecordsCustomerUniqueIds(Trigger.new, Trigger.oldMap);
        //} 
    }
    
    if (Trigger.IsInsert) {   
        if (Trigger.isAfter) {
            List<Account> updateCMList = new List<Account>();
            for(Account a : trigger.new) {
                if(a.isPersonAccount && (a.Campaign_Code__c != null )) {  
                    updateCMList.add(a);
                }
            }
            if (updateCMList != null && updateCMList.size() > 0) {
                /*     try {
                PersonAccountManagementServices.AddCampaignToAccount(updateCMList);
                } catch (GlobalException ex) {
                System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
                }*/
            }
        }
    }    
    if(Trigger.isUpdate) {
        
        List < DupResultsDTO > dupResList = new List < DupResultsDTO > ();
        Map<lead,Account> leadaccMap = new Map<lead,Account>();
        if (Trigger.isBefore) {
            If(!(System.isBatch())) {
                List<Lead> leadList=new List<Lead>();
                for(Account acc:Trigger.New){
                    Lead leadObj=new Lead();
                    
                    leadObj.lastName = acc.lastName;
                    leadObj.MobilePhone=acc.PersonMobilePhone;
                    leadObj.Phone=acc.Phone;
                    leadObj.Email = acc.PersonEmail;
                    leadObj.RDS_Alternate_Email_Id__c= acc.Alternate_Email__c;
                    leadObj.Account_ID__c=acc.Id;
                    leadList.add(leadObj);
                    leadaccMap.put(leadObj, acc);
                    // boolean
                }
                
                System.debug('DEBUG: new value of Unique'+Trigger.new[0].Unique_Customer_ID__c);
                System.debug('DEBUG:'+Trigger.oldMap.get(Trigger.new[0].id).Unique_Customer_ID__c);
                // if Account merge process or applicant process is in progress then do not run the lead processing.
                if(! (ApplicantTriggerHandler.applicationTriggerProcess || AccountMergeController.accountMergeProcessInProgress || Test.isRunningTest())) {
                    dupResList = LeadManagementServices.leadPreProcessing(leadList, 'WEB');
                }
                
                if (!dupResList.isEmpty() || Test.isRunningTest()) {
                    
                    for (Lead l: leadList) {
                        System.debug('Trigger.new: ' + l);
                        for (DupResultsDTO d: dupResList) {
                            if (d.originalLead == l) {
                                System.debug('Trigger.new: dup match' + l + d.originalLead);
                                String errMsg = 'Duplicates exists for:' + l.lastName; //Duplicates exists for:' + l.lastName + '\n'+'you cannot create duplicates
                                //String errMsg = 'Duplicates exists for:' +l.FirstName+' '+l.MiddleName+' '+l.lastName + '\n';
                                
                                for (String dupType: d.duplicatesMap.keySet()) {
                                    errMsg += ' (' + d.duplicatesMap.get(dupType) + ')';  // Changed by Neha on 23/1/19                                                              
                                }
                                if(!test.isRunningTest())
                                    leadAccMap.get(l).addError(errMsg);  
                            }
                        }
                    }
                }
                // added by Artee on 17-01-2025
                // Purpose : NICE - Apex class handler method for before update, encrypts mobile numbers & emails if they are provided.
                AccountTriggerHandler.processAccountFieldsBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            } 
            else {
                // added by Artee on 17-01-2025 
                // Purpose : NICE - Apex class handler method for before update, encrypts mobile numbers & emails if they are provided.
                AccountTriggerHandler.processAccountFieldsBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            }            
        }
        
        if(Trigger.isAfter) {
            List < Account > updateCMList = new List < Account > ();
            for (account a: trigger.new) {
                if (Trigger.newMap.get(a.Id).Campaign_Code__C != Trigger.oldMap.get(a.Id).Campaign_Code__C )  
                    updateCMList.add(a);
            }
            if (updateCMList != null && updateCMList.size() > 0) {
                /*  try {
                PersonAccountManagementServices.AddCampaignToAccount(updateCMList);
                } catch (GlobalException ex) {
                System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
                }*/
            }
        }
    }
    
    /******************************************************************************************************************
    Method  : processAccountFieldsBeforeSave
    Purpose : NICE - Apex class handler method for before insert, encrypts mobile numbers & emails if they are provided.
    Author  : Artee Varma
    ******************************************************************************************************************/
        
    if (Trigger.isInsert && Trigger.isBefore) {
        System.debug('before insert');
        AccountTriggerHandler.processAccountFieldsBeforeSave(trigger.new);
    }
}
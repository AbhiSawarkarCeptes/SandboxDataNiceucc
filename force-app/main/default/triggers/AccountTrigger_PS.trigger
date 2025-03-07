trigger AccountTrigger_PS on Account(before Insert, after Insert, before update, after update) {
    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            AccountTriggerHelper.updateAccount(Trigger.new, Trigger.oldMap);            
            AccountTriggerHelper.updateBillingStreetField(Trigger.new, Trigger.oldMap);     // Added By Gourav Gour 05/06/2024         
            AccountTriggerHelper.updateCRMOpsUser(Trigger.new, Trigger.oldMap);     // Added By Gourav Gour 10/06/2024         
            AccountTriggerHelper.updateStatus(Trigger.new, Trigger.oldMap);
            AccountTriggerHelper.checkDuplicatePassportOrTRN(Trigger.new, Trigger.oldMap);
            AccountTriggerHelper.addChannelRelationshipAndSalesHead(Trigger.new);
            AccountTriggerHelper.checkActiveStatus(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isInsert) {
            AccountTriggerHelper.updateAccount(Trigger.new, Trigger.oldMap); 
            AccountTriggerHelper.updateBillingStreetField(Trigger.new, Trigger.oldMap); // Added By Gourav Gour 05/06/2024 
            AccountTriggerHelper.updateCRMOpsUser(Trigger.new, null); // Added By Gourav Gour 10/06/2024 
            AccountTriggerHelper.checkDuplicatePassportOrTRN(Trigger.new, Trigger.newMap);
            AccountTriggerHelper.addChannelRelationshipAndSalesHead(Trigger.new);
        }
    }
    if (Trigger.isInsert) {   
        if (Trigger.isAfter) {
            AccountTriggerHelper.SendBrokerRegistrationMail(Trigger.new);
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
            
            //Added by Anil on 17/08/2023
            // AccountTriggerHelper.sendMailtoPublicGroupInsertion(Trigger.new); // commented by Gourav Gour 22/05/2024
            

        }
        if (Trigger.isBefore) {
            AccountTriggerHelper.updateBrokerCode(Trigger.new);
        }
   }    
   if(Trigger.isUpdate) {
      if (Trigger.isAfter){
            AccountTriggerHelper.updateBookingFromBrokerAccount(Trigger.New , Trigger.oldMap);          
            //AccountTriggerHelper.sendNocForAuditApprovalProcess(Trigger.New , Trigger.oldMap);  
            AccountTriggerHelper.sendNocForFinalSignature(Trigger.New , Trigger.oldMap);
            //  Added By Gourav Gour 30/05/2024 
            if(!System.isFuture()){
                AccountTriggerHelper.updateBrokerApprovalRecord(JSON.serialize(Trigger.new), JSON.serialize(Trigger.oldMap));
            }          
      }
      List < DupResultsDTO > dupResList = new List < DupResultsDTO > ();
        Map<lead,Account> leadaccMap = new Map<lead,Account>();
        if (Trigger.isBefore) {
            If(!(System.isBatch())) {
                 List<Lead> leadList=new List<Lead>();
                 for(Account acc:Trigger.New){
                 Lead leadObj=new Lead();
                              
                 leadObj.lastName = acc.lastName;
                 leadObj.MobilePhone = acc.PersonMobilePhone;
                 leadObj.Phone=acc.Phone;
                 leadObj.Email = acc.PersonEmail;
                 leadObj.RDS_Alternate_Email_Id__c= acc.Alternate_Email__c;
                 leadObj.Account_ID__c=acc.Id;
                 leadList.add(leadObj);
                 leadaccMap.put(leadObj, acc);
             }
            
                /*dupResList = LeadManagementServices.leadPreProcessing(leadList, 'WEB');
                if (!dupResList.isEmpty()) {
                    
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
              }*/
            }
          
        }
     
        if(Trigger.isAfter) {
            AccountTriggerHelper.sendManDataLetter(Trigger.new, Trigger.oldMap);
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
            
            //Added by Anil on 17/08/2023
            // AccountTriggerHelper.sendMailtoPublicGroupUpdation(Trigger.New , Trigger.oldMap);  //Commented By Gourav Gour 22/05/2024 
            // Added By Gourav on 19/03/2024
            AccountTriggerHelper.sendMailForVatUpload(Trigger.new, Trigger.oldMap);
        }
   }
 }
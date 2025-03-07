public class CallOzonetelSchedulerAPI{
    
    @future(callout = true)
    public static void scheduleCall(Set<Id> taskIdSet){
        List< Task > tlist = new List< Task >();
        List< Lead > leadList = new List< Lead >();
        List< Opportunity > opList = new List< Opportunity >();
        User u = new User();
        List<Callout_Log__c> clList = new List 
        <Callout_Log__c>();
        String apiKey = '';
        String AgentId = '';
        String endpointURL = '';
        String campaignName = '';
        String username = '';
        String scheduledDateTime = '';
        String mobile = '';
        String RecordId = '';
        String Priority = '';
        String Skill = '';
        
        tlist = [Select Id,WhoId,WhatId,Next_Action_Date__c, Call_Attempt_Status__c from Task 
                where Id =:taskIdSet and Next_Action_Date__c != null ];                
        system.debug('tlist :: '+tlist);      
          
        leadList = [Select Id,name,MobilePhone, Phone, RDS_Country__c, RDS_Country_Code__c, Project__c, Isconverted  
                    from Lead where Id =:tlist[0].WhoId  AND Isconverted = False ];
        opList = [Select Id,name,AccountId,Account.PersonMobilePhone,Account.Country_Code__c,
                  Account.Country__c,Project__c,Account.Phone from Opportunity where Id =:tlist[0].WhatId ];
        
        system.debug('opList>>'+opList);
        system.debug('leadList>>'+leadList);
        
        
        /* Get API key and outbound campaign from user details*/
        u = [SELECT api_key__c,Ozonetel_Outbound_Campaign_Name__c,OzoneTel_AgentId__c,
             OzoneTel_Username__c,skill__c FROM User WHERE Id = :UserInfo.getUserId()];
        if(u != Null){
        apiKey = u.api_key__c;
        AgentId = u.OzoneTel_AgentId__c;
        username =u.OzoneTel_Username__c;
        Skill = u.skill__c;
        }
         if(u.Ozonetel_Outbound_Campaign_Name__c != null){              
           campaignName = u.Ozonetel_Outbound_Campaign_Name__c;                   
         }   
        
        endpointURL  = 'https://api1.getkookoo.com/CAServices/scheduleCampaignData/scheduleCampaignData.php?';
        
        if(tlist.size() > 0){
        for(Task t : tlist ){
            scheduledDateTime = String.valueOf(t.Next_Action_Date__c);  
            // added for Priority
            If(t.Call_Attempt_Status__c == 'Visit Confirmed'){
            Priority = '9';
            system.debug('Priority ::: ' + Priority );
            }else if(t.Call_Attempt_Status__c == 'Visit Proposed'){
            Priority = '9';
            system.debug('Priority ::: ' + Priority );
            }else if(t.Call_Attempt_Status__c == 'Follow up'){
            Priority = '7';
            system.debug('Priority ::: ' + Priority );
            }else{
            Priority = '6';
            }
          }
        }       
        system.debug('Priority ::: ' + Priority );
                               
        if(!leadList.IsEmpty()){        
           for(Lead lObj : leadList){
                system.debug('lObj ::: ' + lObj );
                RecordId = lObj.Id;
                
              if(lObj.RDS_Country_Code__c != null){              
               if(lObj.MobilePhone != null){
                 if(lObj.RDS_Country__c == 'United Arab Emirates'){
                   mobile = '0'+lObj.MobilePhone;                     
                  }else {
                  if((lObj.RDS_Country_Code__c != null && lObj.MobilePhone != null )){
                                     
                                            String countryCode= lObj.RDS_Country_Code__c;
                                            mobile  = lObj.MobilePhone;
                                            
                                            if(countryCode != null && !String.isBlank(countryCode)){
                                            if(countryCode.indexOf('0') != -1){
                                                countryCode = countryCode.removeStart('0');
                                                countryCode = '00' + countryCode;
                                            } else if(countryCode.indexOf('+') != -1){
                                                countryCode = countryCode.removeStart('+');
                                                countryCode = '00' + countryCode;
            
                                           }                  
                                  }
                             mobile = countryCode +lObj.MobilePhone;                                                        
                          }
                     }
                }else if(lObj.Phone != null){
                if(lObj.RDS_Country_Code__c.startsWith('+')){
                               lObj.RDS_Country_Code__c.replace('+','00');
                }
                 if(lObj.RDS_Country__c == 'United Arab Emirates'){
                 mobile ='0'+ lObj.Phone;}
                 else{
                 mobile =lObj.RDS_Country_Code__c+ lObj.Phone;
                 }                                           
                }
              }
              else{/*
                system.debug('Inside else of country code is missing');
                if(lObj.MobilePhone != null)
                    mobile = lObj.MobilePhone;
                else if(lObj.Phone != null)
                    mobile = lObj.Phone;                
                system.debug('mobile ::'+mobile );    */                                              
            }
        }
      }    
        system.debug('opList ::: ' + opList );
         if(!opList.IsEmpty()){
            for(Opportunity oppObj : opList){
                system.debug('oppObj ::: ' + oppObj );
                RecordId = oppObj.Id;
              if(oppObj.Account.Country_Code__c != null){              
                  if(oppObj.Account.PersonMobilePhone != null){
               if(oppObj.Account.Country__c == 'United Arab Emirates'){
                  mobile = '0' +oppObj.Account.PersonMobilePhone;
                }else{                      
                   //Added on 27 April 2021   
                   String countryCode= '';
                   countryCode = oppObj.Account.Country_Code__c;                   
                      if(countryCode.indexOf('+') != -1){                                
                                    countryCode = countryCode.removeStart('+');
                                    countryCode = '00' + countryCode;                                                                
                     }                     
                    mobile = countryCode +oppObj.Account.PersonMobilePhone;}
                  }
             /*   else if(oppObj.Account.Phone  != null)
                if(oppObj.Account.Country__c == 'United Arab Emirates'){
                  mobile = '0' +oppObj.Account.Phone ;
                }else{
                    mobile = oppObj.Account.Country_Code__c+oppObj.Account.Phone ;}
                 */                       
              }
             /* else{                
                if(oppObj.Account.PersonMobilePhone != null)
                    mobile = '0'+oppObj.Account.PersonMobilePhone;
                else if(oppObj.Account.Phone  != null)
                    mobile = '0'+oppObj.Account.Phone ;               
                }*/
                    system.debug('mobile ::'+mobile );                     
                    if(u.Ozonetel_Outbound_Campaign_Name__c != null) {
                        campaignName = u.Ozonetel_Outbound_Campaign_Name__c;
                    }                            
           }
        }  
     
      
     if(leadList.size() > 0 || opList.size() > 0)
      {           
        if(String.isNotBlank(mobile) && String.isNotBlank(apiKey) && String.isNotBlank(campaignName) && String.isNotBlank(AgentId) && String.isNotBlank(Skill) && String.isNotBlank(Priority)){
            system.debug('Call endpoint');
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setMethod('GET');  
            request.setTimeout(60000);
            
            system.debug('Priority ::: ' + Priority );
            String strbulkData =  '{"map":["PhoneNumber","ScheduledTime","AgentID","Priority","skill"],'+'"data":[["'+mobile+'","'+scheduledDateTime+'","'+AgentId+'","'+Priority+'","'+skill+'"]]}';
            system.debug('Priority ::: ' + Priority );
            strbulkData = EncodingUtil.URLENCODE(strbulkData ,'UTF-8');
            
            system.debug('strbulkData @@'+ strbulkData);  
            String endpoint = endpointURL+'api_key='+apiKey+'&campaign_name='+campaignName+'&bulkData='+strbulkData+'&username='+username;
            system.debug('endpoint @@'+ endpoint ); 
            system.debug('priority @@'+ priority); 
            
            //if(!Test.isRunningTest()){
                system.debug('endpoint:: ' + endpoint);
                request.setEndpoint(endpoint);
                HttpResponse response = http.send(request);
                /* Create log for callout */
                Callout_Log__c cl = new Callout_Log__c();
                cl.Request__c = endpoint;
                cl.Response__c = response.getBody();
                if(leadList.size() > 0)
                {
                 cl.Lead__c = RecordId;
                 system.debug('Inside lead >>> '+leadList );
                 system.debug('Inside lead >>> '+leadList );
                
                 }
                 if(opList.size() > 0)
                 {
                  cl.Opportunity__c = RecordId;
                 system.debug('Inside Opp>>> '+opList );
                 system.debug('Inside Opp>>> '+RecordId);
                
                 }
                
                clList.add(cl);
           }
        } 
  
        if(!clList.isEmpty() && clList.size() > 0){
            insert clList;}
    }

}
public class callOzonetelManualAPI{
    
    @future(callout = true)
    public static void makeaCall(Set<Id> leadIdSet){
        system.debug('Inside makeacall method');
        
        List<Lead> leadList = new List<Lead>(); 
        List<Language_based_Ozonetel__c> ozonetelcustList = new List<Language_based_Ozonetel__c>();
        List<Callout_Log__c> clList = new List<Callout_Log__c>();
        
        User u = new User();
        String apiKey = '';
        String skill = '';
        String Priority = '';
        String endpointURL = '';
        String countryCode = '';
        
        /* Get Mobile and Project from lead details */
        leadList = [SELECT Id, Name, Lead_Id__c, MobilePhone, Phone, ownerid, New_Missed_Call_Lead__c, 
                    RDS_Country__c , RDS_Country_Code__c, Project__c, Website_Language__c 
                    FROM Lead WHERE Id IN :leadIdSet];
        system.debug('lead::: ' + leadList);
     
        /* Get API key and outbound campaign from user details*/
            u = [SELECT LastName, api_key__c,Ozonetel_Outbound_Campaign_Name__c,Agent_Language__c,
                 skill__c FROM User WHERE Id = :UserInfo.getUserId()];
            system.debug('user id'+u.id);
            endpointURL = 'https://api1.getkookoo.com/cloudAgentRestAPI/index.php/CloudAgent/CloudAgentAPI/addCamapaignData?';               
            system.debug('User details >>>>>>>> '+u.LastName);
        
        /* Get Custom setting details */
        ozonetelcustList = [SELECT Id, Name, api_key__c, country__c, country_code__c, ozonetel_outbound_campaign__c, 
                            Priority__c, skill__c from Language_based_Ozonetel__c];
        
        
            for(Lead leadToCall: leadList){
                system.debug('leadToCall::: ' + leadToCall);               
                String campaignName = '';
                String mobile = '';
                String Name = '';
            
           //If country code is present on the lead
           if(leadToCall.RDS_Country_Code__c != null){
            if(leadToCall.MobilePhone != null){
                if(leadToCall.RDS_Country__c == 'United Arab Emirates'){
                    mobile = '0'+leadToCall.MobilePhone;
                }else{                
                   countryCode  = leadToCall.RDS_Country_Code__c;                  
                                if(countryCode.indexOf('++') != -1){
                                    countryCode = countryCode.removeStart('++');
                                    countryCode = '00' + countryCode;
                                    system.debug('countryCode  >>>>'+countryCode );
                                } else if(countryCode.indexOf('+') != -1){
                                    countryCode = countryCode.removeStart('+');
                                    countryCode = '00' + countryCode;
                                    system.debug('countryCode  >>>>'+countryCode );
                                } 
                               else if(countryCode.indexOf('+0') != -1){
                                    countryCode = countryCode.removeStart('+0');
                                    countryCode = '00' + countryCode;
                                } else if(countryCode.indexOf('0') != -1){
                                    countryCode = countryCode.removeStart('0');
                                    countryCode = '00' + countryCode;
                                }
                                else if(countryCode.indexOf('+') != -1){
                                
                                    countryCode = countryCode.removeStart('+');
                                    countryCode = '00' + countryCode;
                                }                                 
                mobile = countryCode  +leadToCall.MobilePhone;
                }                            
            }else if(leadToCall.Phone != null){
                mobile = leadToCall.RDS_Country_Code__c+leadToCall.Phone;
            }
           } else{           
                if(leadToCall.MobilePhone != null)
                   mobile = leadToCall.MobilePhone;
                else if(leadToCall.Phone != null)
                   mobile = leadToCall.Phone;
                           
           } 
            
            system.debug('leadToCall.Website_Language__c %%%%%%%%'+leadToCall.Website_Language__c);
            system.debug('leadToCall.RDS_Country_Code__c&&&&&&&&&&&&& '+ leadToCall.RDS_Country_Code__c );
            system.debug('leadToCall.RDS_Country__c&&&&&&&&&&&&& '+ leadToCall.RDS_Country__c );
            system.debug('ozonetelcustList&&&&&&&&&&&&& '+ ozonetelcustList );
            system.debug('leadToCall.Website_Language__c&&&&&&&&&&&&& '+ leadToCall.Website_Language__c );                   
        
           if(ozonetelcustList.size() > 0){
             for(Language_based_Ozonetel__c p : ozonetelcustList ){   
               if(p.skill__c == leadToCall.Website_Language__c && p.Country__c == leadToCall.RDS_Country__c)
               {
                    system.debug('Inside local campaign'+leadToCall.Name);
                   If(campaignName == ''){
                            campaignName = p.ozonetel_outbound_campaign__c; 
                            skill = p.skill__c;  
                            Priority = p.Priority__c; 
                            Apikey = p.api_key__c ;      
                            Name = leadToCall.Lead_Id__c;                     
                            system.debug('campaignName '+campaignName );
                            system.debug('apiKey  Inside If '+apiKey );
                            system.debug('skill  Inside If '+skill );
                            system.debug('Priority  Inside If '+Priority);
                            system.debug('Name  Of campaign If >>>>>>>>>>>> '+p.Name); 
                   }  
                    system.debug('leadToCall.RDS_Country__c&&&&&&&&&&&&& '+ leadToCall.RDS_Country__c );
                    
               }else if(leadToCall.RDS_Country__c != '' && leadToCall.RDS_Country__c != null && (leadToCall.RDS_Country__c != 'United Arab Emirates' || leadToCall.RDS_Country__c != 'United Kingdom' 
                       ||  leadToCall.RDS_Country__c != 'India')){
                    if(p.name == 'Global English'){
                        system.debug('Inside global campaign'+leadToCall.Name);
                        system.debug('Inside global campaign'+leadToCall.RDS_Country__c);
                        If(campaignName == ''){
                            campaignName = p.ozonetel_outbound_campaign__c; 
                            skill = p.skill__c;  
                            Priority = p.Priority__c; 
                            Apikey = p.api_key__c ;  
                            Name = leadToCall.Lead_Id__c;                            
                            system.debug('campaignName '+campaignName );
                            system.debug('apiKey  Inside else '+apiKey );
                            system.debug('skill  Inside else '+skill );
                            system.debug('Priority  Inside else '+Priority);
                            system.debug('Name  Of campaign else>>>>>>>>>>>> '+p.Name);   
                        }
                    system.debug('leadToCall.RDS_Country__c&&&&&&&&&&&&& '+ leadToCall.RDS_Country__c );
                 } 
               }else{
                   If(campaignName == ''){
                   if(p.name == 'Default'){
                            system.debug('Inside default campaign'+leadToCall.Name);
                            campaignName = p.ozonetel_outbound_campaign__c; 
                            skill = p.skill__c;  
                            Priority = p.Priority__c; 
                            Apikey = p.api_key__c ; 
                            Name = leadToCall.Lead_Id__c;                                
                            system.debug('campaignName '+campaignName );
                            system.debug('apiKey  Inside Default '+apiKey );
                            system.debug('skill  Inside Default '+skill );
                            system.debug('Priority  Inside Default '+Priority);
                            system.debug('Name  Of campaign default >>>>>>>>>>>> '+p.Name);                     
                            system.debug('leadToCall.RDS_Country__c&&&&&&&&&&&&& '+ leadToCall.RDS_Country__c );
                     }
                   }
               }
                 
                 // setting a priorty for missed call fresh leads
                    if(leadToCall.New_Missed_Call_Lead__c == True){
                        if(p.name == 'Default'){
                            campaignName = p.ozonetel_outbound_campaign__c; 
                            skill = p.skill__c;  
                            Priority = '9'; 
                            Apikey = p.api_key__c ; 
                            Name = leadToCall.Lead_Id__c;        
                }
               
                system.debug('Mobile >>>>>>>>>>>>>>>>>>>>>' +mobile);
                system.debug('apiKey >>>>>>>>>>>>>>>>>>>>>' +apiKey);
                system.debug('campaignName >>>>>>>>>>>>>>>>>>>>>' +campaignName);
                system.debug('skill >>>>>>>>>>>>>>>>>>>>>' +skill);
                system.debug('Priority >>>>>>>>>>>>>>>>>>>>>' +Priority);          
           }
         }
      } 
            system.debug('Mobile >>>>>>>>>>>>>>>>>>>>>' +mobile);
            system.debug('apiKey >>>>>>>>>>>>>>>>>>>>>' +apiKey);
            system.debug('campaignName >>>>>>>>>>>>>>>>>>>>>' +campaignName);
            system.debug('skill >>>>>>>>>>>>>>>>>>>>>' +skill);
            system.debug('Priority >>>>>>>>>>>>>>>>>>>>>' +Priority);
            system.debug('Name  >>>>>>>>>>>>>>>>>>>>>' +Name);
            
            
            if(String.isNotBlank(mobile) && String.isNotBlank(apiKey) && String.isNotBlank(campaignName) 
               && String.isNotBlank(skill) && String.isNotBlank(Priority)){
                system.debug('Call endpoint');
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                request.setMethod('GET');  
                request.setTimeout(60000);
                
                String endpoint = endpointURL+'api_key='+apiKey+'&campaign_name='+campaignName+'&skill='+skill+'&Name='+Name+'&Priority='+Priority+'&format=json&PhoneNumber='+mobile+'&action=start&checkDuplicate=true';
                system.debug('endpoint >>>>>>>>>>>>>>>>>>>>>' +endpoint );

                if(!Test.isRunningTest()){
                    system.debug('endpoint:: ' + endpoint);
                    request.setEndpoint(endpoint);
                    HttpResponse response = http.send(request);
                    /* Create log for callout */
                    Callout_Log__c cl = new Callout_Log__c();
                    cl.Request__c = endpoint;
                    cl.Response__c = response.getBody();
                    cl.Lead__c = leadToCall.Id;
                    clList.add(cl);
                }
            } 
        }  
        if(!clList.isEmpty() && clList.size() > 0)
            insert clList;
    }
}
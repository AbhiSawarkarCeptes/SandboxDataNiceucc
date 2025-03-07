@RestResource(urlMapping='/Integration/Callback1/*')
    
global class REST_CallbackCTI {
  
   
   @HttpPost
    global static void CreateActivity() {
         String data = '';
         data = RestContext.request.params.get('data');
    
         CallbackParse cb = CallbackParse.Parse(data);
         
         String customerNumber = cb.national;
         String did = cb.DID;
         String ucid = cb.monitorUCID;
         String callStatus = cb.Status;
         String callType =cb.Type_Z;
         String account =cb.UserName;
         String recordingFile = cb.AudioFile;
         String duration = cb.CallDuration;
         String UUI = cb.UUI;
         String CampaignStatus = cb.CampaignStatus;
         boolean newlead = false;
         List<lead> llist = new List<lead>();
         List<Account> aList = new List<Account>();
         String country;
         String countryCode = cb.countryCode ;
         String formattedphone;
         Id recordId;
                  
         System.debug('Incoming request:' + callType + ':' + callStatus + ':' + customerNumber + ':' + ucid + 'UUI:' + UUI + 'CampaignStatus:' + CampaignStatus + 'DID:' + did + 'countryCode :' + countryCode ); 
         Boolean isRecordIdBlank = true;
         formattedphone=customerNumber;
         system.debug('formattedphone:::::::::::'+formattedphone);
         System.debug('Incoming request:' + callType + ':' + callStatus + ':' + customerNumber + ':' + ucid + 'UUI:' + UUI + 'CampaignStatus:' + CampaignStatus + 'DID:' + did + 'countryCode :' + countryCode ); 
  
        
        system.debug('countryCode >> '+countryCode);
        
            Map<String,String> cDetails = new Map<String,String>();
            if(String.isNotBlank(customerNumber ) && String.isNotBlank(countryCode)){
                system.debug('inside dialing code');
                cDetails = FormatMobileNumber.getCountryByCountryCode(countryCode);
                if(cDetails.size() > 0 && cDetails != null){
                       country = cDetails.get('country');
                    
                       system.debug('country >>>>>>>>>>'+country);
                       system.debug('customerNumber >>>>>>>>>>'+customerNumber );
                       system.debug('countryCode>>>>>>>>>>'+countryCode);
                }
            } /*else if(String.isNotBlank(customerNumber ) && String.isBlank(customerNumber )) {
                system.debug('inside mobile number');
                cDetails = FormatMobileNumber.getDetailsByMobile(customerNumber );
                if(cDetails.size() > 0 && cDetails != null){
                     country = cDetails.get('country');
                    
                       system.debug('country >>>>>>>>>>'+country);
                       system.debug('countryCode>>>>>>>>>>'+countryCode);
                }
            } */
        

        
        system.debug('countryCode >>>> '+countryCode );
        system.debug('customerNumber >>> '+customerNumber);
           
         if(String.isNotBlank(callStatus) && callStatus!=Null && (callStatus.equalsIgnoreCase('NotAnswered')) && callType == 'Inbound'){ 
            // formattedphone=getPhoneSearchString(customerNumber);
            System.debug('Inside if callStatus: ' + callStatus + ' customerNumber::: ' + customerNumber + ' UUI::: '+UUI);   
              task t = new task(); 
                        t.status = 'Completed';
                       // t.Mobile_No__c = customerNumber;
                        t.Subject = 'Missed Call:' + did;
                        t.callType = 'Inbound'; 
                        t.Communication_Type__c='Inbound call';
                        //t.Virtual_Number__c=did;
                        t.description = 'Missed Call:' + did;
                        //t.CTI_Call_Status__c = callStatus;
                        t.Task_Type__C = 'Presales Call';
          
             List<Campaign> CampaignList = new List<Campaign>();
             String leadSource;
             String LeadSubSource;
             String Subsourcecategory;
             String OtherleadsourceDetails;
             String CampaignName;
            CampaignList = [SELECT Id,Name,Primary_Project__c,Sub_Source__c, Digital_Maketing_Campaign_Code__c from Campaign Where 
                            Digital_Maketing_Campaign_Code__c = :did and isactive=true]; //Source__c
        
        
        if (CampaignList.size() > 0) 
        {      
           //LeadSource = CampaignList[0].Source__c;       
          //  LeadSubSource = CampaignList[0].Lead_Source_1__c;
            Subsourcecategory = CampaignList[0].Sub_Source__c;
           // OtherleadsourceDetails = CampaignList[0].Sub_Source__c;
           CampaignName = CampaignList[0].Name;
            
        }
                  
            system.debug('customerNumber::::::::'+customerNumber);
             List <lead> leadList =[SELECT Id,ownerid,Name,Campaign_Code__c,LeadSource,Lead_Sub_Source__c,Project__c,
                                    RDS_Country__c,RDS_Country_Code__c FROM Lead WHERE (MobilePhone = :customerNumber 
                                                                                        OR Phone = :customerNumber) 
                                    and isConverted= false ]; 
             
             if(leadList != null && !leadList.isEmpty() && leadList.size() > 0){
                       system.debug('Inside Lead >>>>>'+ leadList);
                             recordId = leadList[0].Id;
                             leadList[0].is_serviced__c = false;
                             update leadList[0];
                 
                             recordId = leadList[0].Id;
                             t.whoId=recordId;
                 system.debug('leadList[0].ownerid ::'+leadList[0].ownerid);
                             t.OwnerId=leadList[0].ownerid;  
                 system.debug('task owner ::'+t.ownerId);
             }else {
                    aList = [Select Id, is_serviced__c, PersonContactId from Account where 
                             (personMobilePhone = :customerNumber or Phone =:customerNumber) and isPersonAccount = true];
                    system.debug('alist is::'+aList);
                    if(aList != null && !aList.isEmpty() && aList.size() > 0) {
                        t.whoid=alist[0].PersonContactId;
                        alist[0].is_serviced__c = false;
                        update alist[0];
                        recordId = alist[0].Id;
                           List<opportunity>opList = new List<Opportunity>(); 
                        IF(aList.size() > 0){
                           opList = [select id,name,  Project__c, OwnerId from opportunity where 
                                     AccountId =: aList[0].id and stagename != 'Closed Lost'  
                                     order by LastModifiedDate DESC];
                        }
                           if(opList != null && !opList.isEmpty())
                            {
                               system.debug('opList is::'+opList);          
                               recordId = oplist[0].Id;
                               t.WhatId=recordId;
                               t.ownerid=opList[0].ownerid; 
                                system.debug('task owner ::'+t.ownerId);
                        }
                     }  else {
                           System.debug('Inside missed call lead');
                          Lead l = new Lead(lastName = 'CTI Missed Call lead',
                                         // Added by Priya on 5 March 2021
                                          New_Missed_Call_Lead__c = True,
                                          LeadSource=LeadSource,
                                          Lead_Sub_Source__c=LeadSubSource,
                                          Lead_Source__c = LeadSource,         
                                         // sub_source_category__c =Subsourcecategory,
                                        //  Other_lead_source_Details__c =OtherleadsourceDetails,
                                          mobilePhone= customerNumber, 
                                          RDS_Country__c = Country, 
                                          RDS_Country_Code__c = countryCode
                                           );
                                         if(campaignList.size()>0){
                                          // l.Campaign__c=CampaignList[0].id;
                                           l.Campaign_Code__c=CampaignList[0].Digital_Maketing_Campaign_Code__c;
                                           l.Project__c=CampaignList[0].Primary_Project__c;                                           
                                         }
                                try{
                                    insert l;
                                    recordId = l.Id;
                                    system.debug('New lead inserted'+l.Id);
                                    newlead = true;
                                    t.WhoId=recordId;
                                }catch (Exception ex) {
                                  Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
                                  logError.class__c = 'REST_CallbackCTI';
                                  logError.Request__c = data;
                                  insert logError;
                                            System.debug('lead isert failed :' + ex.getMessage());
                               }
                     }
                 }
               
                   try {                                
                                        
                      insert t;
                      System.debug('task created:' + t.id);
                      system.debug('task owner ::'+t.ownerId);
                     } catch (Exception ex) {
                      Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
                      logError.class__c = 'REST_CallbackCTI';
                      logError.Request__c = data;
                       insert logError;
                                        System.debug('task insert failed :' + ex.getMessage());
                    }
             }
        }
    }
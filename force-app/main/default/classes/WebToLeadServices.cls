global class WebToLeadServices {

    global static final String PARAM_MISSING = 'MISSING REQUIRED PARAMETERS';
    global static final String PROJECT_INVALID = 'INVALID PROJECT SELECTED';
    global static final String SOURCE_INVALID = 'INVALID SOURCE';


    global class result {
        webservice Integer returnCode;
        webservice String message;
        webservice Id recordId;
    }

    global class WebLead {
        webservice String fullName;
        webservice String emailAddress;
        webservice String country;
        webservice String city;       // added as per client's requirement
        webservice String dialingCode;
        webservice String mobileNumber;
        webservice String projectInterested;
        webservice String budget;
        webservice String CampaignCode;
        webservice String source; //click2call, microsite, corpsite, liveserv etc.
        webservice String subSource; // Added By Neha on 28/12
        webservice String webbannerSource;
        webservice String UTMCampaign;
        webservice String UTMDisplay;
        webservice String UTMMedium;
        webservice String UTMSource;
        webservice String UTMTerm;
        webservice String IPAddress;
        webservice String SpecialRequestInfo;
        webservice String Remarks;    //Added by Prashant
        
        /************ Added by Neha on 05/12/18 Starts Here ***************************/
        webservice String WebSource;
        webservice String Adgroup;
        webservice String Goal;
        webservice String DigitalSource;
        webservice String ChannelCluster;
        webservice String BannerSize;
        webservice String Keyword;
        webservice String Placement;
        webservice String Adposition;
        webservice String MatchType;
        webservice String Network;
        webservice String BidType;
        webservice String UTMcontent;
        webservice String LeadSource;
        webservice String LastMileConversion;
        webservice String Device;
        webservice String OS;
        webservice String Resolution;
        webservice String Browser;
        webservice String GCLID;
        webservice String TimeSpentbeforeFormSubmit;
        webservice String LandingPageURL;
        webservice String WebsiteLanguage;
        webservice String IsWAYBEOLead;   
        /************ Added by Neha on 05/12/18 Ends Here ***************************/
        /************ Added by Neha on 24/12/18 For Scheduling a Visit Starts Here *******/
        webservice String InterestedIn;
        webservice String DateOfVisit; //Format should be 2018-12-25T00:00:00.0
        webservice String HH;
        webservice String MM;        
        /************ Added by Neha on 24/12/18 For Scheduling a Visit Ends Here *******/                
    }

    webservice static result createLeadFromWeb(WebLead wl) {
        List < Lead > leadList = new List < Lead > ();
        Lead l = null;
        result r = new result();
        String projectId = null;
        System.debug('WEB LEAD:' + wl);
        String hexdigest = generateRandomString1(10);  //Added By Prashant
        System.debug('Random number : '+hexdigest);
        
        //written by Prashant
            if(String.isBlank(wl.mobileNumber))
            {
                 wl.mobileNUmber = 'mo-' + hexdigest;
            }
        //end of code written by Prashant
        
 //       if (String.isNotBlank(wl.source) && wl.source.equals('DIGITAL MARKETING')) { // Commented by Neha on 5/12/18
           if (String.isBlank(wl.fullName) || String.isBlank(wl.mobileNumber) || String.isBlank(wl.source) ) {
                System.debug('Missing Required Parameters');
                r.returnCode = 1;
                r.message = PARAM_MISSING;
                r.recordId = null;
                return r;
            } else {
                List < Project__c > pList = [Select Id, Name from project__c where Name = : wl.projectInterested];
                if (pList.size() == 1) {
                    projectId = pList[0].Id;
                } else {
                    System.debug('Project Error:' + pList);
                    r.returnCode = 1;
                    r.message = PROJECT_INVALID;
                    r.recordId = null;
                    return r;
                }
                               
                Date visitDate;  
                Boolean check;           
                if (String.isBlank(wl.DateOfVisit)) {
                    visitDate = NULL;
                } else {
                    visitDate = Date.valueOf(wl.DateOfVisit);
                }
                
                if (String.isBlank(wl.IsWAYBEOLead)) {
                     check = false;
                } else {
                     check = Boolean.valueOf(wl.IsWAYBEOLead);
                }
                
                l = new Lead(
                lastName = wl.fullName,
                RDS_Mobile__c = wl.mobileNumber,
                RDS_Email__c = wl.emailAddress,
                MobilePhone = wl.mobileNumber,
                Email = wl.emailAddress,
                leadsource = wl.source,
                Lead_Sub_Source__c = wl.WebSource,
                RDS_Country__c = wl.country,
                City = wl.city,
                RDS_Country_Code__c = wl.dialingCode,
                RDS_Budget__c = wl.budget,
                Project__c = projectId,
                Source_Remarks__c = wl.source,
                Campaign_Code__c = wl.CampaignCode,
                web_banner_source__c = wl.webBannerSource,
                IP_address_web2lead__c = wl.IPAddress,
                Special_Request_Info__c=wl.SpecialRequestInfo,
                Description__c=wl.Remarks,    ///Added By Prashant
          
        /////////////////////////--------------- vikas added below field on dated 23-08-16 -----------------------------/////////////////////
                UTM_Campaign__c = wl.UTMCampaign,
                UTM_Display__c = wl.UTMDisplay,
                UTM_Medium__c = wl.UTMMedium,
                UTM_Source__c = wl.UTMSource,
                UTM_Term__c = wl.UTMTerm,
                auto_assign__c = true,
                // Added by shailesh //
             //   Campaign_Error__c = campaignError ,
             //   Campaign_Error_Subject__c = campaignErrorSubject,
             //   Campaign_Code_Source_Tagging__c = campaignCodeTagged, 
          /***** Added by Neha on 5/12/18 Starts Here ***********************************/
                Web_Source__c = wl.WebSource,
                Adgroup__c = wl.Adgroup,
                Goal__c = wl.Goal,
                Digital_Source__c = wl.DigitalSource,
                Channel_Cluster__c = wl.ChannelCluster,
                Web_Banner_Size__c = wl.BannerSize,
                Keyword__c = wl.Keyword,
                Placement__c = wl.Placement,
                Adposition__c = wl.Adposition,
                Matchtype__c = wl.MatchType,
                network__c = wl.Network,
                Bid_Type__c = wl.BidType,
                UTM_Content__c = wl.UTMcontent,
                Lead_Source__c = wl.LeadSource,
                Last_Mile_Conversion__c = wl.LastMileConversion,
                Device__c = wl.Device,
                OS__c = wl.OS,
                Resolution__c = wl.Resolution,
                Browser__c = wl.Browser,
                GCLID__c = wl.GCLID,
                Time_Spent_before_Form_Submit__c = wl.TimeSpentbeforeFormSubmit,
                Landing_Page_URL__c = wl.LandingPageURL,
                Website_Language__c = wl.WebsiteLanguage,
                Is_WAYBEO_Lead__c = check ,    
                Is_Auto_Calling__c = True,          
      /****************** Added by Neha on 05/12/18 Ends Here *********************************/      
      /************ Added by Neha on 24/12/18 For Scheduling a Visit Starts Here *******/
                Interested_In__c = wl.InterestedIn,
                Date_of_Visit__c = visitDate , //Format should be 2018-12-25T00:00:00.0
                HH__c = wl.HH,
                MM__c = wl.MM
      /************ Added by Neha on 24/12/18 For Scheduling a Visit Ends Here *******/
                );
        /////////////////--------------------- vikas added end here -------------------------------///////////////////////////////                                 
            }
   /*     } else { // Commented by Neha on 5/12/18
            System.debug('Invalid Source:' + wl.source);
            r.returnCode = 1;
            r.message = SOURCE_INVALID;
            r.recordId = null;
            return r;
        } */
        
        
        if (l != null) {
            leadList.add(l);
            try {
                List < DupResultsDTO > dupList = LeadManagementServices.leadPreprocessing(leadList, 'WEB');
                if (dupList.isEmpty()) {
                    try {
                        Database.saveResult[] srList = Database.insert(leadList, true);
                        for (Database.SaveResult sr: srList) {
                            if (sr.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted lead. lead ID: ' + sr.getId());
                                r.recordId = sr.getId();
                                r.returnCode = 0;
                                r.message = 'SUCCESS';
                                try {
                                    // once the lead is created, save the entire enquiry information as a task of type enquiry received.
                                    // this is so that the complete form info is saved somewhere
                                    Map < Id, Lead > enquiryMap = new Map < Id, Lead > ();
                                    enquiryMap.put(sr.getId(), l);
                                    Map < Id, Task > whoIdMap = new Map < Id, Task > ();
                                    whoIdMap = TaskManagementServices.createTaskforEnquiries(enquiryMap);
                                    task t = [Select Id, new_lead_created__c from task where id = : whoIDMap.get(sr.getId()).Id];
                                         t.new_lead_created__c  = true;
                                         upsert t;
                                } catch (Exception ex) {
                                    System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage());
                                }
                            } else {
                                // Operation failed, so get all errors  
                                String msg = null;
                                for (Database.Error err: sr.getErrors()) {
                                    msg = 'Lead Insert Failed :' + err.getMessage();
                                }
                                r.returnCode = 1;
                                r.message = msg;
                                r.recordId = null;
                                return r;
                            }
                        }
                    } catch (System.DmlException ex) {
                        String msg = null;
                        for (Integer i = 0; i < ex.getNumDml(); i++) {
                            msg = 'Lead Insert Failed :' + ex.getMessage();
                        }
                        r.returnCode = 1;
                        r.message = msg;
                        r.recordId = null;
                        return r;
                    }
                } else {
                    r.recordId = dupList[0].duplicateMaster;
                    r.returnCode = 0;
                    r.message = 'SUCCESS';
                }
            } catch (GlobalException g) {
                r.returnCode = 1;
                r.message = g.getErrorMsg()[0];
                r.recordId = null;
                return r;
            }
            return r;
        } else {
            System.debug('Lead list empty:');
            r.returnCode = 1;
            r.message =  'UNKNOWN EXCEPTION';
            r.recordId = null;
            return r;
        }
    }
    
      ///////////////////////////Written by prashant/////////////////////////////////////
      public static String generateRandomString1(Integer len)
      {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String[] result = new String[len];
        Integer idx = 0;
    
        while(idx < len) 
        {
            Integer chr = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
            result[idx++] = chars.substring(chr, chr+1);
        }
        return String.join(result,'');
     }
     //////////end of code writtemn by prashant/////////////////////
}
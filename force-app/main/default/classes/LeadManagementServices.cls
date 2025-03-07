public class LeadManagementServices{
    

    public static List<DupResultsDTO> leadPreProcessing(List<Lead> LeadList, String context){
        DateTime startTime = system.now();
        Map<String,String> originalMap = new Map<String,String>();
        Map<Lead,List<Lead>> leadEmailDupMap = DedupeChecker.findLeadDupeforLeads('EMAIL', leadList);
        System.debug('lead email dup: ' + leadEmailDupMap);
        if(leadEmailDupMap.size() > 0){
            for(lead ld : leadEmailDupMap.keyset()){
            originalMap.put(ld.LastName,ld.Email);
            }}
        
        Map<Lead,List<Account>> personAccountEmailDup = DedupeChecker.findPADupeforLeads('EMAIL',leadList);
        System.debug('PA Email Dup: ' + personAccountEmailDup);
        if(personAccountEmailDup.size() > 0){
            for(lead ld : personAccountEmailDup.keyset()){
            originalMap.put(ld.LastName,ld.Email);
            }}
        Map<Lead,List<Lead>> leadAltEmailDupMap = DedupeChecker.findLeadDupeforLeads('ALTEMAIL', leadList);
        System.debug('lead email dup: ' + leadAltEmailDupMap);
        if(leadAltEmailDupMap.size() > 0){
            for(lead ld : leadAltEmailDupMap.keyset()){
            originalMap.put(ld.LastName,ld.RDS_Alternate_Email_Id__c);
            }}
        Map<Lead,List<Account>> personAccountAltEmailDup = DedupeChecker.findPADupeforLeads('ALTEMAIL',leadList);
        System.debug('PA Email Dup: ' + personAccountAltEmailDup);
        if(personAccountAltEmailDup.size() > 0){
            for(lead ld : personAccountAltEmailDup.keyset()){
            originalMap.put(ld.LastName,ld.RDS_Alternate_Email_Id__c);
            }}
        Map<Lead, List<Lead>> leadMobileDupMap  = DedupeChecker.findLeadDupeforLeads('MOBILE', leadList);
        System.debug('Lead Mobile Dup: ' + leadMobileDupMap);
        if(leadMobileDupMap.size() > 0){
            for(lead ld : leadMobileDupMap.keyset()){
            originalMap.put(ld.LastName,ld.MobilePhone);
            }}
        Map<Lead,List<Account>>  PAMobileDupMap = DedupeChecker.findPADupeforLeads('MOBILE',leadList);
        System.debug('PA Mobile Duplicates: ' + PAMobileDupMap);
        if(PAMobileDupMap.size() > 0){
            for(lead ld : PAMobileDupMap.keyset()){
            originalMap.put(ld.LastName,ld.MobilePhone);
            }}
         Map<Lead, List<Lead>> leadAltMobileDupMap  = DedupeChecker.findLeadDupeforLeads('ALTMOBILE', leadList);
        System.debug('Lead Mobile Dup: ' + leadAltMobileDupMap);
        if(leadAltMobileDupMap.size() > 0){
            for(lead ld : leadAltMobileDupMap.keyset()){
            originalMap.put(ld.LastName,ld.Phone);
            }}
        Map<Lead,List<Account>>  PAAltMobileDupMap = DedupeChecker.findPADupeforLeads('ALTMOBILE',leadList);
        System.debug('PA Mobile Duplicates: ' + PAAltMobileDupMap);
        if(PAAltMobileDupMap.size() > 0){
            for(lead ld : PAAltMobileDupMap.keyset()){
            originalMap.put(ld.LastName,ld.Phone);
            }}
        
         system.debug('originalMap' + originalMap);
         List<Lead> originalLeadlist = [select id from lead where MobilePhone  in :originalMap.values()];
  
        system.debug('originalLeadlist' + originalLeadlist);
        Map<Lead, Map<String, List<Id>>> leadDupAgg = DedupeChecker.aggregateLeadDuplicates(leadEmailDupMap, leadMobileDupMap, personAccountEmailDup, PAMobileDupMap, leadAltEmailDupMap, leadAltMobileDupMap,personAccountAltEmailDup, PAAltMobileDupMap );
        System.debug('AggregatedDuplicates: ' + leadDupAgg);
        List<DupResultsDTO> dupResults = new List<DupResultsDTO>();
        if(leadDupAgg!=null & !leadDupAgg.isEmpty()) {
            // duplicates exists, based on the context of the method call, like batch loading, webservice call 
            // take context specific remedial action for duplicates
            dupResults = DedupeChecker.dupHandler(leadDupAgg, context,originalLeadlist);
        }
        DateTime endTime = system.now();
        system.debug('VVK Execution Time: '+string.valueOf((endTime.getTime()-startTime.getTime())));
        return dupResults;
    }  
  /*   public static void SetSystemCampaignOnLead(List<Lead> leadList) {
        //Based on EnquiryMode for CALLS
        Map<String,List<String>> campaignDetails = new Map<String,List<String>>();
        
        //collect the campaign codes or toll free numbers into a list and put them into appropriate buckets [mapkeys]
        for(lead l:leadList) {
                if(l.Campaign_Code__C != null)  {
                    if(campaignDetails.containsKey('CAMPAIGNCODE')) {
                        campaignDetails.get('CAMPAIGNCODE').add(l.Campaign_Code__C);
                    } else {
                        List<String> codeList = new List<String>();
                        codeList.add(l.Campaign_Code__C);
                        campaignDetails.put('CAMPAIGNCODE', codeList);
                    }
                }
        }
        Map<String,Campaign> searchResults = new Map<String,Campaign>();
        List < CampaignMember > cmList = new List < campaignMember > ();
        System.debug('CampaignDetails:' + CampaignDetails);
        if(campaignDetails != null && !campaignDetails.isEmpty())   
        searchResults = CampaignManagementServices.searchCampaign(CampaignDetails); 
       for (lead l: leadList) {
            if(!searchResults.isEmpty()) {
                if (searchResults.containsKey(l.Campaign_Code__C)) {
                    if(searchResults.get(l.Campaign_Code__C).Is_CTI_Campaign__c) {
                        //CampaignMember cm = new CampaignMember(CampaignId = searchResults.get(l.Campaign_Code__C).Id, LeadId = l.Id, Status = 'Responded');
                        //cmList.add(cm);
                        if(l.Lead_Sub_Source__c == null && l.LeadSource == null && l.Project__c == null) {
                            l.Lead_Sub_Source__c = searchResults.get(l.Campaign_Code__C).Sub_Source__c; //added line to default the CCU source to system source on 20.7.15 UAT - comments
                            l.LeadSource = searchResults.get(l.Campaign_Code__C).Type; //added line to map the leadsource to campaign type on 20.7.15 UAT - comments
                            l.Project__c = searchResults.get(l.Campaign_Code__C).Primary_Project__c;
                            l.Campaign_Code_Source_Tagging__c = searchResults.get(l.Campaign_Code__C).Digital_Maketing_Campaign_Code__c;
                            l.Campaign_Error__c = '';
                            l.Campaign_Error_Subject__c = '';
                        }
                    }
               }
           }
           else if(l.Lead_Sub_Source__c == null && l.Project__c == null){
              l.Campaign_Error__c = 'Invalid Campaign Code: '+ l.Campaign_Code__C;
              l.Campaign_Error_Subject__c = 'Invalid Campaign Code Received in Set System Campaign';
           }
        }
        System.debug('Lead Source Details:' + LeadList);
        
    }
    
    public static void AddCampaignToLead(List<Lead> leadList) {
        //Based on EnquiryMode for CALLS
        Map<String,List<String>> campaignDetails = new Map<String,List<String>>();
        System.debug('inside addCampaignToLead method');
        //collect the campaign codes or toll free numbers into a list and put them into appropriate buckets [mapkeys]
        for(lead l:leadList) {
          
                if(l.Campaign_Code__C != null)  {
                    if(campaignDetails.containsKey('CAMPAIGNCODE')) {
                        campaignDetails.get('CAMPAIGNCODE').add(l.Campaign_Code__C);
                    } else {
                        List<String> codeList = new List<String>();
                        codeList.add(l.Campaign_Code__C);
                        campaignDetails.put('CAMPAIGNCODE', codeList);
                    }
                }
                // change made on 11-7-15, to fix the gap in code where, the lead is added as member of
                // CCU campaigns and site visit campaigns 
           
        }
        Map<String,Campaign> searchResults = new Map<String,Campaign>();
        
        System.debug('CampaignDetails:' + CampaignDetails);
        if(campaignDetails != null && !campaignDetails.isEmpty())   
        searchResults = CampaignManagementServices.searchCampaign(CampaignDetails);
        
        // create a Map like below
        // [campaingnA, [List of Lead to add to that campaign]
        //   campaignB, [List of leads to add to that campaign]]
        Map<Campaign,List<lead>> campaignMap = new Map<Campaign,List<Lead>>();
        
        for(lead l: leadList) {
            
            if(searchResults.containsKey(l.Campaign_Code__c)) {
                Campaign c= searchResults.get(l.Campaign_Code__c);
                if(campaignMap.containsKey(c)){
                    campaignMap.get(c).add(l);
                } else {
                    List<lead> ll = new List<Lead>();
                    ll.add(l);
                    campaignMap.put(c,ll);
                }
            }            
           
        }
        CampaignManagementServices.addCampaignToLead(campaignMap);
    } 
    
    */
    

    public static void updateLeadStatus(List<Lead> newList, Map<Id,Lead> oldMap){
        for(Lead l : newList){
            if(l.Last_Call_Attempt_Status__c != null && (oldMap == null || oldMap.get(l.id).Last_Call_Attempt_Status__c != l.Last_Call_Attempt_Status__c)){
                if(l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Visit Proposed') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Visit Confirmed') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Tele Meeting Fixed')){l.status = 'Qualified';}
                
                if(l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Visit Proposed') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Visit Confirmed') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Tele-Meeting Fixed') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Tele Meeting Fixed')){l.status = 'Qualified';}

                if(l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Follow up') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('No Contact') ){ l.status = 'Open'; }
                if(l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Junk') ||l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Junk Lead') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Invalid Enquiry') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Invalid No') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Invalid Number') || l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Not Interested')){
                    l.status = 'Lost';
                    l.reason_for_lost__c = l.Last_Call_Attempt_Status__c.equalsIgnoreCase('Not Interested') ? 'Not Interested' : 'Invalid Enquiry';
                }} }}
    public static void checkIfLeadShouldBeRoutedToWeekendQueue(List<Lead> newList){
       // Date d = System.today();
        //Datetime dt = (DateTime)d;
        //String dayOfWeek = dt.format('EEEE');
        //Integer Hour = System.now().hour();
        
         //Datetime dt = System.now();
         Datetime dt = System.now();
        String dayOfWeek = dt.format('EEEE');
        Integer Hour = dt.hour();
        /*if((dayOfWeek == 'Friday' || dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday'||Test.isRunningTest()))
        {
            if((dayOfWeek == 'Friday' && hour >= 19) || (dayOfWeek == 'Saturday' && hour <19) ||Test.isRunningTest()){
                for(Lead l : newList){
                    l.Route_To_Saturday_Queue1__c = true;
                }
            }
            else if((dayOfWeek == 'Saturday' && hour >= 19) || (dayOfWeek == 'Sunday' && hour <19)){
                for(Lead l : newList){
                    l.Route_To_Sunday_Queue1__c = true;
                }
            }
         }*/
        
    }
  }
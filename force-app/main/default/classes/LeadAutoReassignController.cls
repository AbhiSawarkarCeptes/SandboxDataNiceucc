public without sharing class LeadAutoReassignController {
    public static boolean skipDuplicateLeadLogic = false;
    
    @AuraEnabled
    public static void updateLeadToProcessing(string leadId){
        try{
            Lead l = [select Id,Processing_Owners__c from Lead where Id=:leadId];
            User u = [select Id,Name from User where Id=:UserInfo.getUserId()];
            l.Processing_Owners__c = (l.Processing_Owners__c!=null && l.Processing_Owners__c!='')?l.Processing_Owners__c+', '+u.Name:u.Name;
            l.Last_Call_Attempt_Status__c = 'Processing';
            l.Last_Processing_DateTime__c = system.now();
            LeadAutoReassignController.skipDuplicateLeadLogic = true;
            update l;
        }
        catch(Exception e){
            LeadAutoReassignController.insertErrorLog(leadId,'LeadAutoReassignController','updateLeadToProcessing',e.getMessage(),e.getStackTraceString());
        }
    }
    
    public static map<string,string> getLeadShuffleConfigs(){
        map<string,string> leadShuffleConfigs = new map<string,string>();
        for(Automatic_Lead_Shuffle__mdt config : [select Id,DeveloperName,Value__c from Automatic_Lead_Shuffle__mdt]){
            leadShuffleConfigs.put(config.DeveloperName, config.Value__c);
        }
        return leadShuffleConfigs;
    }
    
    public static void insertErrorLog(string recordId,string className,string methodName,string errorMsg,string stackTrace){
        Error_Log__c log=new Error_Log__c();
        log.Name=recordId;
        log.Class__c=className;
        log.Api_Type__c=methodName;
        log.Message__c=errorMsg;
        log.Request__c=stackTrace;
        insert log;
    }
    
    @InvocableMethod
    public static void reassignLead(List<Lead> leadId) {
        
        try{
            map<string,string> leadShuffleConfigs = LeadAutoReassignController.getLeadShuffleConfigs();
            integer morningStartHour = integer.valueOf(leadShuffleConfigs.get('MorningStartHour'));
            integer morningStartMinute = integer.valueOf(leadShuffleConfigs.get('MorningStartMinute'));
            integer eveningEndHour = integer.valueOf(leadShuffleConfigs.get('EveningEndHour'));
            integer eveningEndMinute = integer.valueOf(leadShuffleConfigs.get('EveningEndMinute'));
            string functionalityToggle = string.valueOf(leadShuffleConfigs.get('FunctionalityToggle'));
            functionalityToggle=functionalityToggle.toLowerCase();
            string roadshowPlaces = string.valueOf(leadShuffleConfigs.get('RoadshowPlaces'));
            String utmCampaignCountries = string.valueOf(leadShuffleConfigs.get('UTM_Campaign_Countries'));
            String campaignCountries = string.valueOf(leadShuffleConfigs.get('campaign_Countries'));
            
            boolean isWorkingHours = false;
            
            string currentTime = system.now().format();
            string hr_min = currentTime.split(' ')[1];
            string am_pm = currentTime.split(' ')[2];
            am_pm = am_pm.toLowerCase();
            integer hr = integer.valueOf(hr_min.split(':')[0]);
            integer min = integer.valueOf(hr_min.split(':')[1]);
            
            Datetime targetDate = System.today();
            String dayOfWeek = targetDate.format('EEEE');
            dayOfWeek = dayOfWeek.toLowerCase();
            
            if(dayOfWeek != 'sunday' && am_pm=='am' && hr!=12 && ((hr==morningStartHour && min>=morningStartMinute) || (hr>morningStartHour)))
            {
                isWorkingHours=true;
            }
            if(dayOfWeek != 'sunday' && am_pm=='pm' && ((hr==eveningEndHour && min<=eveningEndMinute) || (hr<eveningEndHour) || (hr==12)))
            {
                isWorkingHours=true;
            }
            system.debug('isWorkingHours: '+isWorkingHours);
            system.debug('functionalityToggle: '+functionalityToggle);
            //isWorkingHours = true; //for testing purpose
            if((isWorkingHours && functionalityToggle=='true') || Test.isRunningTest()){
                List<Lead> leads = [select Id,Last_Call_Attempt_Status__c,Web_Source__c,OwnerId,Reassigned_Owners__c,Willing_to_meet_this_week__c,
                                    Facebook_Adset_Name__c,Facebook_Ad_Name__c,UTM_Source__c,Campaign_Name__c,Source__c,RDS_Country_Code__c,Lead_Age__c,  
                                    UTM_Campaign__c,Route_To_Saturday_Queue1__c,Route_To_Sunday_Queue1__c,LeadSource,Digital_Source__c,Lead_Sub_Source__c,IsConverted
                                    from Lead where Id =: leadId[0].Id];
                if(leads.size()>0 && (leads[0].Last_Call_Attempt_Status__c=='Not Actioned' || leads[0].Last_Call_Attempt_Status__c=='Processing')){
                    
                    string groupName='';
                    string webSource = (leads[0].Web_Source__c!=null && leads[0].Web_Source__c!='')?leads[0].Web_Source__c:'';
                    string facebookAdsetName = (leads[0].Facebook_Adset_Name__c!=null && leads[0].Facebook_Adset_Name__c!='')?leads[0].Facebook_Adset_Name__c:'';
                    string facebookAdName = (leads[0].Facebook_Ad_Name__c!=null && leads[0].Facebook_Ad_Name__c!='')?leads[0].Facebook_Ad_Name__c:'';
                    string UTMSource = (leads[0].UTM_Source__c!=null && leads[0].UTM_Source__c!='')?leads[0].UTM_Source__c:'';
                    string UTMCampaign = (leads[0].UTM_Campaign__c!=null && leads[0].UTM_Campaign__c!='')?leads[0].UTM_Campaign__c:'';
                    string leadSource = (leads[0].LeadSource!=null && leads[0].LeadSource!='')?leads[0].LeadSource:'';
                    string campaignName = (leads[0].Campaign_Name__c!=null && leads[0].Campaign_Name__c!='')?leads[0].Campaign_Name__c:'';
                    //campaignName = campaignName.toLowerCase();
                    String leadCountryCode = (leads[0].RDS_Country_Code__c != null && leads[0].RDS_Country_Code__c != '')?  leads[0].RDS_Country_Code__c : '' ;
                    String leadDigitalSource = (leads[0].Digital_Source__c != null && leads[0].Digital_Source__c != '')?  leads[0].Digital_Source__c : '' ;
                    String leadSubSource = (leads[0].Lead_Sub_Source__c != null && leads[0].Lead_Sub_Source__c != '')?  leads[0].Lead_Sub_Source__c : '' ;
                    String source = (leads[0].Source__c != null && leads[0].Source__c != '')?  leads[0].Source__c : '' ;
                    String willingToMeet = (leads[0].Willing_to_meet_this_week__c != null && leads[0].Willing_to_meet_this_week__c != '')?  leads[0].Willing_to_meet_this_week__c : '' ;
                    
                    if(campaignName.containsIgnoreCase('Careers')){
                        groupName = 'Careers Lead';
                    }
                    else if(campaignName.containsIgnoreCase('Investor Relation')){
                        groupName = 'Investor Relations';
                    }
                    else if(leadSource=='Stand Leads' && (willingToMeet == 'No' || willingToMeet == 'Later' || (willingToMeet == 'Yes' && leads[0].Lead_Age__c >= 70 && !leads[0].isConverted) )){
                        groupName = 'Mall Stand';
                    }
                    
                    else if(UTMCampaign!='' && UTMCampaign.contains('RS-')){
                        groupName=UTMCampaign.split('-')[1];
                        groupName=groupName.trim(); 
                        groupName = (leadShuffleConfigs.containsKey(groupName))?leadShuffleConfigs.get(groupName):'';
                    }
                    else if(campaignName!='' && campaignName.containsIgnoreCase('roadshow')){
                        /*if(roadshowPlaces!='' && roadshowPlaces!=null){
                             for(string roadshowPlace : roadshowPlaces.split(',')){
                                roadshowPlace = roadshowPlace.trim();
                                roadshowPlace = roadshowPlace.toLowerCase();
                                if(campaignName.contains(roadshowPlace)){
                                    groupName = roadshowPlace;
                                    break;
                                }
                            }
                        }*/
                        groupName = getCountryOrCityName(roadshowPlaces,campaignName);
                        groupName = (leadShuffleConfigs.containsKey(groupName))?leadShuffleConfigs.get(groupName):'';
                    }
                    else if(utmCampaignCountries != null && UTMCampaign!=null && UTMCampaign!='' && UTMCampaign.contains(getCountryOrCityName(utmCampaignCountries,UTMCampaign))) {
                        groupName = getCountryOrCityName(utmCampaignCountries,UTMCampaign);
                        groupName = (leadShuffleConfigs.containsKey(groupName))?leadShuffleConfigs.get(groupName):'';
                    }
                    else if(campaignCountries != null && campaignName!=null && campaignName!='' && campaignName.contains(getCountryOrCityName(campaignCountries,campaignName))) {
                        groupName = getCountryOrCityName(campaignCountries,campaignName);
                        groupName = (leadShuffleConfigs.containsKey(groupName))?leadShuffleConfigs.get(groupName):'';
                    }
                    else if(UTMSource.containsIgnoreCase('Xiongma') || UTMSource.containsIgnoreCase('HF') || UTMSource.containsIgnoreCase('GFN') || UTMSource.containsIgnoreCase('EX') ) {
                        groupName = 'Normal Agent Standard Queue';
                    }
                    else if(leadCountryCode == '+7' || UTMSource.containsIgnoreCase('LGMRU')) {
                        groupName = 'LGMRU';
                    }
                    else if(leadDigitalSource.containsIgnoreCase('Website') ||
                            (leadSource.containsIgnoreCase('Digital') && leadSubSource.containsIgnoreCase('Google-search') && leadSubSource.containsIgnoreCase('-en') )) {
                                groupName = 'Super Agent - English Language';
                            }
                    else if(webSource.containsIgnoreCase('Facebook') || facebookAdsetName.containsIgnoreCase('Facebook/Instagram') || facebookAdName.containsIgnoreCase('Facebook/Instagram') || 
                            facebookAdName.containsIgnoreCase('lead gen') || facebookAdName.containsIgnoreCase('lead-gen') || UTMSource.containsIgnoreCase('propertyfinder') || 
                            UTMSource.containsIgnoreCase('yallacompare') || UTMSource.containsIgnoreCase('HOD') || UTMSource.containsIgnoreCase('Etiquette') || UTMSource.containsIgnoreCase('Facebook') || 
                            UTMSource.containsIgnoreCase('PropertyGuru') || UTMCampaign.containsIgnoreCase('AO-') || leadSource.containsIgnoreCase('Digital') || UTMSource.containsIgnoreCase('bayt') ||
                            UTMSource.containsIgnoreCase('JEAF') || UTMSource.containsIgnoreCase('AZ-AFF') || UTMSource.containsIgnoreCase('SHF') || UTMSource.containsIgnoreCase('SHFSO') ||
                            UTMSource.containsIgnoreCase('AFF-NABD') || UTMSource.containsIgnoreCase('TikTok')){
                                //groupName='Super Agent - English Language Group';
                                groupName = 'Normal Agent Standard Queue';
                            }
                    
                    if(groupName!='' && groupName!=null)
                        groupName = '%'+groupName+'%'; 
                    
                    system.debug('groupName: '+groupName);
                    
                    if(groupName!='' && groupName!=null){
                        list<Assignment_Group_Name__c> assignmentGroups = [select Id, 
                                                                           (select Id,User__c,Rank__c,User__r.Name from Assignment_Groups__r where Active__c='True'
                                                                            AND User_Active__c='True' AND Rank__c!=null Order By Rank__c ASC) 
                                                                           from Assignment_Group_Name__c where Name LIKE : groupName LIMIT 1];
                        
                        system.debug('assignmentGroups.size(): '+assignmentGroups.size());
                        if(assignmentGroups.size()>0){
                            list<Assignment_Groups__c> groups = assignmentGroups[0].Assignment_Groups__r;
                            system.debug('groups.size(): '+groups.size());
                            if(groups.size()>0){
                                integer currentOwnerRank;
                                string selectedOwner='';
                                string selectedOwnerName='';
                                for(Assignment_Groups__c g : groups){
                                    if(g.User__c == leads[0].OwnerId){
                                        currentOwnerRank=Integer.valueOf(g.Rank__c);
                                        break;
                                    }
                                }
                                if(currentOwnerRank==null)
                                    currentOwnerRank=0;
                                if((currentOwnerRank-1) == groups.size()){
                                    selectedOwner = groups[0].User__c;
                                    selectedOwnerName = groups[0].User__r.Name;
                                }
                                if(selectedOwner=='')
                                {
                                    for(Assignment_Groups__c g : groups){
                                        if(g.Rank__c > currentOwnerRank){ 
                                            selectedOwner=g.User__c;
                                            selectedOwnerName = g.User__r.Name;
                                            break; 
                                        }
                                    }
                                }
                                if(selectedOwner=='')
                                {
                                    for(Assignment_Groups__c g : groups){
                                        if(g.Rank__c < currentOwnerRank){
                                            selectedOwner=g.User__c;
                                            selectedOwnerName = g.User__r.Name;
                                            break;
                                        }
                                    }
                                }
                                system.debug('selectedOwner: '+selectedOwner);
                                system.debug('selectedOwnerName: '+selectedOwnerName);
                                if(selectedOwner!=''){
                                    leads[0].Last_Reassign_DateTime__c = system.now();
                                    leads[0].Lead_Assignment_DateTime__c = system.now();
                                    leads[0].Reassign_Owner__c = true;
                                    leads[0].OwnerId = selectedOwner;
                                    leads[0].Presales_Agent__c = selectedOwner;
                                    leads[0].Last_Call_Attempt_Status__c = 'Not Actioned';
                                    leads[0].Reassigned_Owners__c = (leads[0].Reassigned_Owners__c!=null && leads[0].Reassigned_Owners__c!='')?leads[0].Reassigned_Owners__c+', '+selectedOwnerName:selectedOwnerName;
                                    LeadAutoReassignController.skipDuplicateLeadLogic = true;
                                    update leads[0];
                                }                    
                            }
                        }
                    }
                    else{
                        LeadAutoReassignController.insertErrorLog(leadId[0].Id,'LeadAutoReassignController','reassignLead','GROUP NOT FOUND','');
                    }
                }
            }
            else{
                Lead beyondWorkingHourLead = new Lead(Id=leadId[0].Id,Beyond_Working_Hours__c=true);
                LeadAutoReassignController.skipDuplicateLeadLogic = true;
                update beyondWorkingHourLead;
            }
        }
        catch(Exception e){
            LeadAutoReassignController.insertErrorLog(leadId[0].Id,'LeadAutoReassignController','reassignLead',e.getMessage(),e.getStackTraceString());
        }
        
    }
    
    public static string getCountryOrCityName(string countryList, string campaign){
        if(countryList!='' && countryList!=null){
            for(string country : countryList.split(',')){
                country = country.trim();
                if(campaign.contains(country)){
                    return country;
                }
            }
        }
        return 'COUNTRY_CITY_NOT_FOUND';
    }
}
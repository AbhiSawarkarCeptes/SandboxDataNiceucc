public class EnquiryAssignIn60Minutes {
    @InvocableMethod
    public static void reAssignEnquiryIn20Min(List<PropStrength__Request__c> leadId) {
        map<string,string> leadShuffleConfigs = LeadAutoReassignController.getLeadShuffleConfigs();
        integer morningStartHour = integer.valueOf(leadShuffleConfigs.get('MorningStartHour'));
        integer morningStartMinute = integer.valueOf(leadShuffleConfigs.get('MorningStartMinute'));
        integer eveningEndHour = integer.valueOf(leadShuffleConfigs.get('EveningEndHour'));
        integer eveningEndMinute = integer.valueOf(leadShuffleConfigs.get('EveningEndMinute'));
        string functionalityToggle = string.valueOf(leadShuffleConfigs.get('FunctionalityToggle'));
        functionalityToggle=functionalityToggle.toLowerCase();
        string roadshowPlaces = string.valueOf(leadShuffleConfigs.get('RoadshowPlaces'));
        
        boolean isWorkingHours = false;
        
        string currentTime = system.now().format();
        string hr_min = currentTime.split(' ')[1];
        string am_pm = currentTime.split(' ')[2];
        am_pm = am_pm.toLowerCase();
        integer hr = integer.valueOf(hr_min.split(':')[0]);
        integer min = integer.valueOf(hr_min.split(':')[1]);
        
        if(am_pm=='am' && ((hr==morningStartHour && min>=morningStartMinute) || (hr>morningStartHour)))
        {
            isWorkingHours=true;
        }
        if(am_pm=='pm' && ((hr==eveningEndHour && min<=eveningEndMinute) || (hr<eveningEndHour) || (hr==12)))
        {
            isWorkingHours=true;
        }
        system.debug('isWorkingHours: '+isWorkingHours);
        system.debug('functionalityToggle: '+functionalityToggle);
        if((isWorkingHours && functionalityToggle=='true') || Test.isRunningTest()){
            try{
                Map<String, PropStrength__Assignment_Group_Name__c> assGrpMap = new Map<String, PropStrength__Assignment_Group_Name__c>([SELECT Id, Name, (SELECT Id, PropStrength__User__c, PropStrength__Order__c FROM PropStrength__Group_Members__r WHERE PropStrength__Active__c = 'TRUE' ORDER BY PropStrength__Order__c), 
                                                                        (SELECT Id, PropStrength__Criteria__c FROM PropStrength__Assignment_Rule_entries__r ORDER BY PropStrength__Order__c)
                                                                        FROM PropStrength__Assignment_Group_Name__c WHERE PropStrength__Active__c = TRUE AND PropStrength__Type__c = 'Enquiry']);
                
                System.debug('assGrpMap::'+assGrpMap);
                List<PropStrength__Request__c> enquiryList = [select Id,Assignment_Group__c,Enquiry_Owner_Batch_Update_60_min__c,PropStrength__Request_Status__c,Web_Source__c,OwnerId,Reassigned_Owners__c,
                                    Facebook_Adset_Name__c,Facebook_Ad_Name__c,UTM_Source__c,Campaign_Name__c,Mobile_Country_Code__c,  Prefered_LAnguage__c, Last_Processing_DateTime__c, 
                                    UTM_Campaign__c,Route_To_Saturday_Queue1__c,Route_To_Sunday_Queue1__c,PropStrength__Request_Source__c
                                    from PropStrength__Request__c where Id =: leadId[0].Id AND Re_Enquiry__c = TRUE];
                if(!enquiryList.isEmpty()){
                    List<PropStrength__Request__c> updEnqRecList = new List<PropStrength__Request__c>();
                    PropStrength__Request__c req = enquiryList[0];
                    if(req.Enquiry_Owner_Batch_Update_60_min__c != null ) {
                        Long millisecondsDifference = System.now().getTime() - req.Enquiry_Owner_Batch_Update_60_min__c.getTime();
                        Integer minutesDifference = Integer.valueOf(millisecondsDifference / (1000 * 60));
                        System.debug(minutesDifference);
                        
                        if(req.Last_Processing_DateTime__c == null && req.Enquiry_Owner_Batch_Update_60_min__c != null && (req.PropStrength__Request_Status__c == 'Open') && minutesDifference >= 55 && minutesDifference <= 65) {
                            Id userId = null;
                            List<PropStrength__Group_Member__c> usersInfo = new List<PropStrength__Group_Member__c>();
                            if( req.Assignment_Group__c != null && assGrpMap.containsKey(req.Assignment_Group__c)) {
                                usersInfo = assGrpMap.get(req.Assignment_Group__c).PropStrength__Group_Members__r;
                            }
                            
                            System.debug('usersInfo::'+usersInfo);
                            if(!usersInfo.isEmpty()) {
                                Integer cnt = 1;
                                for(Integer i = 0; i < usersInfo.size(); i++) {
                                    if(usersInfo[i].PropStrength__User__c == req.OwnerId && usersInfo.size() > cnt) {
                                        userId = usersInfo[i+1].PropStrength__User__c;
                                    } else if(usersInfo[i].PropStrength__User__c == req.OwnerId && usersInfo.size() == cnt) {
                                        userId = usersInfo[0].PropStrength__User__c;
                                    }
                                    cnt++;
                                }
                                System.debug('userId::'+userId);
                                if(userId != null) {
                                    updEnqRecList.add(new PropStrength__Request__c(Id = req.Id, Enquiry_Owner_Batch_Update_60_min__c = System.now(), OwnerId = userId, Last_Processing_DateTime__c = null));   
                                }
                            }
                        }    
                    }
                    System.debug('updEnqRecList::'+updEnqRecList);
                    if(!updEnqRecList.isEmpty()) {
                        update updEnqRecList;
                    }
                }
            }
            catch(Exception e){
                LeadAutoReassignController.insertErrorLog(leadId[0].Id,'LeadAutoReassignController','reassignLead',e.getMessage(),e.getStackTraceString());
            }
        } 
        else{
            Datetime now = Datetime.now();
            Datetime tomorrowDateTime = Datetime.newInstance(now.year(),now.month(),now.day() + 1,10,00,0);

            System.debug('Tomorrow at 10:00 AM: ' + tomorrowDateTime);
            List<PropStrength__Request__c> updEnqRecList = new List<PropStrength__Request__c>();
            updEnqRecList.add(new PropStrength__Request__c(Id = leadId[0].Id, Enquiry_Owner_Batch_Update_60_min__c = tomorrowDateTime, Last_Processing_DateTime__c = null));   
            System.debug('updEnqRecList::'+updEnqRecList);
            if(!updEnqRecList.isEmpty()) {
                update updEnqRecList;
            }
        }
    }
}
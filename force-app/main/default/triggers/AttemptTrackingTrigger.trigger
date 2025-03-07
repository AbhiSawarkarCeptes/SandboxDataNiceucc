/* Bypass Framework Enabled */
trigger AttemptTrackingTrigger on Attempt_Tracking__c (before update, after update) {
    
	Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    if(trigger.isBefore){
        /*list<Attempt_Tracking__c> atToCheckFileUpload = new list<Attempt_Tracking__c>();
        for(Attempt_Tracking__c at : trigger.new){
            if((at.Name=='Official Mobile') && at.Status__c != trigger.oldmap.get(at.id).Status__c){
                atToCheckFileUpload.add(at);
            }
        }
        map<string,integer> attemptToFiles = new map<string,integer>();
        if(atToCheckFileUpload.size()>0){
            for(Attempt_Tracking__c at : [select Id, (select Id from ContentDocumentLinks) from Attempt_Tracking__c where ID IN: atToCheckFileUpload]){
                if(at.ContentDocumentLinks != null){
                    attemptToFiles.put(at.Id,at.ContentDocumentLinks.size());
                }
                else{
                    attemptToFiles.put(at.Id,0);
                }
            }
        }
        for(Attempt_Tracking__c at : trigger.new){
            if(attemptToFiles.containsKey(at.Id) && attemptToFiles.get(at.Id) == 0 && !Test.isRunningTest()){
                at.addError('Please attach the screenshot of the attempt under Notes & Attachments.');
            }
        }*/
    }
    
    if(trigger.isAfter){
        list<string> invalidStatusList = new list<string>();
        invalidStatusList.add('Junk Lead');
        invalidStatusList.add('junk lead');
        invalidStatusList.add('junk Lead');
        invalidStatusList.add('Junk lead');
        invalidStatusList.add('junk');
        invalidStatusList.add('Junklead');
        invalidStatusList.add('JUNK LEAD');
        
        list<Attempt_Tracking__c> atToProcess = new list<Attempt_Tracking__c>();
        list<Attempt_Tracking__c> atToUpdateDayTracking = new list<Attempt_Tracking__c>();
        for(Attempt_Tracking__c at : trigger.new){
            if((at.Status__c == 'No Contact - Follow-up' || at.Status__c == 'WhatsApp Not Available') && at.Status__c != trigger.oldmap.get(at.id).Status__c){
                atToProcess.add(at);
            }
            if(at.Status__c != trigger.oldmap.get(at.id).Status__c){
                atToUpdateDayTracking.add(at);
            }
        }
        
        map<string,string> dayToAttempts = new map<string,string>();
        List<Lead_Nurturing__mdt> days = [select Label, Value__c from Lead_Nurturing__mdt where DeveloperName LIKE 'Day_%'];
        for(Lead_Nurturing__mdt d : days){
            dayToAttempts.put(d.Label,d.Value__c);
        }
        
        map<string,string> recordTypeNameToId = new map<string,string>();
        for(RecordType recType : [select id,name from RecordType where sObjectType='Attempt_Tracking__c']){
            recordTypeNameToId.put(recType.name,recType.id);
        }
        
        list<Attempt_Tracking__c> atToInsert = new list<Attempt_Tracking__c>();
        list<Attempt_Tracking__c> atToInsert4Hours = new list<Attempt_Tracking__c>();
        for(Attempt_Tracking__c at : [select Id,Day_Tracking__c,Attempt_Sequence__c,Day_Tracking__r.Name,Attempted_By__c,Day_Tracking__r.Lead__r.WhatsApp_Not_Available__c from Attempt_Tracking__c where ID IN : atToProcess AND Day_Tracking__r.Lead__r.Last_Call_Attempt_Status__c NOT IN : invalidStatusList]){
            string allAttempts = dayToAttempts.get(at.Day_Tracking__r.Name);
            if(Integer.valueOf(at.Attempt_Sequence__c) < allAttempts.split(',').size()){
                string attempt = allAttempts.split(',')[Integer.valueOf(at.Attempt_Sequence__c)];
                Attempt_Tracking__c a = new Attempt_Tracking__c();
                if(attempt=='WhatsApp' && at.Day_Tracking__r.Lead__r.WhatsApp_Not_Available__c){
                    attempt = allAttempts.split(',')[Integer.valueOf(at.Attempt_Sequence__c)+1];
                    a.Attempt_Sequence__c = string.valueOf(Integer.valueOf(at.Attempt_Sequence__c) + 2);
                }
                else{
                    a.Attempt_Sequence__c = string.valueOf(Integer.valueOf(at.Attempt_Sequence__c) + 1);
                }
                a.Day_Tracking__c = at.Day_Tracking__c;
                a.Attempted_By__c = at.Attempted_By__c;
                a.Name = attempt;
                a.RecordTypeId = recordTypeNameToId.get(attempt);
                if(attempt == 'Official Mobile' || attempt == 'Official Landline'){
                    atToInsert4Hours.add(a);
                }else{
                    atToInsert.add(a);
                }
                
            }
        }
        if(atToInsert.size() > 0){
            insert atToInsert;
        }
        if(atToInsert4Hours.size() > 0){
            map<string,string> leadShuffleConfigs = LeadNurturingController.getLeadNurturingConfigs();
            integer morningStartHour = integer.valueOf(leadShuffleConfigs.get('MorningStartHour'));
            integer morningStartMinute = integer.valueOf(leadShuffleConfigs.get('MorningStartMinute'));
            integer eveningEndHour = integer.valueOf(leadShuffleConfigs.get('EveningEndHour'));
            integer eveningEndMinute = integer.valueOf(leadShuffleConfigs.get('EveningEndMinute'));
            integer attemptInterval = integer.valueOf(leadShuffleConfigs.get('Attempt_Interval'));
            boolean isWorkingHours = false;
            
            string currentTime = system.now().addHours(attemptInterval).format();
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
            if(isWorkingHours)
                insert atToInsert4Hours;
        }
        
        if(atToUpdateDayTracking.size()>0){
            list<Day_Tracking__c> dayToUpdate = new list<Day_Tracking__c>();
            map<string,string> dayTrackingToStatus = new map<string,string>();
            set<string> dayIdsWhereWhatsAppNotAvailable = new set<string>();
            
            for(Attempt_Tracking__c at : atToUpdateDayTracking){
                if(at.Status__c == 'WhatsApp Not Available'){
                    dayIdsWhereWhatsAppNotAvailable.add(at.Day_Tracking__c);
                    dayToUpdate.add(new Day_Tracking__c(Id=at.Day_Tracking__c));
                    dayTrackingToStatus.put(at.Day_Tracking__c,at.Status__c);
                }
                else{
                    dayToUpdate.add(new Day_Tracking__c(Id=at.Day_Tracking__c,Status__c=at.Status__c));
                	dayTrackingToStatus.put(at.Day_Tracking__c,at.Status__c);
                }
            }
            if(dayToUpdate.size()>0){
                try{
                    update dayToUpdate;
                    list<Lead> leadToUpdate = new list<Lead>();
                    for(Day_Tracking__c d : [select Id,Lead__c from Day_Tracking__c where Id IN: dayTrackingToStatus.keySet()]){
                        if(dayIdsWhereWhatsAppNotAvailable.contains(d.Id)){
                            leadToUpdate.add(new Lead(Id=d.Lead__c,Last_Attempt_Date__c=system.now(),WhatsApp_Not_Available__c=true));
                        }
                        else{
                            leadToUpdate.add(new Lead(Id=d.Lead__c,Last_Call_Attempt_Status__c=dayTrackingToStatus.get(d.Id),Last_Attempt_Status__c=dayTrackingToStatus.get(d.Id),Last_Attempt_Date__c=system.now()));
                        }
                    }
                    if(leadToUpdate.size()>0){
                        LeadAutoReassignController.skipDuplicateLeadLogic = true;
                        update leadToUpdate;
                    }
                }
                catch(Exception e){
                    system.debug('VVK leadToUpdate: '+e.getMessage());
                }
            }
        }
    }
    
}
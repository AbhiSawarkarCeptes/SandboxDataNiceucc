global class CreateLeadDailyTrackingBatch implements Database.Batchable<sObject>, Schedulable {
    global list<string> statusList = new list<string>();
    global list<string> presalesLastCallAttemptStatusList = new list<string>();
    global list<string> invalidStatusList = new list<string>();
    
    global void execute(SchedulableContext SC) {
        Database.executebatch(new CreateLeadDailyTrackingBatch(),50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        statusList.add('No Contact - Follow-up'); // configure metadata  
        presalesLastCallAttemptStatusList.add('Not Actioned');
        invalidStatusList.add('Junk Lead');
        invalidStatusList.add('junk lead');
        invalidStatusList.add('junk Lead');
        invalidStatusList.add('Junk lead');
        invalidStatusList.add('junk');
        invalidStatusList.add('Junklead');
        invalidStatusList.add('JUNK LEAD');
        
        String query = 'SELECT Id, CreatedDate, Last_Attempt_Status__c FROM Lead WHERE Last_Attempt_Status__c IN: statusList AND Last_Call_Attempt_Status__c NOT IN : invalidStatusList';
        //Below query is only for UAT
        //String query = 'SELECT Id, CreatedDate, Last_Attempt_Status__c, Temp_CreatedDate__c FROM Lead WHERE Last_Attempt_Status__c IN: statusList and Temp_CreatedDate__c != null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        map<string,string> leadShuffleConfigs = LeadNurturingController.getLeadNurturingConfigs();
        list<Day_Tracking__c> dayTrackingsToCreate = new list<Day_Tracking__c>();
        Date tdy = system.today();
        string skipDays = string.valueOf(leadShuffleConfigs.get('SkipDays'));
        list<integer> skipDaysList = new list<integer>();
        for(String day : skipDays.split(',')){
            day = day.trim();
            skipDaysList.add(Integer.valueOf(day));
        }
        list<lead> toBeCloseLeadList = new list<lead>();
        for(Lead l : leadList){
            Integer leadAge = (tdy.daysBetween(l.CreatedDate.Date()))*(-1)+1;
            //Below line is only for UAT
            //Integer leadAge = (tdy.daysBetween(l.Temp_CreatedDate__c.Date()))*(-1)+1;
            if(leadAge<21 && !skipDaysList.contains(leadAge)){ // configure 21
                Day_Tracking__c d = new Day_Tracking__c();
                d.Name = 'Day '+leadAge;
                d.Lead__c = l.Id;
                dayTrackingsToCreate.add(d);
            }
            if(leadAge==21){
                l.Status = 'Closed';
                toBeCloseLeadList.add(l);
            }
        }
        if(dayTrackingsToCreate.size()>0){
            insert dayTrackingsToCreate;
            list<Attempt_Tracking__c> atToInsert = new list<Attempt_Tracking__c>();
            map<string,string> dayToAttempts = new map<string,string>();
            List<Lead_Nurturing__mdt> days = [select Label, Value__c from Lead_Nurturing__mdt where DeveloperName LIKE 'Day_%'];
            for(Lead_Nurturing__mdt d : days){
                dayToAttempts.put(d.Label,d.Value__c);
            }
            map<string,string> recordTypeNameToId = new map<string,string>();
            for(RecordType recType : [select id,name from RecordType where sObjectType='Attempt_Tracking__c']){
                recordTypeNameToId.put(recType.name,recType.id);
            }
            for(Day_Tracking__c dT : [select Id, Name, Lead__r.OwnerId, Lead__r.WhatsApp_Not_Available__c from Day_Tracking__c where Id IN : dayTrackingsToCreate]){
                string ownerId = dT.Lead__r.OwnerId;
                string allAttempts = dayToAttempts.get(dT.Name);
                string attempt = allAttempts.split(',')[0];
                Attempt_Tracking__c a = new Attempt_Tracking__c();
                if(attempt=='WhatsApp' && dT.Lead__r.WhatsApp_Not_Available__c){
                    attempt = allAttempts.split(',')[1];
                    a.Attempt_Sequence__c = '2';
                }
                else{
                    a.Attempt_Sequence__c = '1';
                }
                a.Day_Tracking__c = dT.Id;
                a.Name = attempt;
                a.Attempted_By__c = (ownerId!=null && ownerId.startsWith('005'))?ownerId:null;
                a.RecordTypeId = recordTypeNameToId.get(attempt);
                atToInsert.add(a);
            }
            if(atToInsert.size()>0){
                insert atToInsert;
            }
        }
        if(toBeCloseLeadList.size()>0){
            try{
            	update toBeCloseLeadList;
            }
            catch(Exception e){
                
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
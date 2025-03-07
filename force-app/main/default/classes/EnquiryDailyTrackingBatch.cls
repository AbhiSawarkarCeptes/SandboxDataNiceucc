global class EnquiryDailyTrackingBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, CreatedDate, Last_Attempt_Status__c, Temp_CreatedDate__c ' + 
                        'FROM PropStrength__Request__c ' + 
                        'WHERE Last_Attempt_Status__c = \'No Contact - Follow-up\'';
        /*if(!Test.isRunningTest()) {
            query += 'AND CreatedDate < Today';
        }*/
        //For UAT
        query += 'AND Temp_CreatedDate__c != null AND Temp_CreatedDate__c < Today';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<PropStrength__Request__c> requestList) {
        System.debug('===> requestList ' + requestList);
        List<Day_Tracking__c> dayTrackingList = new List<Day_Tracking__c>();
        Map<String, String> leadNurturingConfig = new Map<String, String>();
        List<Integer> skipDaysList = new List<Integer>();
        List<PropStrength__Request__c> closedRequestList = new List<PropStrength__Request__c>();
        Set<String> dayTrackIds = new Set<String>();
        List<Attempt_Tracking__c> attempTrackList = new List<Attempt_Tracking__c>();
        Map<String, String> attempTrackingRecordTypeToIdMap = new Map<String, String>();
        Date to_day = System.today();
        for(RecordType recType : [SELECT id, Name FROM RecordType 
                                    WHERE sObjectType = 'Attempt_Tracking__c' LIMIT 99]) {
            attempTrackingRecordTypeToIdMap.put(recType.Name, recType.Id);
        }
        for(Lead_Nurturing__mdt config : [SELECT Id, Label, DeveloperName, Value__c 
                                            FROM Lead_Nurturing__mdt LIMIT 999]) {
            leadNurturingConfig.put(config.Label, config.Value__c);
        }
        if(leadNurturingConfig.containskey('SkipDays')) {
            String skipDays = String.valueOf(leadNurturingConfig.get('SkipDays'));
            for(String day : skipDays.split(',')) {
                day = day.trim();
                skipDaysList.add(Integer.valueOf(day));
            }
        }
        System.debug('===> skipDaysList ' + skipDaysList);
        try {
            if(requestList != null && !requestList.isEmpty()) {
                for(PropStrength__Request__c req : requestList) {
                    /*Integer requestAge;
                    if(!Test.isRunningTest()) {
                        requestAge = (to_day.daysBetween(req.CreatedDate.Date())) * (-1) + 1;
                    } else {
                        requestAge = 2;
                    }*/
                    //For UAT
                    Integer requestAge = (to_day.daysBetween(req.Temp_CreatedDate__c.Date())) * (-1) + 1;
                    System.debug('===> requestAge ' + requestAge);
                    if(requestAge < 21 && !skipDaysList.contains(requestAge)) {
                        Day_Tracking__c dayTrack = new Day_Tracking__c();
                        dayTrack.Name = 'Day ' + requestAge;
                        dayTrack.Enquiry__c = req.Id;
                        dayTrackingList.add(dayTrack);
                    }
                    if(requestAge == 21) {
                        req.PropStrength__Request_Status__c = 'Closed/ Lost';
                        closedRequestList.add(req);
                    }
                }
            }
            System.debug('===> dayTrackingList ' + dayTrackingList);
            if(!dayTrackingList.isEmpty()) {
                Database.SaveResult[] saveDailyResult = Database.insert(dayTrackingList, false);
                for(Database.SaveResult srDaily : saveDailyResult) {
                    if(srDaily.isSuccess()) {
                        System.debug('===> Daily Track Id: ' + srDaily.getId());
                        dayTrackIds.add(String.valueof(srDaily.getId()));
                    } else {
                        for(Database.Error errDaily : srDaily.getErrors()) {
                            System.debug('===> Exception: ' + errDaily.getMessage());
                        }
                    }
                }
            }
            System.debug('===> dayTrackIds ' + dayTrackIds);
            if(!dayTrackIds.isEmpty()) {
                for(Day_Tracking__c dTrack : [SELECT Id, Name, Enquiry__r.OwnerId, 
                                                Enquiry__r.WhatsApp_Not_Available__c 
                                                FROM Day_Tracking__c 
                                                WHERE Id IN: dayTrackIds]) {
                    System.debug('===> dayTrackIds ' + dayTrackIds);
                    if(leadNurturingConfig.containskey(dTrack.Name)) {
                        String allAttempts = leadNurturingConfig.get(dTrack.Name);
                        String attempt = allAttempts.split(',')[0];
                        if(attempTrackingRecordTypeToIdMap.containskey(attempt)) {
                            Attempt_Tracking__c attemptRec = new Attempt_Tracking__c();
                            if(attempt == 'WhatsApp' && dTrack.Enquiry__r.WhatsApp_Not_Available__c) {
                                attempt = allAttempts.split(',')[1];
                                attemptRec.Attempt_Sequence__c = '2';
                            } else {
                                attemptRec.Attempt_Sequence__c = '1';
                            }
                            attemptRec.Day_Tracking__c = dTrack.Id;
                            attemptRec.Name = attempt;
                            attemptRec.Attempted_By__c = (dTrack.Enquiry__r.OwnerId != null) ? dTrack.Enquiry__r.OwnerId : null;
                            attemptRec.RecordTypeId = attempTrackingRecordTypeToIdMap.get(attempt);
                            attempTrackList.add(attemptRec);
                        }
                    }
                }
            }
            System.debug('===> attempTrackList ' + attempTrackList);
            if(!attempTrackList.isEmpty()) {
                Database.SaveResult[] saveAttempResult = Database.insert(attempTrackList, false);
                for(Database.SaveResult srTrack : saveAttempResult) {
                    if(srTrack.isSuccess()) {
                        System.debug('===> Attemp Track Id: ' + srTrack.getId());
                    } else {
                        for(Database.Error errTrack : srTrack.getErrors()) {
                            System.debug('===> Exception: ' + errTrack.getMessage());
                        }
                    }
                }
            }
            if(!closedRequestList.isEmpty()) {
                Database.SaveResult[] saveEnqResult = Database.update(closedRequestList, false);
                for(Database.SaveResult srEnq : saveEnqResult) {
                    if(srEnq.isSuccess()) {
                        System.debug('===> Enq Id: ' + srEnq.getId());
                    } else {
                        for(Database.Error errEnq : srEnq.getErrors()) {
                            System.debug('===> Exception: ' + errEnq.getMessage());
                        }
                    }
                }
            }
        } catch(Exception exec) {
            System.debug('===> Exception: ' + exec.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}
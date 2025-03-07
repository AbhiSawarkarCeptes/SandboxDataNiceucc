public class AttemptTrackingTriggerHelper {
    public static boolean run = true;
    //Validate Attempt Record - When update attempt record upload at least one file in related List
    public static void validateAttemptTracking(List<Attempt_Tracking__c> newAttempList, Map<Id, Attempt_Tracking__c> oldAttempMap) {
        List<Attempt_Tracking__c> checkFileUploadList = new List<Attempt_Tracking__c>();
        Map<String, Integer> attemptToFiles = new Map<String, Integer>();
        for(Attempt_Tracking__c attempt : newAttempList) {
            if(attempt.Name == 'Official Mobile' && attempt.Status__c != oldAttempMap.get(attempt.id).Status__c) {
                checkFileUploadList.add(attempt);
            }
        }
        if(!checkFileUploadList.isEmpty()) {
            for(Attempt_Tracking__c attemptRecord : [SELECT Id, (SELECT Id FROM ContentDocumentLinks) 
                                                        FROM Attempt_Tracking__c 
                                                        WHERE ID IN: checkFileUploadList]) {
                if(attemptRecord.ContentDocumentLinks != null) {
                    attemptToFiles.put(attemptRecord.Id, attemptRecord.ContentDocumentLinks.size());
                } else {
                    attemptToFiles.put(attemptRecord.Id, 0);
                }
            }
        }
        for(Attempt_Tracking__c rec : newAttempList) {
            if(attemptToFiles.containsKey(rec.Id) && 
                attemptToFiles.get(rec.Id) == 0 && 
                !Test.isRunningTest()) {
                rec.addError('Please attach the screenshot of the attempt under Notes & Attachments.');
            }
            if(rec.Status__c != oldAttempMap.get(rec.id).Status__c && 
                (oldAttempMap.get(rec.id).Status__c == 'Sobha Landline - Contacted' || 
                oldAttempMap.get(rec.id).Status__c == 'WhatsApp - Contacted' || 
                oldAttempMap.get(rec.id).Status__c == 'Email - Contacted' || 
                oldAttempMap.get(rec.id).Status__c == 'Official Mobile - Contacted' || 
                oldAttempMap.get(rec.id).Status__c == 'Official Landline - Contacted') && 
                !Test.isRunningTest()) {
                rec.addError('You cann\'t change this status.');
            }
        }
    }
    //When user change the status on Attempt Tracking, New Attempt Tracking Record will be 
    //Created as per Lead Nurturing Metadata and Update Day Tracking Status and Update Lead and Enquiry
    public static void updateLeadandEnquiry(List<Attempt_Tracking__c> newAttempList, Map<Id, Attempt_Tracking__c> oldAttempMap) {
        System.debug(newAttempList);
        System.debug(oldAttempMap);
        Set<String> attemptIds = new Set<String>();
        Set<String> dayIdsWhereWhatsAppNotAvailable = new Set<String>();
        List<Day_Tracking__c> dayToUpdate = new List<Day_Tracking__c>();
        Map<String, String> dayTrackingToStatus = new Map<String, String>();
        Map<String, String> dayToAttempts = new map<String, String>();
        Map<String, String> recordTypeNameToId = new Map<String, String>();
        List<Attempt_Tracking__c> existAttemtpList = new List<Attempt_Tracking__c>();
        List<Attempt_Tracking__c> atToInsert = new List<Attempt_Tracking__c>();
        List<Attempt_Tracking__c> atToInsert4Hours = new List<Attempt_Tracking__c>();
        Map<String, List<String>> dayToAttemptListMap = new Map<String, List<String>>();
        for(Attempt_Tracking__c aTRecord : newAttempList) {
            System.debug('===> aTRecord ' + aTRecord);
            System.debug('===> aTRecord ' + aTRecord.Status__c);
            if((aTRecord.Status__c == 'No Contact - Follow-up' || 
                aTRecord.Status__c == 'WhatsApp Not Available') && 
                aTRecord.Status__c != oldAttempMap.get(aTRecord.id).Status__c) {
                attemptIds.add(aTRecord.Id);
            }
            if(aTRecord.Status__c != oldAttempMap.get(aTRecord.id).Status__c && 
                aTRecord.Day_Tracking__c != null) {
                if(aTRecord.Status__c == 'WhatsApp Not Available') {
                    dayIdsWhereWhatsAppNotAvailable.add(aTRecord.Day_Tracking__c);
                }
                dayToUpdate.add(new Day_Tracking__c(Id = aTRecord.Day_Tracking__c, Status__c = aTRecord.Status__c));
                dayTrackingToStatus.put(aTRecord.Day_Tracking__c, aTRecord.Status__c);
            }
        }
        System.debug('===> attemptIds ' + attemptIds);
        System.debug('===> dayIdsWhereWhatsAppNotAvailable ' + dayIdsWhereWhatsAppNotAvailable);
        System.debug('===> dayToUpdate ' + dayToUpdate);
        System.debug('===> dayTrackingToStatus ' + dayTrackingToStatus);
        for(Lead_Nurturing__mdt nurture : [SELECT Label, Value__c 
                                            FROM Lead_Nurturing__mdt 
                                            WHERE Value__c != null LIMIT 999]) {
            dayToAttempts.put(nurture.Label, nurture.Value__c);
        }
        System.debug('===> dayToAttempts ' + dayToAttempts);
        for(RecordType recType : [SELECT Id, Name FROM RecordType 
                                    WHERE sObjectType = 'Attempt_Tracking__c' LIMIT 99]) {
            recordTypeNameToId.put(recType.Name, recType.Id);
        }
        System.debug('===> recordTypeNameToId ' + recordTypeNameToId);
        if(!dayTrackingToStatus.keyset().isEmpty()) {
            for(Attempt_Tracking__c arRecord : [SELECT Id, Name, Day_Tracking__c 
                                                FROM Attempt_Tracking__c 
                                                WHERE Day_Tracking__c IN: dayTrackingToStatus.keyset()]) {
                if(dayToAttemptListMap.containskey(arRecord.Day_Tracking__c)) {
                    List<String> tempList = dayToAttemptListMap.get(arRecord.Day_Tracking__c);
                    tempList.add(arRecord.Name);
                    dayToAttemptListMap.put(arRecord.Day_Tracking__c, tempList);
                } else {
                    dayToAttemptListMap.put(arRecord.Day_Tracking__c, new List<String>{arRecord.Name});
                }
            }
        }
        if(!attemptIds.isEmpty()) {
            for(Attempt_Tracking__c aRecord : [SELECT Id, Name, Day_Tracking__c, Attempt_Sequence__c, 
                                                Day_Tracking__r.Name, Attempted_By__c, 
                                                Day_Tracking__r.Lead__c, Day_Tracking__r.Enquiry__c, 
                                                Day_Tracking__r.Lead__r.WhatsApp_Not_Available__c, 
                                                Day_Tracking__r.Enquiry__r.WhatsApp_Not_Available__c 
                                                FROM Attempt_Tracking__c 
                                                WHERE Id IN : attemptIds]) {
                if(dayToAttempts.containskey(aRecord.Day_Tracking__r.Name) && 
                    aRecord.Attempt_Sequence__c != null) {
                    String allAttempts = dayToAttempts.get(aRecord.Day_Tracking__r.Name);
                    System.debug('===> allAttempts ' + allAttempts);
                    List<String> allAttemptNames = new List<String>();
                    if(allAttempts.contains(',')) {
                        allAttemptNames.addAll(allAttempts.split(','));
                    } else {
                        allAttemptNames.add(allAttempts);
                    }
                    if(Integer.valueOf(aRecord.Attempt_Sequence__c) < allAttemptNames.size()) {
                        String attempt = allAttemptNames[Integer.valueOf(aRecord.Attempt_Sequence__c)];
                        System.debug('===> attempt ' + attempt);
                        if(recordTypeNameToId.containskey(attempt) && 
                            dayToAttemptListMap.containskey(aRecord.Day_Tracking__c) && 
                            !dayToAttemptListMap.get(aRecord.Day_Tracking__c).isEmpty() && 
                            !dayToAttemptListMap.get(aRecord.Day_Tracking__c).contains(attempt)) {
                            Attempt_Tracking__c a = new Attempt_Tracking__c();
                            if(attempt == 'WhatsApp' && 
                                ((aRecord.Day_Tracking__r.Lead__c != null && 
                                aRecord.Day_Tracking__r.Lead__r.WhatsApp_Not_Available__c) || 
                                (aRecord.Day_Tracking__r.Enquiry__c != null && 
                                aRecord.Day_Tracking__r.Enquiry__r.WhatsApp_Not_Available__c))) {
                                System.debug('===> Call Call ');
                                attempt = allAttemptNames[Integer.valueOf(aRecord.Attempt_Sequence__c) + 1];
                                a.Attempt_Sequence__c = string.valueOf(Integer.valueOf(aRecord.Attempt_Sequence__c) + 2);
                            } else {
                                a.Attempt_Sequence__c = string.valueOf(Integer.valueOf(aRecord.Attempt_Sequence__c) + 1);
                            }
                            a.Day_Tracking__c = aRecord.Day_Tracking__c;
                            a.Attempted_By__c = aRecord.Attempted_By__c;
                            a.Name = attempt;
                            a.RecordTypeId = recordTypeNameToId.get(attempt);
                            System.debug('===> a ' + a);
                            if(attempt == 'Official Mobile' || attempt == 'Official Landline') {
                                atToInsert4Hours.add(a);
                            } else {
                                atToInsert.add(a);
                            }
                        }
                    }
                }
            }
        }
        System.debug('===> atToInsert ' + atToInsert);
        System.debug('===> atToInsert4Hours ' + atToInsert4Hours);
        if(atToInsert.size() > 0) {
            insert atToInsert;
        }
        if(atToInsert4Hours.size() > 0) {
            Integer morningStartHour = 0;
            Integer morningStartMinute = 0;
            Integer eveningEndHour = 0;
            Integer eveningEndMinute = 0;
            Integer attemptInterval = 0;
            Boolean isWorkingHours = false;
            if(dayToAttempts.containskey('MorningStartHour')) {
                morningStartHour = Integer.valueOf(dayToAttempts.get('MorningStartHour'));
            }
            if(dayToAttempts.containskey('MorningStartMinute')) {
                morningStartMinute = Integer.valueOf(dayToAttempts.get('MorningStartMinute'));
            }
            if(dayToAttempts.containskey('EveningEndHour')) {
                eveningEndHour = Integer.valueOf(dayToAttempts.get('EveningEndHour'));
            }
            if(dayToAttempts.containskey('EveningEndMinute')) {
                eveningEndMinute = Integer.valueOf(dayToAttempts.get('EveningEndMinute'));
            }
            if(dayToAttempts.containskey('Attempt_Interval')) {
                attemptInterval = Integer.valueOf(dayToAttempts.get('Attempt_Interval'));
            }
            String currentTime = system.now().addHours(attemptInterval).format();
            String hr_min = currentTime.split(' ')[1];
            String am_pm = currentTime.split(' ')[2];
            am_pm = am_pm.toLowerCase();
            Integer hr = Integer.valueOf(hr_min.split(':')[0]);
            Integer min = Integer.valueOf(hr_min.split(':')[1]);
            if(am_pm == 'am' && 
                ((hr == morningStartHour && min >= morningStartMinute) || 
                (hr>morningStartHour))) {
                isWorkingHours = true;
            }
            if(am_pm == 'pm' && 
                ((hr==eveningEndHour && min<=eveningEndMinute) || 
                (hr<eveningEndHour) || (hr==12))) {
                isWorkingHours = true;
            }
            if(isWorkingHours) {
                insert atToInsert4Hours;
            }
        }
        if(!dayToUpdate.isEmpty()) {
            try {
                update dayToUpdate;
                List<Lead> leadToUpdate = new List<Lead>();
                List<PropStrength__Request__c> requestList = new List<PropStrength__Request__c>();
                for(Day_Tracking__c d : [SELECT Id, Lead__c, Enquiry__c 
                                            FROM Day_Tracking__c 
                                            WHERE Id IN: dayTrackingToStatus.keySet()]) {
                    if(d.Lead__c != null) {
                        if(dayIdsWhereWhatsAppNotAvailable.contains(d.Id)) {
                            leadToUpdate.add(new Lead(Id=d.Lead__c, 
                                                        Last_Attempt_Date__c=system.now(),
                                                        WhatsApp_Not_Available__c=true));
                        } else{
                            leadToUpdate.add(new Lead(Id=d.Lead__c, 
                                                        Last_Call_Attempt_Status__c=dayTrackingToStatus.get(d.Id), 
                                                        Last_Attempt_Status__c=dayTrackingToStatus.get(d.Id), 
                                                        Last_Attempt_Date__c=system.now()));
                        }
                    } else if(d.Enquiry__c != null) {
                        System.debug('===> dayIdsWhereWhatsAppNotAvailable.contains(d.Id) ' + dayIdsWhereWhatsAppNotAvailable.contains(d.Id));
                        if(dayIdsWhereWhatsAppNotAvailable.contains(d.Id)) {
                            requestList.add(new PropStrength__Request__c(Id=d.Enquiry__c, 
                                                                        Last_Attempt_Date__c=system.now(), 
                                                                        WhatsApp_Not_Available__c=true));
                        } else{
                            requestList.add(new PropStrength__Request__c(Id=d.Enquiry__c, 
                                                                            Last_Call_Attempt_Status__c=dayTrackingToStatus.get(d.Id), 
                                                                            Last_Attempt_Status__c=dayTrackingToStatus.get(d.Id), 
                                                                            Last_Attempt_Date__c=system.now()));
                        }
                    }
                }
                if(leadToUpdate.size()>0) {
                    LeadAutoReassignController.skipDuplicateLeadLogic = true;
                    update leadToUpdate;
                }
                System.debug('===> requestList.size() ' + requestList.size());
                if(requestList.size()>0) {
                    update requestList;
                }
            } catch(Exception e) {
                system.debug('===> Exception: ' + e.getMessage());
            }
        }
    }
    public static boolean runOnce() {
        if(run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }
}
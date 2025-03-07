public class TaskTriggerHelper {
    public static boolean run = true;
    //When user will change value of "Call Attempt Status" field,
    //It's Related To (Enquiry) and Name (Contact) Record fields wil be updated.
    //(Last Call Attempt Status, Last Attempt Status, Last Attempt Date)
    public static void updateRelatedOrAssignedToRecord(List<Task> newTaskList, Map<Id, Task> oldTaskMap) {
        try {
            Map<String, Task> idToTaskMap = new Map<String, Task>();
            Set<String> objectIds = new Set<String>();
            List<PropStrength__Request__c> reqList = new List<PropStrength__Request__c>();
            List<Contact> conList = new List<Contact>();
            for(Task tsk : newTaskList) {
                if(tsk.Call_Attempt_Status__c != null && 
                    tsk.Call_Attempt_Status__c != oldTaskMap.get(tsk.Id).Call_Attempt_Status__c) {
                    if(tsk.WhatId != null) {
                        objectIds.add(tsk.WhatId);
                        idToTaskMap.put(tsk.WhatId, tsk);
                    }
                    if(tsk.WhoId != null) {
                        objectIds.add(tsk.WhoId);
                        idToTaskMap.put(tsk.WhoId, tsk);
                    }
                }
            }
            System.debug('===> objectIds ' + objectIds);
            System.debug('===> idToTaskMap ' + idToTaskMap);
            if(!objectIds.isEmpty()) {
                for(String str : objectIds) {
                    Id initiateId = Id.valueOf(str);
                    System.debug('===> initiateId ' + initiateId);
                    String objAPIName = initiateId.getSObjectType().getDescribe().getName();
                    System.debug('===> objAPIName ' + objAPIName);
                    if(idToTaskMap.containskey(str)) {
                        if(objAPIName == 'PropStrength__Request__c') {
                            PropStrength__Request__c req = new PropStrength__Request__c();
                            req.Id = str;
                            req.Last_Call_Attempt_Status__c = idToTaskMap.get(str).Call_Attempt_Status__c;
                            req.Last_Attempt_Status__c = idToTaskMap.get(str).Call_Attempt_Status__c;
                            req.Last_Attempt_Date__c = System.now();
                            reqList.add(req);
                        } else if(objAPIName == 'Contact') {
                            Contact con = new Contact();
                            con.Id = str;
                            con.Last_Call_Attempt_Status__c = idToTaskMap.get(str).Call_Attempt_Status__c;
                            con.Last_Attempt_Status__c = idToTaskMap.get(str).Call_Attempt_Status__c;
                            con.Last_Attempt_Date__c = System.now();
                            conList.add(con);
                        }
                    }
                }
            }
            System.debug('===> reqList ' + reqList);
            if(!reqList.isEmpty()) {
                update reqList;
            }
            System.debug('===> conList ' + conList);
            if(!conList.isEmpty()) {
                update conList;
            }
        } catch(Exception exe) {
            System.debug('===> Exception: ' + exe.getMessage());
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
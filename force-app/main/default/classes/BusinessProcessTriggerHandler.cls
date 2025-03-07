public class BusinessProcessTriggerHandler {
    
    Public static void sendEmailOnCompletion(List<Business_Process__c> newList, Map<Id,Business_Process__c> oldMap){
        set<id> bpIdSet = new set<id>();
        for(Business_Process__c bp :newList){
            if(bp.Status__c == 'Completed' && bp.Status__c != oldMap.get(bp.Id).Status__c){
                bpIdSet.add(bp.Id);
            }
        } 
        set<id> queueIds = new set<id>();
        for(Business_Process_Step__c bps :[Select Id,Business_Process__c, Original_Queue_Id__c From Business_Process_Step__c where Business_Process__c In : bpIdSet]){
            if(bps.Original_Queue_Id__c != null){
                queueIds.add(bps.Original_Queue_Id__c);
            }
        }
        set<id> userIds = new set<id>();
        for(GroupMember gm :[SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :queueIds]){
            userIds.add(gm.UserOrGroupId);
        }
        list<string> emailsList = new list<string>();
        for(User u :[Select email from User where Id IN :userIds]){
            emailsList.add(u.Email);
        }
        if(emailsList.size() > 0){
            Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
        mymail.setToAddresses(emailsList);
        mymail.setSubject('Business Process Completed');
        mymail.setHtmlBody('Hi <br/><br/>Business Process closed.<br/><br/>Thanks');        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });
        }
        
    }
    Public static void updateTAT(List<Business_Process__c> newList, Map<Id,Business_Process__c> oldMap){
        for(Business_Process__c bp :newList){
            if(bp.Status__c == 'Completed' && bp.Status__c != oldMap.get(bp.Id).status__c && bp.Start_Date__c != null){
                DateTime workStartTime = DateTime.newInstance((bp.Start_Date__c).date(), Time.newInstance(9, 0, 0, 0));
                DateTime workEndTime = DateTime.newInstance((bp.Start_Date__c).date(), Time.newInstance(18, 0, 0, 0)); 
                workStartTime = workStartTime.addHours(4);
                workEndTime = workEndTime.addHours(4);
                

                String timeGap = HolidayUtility.calculateBusinessHours(bp.Start_Date__c.addHours(4), bp.End_Date__c.addHours(4), workStartTime , workEndTime );            
                bp.TAT__c = decimal.valueOf(timeGap);
            }
        }
    }
    Public static void updateAgeing(List<Business_Process__c> newList, Map<Id,Business_Process__c> oldMap){
        for(Business_Process__c bp :newList){
            if((bp.Status__c == 'Completed' || bp.Status__c == 'Rejected') && bp.Status__c != oldMap.get(bp.Id).status__c && bp.Start_Date__c != null && bp.End_Date__c != null){
                DateTime workStartTime = DateTime.newInstance((bp.Start_Date__c).date(), Time.newInstance(9, 0, 0, 0));
                DateTime workEndTime = DateTime.newInstance((bp.Start_Date__c).date(), Time.newInstance(18, 0, 0, 0)); 
                workStartTime = workStartTime.addHours(4);
                workEndTime = workEndTime.addHours(4);
                

                String timeGap = HolidayUtility.calculateBusinessHours(bp.Start_Date__c.addHours(4), bp.End_Date__c.addHours(4), workStartTime , workEndTime );            
                bp.Ageing__c = decimal.valueOf(timeGap);
            }
        }
        
    }
}
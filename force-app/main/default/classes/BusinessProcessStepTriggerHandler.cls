public class BusinessProcessStepTriggerHandler {

    Public static void openNextStep(list<Business_Process_Step__c> newList, Map<id,Business_Process_Step__c> oldMap){
        Map<id,decimal> busIdToSequenceNo = new Map<id,decimal>();
        for(Business_Process_Step__c bps :newList){
            if(bps.Approval_Status__c == 'Approved' && bps.Approval_Status__c != oldmap.get(bps.Id).Approval_Status__c){
                busIdToSequenceNo.put(bps.Business_Process__c,bps.Sequence__c+1);
                bps.Status__c = 'Completed';      
            }

            
            if((bps.Status__c == 'Completed' || bps.Status__c == 'Rejected') && bps.Status__c != oldmap.get(bps.Id).Status__c){
                bps.Final_Completed_Time__c = system.now();
                updateAging(bps);
            }     
        }
        list<Business_Process_Step__c> bpsListToUpdate = new list<Business_Process_Step__c>();
        
        Set<Id> setIdBP = new Set<Id>();
        for(Business_Process_Step__c bps :[Select id,Sequence__c,Business_Process__c,Assigned_Time__c,Final_Assigned_Time__c from Business_Process_Step__c where Business_Process__c In :busIdToSequenceNo.keySet()]) {
            if(bps.Sequence__c == busIdToSequenceNo.get(bps.Business_Process__c)){
                bps.Status__c = 'Open';
                
                bps.Final_Assigned_Time__c = System.now();
                if(bps.Assigned_Time__c==null){
                    bps.Assigned_Time__c = System.now();
                }                
                bpsListToUpdate.add(bps);
                setIdBP.add(bps.Business_Process__c);
            }            
        }
        List<Business_Process__c> listUpdateBP = new List<Business_Process__c>();
        for(Id bpId : busIdToSequenceNo.keySet()){
            if(!setIdBP.contains(bpId)){
                Business_Process__c objBP = new Business_Process__c();
                objBP.Id = bpId;
                objBP.Status__c = 'Completed';
                objBP.End_Date__c = system.now();
                listUpdateBP.add(objBP);                
            }
        }
        if(listUpdateBP.size()>0){
            update listUpdateBP;
        }        
        if(bpsListToUpdate.size()>0){
            update bpsListToUpdate;
        }
    }
    
    public static void updateBusinessProcess(list<Business_Process_Step__c> newList, Map<id,Business_Process_Step__c> oldMap){
        List<Business_Process__c> listUpdateBP = new List<Business_Process__c>();
        
        for(Business_Process_Step__c bps : newList){
            if(bps.Approval_Status__c == 'Rejected' && bps.Approval_Status__c != oldmap.get(bps.Id).Approval_Status__c){
                Business_Process__c objBP = new Business_Process__c();
                objBP.Id = bps.Business_Process__c;
                objBP.Status__c = 'Rejected';
                objBP.End_Date__c = system.now();
                bps.Status__c = 'Rejected';
                bps.Final_Completed_Time__c = system.now();
                if(bps.Completed_Time__c==null){
                    bps.Completed_Time__c = System.now();
                }                
                listUpdateBP.add(objBP);
            }
        }
        
        if(listUpdateBP!=null && listUpdateBP.size()>0){
            update listUpdateBP;
        }
    
    }
    Public static void sendEmailNotificationUpdate(list<Business_Process_Step__c> newList, Map<id,Business_Process_Step__c> oldMap){
        set<Id> queIdSet = new Set<Id>();
        for(Business_Process_Step__c bps :newList){
            if(bps.status__c == 'Open' && bps.Status__c != oldMap.get(bps.Id).Status__c){
                queIdSet.add(bps.OwnerId);
            }
        }
        Set<Id> userIds = new Set<Id>();
        Map<id,List<id>> groupIdToUsersMap = new Map<id,List<id>>();
        for(GroupMember gm :[SELECT Id, GroupId, UserOrGroupId FROM GroupMember where GroupId IN :queIdSet]){
            userIds.add(gm.UserOrGroupId);
            if(groupIdToUsersMap.containsKey(gm.GroupId)){
                groupIdToUsersMap.get(gm.GroupId).add(gm.UserOrGroupId);
            }
            else{
                list<id> tempList = new list<Id>();
                tempList.add(gm.UserOrGroupId);
                groupIdToUsersMap.put(gm.GroupId,tempList);
            }
        }
        Map<Id,string> userIdToEmailMap = new Map<Id,string>();
        for(User u :[Select email from User where Id IN :userIds]){
            userIdToEmailMap.put(u.Id,u.Email);
        }
        Map<id,list<string>> groupIdToEmailsMap = new Map<id,list<string>>();
        for(id gId : groupIdToUsersMap.keySet()){
            for(Id uId :groupIdToUsersMap.get(gId)){
                If(groupIdToEmailsMap.containsKey(gid)){
                    groupIdToEmailsMap.get(gId).add(userIdToEmailMap.get(uId));
                }
                else{
                    list<string> tempList = new list<string>();
                    tempList.add(userIdToEmailMap.get(uId));
                    groupIdToEmailsMap.put(gId,tempList);
                }
            }
        }
        
        list<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        contact con = [SELECT Id, Name FROM Contact WHERE Name = 'For TAT Emails' limit 1];
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Business_Process_step_queue_email_notification'];
        for(Business_Process_Step__c bps :newList){
            if(bps.status__c == 'Open' && bps.Status__c != oldMap.get(bps.Id).Status__c && groupIdToEmailsMap.containsKey(bps.OwnerId)){
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                mymail.setToAddresses(groupIdToEmailsMap.get(bps.OwnerId));
                mymail.setTargetObjectId(con.Id);
                mymail.setUseSignature(false);
                mymail.setBccSender(false);
                mymail.setSaveAsActivity(false);
                mymail.setTreatTargetObjectAsRecipient(false);
                mymail.setTemplateID(emailTemplate.Id);
                mymail.setWhatId(bps.Id);
                
                //mymail.setSubject('Business Process Step is Assigned');
                //mymail.setHtmlBody('Hi <br/> <br/>Business Process Step is Open and assigned to your queue.Please review and accept.<br/><br/>Thanks');   
                emails.add(mymail);
            }
        }
         Messaging.sendEmail(emails);
    }
    Public static void sendEmailNotificationInsert(list<Business_Process_Step__c> newList){
        set<Id> queIdSet = new Set<Id>();
        for(Business_Process_Step__c bps :newList){
            if(bps.status__c == 'Open'){
                queIdSet.add(bps.OwnerId);
            }
        }
        Set<Id> userIds = new Set<Id>();
        Map<id,List<id>> groupIdToUsersMap = new Map<id,List<id>>();
        for(GroupMember gm :[SELECT Id, GroupId, UserOrGroupId FROM GroupMember where GroupId IN :queIdSet]){
            userIds.add(gm.UserOrGroupId);
            if(groupIdToUsersMap.containsKey(gm.GroupId)){
                groupIdToUsersMap.get(gm.GroupId).add(gm.UserOrGroupId);
            }
            else{
                list<id> tempList = new list<Id>();
                tempList.add(gm.UserOrGroupId);
                groupIdToUsersMap.put(gm.GroupId,tempList);
            }
        }
        Map<Id,string> userIdToEmailMap = new Map<Id,string>();
        for(User u :[Select email from User where Id IN :userIds]){
            userIdToEmailMap.put(u.Id,u.Email);
        }
        Map<id,list<string>> groupIdToEmailsMap = new Map<id,list<string>>();
        for(id gId : groupIdToUsersMap.keySet()){
            for(Id uId :groupIdToUsersMap.get(gId)){
                If(groupIdToEmailsMap.containsKey(gid)){
                    groupIdToEmailsMap.get(gId).add(userIdToEmailMap.get(uId));
                }
                else{
                    list<string> tempList = new list<string>();
                    tempList.add(userIdToEmailMap.get(uId));
                    groupIdToEmailsMap.put(gId,tempList);
                }
            }
        }
        
        list<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Business_Process_step_queue_email_notification'];
        contact con = [SELECT Id, Name FROM Contact WHERE Name = 'For TAT Emails' limit 1];
        for(Business_Process_Step__c bps :newList){
            if(bps.status__c == 'Open' && groupIdToEmailsMap.containsKey(bps.OwnerId)){
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                mymail.setToAddresses(groupIdToEmailsMap.get(bps.OwnerId));
                
                mymail.setTargetObjectId(con.Id);
                mymail.setUseSignature(false);
                mymail.setBccSender(false);
                mymail.setSaveAsActivity(false);
                mymail.setTreatTargetObjectAsRecipient(false);
                mymail.setTemplateID(emailTemplate.Id);
                mymail.setWhatId(bps.Id);
                
                //mymail.setSubject('Business Process Step is Assigned');
                //mymail.setHtmlBody('Hi <br/> <br/>Business Process Step is Open and assigned to your queue.Please review and accept.<br/><br/>Thanks');   
                emails.add(mymail);
            }
        }
         Messaging.sendEmail(emails);
    }
    Public static void statusChangeEmail(list<Business_Process_Step__c> newList, Map<id,Business_Process_Step__c> oldMap){
        list<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        contact con = [SELECT Id, Name FROM Contact WHERE Name = 'For TAT Emails' limit 1];
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Business_Process_step_status_change_email_notification'];
        for(Business_Process_Step__c bps :newList){
            if(bps.Status__c != oldMap.get(bps.Id).Status__c){
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                list<string> emailsList = new list<string>();
                emailsList.add(UserInfo.getUserEmail()); 
                
                mymail.setTargetObjectId(con.Id);
                mymail.setUseSignature(false);
                mymail.setBccSender(false);
                mymail.setSaveAsActivity(false);
                mymail.setTreatTargetObjectAsRecipient(false);
                mymail.setTemplateID(emailTemplate.Id);
                mymail.setWhatId(bps.Id);
                
                mymail.setToAddresses(emailsList);
                //mymail.setSubject('Business Process Step status changed');
                //mymail.setHtmlBody('Hi <br/> <br/>Business Process Step status is changed.<br/><br/>Thanks');   
                emails.add(mymail);
            }
        }
        Messaging.sendEmail(emails);
    }

    public static void updateAging(Business_Process_Step__c bps){
        DateTime workStartTime = DateTime.newInstance((bps.Final_Assigned_Time__c).date(), Time.newInstance(9, 0, 0, 0));
        DateTime workEndTime = DateTime.newInstance((bps.Final_Assigned_Time__c).date(), Time.newInstance(18, 0, 0, 0)); 
        workStartTime = workStartTime.addHours(4);
        workEndTime = workEndTime.addHours(4);
        
        System.debug('bps.Final_Assigned_Time__c '+bps.Final_Assigned_Time__c);
        System.debug('bps.Final_Completed_Time__c '+bps.Final_Completed_Time__c);
        String timeGap = HolidayUtility.calculateBusinessHours(bps.Final_Assigned_Time__c.addHours(4), bps.Final_Completed_Time__c.addHours(4), workStartTime , workEndTime );            
        bps.Aging__c = decimal.valueOf(timeGap);

        if(bps.Completed_time__c==null){
            bps.Completed_time__c = system.now();
        }        
    }

}
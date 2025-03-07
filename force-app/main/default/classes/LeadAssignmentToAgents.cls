public class LeadAssignmentToAgents implements Database.Batchable<sObject>,Database.stateful{ 
    public Integer successRec = 0; 
    public Integer failedRec = 0; 
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id,is_serviced__c, Presales_Agent__c, OwnerId,Round_Robin_Assigned_User_Id__c,Lead_Sub_Source__c,owner.FirstName,Owner.LastName from Lead where is_serviced__c = false order by lastmodifiedDate desc';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> LeadList){
        List<Lead> finalLeadList = new List<Lead>();
        for (Lead le: LeadList) {
            if (le.Lead_Sub_Source__c != null && (le.Lead_Sub_Source__c.contains('-en') || le.owner.FirstName =='CTI' || le.owner.LastName == 'Site Guest User')) {
                finalLeadList.add(le);
            } 
        }
        List<Assignment_groups__c> allUsersList = new  List<Assignment_Groups__c>();
        List<Lead> leadToUpdate = new List<Lead>();
        set<Id> groupToUpdate = new set<Id>();
        Map<String,List<String>> leadToAssignmentMap = new Map<String,List<String>>();
        Lead_Hoping_Settings__c myCS1 = Lead_Hoping_Settings__c.getValues('Lead Assignment Group Name');
        String groupName = myCS1.Value__c;
        allUsersList= [Select id,Name,CreatedDate, Active__c, User_Active__c, Is_Assigned__c,Group_Name__r.Name,User__c from Assignment_Groups__c where Group_Name__r.Name=:groupName
                             and User_Active__c = 'true' and Active__c = 'true' order by is_Assigned__c asc   ]; 

        
        for (Lead l : finalLeadList) {
            List<String> assignmentGroupsList = new List<String>();
            if (l.Round_Robin_Assigned_User_Id__c != null) {
                assignmentGroupsList = l.Round_Robin_Assigned_User_Id__c.split(',');
            }
            leadToAssignmentMap.put(l.Id,assignmentGroupsList);
        }
        List<Lead> leadListToUpdate = new List<Lead>();
        for (String key : leadToAssignmentMap.keySet()) {
            System.debug(leadToAssignmentMap.get(key).size());
            System.debug(allUsersList.size());
            if(leadToAssignmentMap.get(key).size() == allUsersList.size()) {
                Lead l = new Lead();
                l.Round_Robin_Assigned_User_Id__c = null;
                l.Id = key;
                leadListToUpdate.add(l);
                leadToAssignmentMap.put(key,new List<String>());
            }
        }
       update leadListToUpdate;
             
        if (!allUsersList.isEmpty() && !finalLeadList.isEmpty()) {
            Integer i=0;
            finalLeadList = [Select id,is_serviced__c, Presales_Agent__c, OwnerId,Round_Robin_Assigned_User_Id__c from Lead where id in:finalLeadList];
            for (Lead l :finalLeadList) {
                Boolean flag = false;
                if (allUsersList.size() == i ) {
                    i = 0;
                    if (groupToUpdate.size() == allUsersList.size()) {
                        groupToUpdate = new Set<Id>();
                    }
                }
                if (allUsersList.size() -1 >= i) {
                    if (leadToAssignmentMap.containsKey(l.Id) &&  !leadToAssignmentMap.get(l.Id).contains(allUsersList[i].User__c)) {
                        l.ownerId = allUsersList[i].User__c;
                        l.Presales_Agent__c = allUsersList[i].User__c;
                        if (l.Round_Robin_Assigned_User_Id__c != null) {
                            l.Round_Robin_Assigned_User_Id__c = l.Round_Robin_Assigned_User_Id__c +','+allUsersList[i].User__c;
                        } else {
                            l.Round_Robin_Assigned_User_Id__c = allUsersList[i].User__c;
                        }
                        groupToUpdate.add(allUsersList[i].Id);
                        leadToUpdate.add(l);
                        flag = true;
                    }
                    if (!flag) {
                        for (Integer j=0 ; j<allUsersList.size() ;j++) {
                            if (!leadToAssignmentMap.get(l.Id).contains(allUsersList[j].User__c) ) {
                                Integer randomNumber = Integer.valueof((Math.random() * (allUsersList.size() -1)));
                                String userId = null;
                                if (!leadToAssignmentMap.get(l.Id).contains(allUsersList[randomNumber].User__c)) {
                                    userId = allUsersList[randomNumber].User__c;
                                    groupToUpdate.add(allUsersList[randomNumber].Id);
                                } else {
                                  userId = allUsersList[j].User__c; 
                                  groupToUpdate.add(allUsersList[j].Id);
                                }
                                l.ownerId = userId;
                                l.Presales_Agent__c = userId; 
                                l.Round_Robin_Assigned_User_Id__c = l.Round_Robin_Assigned_User_Id__c +','+userId;
                                leadToUpdate.add(l);
                                break;
                            }
                        }
                    }
                } 
                i++;
            }
        }
        List<Assignment_Groups__c> groupMemberToUpdate = new List<Assignment_Groups__c>();
        for (Assignment_Groups__c assignGroupMember : allUsersList) {
            if (groupToUpdate.size() == allUsersList.size()) {
                assignGroupMember.Is_Assigned__c = false;
            } else {
                if (groupToUpdate.contains(assignGroupMember.Id)) {
                    assignGroupMember.Is_Assigned__c = true;
                } else {
                    assignGroupMember.Is_Assigned__c = false;
                }
            }
            groupMemberToUpdate.add(assignGroupMember);
        }
        update groupMemberToUpdate;
           
   
         List<Database.SaveResult> results = Database.update(leadToUpdate, false);
        for (Database.SaveResult result : results) {
            if (result.isSuccess()){
                successRec++;
            }else{
                failedRec++;
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
}
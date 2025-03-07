public class CaseRoundRobinTriggerHandler {

    public static Integer recursiveCounter = 0;
    public static Boolean skipRun = false;


    
    public static void updateCaseOwnerWithGroupMembers(List<Case> cases, Boolean calledFromBatch) {System.debug('updateCaseOwnerWithGroupMembers');
        List<Case_Roundrobin_Working_Hours__mdt> workingHoursList = [SELECT Queue_Name__c,Group_Name__c
                                                                   FROM Case_Roundrobin_Working_Hours__mdt LIMIT 1];
        String queueName = workingHoursList[0].Queue_Name__c;
        String groupName = workingHoursList[0].Group_Name__c;
        If(Test.isRunningTest()){
          //  queueName = 'Test';
            groupName = 'Test';
        }
        List<Assignment_Group_Name__c> activeGroupMembers = [select Id, 
                                                           (select Id,User__c,Rank__c,User__r.Name from Assignment_Groups__r where Active__c='True'
                                                            AND User_Active__c='True' AND Rank__c!=null Order By Rank__c ASC) 
                                                           from Assignment_Group_Name__c where Name LIKE : groupName LIMIT 1];
        System.debug('activeGroupMembers:'+activeGroupMembers);
        List<Assignment_Groups__c> assignmentGroups = [select Id,User__c,Rank__c,User__r.Name from Assignment_Groups__c where Active__c='True'
                                                            AND User_Active__c='True' AND Group_Name__r.id =:activeGroupMembers[0].id AND Rank__c!=null Order By Rank__c ASC ];
        System.debug('assignmentGroups:'+assignmentGroups);

        
        Integer numActiveMembers = assignmentGroups.size();
        Datetime currentDatetime = Datetime.now();
        String queueId = getQueueIdByName(queueName);
        List<Case> casesToUpdate = new List<Case>();
        for (Case currentCase : cases) {
            Datetime caseCreatedDatetime;System.debug('CreatedDate:'+currentCase.CreatedDate);
            if(!Test.isRunningTest()){
                  caseCreatedDatetime = System.now();
               // caseCreatedDatetime = currentCase.CreatedDate != null ? currentCase.CreatedDate : System.now();
            }
            Id ownerId = null;            
            // Check if the case was created during working hours
            if (!Test.isRunningTest() && isWorkingHour(caseCreatedDatetime) && !assignmentGroups.isEmpty()) {
                Integer currentIndex = getNextIndex();
                currentIndex = Math.mod(currentIndex, numActiveMembers);
                ownerId = assignmentGroups[currentIndex].User__c; // Assuming User lookup field on Group_Member__c
                System.debug('currentIndex:'+currentIndex);
                System.debug('User:'+assignmentGroups[currentIndex].User__c);
                updateNextIndex(currentIndex+1); // Update the stored index for the next case
            } else {System.debug('else');
                ownerId = queueId;
            }
            
            currentCase.OwnerId = ownerId;
            casesToUpdate.add(currentCase);
            
        }System.debug('cases:'+cases);
        if(calledFromBatch == true){
            update cases;
        }
    }
    
    public static Integer getNextIndex() {
        CaseRoundRobinIndex__c roundRobinIndex = CaseRoundRobinIndex__c.getOrgDefaults();
        return roundRobinIndex != null ? Integer.valueOf(roundRobinIndex.Name) : 0;
    }
    
    public static void updateNextIndex(Integer newIndex) {System.debug('newIndex:'+newIndex);
        CaseRoundRobinIndex__c roundRobinIndex = CaseRoundRobinIndex__c.getOrgDefaults();
        if (roundRobinIndex == null) {
            roundRobinIndex = new CaseRoundRobinIndex__c();
        }
        roundRobinIndex.Name = String.valueOf(newIndex);
        upsert roundRobinIndex;
    }
    
    public static Boolean isWorkingHour(Datetime datetime1) {System.debug('isWorkingHour');System.debug('datetime1:'+datetime1);
        List<Case_Roundrobin_Working_Hours__mdt> workingHoursList = [SELECT Starting_Hour__c,Starting_Minute__c, End_Hour__c, End_Minute__c
                                                                   FROM Case_Roundrobin_Working_Hours__mdt LIMIT 1];
        
        if (!workingHoursList.isEmpty()) {System.debug('workingHoursList_NotEmpty');
            // Default to working hours if no custom metadata records are defined
            System.debug('caseTime:'+datetime1.time());
            Time startOfWorkingHour = Time.newInstance(Integer.valueOf(workingHoursList[0].Starting_Hour__c), Integer.valueOf(workingHoursList[0].Starting_Minute__c), 0, 0); 
            Time endOfWorkingHour = Time.newInstance(Integer.valueOf(workingHoursList[0].End_Hour__c), Integer.valueOf(workingHoursList[0].End_Minute__c), 0, 0); 
            System.debug('startOfWorkingHour:'+startOfWorkingHour);
			System.debug('endOfWorkingHour:'+endOfWorkingHour);
            Time caseTime = datetime1.time();
            return caseTime >= startOfWorkingHour && caseTime <= endOfWorkingHour;
        }
        
        Time caseTime = datetime1.time();
        
        for (Case_Roundrobin_Working_Hours__mdt workingHour : workingHoursList) {
            Time startOfWorkingHour = Time.newInstance(Integer.valueOf(workingHoursList[0].Starting_Hour__c), Integer.valueOf(workingHoursList[0].Starting_Minute__c), 0, 0); 
            Time endOfWorkingHour = Time.newInstance(Integer.valueOf(workingHoursList[0].End_Hour__c), Integer.valueOf(workingHoursList[0].End_Minute__c), 0, 0); 
            
            if (caseTime >= startOfWorkingHour && caseTime <= endOfWorkingHour) {
                return true;
            }
        }
        
        return false;
    }
    
    public static String getQueueIdByName(String queueName) {
        Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :queueName LIMIT 1];
        return queue != null ? queue.Id : null;
    }
}
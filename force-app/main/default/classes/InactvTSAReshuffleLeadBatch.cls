global class InactvTSAReshuffleLeadBatch implements Database.Batchable<SObject> {
    private Id deactivatedUserId;
    
    global InactvTSAReshuffleLeadBatch(Id userId) {
        this.deactivatedUserId = userId;
        
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        // Query for leads owned by the deactivated user              
        String leadQuery = 'SELECT Id, OwnerId FROM Lead WHERE IsConverted = FALSE AND Presales_Agent__c = :deactivatedUserId AND (Last_Call_Attempt_Status__c != \'Junk Lead\' OR Status != \'Junk Lead\')';
        
        
        return Database.getQueryLocator(leadQuery);
    }

    global void execute(Database.BatchableContext BC, List<Lead> scope) {
       
        Map<Id, Datetime> userLastLeadAssignedDateTimeMap = new Map<Id, Datetime>();
        List<Lead> leadsToUpdate = new List<Lead>();
       	Id[] userIds = new Id[0];
       
        //Query managerId of deactivated user]
        User deactivatedUser = [SELECT ManagerId FROM User WHERE Id = :deactivatedUserId];
        Id managerId = deactivatedUser.ManagerId;
        
         // Query existing Presales rolePresales Agent for checking user should have this role assigned.
         //  As there is validation on Presales_Agent__c to have user with role PresalesAgent
        UserRole presalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Presales_Agent' LIMIT 1];

        
        // Query for active users whose manager is the same as the deactivated user's manager
        List<User> activeUsers=[SELECT Id FROM User 
                                WHERE IsActive = true 
                                AND UserRoleID =:presalesRole.Id
                                AND ManagerId = :managerId 
                                AND ManagerId != NULL ORDER BY Last_Lead_Assigned_Date__c ASC];
        // Gather user IDs
        for (User u : activeUsers) {
             userIds.add(u.Id);
        }
        system.debug('userIds in Execute:'+userIds);
       
       // Id[] userIds = new Id[0];
        Integer userIndex = 0;
       
        
       // Assign leads to active users based on the ordered user list
        for (Lead lead : scope) {
            lead.OwnerId = userIds[userIndex];
            lead.Presales_Agent__c = userIds[userIndex];
            leadsToUpdate.add(lead);
            userLastLeadAssignedDateTimeMap.put(userIds[userIndex], System.Now());
            userIndex = (userIndex == userIds.size() - 1) ? 0 : userIndex + 1;
        }

        // Update leads 
        update leadsToUpdate;
        
        // Update Last_Lead_Assigned_Date__c on users to whom leads were assigned
        List<User> usersToUpdate = new List<User>();
        for (Id userId : userLastLeadAssignedDateTimeMap.keySet()) {
            User u = new User(Id = userId, Last_Lead_Assigned_Date__c = userLastLeadAssignedDateTimeMap.get(userId));
            usersToUpdate.add(u);
        }
        
        update usersToUpdate;
                                                                     
    }

    global void finish(Database.BatchableContext BC) {
        {
             InactvTSAReshuffleOppBatch oppBatch = new InactvTSAReshuffleOppBatch(deactivatedUserId);
             Database.executeBatch(oppBatch);            
            
        }
                                           
    }
}
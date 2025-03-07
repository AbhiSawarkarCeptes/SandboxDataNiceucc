global class InactvTSAReshuffleOppBatch implements Database.Batchable<SObject> {
    private Id deactivatedUserId;
    
    global InactvTSAReshuffleOppBatch(Id userId) {
        this.deactivatedUserId = userId;
       
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        // Query for leads owned by the deactivated user              
        String oppQuery = 'SELECT Id, OwnerId, Account.ownerId,AccountID FROM Opportunity WHERE Presales_Agent__c = :deactivatedUserId';
        
        
        return Database.getQueryLocator(oppQuery);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
       

        Map<Id, Datetime> userLastOppAssignedDateTimeMap = new Map<Id, Datetime>();
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Account> acctsToUpdate = new List<Account>();
        Id[]  userIds = new Id[0];
        Integer userIndex = 0;
        
        /* Query existing Presales rolePresales Agent for checking user should have this role assigned.
         *  As there is validation on Presales_Agent__c to have user with role PresalesAgent
		*/
        UserRole presalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Presales_Agent' LIMIT 1];

        //Query managerId of deactivated User
        User deactivatedUser = [SELECT ManagerId FROM User WHERE Id = :deactivatedUserId];
        Id managerId = deactivatedUser.ManagerId;
        
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
        
        // Map to hold Account ID and corresponding Opportunities
   		 Map<Id, List<Opportunity>> accountOpportunitiesMap = new Map<Id, List<Opportunity>>();
    
   		 // Iterate through the scope and group opportunities by Account ID
   		 for (Opportunity opp : scope) {
      	  if (!accountOpportunitiesMap.containsKey(opp.AccountId)) {
            accountOpportunitiesMap.put(opp.AccountId, new List<Opportunity>{ opp });
       		 } else {
            accountOpportunitiesMap.get(opp.AccountId).add(opp);
        	}
    }
       
       // Assign leads to active users based on the ordered user list
        // Iterate through the grouped opportunities
    for (Id accountId : accountOpportunitiesMap.keySet()) {
        // Get the list of opportunities for the current account
        List<Opportunity> oppsForAccount = accountOpportunitiesMap.get(accountId);

        // Iterate through the opportunities for the current account
        for (Opportunity opp : oppsForAccount) {
            // Update the Presales_Agent__c field on the Opportunity
            opp.Presales_Agent__c = userIds[userIndex];
            oppsToUpdate.add(opp);
        }
        // Get the Account record for the current account
        Account acc = new Account(Id = accountId, OwnerId = userIds[userIndex]);
        acctsToUpdate.add(acc);

        // Update the map to track the last assigned datetime for the user
        userLastOppAssignedDateTimeMap.put(userIds[userIndex], System.Now());
        
        // Increment the userIndex for the next opportunity
        userIndex = (userIndex == userIds.size() - 1) ? 0 : userIndex + 1;
    }

    // Update Opportunities
    update oppsToUpdate;
    
    // Update Accounts
    update acctsToUpdate;         
        // Update Last_Lead_Assigned_Date__c on users to whom leads were assigned
        List<User> usersToUpdate = new List<User>();
        for (Id userId : userLastOppAssignedDateTimeMap.keySet()) {
            User u = new User(Id = userId, Last_Lead_Assigned_Date__c = userLastOppAssignedDateTimeMap.get(userId));
            usersToUpdate.add(u);
        }
        
            update usersToUpdate;
        
    }

    global void finish(Database.BatchableContext BC) {
       
                                           
    }
}
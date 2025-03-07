public without sharing class UserTriggerHandler {
    public static void onAfterUpdate(List<User> newList, Map<Id, User> oldMap) {
        List<Id> deactivatedUserIds = new List<Id>();
		system.debug('inside Handler:'+newList);
        for(User newUser : newList) {
            User oldUser = oldMap.get(newUser.Id);
            if(newUser.IsActive == false && oldUser.IsActive == true)
            {
                deactivatedUserIds.add(newUser.Id);
            }
        }

        if(!deactivatedUserIds.isEmpty()) {
            for(Id userId : deactivatedUserIds) {
                InactvTSAReshuffleLeadBatch leadBatch = new InactvTSAReshuffleLeadBatch(userId);
                	Database.executeBatch(leadBatch);
                /*
                InactvTSAReshuffleOppBatch oppBatch = new InactvTSAReshuffleOppBatch(userId);
             Database.executeBatch(oppBatch);            
            */
            }
        }
    }
}
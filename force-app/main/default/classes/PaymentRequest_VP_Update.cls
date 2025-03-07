global class PaymentRequest_VP_Update implements Database.Batchable<sObject>, Database.Stateful {
    
    global list<Payment_Request__c> prDataList =  new List<Payment_Request__c>();
    global List<Id> recordIds;
    
    // Constructor to accept specific record IDs
    global PaymentRequest_VP_Update(List<Id> ids) {
        recordIds = ids;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        if(recordIds != null && recordIds.size() > 0)
        {
        	query = 'SELECT Id,VP_For_PR__c,CreatedById FROM Payment_Request__c WHERE Id IN :recordIds';
        }else
        {
         	query = 'SELECT Id,VP_For_PR__c,CreatedById FROM Payment_Request__c WHERE VP_For_PR__c = null';   
        }
         
         return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Payment_Request__c> prList) {
         system.debug('i am pr:'+prList);
        system.debug('i am pr:'+recordIds);
         List<Payment_Request__c> updatePRList = new List<Payment_Request__c>();
         Set<Id> createdByIds = new Set<Id>();
         for (Payment_Request__c pr : prList) {
            if (pr.CreatedById != null) {
                createdByIds.add(pr.CreatedById);
            }
        }
        
        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Name, UserRole.Name, ManagerId, Manager.Name, Manager.UserRoleId, 
                                                    Manager.Manager.Name FROM User WHERE Id IN: createdByIds]);
        for(Payment_Request__c pr : prList)
        {
            User createdByUser = usersMap.get(pr.CreatedById);
            if (createdByUser != null) 
            {
                String createdByUserRole = createdByUser.UserRole != null ? createdByUser.UserRole.Name : 'N/A';
                String managerName = createdByUser.Manager != null ? createdByUser.Manager.Name : 'N/A';
                String managerManagerName = (createdByUser.Manager != null && createdByUser.Manager.Manager != null) ? createdByUser.Manager.Manager.Name : 'N/A';
                
                if(createdByUserRole.contains('Sales Manager'))
                {
                    pr.VP_For_PR__c = managerManagerName;
                }else if(createdByUserRole.contains('Sales Head'))
                {
                     pr.VP_For_PR__c = managerName;
                }else if(createdByUserRole.contains('CRM'))
                {
                    pr.VP_For_PR__c = 'CRM';
                }else if(createdByUserRole.contains('Collection'))
                {
                    pr.VP_For_PR__c = 'Collection';
                }else if(createdByUserRole.contains('CCC Team'))
                {
                    pr.VP_For_PR__c = 'Development';
                }
                
                updatePRList.add(pr);
            }
        }
        
          if(updatePRList != null && !updatePRList.isEmpty())
          {
                    Database.SaveResult[] resultprupdate = Database.update(updatePRList);
          }
        
     }
    
    global void finish(Database.BatchableContext BC) {}
}
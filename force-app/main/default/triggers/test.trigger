trigger test on Screenpop_Notification__e ( after Insert) {
  system.debug('event fired:' + trigger.new);
  
  // List to hold all cases to be created.
    List<Case> cases = new List<Case>();
    
    // Get user Id for case owner. Replace username value with a valid value.
    User adminUser = [SELECT Id FROM User WHERE Username='ankur.pd@stetig.in.ctwp'];
       
    // Iterate through each notification.
    for (Screenpop_Notification__e event: Trigger.New) {
        
        
            // Create Case to order new printer cartridge.
            Case cs = new Case();
            cs.Priority = 'Medium';
            cs.Subject = 'New screen pop received ' + event.Message__c + ' from ' + event.recordId__c;
            // Set case owner ID so it is not set to the Automated Process entity.
            cs.OwnerId = adminUser.Id;
            cases.add(cs);
        
    }
    
    // Insert all cases in the list.
    if (cases.size() > 0) {
        insert cases;
    }
}
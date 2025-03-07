trigger OpportunityTrg on Opportunity (before update, after update, after insert) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
    if(bypassSettingInstance.Bypass_All__c || bypassSettingInstance.Bypass_All_Triggers__c || bypassSettingInstance.Bypass_Opportunity_Trigger__c){ 
        System.debug('Inside ByPass Setting Triggered ->'+bypassSettingInstance); 
        return; 
    }
    
    Set<id> bIds = new set<id>();
    Map <Id, Id> optySMmap = new Map <Id, Id>();
    Map <Id, Id> deleteSharedoptymap = new Map <Id, Id>();
    List<Opportunity> opportunitiesToUpdateLeadStatus = new List<Opportunity>(); // New list to hold Opportunities for Lead status update
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
        List<OpportunityShare> oppShareList = new List<OpportunityShare>();
        for(opportunity opp : trigger.new)
        {
            if(opp.Secondary_Sales_Manager__c <> null)
            {
                OpportunityShare oppShare = new OpportunityShare();    
                oppShare.OpportunityAccessLevel = 'Edit';
                oppShare.OpportunityId = opp.Id;
                oppShare.UserOrGroupId = opp.Secondary_Sales_Manager__c;
                oppShare.RowCause = 'Manual';
                oppShareList.add(oppShare);
            }
        }
        if(oppShareList != null && !Test.isRunningTest())
            insert oppShareList;
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        for(opportunity op : trigger.new){ 
            op.Hash_Value__c = LeadUtility.getSha256(op.CreatedById + ',' + op.Form_Data__c +',' +
                                                     op.Leadgen_Form_ID__c+','+
                                                     op.Facebook_Adset_ID__c+','+
                                                     op.Facebook_Adset_Name__c+','+
                                                     op.Facebook_Ad_ID__c+','+
                                                     op.Facebook_Ad_Name__c+','+
                                                     op.Campaign_Code__c+','+
                                                     op.Account_Email__c+','+
                                                     op.Facebook_Form_Name__c+','+
                                                     op.Name+','+
                                                     op.Facebook_Page_Name__c+','+
                                                     op.Account_Mobile_Number__c+','+
                                                     op.Platform__c+','+
                                                     op.Account_Mobile_Number__c+','+
                                                     op.Country_Code__c);
            
           
        }
       
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        for(opportunity op : trigger.new){   
            if(trigger.newMap.get(op.Id).Secondary_Sales_Manager__c != null && trigger.newMap.get(op.Id).Secondary_Sales_Manager__c != trigger.oldMap.get(op.Id).Secondary_Sales_Manager__c && op.Secondary_Sales_Manager__c != op.ownerId){
                optySMmap.put(op.Id, op.Secondary_Sales_Manager__c);
            }
            if(trigger.oldMap.get(op.Id).Secondary_Sales_Manager__c != null && trigger.newMap.get(op.Id).Secondary_Sales_Manager__c != trigger.oldMap.get(op.Id).Secondary_Sales_Manager__c){
                deleteSharedoptymap.put(op.Id, trigger.oldMap.get(op.Id).Secondary_Sales_Manager__c);
            }
			 // Check if Last_call_attempt_status__c has changed and add to list for Lead status update
            if(op.Last_call_attempt_status__c != Trigger.oldMap.get(op.Id).Last_call_attempt_status__c){
                System.debug('STATUS'+op.Last_call_attempt_status__c );
                opportunitiesToUpdateLeadStatus.add(op);
            }
        }
		 // Add the logic for updating Lead Last Call Attempt Status using Apex healper class
        if(!opportunitiesToUpdateLeadStatus.isEmpty()){ 
            System.debug('Inside'+opportunitiesToUpdateLeadStatus);
            OpportunityTriggerHandler.updateLeadAttemptStatus(opportunitiesToUpdateLeadStatus);
        }
        
        ///// Added by Neha on 6/6/19 to delete shared opty with old Secondary SM
        if(!deleteSharedoptymap.isEmpty()){      // && deleteSharedoptymap != null
            List<OpportunityShare> oppDeleteShareList = new List<OpportunityShare>();
            
            for(Id o: deleteSharedoptymap.KeySet()){
                List<OpportunityShare> oppDeleteShare = new List<OpportunityShare>();
                oppDeleteShare = [Select ID, RowCause From OpportunityShare Where OpportunityId = :o AND RowCause = 'Manual' Limit 1];
                if(oppDeleteShare.size() > 0){
                    oppDeleteShareList.add(oppDeleteShare[0]);
                }
            }
            if(oppDeleteShareList != null)
                delete oppDeleteShareList;    
        }
        
        ////// Added by Neha on 6/6/19 to share opty with Secondary Sales Manager 
        if(!optySMmap.isEmpty()){ // && optySMmap != null
            List<OpportunityShare> oppShareList = new List<OpportunityShare>();
            
            for(Id o: optySMmap.keySet()){
                OpportunityShare oppShare = new OpportunityShare();    
                oppShare.OpportunityAccessLevel = 'Edit';
                oppShare.OpportunityId = o;
                oppShare.UserOrGroupId = optySMmap.get(o);
                oppShare.RowCause = 'Manual';
                oppShareList.add(oppShare);
            }
            if(oppShareList != null)
                insert oppShareList;
        }  
        
        
    }
}
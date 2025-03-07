/* Bypass Framework Enabled */
trigger EVR_Trigger on External_Verification_Register__c (before update){//TestClass : Test_EVR_Trigger
    
	Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    Boolean hasFinanceAccess = false;
    Boolean hasVendorAccess = false;
    Boolean hasAdminAccess = UserInfo.getProfileId() == [SELECT id FROM Profile WHERE Name = 'System Administrator'].Id;
    for(PermissionSetAssignment psa : [SELECT Id,AssigneeId,PermissionSetId,Assignee.Name,PermissionSet.Name,ExpirationDate,IsActive FROM PermissionSetAssignment WHERE PermissionSet.Name = 'External_SOA_Verification_Finance' OR PermissionSet.Name = 'External_SOA_Verification_Vendor']){
        if(psa.PermissionSet.Name == 'External_SOA_Verification_Finance'){
           hasFinanceAccess = psa.AssigneeId == UserInfo.getUserId() || hasFinanceAccess;
        }
        if(psa.PermissionSet.Name == 'External_SOA_Verification_Vendor'){
            hasVendorAccess = psa.AssigneeId == UserInfo.getUserId() || hasVendorAccess;
        }
    }
    
    if(Test.isRunningTest()){
        hasFinanceAccess = Test_EVR_Trigger.hasFinanceAccess;
        hasVendorAccess = Test_EVR_Trigger.hasVendorAccess;
        hasAdminAccess = Test_EVR_Trigger.hasAdminAccess;
    }
    
    for(External_Verification_Register__c newEVR : Trigger.new){
        External_Verification_Register__c oldEVR = Trigger.oldMap.get(newEVR.Id);
        
        if(String.isNotBlank(oldEVR.Booking__c) && newEVR.Booking__c != oldEVR.Booking__c){//trying to change Booking
            newEVR.addError('Booking cannot be edited.');
        }
        
        //Validations
        if(!hasAdminAccess){
            if(!hasFinanceAccess && hasVendorAccess){//Vendor Access without Finance Access
                if(oldEVR.SOA_Verified__c && !newEVR.SOA_Verified__c){//trying to reset "SOA Verified?"
                    newEVR.addError('You are not authorized to uncheck "SOA Verified?" checkbox once it is checked. Please reach out to Akshay Tilak or Keerthana Ramachandran!');
                }
                if(oldEVR.Rectification_Completed__c && !newEVR.Rectification_Completed__c){//trying to reset "Rectification Completed"
                    newEVR.addError('You are not authorized to uncheck "Rectification Completed" checkbox once it is checked. Please reach out to Akshay Tilak or Keerthana Ramachandran!');
                }
            }
            
            if(hasFinanceAccess && !hasVendorAccess){//Finance Access without Vendor Access
                if(!oldEVR.SOA_Verified__c && newEVR.SOA_Verified__c){//trying to set "SOA Verified?"
                    newEVR.addError('Only external vendors can check "SOA Verified?"!');
                }       
                if(!oldEVR.Rectification_Completed__c && newEVR.Rectification_Completed__c){//trying to reset "Rectification Completed"
                    newEVR.addError('Only external vendors can check "Rectification Completed"!');
                }
            }
            
            if(newEVR.SOA_Verified__c && String.isBlank(newEVR.Verifier_s_Comment_Options__c)){//no comment options is selected
                newEVR.addError('"Verifier\'s Comment Options" field is mandatory while checking "SOA Verified?"');
            }
            
            if(newEVR.AR_Verified__c && !newEVR.SOA_Verified__c){//trying to set "AR Verified" before "SOA Verified?"
                newEVR.addError('"AR Verified" cannot be checked if "SOA Verified?" is unchecked!');
            }
        }
        
        //Instance Capture
        if(newEVR.SOA_Verified__c && !oldEVR.SOA_Verified__c){
            newEVR.Verifying_User__c = UserInfo.getUserId();
            newEVR.Verification_Date__c = System.now().date();
            newEVR.Verification_Time__c = System.now().time();
        }
        
        if(newEVR.Rectification_Completed__c && !oldEVR.Rectification_Completed__c){//trying to reset "Rectification Completed"
        	newEVR.Rectification_Completed_Date__c = System.now().date();
        }
        
        if(newEVR.AR_Verified__c && !oldEVR.AR_Verified__c){
            newEVR.AR_Verifying_User__c = UserInfo.getUserId();
            newEVR.AR_Verification_Date__c = System.now().date();
            newEVR.AR_Verification_Time__c = System.now().time();
        }
        
    }
}
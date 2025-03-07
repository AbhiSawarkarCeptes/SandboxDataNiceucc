/* Bypass Framework Enabled */
trigger AdvancePaymentRebateTrigger on Advance_Payment_Rebate__c (before update, after update) {

    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    if(trigger.isBefore){
        for(Advance_Payment_Rebate__c pr : trigger.new){
            if(trigger.isInsert || (trigger.isUpdate && trigger.oldmap.get(pr.Id).Approval_Status__c	!= pr.Approval_Status__c)){
                if(pr.OwnerId == UserInfo.getUserId() && trigger.oldmap.get(pr.Id).Approval_Status__c == 'Submitted'){
                    pr.addError('Only Assigned approvers are allowed to Approve and Reject this record');
                }
                    pr.Status_Lapse__c = (pr.Status_Lapse__c != null)?pr.Status_Lapse__c + ' \n' + pr.Approval_Status__c + ' - ' + system.now() : pr.Approval_Status__c + ' - ' + system.now(); 
                    if(pr.Status_Lapse__c.length() > 255){
                        pr.Status_Lapse__c = pr.Status_Lapse__c.substring(0,255);
                    }
                
            }
            if(trigger.isUpdate && trigger.oldmap.get(pr.Id).Approval_Status__c	!= pr.Approval_Status__c
            && pr.Approval_Status__c == 'Approved'){
               
                    pr.Approved_Time__c = system.now();
                
            }
            if(trigger.isUpdate && trigger.oldmap.get(pr.Id).Approval_Status__c	!= pr.Approval_Status__c
            && pr.Approval_Status__c == 'Approved by Collection Manager'
            && (pr.Calculation_Sheet_Uploaded__c == False) ){
               
                   pr.addError('Please select at least one Calculation Sheet Document before approving.');
                
            }
            if(trigger.isUpdate && trigger.oldmap.get(pr.Id).Approval_Status__c	!= pr.Approval_Status__c
            && pr.Approval_Status__c == 'Approved by Collection Manager'
            && ( pr.Eligible_Rebate__c == null) ){
               
                   pr.addError('Please update eligible rebate before approving.');
                
            }
        }
    }
}
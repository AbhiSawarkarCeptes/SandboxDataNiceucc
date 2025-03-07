/* Bypass Framework Enabled */
trigger IssueManagementTrigger on Issue__c (before insert,before update)
{
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    {
        IssuePriorityClass.checkPriorityOfIssues();   
    }
    {
        IssueManagementVR.requiredField();
    }    
    if(Trigger.isUpdate)
    {
        IssueManagementService ism = new IssueManagementService();
        ism.sendIssueUpdateEmail(trigger.new, trigger.old);
    }
}
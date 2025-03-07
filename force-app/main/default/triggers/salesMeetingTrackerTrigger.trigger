/* Bypass Framework Enabled */
trigger salesMeetingTrackerTrigger on Sales_Meeting_Tracker__c (before insert,before update, after insert, after update) {
Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    //String htmlText;
    //Map<string,string> emailMapwithRole= new Map<string,string>();
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert) )
    {
        SalesMeetTrckTrgHelper.findUserAndManager(Trigger.new);
    }
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert) )
    {
        SalesMeetTrckTrgHelper.sendEmail(Trigger.new);
    }
    

}
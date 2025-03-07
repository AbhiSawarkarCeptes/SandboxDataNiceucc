/* Bypass Framework Enabled */
trigger TrgFinanceReport on Finance_Report_Records__c (after insert, after update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        
        List<String> bookingNameList = new List<String>(); 
        
        for(Finance_Report_Records__c frr : trigger.new){
            if(frr.Process_CR__c == true){
                bookingNameList.add(frr.booking_No__c);
            }
        }
        CollectionReportController.dateCalculation(bookingNameList);   
        
    }
}
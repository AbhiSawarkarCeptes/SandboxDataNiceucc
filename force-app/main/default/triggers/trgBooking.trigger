/* Bypass Framework Enabled */
trigger trgBooking on Booking__c (after insert, after update, before update, before insert) { 

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    //Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
    //If(bypassSettingInstance.Bypass_All__c || bypassSettingInstance.Bypass_All_Triggers__c || bypassSettingInstance.Bypass_Booking_Trigger__c){ return; }
    List<Quotation__c> quotationList = new List<Quotation__c>();
    List<Booking__c> bookingList = new List<Booking__c>();
    List<Unit__c> unitList = new List<Unit__c>();
    set<id> bookset = new set<id>();
    
    Set<Id> contentDocumentIds = new Set<Id>(); // Added by neha on 6/11/19
    Map<Id, Integer> bookingcontentDocumentMap = new Map<Id, Integer>(); // Added by neha on 6/11/19
    map<id, id> bookmap = new map<id,id>();
    map<id, id> unitmap = new map<id,id>();
    set<id> projSetIds = new set<id>();
    set<Id> towerSetIds = new Set<Id>(); //// Added by Neha on 7/3/19
    string errorMsg = '';
    
    /*Map<id, Booking__c> bMap = new Map<id, Booking__c>();
    
    if(Trigger.isInsert) {
        If(Trigger.isAfter) {
            
        }
    }
    
    //// Added by Neha on 6/11/19 to check if there is multiple booking forms on booking before sending welcome email  
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            
        }
    }
    /////// After Update    
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            
        }
    }*/
    
    
    /// VAMSI --- Added on 4-24-2021
    if(trigger.isAfter && trigger.isUpdate && !Test.isRunningTest()){
        BookingApprovalTriggerHandler.submitForApproval(trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        if (trgBookinghandler.beforeUpdateTriggerFirstRun) {
            trgBookinghandler.beforeupdate();
            trgBookinghandler.beforeUpdateTriggerFirstRun = false;
            try {
                trgBookinghandler.beforeUpdateValidation(trigger.new,trigger.oldMap);
            }
            catch (Exception e) {
            Error_Log__c trackRec = new Error_Log__c(Class__c = 'trgBooking--beforeUpdateValidation',Message__c = e.getmessage());
            database.insert(trackRec, false);
        }
        }
        BookingApprovalTriggerHandler.UpdateFieldsBeforeApproval(trigger.new,trigger.oldMap);
       
    }
    if(Trigger.isBefore && Trigger.isInsert){
        if (trgBookinghandler.beforeInsertTriggerFirstRun) {
            trgBookinghandler.beforeinsert();
            trgBookinghandler.beforeInsertTriggerFirstRun = false;
        }
        
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        if (trgBookinghandler.afterUpdateTriggerFirstRun) {
            trgBookinghandler.AfterUpdate();
            trgBookinghandler.afterUpdateTriggerFirstRun = false;
        }
        
    }
    if(Trigger.isAfter && Trigger.isInsert){
        if (trgBookinghandler.afterInsertTriggerFirstRun) {
            trgBookinghandler.Afterinsert();
            trgBookinghandler.afterInsertTriggerFirstRun = false;
        }
        
    }
}
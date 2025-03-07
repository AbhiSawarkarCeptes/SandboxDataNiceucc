trigger Apptrig on Applicant_Details__c (after insert, after update, before insert, before update) {
     //Just wanted to bypass trigger for legacy update.
    if(PopulateUniqueIdOnAcc.oneTimePopulateUniqueId) {
        return;
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        list<Applicant_Details__c> lstApp = new list<Applicant_Details__c>(trigger.new);
        CopyApptoOpty.updateOPTY(lstApp);
        CopyAppttoBooking.updateBooking(lstApp);
        
        // ** BOF For Mobile APP Create User Applicant**
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        if(mobile_appmdt.Applicant_Details_Trigger__c){
            Boolean isInsert = true;
            Map<Id,Applicant_Details__c> oldMap = new Map<Id, Applicant_Details__c>();
            if(Trigger.isUpdate){
                oldMap = Trigger.oldMap;
                isInsert = false;
            }
            // bypassing of calling below mobile queueable if process starts from Merge process.
            if(!AccountMergeController.accountMergeProcessInProgress) {
                System.enqueueJob(new MobileAppUsercreationQueuable(Trigger.New, oldMap, isInsert));
            }
        }
    }
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        Map<Id, Applicant_Details__c> oldMap = Trigger.isUpdate ? Trigger.oldMap : null;
        ApplicantTriggerHandler.onBeforeInsertUpdate(Trigger.new, Trigger.oldMap);
            
        /******************************************************************************************************************
        Method  : processAppDetailsFieldsBeforeSave
        Purpose : NICE - Apex class handler method for before insert, encrypts mobile numbers & emails if they are provided.
        Author  : Artee Varma
        Date    : 22-01-2025
        ******************************************************************************************************************/
        
        ApplicantTriggerHandler.processAppDetailsFieldsBeforeSave(Trigger.new);// Commented by Ayaz as it is passing null map
        
        /******************************************************************************************************************
        Method  : processAppDetailsFieldsBeforeUpdate
        Purpose : NICE - Apex class handler method for before update, encrypts mobile numbers & emails if they are provided.
        Author  : Artee Varma
        Date    : 22-01-2025
        ******************************************************************************************************************/
        
        ApplicantTriggerHandler.processAppDetailsFieldsBeforeUpdate(Trigger.newMap, Trigger.oldMap);// Commented by Ayaz as it is passing null map
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert)
        {
            ApplicantTriggerHandler.onAfterInsertUniqueCustomer(trigger.newmap);
            //ApplicantTriggerHandler.onAfterInsertLeadConversion(trigger.newmap);
        }
    }

    if(Trigger.isInsert && Trigger.isAfter){//added for SOB-1944
        X_XSD_Util.processInit(Trigger.oldMap,Trigger.newMap);
    }
}
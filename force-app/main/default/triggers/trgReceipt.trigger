/* Bypass Framework Enabled */
trigger trgReceipt on Receipt__c (after insert,after update,before insert,before update) {

    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
    if(bypassSettingInstance.Bypass_All__c || bypassSettingInstance.Bypass_All_Triggers__c || bypassSettingInstance.Bypass_Receipt_Trigger__c){ return; }
    
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];

    if (trigger.isAfter && trigger.isInsert) {
        system.debug('tlimit1 '+limits.getQueries());
        List<Id> receiptsIdList = new List<Id>();
        
        for (Receipt__c receipt:Trigger.new) {
            {
                if(receipt.Requester__c	 != null){
                    receiptsIdList.add(receipt.Id);
                } 
            } 
        }
        if(receiptsIdList!=null && !receiptsIdList.isEmpty()){                 
            sendreceiptcontroller.sendAttachedReceiptPB(receiptsIdList);
        } 
        system.debug('tlimit2 '+limits.getQueries());
    }
    if (trigger.isAfter && (trigger.isUpdate || trigger.isInsert)) {
        try{
        	trgReceiptHandler.sendEmailNotificationToAuditOnReceiptSubmission(trigger.new,trigger.oldMap,Trigger.operationType);// added by Roshan
        }catch(Exception ex){
            System.debug('trgReceipt.trigger exception - '+ex.getMessage()+'\n\n'+ex.getStackTraceString()+'\n\n'+ex);
        }
        
        system.debug('i am here');
        system.debug('tlimit3 '+limits.getQueries());
        List<Receipt__c> towardsUnitPriceReceipt = new List<Receipt__c>();
        List<Receipt__c> otherChargeTypesList = new List<Receipt__c>();
        List<Receipt__c> preRegistrationList = new List<Receipt__c>();
        List<string> cancelledReceiptList = new List<string>();
        if(trigger.isUpdate){ 
             resaleprocesscontroller.onAfterUpdatereceipt(trigger.New, trigger.oldmap); // Added by Hitesh GV
            set<string> bookingIds = new set<string>();
            for (Receipt__c r : trigger.new) {
                if((trigger.oldMap.get(r.Id).Receipt_Status__c  != r.Receipt_Status__c && r.Receipt_Status__c == 'Cleared')){
                    bookingIds.add(r.Booking__c);
                    if(r.Amount_Rs__c != null && r.Booking__c != null){
                        towardsUnitPriceReceipt.add(r);
                        if(r.Other_Charges_Type__c != null){
                            otherChargeTypesList.add(r);
                        }
                        if(r.Registration_Collection_Control_Report__c != null && r.Registration_Collection_Control_Report__c > 0){
                        	preRegistrationList.add(r);
                    	}
                    }
                }
                
                if((trigger.oldMap.get(r.Id).Receipt_Status__c  != r.Receipt_Status__c && r.Receipt_Status__c == 'Cancelled')){
                    bookingIds.add(r.Booking__c);
                    if(r.Amount_Rs__c != null && r.Booking__c != null){
                        cancelledReceiptList.add(r.id);
                    }
                }                
            }
            system.debug('tlimit4 '+limits.getQueries());
            if(cancelledReceiptList.size() > 0 && tpmMetaData.Active__c == true){   
                 TrackPaymentMilestoneController.cancelTPM(cancelledReceiptList);
            }
            
            if(bookingIds.size() > 0){
                List<string> bookingIdList = new List<string>();
                bookingIdList.addAll(bookingIds);
                CollectionDashboardController.createTask(bookingIdList);
            }
        }
        system.debug('tlimit5 '+limits.getQueries());
        if(trigger.isInsert){
            resaleprocesscontroller.onAfterInsertreceipt(trigger.New); // Added by Hitesh GV
            for (Receipt__c r : trigger.new) {
                if(r.Amount_Rs__c != null && r.Booking__c != null && r.Receipt_Status__c == 'Cleared'){
                    towardsUnitPriceReceipt.add(r);
                    if(r.Other_Charges_Type__c != null){
                        otherChargeTypesList.add(r);
                    }
                    if(r.Registration_Collection_Control_Report__c != null && r.Registration_Collection_Control_Report__c > 0){
                        preRegistrationList.add(r);
                    }
                }    
            }
        }
        system.debug('tlimit6 '+limits.getQueries());
         if(towardsUnitPriceReceipt.size() > 0 && tpmMetaData.Active__c == true){
             TrackPaymentMilestoneController.generateTPM(towardsUnitPriceReceipt);
         }
        
         if(otherChargeTypesList.size() > 0 && tpmMetaData.Active__c == true){
             OtherChargesDemandController.updateotherchargesReceipt(otherChargeTypesList);
         }
        
          if(preRegistrationList.size() > 0 && tpmMetaData.Active__c == true){
             TrackPaymentMilestoneController.preRegistrationTPM(preRegistrationList);
         }
        
        system.debug('tlimit7 '+limits.getQueries());
        if (TriggerFinanceReportRecordHandler.afterTriggerReceiptFirstRun) {
            List<Id> receiptsIds = new List<id>();
            for (Receipt__c r:Trigger.new) {
                receiptsIds.add(r.Id);
            }
            //Query FRR where receipt looking IN receiptsIds
            List<Finance_Report_Records__c> frrrecordsList = new List<Finance_Report_Records__c>();
            List<Id> frrIdsList = new List<id>();
            frrrecordsList = [SELECT ID 
                              FROM Finance_Report_Records__c
                              WHERE Receipt__c 
                              IN :receiptsIds];
            if(frrrecordsList.size()>0){
                for(Finance_Report_Records__c frr : frrrecordsList){
                    frrIdsList.add(frr.Id);
                }         
                TriggerFinanceReportRecordHandler.updateFRR(frrIdsList);
            }
            if(receiptsIds.size()>0){
                TriggerFinanceReportRecordHandler.UpdateBooking(receiptsIds);
            }
            TriggerFinanceReportRecordHandler.afterTriggerReceiptFirstRun = false;           
        }
        system.debug('tlimit8 '+limits.getQueries());   
    } 

    if(Trigger.isAfter && Trigger.isUpdate){
        try{
        	trgReceiptHandler.sendEmailNotificationOnApproveAndRejectionByAuditor(trigger.new,trigger.oldMap);// added by Roshan
        }catch(Exception ex){
            System.debug('trgReceipt.trigger exception - '+ex.getMessage()+'\n\n'+ex.getStackTraceString()+'\n\n'+ex);
        }
    }
    
    
    if(trigger.isInsert && trigger.isBefore){
        for (Receipt__c receipt:Trigger.new) {
            if(receipt.Receipt_Status__c == 'Cleared'){
                receipt.Receipt_Clearance_Date__c = System.Now();

                if(receipt.Mode__c != NULL){
                    if(!receipt.Mode__c.equalsIgnoreCase('Website') && !receipt.Mode__c.equalsIgnoreCase('credit note')){
                        receipt.Audit_Approval_Status__c = 'Under Approval' ;
                    }else if(receipt.Mode__c.equalsIgnoreCase('Website') || receipt.Mode__c.equalsIgnoreCase('credit note')){
                        receipt.Audit_Approval_Status__c = 'Not Applicable';
                    }
                }
            }
            
        }
        //code added by Roshan ticket number 1909
	    //FinalApproverOnPRandReceipts.UpdateReceipts(trigger.newMap.keySet());

    }
    

    if(trigger.isUpdate && trigger.isBefore){
        
        try{
            trgReceiptHandler.setPrFinalApprover(trigger.new,trigger.oldMap);
            trgReceiptHandler.setAuditStatus(trigger.new,trigger.oldMap);// code added by Roshan SOB 1906
        	trgReceiptHandler.updateAgingField(trigger.new,trigger.oldMap); // code by Deepanshu for 
        }catch(Exception ex){
            System.debug('trgReceipt.trigger exception - '+ex.getMessage()+'\n\n'+ex.getStackTraceString()+'\n\n'+ex);
        }
        for (Receipt__c receipt:Trigger.new) {
            Receipt__c oldReceipt = Trigger.oldMap.containsKey(receipt.id) ? Trigger.oldMap.get(receipt.id) : NULL;
            if(oldReceipt == NULL) continue;

            if(receipt.Receipt_Status__c == 'Cleared' && receipt.Receipt_Status__c != oldReceipt.Receipt_Status__c){
                receipt.Receipt_Clearance_Date__c = System.Now();
            }
            
            if(receipt.Receipt_Status__c != 'Cleared' && (receipt.Audit_Approval_Status__c == 'Under Approval' || receipt.Audit_Approval_Status__c == 'Rejected')){
                receipt.Audit_Approval_Status__c = 'Not Applicable';
            }
           
        }
    }

    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){//added for SOB-1944
        X_XSD_Util.processInit(Trigger.oldMap,Trigger.newMap);
        
        List<Recalculate_Collections__e> rcEvents =  new List<Recalculate_Collections__e>();
        for(Receipt__c receipt : Trigger.new){
            rcEvents.add(new Recalculate_Collections__e(Receipt_Id__c = receipt.Id));
        }
        if(!rcEvents.isEmpty()) EventBus.publish(rcEvents);
    }
}
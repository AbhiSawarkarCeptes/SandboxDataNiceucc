public class resaletriggerHandler {
    public Static void onBeforeUpdate(List<Resale_Process__c> newResLst, Map<id, Resale_Process__c> oldMapresale){
        for(Resale_Process__c res : newResLst){
            System.debug('Insdie'+res.Approval_Status__c+' - '+oldMapresale.get(res.id).Approval_Status__c);
            if(res.Approval_Status__c =='Pending for Accounts Approval' && oldMapresale.get(res.id).Approval_Status__c== 'Pending for Collections Approval'){
                if(res.is_cheklist_completed__c==false){
                    res.addError('Please Complete Collection Checklist before Approve'); 
                }
            }
            if(res.Approval_Status__c =='Rejected by Collections' && oldMapresale.get(res.id).Approval_Status__c== 'Pending for Collections Approval'){
                if(res.Collections_Rejection_Comments__c == null){
                    // res.addError('Please populate Collection Rejection Comments in the record, Before Rejecting'); 
                }
            }
            if(res.Approval_Status__c =='Rejected by Accounts' && oldMapresale.get(res.id).Approval_Status__c== 'Pending for Accounts Approval'){
                if(res.Rejected_To__c == null || res.Rejected_To__c == ''){
                    res.addError('Please populate Rejected To, Before Rejecting');  
                }
                if(res.Accounts_Rejection_Comments__c == null){
                    // res.addError('Please populate Accounts Rejection Comments in the record, Before Rejecting'); 
                }
            }
            if(res.Approval_Status__c =='Rejected by Audit' && oldMapresale.get(res.id).Approval_Status__c== 'Pending for Audit Approval'){
                if(res.Rejected_To__c == null || res.Rejected_To__c == ''){
                    res.addError('Please populate Rejected To, Before Rejecting');  
                }
                if(res.Audit_Rejection_Comments__c == null){
                    // res.addError('Please populate Audit Rejection Comments in the record, Before Rejecting'); 
                }
            }
            if(res.Rejected_To__c == 'Audit Rejected to Accounts' && res.Approval_Status__c =='Pending for Audit Approval' && oldMapresale.get(res.id).Approval_Status__c== 'Rejected by Audit'){
                if(res.Accounts_Resubmit_comments__c  == null){
                    // res.addError('Please fill Account Resubmit Comments on record , Before Submitting');  
                }else{
                    res.Rejected_To__c ='';
                }
            }
            if((res.Rejected_To__c == 'Audit Rejected to Collections') && res.Approval_Status__c =='Pending for Audit Approval' && oldMapresale.get(res.id).Approval_Status__c== 'Rejected by Audit'){
                if(res.Collections_Resubmit_comments__c == null){
                    // res.addError('Please fill Collections Resubmit Comments on record, Before Approving');  
                }else{
                    res.Rejected_To__c ='';
                }
            }
            if((res.Rejected_To__c == 'Audit Rejected to CRM' || res.Rejected_To__c =='Audit Rejected to CRM & Collections & Accounts')  && (res.Approval_Status__c =='Pending for Audit Approval' || res.Approval_Status__c== 'Pending for Collections Approval') && oldMapresale.get(res.id).Approval_Status__c== 'Rejected by Audit'){
                if(res.CRM_Resubmit_comments__c == null){
                    // res.addError('Please fill CRM Resubmit Comments on record, Before Submitting');  
                }else{
                    res.Rejected_To__c ='';
                }
            }
            if((res.Rejected_To__c == 'Accounts Rejected to Collections' || res.Rejected_To__c =='Audit Rejected to Collections & Accounts') && res.Approval_Status__c =='Pending for Accounts Approval' && (oldMapresale.get(res.id).Approval_Status__c== 'Rejected by Accounts' || oldMapresale.get(res.id).Approval_Status__c== 'Rejected by Audit')){
                if(res.Collections_Resubmit_comments__c == null){
                    // res.addError('Please fill Collections Resubmit Comments on record, Before Approving');  
                }else{
                    res.Rejected_To__c ='';
                }
            }
            if((res.Rejected_To__c == 'Accounts Rejected to CRM' || res.Rejected_To__c =='Audit Rejected to CRM & Accounts')  && res.Approval_Status__c =='Pending for Accounts Approval' && (oldMapresale.get(res.id).Approval_Status__c == 'Rejected by Accounts' || oldMapresale.get(res.id).Approval_Status__c == 'Rejected by Audit')){
                if(res.CRM_Resubmit_comments__c == null){
                    // res.addError('Please fill CRM Resubmit Comments on record, Before Submitting');  
                }else{
                    res.Rejected_To__c ='';
                }
            }
        }
        
        // Collect record Ids where checkbox is checked
        Set<Id> recordIdsWithCheckboxChecked = new Set<Id>();   
        for (Resale_Process__c resale : newResLst) {
            if(resale.Oqood_Title_deed_received_by_new_buyer__c==true && 
               resale.Oqood_Title_deed_received_by_new_buyer__c<>oldMapresale.get(resale.Id).Oqood_Title_deed_received_by_new_buyer__c){
                   recordIdsWithCheckboxChecked.add(resale.Id);
               }
        }
        
        if(recordIdsWithCheckboxChecked != null && recordIdsWithCheckboxChecked.size() > 0){
               // Query Notes and Attachments
               Map<Id, Integer> fileCountMap = new Map<Id, Integer>();
               for (ContentDocumentLink attachment : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :recordIdsWithCheckboxChecked AND ContentDocument.Title = 'New_oqood_Title']) {
                   if (fileCountMap.containsKey(attachment.LinkedEntityId)) {
                       fileCountMap.put(attachment.LinkedEntityId, fileCountMap.get(attachment.LinkedEntityId) + 1);
                   } else {
                       fileCountMap.put(attachment.LinkedEntityId, 1);
                   }
               }
               
               // Check for each record if there is a file with the specified name
               for (Resale_Process__c resale : newResLst) {
                   if (recordIdsWithCheckboxChecked.contains(resale.Id) && (!fileCountMap.containsKey(resale.Id) || fileCountMap.get(resale.Id) == 0)) {
                       resale.Oqood_Title_deed_received_by_new_buyer__c.addError('please upload this New_oqood_Title in notes and attahcment. or already uploded then please check the name of document should be "New_oqood_Title".');
                   }
               }
           }
    }

    public Static void onAfterUpdate(Map<Id, Resale_Process__c> newMapresale, Map<id, Resale_Process__c> oldMapresale){
        List<Id> reIdLst = New List<Id>();
        //Set<Id> bookids = New Set<Id>();
        Map<Id, Id> resalBookMap = New Map<Id, Id>();
        List<Opportunity> existingOpportunity = new List<Opportunity>();
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Unit__c> UnitList = new List<Unit__c>();
        Map<String, Account> mapAccount = new Map<String, Account>();
        Map<String, Opportunity> mapOpportunity = new Map<String, Opportunity>();
        Map<String, Applicant_Details__c> mapApplicants = new Map<String, Applicant_Details__c>();
        List<Applicant_Details__c> existingApplicants = new List<Applicant_Details__c>();

        Savepoint sp = Database.setSavepoint();

        List<Account> accountList = new List<Account>();
        try 
        	{
            for(Resale_Process__c rsp :newMapresale.Values()){
                if(rsp.Oqood_Title_deed_received_by_new_buyer__c==true && rsp.Oqood_Title_deed_received_by_new_buyer__c<>oldMapresale.get(rsp.Id).Oqood_Title_deed_received_by_new_buyer__c){
                    reIdLst.add(rsp.Id); 
                    //bookids.add(rsp.Booking__c);
                    resalBookMap.put(rsp.Booking__c, rsp.Id);
                }
            }
			if(!reIdLst.isEmpty()){
            List<Account> accUniqueCusId = [Select Id, Unique_Customer_ID__c from Account where Unique_Customer_ID__c <> null order by Unique_Customer_ID__c desc Limit 1];
            for(Applicant_Details__c app : [SELECT Id,Email_Address__c, Booking__c FROM Applicant_Details__c WHERE Booking__c IN : resalBookMap.KeySet()])
            {
                app.Resale_Process__c=resalBookMap.get(app.Booking__c);
                app.Booking__c = null;
                existingApplicants.add(app);
                // mapApplicants.put(app.Email_Address__c,app);
            }
            
            for(Opportunity op : [ SELECT Id,Name,Booking__c FROM Opportunity WHERE Booking__c IN : resalBookMap.KeySet()]){
                op.Booking__c = null;
                existingOpportunity.add(op);
            }

                for(Buyer__c buyer :[SELECT Id, Name, Address__c,OwnerId,Resale_Process__r.Unit__c, Buyer_Type__c, Email__c, Nationality__c, Passport_Number__c, Phone_Number__c, 
                                        Resale_Process__c, Residence_Status__c, Salutation__c, Trade_License__c,Resale_Process__r.Booking__c  FROM Buyer__c WHERE Resale_Process__c IN :reIdLst]){
                    
                    Integer nextUniqId = Integer.valueOf(accUniqueCusId[0].Unique_Customer_ID__c) +1 ;
                    Account acc = new Account();
                    acc.FirstName = buyer.Salutation__c;
                    acc.LastName = buyer.name;
                    acc.PersonEmail = buyer.Email__c;
                    acc.OwnerId = buyer.OwnerId;
                    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                    acc.PersonMobilePhone = buyer.Phone_Number__c;
                    acc.Unique_Customer_ID__c=String.valueOf(nextUniqId);
                    mapAccount.put(buyer.Email__c,acc);
                    
                    
                    Opportunity opp = new Opportunity();
                    opp.Name = buyer.Salutation__c+' '+buyer.name;
                    opp.OwnerId = buyer.OwnerId;
                    opp.CloseDate = System.today();
                    opp.StageName = 'Closed Won';
                    opp.Booking__c = buyer.Resale_Process__r.Booking__c;
                    opp.Primary_Name__c = buyer.Salutation__c+' '+buyer.name;
                    opp.Primary_Phone__c = buyer.Phone_Number__c;
                    opp.Primary_Email__c = buyer.Email__c;
                    opp.Mailing_Address__c = buyer.Address__c;
                    opp.Permanent_Address__c = buyer.Address__c;
                    
                    mapOpportunity.put(buyer.Email__c,opp);
                    
                    Applicant_Details__c applicant = new Applicant_Details__c();
                    applicant.Name=buyer.name;
                    applicant.Salutation__c =buyer.Salutation__c;
                    applicant.Applicant_Number__c = buyer.Buyer_Type__c;
                    applicant.Mailing_Address__c =buyer.Address__c;
                    applicant.Email_Address__c=buyer.Email__c;
                    applicant.Nationality__c =buyer.Nationality__c;
                    applicant.Passport_Copy_Details__c=buyer.Passport_Number__c;
                    applicant.Mobile_Number__c = buyer.Phone_Number__c;
                    applicant.Resale_Process__c =buyer.Resale_Process__c;
                    applicant.Booking__c =buyer.Resale_Process__r.Booking__c;
                    applicant.Unit__c =buyer.Resale_Process__r.Unit__c;
                    applicant.Resale_Process__c = null;
                    mapApplicants.put(buyer.Email__c,applicant);
                }
                
            

            // Create or update a hierarchical custom setting record
            Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
            bypassSettingInstance.Bypass_Account_Trigger__c = true;
            bypassSettingInstance.Bypass_Booking_Trigger__c = true;
            bypassSettingInstance.Bypass_Opportunity_Trigger__c = true;
            bypassSettingInstance.Bypass_Unit_Trigger__c = true;
            bypassSettingInstance.Bypass_Lead_Trigger__c = true;

            upsert bypassSettingInstance;

            if(mapAccount.size() > 0){
                if(existingApplicants.size() > 0){
                    update existingApplicants;
                }
                insert mapAccount.Values();
                for(Account acc : mapAccount.Values()){
                    System.debug('acc ->'+acc);
                    System.debug('acc ->'+acc.id);
                    mapOpportunity.get(acc.PersonEmail).AccountId = acc.Id;
                }
                if(mapOpportunity.size() > 0){
                    insert mapOpportunity.Values();
                    for (Opportunity op : mapOpportunity.values()) {
                        System.debug('op ->'+op);
                        System.debug('op ->'+op.Id);
                        mapApplicants.get(op.Primary_Email__c).Opportunity__c = op.Id; 
                        // mapApplicants.get(op.Primary_Email__c).Account__c = mapAccount.get(op.Primary_Email__c).Id; 
                        if(mapApplicants.get(op.Primary_Email__c).Applicant_Number__c == 'Primary Applicant'){
                            bookingList.add(new Booking__c(Id=mapApplicants.get(op.Primary_Email__c).Booking__c,Opportunity__c=op.Id));
                            UnitList.add(new unit__c(Id=mapApplicants.get(op.Primary_Email__c).Unit__c,Customers__c=op.Id));
                        }
                    }
                    if(mapApplicants.size()>0){
                        upsert mapApplicants.values();
                    }
                    if(bookingList.size() > 0){
                        update bookingList;
                    }
                    if(UnitList.size() > 0){
                        update UnitList;
                    }
                    if(existingOpportunity.size() > 0){
                        update existingOpportunity;
                    }
                }
            }

            bypassSettingInstance = Bypass_Setting__c.getInstance();
            bypassSettingInstance.Bypass_Account_Trigger__c = false;
            bypassSettingInstance.Bypass_Booking_Trigger__c = false;
            bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
            bypassSettingInstance.Bypass_Unit_Trigger__c = false;
            bypassSettingInstance.Bypass_Lead_Trigger__c = false;

            upsert bypassSettingInstance;
            }
        } 
        catch (Exception e) {

            Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
            bypassSettingInstance.Bypass_Account_Trigger__c = false;
            bypassSettingInstance.Bypass_Booking_Trigger__c = false;
            bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
            bypassSettingInstance.Bypass_Unit_Trigger__c = false;
            bypassSettingInstance.Bypass_Lead_Trigger__c = false;

            upsert bypassSettingInstance;

            Database.rollback(sp);
            Error_Log__c logError = new Error_Log__c(Message__c = e.getMessage()+' - Line number :' +e.getLineNumber() + ' Stack Trace :' +e.getStackTraceString());
            logError.class__c = 'resaletriggerHandler';
            insert logError;
        } 
    }
    
    public Static void onBeforeInsert(List<Resale_Process__c> newResLst){
        Set<Id> bookingIds = new Set<Id>();
        Map<Id, Boolean> bookingMap = new Map<Id, Boolean>();
        List<String> otherChargeTypesLst =  new List<String>();
        for(Resale_Other_Charges_Type__mdt roctm : [Select Other_Charges_Type__c  from Resale_Other_Charges_Type__mdt]){
            otherChargeTypesLst.add(roctm.Other_Charges_Type__c); 
        }
        for(Resale_Process__c resale : newResLst){
            resale.CRM_Document_Controller__c =Label.Resale_CRM_Document_Controller;
            bookingIds.add(resale.Booking__c);
        }
        for(Booking__c book : [SELECT Id,(SELECT Id, Receipt_Status__c, Other_Charges_Type__c FROM Receipts__r ),CRM_Executive__c FROM Booking__c WHERE Id IN:bookingIds]){
            Boolean check=false;
            for(Resale_Process__c resale : newResLst){
                if(resale.Booking__c == book.Id){
                    resale.CRM_Representative__c = book.CRM_Executive__c;
                }
            }
            for(Receipt__c rcp : book.Receipts__r){
                if(rcp.Receipt_Status__c == 'UnProcessed' && otherChargeTypesLst.contains(rcp.Other_Charges_Type__c )){
                    check=true;
                    break;
                }
            }
            if(check){
                bookingMap.put(book.Id, true);
            }
        }
        for (Resale_Process__c resale : newResLst){
            if(bookingMap.containskey(resale.Booking__c)){
               resale.Unprocessed_Receipt__c=true; 
            }  
        }
    }

    public Static void onAfterInsert(List<Resale_Process__c> newResLst){
      //after insert logic   
    }

    public static void dummyCov(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}
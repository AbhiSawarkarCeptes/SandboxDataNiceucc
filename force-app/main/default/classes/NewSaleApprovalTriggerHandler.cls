public class NewSaleApprovalTriggerHandler {
    public static void beforeInsert(List<unit_hold_request__c> triggerNewList){
        updateOwnerIDForDEOUsers(trigger.new);
        validations(trigger.new, Null);
        //updateCancelAndSwapOnBooking(trigger.new);
    }
    public static void afterUpdate(List<unit_hold_request__c> triggerNewList, Map<Id,unit_hold_request__c> oldMap){
        List<ID> nsaListToCopyDocument = new List<ID>();
        for(unit_hold_request__c nsa : triggerNewList){
            if(nsa.booking__c != null
               && nsa.booking__c != oldmap.get(nsa.id).booking__c){
                   nsaListToCopyDocument.add(nsa.id);
               }
        }
        if(nsaListToCopyDocument.isEmpty()){
            return;
        }
        Map<Id,List<ID>> nsaListToDocMap = new  Map<Id,List<ID>>();
        Map<Id,Set<String>> nsaListToDocName = new  Map<Id,Set<String>>();
        for(ContentDocumentLink cdl : [select id,linkedEntityID,contentDocumentID,contentDocument.title from contentdocumentLink where 
                                       contentDocument.title like '%Applicant%' and linkedEntityID in : nsaListToCopyDocument]){
                                           if(!nsaListToDocMap.containsKey(cdl.linkedEntityID)){
                                               nsaListToDocMap.put(cdl.linkedEntityID,new List<Id>());
                                               nsaListToDocName.put(cdl.linkedEntityID, new Set<String>());
                                           }
                                           nsaListToDocMap.get(cdl.linkedEntityID).add(cdl.contentDocumentID);
                                           nsaListToDocName.get(cdl.linkedEntityID).add( cdl.contentDocument.title);
                                       }
        
        List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        Map<Id,ID> mapbookingTpNsaId = new Map<Id,Id>();
        for(unit_hold_request__c nsa : triggerNewList){
            if(nsaListToDocMap.containsKey(nsa.id)){
                for(Id cdId : nsaListToDocMap.get(nsa.id)){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.linkedEntityID = nsa.booking__c;
                    cdl.contentDocumentID = cdId;
                    cdlToInsert.add(cdl);
                    mapbookingTpNsaId.put(nsa.booking__c,nsa.id);
                }
            }
        }
        insert cdlToInsert;
        List<Applicant_Details__c> applicationDetailToUpdate = new List<Applicant_Details__c> ();
        for(Booking__c booking : [select id ,(SELECT   ID, Name,Applicant_Number__c,National_Id_Uploaded__c, Passport_Uploaded__c,
                                              Emirates_Id_Uploaded__c,Other_Documents_Uploaded__c FROM ApplicantDetails__r) from booking__c
                                  WHERE id in: mapbookingTpNsaId.keySet()]){
                                      Id nsaId = mapbookingTpNsaId.get(booking.id);
                                      Set<String> docSet = nsaListToDocName.get(nsaId);
                                      for(Applicant_Details__c appDetail : booking.ApplicantDetails__r){
                                          if(appDetail.Applicant_Number__c == 'Primary Applicant'){
                                              appDetail.Passport_Uploaded__c = docSet.contains('Primary Applicant - Passport Copy');
                                              appDetail.National_Id_Uploaded__c = docSet.contains('Primary Applicant - National Id');
                                              appDetail.Emirates_Id_Uploaded__c = docSet.contains('Primary Applicant - Emirates Id');
                                              //appDetail.Other_Documents_Uploaded__c = docSet.contains('Primary Applicant - Others');
                                              applicationDetailToUpdate.add(appDetail);
                                          }
                                          else if(appDetail.Applicant_Number__c == 'Second Applicant'){
                                              appDetail.Passport_Uploaded__c = docSet.contains('Second Applicant - Passport Copy');
                                              appDetail.National_Id_Uploaded__c = docSet.contains('Second Applicant - National Id');
                                              appDetail.Emirates_Id_Uploaded__c = docSet.contains('Second Applicant - Emirates Id');
                                              //appDetail.Other_Documents_Uploaded__c = docSet.contains('Second Applicant - Others');
                                              applicationDetailToUpdate.add(appDetail);
                                          }
                                          else if(appDetail.Applicant_Number__c == 'Third Applicant'){
                                              appDetail.Passport_Uploaded__c = docSet.contains('Third Applicant - Passport Copy');
                                              appDetail.National_Id_Uploaded__c = docSet.contains('Third Applicant - National Id');
                                              appDetail.Emirates_Id_Uploaded__c = docSet.contains('Third Applicant - Emirates Id');
                                              //appDetail.Other_Documents_Uploaded__c = docSet.contains('Third Applicant - Others');
                                              applicationDetailToUpdate.add(appDetail);
                                          }
                                          else if(appDetail.Applicant_Number__c == 'Fourth Applicant'){
                                              appDetail.Passport_Uploaded__c = docSet.contains('Fourth Applicant - Passport Copy');
                                              appDetail.National_Id_Uploaded__c = docSet.contains('Fourth Applicant - National Id');
                                              appDetail.Emirates_Id_Uploaded__c = docSet.contains('Fourth Applicant - Emirates Id');
                                              //appDetail.Other_Documents_Uploaded__c = docSet.contains('Fourth Applicant - Others');
                                              applicationDetailToUpdate.add(appDetail);
                                          }
                                          else if(appDetail.Applicant_Number__c == 'Fifth Applicant'){
                                              appDetail.Passport_Uploaded__c = docSet.contains('Fifth Applicant - Passport Copy');
                                              appDetail.National_Id_Uploaded__c = docSet.contains('Fifth Applicant - National Id');
                                              appDetail.Emirates_Id_Uploaded__c = docSet.contains('Fifth Applicant - Emirates Id');
                                              //appDetail.Other_Documents_Uploaded__c = docSet.contains('Fifth Applicant - Others');
                                              applicationDetailToUpdate.add(appDetail);
                                          }
                                      }
                                  }
        update applicationDetailToUpdate;
    }
    private static void updateOwnerIDForDEOUsers(List<unit_hold_request__c> triggerNewList){
        String profileName = [SELECT Id,Name from profile WHERE id =: userinfo.getprofileId()].name;
        if(profileName == 'VP-Data Entry Operator' || Test.isRunningTest()){
            Map<Id,Payment_Request__c> mapIdToPaymentRequest = new Map<Id,Payment_Request__c>();
            Set<Id> paymentRequestId = new Set<Id>();
            for(unit_hold_request__c nsa : triggerNewList){
                paymentRequestId.add(nsa.payment_request__c);
            }
            if(!paymentRequestId.isEmpty()){
                for(Payment_Request__c pr : [SELECT ID,Sales_Manager__c FROM Payment_Request__c WHERe ID IN : paymentRequestId]){
                    mapIdToPaymentRequest.put(pr.id, pr);
                }
                for(unit_hold_request__c nsa : triggerNewList){
                    if(mapIdToPaymentRequest.containsKey(nsa.payment_request__c)){
                        nsa.ownerId = mapIdToPaymentRequest.get(nsa.payment_request__c).Sales_Manager__c;
                    }
                }
            }
        }
    }
    private static void validations(List<unit_hold_request__c> triggerNewList, Map<Id,unit_hold_request__c> oldMapNsa)
    {
        Map<Id, unit_hold_request__c> nsaoppMap = new Map<Id, unit_hold_request__c>();
        list<string> emailList = new list<string>();
        list<string> nameList = new list<string>();
        list<string> phoneList = new list<string>();
        map<string,string> prToUnit = new map<string,string>();
        for(unit_hold_request__c nsa : triggerNewList) 
        {
            if(nsa.Applicant_Name1__c != null) nameList.add(nsa.Applicant_Name1__c);
            if(nsa.Applicant_Name2__c != null) nameList.add(nsa.Applicant_Name2__c);
            if(nsa.Applicant_Name3__c != null) nameList.add(nsa.Applicant_Name3__c);
            if(nsa.Applicant_Name4__c != null) nameList.add(nsa.Applicant_Name4__c);
            if(nsa.Applicant_Name5__c != null) nameList.add(nsa.Applicant_Name5__c);
            
            if(nsa.Applicant_Mobile_Number1__c != null) phoneList.add(nsa.Applicant_Mobile_Number1__c);
            if(nsa.Applicant_Mobile_Number2__c != null) phoneList.add(nsa.Applicant_Mobile_Number2__c);
            if(nsa.Applicant_Mobile_Number3__c != null) phoneList.add(nsa.Applicant_Mobile_Number3__c);
            if(nsa.Applicant_Mobile_Number4__c != null) phoneList.add(nsa.Applicant_Mobile_Number4__c);
            if(nsa.Applicant_Mobile_Number5__c != null) phoneList.add(nsa.Applicant_Mobile_Number5__c);
            
            if(nsa.Applicant_Email_Id1__c  != null) emailList.add(nsa.Applicant_Email_Id1__c );
            if(nsa.Applicant_Email_Id2__c  != null) emailList.add(nsa.Applicant_Email_Id2__c );
            if(nsa.Applicant_Email_Id3__c  != null) emailList.add(nsa.Applicant_Email_Id3__c );
            if(nsa.Applicant_Email_Id4__c  != null) emailList.add(nsa.Applicant_Email_Id4__c );
            if(nsa.Applicant_Email_Id5__c  != null) emailList.add(nsa.Applicant_Email_Id5__c );
            
            if(nsa.Opportunity__c <> null)
            {
                if(nsaoppMap.containsKey(nsa.Opportunity__c))
                {
                    nsa.addError('The Opportunity is already tagged to NSA record, please Contact System Admin');
                }
                else
                {
                    if(oldMapNsa==null || nsa.Opportunity__c <> oldMapNsa.get(nsa.Id).Opportunity__c)
                    {
                        nsaoppMap.put(nsa.Opportunity__c, nsa); 
                    }
                } 
            }
            if(nsa.Payment_Request__c != null){
                prToUnit.put(nsa.Payment_Request__c,'');
            }
        }
        if(!nsaoppMap.isEmpty())
        {
            for(unit_hold_request__c extnsa :[Select Id, Opportunity__c  from unit_hold_request__c where Opportunity__c in :nsaoppMap.keySet() 
                                              and (Approval_Status__c='Approved by Sales VP' or Approval_Status__c='Approved by Sales Ops' or 
                                                   Approval_Status__c='Approved by Sales VP' or Approval_Status__c='Pending' or Approval_Status__c=''
                                                   or Approval_Status__c='Approved')])
            {
                unit_hold_request__c nsa= nsaoppMap.get(extnsa.Opportunity__c); 
                nsa.addError('The Opportunity is already tagged to NSA record, please Contact System Admin');
            }
            
        }  
        
        try{
            list<string> passportIds = new list<string>();
            if(prToUnit.keySet().size() > 0){
                for(Payment_Request__c pr : [select Id,Unit__c,Emirates_Id_Passport_Number__c from Payment_Request__c where Id IN: prToUnit.keySet()]){
                    prToUnit.put(pr.Id,pr.Unit__c);
                    if(pr.Emirates_Id_Passport_Number__c!=null) passportIds.add(pr.Emirates_Id_Passport_Number__c);
                }
            }
            
            list<string> blacklistedAccount=new list<string>();
            if(passportIds.size()>0){
                for(Applicant_Details__c ad : [select Id,Account__c from Applicant_Details__c where 
                                               (Passport_Copy_Details__c IN : passportIds OR Emirates_ID_Details__c IN: passportIds) AND 
                                               Account__c != null])
                {
                    blacklistedAccount.add(ad.Account__c);
                }
                for(Opportunity op : [select Id,AccountId from Opportunity where 
                                      AccountId!=null AND Passport_No__c IN: passportIds])
                {
                    blacklistedAccount.add(op.AccountId);
                }
            }
            
            list<Blacklisted_Customer__c> blacklistedCustomer = [select Id,Unit__r.Name,Unit__c,From_Date__c,To_Date__c from Blacklisted_Customer__c where
                                                                 (Name IN : nameList OR Account__r.Name IN : nameList OR 
                                                                  Account__r.PersonEmail IN : emailList OR
                                                                  Account__r.PersonMobilePhone IN : phoneList OR
                                                                  Account__r.Phone IN : phoneList OR 
                                                                  (Account__c != null AND Account__c IN: blacklistedAccount)) 
                                                                 AND Blacklisted__c = true ORDER BY CreatedDate Desc];
            for(unit_hold_request__c nsa : triggerNewList) 
            {
                if(blacklistedCustomer.size()>0){
                    string blacklistedCustomerUnitId='';
                    if(blacklistedCustomer[0].Unit__c!=null)
                        blacklistedCustomerUnitId = blacklistedCustomer[0].Unit__c;
                    
                    string nsaUnit = (prToUnit.containsKey(nsa.Payment_Request__c))?prToUnit.get(nsa.Payment_Request__c):'';
                    
                    if(blacklistedCustomerUnitId=='' || nsaUnit == blacklistedCustomerUnitId)
                    {
                        if(blacklistedCustomer[0].From_Date__c != null && blacklistedCustomer[0].To_Date__c != null && blacklistedCustomer[0].From_Date__c <= system.today() && blacklistedCustomer[0].To_Date__c >= system.today())
                            nsa.addError('Due to System restriction please contact SalesOps SPOC to assist.');
                        else if(blacklistedCustomer[0].From_Date__c != null && blacklistedCustomer[0].To_Date__c == null && blacklistedCustomer[0].From_Date__c <= system.today())
                            nsa.addError('Due to System restriction please contact SalesOps SPOC to assist.');
                        else if(blacklistedCustomer[0].From_Date__c == null && blacklistedCustomer[0].To_Date__c == null)
                            nsa.addError('Due to System restriction please contact SalesOps SPOC to assist.');                    
                    }
                }
            }
        }
        catch(Exception e){
            PaymentRequestFormController.insertErrorLog(e.getMessage(),e.getStackTraceString(),triggerNewList[0].Payment_Request__c,'NewSaleApprovalTriggerHandler','validations');
        }
    }
    public static void beforeUpdate(List<unit_hold_request__c> triggerNewList, Map<Id,unit_hold_request__c> oldMap)
    {
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name; 
        if(profileName.contains('Sales Operation')){
            for(unit_hold_request__c nsa : triggerNewList){
                if(nsa.New_Sale_Verification_by_SO__c != oldMap.get(nsa.Id).New_Sale_Verification_by_SO__c){
                    nsa.SO_Verified_By__c = userinfo.getuserid();   
                }
                
            }
        }
        validations(triggerNewList, oldMap);
        getCancelAndRebookField(triggerNewList, oldMap);
    }
    public static void getCancelAndRebookField(List<unit_hold_request__c> triggerNewList, Map<Id,unit_hold_request__c> triggerOldList){
        set<Id> bookingIdSet = new Set<Id>();
        List<booking__c> booklist = new List<Booking__c>();
        for(unit_hold_request__c nsa: triggerNewList){
            if(triggerOldList != null){
                Boolean hasCancelSwapChanged = (nsa.Cancel_Swap__c != triggerOldList.get(nsa.Id).Cancel_Swap__c);
                Boolean hasBookingChanged = (nsa.Booking__c != triggerOldList.get(nsa.Id).Booking__c);
                Boolean hasCancelRebookChanged = (nsa.Cancel_Rebook__c != triggerOldList.get(nsa.Id).Cancel_Rebook__c);
                if((hasBookingChanged || hasCancelSwapChanged || hasCancelRebookChanged) && nsa.Booking__c != null ){
                    Booking__c booking = new Booking__c(Id = nsa.Booking__c );
                    if((hasCancelRebookChanged || hasCancelSwapChanged) && nsa.Cancel_Rebook__c == 'Yes' &&  nsa.Cancel_Swap__c == 'Yes'){
                        nsa.addError('Cannot update both Cancel-Swap & Cancel-Rebook as Yes');
                    }
                    if(hasCancelRebookChanged){
                        booking.Cancel_Rebook__c = nsa.Cancel_Rebook__c ;  
                    }
                    if(hasCancelSwapChanged){
                        booking.Cancel_Swap__c = nsa.Cancel_Swap__c; 
                    }
                    booklist.add(booking);  
                    System.debug('booking'+booking);
                }
                
            }
        }
        if(booklist.size()>0){
            Update booklist;
        }
    }
    
}
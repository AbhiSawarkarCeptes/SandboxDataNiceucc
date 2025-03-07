public class TransactionRequestTriggerHelper {
    public static Boolean isRun = true;
    
    public static void errorMSG(List<PropStrength__Transaction_Requests__c> newList,map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        set<Id> transactionIds = new set<Id>();
        Id refundRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
        List<PropStrength__Transaction_Requests__c> updateList = new List<PropStrength__Transaction_Requests__c>();
        for(PropStrength__Transaction_Requests__c trans : newList) {
            if(trans.PropStrength__Application_Booking__c != null &&
               trans.RecordTypeId == refundRecordTypeId) {
                   transactionIds.add(trans.PropStrength__Application_Booking__c);
               }
        }
        system.debug('transactionIds::'+transactionIds);
        Map<Id, PropStrength__Application_Booking__c> bookingMap=new   Map<Id, PropStrength__Application_Booking__c>();
        if(!transactionIds.isEmpty()) {
            bookingMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id,PropStrength__Outstanding_Balance__c, PCC_Document_Approved__c
                                                                                                                          FROM PropStrength__Application_Booking__c 
                                                                                                                          WHERE Id IN: transactionIds]);// 
        }

        for(PropStrength__Transaction_Requests__c trans : newList) {
            if(Trigger.isInsert) {
                if(trans.Actual_Advance_Amount__c == null) {
                    trans.Actual_Advance_Amount__c = 0;
                }
                /*if(trans.Refund_Reason__c != 'Cancel and refund' && trans.PropStrength__Application_Booking__c != null && bookingMap.containsKey(trans.PropStrength__Application_Booking__c) && !bookingMap.get(trans.PropStrength__Application_Booking__c).PCC_Document_Approved__c) {
                    trans.addError('Refund cannot be initiated as the PCC process is not completed.');
                }*/
                if(trans.PropStrength__Application_Booking__c != null && bookingMap.containsKey(trans.PropStrength__Application_Booking__c) && bookingMap.get(trans.PropStrength__Application_Booking__c).PropStrength__Outstanding_Balance__c <= 0 && trans.PropStrength__Refund_Type__c == 'Advance Refund' &&
                    trans.PropStrength__Final_Refund_Amount__c != null &&
                    trans.PropStrength__Final_Refund_Amount__c > Math.abs(bookingMap.get(trans.PropStrength__Application_Booking__c).PropStrength__Outstanding_Balance__c)) {
                  //  trans.PropStrength__Final_Refund_Amount__c.addError('Amount should not be greater then actual advance amount    ');
                }
            } else if(Trigger.isUpdate) {
                if(trans.PropStrength__Application_Booking__c != null && bookingMap.containsKey(trans.PropStrength__Application_Booking__c) && bookingMap.get(trans.PropStrength__Application_Booking__c).PropStrength__Outstanding_Balance__c <= 0 && trans.PropStrength__Refund_Type__c == 'Advance Refund' &&
                    trans.PropStrength__Final_Refund_Amount__c != null &&
                    trans.PropStrength__Final_Refund_Amount__c > trans.Actual_Advance_Amount__c) {
              //      trans.PropStrength__Final_Refund_Amount__c.addError('Amount should not be greater then actual advance amount    ');
                }
            }
        }
    }
    
    public static void sendDLDCertificate(List<PropStrength__Transaction_Requests__c> newList,map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        set<Id> transactionIds = new set<Id>();
        Id SPARecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Pre-Registration Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c trans : newList) {
            if(trans.DLD_Certificate_Uploaded__c == True && trans.DLD_Certificate_Uploaded_Date__c != null &&
               trans.DLD_Certificate_Uploaded__c != oldMap.get(trans.Id).DLD_Certificate_Uploaded__c &&
               trans.DLD_Certificate_Uploaded_Date__c != oldMap.get(trans.Id).DLD_Certificate_Uploaded_Date__c &&
               trans.PropStrength__Application_Booking__c != null &&
               trans.RecordTypeId == SPARecordTypeId) {
                   transactionIds.add(trans.Id);
               } 
        }
        if(!transactionIds.isEmpty()) {
            if(System.IsBatch() == false && System.isFuture() == false) { 
                TransactionRequestEmailSend.sendEmailDLDCertificate(transactionIds);
            }
        }
    }
    
    public static void updateDLDCertificate(List<PropStrength__Transaction_Requests__c> newList,map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        Id refundRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Pre-Registration Process').getRecordTypeId();
        List<PropStrength__Transaction_Requests__c> updateList = new List<PropStrength__Transaction_Requests__c>();
        for(PropStrength__Transaction_Requests__c trans : newList) {
            if(trans.Oqood_Certificate_No__c != null && 
               trans.Oqood_Certificate_No__c != oldMap.get(trans.Id).Oqood_Certificate_No__c &&
               trans.RecordTypeId == refundRecordTypeId) {
                   trans.DLD_Certificate_Uploaded__c = true;
                   trans.DLD_Certificate_Uploaded_Date__c = System.now();
               }
        }
    }
    
    public static void sendDSPA(List<PropStrength__Transaction_Requests__c> newList,map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        set<Id> transactionIds = new set<Id>();
        set<Id> transactionLegalIds = new set<Id>();
        Id SPARecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('DSPA Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c trans : newList) {
            if(trans.DSPA_Created__c == True && trans.DCR_Created__c == True && 
               trans.DCR_Created__c != oldMap.get(trans.Id).DCR_Created__c &&
               trans.PropStrength__Application_Booking__c != null &&
               trans.RecordTypeId == SPARecordTypeId) {
                   transactionIds.add(trans.Id);
               } else if(trans.DSPA_Created__c == True && trans.DCR_Created__c == True && 
                         trans.PropStrength__Status__c == 'DSPA Executed' &&
                         trans.PropStrength__Status__c != oldMap.get(trans.Id).PropStrength__Status__c &&
                         trans.PropStrength__Application_Booking__c != null &&
                         trans.RecordTypeId == SPARecordTypeId) {
                             transactionLegalIds.add(trans.Id);
                         }
        }
         if(!transactionIds.isEmpty()) {
            if(System.IsBatch() == false && System.isFuture() == false) { 
                TransactionRequestEmailSend.sendEmailDSPA(transactionIds);
            }
        }
        if(!transactionLegalIds.isEmpty()) {
            if(System.IsBatch() == false && System.isFuture() == false) { 
                TransactionRequestEmailSend.sendEmailLegalDSPA(transactionLegalIds);
            }
        }
    }
    
   /* public static void submitForApproval(List<PropStrength__Transaction_Requests__c> newList,map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        set<Id> transactionIds = new set<Id>();
        Id spaRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        List<PropStrength__Transaction_Requests__c> updateList = new List<PropStrength__Transaction_Requests__c>();
        for(PropStrength__Transaction_Requests__c trans : newList) {
            if(trans.Digi_Signed_SPA_Received_From_Customer__c == true && 
               trans.Digi_Signed_SPA_Received_From_Customer__c != oldMap.get(trans.Id).Digi_Signed_SPA_Received_From_Customer__c &&
               trans.PropStrength__Application_Booking__c != null &&
               trans.RecordTypeId == spaRecordTypeId) {
                   System.debug(trans.Digi_Signed_SPA_Received_From_Customer__c+'*---*'+trans.SPA_Sent_to_Customer_for_Digi_Sign__c+'*---*'+trans.SPA_Sent_for_Audit_Verification__c);
                   Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                   req1.setComments('Submitting request for approval.');
                   req1.setObjectId(trans.id);
                   
                   // Submit on behalf of a specific submitter
                   req1.setSubmitterId(trans.CreatedById); 
                   
                   // Submit the record to specific process and skip the criteria evaluation
                   req1.setProcessDefinitionNameOrId('SPA_Process_Approcal_Process');
                   req1.setSkipEntryCriteria(true);
                   
                   // Submit the approval request for the account
                   Approval.ProcessResult result = Approval.process(req1);
                   system.debug('result::'+result);
               }
        }
    }*/
  /*  
    public static void sendSPA(List<PropStrength__Transaction_Requests__c> newList,map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        set<Id> transactionIds = new set<Id>();
        set<Id> transactionLegalIds = new set<Id>();
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        Id SPARecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c trans : newList) {
            if(trans.PropStrength__Status__c == 'SPA Executed' && 
               trans.PropStrength__Status__c != oldMap.get(trans.Id).PropStrength__Status__c &&
               trans.PropStrength__Application_Booking__c != null &&
               trans.SPA_Created__c == true && 
               trans.RecordTypeId == SPARecordTypeId) {
                   transactionIds.add(trans.Id);
                   PropStrength__Application_Booking__c oneTrans = new PropStrength__Application_Booking__c();
                                oneTrans.Id = trans.PropStrength__Application_Booking__c;
                                oneTrans.SPA_Executed__c = true;
                                oneTrans.SPA_Execution_Date__c = Date.Today();
                                updateList.add(oneTrans);
               }
        }
        if(!updateList.isEmpty()) {
                                update updateList;
                            }
         if(!transactionIds.isEmpty()) {
            if(System.IsBatch() == false && System.isFuture() == false) { 
                TransactionRequestEmailSend.sendEmailSPA(transactionIds);
            }
        }
    }*/
  /*  
    public static void sendMOU(List<PropStrength__Transaction_Requests__c> newList,map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        set<Id> transactionIds = new set<Id>();
        set<Id> transactionLegalIds = new set<Id>();
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Transaction_Requests__c> updateTranList = new List<PropStrength__Transaction_Requests__c>();
        Id mouRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('MOU Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c trans : newList) {
            if(trans.PropStrength__Status__c == 'MOU Executed' && 
               trans.PropStrength__Status__c != oldMap.get(trans.Id).PropStrength__Status__c &&
               trans.PropStrength__Application_Booking__c != null &&
               trans.MOU_Created__c == true && 
               trans.RecordTypeId == mouRecordTypeId) {
                   transactionIds.add(trans.Id);
                   PropStrength__Transaction_Requests__c oneTrans = new PropStrength__Transaction_Requests__c();
                   oneTrans.Id = trans.Id;
                   oneTrans.MOU_Sent_for_Final_Approval__c = true;
                   oneTrans.MOU_Sent_for_Final_Approval_Date__c = Date.Today();
                   updateTranList.add(oneTrans);
                   
                   PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c();
                   book.Id = trans.PropStrength__Application_Booking__c;
                   book.MOU_Executed__c = true;
                   book.MOU_Execution_Date__c = Date.today();
                   updateList.add(book);
               } else if(trans.MOU_Verified_by_Development_Legal_Team__c == true && 
                         trans.MOU_Verified_by_Development_Legal_Team__c != oldMap.get(trans.Id).MOU_Verified_by_Development_Legal_Team__c &&
                         trans.MOU_Verification_Date__c != null &&
                         trans.MOU_Verification_Date__c != oldMap.get(trans.Id).MOU_Verification_Date__c &&
                         trans.PropStrength__Application_Booking__c != null &&
                         trans.MOU_Created__c == true && 
                         trans.RecordTypeId == mouRecordTypeId) {
                   transactionLegalIds.add(trans.Id);
               }
        }
        if(!updateList.isEmpty()) {
            update updateTranList;
        }
        if(!updateList.isEmpty()) {
            update updateList;
        }
        System.debug('transactionIds****'+transactionIds);
         if(!transactionIds.isEmpty()) {
            if(System.IsBatch() == false && System.isFuture() == false) { 
                TransactionRequestEmailSend.sendEmailMOU(transactionIds);
            }
        }
        System.debug('transactionLegalIds****'+transactionLegalIds);
        if(!transactionLegalIds.isEmpty()) {
            if(System.IsBatch() == false && System.isFuture() == false) { 
                TransactionRequestEmailSend.sendEmailLegalMOU(transactionLegalIds);
            }
        }
    }
    */
    public static void updateAdvanceAmount(List<PropStrength__Transaction_Requests__c> newList) {
        set<Id> transactionIds = new set<Id>();
        Id refundRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
        List<PropStrength__Transaction_Requests__c> updateList = new List<PropStrength__Transaction_Requests__c>();
        for(PropStrength__Transaction_Requests__c trans : newList) {
            if(trans.PropStrength__Refund_Type__c == 'Advance Refund' && 
               trans.PropStrength__Application_Booking__c != null &&
               trans.RecordTypeId == refundRecordTypeId) {
                   transactionIds.add(trans.PropStrength__Application_Booking__c);
               }
        }
        system.debug('transactionIds::'+transactionIds);
        if(!transactionIds.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id,PropStrength__Outstanding_Balance__c
                                                                                                                          FROM PropStrength__Application_Booking__c 
                                                                                                                          WHERE Id IN: transactionIds AND
                                                                                                                          (PropStrength__Outstanding_Balance__c < 0 OR PropStrength__Outstanding_Balance__c =: 0)]);// 
            system.debug('bookingMap::'+bookingMap);
            if(!bookingMap.isEmpty()) {
                for(PropStrength__Transaction_Requests__c trans : newList) {
                    if(bookingMap.containsKey(trans.PropStrength__Application_Booking__c)) {
                        PropStrength__Transaction_Requests__c oneTrans = new PropStrength__Transaction_Requests__c();
                        oneTrans.Id = trans.Id;
                        oneTrans.Actual_Advance_Amount__c = (bookingMap.get(trans.PropStrength__Application_Booking__c).PropStrength__Outstanding_Balance__c != null && bookingMap.get(trans.PropStrength__Application_Booking__c).PropStrength__Outstanding_Balance__c != 0) ? 
                                                            Math.abs(bookingMap.get(trans.PropStrength__Application_Booking__c).PropStrength__Outstanding_Balance__c) : 0;
                        updateList.add(oneTrans);
                    }
                }
                if(!updateList.isEmpty()) {
                    List<Database.SaveResult> updateResultList = Database.update(updateList,true);
                    system.debug('updateResultList::'+updateResultList);
                }
            }
        }
    }
    
    //Added by Deepak sharma to create payment received record of Rebate Amount Type
    public static void createPaymentRecRebateRecord(List<PropStrength__Transaction_Requests__c> newList,map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        List<PropStrength__Received_Payment__c> createPayRec = new List<PropStrength__Received_Payment__c>();
        Id payRecRecTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id transReqRecTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Advance Payment Rebate').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c transReq: newList) {
            if(transReq.PropStrength__Status__c != oldMap.get(transReq.Id).PropStrength__Status__c && transReq.PropStrength__Status__c == 'Request Completed' && transReq.RecordTypeId == transReqRecTypeId) {
                createPayRec.add(new PropStrength__Received_Payment__c(PropStrength__Amount__c = transReq.Advance_Payment_Rebate_Amount__c, RecordTypeId = payRecRecTypeId, PropStrength__Amount_Due_Type__c = 'Rebate', PropStrength__Payment_Type__c = 'Cash', PropStrength__Payment_Date__c = transReq.Payment_Date__c, PropStrength__Issue_Date__c = transReq.Payment_Date__c, Last_Reminder_Sent__c = FALSE, PropStrength__Adjusted__c = FALSE, PropStrength__Bank_Verified_Signature__c = FALSE, PropStrength__Booking_Amount__c = FALSE, PropStrength__Booking_Cheque_Bounced__c = FALSE, PropStrength__Call_Notice_Sent__c = FALSE, PropStrength__Cheque_Bounced__c = FALSE, PropStrength__Cheque_Deposited__c = FALSE, PropStrength__Created_Automatically__c = FALSE, PropStrength__Decrease_Agreement_Amount__c = FALSE, PropStrength__Demand_Email_Sent__c = FALSE, PropStrength__Demand_Generated__c = FALSE, PropStrength__Demand_SMS_Sent__c = FALSE, PropStrength__Is_Reversal_Created__c = FALSE, PropStrength__IsAdjustedWaiverChargeAmount__c = FALSE, PropStrength__IsCreatedFromSpecificWaiver__c = FALSE, PropStrength__Milestone_Approved__c = FALSE, PropStrength__Partial_Booking_Cheque_Bounce__c = FALSE, PropStrength__Pay_Interest__c = FALSE, PropStrength__Payment_Used__c = FALSE, PropStrength__Reallocation_Fund_Transfer__c = FALSE, PropStrength__Rebate_Applicable__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Submit_For_Reversal__c = FALSE, PropStrength__TDS_Received__c = FALSE, PropStrength__TPD_Given__c = FALSE, PropStrength__TPD_Reversed__c = FALSE, Rebate_Calculated__c = FALSE, X1st_Reminder_Sent__c = FALSE, X2nd_Reminder_Sent__c = FALSE, X3rd_Reminder_Sent__c = FALSE, X4th_Reminder_Sent__c = FALSE, PropStrength__Application_Booking__c = transReq.PropStrength__Application_Booking__c));
            }
        }
        if(!createPayRec.isEmpty()) {
            System.debug('createPayRec::'+createPayRec);
            insert createPayRec;
            Map<Id, List<Id>> appPayMap = new Map<Id, List<Id>>();
            for(PropStrength__Received_Payment__c payCreate : createPayRec) {
                if(payCreate.PropStrength__Application_Booking__c != null && appPayMap.containsKey(payCreate.PropStrength__Application_Booking__c)) {
                    appPayMap.get(payCreate.PropStrength__Application_Booking__c).add(payCreate.Id);
                } else if(payCreate.PropStrength__Application_Booking__c != null) {
                    appPayMap.put(payCreate.PropStrength__Application_Booking__c, new List<Id>{payCreate.Id});   
                }
            }
            if(!appPayMap.isEmpty()) {
                List<PropStrength__Received_Payment__c> updatePayRec = new List<PropStrength__Received_Payment__c>();
                for(PropStrength__Transaction_Requests__c transReq: newList) {
                    if(transReq.Selected_Payment__c != '') {
                        List<String> payIds = transReq.Selected_Payment__c.split(',');
                        for(String payId: payIds) {
                            if(transReq.PropStrength__Application_Booking__c != null && appPayMap.containsKey(transReq.PropStrength__Application_Booking__c)) {      
                                Id keyId = appPayMap.get(transReq.PropStrength__Application_Booking__c)[0];
                                updatePayRec.add(new PropStrength__Received_Payment__c(Id = payId, Rebate_Calculated__c = TRUE, Rebate_Record__c = keyId));    
                            }
                        }
                    }
                }
                System.debug('updatePayRec::'+updatePayRec);
                if(!updatePayRec.isEmpty()) {
                    update updatePayRec;
                }
            }
        }
    }

    //Added by Deepak sharma to show error message when customer change transaction request is created after flip date 
    public static void customerChangeErrorMsg(List<PropStrength__Transaction_Requests__c> newList) {
        Set<Id> bookId = new Set<Id>();
        Id nameChangeRecType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Addition / Deletion of Name').getRecordTypeId();

        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(nameChangeRecType != null && tr.RecordTypeId == nameChangeRecType && tr.PropStrength__Application_Booking__c != null) {
                bookId.add(tr.PropStrength__Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Primary_Customer__c, PropStrength__Primary_Customer__r.PropStrength__Account_Type__c, Flip_Validity_Date__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            if(!bookMap.isEmpty()) {
                for(PropStrength__Transaction_Requests__c tr : newList) {
                    if(nameChangeRecType != null && tr.RecordTypeId == nameChangeRecType && tr.PropStrength__Customer_Transfer_Type__c == 'Customer Transfer' && bookMap.containsKey(tr.PropStrength__Application_Booking__c) && bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__c != null && bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.PropStrength__Account_Type__c == 'Broker' && bookMap.get(tr.PropStrength__Application_Booking__c).Flip_Validity_Date__c != null && bookMap.get(tr.PropStrength__Application_Booking__c).Flip_Validity_Date__c < System.Today()) {
                        tr.addError('The flip validity period has ended.');
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma to Create Payment of Income Charge Due Record Type on Aug'07 2023
    /*public static void createPaymentIncomeChargeDue(List<PropStrength__Transaction_Requests__c> newList) {
        Id recTypeTransId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId();
        Set<Id> bookingId = new Set<Id>();
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.RecordTypeId == recTypeTransId && tr.New_Buyer_s_Documents_Received__c && tr.PropStrength__Application_Booking__c != null) {
                bookingId.add(tr.PropStrength__Application_Booking__c);
            }
        }
        System.debug('bookingId**---'+bookingId);
        if(!bookingId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Project__r.Transfer_Charges_Title_Transfer__c, PropStrength__Project__r.Transfer_Charges_No_Title_Transfer__c, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.Name, PropStrength__Project__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__GST_Status__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]);
            if(!bookingMap.isEmpty()) {
                Map<Id, PropStrength__Projects__c> projectMap = new Map<Id, PropStrength__Projects__c>();
                Set<Id> projIds = new Set<Id>();
                for(PropStrength__Application_Booking__c book : bookingMap.values()) {
                    if(book.PropStrength__Project__c != null) {
                        projIds.add(book.PropStrength__Project__c);
                    }
                }
            
                if(!projIds.isEmpty()) {
                    projectMap = new Map<Id, PropStrength__Projects__c>([SELECT Id, (SELECT Id, PropStrength__Income_Charge_Code__c, Name, PropStrength__Service_Tax__c, RecordType.Name FROM PropStrength__Income_Charges__r WHERE Name = 'Transfer Fee' AND PropStrength__Income_Charge_Code__c = 'Transfer Fee' AND PropStrength__Active__c = TRUE) FROM PropStrength__Projects__c WHERE Id IN :projIds]);
                }
                
                List<PropStrength__Received_Payment__c> paymentInsertList = new List<PropStrength__Received_Payment__c>();
                Id recTypeIncDueId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
                for(PropStrength__Transaction_Requests__c tr : newList) {
                    if(tr.RecordTypeId == recTypeTransId && tr.New_Buyer_s_Documents_Received__c && tr.PropStrength__Application_Booking__c != null && bookingMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        Decimal taxAmt = 0;
                        if(projectMap.containsKey(bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__c) && projectMap.get(bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r.size() > 0) {
                            PropStrength__Income_Charges__c inCh = projectMap.get(bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r[0];
                            System.debug('Rectype**'+inCh.RecordType.Name );
                            System.debug( inch.PropStrength__Service_Tax__c);
                            if(inCh.RecordType.Name == 'Fixed') {
                                taxAmt = inch.PropStrength__Service_Tax__c;
                            }
                        }
                        System.debug(taxAmt);
                        if(tr.PropStrength__Customer_Transfer_Type__c == 'Title Transfer') {
                            paymentInsertList.add(new PropStrength__Received_Payment__c(RecordTypeId = recTypeIncDueId, PropStrength__Amount_Due_Type__c='Transfer Fee', PropStrength__Amount__c=bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__r.Transfer_Charges_Title_Transfer__c+((bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__r.Transfer_Charges_Title_Transfer__c * taxAmt) / 100), PropStrength__Payment_Date__c=System.Today(), PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c));                 
                            tr.Transfer_Charges_Raised_to_Customer__c=TRUE;
                        } else if(tr.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer') {
                            paymentInsertList.add(new PropStrength__Received_Payment__c(RecordTypeId = recTypeIncDueId, PropStrength__Amount_Due_Type__c='Transfer Fee', PropStrength__Amount__c=bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__r.Transfer_Charges_No_Title_Transfer__c+((bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__r.Transfer_Charges_No_Title_Transfer__c * taxAmt )/ 100), PropStrength__Payment_Date__c=System.Today(), PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c));
                            tr.Transfer_Charges_Raised_to_Customer__c=TRUE;
                        }
                    }
                }
                System.debug(paymentInsertList);
                if(!paymentInsertList.isEmpty()) {
                    insert paymentInsertList;
                    Set<Id> payIds = new Set<Id>();
                    for(PropStrength__Received_Payment__c pay: paymentInsertList) {
                        payIds.add(pay.Id);
                    }
                    List<PropStrength__Received_Payment__c> sendPayData = [SELECT Id, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Application_Booking__r.Name,  PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email FROM PropStrength__Received_Payment__c WHERE Id IN :payIds];
                    for(PropStrength__Received_Payment__c tr: sendPayData) {
                        TransactionRequestTriggerHelper.sendEmailNotification(tr.Id, tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email);
                    }
                }
            }
        }
    }*/
    
    //Added by Deepak sharma to Create Payment of Income Charge Due Record Type on Aug'07 2023
    /*public static void createPaymentIncomeChargeDueOnUpdate(List<PropStrength__Transaction_Requests__c> newList, Map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        Id recTypeTransId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId();
        Set<Id> bookingId = new Set<Id>();
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.PropStrength__Application_Booking__c != null && tr.RecordTypeId == recTypeTransId && tr.New_Buyer_s_Documents_Received__c && oldMap.get(tr.Id).New_Buyer_s_Documents_Received__c != tr.New_Buyer_s_Documents_Received__c) {
                bookingId.add(tr.PropStrength__Application_Booking__c);
            }
        }
        System.debug('bookingId**---'+bookingId);
        if(!bookingId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Project__r.Transfer_Charges_Title_Transfer__c, PropStrength__Project__r.Transfer_Charges_No_Title_Transfer__c, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.Name, PropStrength__Project__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__GST_Status__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]);
            if(!bookingMap.isEmpty()) {
                Map<Id, PropStrength__Projects__c> projectMap = new Map<Id, PropStrength__Projects__c>();
                Set<Id> projIds = new Set<Id>();
                for(PropStrength__Application_Booking__c book : bookingMap.values()) {
                    if(book.PropStrength__Project__c != null) {
                        projIds.add(book.PropStrength__Project__c);
                    }
                }
            
                if(!projIds.isEmpty()) {
                    projectMap = new Map<Id, PropStrength__Projects__c>([SELECT Id, (SELECT Id, PropStrength__Income_Charge_Code__c, Name, PropStrength__Service_Tax__c, RecordType.Name FROM PropStrength__Income_Charges__r WHERE Name = 'Transfer Fee' AND PropStrength__Income_Charge_Code__c = 'Transfer Fee' AND PropStrength__Active__c = TRUE) FROM PropStrength__Projects__c WHERE Id IN :projIds]);
                }
                
                List<PropStrength__Received_Payment__c> paymentInsertList = new List<PropStrength__Received_Payment__c>();
                Id recTypeIncDueId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
                for(PropStrength__Transaction_Requests__c tr : newList) {
                    if(oldMap.get(tr.Id).New_Buyer_s_Documents_Received__c != tr.New_Buyer_s_Documents_Received__c && tr.RecordTypeId == recTypeTransId && tr.New_Buyer_s_Documents_Received__c && tr.PropStrength__Application_Booking__c != null && bookingMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        Decimal taxAmt = 0;
                        if(projectMap.containsKey(bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__c) && projectMap.get(bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r.size() > 0) {
                            PropStrength__Income_Charges__c inCh = projectMap.get(bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r[0];
                            System.debug('Rectype**'+inCh.RecordType.Name );
                            if(inCh.RecordType.Name == 'Fixed') {
                                taxAmt = (bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__r.Transfer_Charges_Title_Transfer__c * inch.PropStrength__Service_Tax__c ) / 100;
                            }
                        }
                        if(tr.PropStrength__Customer_Transfer_Type__c == 'Title Transfer') {
                            paymentInsertList.add(new PropStrength__Received_Payment__c(RecordTypeId = recTypeIncDueId, PropStrength__Amount_Due_Type__c='Transfer Fee', PropStrength__Amount__c=bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__r.Transfer_Charges_Title_Transfer__c + taxAmt, PropStrength__Payment_Date__c=System.Today(), PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c));                 
                            tr.Transfer_Charges_Raised_to_Customer__c=TRUE;
                            tr.PropStrength__Status__c = 'Assignment: Update Applicants & Verify Applicants' ;
                            
                        } else if(tr.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer') {
                            paymentInsertList.add(new PropStrength__Received_Payment__c(RecordTypeId = recTypeIncDueId, PropStrength__Amount_Due_Type__c='Transfer Fee', PropStrength__Amount__c=bookingMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Project__r.Transfer_Charges_No_Title_Transfer__c + taxAmt, PropStrength__Payment_Date__c=System.Today(), PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c));
                            tr.Transfer_Charges_Raised_to_Customer__c=TRUE;
                            tr.PropStrength__Status__c = 'Assignment: Update Applicants & Verify Applicants' ;
                            
                        }
                    }
                }
                System.debug(paymentInsertList);
                if(!paymentInsertList.isEmpty()) {
                    insert paymentInsertList;
                    Set<Id> payIds = new Set<Id>();
                    for(PropStrength__Received_Payment__c pay: paymentInsertList) {
                        payIds.add(pay.Id);
                    }
                    List<PropStrength__Received_Payment__c> sendPayData = [SELECT Id, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Application_Booking__r.Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email FROM PropStrength__Received_Payment__c WHERE Id IN :payIds];
                    for(PropStrength__Received_Payment__c tr: sendPayData) {
                        TransactionRequestTriggerHelper.sendEmailNotification(tr.Id, tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email);
                    }
                }
            }
        }
    }*/
    
    //Added by Deepak sharma to send email to customer executive on Aug'08 2023
    /*public static void sendMailOnAuditApprove(List<PropStrength__Transaction_Requests__c> newList, Map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        Set<Id> trIds = new Set<Id>();
        Id recTypeTransfer = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.RecordTypeId == recTypeTransfer && tr.PropStrength__Status__c == 'Audit Approved' && tr.PropStrength__Status__c != oldMap.get(tr.Id).PropStrength__Status__c) {
                trIds.add(tr.Id);
            }
        }
        
        if(!trIds.isEmpty()) {
            List<PropStrength__Transaction_Requests__c> trRecs = [SELECT Id, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email, PropStrength__Application_Booking__r.Name, PropStrength__Application_Booking__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trIds];
            for(PropStrength__Transaction_Requests__c tr  :trRecs) {
                TransactionRequestTriggerHelper.sendEmailNotificationOnAudit(tr.Id, tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c, tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email, tr.PropStrength__Application_Booking__r.Name, tr.PropStrength__Application_Booking__c);
            }
        }
    }*/
    
    //Added by Deepak sharma to send email to customer on Aug'10 2023
    public static void sendMailOnRequestComplete(List<PropStrength__Transaction_Requests__c> newList, Map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        Set<Id> trIds = new Set<Id>();
        Id recTypeHandover = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Handover').getRecordTypeId();
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.RecordTypeId == recTypeHandover && tr.PropStrength__Status__c == 'Request Completed' && tr.PropStrength__Status__c != oldMap.get(tr.Id).PropStrength__Status__c) {
                trIds.add(tr.Id);
                tr.Handover_Completed__c=TRUE;
                tr.Handover_WL_Sent_Date__c=System.Today();
                tr.Handover_Completed_Date__c = System.Today();
                if(tr.PropStrength__Application_Booking__c != null) {
                    bookingList.add(new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c, Handover_Completed__c = TRUE));
                }
            }
        }
        
        if(!trIds.isEmpty()) {
            List<PropStrength__Transaction_Requests__c> trRecs = [SELECT Id, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.POA_Email_Address__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, Handover_to_be_done_by__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trIds];
            Set<Id> bookId = new Set<Id>();
            for(PropStrength__Transaction_Requests__c tr  :trRecs) {
                if(tr.PropStrength__Application_Booking__c != null) {
                    bookId.add(tr.PropStrength__Application_Booking__c);
                }
            }
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r) FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            for(PropStrength__Transaction_Requests__c tr  :trRecs) {
                if(bookMap.containsKey(tr.PropStrength__Application_Booking__c) && !bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appDetail : bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r) {
                        TransactionRequestTriggerHelper.sendHandoverWelcomeLetterEmail(tr.Id, appDetail.PropStrength__Customer_Name__c, appDetail.PropStrength__Applicant_Email__c, tr.PropStrength__Application_Booking__r.POA_Email_Address__c, tr.Handover_to_be_done_by__c);   
                    }
                }
            }
            if(!bookingList.isEmpty()) {
                update bookingList;
            }
        }
    }
    
    //Added by Deepak sharma to send email to primary customer on Aug'07 2023
    //@future(callout=true)
    /*public static void sendEmailNotification(Id trId, String customerName, String customerEmail) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String framesrc = '/apex/TransferChargeNotice?id='+trId;
        PageReference p1 = new PageReference(framesrc);
        blob content;
        if(Test.isRunningTest()) { 
            content = blob.valueOf('Unit.Test');
        } else {
            content = p1.getContentAsPDF();
        }
        System.debug(content);
        mail.setSubject('Transfer Charges Demand');
        mail.setplaintextbody('Dear '+customerName+',\n\nWe trust this message finds you well.\n\nWe would like to inform you that the due of transfer charge has been created.\n\nKindly find the details regarding this charge in the attached document.\n\nIf you have any questions or require further assistance, please don\'t hesitate to reach out to us. Our dedicated team is here to help.\n\nThank you for your prompt attention to this matter.\n\nBest regards,\n\nSobha Team');
        mail.setToAddresses(new List<String>{customerEmail});
        
        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        efa1.setFileName('Transfer Charges Demand.pdf');
        efa1.setBody(content);   
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
        System.debug(mail);
        emailList.add(mail);
        
        System.debug(emailList);
        if(emailList != null && emailList.size()>0 ) {
            System.debug(emailList);
            Messaging.sendEmail(emailList);
            EmailMessage newEmail = new EmailMessage();
            newEmail.ToAddress = customerEmail;
            newEmail.Subject = 'Transfer Charges Demand';
            newEmail.TextBody = mail.getPlainTextBody();
            newEmail.RelatedToId = trId;
            newEmail.Status = '3';
            insert newEmail;
        }
    }*/
    
    //Added by Deepak sharma to send email to customer executive on Aug'08 2023
    /*@future(callout=true)
    public static void sendEmailNotificationOnAudit(Id trId, String house, String customerEmail, String bookName, String bookId) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        System.debug(trId);  
        System.debug(house);  
        System.debug(customerEmail);
        System.debug(bookName);
        System.debug(bookId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String urlStr = URL.getSalesforceBaseUrl().toExternalForm()+'/'+bookId;
        mail.setSubject('Transfer of Property Transaction approved by Audit');
        //mail.setPlainTextBody('Dear CRM Team,\n\nPlease note Transfer of Property for unit '+house+', booking ID '+bookName+' has been approved by audit for processing.\n\nIt is in your queue for execution. Please complete the execution and close the step.\n\nRegards,\nSalesforce');
        mail.setHtmlBody('<html><body>Dear CRM Team,<br/><br/>Please note Transfer of Property for unit '+house+', <a href="'+urlStr+'">'+bookName+'</a> has been approved by audit for processing.<br/><br/>It is in your queue for execution. Please complete the execution and close the step.<br/><br/>Regards,<br/>Salesforce</body></html>');
        mail.setToAddresses(new List<String>{customerEmail});

        System.debug(mail);
        emailList.add(mail);
        
        System.debug(emailList);
        if(emailList != null && emailList.size()>0 ) {
            System.debug(emailList);
            Messaging.sendEmail(emailList);
            EmailMessage newEmail = new EmailMessage();
            newEmail.ToAddress = customerEmail;
            newEmail.Subject = 'Transfer of Property Transaction approved by Audit';
            newEmail.HtmlBody = mail.getHtmlBody();
            newEmail.RelatedToId = trId;
            newEmail.Status = '3';
            insert newEmail;
        }
    }*/
    
    //Added by Deepak sharma to send email to customer on Aug'10 2023
    @future(callout=true)
    public static void sendHandoverWelcomeLetterEmail(String recId, String customerName, String customerEmail, String poaEmail, String hDoneBy) {
        if(recId != null) {
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String frmsrc = '/apex/HandoverWelcomeLetter?id='+recId;
            PageReference p1 = new PageReference(frmsrc);
            blob content;
            if(Test.isRunningTest()) { 
                content = blob.valueOf('Unit.Test');
            } else {
                content = p1.getContentAsPDF();
            }

            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest()) {
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
            }
            System.debug(content);
            mail.setSubject('Welcome to Your New Home: A Heartfelt Congratulations');
            mail.setplaintextbody('Dear '+customerName+',\n\nWarm greetings from Sobha LLC! We are absolutely delighted to extend our warmest congratulations to you on the successful completion of your property\'s handover.\n\nIt brings us immense joy to officially welcome you to your new home. This moment marks the culmination of months of hard work, dedication, and anticipation. Your property is now more than just a construction; it\'s a place where memories will be created, dreams will be realized, and milestones will be celebrated.\n\nWe trust that you\'ll find every corner of your new home meticulously crafted to reflect our commitment to quality, design, and comfort. It\'s now your canvas to make uniquely yours, and we\'re thrilled to be a part of your journey.\n\nAs you settle in, we\'re here to assist you with any questions or needs you may have. Our customer support team is available to address any inquiries or offer guidance.\n\nWe hope your time here is filled with joy, warmth, and the fulfillment of cherished aspirations. Once again, welcome to your new home, and thank you for choosing Sobha LLC to be a part of this special chapter in your life.\n\nWishing you countless happy moments ahead.\n\n\nWarm regards,\nSobha LLC');
            mail.setToAddresses(new List<String>{customerEmail});
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            if(hDoneBy == 'POA' && poaEmail != null) {
                mail.setCcAddresses(new List<String>{poaEmail});   
            }
            
            Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
            efa1.setFileName('Handover Welcome Letter.pdf');
            efa1.setBody(content);   
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
            System.debug(mail);
            emailList.add(mail);
            
            System.debug(emailList);
            try{
                if(emailList != null && emailList.size()>0 ) {
                    System.debug(emailList);
                    Messaging.sendEmail(emailList);
                    EmailMessage newEmail = new EmailMessage();
                    newEmail.ToAddress = customerEmail;
                    newEmail.Subject = 'Welcome to Your New Home: A Heartfelt Congratulations';
                    newEmail.TextBody = mail.getPlainTextBody();
                    newEmail.RelatedToId = recId;
                    newEmail.Status = '3';
                    if(hDoneBy == 'POA' && poaEmail != null) {
                        newEmail.CcAddress = poaEmail;   
                    }
                    insert newEmail;
                }
            }catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
    
    //Added by Deepak sharma to show error on creation of Title Deed record on some conditions on Aug'10 2023
    public static void showErrorForTitleDeedRecord(List<PropStrength__Transaction_Requests__c> newTrList) {
        Set<Id> bookingId = new Set<Id>();
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newTrList) {
            if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null) {
                bookingId.add(tr.PropStrength__Application_Booking__c);
            }
        }
        
        if(!bookingId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Total_Paid_Percent__c, Title_Deed_Process_Exception__c, SPA_Executed__c, Pre_Registration_Completed__c, Handover_Completed__c, Title_Deed_Fees_Received__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]);
            if(!bookingMap.isEmpty()) {
                for(PropStrength__Transaction_Requests__c tr : newTrList) {
                    if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && bookingMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        PropStrength__Application_Booking__c book = bookingMap.get(tr.PropStrength__Application_Booking__c);
                        if(!(book.Title_Deed_Process_Exception__c || (book.PropStrength__Total_Paid_Percent__c >= 100 && book.SPA_Executed__c && book.Pre_Registration_Completed__c && book.Handover_Completed__c && book.Title_Deed_Fees_Received__c != null))) {
                            tr.addError('The Title Deed Transaction cannot be processed as the initial conditions are not met.');
                        }
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma to show error on creation of Transfer Of Property record on some conditions on Sep'14 2023
    /*public static void showErrorForTransferOfPropertyRecord(List<PropStrength__Transaction_Requests__c> newTrList) {
        Set<Id> bookingId = new Set<Id>();
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newTrList) {
            if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null) {
                bookingId.add(tr.PropStrength__Application_Booking__c);
            }
        }
        
        if(!bookingId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Total_Paid_Percent__c, PCC_Status__c, PCC_Document_Approved__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]);
            if(!bookingMap.isEmpty()) {
                for(PropStrength__Transaction_Requests__c tr : newTrList) {
                    if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && bookingMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        PropStrength__Application_Booking__c book = bookingMap.get(tr.PropStrength__Application_Booking__c);
                        if(!Test.isRunningTest() && book.PropStrength__Total_Paid_Percent__c < 40 && tr.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer') {
                            tr.addError('Record cannot create because Total paid percent is less than 40%');
                        }
                        if(!Test.isRunningTest() && book.PCC_Status__c != 'PCC Approved' && !book.PCC_Document_Approved__c && tr.PropStrength__Customer_Transfer_Type__c == 'Title Transfer') {
                            tr.addError('PCC is not approved');
                        }
                    }
                }
            }
        }
    }*/
    
    
    //Added by Deepak sharma to create task for title deed record type on Aug'10 2023
    public static void createTaskForTitleDeed(List<PropStrength__Transaction_Requests__c> newTrList) {
        Set<Id> bookingId = new Set<Id>();
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newTrList) {
            if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null) {
                bookingId.add(tr.PropStrength__Application_Booking__c);
            }
        }
        
        List<Task> tasksToInsert = new List<Task>();
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        List<PropStrength__Transaction_Requests__c> trList1 = new List<PropStrength__Transaction_Requests__c>();
        if(!bookingId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, CRM_Executive__c, PropStrength__Project__r.DLD_Executive__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]);
            if(!bookingMap.isEmpty()) {
                for(PropStrength__Transaction_Requests__c tr : newTrList) {
                    if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && bookingMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        PropStrength__Application_Booking__c book = bookingMap.get(tr.PropStrength__Application_Booking__c);
                        if(book.PropStrength__Project__r.DLD_Executive__c != null) {
                            Task newTask = new Task(
                                Subject = 'Generate DSR and Upload the DSR Procedure number',
                                Description = 'Generate DSR and Upload the DSR Procedure number',
                                WhatId = tr.Id,
                                OwnerId = book.PropStrength__Project__r.DLD_Executive__c,
                                ActivityDate = Date.today().addDays(1)
                            );
                            tasksToInsert.add(newTask);
                            //trList.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, DSR_Generation_Requested_from_DLD_Team__c = TRUE));
                        }
                        /*if(book.CRM_Executive__c != null) {
                            Task newTask1 = new Task(
                                Subject = 'Send DSR for Digital Signature',
                                Description = 'Send DSR for Digital Signature',
                                WhatId = tr.Id,
                                OwnerId = book.CRM_Executive__c,
                                ActivityDate = Date.today().addDays(1)
                            );
                            tasksToInsert.add(newTask1);
                            trList1.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, DSR_Signing_Requested_from_CRM_Team__c = TRUE));
                        }*/
                    }
                }
            }
            if(!tasksToInsert.isEmpty()) {
                insert tasksToInsert;
            }
            if(!trList.isEmpty()) {
                update trList;
            }
            if(!trList1.isEmpty()) {
                update trList1;
            }
        }
    }
    
    //Added by Deepak sharma to create task for title deed on record type for the status audit approved on Aug'10 2023
    public static void createTaskForTitleDeedAudit(List<PropStrength__Transaction_Requests__c> newTrList, Map<Id, PropStrength__Transaction_Requests__c> oldMapTR) {
        Set<Id> trId = new Set<Id>();
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newTrList) {
            if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && tr.PropStrength__Status__c == 'Audit Approved' && tr.PropStrength__Status__c != oldMapTr.get(tr.Id).PropStrength__Status__c) {
                trId.add(tr.Id);
            }
        }
        
        List<Task> tasksToInsert = new List<Task>();
        if(!trId.isEmpty()) {
            List<PropStrength__Transaction_Requests__c> trList = [SELECT Id, PropStrength__Application_Booking__r.CRM_Executive__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trId];
            for(PropStrength__Transaction_Requests__c tr : trList) {
                Task newTask = new Task(
                    Subject = 'Download DSR and get it signed by the Authorized Signatory',
                    Description = 'Download DSR and get it signed by the Authorized Signatory',
                    WhatId = tr.Id,
                    OwnerId = tr.PropStrength__Application_Booking__r.CRM_Executive__c,
                    ActivityDate = Date.today().addDays(1)
                );
                tasksToInsert.add(newTask);
            }
            if(!tasksToInsert.isEmpty()) {
                insert tasksToInsert;
            }
        }
    }
    
    //Added by Deepak sharma to create task for title deed on record type for the status audit approved on Aug'10 2023
    public static void createTaskForTitleDeedDSRCB(List<PropStrength__Transaction_Requests__c> newTrList, Map<Id, PropStrength__Transaction_Requests__c> oldMapTR) {
        Set<Id> trId = new Set<Id>();
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newTrList) {
            if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && tr.DSR_Submitted_to_DLD__c && tr.DSR_Submitted_to_DLD__c != oldMapTr.get(tr.Id).DSR_Submitted_to_DLD__c) {
                trId.add(tr.Id);
            }
        }
        
        List<Task> tasksToInsert = new List<Task>();
        List<PropStrength__Application_Booking__c> bookList = new List<PropStrength__Application_Booking__c>();
        if(!trId.isEmpty()) {
            List<PropStrength__Transaction_Requests__c> trList = [SELECT Id, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trId];
            for(PropStrength__Transaction_Requests__c tr : trList) {
                Task newTask = new Task(
                    Subject = 'Generate Title Deed and Upload',
                    Description = 'Generate Title Deed and Upload',
                    WhatId = tr.Id,
                    OwnerId = tr.PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__c,
                    ActivityDate = Date.today().addDays(1)
                );
                tasksToInsert.add(newTask);
                bookList.add(new PropStrength__Application_Booking__c(Id = tr.PropStrength__Application_Booking__c, Title_Deed_Reminder_24_Hr__c = System.Today().addDays(1)));
            }
            if(!tasksToInsert.isEmpty()) {
                insert tasksToInsert;
            }
            if(!bookList.isEmpty()) {
                update bookList;
            }
        }
    }

    //Added by Nishank Manwani to update Title Deed Reminder 48 Hours on 15-May-2024
    public static void changeTitleDeed48(List<PropStrength__Transaction_Requests__c> newTrList, Map<Id, PropStrength__Transaction_Requests__c> oldMapTR) {
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newTrList) {
            if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && tr.DSR_Signing_Requested_from_CRM_Team__c && !tr.Customer_Signed_DSR_Uploaded__c && tr.DSR_Signing_Requested_from_CRM_Team__c != oldMapTr.get(tr.Id).DSR_Signing_Requested_from_CRM_Team__c) {
                tr.Title_Deed_Reminder_48_Hours__c = System.Today();
            } else if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && tr.DSR_Signing_Requested_from_CRM_Team__c && tr.Customer_Signed_DSR_Uploaded__c && tr.Customer_Signed_DSR_Uploaded__c != oldMapTr.get(tr.Id).Customer_Signed_DSR_Uploaded__c) {
                tr.Title_Deed_Reminder_48_Hours__c = null;
            }
        }
    }
    
    //Added by Deepak sharma to add validation on Title Deed Uploaded Checkbox on Aug'10 2023
    public static void errorOnTitleDeedCB(List<PropStrength__Transaction_Requests__c> newTrList, Map<Id, PropStrength__Transaction_Requests__c> oldMapTR) {
        Set<Id> trId = new Set<Id>();
        Set<Id> bookId = new Set<Id>();
        list<PropStrength__Applicant_Detail__c> DetailLst = new list<PropStrength__Applicant_Detail__c>();
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c();
        PropStrength__Applicant_Detail__c appDetailSec = new PropStrength__Applicant_Detail__c();
        PropStrength__Applicant_Detail__c appDetailThir = new PropStrength__Applicant_Detail__c();
        PropStrength__Applicant_Detail__c appDetailForth = new PropStrength__Applicant_Detail__c();
        PropStrength__Applicant_Detail__c appDetailFifth = new PropStrength__Applicant_Detail__c();
        String aplicant1;
        String aplicant2;
        String aplicant3;
        String aplicant4;
        String aplicant5;
        
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newTrList) {
            if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && tr.Title_Deed_Uploaded__c && tr.Title_Deed_Uploaded__c != oldMapTr.get(tr.Id).Title_Deed_Uploaded__c) {
                trId.add(tr.Id);
                bookId.add(tr.PropStrength__Application_Booking__c);
            }
        }
        if(bookId != null){
            DetailLst = [Select id, Name,PropStrength__Applicant_Acc__r.Salutation,PropStrength__Account_Name__c,PropStrength__Applicant_Acc__r.Name,PropStrength__Applicant_Acc__r.FirstName,PropStrength__Applicant_Acc__r.Mailing_City__c  ,PropStrength__Applicant_Acc__r.MailingStreet, PropStrength__Applicant_Acc__r.MailingCity, PropStrength__Applicant_Acc__r.MailingState,PropStrength__Applicant_Acc__r.PropStrength__Account_Type__c,
                         PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Active__c,PropStrength__Applicant_Acc__r.MailingCountry, PropStrength__Applicant_Acc__r.MailingPostalCode From PropStrength__Applicant_Detail__c Where PropStrength__Application__c =: bookId AND PropStrength__Active__c=true];
            
            if(DetailLst != null && DetailLst.size()>0){
                for(PropStrength__Applicant_Detail__c app : DetailLst){
                    
                    if(app.PropStrength__Type__c == '1st Applicant' && app.PropStrength__Active__c ==True){
                        appDetail = app;
                    }
                    if(app.PropStrength__Type__c == '2nd Applicant' && app.PropStrength__Active__c ==True){
                        appDetailSec = app;
                    }                
                    if(app.PropStrength__Type__c == '3rd Applicant' && app.PropStrength__Active__c ==True){
                        appDetailThir = app;
                    }
                    if(app.PropStrength__Type__c == '4th Applicant' && app.PropStrength__Active__c ==True){
                        appDetailForth = app;
                    }
                    if(app.PropStrength__Type__c == '5th Applicant' && app.PropStrength__Active__c ==True){
                        appDetailFifth = app;
                    }
                }
            } 
            
            aplicant1 = appDetail.PropStrength__Applicant_Acc__r.Name != null ? appDetail.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetail.PropStrength__Applicant_Acc__r.Name : '';
                
            aplicant2 = appDetailSec.PropStrength__Applicant_Acc__r.Name != null ? ' & ' + appDetailSec.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetailSec.PropStrength__Applicant_Acc__r.Name : '';
            
            aplicant3 = appDetailThir.PropStrength__Applicant_Acc__r.Name != null ? ' & ' + appDetailThir.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetailThir.PropStrength__Applicant_Acc__r.Name : '';
            
            aplicant4 = appDetailForth.PropStrength__Applicant_Acc__r.Name != null ? ' & ' + appDetailForth.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetailForth.PropStrength__Applicant_Acc__r.Name : '';
            
            aplicant5 = appDetailFifth.PropStrength__Applicant_Acc__r.Name != null ? ' & ' + appDetailFifth.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetailFifth.PropStrength__Applicant_Acc__r.Name : '';
        }
        
        if(!trId.isEmpty()) {
            Map<Id, PropStrength__Transaction_Requests__c> trList = new Map<Id, PropStrength__Transaction_Requests__c>([SELECT Id, PropStrength__Application_Booking__r.CRM_Executive__c, (SELECT Id, Name FROM Attachments) FROM PropStrength__Transaction_Requests__c WHERE Id IN :trId]);
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Primary_Applicant_Name__c,PropStrength__Property_Name__c,PropStrength__Project__r.name, (SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r) FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            Set<Id> attachId = new Set<Id>();
            for(PropStrength__Transaction_Requests__c tr : trList.values()){
                if(!tr.Attachments.isEmpty()) {
                    for(Attachment att : tr.Attachments) {
                        attachId.add(att.Id);
                    }
                }
            }

            Map<Id,ContentVersion> attachmentMap = new Map<Id,ContentVersion>();
            List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :trId];
            if(!contDocLinks.isEmpty()) {
                List<ContentDocument> documents = [SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id = :contDocLinks[0].ContentDocumentId AND Title LIKE :'%Title Deed%' ORDER BY CreatedDate DESC LIMIT 1];
                if(!documents.isEmpty()) {
                    List<ContentVersion> contentVersions = [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId = :documents[0].Id];
                    if(!contentVersions.isEmpty()) {
                        attachmentMap.put(contDocLinks[0].LinkedEntityId,contentVersions[0]);
                    }
                }
            }

            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest()) {
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
            }

            List<EmailMessage> emailLst = new List<EmailMessage>();
            Map<Id, PropStrength__Application_Booking__c> bookUpList = new Map<Id, PropStrength__Application_Booking__c>();
            Map<Id, Attachment> attmap = new Map<Id,Attachment>([SELECT Id, Name, Body, ContentType FROM Attachment WHERE Id IN :attachId]);
            for(PropStrength__Transaction_Requests__c tr : newTrList) {
                if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && tr.Title_Deed_Uploaded__c && tr.Title_Deed_Uploaded__c != oldMapTr.get(tr.Id).Title_Deed_Uploaded__c) {
                    if(trList.get(tr.Id).Attachments.isEmpty() && attachmentMap.isEmpty()) {
                        tr.addError('Please upload the \'Title Deed Document\' in the \'Notes & Attachments\'');
                    } else {
                        List<String> toAddList = new List<String>();
                        String toAddStr = '';
                        for(PropStrength__Applicant_Detail__c appDetailvar : bookMap.get(trList.get(tr.Id).PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r) {
                            if(appDetailvar.PropStrength__Applicant_Email__c != null) {
                                toAddList.add(appDetailvar.PropStrength__Applicant_Email__c);
                                toAddStr += appDetailvar.PropStrength__Applicant_Email__c + ',';
                            }
                        } 

                        if(!toAddList.isEmpty()) {
                            List<EmailTemplate> templatelist = [SELECT id,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Title_Deed_Completed' limit 1];
                
                            Id TempId;
                            if(!templatelist.isEmpty()) {
                                TempId = templatelist[0].id;
                            }
                            
                            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                               // mail.setSubject('Title Deed Completed – UNIT '+bookMap.get(trList.get(tr.Id).PropStrength__Application_Booking__c).PropStrength__Property_Name__c+' '+bookMap.get(trList.get(tr.Id).PropStrength__Application_Booking__c).PropStrength__Project__r.name+'');
                               // mail.setplaintextbody('Dear '+bookMap.get(trList.get(tr.Id).PropStrength__Application_Booking__c).PropStrength__Primary_Applicant_Name__c+',\n\n\nWe are pleased to inform you that the Title Deed for your property is now ready for your records. This important document signifies your ownership of the property and is a testament to the successful partnership between you and Sobha LLC.\n\nTo access your Title Deed, please find the attached PDF file. If you have any questions or require further assistance, please don\'t hesitate to reach out to our customer support team. We\'re here to help.\n\nThank you for choosing Sobha LLC as your real estate partner. We value your trust and look forward to continuing to serve you in the future.\n\n\nBest regards,\nSobha LLC');
                                mail.setToAddresses(toAddList);

                                if (owea.size() > 0) {
                                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                                }
                                
                                if(trList.get(tr.Id).PropStrength__Application_Booking__r.CRM_Executive__c != null) {
                                    mail.setCcAddresses(new List<String>{trList.get(tr.Id).PropStrength__Application_Booking__r.CRM_Executive__c});   
                                }
                                mail.setTemplateId(TempId);
                                mail.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
                                mail.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                                if(!attMap.isEmpty()) {
                                    efa1.setFileName(attMap.get(trList.get(tr.Id).Attachments[0].Id).Name);
                                    efa1.setBody(attMap.get(trList.get(tr.Id).Attachments[0].Id).Body); 
                                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                                }
                                if(!attachmentMap.isEmpty()) {
                                    if(attachmentMap.containskey(tr.Id)){
                                        ContentVersion att = attachmentMap.get(tr.Id);
                                        if(att.Title.contains('Title Deed')) {
                                            efa1.setFileName(attachmentMap.get(tr.Id).Title + '.' + attachmentMap.get(tr.Id).FileExtension);
                                            efa1.setBody(attachmentMap.get(tr.Id).VersionData); 
                                            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                                        }
                                    }
                                }
                                mail.setWhatId(tr.Id);
                                mail.setTargetObjectId(tr.CreatedById);
                                mail.saveAsActivity = false; 
                                System.debug(mail);
                                emailList.add(mail); 
                            
                            System.debug(emailList);
                            try{
                                if(emailList != null && emailList.size()>0 ) {
                                    System.debug(emailList);
                                    Messaging.sendEmail(emailList);
                                    EmailMessage newEmail = new EmailMessage();
                                    newEmail.ToAddress = toAddStr.substring(0, toAddStr.length()-1);
                                    newEmail.Subject = 'Title Deed Completed – UNIT '+bookMap.get(trList.get(tr.Id).PropStrength__Application_Booking__c).PropStrength__Property_Name__c+' '+bookMap.get(trList.get(tr.Id).PropStrength__Application_Booking__c).PropStrength__Project__r.name+'';
                                    //newEmail.TextBody = mail.getPlainTextBody();
                                    newEmail.RelatedToId = tr.Id;
                                    if(trList.get(tr.Id).PropStrength__Application_Booking__r.CRM_Executive__c != null) {
                                        newEmail.CcAddress = trList.get(tr.Id).PropStrength__Application_Booking__r.CRM_Executive__c;
                                    }
                                    newEmail.Status = '3';
                                    emailLst.add(newEmail);
                                    tr.PropStrength__Status__c='Title Deed Issued';
                                    if(!bookUpList.containsKey(tr.PropStrength__Application_Booking__c)) {
                                        bookUpList.put(tr.PropStrength__Application_Booking__c, new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c, Title_Deed_Transfer_Executed__c=TRUE, Title_Deed_Sent_Date__c = System.Now()));
                                    }
                                }
                            }catch(Exception ex){
                                system.debug('===========Exception ============'+ex.getmessage());
                                system.debug('===========Exception ============'+ex.getlinenumber());
                            }
                        }
                    }
                }
            }
            
            if(!emailLst.isEmpty()) {
                insert emailLst;
            }
            if(!bookUpList.isEmpty()) {
                update bookUpList.values();
            }
        }
    }
    
    //Added by Deepak sharma to send email to customer executive on Aug'10 2023
    public static void sendMailOnHandoverDocumentShared(List<PropStrength__Transaction_Requests__c> newList, Map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        Set<Id> trIds = new Set<Id>();
        Id recTypeTransfer = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Handover').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.RecordTypeId == recTypeTransfer && tr.Handover_Document_Shared__c && tr.Handover_Document_Shared__c != oldMap.get(tr.Id).Handover_Document_Shared__c) {
                trIds.add(tr.Id);
            }
        }
        
        if(!trIds.isEmpty()) {
            List<PropStrength__Transaction_Requests__c> trRecs = [SELECT Id, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Address__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.POA_Email_Address__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, Handover_to_be_done_by__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trIds];
            Set<Id> bookId = new Set<Id>();
            for(PropStrength__Transaction_Requests__c tr  :trRecs) {
                if(tr.PropStrength__Application_Booking__c != null) {
                    bookId.add(tr.PropStrength__Application_Booking__c);
                }
            }
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r) FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            for(PropStrength__Transaction_Requests__c tr  :trRecs) {
                if(bookMap.containsKey(tr.PropStrength__Application_Booking__c) && !bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appDetail : bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r) {
                        TransactionRequestTriggerHelper.mailHandoverWelcomeLetterEmail(tr.Id, appDetail.PropStrength__Customer_Name__c, appDetail.PropStrength__Applicant_Email__c, tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Address__c);   
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma to send email to customer executive on Aug'10 2023
    public static void sendMailOnUndertakingDocumentsShared(List<PropStrength__Transaction_Requests__c> newList, Map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        Set<Id> trIds = new Set<Id>();
        Id recTypeTransfer = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Handover').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.RecordTypeId == recTypeTransfer && tr.Undertaking_Documents_Shared__c && tr.Undertaking_Documents_Shared__c != oldMap.get(tr.Id).Undertaking_Documents_Shared__c) {
                trIds.add(tr.Id);
            }
        }
        
        if(!trIds.isEmpty()) {
            List<PropStrength__Transaction_Requests__c> trRecs = [SELECT Id, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.POA_Email_Address__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, Handover_to_be_done_by__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trIds];
            Set<Id> bookId = new Set<Id>();
            for(PropStrength__Transaction_Requests__c tr  :trRecs) {
                if(tr.PropStrength__Application_Booking__c != null) {
                    bookId.add(tr.PropStrength__Application_Booking__c);
                }
            }
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r) FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            for(PropStrength__Transaction_Requests__c tr  :trRecs) {
                if(bookMap.containsKey(tr.PropStrength__Application_Booking__c) && !bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appDetail : bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r) {
                        TransactionRequestTriggerHelper.mailUndertakingDocumentsSharedEmail(tr.Id, appDetail.PropStrength__Customer_Name__c, appDetail.PropStrength__Applicant_Email__c);   
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma to send email to customer on Aug'10 2023
    @future(callout=true)
    public static void mailHandoverWelcomeLetterEmail(String recId, String customerName, String customerEmail, String propAddress) {
        if(recId != null) {
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if( !test.isrunningtest()) {
                    owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
                }
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String frmsrc = '/apex/HandoverDocument?id='+recId;
                PageReference p1 = new PageReference(frmsrc);
                blob content;
                if(Test.isRunningTest()) { 
                    content = blob.valueOf('Unit.Test');
                } else {
                    content = p1.getContentAsPDF();
                }
                System.debug(content);
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                mail.setSubject('Property Handover Document');
                mail.setplaintextbody('Dear '+customerName+',\n\nI hope this message finds you well. It is with pleasure that we share the property handover document for the property at '+propAddress+'. This document outlines the details of the property\'s condition and marks the successful completion of the handover process.Kindly find the attached Property Handover Document. We kindly ask that you carefully review the document to ensure that all information is accurate and satisfactory. If you have any questions or require any further assistance, please don\'t hesitate to get in touch with us.\n\nOnce you have reviewed the document and are satisfied with the details, please respond to this email to confirm your acceptance of the handover. This step is essential for finalizing the process and updating our records accordingly.\n\nThank you for choosing SOBHA LLC for your property journey. We look forward to serving you in the future.\n\n\nBest regards,\nSOBHA LLC');
                mail.setToAddresses(new List<String>{customerEmail});
                
                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setFileName('Handover Document.pdf');
                efa1.setBody(content);   
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                System.debug(mail);
                emailList.add(mail);
                
                System.debug(emailList);
                try{
                    if(emailList != null && emailList.size()>0 ) {
                        System.debug(emailList);
                        Messaging.sendEmail(emailList);
                        EmailMessage newEmail = new EmailMessage();
                        newEmail.ToAddress = customerEmail;
                        newEmail.Subject = 'Handover Document';
                        newEmail.TextBody = mail.getPlainTextBody();
                        newEmail.RelatedToId = recId;
                        newEmail.Status = '3';
                        insert newEmail;
                    }
                }catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
        }
    }
    
    //Added by Deepak sharma to send email to customer on Aug'10 2023
    @future(callout=true)
    public static void mailUndertakingDocumentsSharedEmail(String recId, String customerName, String customerEmail) {
        if(recId != null) {
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest()) {
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
            }
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String frmsrc = '/apex/UndertakingDocuments?id='+recId;
            PageReference p1 = new PageReference(frmsrc);
            blob content;
            if(Test.isRunningTest()) { 
                content = blob.valueOf('Unit.Test');
            } else {
                content = p1.getContentAsPDF();
            }
            System.debug(content);
            mail.setSubject('Important: Undertaking Document');
            mail.setplaintextbody('Dear '+customerName+',\n\nI trust this email finds you well. We are excited to share with you the undertaking document for your property. This document outlines the terms and conditions of your ownership, ensuring a clear and smooth transition.\n\nPlease find the attached Undertaking Document. Kindly review it at your earliest convenience. If you have any questions or require further clarification, please feel free to reach out to us.\n\nOnce you have reviewed the document and are ready to proceed, please confirm your acceptance by replying to this email. Your prompt action will enable us to move forward with the necessary formalities swiftly.\n\nThank you for choosing SOBHA LLC.  for your property needs. We look forward to assisting you throughout this process.\n\n\nBest regards,\nSobha LLC');
            mail.setToAddresses(new List<String>{customerEmail});
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            
            Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
            efa1.setFileName('Undertaking Document.pdf');
            efa1.setBody(content);   
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
            System.debug(mail);
            emailList.add(mail);
            
            System.debug(emailList);
            try{
                if(emailList != null && emailList.size()>0 ) {
                    System.debug(emailList);
                    Messaging.sendEmail(emailList);
                    EmailMessage newEmail = new EmailMessage();
                    newEmail.ToAddress = customerEmail;
                    newEmail.Subject = 'Undertaking Document';
                    newEmail.TextBody = mail.getPlainTextBody();
                    newEmail.RelatedToId = recId;
                    newEmail.Status = '3';
                    insert newEmail;
                }
            }catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
    
    //Added by Deepak sharma to send Demand Letter to Customer on Mortgage Process on Aug'21 2023
    public static void createIncChrgeDueForMortgage(List<PropStrength__Transaction_Requests__c> newList, Map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        List<PropStrength__Received_Payment__c> insertIncDue = new List<PropStrength__Received_Payment__c>();
        Id incChrDueRecId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        Set<Id> trId = new Set<Id>();
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.PropStrength__Status__c != oldMap.get(tr.Id).PropStrength__Status__c && tr.PropStrength__Status__c == 'Mortgage Fees Approved') {
                insertIncDue.add(new PropStrength__Received_Payment__c(PropStrength__Amount__c=tr.Mortgage_Fees__c, PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c, PropStrength__Demand_Generated__c=TRUE, PropStrength__Demand_Generated_By__c=UserInfo.getUserId(), PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c='Demand Generated', RecordTypeId=incChrDueRecId, PropStrength__Amount_Due_Type__c='Mortgage Fees', PropStrength__Payment_Date__c=System.Today(), PropStrength__Actual_Payment_Date__c=System.Today().addDays(15)));
            }
            
            if(tr.Mortgage_Fees_Received__c != oldMap.get(tr.Id).Mortgage_Fees_Received__c && tr.Mortgage_Fees_Received__c) {
                trId.add(tr.Id);
            }
        }
        
        if(!insertIncDue.isEmpty()) {
            insert insertIncDue;
            Set<Id> incId = new Set<Id>();
            for(PropStrength__Received_Payment__c pay : insertIncDue) {
                incId.add(pay.Id);
            }
            TransactionRequestTriggerHelper.sendDemandEmail(incId);
        }
        
        if(!trId.isEmpty()) {
            List<PropStrength__Transaction_Requests__c> trList = [SELECT Id, PropStrength__Application_Booking__r.PropStrength__Property_Name__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__r.Email, PropStrength__Application_Booking__r.PropStrength__Project__r.Accounts_Executive__r.Email FROM PropStrength__Transaction_Requests__c WHERE Id IN :trId];
            
            for(PropStrength__Transaction_Requests__c tr : trList) {
                TransactionRequestTriggerHelper.sendMailToDLD(tr.Id, tr.PropStrength__Application_Booking__r.PropStrength__Property_Name__c, tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, tr.PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__r.Email, tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Accounts_Executive__r.Email);
            }
        }
    }
    
    //Added by Deepak sharma to send Demand Letter in mail to customer on Aug'21 2023
    @Future(Callout=True)
    public static void sendDemandEmail(Set<Id> payIdset) {
        List<PropStrength__Received_Payment__c> updatePaymentList = new List<PropStrength__Received_Payment__c>();
        system.debug('finish::'+payIdset);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<Attachment> insertList = new List<Attachment>();
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        if(!payIdset.isEmpty()) {
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest()) {
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
            }

            List<PropStrength__Received_Payment__c> paymentList = [SELECT Id,PropStrength__Payment_Date__c,PropStrength__Application_Booking__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__r.PropStrength__Grace_Days__c, RecordType.Name
                                                                   FROM PropStrength__Received_Payment__c
                                                                   WHERE Id IN: payIdset];
            if(!paymentList.isEmpty()) {
                for(PropStrength__Received_Payment__c pay : paymentList) {
                    bookingIds.add(pay.PropStrength__Application_Booking__c);
                }
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                                                                           if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                                                                               List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                                                                               newPLI.add(appLicant);
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                                                                           } else {
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                                                                           }
                                                                       }
                }
                if(!applicantListMap.isEmpty()) {
                    for(PropStrength__Received_Payment__c pay : paymentList) {
                        PageReference pdf = Page.TransferChargeNotice;
                       
                        if (pdf != null) {
                            pdf.getParameters().put('id', pay.Id); // Replace 'id' with the actual parameter name
                        }
                  
                        Blob b;
                        if(Test.isRunningTest()) {
                            b = Blob.valueOf('test');
                        } else {
                            b = pdf.getContent();
                        }
                        Attachment att = new Attachment();
                        att.ParentId = pay.Id;
                        att.Name = 'TransferChargeNotice.pdf';
                        att.Body = b;
                        insertList.add(att);
                    }
                    if(!insertList.isEmpty()) {
                        insert insertList;
                        system.debug('insertList::'+insertList);
                        for(Attachment oneAtt : insertList) {
                            if(attachmentMap.containskey(oneAtt.ParentId)) {
                                List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                                newPLI.add(oneAtt);
                                attachmentMap.put(oneAtt.ParentId, newPLI);
                            } else {
                                attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                            }
                        }
                    }
                    if(!attachmentMap.isEmpty()) {
                        system.debug('attachmentMap::'+attachmentMap);
                        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                             FROM EmailTemplate 
                                                             WHERE DeveloperName =: 'Demand_Letter_Mortgage'];
                        String tempId = '';
                        if(emailTemplate.size() > 0){
                           tempId = emailTemplate[0].Id;
                        }
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
                            if(applicantListMap.containskey(ppd.PropStrength__Application_Booking__c)){
                                for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.PropStrength__Application_Booking__c)) {
                                    if(applicant.PropStrength__Type__c == '1st Applicant') {
                                        sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                    if(applicant.PropStrength__Type__c != '1st Applicant') {
                                        ccList.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                }
                            }
                        }
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            if(!sendTo.isEmpty()) {
                                email.setToAddresses(sendTo);
                            }
                            if(!ccList.isEmpty()) {
                                email.setCcAddresses(ccList);
                            }
                            email.setWhatId(ppd.id);
                            email.setTargetObjectId(ppd.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                            email.setTreatTargetObjectAsRecipient(False);
                            email.saveAsActivity = true;
                            if(String.isNotBlank(tempId))
                                email.setTemplateId(tempId);
                            if (owea.size() > 0) {
                                email.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            if(attachmentMap.containskey(ppd.Id)){
                                for(Attachment att : attachmentMap.get(ppd.Id)) {
                                    if(att.Name == 'TransferChargeNotice.pdf') {
                                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                        efa.setFileName('TransferChargeNotice.pdf');
                                        efa.setBody(att.Body);
                                        efalst.add(efa);
                                    }
                                    if(!efalst.isEmpty()) {
                                        email.setFileAttachments(efalst);
                                    }
                                }
                            }
                            mails.add(email); 
                        }
                        try {
                            if(!mails.isEmpty()){
                                Messaging.sendEmail(mails);
                            }
                        } catch(Exception e){
                            System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                            System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                        }
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma to send email to customer on Aug'21 2023
    @future(callout=true)
    public static void sendMailToDLD(String recId, String propertyName, String primaryCustName, String customerEmail, String accExeEmail) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setSubject('Mortgage Fees Received Notification');
        mail.setplaintextbody('Dear DLD Executive,\n\nThis is to bring to your notice that the Mortgage Fee has been received for the Customer '+primaryCustName+' for the Property '+propertyName+'.\nRequest you to please do the needful.\n\n\nBest Regards\nCRM Team');
        mail.setToAddresses(new List<String>{customerEmail, accExeEmail});
        emailList.add(mail);
        
        System.debug(emailList);
        try{
            if(emailList != null && emailList.size()>0 ) {
                System.debug(emailList);
                Messaging.sendEmail(emailList);
                EmailMessage newEmail = new EmailMessage();
                newEmail.ToAddress = customerEmail;
                newEmail.Subject = 'Mortgage Fees Received Notification';
                newEmail.TextBody = mail.getPlainTextBody();
                newEmail.RelatedToId = recId;
                newEmail.Status = '3';
                insert newEmail;
            }
        }catch(Exception ex){
            system.debug('===========Exception ============'+ex.getmessage());
            system.debug('===========Exception ============'+ex.getlinenumber());
        }
    }
    
    //Added by Deepak sharma to send Waiver Receipt to Customer on Aug'21 2023
    public static void sendMailOnWaiverTR(List<PropStrength__Transaction_Requests__c> newList, Map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        Id waiverTrRecId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Credit Waiver').getRecordTypeId();
        Set<Id> trId = new Set<Id>();
        
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.RecordTypeId == waiverTrRecId && tr.PropStrength__Status__c == 'Request Completed' && tr.PropStrength__Status__c != oldMap.get(tr.Id).PropStrength__Status__c) {
                trId.add(tr.Id);               
            }
        }
        
        if(!trId.isEmpty()) {
            TransactionRequestTriggerHelper.sendMailWaiver(trId);
        }
    }
    
    //Added by Deepak sharma to send Waiver Receipt to Customer on Aug'21 2023
    // public static void sendMailOnCreditNoteTR(List<PropStrength__Transaction_Requests__c> newList, Map<Id,PropStrength__Transaction_Requests__c> oldMap) {
    //     Id credNoteTrRecId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Credit Notes').getRecordTypeId();
    //     Set<Id> trId = new Set<Id>();
        
    //     for(PropStrength__Transaction_Requests__c tr : newList) {
    //         if(tr.PropStrength__Amount_Type__c == 'Amount' && tr.RecordTypeId == credNoteTrRecId && tr.PropStrength__Status__c == 'Request Completed' && tr.PropStrength__Status__c != oldMap.get(tr.Id).PropStrength__Status__c) {
    //          trId.add(tr.Id);               
    //         }
    //     }
        
    //     if(!trId.isEmpty()) {
    //         TransactionRequestTriggerHelper.sendMailCreditNote(trId);
    //     }
    // }
    
    //Added by Deepak sharma to send Waiver Receipt in mail to customer on Aug'21 2023
    @Future(Callout=True)
    public static void sendMailWaiver(Set<Id> payIdset) {
        List<PropStrength__Transaction_Requests__c> updatePaymentList = new List<PropStrength__Transaction_Requests__c>();
        system.debug('finish::'+payIdset);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<Attachment> insertList = new List<Attachment>();
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        if(!payIdset.isEmpty()) {
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest()) {
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
            }

            List<PropStrength__Transaction_Requests__c> paymentList = [SELECT Id,PropStrength__Application_Booking__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__c
                                                                   FROM PropStrength__Transaction_Requests__c
                                                                   WHERE Id IN: payIdset];
            if(!paymentList.isEmpty()) {
                for(PropStrength__Transaction_Requests__c pay : paymentList) {
                    bookingIds.add(pay.PropStrength__Application_Booking__c);
                }
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                                                                           if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                                                                               List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                                                                               newPLI.add(appLicant);
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                                                                           } else {
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                                                                           }
                                                                       }
                }
                if(!applicantListMap.isEmpty()) {
                    for(PropStrength__Transaction_Requests__c pay : paymentList) {
                        PageReference pdf = Page.WaiverReceiptPdf;
                       
                        if (pdf != null) {
                            pdf.getParameters().put('id', pay.Id); // Replace 'id' with the actual parameter name
                        }
                      
                        Blob b;
                        if(Test.isRunningTest()) {
                            b = Blob.valueOf('test');
                        } else {
                            b = pdf.getContent();
                        }
                        Attachment att = new Attachment();
                        att.ParentId = pay.Id;
                        att.Name = 'Waiver Receipt.pdf';
                        att.Body = b;
                        insertList.add(att);
                    }
                    if(!insertList.isEmpty()) {
                        insert insertList;
                        system.debug('insertList::'+insertList);
                        for(Attachment oneAtt : insertList) {
                            if(attachmentMap.containskey(oneAtt.ParentId)) {
                                List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                                newPLI.add(oneAtt);
                                attachmentMap.put(oneAtt.ParentId, newPLI);
                            } else {
                                attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                            }
                        }
                    }
                    if(!attachmentMap.isEmpty()) {
                        system.debug('attachmentMap::'+attachmentMap);
                        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                             FROM EmailTemplate 
                                                             WHERE DeveloperName =: 'Credit_Waiver'];
                        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                        for(PropStrength__Transaction_Requests__c ppd : paymentList) {
                            if(applicantListMap.containskey(ppd.PropStrength__Application_Booking__c)){
                                for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.PropStrength__Application_Booking__c)) {
                                    if(applicant.PropStrength__Type__c == '1st Applicant') {
                                        sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                    if(applicant.PropStrength__Type__c != '1st Applicant') {
                                        ccList.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                }
                            }
                        }
                        for(PropStrength__Transaction_Requests__c ppd : paymentList) {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            if(!sendTo.isEmpty()) {
                                email.setToAddresses(sendTo);
                            }
                            if(!ccList.isEmpty()) {
                                email.setCcAddresses(ccList);
                            }
                            if (owea.size() > 0) {
                                email.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            email.setWhatId(ppd.id);
                            email.setTargetObjectId(ppd.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                            email.setTreatTargetObjectAsRecipient(False);
                            email.saveAsActivity = true;
                            email.setTemplateId(tempId);
                            if(attachmentMap.containskey(ppd.Id)){
                                for(Attachment att : attachmentMap.get(ppd.Id)) {
                                    if(att.Name == 'Waiver Receipt.pdf') {
                                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                        efa.setFileName('Waiver Receipt.pdf');
                                        efa.setBody(att.Body);
                                        efalst.add(efa);
                                    }
                                    if(!efalst.isEmpty()) {
                                        email.setFileAttachments(efalst);
                                    }
                                }
                            }
                            mails.add(email); 
                        }
                        try {
                            if(!mails.isEmpty()){
                                Messaging.sendEmail(mails);
                            }
                        } catch(Exception e){
                            System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                            System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                        }
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma to send Waiver Receipt in mail to customer on Aug'21 2023
    // @Future(Callout=True)
    // public static void sendMailCreditNote(Set<Id> payIdset) {
    //     List<PropStrength__Transaction_Requests__c> updatePaymentList = new List<PropStrength__Transaction_Requests__c>();
    //     system.debug('finish::'+payIdset);
    //     List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    //     List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
    //     List<String> sendTo = new List<String>(); 
    //     List<String> ccList = new List<String>(); 
    //     List<Attachment> insertList = new List<Attachment>();
    //     Set<Id> bookingIds = new Set<Id>(); 
    //     Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
    //     Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
    //     if(!payIdset.isEmpty()) {
    //         List<PropStrength__Transaction_Requests__c> paymentList = [SELECT Id,PropStrength__Application_Booking__c,
    //                                                                PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
    //                                                                PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
    //                                                                PropStrength__Application_Booking__r.PropStrength__Project__c
    //                                                                FROM PropStrength__Transaction_Requests__c
    //                                                                WHERE Id IN: payIdset];
    //         if(!paymentList.isEmpty()) {
    //             for(PropStrength__Transaction_Requests__c pay : paymentList) {
    //                 bookingIds.add(pay.PropStrength__Application_Booking__c);
    //             }
    //             if(!bookingIds.isEmpty()) {
    //                 for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
    //                                                                    FROM PropStrength__Applicant_Detail__c 
    //                                                                    WHERE PropStrength__Application__c IN: bookingIds 
    //                                                                    AND PropStrength__Active__c =: true 
    //                                                                    AND PropStrength__Applicant_Acc__c != null]) {
    //                                                                        if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
    //                                                                            List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
    //                                                                            newPLI.add(appLicant);
    //                                                                            applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
    //                                                                        } else {
    //                                                                            applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
    //                                                                        }
    //                                                                    }
    //             }
    //             if(!applicantListMap.isEmpty()) {
    //                 for(PropStrength__Transaction_Requests__c pay : paymentList) {
    //                     PageReference pdf = Page.CreditNotePdf;
                       
    //                     if (pdf != null) {
    //                         pdf.getParameters().put('id', pay.Id); // Replace 'id' with the actual parameter name
    //                     }
    //                     Blob b = pdf.getContent();
    //                     Attachment att = new Attachment();
    //                     att.ParentId = pay.Id;
    //                     att.Name = 'Credit Note.pdf';
    //                     att.Body = b;
    //                     insertList.add(att);
    //                 }
    //                 if(!insertList.isEmpty()) {
    //                     insert insertList;
    //                     system.debug('insertList::'+insertList);
    //                     for(Attachment oneAtt : insertList) {
    //                         if(attachmentMap.containskey(oneAtt.ParentId)) {
    //                             List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
    //                             newPLI.add(oneAtt);
    //                             attachmentMap.put(oneAtt.ParentId, newPLI);
    //                         } else {
    //                             attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
    //                         }
    //                     }
    //                 }
    //                 if(!attachmentMap.isEmpty()) {
    //                     system.debug('attachmentMap::'+attachmentMap);
    //                     List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
    //                                                          FROM EmailTemplate 
    //                                                          WHERE DeveloperName =: 'Credit_Note'];
    //                     String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
    //                     for(PropStrength__Transaction_Requests__c ppd : paymentList) {
    //                         if(applicantListMap.containskey(ppd.PropStrength__Application_Booking__c)){
    //                             for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.PropStrength__Application_Booking__c)) {
    //                                 if(applicant.PropStrength__Type__c == '1st Applicant') {
    //                                     sendTo.add(applicant.PropStrength__Applicant_Email__c);
    //                                 }
    //                                 if(applicant.PropStrength__Type__c != '1st Applicant') {
    //                                     ccList.add(applicant.PropStrength__Applicant_Email__c);
    //                                 }
    //                             }
    //                         }
    //                     }
    //                     for(PropStrength__Transaction_Requests__c ppd : paymentList) {
    //                         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //                         if(!sendTo.isEmpty()) {
    //                             email.setToAddresses(sendTo);
    //                         }
    //                         if(!ccList.isEmpty()) {
    //                             email.setCcAddresses(ccList);
    //                         }
    //                         email.setWhatId(ppd.id);
    //                         email.setTargetObjectId(ppd.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
    //                         email.setTreatTargetObjectAsRecipient(False);
    //                         email.saveAsActivity = true;
    //                         email.setTemplateId(tempId);
    //                         if(attachmentMap.containskey(ppd.Id)){
    //                             for(Attachment att : attachmentMap.get(ppd.Id)) {
    //                                 if(att.Name == 'Credit Note.pdf') {
    //                                     Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    //                                     efa.setFileName('Credit Note.pdf');
    //                                     efa.setBody(att.Body);
    //                                     efalst.add(efa);
    //                                 }
    //                                 if(!efalst.isEmpty()) {
    //                                     email.setFileAttachments(efalst);
    //                                 }
    //                             }
    //                         }
    //                         mails.add(email); 
    //                     }
    //                     try {
    //                         if(!mails.isEmpty()){
    //                             Messaging.sendEmail(mails);
    //                         }
    //                     } catch(Exception e){
    //                         System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
    //                         System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }
    
    //Added by Deepak Sharma to submit for approval process when record type is Area change on 23-Aug-23
    public static void submitForAPForAreaChangeRT(List<PropStrength__Transaction_Requests__c> newList) {
        Id areaChangeRTId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Area Change').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.RecordTypeId == areaChangeRTId && tr.PropStrength__Adjustment_Method__c != null && tr.PropStrength__Status__c == null) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(tr.id);
                
                // Submit on behalf of a specific submitter
                req1.setSubmitterId(UserInfo.getUserId()); 
                
                // Submit the record to specific process and skip the criteria evaluation
                req1.setProcessDefinitionNameOrId('Area_Change_Approval');
                req1.setSkipEntryCriteria(true);
                
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
            }
        }
    }
    
    
    //Added by Deepak Sharma to inseri income charge sue record when record type is Change In Payment Pla and status is request completed on 23-Aug-23
    public static void sendMailForChangeInPaymentPlan(List<PropStrength__Transaction_Requests__c> newList, Map<Id,PropStrength__Transaction_Requests__c> oldMap) {
        Id chngeInPPRecType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Change In Payment Plan').getRecordTypeId();
        List<PropStrength__Received_Payment__c> insertIncDue = new List<PropStrength__Received_Payment__c>();
        Id incChrDueRecId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        Set<Id> trId = new Set<Id>();
        
        for(PropStrength__Transaction_Requests__c tr : newList) {
            if(tr.Transaction_Fee__c != null && tr.Transaction_Fee_Type__c != null && tr.Transaction_Fee_Type__c != '' && tr.RecordTypeId == chngeInPPRecType && tr.PropStrength__Status__c == 'Payment Plan Change:Payment Plan Approved,Update Milestones and Service Tax' && tr.PropStrength__Status__c != oldMap.get(tr.Id).PropStrength__Status__c) {
                trId.add(tr.Id);
            }
        }
        if(!trId.isEmpty()) {
            Map<Id, PropStrength__Transaction_Requests__c> trMap = new Map<Id, PropStrength__Transaction_Requests__c>([SELECT Id, PropStrength__Application_Booking__r.PropStrength__Revised_Total_Sales_Consideration__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trId]);
            for(PropStrength__Transaction_Requests__c tr : newList) {
                if(tr.Transaction_Fee__c != null && tr.Transaction_Fee_Type__c != null && tr.Transaction_Fee_Type__c != '' && tr.RecordTypeId == chngeInPPRecType && tr.PropStrength__Status__c == 'Payment Plan Change:Payment Plan Approved,Update Milestones and Service Tax' && tr.PropStrength__Status__c != oldMap.get(tr.Id).PropStrength__Status__c) {
                    if(tr.Transaction_Fee_Type__c == '%') {
                        insertIncDue.add(new PropStrength__Received_Payment__c(PropStrength__Amount__c=(trMap.get(tr.Id).PropStrength__Application_Booking__r.PropStrength__Revised_Total_Sales_Consideration__c*tr.Transaction_Fee__c)/100, PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c, PropStrength__Demand_Generated__c=TRUE, PropStrength__Demand_Generated_By__c=UserInfo.getUserId(), PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c='Demand Generated', RecordTypeId=incChrDueRecId, PropStrength__Amount_Due_Type__c='Change in PP Transaction Fees', PropStrength__Payment_Date__c=System.Today(), PropStrength__Actual_Payment_Date__c=System.Today().addDays(15)));   
                    } else {
                        insertIncDue.add(new PropStrength__Received_Payment__c(PropStrength__Amount__c=tr.Transaction_Fee__c, PropStrength__Application_Booking__c=tr.PropStrength__Application_Booking__c, PropStrength__Demand_Generated__c=TRUE, PropStrength__Demand_Generated_By__c=UserInfo.getUserId(), PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c='Demand Generated', RecordTypeId=incChrDueRecId, PropStrength__Amount_Due_Type__c='Change in PP Transaction Fees', PropStrength__Payment_Date__c=System.Today(), PropStrength__Actual_Payment_Date__c=System.Today().addDays(15)));   
                    }
                }
            }
            if(!insertIncDue.isEmpty()) {
                insert insertIncDue;
                Set<Id> incId = new Set<Id>();
                for(PropStrength__Received_Payment__c pay : insertIncDue) {
                    incId.add(pay.Id);
                }
                TransactionRequestTriggerHelper.sendDemandEmailChange(incId);
            }
        }
    }
    
    //Added by Deepak sharma to send Demand Letter in mail to customer on Aug'23 2023
    @Future(Callout=True)
    public static void sendDemandEmailChange(Set<Id> payIdset) {
        List<PropStrength__Received_Payment__c> updatePaymentList = new List<PropStrength__Received_Payment__c>();
        system.debug('finish::'+payIdset);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<Attachment> insertList = new List<Attachment>();
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        if(!payIdset.isEmpty()) {
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest()) {
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
            }
            List<PropStrength__Received_Payment__c> paymentList = [SELECT Id,PropStrength__Payment_Date__c,PropStrength__Application_Booking__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__r.PropStrength__Grace_Days__c, RecordType.Name
                                                                   FROM PropStrength__Received_Payment__c
                                                                   WHERE Id IN: payIdset];
            if(!paymentList.isEmpty()) {
                for(PropStrength__Received_Payment__c pay : paymentList) {
                    bookingIds.add(pay.PropStrength__Application_Booking__c);
                }
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                                                                           if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                                                                               List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                                                                               newPLI.add(appLicant);
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                                                                           } else {
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                                                                           }
                                                                       }
                }
                if(!applicantListMap.isEmpty()) {
                    for(PropStrength__Received_Payment__c pay : paymentList) {
                        PageReference pdf = Page.TransferChargeNotice;
                       
                        if (pdf != null) {
                            pdf.getParameters().put('id', pay.Id); // Replace 'id' with the actual parameter name
                        }
                        Blob b;
                        if(Test.isRunningTest()) {
                            b = Blob.valueOf('test');
                        } else {
                            b = pdf.getContent();
                        }
                        Attachment att = new Attachment();
                        att.ParentId = pay.Id;
                        att.Name = 'TransferChargeNotice.pdf';
                        att.Body = b;
                        insertList.add(att);
                    }
                    if(!insertList.isEmpty()) {
                        insert insertList;
                        system.debug('insertList::'+insertList);
                        for(Attachment oneAtt : insertList) {
                            if(attachmentMap.containskey(oneAtt.ParentId)) {
                                List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                                newPLI.add(oneAtt);
                                attachmentMap.put(oneAtt.ParentId, newPLI);
                            } else {
                                attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                            }
                        }
                    }
                    if(!attachmentMap.isEmpty()) {
                        system.debug('attachmentMap::'+attachmentMap);
                        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                             FROM EmailTemplate 
                                                             WHERE DeveloperName =: 'Demand_Letter_Change'];
                        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
                            if(applicantListMap.containskey(ppd.PropStrength__Application_Booking__c)){
                                for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.PropStrength__Application_Booking__c)) {
                                    if(applicant.PropStrength__Type__c == '1st Applicant') {
                                        sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                    if(applicant.PropStrength__Type__c != '1st Applicant') {
                                        ccList.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                }
                            }
                        }
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            if(!sendTo.isEmpty()) {
                                email.setToAddresses(sendTo);
                            }
                            if(!ccList.isEmpty()) {
                                email.setCcAddresses(ccList);
                            }
                            if (owea.size() > 0) {
                                email.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            email.setWhatId(ppd.id);
                            email.setTargetObjectId(ppd.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                            email.setTreatTargetObjectAsRecipient(False);
                            email.saveAsActivity = true;
                            email.setTemplateId(tempId);
                            if(attachmentMap.containskey(ppd.Id)){
                                for(Attachment att : attachmentMap.get(ppd.Id)) {
                                    if(att.Name == 'TransferChargeNotice.pdf') {
                                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                        efa.setFileName('TransferChargeNotice.pdf');
                                        efa.setBody(att.Body);
                                        efalst.add(efa);
                                    }
                                    if(!efalst.isEmpty()) {
                                        email.setFileAttachments(efalst);
                                    }
                                }
                            }
                            mails.add(email); 
                        }
                        try {
                            if(!mails.isEmpty()){
                                Messaging.sendEmail(mails);
                            }
                        } catch(Exception e){
                            System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                            System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                        }
                    }
                }
            }
        }
    }
    
    public static void updateTransactionStatus(List<PropStrength__Transaction_Requests__c> newList){
        Set<Id> transId = new Set<Id>();
        Set<Id> bookId = new Set<Id>();

        for(PropStrength__Transaction_Requests__c tranReq : newList){
            if(tranReq.PropStrength__Status__c == 'Transfer Letter Generated' && tranReq.Transfer_Assignment_Document_Signed__c)
                {
                    tranReq.PropStrength__Status__c = 'Transfer Letter Signed'; 
                }
            if(tranReq.PropStrength__Status__c == 'Transfer Letter Signed' && tranReq.Transfer_Assigment_Agreement_Uploaded__c)
                {
                    tranReq.PropStrength__Status__c = 'Transfer Letter Uploaded'; 
                }
            
            if(tranReq.PropStrength__Status__c == 'Transfer & Assignment Agreement Generated' && tranReq.Transfer_Assignment_Document_Signed__c)
                {
                    tranReq.PropStrength__Status__c = 'Transfer & Assignment Agreement Signed'; 
                }
            if(tranReq.PropStrength__Status__c == 'Transfer & Assignment Agreement Signed' && tranReq.Transfer_Assigment_Agreement_Uploaded__c)
                {
                    tranReq.PropStrength__Status__c = 'Transfer & Assignment Agreement Uploaded'; 
                }
            if((tranReq.PropStrength__Status__c == 'Transfer & Assignment Agreement Uploaded'|| tranReq.PropStrength__Status__c == 'Transfer Letter Uploaded') && tranReq.SPA_DSPA_Sent_to_New_Customer__c)
                {
                    tranReq.PropStrength__Status__c = 'SPA/DSPA Sent to New Customer'; 
                }
            if(tranReq.PropStrength__Status__c == 'NOC Generated' && tranReq.SPA_DSPA_Sent_to_New_Customer__c)
                {
                    //tranReq.PropStrength__Status__c = 'NOC Handed Over to Customer'; 
                }

                if(tranReq.PropStrength__Status__c == 'Transfer Letter Generated' && tranReq.Transfer_Letter_Signed__c)
                {
                    tranReq.PropStrength__Status__c = 'Transfer Letter Signed'; 
                }

                if(tranReq.PropStrength__Status__c == 'Transfer Letter Signed' && tranReq.Transfer_Letter_Uploaded__c)
                {
                    tranReq.PropStrength__Status__c = 'Transfer Letter Uploaded'; 
                }
                if(tranReq.PropStrength__Status__c == 'NOC Generated' && tranReq.NOC_Handed_Over_to_Customer__c)
                {
                    tranReq.PropStrength__Status__c = 'Request Completed'; 
                    transId.add(tranReq.Id);
                    bookId.add(tranReq.PropStrength__Application_Booking__c);
                }
        }

        if(!transId.isEmpty() && !bookId.isEmpty()) {
            TransactionRequestTriggerHelper.sendMailToCrmOnReqComp(transId, bookId);
        }
    }

    //Added by Deepak sharma to send email to CRM Executive on Request Completion on Nov'24 2023
    @future(callout=true)
    public static void sendMailToCrmOnReqComp(Set<Id> recordIds, Set<Id> bookingId) {
        if(!recordIds.isEmpty() && !bookingId.isEmpty()) {
            List<PropStrength__Transaction_Requests__c> transRecs = [SELECT Id, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c, 
                                                                        PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email 
                                                                        FROM PropStrength__Transaction_Requests__c WHERE Id IN :recordIds];
                                                    
            Map<Id, PropStrength__Application_Booking__c> bookRecs = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Customer_Name__c, PropStrength__Active__c FROM PropStrength__Applicant_Details__r ORDER BY PropStrength__Type__c) FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]); 
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<EmailMessage> activityList = new List<EmailMessage>();

            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest()) {
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
            }

            for(PropStrength__Transaction_Requests__c tr : transRecs) {
                String prevOwner = '';
                String newOwner = '';

                if(tr.PropStrength__Application_Booking__c != null && bookRecs.containsKey(tr.PropStrength__Application_Booking__c)) {
                    for(PropStrength__Applicant_Detail__c applicant : bookRecs.get(tr.PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r) {
                        if(applicant.PropStrength__Active__c) {
                            newOwner += applicant.PropStrength__Customer_Name__c + ' & ';
                        } else {
                            prevOwner += applicant.PropStrength__Customer_Name__c + ' & ';
                        }
                    }
                }
                if(prevOwner != '') {
                    prevOwner = prevOwner.substring(0, prevOwner.length()-3);
                }
                if(newOwner != '') {
                    newOwner = newOwner.substring(0, newOwner.length()-3);
                }


                String body = 'Dear CRM Team,\n\nI hope this email finds you well. We would like to inform you that the ownership of Unit '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c+' has been successfully transferred to a new customer.\n\nDetails of the transfer are as follows:\n\n- Unit Number: '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c+'\n- Previous Owner: '+prevOwner+'\n- New Owner: '+newOwner+'\n\nPlease ensure that the CRM records are updated accordingly to reflect the change in ownership. This includes updating customer details, contact information, and any other relevant data in the CRM system.\n\nThank you for your cooperation.\n\nBest regards,\n\nSobha Realty';

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setSubject('Unit Ownership Transfer Notification');
                mail.setplaintextbody(body);
                mail.setToAddresses(new List<String>{tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email});
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                emailList.add(mail);

                EmailMessage newEmail = new EmailMessage();
                newEmail.ToAddress = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email;
                newEmail.Subject = 'Unit Ownership Transfer Notification';
                newEmail.TextBody = mail.getPlainTextBody();
                newEmail.RelatedToId = tr.Id;
                newEmail.Status = '3';

                activityList.add(newEmail);
            }

            System.debug(emailList);
            try{
                if(emailList != null && emailList.size()>0 ) {
                    System.debug(emailList);
                    Messaging.sendEmail(emailList);
                    insert activityList;
                }
            }catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }

    //Added by Deepak Sharma on 14 December 2023 to update TitleTitle_Deed_Status__c and Pre_Registration_Status__c on booking
    public static void updateTitleDeedNPreRegistrationStatus(List<PropStrength__Transaction_Requests__c> trList, Map<Id, PropStrength__Transaction_Requests__c> oldTRMap, String actionType) {
        List<PropStrength__Application_Booking__c> updateBookingList = new List<PropStrength__Application_Booking__c>();
        Id titleDeedRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        Id preRegistrationChargesRTId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Pre-Registration Process').getRecordTypeId();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.PropStrength__Application_Booking__c != null) {
                if(actionType == 'Insert') {
                    PropStrength__Application_Booking__c temp = new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c);
                    
                    if(tr.RecordTypeId == titleDeedRecordTypeId) {
                        if(tr.DSR_Generation_Requested_from_DLD_Team__c) {
                            temp.Title_Deed_Status__c = 'DSR Generation Requested from DLD Team';
                        }
                        if(tr.DSR_Signing_Requested_from_CRM_Team__c) {
                            temp.Title_Deed_Status__c = 'DSR Signing Requested from CRM Team';
                        }
                        if(tr.Customer_Signed_DSR_Uploaded__c) {
                            temp.Title_Deed_Status__c = 'Customer Signed DSR Uploaded';
                        }
                        if(tr.DSR_Submitted_to_DLD__c) {
                            temp.Title_Deed_Status__c = 'DSR Submitted to DLD';
                        }
                        if(tr.Title_Deed_Uploaded__c) {
                            temp.Title_Deed_Status__c = 'Title Deed Uploaded';
                        }
                        if(tr.PropStrength__Status__c == 'Request Completed') {
                            temp.Title_Deed_Status__c = 'Request Completed';
                        }
                        updateBookingList.add(temp);
                    } else if(tr.RecordTypeId == preRegistrationChargesRTId) {
                        if(tr.PropStrength__Status__c == 'DSR Sent For Audit Approval') {
                            temp.Pre_Registration_Status__c = 'DSR Sent for Audit Approval';
                        }
                        else if(tr.PropStrength__Status__c == 'DSR Audit Approved, Upload Draft in Oqood Portal') {
                            temp.Pre_Registration_Status__c = 'DSR Audit Approved, Upload Draft in Oqood Portal';
                        }
                        else if(tr.PropStrength__Status__c == 'Download DLD Certificate & Upload In PS') {
                            temp.Pre_Registration_Status__c = 'Download DLD Certificate & Upload In PS';
                        }
                        else if(tr.PropStrength__Status__c == 'DLD Certificate Uploaded, Update Certificate No.') {
                            temp.Pre_Registration_Status__c = 'DLD Certificate Uploaded, Update Certificate No.';
                        }
                        else if(tr.PropStrength__Status__c == 'Pre-Registration Successful, Email Sent To Customer') {
                            temp.Pre_Registration_Status__c = 'Pre-Registration Successful, Email Sent To Customer';
                        }
                        else if(tr.PropStrength__Status__c == 'Pre-Registration Successful, Email Sent To Customer') {
                            temp.Pre_Registration_Status__c = 'Pre-Registration Successful, Email Sent To Customer';
                            temp.Pre_Registration_Completed__c = true;
                            temp.Pre_Registration_Completed_Date__c = System.today();
                        }
                        updateBookingList.add(temp);
                    }
                }
                if(actionType == 'Update') {
                    PropStrength__Application_Booking__c temp = new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c);

                    if(tr.RecordTypeId == titleDeedRecordTypeId) {
                        if(tr.DSR_Generation_Requested_from_DLD_Team__c && tr.DSR_Generation_Requested_from_DLD_Team__c != oldTRMap.get(tr.Id).DSR_Generation_Requested_from_DLD_Team__c) {
                            temp.Title_Deed_Status__c = 'DSR Generation Requested from DLD Team';
                        }
                        if(tr.DSR_Signing_Requested_from_CRM_Team__c && tr.DSR_Signing_Requested_from_CRM_Team__c != oldTRMap.get(tr.Id).DSR_Signing_Requested_from_CRM_Team__c) {
                            temp.Title_Deed_Status__c = 'DSR Signing Requested from CRM Team';
                        }
                        if(tr.Customer_Signed_DSR_Uploaded__c && tr.Customer_Signed_DSR_Uploaded__c != oldTRMap.get(tr.Id).Customer_Signed_DSR_Uploaded__c) {
                            temp.Title_Deed_Status__c = 'Customer Signed DSR Uploaded';
                        }
                        if(tr.DSR_Submitted_to_DLD__c && tr.DSR_Submitted_to_DLD__c != oldTRMap.get(tr.Id).DSR_Submitted_to_DLD__c) {
                            temp.Title_Deed_Status__c = 'DSR Submitted to DLD';
                        }
                        if(tr.Title_Deed_Uploaded__c && tr.Title_Deed_Uploaded__c != oldTRMap.get(tr.Id).Title_Deed_Uploaded__c) {
                            temp.Title_Deed_Status__c = 'Title Deed Uploaded';
                        }
                        if(tr.PropStrength__Status__c == 'Request Completed' && tr.PropStrength__Status__c != oldTRMap.get(tr.Id).PropStrength__Status__c) {
                            temp.Title_Deed_Status__c = 'Request Completed';
                            temp.Pre_Registration_Completed__c = true;
                            temp.Pre_Registration_Completed_Date__c = System.today();
                        }
                        updateBookingList.add(temp);
                    }  else if(tr.RecordTypeId == preRegistrationChargesRTId) {
                        if(tr.PropStrength__Status__c == 'DSR Sent For Audit Approval' && tr.PropStrength__Status__c != oldTRMap.get(tr.Id).PropStrength__Status__c) {
                            temp.Pre_Registration_Status__c = 'DSR Sent for Audit Approval';
                        }
                        else if(tr.PropStrength__Status__c == 'DSR Audit Approved, Upload Draft in Oqood Portal' && tr.PropStrength__Status__c != oldTRMap.get(tr.Id).PropStrength__Status__c) {
                            temp.Pre_Registration_Status__c = 'DSR Audit Approved, Upload Draft in Oqood Portal';
                        }
                        else if(tr.PropStrength__Status__c == 'Download DLD Certificate & Upload In PS' && tr.PropStrength__Status__c != oldTRMap.get(tr.Id).PropStrength__Status__c) {
                            temp.Pre_Registration_Status__c = 'Download DLD Certificate & Upload In PS';
                        }
                        else if(tr.PropStrength__Status__c == 'DLD Certificate Uploaded, Update Certificate No.' && tr.PropStrength__Status__c != oldTRMap.get(tr.Id).PropStrength__Status__c) {
                            temp.Pre_Registration_Status__c = 'DLD Certificate Uploaded, Update Certificate No.';
                        }
                        else if(tr.PropStrength__Status__c == 'Pre-Registration Successful, Email Sent To Customer' && tr.PropStrength__Status__c != oldTRMap.get(tr.Id).PropStrength__Status__c) {
                            temp.Pre_Registration_Status__c = 'Pre-Registration Successful, Email Sent To Customer';
                        }
                        else if(tr.PropStrength__Status__c == 'Request Completed' && tr.PropStrength__Status__c != oldTRMap.get(tr.Id).PropStrength__Status__c) {
                            temp.Pre_Registration_Status__c = 'Request Completed';
                            temp.Pre_Registration_Completed__c = true;
                            temp.Pre_Registration_Completed_Date__c = System.today();
                        }
                        updateBookingList.add(temp);
                    }
                }
            }
        }

        if(!updateBookingList.isEmpty()) {
            update updateBookingList;
        }
    }

    //Added by deepak sharma to update SPA Execution Date when status is SPA Executed on 18 December 2023
    public static void updateSPADate(List<PropStrength__Transaction_Requests__c> trList, Map<Id, PropStrength__Transaction_Requests__c> oldTrMap) {
        for(PropStrength__Transaction_Requests__c tr: trList) {
            if(tr.PropStrength__Status__c == 'SPA Executed' && tr.PropStrength__Status__c != oldTrMap.get(tr.Id).PropStrength__Status__c) {
                tr.SPA_Execution_Date__c = System.Now();
            }
        }
    }

    //Added by Nishank Manwani to show error on SPA Creation as per contact Residential Status on 26 December 2023
    //Modified by Nishank Manwani to show error on Title Deed Creation as per contact Emirates and Passport Id Expiry on 19 Apr 2024
    public static void showErrorForSPAResidentOrNonResident(List<PropStrength__Transaction_Requests__c> trList) {
        Set<Id> bookId = new Set<Id>();
        Id spaRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        Id titleDeedTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        Id preRegRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Pre-Registration Process').getRecordTypeId();


        for(PropStrength__Transaction_Requests__c tr : trList) {
            if((tr.RecordTypeId == spaRecordTypeId || tr.RecordTypeId == titleDeedTypeId || tr.RecordTypeId == preRegRecordTypeId) && tr.PropStrength__Application_Booking__c != null) {
                bookId.add(tr.PropStrength__Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Primary_Customer__c, PropStrength__Primary_Customer__r.PropStrength__Resident_Status__c, PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c, PropStrength__Primary_Customer__r.Passport_Expiry_Date__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);

            for(PropStrength__Transaction_Requests__c tr : trList) {
                if(tr.RecordTypeId == spaRecordTypeId && tr.PropStrength__Application_Booking__c != null) {
                    if(bookMap.containskey(tr.PropStrength__Application_Booking__c) && bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__c != null) {
                        Date today = Date.today();
                        //Commented by Nishank Manwani on 19 Apr 2024 no need of this condition as of now
                        /*if(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.PropStrength__Resident_Status__c == 'Resident Citizen' && bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c != null) {
                            System.debug('1');
                            System.debug(today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c));
                            System.debug(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c));
                            if( bookMap.containskey(tr.PropStrength__Application_Booking__c) && today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c) < 90 || today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c) < 3) {
                                tr.addError('The SPA Transaction cannot be saved as the National ID is about to expire within next three months.');
                            }
                        } else */
                        if( bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c != null ) {
                            System.debug('2');
                            System.debug(today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c));
                            System.debug(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c));
                            if(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c) < 30 || today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c) < 1) {
                                tr.addError('The SPA Transaction cannot be saved as the Passport is about to expire within next one month.');
                            }
                        }
                    }
                } else if(tr.RecordTypeId == titleDeedTypeId && tr.PropStrength__Application_Booking__c != null) {
                    if(bookMap.containskey(tr.PropStrength__Application_Booking__c) && bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__c != null) {
                        Date today = Date.today();

                        if(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c != null) {
                            System.debug('3');
                            System.debug(today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c));
                            System.debug(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c));
                            if(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c) < 30 || today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c) < 1) {
                                tr.addError('The Title Deed Transaction cannot be saved as the Emirates Id is about to expire within next one month.');
                            }
                        } 
                        if(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c != null ) {
                            System.debug('4');
                            System.debug(today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c));
                            System.debug(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c));
                            if(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c) < 30 || today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c) < 1) {
                                tr.addError('The Title Deed Transaction cannot be saved as the Passport is about to expire within next one month.');
                            }
                        }
                    }
                } else if(tr.RecordTypeId == preRegRecordTypeId && tr.PropStrength__Application_Booking__c != null) {
                    if(bookMap.containskey(tr.PropStrength__Application_Booking__c) && bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__c != null) {
                        Date today = Date.today();
                        if(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.PropStrength__Resident_Status__c == 'Resident Citizen' && bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c != null) {
                            System.debug('1');
                            System.debug(today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c));
                            System.debug(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c));
                            if( bookMap.containskey(tr.PropStrength__Application_Booking__c) && today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c) < 0) {
                                tr.addError('The Pre-Registration Process Transaction cannot be saved as the National ID is expired');
                            }
                        } else if( bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c != null ) {
                            System.debug('2');
                            System.debug(today.monthsBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c));
                            System.debug(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c));
                            if(today.daysBetween(bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Primary_Customer__r.Passport_Expiry_Date__c) < 0) {
                                tr.addError('The Pre-Registration Process Transaction cannot be saved as the Passport is expired');
                            }
                        }
                    }
                }
            }
        }
    }

    //Added by Nishank Manwani on 04-Jan-2024 to update SPA_Reminder_Flow_Date__c field on booking when spa sent to customer for digi sign and Digi Signed SPA Received From Customer
    public static void updateReminderSpaDateFldOnBooking(List<PropStrength__Transaction_Requests__c> trList, Map<Id, PropStrength__Transaction_Requests__c> oldTrMap) {
        Id spaRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.RecordTypeId == spaRecordTypeId) {
                if(tr.PropStrength__Application_Booking__c != null && tr.SPA_Sent_to_Customer_for_Digi_Sign__c && tr.SPA_Sent_to_Customer_for_Digi_Sign_Date__c != null && !tr.Digi_Signed_SPA_Received_From_Customer__c && tr.SPA_Sent_to_Customer_for_Digi_Sign__c != oldTrMap.get(tr.Id).SPA_Sent_to_Customer_for_Digi_Sign__c) {
                    updateBookList.add(new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c, SPA_Reminder_Flow_Date__c = System.Today()));
                }
                if(tr.PropStrength__Application_Booking__c != null && tr.Digi_Signed_SPA_Received_From_Customer__c && tr.Digi_Signed_SPA_Received_From_Customer__c != oldTrMap.get(tr.Id).Digi_Signed_SPA_Received_From_Customer__c) {
                    updateBookList.add(new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c, SPA_Reminder_Flow_Date__c = null));
                }
            }
        }

        if(!updateBookList.isEmpty()) {
            update updateBookList;
        }
    }

    //Added by Nishank Manwani on 11-Jan-2024 to send Mail to DLD Executive and Collection Executive when Transaction request get rejected by Audit Team
    public static void sendMailOnRejectedByAuditTeam(List<PropStrength__Transaction_Requests__c> trList, Map<Id, PropStrength__Transaction_Requests__c> oldTrMap) {
        Set<Id> trIds = new Set<Id>();
        Id mortgageProcessRecTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Mortgage Process').getRecordTypeId();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.PropStrength__Status__c == 'Rejected by Audit Team' && tr.PropStrength__Status__c != oldTrMap.get(tr.Id).PropStrength__Status__c && tr.PropStrength__Application_Booking__c != null && tr.RecordTypeId == mortgageProcessRecTypeId) {
                trIds.add(tr.Id);
            }
        }

        if(!trIds.isEmpty()) {
            TransactionRequestTriggerHelper.sendEmailToDLDAndCollectionExecutive(trIds);
        }
    }
    
    //Added by Nishank Manwani on 14-Mar-2024 to update by add date time in DSR Review field 
    public static void updateDsrReveiw(List<PropStrength__Transaction_Requests__c> trList, Map<Id, PropStrength__Transaction_Requests__c> oldTrMap) {
        Id mortgageProcessRecTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Mortgage Process').getRecordTypeId();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.DSR_Review_Accounts_Comments__c != null && tr.DSR_Review_Accounts_Comments__c != oldTrMap.get(tr.Id).DSR_Review_Accounts_Comments__c && tr.RecordTypeId == mortgageProcessRecTypeId) {
                tr.DSR_Review_Accounts_Comments__c += ' ' + System.now().format();
            }
            if(tr.DSR_Review_Audit_Comments__c != null && tr.DSR_Review_Audit_Comments__c != oldTrMap.get(tr.Id).DSR_Review_Audit_Comments__c && tr.RecordTypeId == mortgageProcessRecTypeId) {
                tr.DSR_Review_Audit_Comments__c += ' ' + System.now().format();
            }
        }
    }

    //Added by Nishank Manwani on 11-Jan-2024 to send Mail to DLD Executive and Collection Executive when Transaction request get rejected by Audit Team
    @future
    public static void sendEmailToDLDAndCollectionExecutive(set<Id> trIds) {
        System.debug('trIds***'+trIds);
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>(); 
        String tempId = '';
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Mortgage_Transaction_Rejected_by_Audit'];
        if(!emailTemplate.isEmpty()) {
            tempId = emailTemplate[0].Id;
        }
        System.debug('tempId***'+tempId);
        if(!trIds.isEmpty()) {
            trList = [SELECT Id,PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__c,
                        PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__r.Email, 
                        PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__c,
                        PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__r.Email 
                        FROM PropStrength__Transaction_Requests__c 
                        WHERE Id IN: trIds];
            Set<Id> bookingIds = new Set<Id>();
            for(PropStrength__Transaction_Requests__c tr : trList) {
                if(tr.PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__c != null) {
                    sendTo.add(tr.PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__r.Email);
                } 
                if(tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__c != null) {
                    sendTo.add(tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__r.Email);
                }
            }
        }
        System.debug('trList***'+trList);
        if(!trList.isEmpty()) {
            System.debug('sendTo***'+sendTo);
            for(PropStrength__Transaction_Requests__c tr : trList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                email.setWhatId(tr.id);
                email.setTargetObjectId(tr.PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.setSaveAsActivity(true); 
                email.setTemplateId(tempId);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }

    //Added by Nishank Manwani on 16-Feb-2024 to change status of previoud TR record of SPA Process to voided
    public static void changeStatusToVoid(List<PropStrength__Transaction_Requests__c> trList, Map<Id, PropStrength__Transaction_Requests__c> oldTrMap) {
        Id spaProcessTrId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        Set<Id> bookingIds = new Set<Id>();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.PropStrength__Status__c != oldTrMap.get(tr.Id).PropStrength__Status__c && tr.PropStrength__Status__c == 'SPA Executed' && tr.RecordTypeId == spaProcessTrId && tr.PropStrength__Application_Booking__c != null) {
                bookingIds.add(tr.PropStrength__Application_Booking__c);
            }
        }
        System.debug('bookingIds****');
        System.debug(bookingIds);

        if(!bookingIds.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, 
                                                                                                                    (SELECT Id FROM PropStrength__Transaction_Request__r 
                                                                                                                    WHERE RecordType.Name = 'SPA Process' ANd Id NOT IN :oldTrMap.keySet())
                                                                                                                    FROM PropStrength__Application_Booking__c
                                                                                                                    WHERE Id IN :bookingIds]);

            System.debug('bookMap****');
            System.debug(bookMap);

            List<PropStrength__Transaction_Requests__c> updateTrList = new List<PropStrength__Transaction_Requests__c>();

            for(PropStrength__Transaction_Requests__c tr : trList) {
                if(tr.PropStrength__Status__c != oldTrMap.get(tr.Id).PropStrength__Status__c && tr.PropStrength__Status__c == 'SPA Executed' && tr.RecordTypeId == spaProcessTrId && tr.PropStrength__Application_Booking__c != null) {
                    if(!bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Transaction_Request__r.isEmpty()) {
                        for(PropStrength__Transaction_Requests__c trNew : bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Transaction_Request__r) {
                            updateTrList.add(new PropStrength__Transaction_Requests__c(Id=trNew.Id, PropStrength__Status__c = 'Voided'));
                        }
                    }
                }
            }
            System.debug('updateTrList****');
            System.debug(updateTrList);

            if(!updateTrList.isEmpty()) {
                update updateTrList;
            }
        }
    }
     // Added by Gourav on 16-02- 2024 Send Email to Sales Head and Sales Manager on SPA Execution.
     public static void sendEmailOnSpaExecute(List<PropStrength__Transaction_Requests__c> transReqList , Map<Id, PropStrength__Transaction_Requests__c> tranReqOldMap) {
        Set<Id> bookingIds = new Set<Id>();
        Map<Id, PropStrength__Transaction_Requests__c> transRecIsSPAExecuted = new Map<Id, PropStrength__Transaction_Requests__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(PropStrength__Transaction_Requests__c rec : transReqList) {
            if(rec.PropStrength__Status__c == 'SPA Executed' && rec.PropStrength__Status__c != tranReqOldMap.get(rec.Id).PropStrength__Status__c) {
                bookingIds.add(rec.PropStrength__Application_Booking__c);
                transRecIsSPAExecuted.put(rec.Id, rec);
            }

        }
        Set<String> fromAddressFromBooking = new Set<String>();
        Map<Id, PropStrength__Application_Booking__c> applcationBookingMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT ID, House_Unit_No__c , PropStrength__Primary_Applicant_Name__c, 
                                    PropStrength__Project__r.Name, Sales_Head__c, Sales_Head__r.Email, Sales_Manager__c, Sales_Manager__r.Email, 
                                    PropStrength__Project__r.Customer_Care_Email_ID__c, PropStrength__Primary_Customer__c 
                                    FROM PropStrength__Application_Booking__c 
                                    WHERE Id IN :bookingIds]);

        for(PropStrength__Application_Booking__c book : applcationBookingMap.values()) {
            fromAddressFromBooking.add(book.PropStrength__Project__r.Customer_Care_Email_ID__c);
        }

        Map<String, Id> mailToOrgIdMap = new Map<String, Id>();

        for(OrgWideEmailAddress org : [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: fromAddressFromBooking]) {
            mailToOrgIdMap.put(org.Address, org.Id);
        }       
        if(!transRecIsSPAExecuted.keySet().isEmpty()) {
            for(PropStrength__Transaction_Requests__c transRec : transRecIsSPAExecuted.values()) {
                PropStrength__Application_Booking__c bookRec = applcationBookingMap.get(transRec.PropStrength__Application_Booking__c);
                List<String> sendTo = new List<String>(); 
                Set<String> fromAddress = new Set<String>();
                if(bookRec.Sales_Head__c != null && bookRec.Sales_Head__r.Email != null) {
                    sendTo.add(bookRec.Sales_Head__r.Email);
                }
                if(bookRec.Sales_Manager__c != null && bookRec.Sales_Manager__r.Email != null) {
                    sendTo.add(bookRec.Sales_Manager__r.Email);
                }
                if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Customer_Care_Email_ID__c != null) {
                    fromAddress.add(bookRec.PropStrength__Project__r.Customer_Care_Email_ID__c);
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(bookRec.House_Unit_No__c +' - Sales and Purchase Agreement Executed');
                String EmailBody = 'Dear Sales Team,\n\n';
                EmailBody += 'This is to inform you that the Sales and Purchase Agreement (SPA) for the unit '+bookRec.House_Unit_No__c+' has been successfully executed.';
                EmailBody += '\n\nDetails are as follows:\n\n';
                EmailBody += 'Project Name : '+bookRec.PropStrength__Project__r.Name+'\n';
                EmailBody += 'Customer Name : '+bookRec.PropStrength__Primary_Applicant_Name__c+'\n';
                EmailBody += 'Unit No. : '+bookRec.House_Unit_No__c+'\n\n\n';
                EmailBody += 'Regards,\n\n';
                EmailBody += 'Sobha';
                mail.setplaintextbody(EmailBody);
                mail.setToAddresses(sendTo);
                mail.setWhatId(transRec.id);
                mail.saveAsActivity = true;
                mail.setTreatTargetObjectAsRecipient(False);
                mail.setTargetObjectId(bookRec.PropStrength__Primary_Customer__c);
                mail.saveAsActivity = true;
                mail.setOrgWideEmailAddressId(mailToOrgIdMap.get(bookRec.PropStrength__Project__r.Customer_Care_Email_ID__c));
                mails.add(mail); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } catch(Exception e) {
                System.debug('--------------Exception in Sending emails Test--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number Test::'+e.getLineNumber());
            }
        }
    }

    public static void updateOriginalWaiverAmount(List<PropStrength__Transaction_Requests__c> transReqList, Map<Id, PropStrength__Transaction_Requests__c> oldReqMap) {
        Id recTypeTransId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Credit Waiver').getRecordTypeId();
       
        for(PropStrength__Transaction_Requests__c rec : transReqList) {
            if(oldReqMap == null && rec.RecordTypeId == recTypeTransId && rec.PropStrength__Credit_Waiver_Amount__c != null) {
                rec.Original_Waiver_Amount__c = rec.PropStrength__Credit_Waiver_Amount__c;
            }
            if(oldReqMap != null && rec.RecordTypeId == recTypeTransId && rec.PropStrength__Credit_Waiver_Amount__c != oldReqMap.get(rec.Id).PropStrength__Credit_Waiver_Amount__c) {
                rec.Original_Waiver_Amount__c = oldReqMap.get(rec.Id).PropStrength__Credit_Waiver_Amount__c != null ? oldReqMap.get(rec.Id).PropStrength__Credit_Waiver_Amount__c : 0;
            }
        }
    }
    // Approval_Status__c is replaced by PropStrength__Status__c, changes made By Gourav Gour 08/06/2024
    public Static void onBeforeUpdate(List<PropStrength__Transaction_Requests__c> newResLst, Map<id, PropStrength__Transaction_Requests__c> oldMapresale){
        for(PropStrength__Transaction_Requests__c res : newResLst) {
            if(res.PropStrength__Status__c =='Pending for Accounts Approval' && oldMapresale.get(res.id).PropStrength__Status__c== 'Pending for Collections Approval'){
                if(res.is_cheklist_completed__c==false){
                    res.addError('Please Complete Collection Checklist before Approve'); 
                }
            }
            if(res.PropStrength__Status__c =='Rejected by Collections' && oldMapresale.get(res.id).PropStrength__Status__c== 'Pending for Collections Approval'){
                if(res.Collections_Rejection_Comments__c == null){
                    res.addError('Please populate Collection Rejection Comments in the record, Before Rejecting'); 
                }
                
            }
            if(res.PropStrength__Status__c =='Rejected by Accounts' && oldMapresale.get(res.id).PropStrength__Status__c== 'Pending for Accounts Approval'){
                if(res.Rejected_To__c == null){
                    res.addError('Please populate Rejected To, Before Rejecting');  
                }
                if(res.Accounts_Rejection_Comments__c == null){
                    res.addError('Please populate Accounts Rejection Comments in the record, Before Rejecting'); 
                }
            }
            if(res.PropStrength__Status__c =='Rejected by Audit' && oldMapresale.get(res.id).PropStrength__Status__c== 'Pending for Audit Approval'){
                if(res.Rejected_To__c == null){
                    res.addError('Please populate Rejected To, Before Rejecting');  
                }
                if(res.Audit_Rejection_Comments__c == null){
                    res.addError('Please populate Audit Rejection Comments in the record, Before Rejecting'); 
                }
            }
            if(res.Rejected_To__c == 'Audit Rejected to Accounts' && res.PropStrength__Status__c =='Pending for Audit Approval' && oldMapresale.get(res.id).PropStrength__Status__c== 'Rejected by Audit'){
                if(res.Accounts_Resubmit_comments__c  == null){
                    res.addError('Please fill Account Resubmit Comments on record , Before Submitting');  
                }
                else{
                    res.Rejected_To__c ='';
                }
            }
            if((res.Rejected_To__c == 'Audit Rejected to Collections') && res.PropStrength__Status__c =='Pending for Audit Approval' && oldMapresale.get(res.id).PropStrength__Status__c== 'Rejected by Audit'){
                if(res.Collections_Resubmit_comments__c == null){
                    res.addError('Please fill Collections Resubmit Comments on record, Before Approving');  
                }
                else{
                    res.Rejected_To__c ='';
                }
            }
            if((res.Rejected_To__c == 'Audit Rejected to CRM' || res.Rejected_To__c =='Audit Rejected to CRM & Collections & Accounts')  && (res.PropStrength__Status__c =='Pending for Audit Approval' || res.PropStrength__Status__c== 'Pending for Collections Approval') && oldMapresale.get(res.id).PropStrength__Status__c== 'Rejected by Audit'){
                if(res.CRM_Resubmit_comments__c == null){
                    res.addError('Please fill CRM Resubmit Comments on record, Before Submitting');  
                }
                else{
                    res.Rejected_To__c ='';
                }
            }
            if((res.Rejected_To__c == 'Accounts Rejected to Collections' || res.Rejected_To__c =='Audit Rejected to Collections & Accounts') && res.PropStrength__Status__c =='Pending for Accounts Approval' && (oldMapresale.get(res.id).PropStrength__Status__c== 'Rejected by Accounts' || oldMapresale.get(res.id).PropStrength__Status__c== 'Rejected by Audit')){
                if(res.Collections_Resubmit_comments__c == null){
                    res.addError('Please fill Collections Resubmit Comments on record, Before Approving');  
                }
                else{
                    res.Rejected_To__c ='';
                }
            }
            if((res.Rejected_To__c == 'Accounts Rejected to CRM' || res.Rejected_To__c =='Audit Rejected to CRM & Accounts')  && res.PropStrength__Status__c =='Pending for Accounts Approval' && (oldMapresale.get(res.id).PropStrength__Status__c == 'Rejected by Accounts' || oldMapresale.get(res.id).PropStrength__Status__c == 'Rejected by Audit')){
                if(res.CRM_Resubmit_comments__c == null){
                    res.addError('Please fill CRM Resubmit Comments on record, Before Submitting');  
                }
                else{
                    res.Rejected_To__c ='';
                }
            }  
            // Added By Gourav Gour 08/06/2024
            if(res.New_Title_Document_Uploaded__c && res.New_Oqood_Document_Uploaded__c && (res.New_Oqood_Document_Uploaded__c != oldMapresale.get(res.Id).New_Oqood_Document_Uploaded__c || res.New_Title_Document_Uploaded__c != oldMapresale.get(res.Id).New_Title_Document_Uploaded__c)) {
                res.PropStrength__Status__c ='Request Completed';
            }
        }
    }
    
    public static void DLDNotificationsend(List<PropStrength__Transaction_Requests__c> transReqList, Map<Id, PropStrength__Transaction_Requests__c> oldReqMap) {
        Id recTypeTransId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId();
        List<String> listOftrnasactionIds = new List<String>();
        for(PropStrength__Transaction_Requests__c rec : transReqList) {            
            if(oldReqMap != null && rec.RecordTypeId == recTypeTransId && 
               rec.Agreement_Docusign_Completed__c != oldReqMap.get(rec.Id).Agreement_Docusign_Completed__c && rec.Agreement_Docusign_Completed__c &&
              ( rec.PropStrength__Customer_Transfer_Type__c == 'Resale with Mortgage' || rec.PropStrength__Customer_Transfer_Type__c == 'Oqood for Apt & Villas'  )) {
                listOftrnasactionIds.add(rec.Id);
            }
        }
        List<PropStrength__Transaction_Requests__c> transectionRecList = new List<PropStrength__Transaction_Requests__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>(); 
        if(listOftrnasactionIds.size() > 0){
            transectionRecList = [SELECT id,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__r.email from PropStrength__Transaction_Requests__c WHERE id  IN : listOftrnasactionIds];
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     FROM EmailTemplate 
                                                     WHERE DeveloperName =: 'DLD_Notification'];
            String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
               /* if(!fromAddress.isEmpty()) {
                    if(!test.isrunningtest())
                        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: fromAddress limit 1];
                }*/
                for(PropStrength__Transaction_Requests__c trRec : transectionRecList) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if( trRec.PropStrength__Application_Booking__r.PropStrength__Project__c != null && trRec.PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__c != null) {
                        email.setToAddresses(new list<String>{trRec.PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__r.Email});
                    }
                   /* if(owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }*/
                    email.setWhatId(trRec.id);
                    email.setTargetObjectId(trRec.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.saveAsActivity = true;
                    email.setTemplateId(tempId);
                    mails.add(email); 
                }
                try {
                    if(!mails.isEmpty()){
                        Messaging.sendEmail(mails);
                    }
                } catch(Exception e){
                    System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                    System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                }
        }
        
    }
    //Added by Gourav Gour 15/04/2024 
    // Modified By Gourav 08/06/2024.
    public static void updateBookingStatusAsPerTR(List<PropStrength__Transaction_Requests__c> transList, map<Id, PropStrength__Transaction_Requests__c> oldMap) {
        Id spaRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        Id transferRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId();
        Map<Id, PropStrength__Application_Booking__c> updateBookingMap = new Map<Id, PropStrength__Application_Booking__c>();
        for(PropStrength__Transaction_Requests__c trans : transList) {
            if(trans.PropStrength__Application_Booking__c != null && trans.RecordTypeId == spaRecordTypeId && (oldMap == null || (oldMap != null && trans.PropStrength__Status__c != oldMap.get(trans.Id).PropStrength__Status__c))) {
                PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Id = trans.PropStrength__Application_Booking__c, SPA_Status__c = trans.PropStrength__Status__c);
                updateBookingMap.put(book.Id, book);
            }
            // Added By gourav 08/06/2024
            if(trans.RecordTypeId == transferRecordTypeId && trans.PropStrength__Application_Booking__c != null && ((oldMap == null || (oldMap != null && (trans.PropStrength__Customer_Transfer_Type__c != oldMap.get(trans.Id).PropStrength__Customer_Transfer_Type__c  || trans.PropStrength__Status__c != oldMap.get(trans.Id).PropStrength__Status__c))))) {
                PropStrength__Application_Booking__c book =  new PropStrength__Application_Booking__c();
                book.Id = trans.PropStrength__Application_Booking__c;
                book.Resale_Status__c = trans.PropStrength__Status__c;
                book.Resale_Type__c = trans.PropStrength__Customer_Transfer_Type__c;
                book.Resale_Completed__c = trans.PropStrength__Status__c == 'Request Completed' ? true : false;
                book.ReSale_Execution_Date__c = trans.PropStrength__Status__c == 'Request Completed' ? System.now() : null;
                updateBookingMap.put(book.Id, book);
            }
        }
        if(!updateBookingMap.values().isEmpty()) {
            update updateBookingMap.values();
        }
    }

    //Added by Nishank Manwani on 17/04/24 to update date fields as per checkboxes for title deed record type
    public static void updateCBSonTitleDeed(List<PropStrength__Transaction_Requests__c> transList, map<Id, PropStrength__Transaction_Requests__c> oldMap) {
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        for(PropStrength__Transaction_Requests__c tr : transList) {
            if(tr.RecordTypeId == titleDeedRecordType) {
                if(tr.DSR_Generation_Requested_from_DLD_Team__c && tr.DSR_Generation_Requested_from_DLD_Team__c != oldMap.get(tr.Id).DSR_Generation_Requested_from_DLD_Team__c) {
                    tr.DSR_Generation_Requested_DLD_Team_Date__c = System.Now();
                }
                if(tr.DSR_Signing_Requested_from_CRM_Team__c && tr.DSR_Signing_Requested_from_CRM_Team__c != oldMap.get(tr.Id).DSR_Signing_Requested_from_CRM_Team__c) {
                    tr.DSR_Signing_Requested_from_CRM_Team_Date__c = System.Now();
                }
                if(tr.DSR_Submitted_to_DLD__c && tr.DSR_Submitted_to_DLD__c != oldMap.get(tr.Id).DSR_Submitted_to_DLD__c) {
                    tr.DSR_Submitted_to_DLD_Date__c = System.Now();
                }
                if(tr.Title_Deed_Uploaded__c && tr.Title_Deed_Uploaded__c != oldMap.get(tr.Id).Title_Deed_Uploaded__c) {
                    tr.Title_Deed_Uploaded_Date__c = System.Now();
                }
                if(tr.Customer_Signed_DSR_Uploaded__c && tr.Customer_Signed_DSR_Uploaded__c != oldMap.get(tr.Id).Customer_Signed_DSR_Uploaded__c) {
                    tr.Customer_Signed_DSR_Uploaded_Date__c = System.Now();
                }
            }
        }
    }

    //Added by Nishank Manwani on 17/04/24 to update DSR Procedure No. and DSR Generated Date for title deed record type
    public static void updateDsrGenDtandProcNum(List<PropStrength__Transaction_Requests__c> transList, map<Id, PropStrength__Transaction_Requests__c> oldMap) {
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        
        Set<Id> bookingId = new Set<Id>();
        for(PropStrength__Transaction_Requests__c tr : transList) {
            if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null) {
                if((tr.DSR_Generated_Date__c != oldMap.get(tr.Id).DSR_Generated_Date__c || tr.DSR_Procedure_No2__c != oldMap.get(tr.Id).DSR_Procedure_No2__c)) {
                    bookingId.add(tr.PropStrength__Application_Booking__c);
                }
            }
        }
        
        List<Task> tasksToInsert = new List<Task>();
        List<PropStrength__Application_Booking__c> bookList = new List< PropStrength__Application_Booking__c>();
        if(!bookingId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, CRM_Executive__c, PropStrength__Project__r.DLD_Executive__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]);
            if(!bookingMap.isEmpty()) {
                for(PropStrength__Transaction_Requests__c tr : transList) {
                    if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && bookingMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        PropStrength__Application_Booking__c book = bookingMap.get(tr.PropStrength__Application_Booking__c);

                        if((tr.DSR_Generated_Date__c != oldMap.get(tr.Id).DSR_Generated_Date__c || tr.DSR_Procedure_No2__c != oldMap.get(tr.Id).DSR_Procedure_No2__c)) {
                            if(!tr.DSR_Signing_Requested_from_CRM_Team__c && book.CRM_Executive__c != null) {
                                Task newTask1 = new Task(
                                    Subject = 'Send DSR for Digital Signature',
                                    Description = 'Send DSR for Digital Signature',
                                    WhatId = tr.Id,
                                    OwnerId = book.CRM_Executive__c,
                                    ActivityDate = Date.today().addDays(1)
                                );
                                tasksToInsert.add(newTask1);
                                tr.DSR_Signing_Requested_from_CRM_Team__c = TRUE;
                                tr.DSR_Signing_Requested_from_CRM_Team_Date__c = System.Now();
                            }
                            bookList.add(new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c, DSR_Procedure_No__c = tr.DSR_Procedure_No2__c, DSR_Generated_Date__c = tr.DSR_Generated_Date__c.date()));
                        }
                    }
                }
            }

            if(!tasksToInsert.isEmpty()) {
                insert tasksToInsert;
            }
            if(!bookList.isEmpty()) {
                update bookList;
            }
        }
    }
    
    //Added by Nishank Manwani on 17/04/24 to update Status Field On Application/Booking for title deed record type
    public static void updateStatusOnBook(List<PropStrength__Transaction_Requests__c> transList, map<Id, PropStrength__Transaction_Requests__c> oldMap) {
        Id titleDeedRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        
        List<PropStrength__Application_Booking__c> bookList = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Transaction_Requests__c tr : transList) {
            if(tr.RecordTypeId == titleDeedRecordType && tr.PropStrength__Application_Booking__c != null && tr.PropStrength__Status__c != oldMap.get(tr.Id).PropStrength__Status__c) {
                bookList.add(new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c, Title_Deed_Status__c = tr.PropStrength__Status__c));
            }
        }
        
        if(!bookList.isEmpty()) {
            update bookList;
        }
    }

    //Added by Nishank Manwani on 29/04/24 to show error while creation of SPA Process TR if conditions aren't met
    public static void showErrorOnSpaCreation(List<PropStrength__Transaction_Requests__c> trList) {
        Id spaRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        Set<Id> bookId = new Set<Id>();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.RecordTypeId == spaRecordType && tr.PropStrength__Application_Booking__c != null) {
                bookId.add(tr.PropStrength__Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id 
                                                                    FROM PropStrength__Application_Booking__c  
                                                                    WHERE ((PropStrength__Property__r.Floor_Plan_Uploaded__c != null
                                                                    AND PropStrength__Property__r.Unit_Plan_Uploaded__c != null
                                                                    AND PropStrength__Property__r.RecordType.Name != 'Plots' 
                                                                    AND PropStrength__Property__r.Area_confirmation_Date_Time__c != null 
                                                                    AND PropStrength__Property__r.Area_Confirmation_by_Sales_Ops_Date__c != null
                                                                    AND PropStrength__Property__r.Material_Specification_Uploaded__c != null
                                                                    AND PropStrength__Property__r.District_Plan_Uploaded__c != null
                                                                    AND PropStrength__Project__r.RERA_Registered__c = true
                                                                    AND Qualification_Date__c != null) OR SPA_Transaction_Exception__c = TRUE ) AND 
                                                                    Id IN :bookId]);

            for(PropStrength__Transaction_Requests__c tr : trList) {
                if(tr.RecordTypeId == spaRecordType && tr.PropStrength__Application_Booking__c != null) {
                    if(!bookMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        tr.addError('SPA Transaction cannot be initiated as the conditions are not met');
                    }
                }
            }
        }
    }

    //Added by Nishank Manwani on 03/05/24 to show error while creation of MOU Process TR if conditions aren't met
    public static void showErrorOnMouCreation(List<PropStrength__Transaction_Requests__c> trList) {
        Id mouRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('MOU Process').getRecordTypeId();
        Set<Id> bookId = new Set<Id>();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.RecordTypeId == mouRecordType && tr.PropStrength__Application_Booking__c != null) {
                bookId.add(tr.PropStrength__Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id 
                                                                    FROM PropStrength__Application_Booking__c  
                                                                    WHERE PropStrength__Active__c = true AND 
                                                                    (MOU_Transaction_Exception__c = TRUE OR (PropStrength__Total_Paid_Percent__c >= 9.5 AND 
                                                                    PropStrength__Property__r.Annexure_Document_Uploaded__c != null AND 
                                                                    PropStrength__Property__r.RecordType.Name =: 'Plots' AND
                                                                    PropStrength__Status__c =: 'Audit Approved')) AND 
                                                                    Id IN :bookId]);

            for(PropStrength__Transaction_Requests__c tr : trList) {
                if(tr.RecordTypeId == mouRecordType && tr.PropStrength__Application_Booking__c != null) {
                    if(!bookMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        tr.addError('MOU Transaction cannot be initiated as the conditions are not met');
                    }
                }
            }
        }
    }

    //Added by Nishank Manwani on 03/05/24 to show error while creation of DSPA Process TR if conditions aren't met
    public static void showErrorOnDspaCreation(List<PropStrength__Transaction_Requests__c> trList) {
        Id dspaRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('DSPA Process').getRecordTypeId();
        Set<Id> bookId = new Set<Id>();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.RecordTypeId == dspaRecordType && tr.PropStrength__Application_Booking__c != null) {
                bookId.add(tr.PropStrength__Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id 
                                                                    FROM PropStrength__Application_Booking__c  
                                                                    WHERE PropStrength__Active__c = true AND  
                                                                    (DSPA_Transaction_Exception__c = true OR (MOU_Executed__c = true AND 
                                                                    PropStrength__Property__r.Annexure_Document_Uploaded__c != null
                                                                    AND PropStrength__Property__r.Plot_Location_Plan_Uploaded__c != null)) AND 
                                                                    Id IN :bookId]);

            for(PropStrength__Transaction_Requests__c tr : trList) {
                if(tr.RecordTypeId == dspaRecordType && tr.PropStrength__Application_Booking__c != null) {
                    if(!bookMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        tr.addError('DSPA Transaction cannot be initiated as the conditions are not met');
                    }
                }
            }
        }
    }

    //Added by Nishank Manwani on 03/05/24 to show error while creation of Pre-Registration Process TR if conditions aren't met
    public static void showErrorOnPreRegistrationCreation(List<PropStrength__Transaction_Requests__c> trList) {
        Id preRegistrationRecordType = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Pre-Registration Process').getRecordTypeId();
        Set<Id> bookId = new Set<Id>();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.RecordTypeId == preRegistrationRecordType && tr.PropStrength__Application_Booking__c != null) {
                bookId.add(tr.PropStrength__Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id 
                                                                    FROM PropStrength__Application_Booking__c  
                                                                    WHERE PropStrength__Active__c = true AND  
                                                                    (Pre_Registration_Transaction_Exception__c = true OR (Oqood_Fees_Received__c = true AND 
                                                                    SPA_Executed__c = true)) AND 
                                                                    Id IN :bookId]);

            for(PropStrength__Transaction_Requests__c tr : trList) {
                if(tr.RecordTypeId == preRegistrationRecordType && tr.PropStrength__Application_Booking__c != null) {
                    if(!bookMap.containsKey(tr.PropStrength__Application_Booking__c)) {
                        tr.addError('Pre-Registration Transaction cannot be initiated as the conditions are not met');
                    }
                }
            }
        }
    }
    
    //Added by Deepak 02-May-2024
    public static void TRrecordCreatePermission(List<PropStrength__Transaction_Requests__c> trList) {
        List<Transaction_Request_Permission__mdt> mcs = Transaction_Request_Permission__mdt.getAll().values();
        map<String,List<String>> mapOfTRAndPermissoin = new map<String,List<String>>();
        for(Transaction_Request_Permission__mdt mDtRec : mcs){
            List<String> listOfPermission = new List<String>();
            if(mDtRec.Profile__c != null)
                listOfPermission.add(mDtRec.Profile__c);
            if(mDtRec.Profile__c == null && mDtRec.Role__c != null)
                listOfPermission.add(mDtRec.Role__c);
            if( listOfPermission.size() > 0)
                mapOfTRAndPermissoin.put(mDtRec.Record_Type__c, listOfPermission);
        }
        User userlIst = [SELECT id,profile.name, userrole.name  from User where Id=:userInfo.getUserId()];
        // Map<String,String> mapOfRecordType = new Map<String,String>();
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Area Change').getRecordTypeId(), 'Area Change');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Addition / Deletion of Name').getRecordTypeId(), 'Addition / Deletion of Name');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Advance Payment Rebate').getRecordTypeId(), 'Advance Payment Rebate');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Booking Form').getRecordTypeId(), 'Booking Form');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Car Parking Allotment').getRecordTypeId(), 'Car Parking Allotment');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Change In Payment Plan').getRecordTypeId(), 'Change In Payment Plan');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Credit Notes').getRecordTypeId(), 'Credit Notes');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('DSPA Process').getRecordTypeId(), 'DSPA Process');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Handing Possession to Customer').getRecordTypeId(), 'Handing Possession to Customer');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Handover').getRecordTypeId(), 'Handover');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('MOU Process').getRecordTypeId(), 'MOU Process');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Mortgage Process').getRecordTypeId(), 'Mortgage Process');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Pre-Registration Process').getRecordTypeId(), 'Pre-Registration Process');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), 'Refund');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId(), 'SPA Process');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId(), 'Title Deed Process');
        // mapOfRecordType.put(Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId(), 'Transfer Of Property');
        for(PropStrength__Transaction_Requests__c tr : trList) {
            String objName = 'PropStrength__Transaction_Requests__c'; 
            System.debug(Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosById().get(tr.recordtypeId).getName()+'**----**'+mapOfTRAndPermissoin);
            if(mapOfTRAndPermissoin.containskey(Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosById().get(tr.recordtypeId).getName())){                
                if( !mapOfTRAndPermissoin.get(Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosById().get(tr.recordtypeId).getName()).contains(userlIst.profile.name) && !mapOfTRAndPermissoin.get(Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosById().get(tr.recordtypeId).getName()).contains(userlIst.userrole.name)){
                    tr.addError('You cannot insert a record with this profile or role for '+Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosById().get(tr.recordtypeId).getName()+' record type.');
                }
            }
        }         
    }

    //Added by Nishank Manwani on 16-05-2024 to send mail to Sales Ops Queue when status is audit approved
    public static void sendMailToQueueSaleOps(List<PropStrength__Transaction_Requests__c> trList, Map<Id, PropStrength__Transaction_Requests__c> oldTrMap) {
        Id addDelRecTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Addition / Deletion of Name').getRecordTypeId();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Send_Mail_To_Sales_Ops_Queue'];
        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');

        List<String> sendTo = new List<String>();
        
        for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Sales_Ops')]) {
            if(u.Email != null) {
                sendTo.add(u.Email);
            }
        }

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.RecordTypeId == addDelRecTypeId && tr.PropStrength__Status__c == 'Audit Approved' && tr.PropStrength__Status__c != oldTrMap.get(tr.Id).PropStrength__Status__c) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                email.setWhatId(tr.id);
                email.setTargetObjectId(tr.CreatedById);
                email.setTreatTargetObjectAsRecipient(False);
                email.setSaveAsActivity(true); 
                email.setTemplateId(tempId);
                mails.add(email); 
            }
        }

        try {
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
        } catch(Exception e){
            System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
            System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
        }
    }
    
    public static boolean runOnce(){
        if(isRun) {
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }

    //Added by Nishank Manwani on 21-05-2024 to validate SPA Creation
    public static void spaCreateValidate(List<PropStrength__Transaction_Requests__c> trList) {
        Id SPARecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        Set<Id> bookId = new Set<Id>();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.RecordTypeId == SPARecordTypeId && tr.PropStrength__Application_Booking__c != null) {
                bookId.add(tr.PropStrength__Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, 
                                                                                                                    (SELECT Id FROM PropStrength__Transaction_Request__r 
                                                                                                                    WHERE RecordType.Name = 'SPA Process' AND PropStrength__Status__c != 'Rejected' AND  
                                                                                                                    PropStrength__Status__c != 'Voided')
                                                                                                                    FROM PropStrength__Application_Booking__c
                                                                                                                    WHERE Id IN :bookId]);

            System.debug('bookMap****');
            System.debug(bookMap);

            for(PropStrength__Transaction_Requests__c tr : trList) {
                if(tr.RecordTypeId == SPARecordTypeId && tr.PropStrength__Application_Booking__c != null) {
                    if(!bookMap.get(tr.PropStrength__Application_Booking__c).PropStrength__Transaction_Request__r.isEmpty()) {
                        tr.addError('SPA Record can not be created because there is already a SPA Transaction Request is present for this Application / Booking.');
                    }
                }
            }
        }
    }

    //Added by Nishank Manwani on 22-05-2024 to perform same action when status is Voided for Rejected
    public static void rejectedByAuditAction(List<PropStrength__Transaction_Requests__c> trList, Map<Id, PropStrength__Transaction_Requests__c> oldTrMap) {
        List<PropStrength__Transaction_Requests__c> insertTrList = new List<PropStrength__Transaction_Requests__c>();
        List<PropStrength__Transaction_Requests__c> updateTrList = new List<PropStrength__Transaction_Requests__c>();
        
        Id SPARecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        Id DSPARecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('DSPA Process').getRecordTypeId();
        Id MOURecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('MOU Process').getRecordTypeId();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.RecordTypeId == SPARecordTypeId && tr.PropStrength__Application_Booking__c != null && tr.PropStrength__Status__c != oldTrMap.get(tr.Id).PropStrength__Status__c && tr.PropStrength__Status__c == 'Rejected') {
                updateTrList.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Voided_By__c = UserInfo.getUserId(), Voided_Date__c = System.Now()));
                insertTrList.add(new PropStrength__Transaction_Requests__c(RecordTypeId=SPARecordTypeId, PropStrength__Application_Booking__c = tr.PropStrength__Application_Booking__c));
            } else if(tr.RecordTypeId == DSPARecordTypeId && tr.PropStrength__Application_Booking__c != null && tr.PropStrength__Status__c != oldTrMap.get(tr.Id).PropStrength__Status__c && tr.PropStrength__Status__c == 'Rejected') {
                updateTrList.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Voided_By__c = UserInfo.getUserId(), Voided_Date__c = System.Now()));
                insertTrList.add(new PropStrength__Transaction_Requests__c(RecordTypeId=DSPARecordTypeId, PropStrength__Application_Booking__c = tr.PropStrength__Application_Booking__c));
            } else if(tr.RecordTypeId == MOURecordTypeId && tr.PropStrength__Application_Booking__c != null && tr.PropStrength__Status__c != oldTrMap.get(tr.Id).PropStrength__Status__c && tr.PropStrength__Status__c == 'Rejected') {
                updateTrList.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Voided_By__c = UserInfo.getUserId(), Voided_Date__c = System.Now()));
                insertTrList.add(new PropStrength__Transaction_Requests__c(RecordTypeId=MOURecordTypeId, PropStrength__Application_Booking__c = tr.PropStrength__Application_Booking__c));
            }
        }

        if(!updateTrList.isEmpty()) {
            update updateTrList;
        }
        if(!insertTrList.isEmpty()) {
            insert insertTrList;
        }
    }

    //Added by Nishank Manwani on 06-June-2024 to send mail to Account Executive Refund Queue on insertion of refund record type transaction request
    public static void sendMailToAccountExecutiveQueue(List<PropStrength__Transaction_Requests__c> trList) {
        Id refundRecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
        List<PropStrength__Transaction_Requests__c> mailToTrList = new List<PropStrength__Transaction_Requests__c>();

        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.RecordTypeId == refundRecordTypeId && tr.PropStrength__Refund_Type__c == 'Termination Refund') {
                mailToTrList.add(tr);
            }
        }

        if(!mailToTrList.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Notification_To_Account_Executive_Queue'];

            String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

            List<String> sendTo = new List<String>();

            List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Account_Executive_Refund_queue'];
            
            for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Account_Executive_Refund_queue')]) {
                if(u.Email != null) {
                    sendTo.add(u.Email);
                }
            }

            if(gmList[0].group.Email != null){
                sendTo.add(gmList[0].group.Email);
            }

            for(PropStrength__Transaction_Requests__c tr : mailToTrList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(sendTo);
                email.setWhatId(tr.Id);
                email.setTargetObjectId(tr.CreatedById);
                email.setTreatTargetObjectAsRecipient(False);
                email.setSaveAsActivity(true); 
                email.setTemplateId(tempId);
                mails.add(email); 
            }

            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    }
}
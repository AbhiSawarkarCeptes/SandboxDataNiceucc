public class InterimPaymentsTriggerHandler{
    public static Boolean isRun = true;
    public static Boolean isRun2 = true;
    public static Boolean isRun3 = true;
    public static Boolean isRun4 = true;
    public static Boolean isRun5 = true;
    public static Boolean isRun6 = true;
    public static Boolean isRun7 = true;
    
    public static void Cheque_hold_Validation(List<Interim_Payments__c> newInterimPayments, Map<id,Interim_Payments__c> oldMap) {
        for(Interim_Payments__c interimPayment : newInterimPayments) {
            if(interimPayment.Submit_for_Check_Hold__c == true &&
               interimPayment.Approval_Status_Interim__c == 'Approved' &&
               interimPayment.Instrument_Date_Interim__c != null &&
                interimPayment.Instrument_Date_Interim__c.daysBetween(Date.today()) <= 10) {
                   interimPayment.addError('The Cheque can be put on hold only 10 days before the instrument date and the interim payment should not be approved');
               }
        }
    }
    
    public static void captureFinalApproverProcess(List<Interim_Payments__c> newIPs, Map<id,Interim_Payments__c> oldIPMap){
        if(!isAsyncContext()){
            captureFinalApproverProcessFuture(JSON.serialize(newIPs),JSON.serialize(oldIPMap));
            return;
        }
        
        Set<Payment_Request__c> prsForUpdate = new Set<Payment_Request__c>();
        for(Interim_Payments__c newIP : newIPs){
            if(newIP.Payment_Request__c == NULL || newIP.Payment_Mode_Interim__c != 'CDM Cheque (Cheque Deposit in Machine)') continue;
            Interim_Payments__c oldIP = oldIPMap.get(newIP.Id);
            if(newIP.Approval_Status_Interim__c == 'Approved' && newIP.Approval_Status_Interim__c != oldIP.Approval_Status_Interim__c){
                prsForUpdate.add(new Payment_Request__c(Id = newIP.Payment_Request__c,Final_Approver__c = UserInfo.getUserId()));
            }
        }
        Database.update(new List<Payment_Request__c>(prsForUpdate),false,AccessLevel.SYSTEM_MODE);
    }
    
    @future
    public static void captureFinalApproverProcessFuture(String newIPs,String oldIPMap){
        captureFinalApproverProcess((List<Interim_Payments__c>) JSON.deserialize(newIPs,List<Interim_Payments__c>.class),(Map<Id,Interim_Payments__c>) JSON.deserialize(oldIPMap,Map<Id,Interim_Payments__c>.class));
    }
    
    static Boolean isAsyncContext(){
        return System.isFuture() || System.isScheduled() || System.isQueueable() || System.isBatch();
    }
    
    public static void capturePaymentClearanceDate(List<Interim_Payments__c> newIps,Map<Id,Interim_Payments__c> oldIpMap){
        Boolean insertOrUpdate = oldIpMap == NULL;
        
        if(insertOrUpdate){
            for(Interim_Payments__c newIp : newIps){
                if(newIp.Approval_Status_Interim__c == 'Approved'){
                    newIp.Payment_Clearance_Date__c = System.now();
                }
            }
        }else{
            for(Interim_Payments__c newIp : newIps){
                if(!oldIpMap.containsKey(newIp.Id)) continue;
                Interim_Payments__c oldIp = oldIpMap.get(newIp.Id);
                if(newIp.Approval_Status_Interim__c == 'Approved' && newIp.Approval_Status_Interim__c != oldIp.Approval_Status_Interim__c){
                    newIp.Payment_Clearance_Date__c = System.now();
                }
            }
        }
    }

    //Added by Nishank Manwani on 26/07/2024 to update Approval status to Cheque Dishonoured wheb cheque bounce get true
    public static void updateApprovalStatusOnChequeBounce(List<Interim_Payments__c> newInterimPayments, Map<id,Interim_Payments__c> oldMap) {
        for(Interim_Payments__c interimPayment : newInterimPayments) {
            if(interimPayment.Cheque_Bounced_Interim__c == true && 
            interimPayment.Cheque_Bounced_Interim__c != oldMap.get(interimPayment.id).Cheque_Bounced_Interim__c ) {
                interimPayment.Approval_Status_Interim__c = 'Cheque Dishonoured';
            }
        }
    }
    
    public static void sendEmailChequeBounced(List<Interim_Payments__c> newInterimPayments, Map<id,Interim_Payments__c> oldMap) {
        set<Id> bookingIds = new set<Id>();
        set<Id> interimPayIds = new set<Id>();
        for(Interim_Payments__c interimPayment : newInterimPayments) {
            if(interimPayment.Cheque_Bounced_Interim__c == true && 
               interimPayment.Cheque_Bounced_Interim__c != oldMap.get(interimPayment.id).Cheque_Bounced_Interim__c &&
               !String.isBlank(interimPayment.Bounced_Reason__c) &&
               interimPayment.Bounced_Reason__c != oldMap.get(interimPayment.id).Bounced_Reason__c) {
                   bookingIds.add(interimPayment.Application_Booking_Interim__c);
                   interimPayIds.add(interimPayment.Id);
               }
        }
        System.debug('interimPayIds***'+interimPayIds);
        System.debug('bookingIds***'+bookingIds);
        if(!interimPayIds.isEmpty() && !bookingIds.isEmpty()) {
            InterimPaymentsTriggerHandler.sendEmailCustomer(interimPayIds,bookingIds);
        }
        if(!interimPayIds.isEmpty()) {
            InterimPaymentsTriggerHandler.sendEmailCollection(interimPayIds);
        }
    }
    
    @future
    public static void sendEmailCustomer(set<Id> interimIds,set<Id> bookingIds) {
        System.debug('interimIds***'+interimIds);
        System.debug('bookingIds***'+bookingIds);
        List<Interim_Payments__c> scope = new List<Interim_Payments__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        String tempId = '';
        String fromaddress = '';
        String owdId = '';
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                             FROM EmailTemplate 
                                             WHERE DeveloperName =: 'Cheque_Bounced_for_Property'];
        if(!emailTemplate.isEmpty()) {
            tempId = emailTemplate[0].Id;
        }
        Map<Id, Id> intPrMap = new Map<Id, Id>();
        System.debug('tempId***'+tempId);
        if(!interimIds.isEmpty() && !bookingIds.isEmpty()) {
            scope = [SELECT Id,Application_Booking_Interim__c,Application_Booking_Interim__r.PropStrength__Primary_Customer__c,
                     Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c, Payment_Request__c 
                     FROM Interim_Payments__c 
                     WHERE Id IN: interimIds
                     AND Application_Booking_Interim__c IN: bookingIds];
            for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c IN: bookingIds AND PropStrength__Active__c =: true AND PropStrength__Applicant_Acc__c != null]) {
                if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                    List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                    newPLI.add(appLicant);
                    applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                } else {
                    applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                }
            }
        }
        System.debug('scope***'+scope);
        System.debug('applicantListMap***'+applicantListMap);
        if(!scope.isEmpty()) {
            if(!applicantListMap.isEmpty()) {
                for(Interim_Payments__c ppd : scope) {
                    if(ppd.Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c != null) {
                        fromaddress = ppd.Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c;
                    }
                    if(applicantListMap.containskey(ppd.Application_Booking_Interim__c)) {
                        for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.Application_Booking_Interim__c)) {
                            if(applicant.PropStrength__Type__c == '1st Applicant') {
                                sendTo.add(applicant.PropStrength__Applicant_Email__c);
                            }
                            if(applicant.PropStrength__Type__c != '1st Applicant') {
                                ccList.add(applicant.PropStrength__Applicant_Email__c);
                            }
                        }
                    }
                    if(ppd.Payment_Request__c != null) {
                        intPrMap.put(ppd.Id, ppd.Payment_Request__c);
                    }
                }
                Map<Id, List<Attachment>> payReqMap = new Map<Id, List<Attachment>>();
                if(!intPrMap.isEmpty()) {
                    List<Attachment> attList = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN :intPrMap.values()];
                    for(Attachment att : attList) {
                        if(payReqMap.containsKey(att.ParentId)) {
                            payReqMap.get(att.ParentId).add(att);
                        } else {
                            payReqMap.put(att.ParentId, new List<Attachment>{att});
                        }
                    }
                }
                if(!String.isBlank(fromaddress)) {
                    List<OrgWideEmailAddress> orgwd = new List<OrgWideEmailAddress>([select id, Address from OrgWideEmailAddress where Address =: fromaddress LIMIT 1]);
                    if(!orgwd.isEmpty()) {
                        owdId = orgwd[0].Id;
                    }
                }
                System.debug('sendTo***'+sendTo);
                System.debug('ccList***'+ccList);
                for(Interim_Payments__c ppd : scope) {
                    List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(!sendTo.isEmpty()) {
                        email.setToAddresses(sendTo);
                    }
                    if(!ccList.isEmpty()) {
                        email.setCcAddresses(ccList);
                    }
                    if(String.isNotblank(owdId))
                    	email.setOrgWideEmailAddressId(owdId);
                    email.setWhatId(ppd.id);
                    email.setTargetObjectId(ppd.Application_Booking_Interim__r.PropStrength__Primary_Customer__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.saveAsActivity = true;
                    if(String.isNotblank(tempId))
                    	email.setTemplateId(tempId);

                    if(ppd.Payment_Request__c != null && payReqMap != null && !payReqMap.isEmpty() && payReqMap.containskey(ppd.Payment_Request__c) && !payReqMap.get(ppd.Payment_Request__c).isEmpty()){
                        for(Attachment att : payReqMap.get(ppd.Payment_Request__c)) {
                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                            efa.setFileName(att.Name);
                            efa.setBody(att.Body);
                            efalst.add(efa);
                        }
                        if(!efalst.isEmpty()) {
                            email.setFileAttachments(efalst);
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
    
    @future
    public static void sendEmailCollection(set<Id> interimIds) {
        if(!interimIds.isEmpty()) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<String> sendTo = new List<String>(); 
            String tempId = '';
            String fromaddress = '';
            String owdId = '';
            List<Interim_Payments__c> interimList = [SELECT Id,Application_Booking_Interim__r.PropStrength__Primary_Customer__c,Payment_Request__c,
                                                     Application_Booking_Interim__c,Application_Booking_Interim__r.PropStrength__Project__c,
                                                     Application_Booking_Interim__r.PropStrength__Project__r.CL_User_1__r.Email,
                                                     Application_Booking_Interim__r.PropStrength__Project__r.CL_User_1__c,
                                                     Application_Booking_Interim__r.PropStrength__Project__r.CL_User_2__c,
                                                     Application_Booking_Interim__r.PropStrength__Project__r.CL_User_3__c,
                                                     Application_Booking_Interim__r.PropStrength__Project__r.CL_User_4__c,
                                                     Application_Booking_Interim__r.PropStrength__Project__r.CL_User_2__r.Email,
                                                     Application_Booking_Interim__r.PropStrength__Project__r.CL_User_3__r.Email,
                                                     Application_Booking_Interim__r.PropStrength__Project__r.CL_User_4__r.Email,
                                                     Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c
                                                     FROM Interim_Payments__c 
                                                     WHERE Id IN: interimIds];
            if(!interimList.isEmpty()) {
                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     FROM EmailTemplate 
                                                     WHERE DeveloperName =: 'Cheque_Bounced_for_Property'];
                if(!emailTemplate.isEmpty()) {
                    tempId = emailTemplate[0].Id;
                }
            }

            Map<Id, Id> intPrMap = new Map<Id, Id>();

            for(Interim_Payments__c ppd : interimList) {
                if(ppd.Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c != null) {
                    fromaddress = ppd.Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c;
                }
                if(ppd.Application_Booking_Interim__r.PropStrength__Project__r.CL_User_1__c != null) {
                    sendTo.add(ppd.Application_Booking_Interim__r.PropStrength__Project__r.CL_User_1__r.Email);
                }
                if(ppd.Application_Booking_Interim__r.PropStrength__Project__r.CL_User_2__c != null) {
                    sendTo.add(ppd.Application_Booking_Interim__r.PropStrength__Project__r.CL_User_2__r.Email);
                }
                if(ppd.Application_Booking_Interim__r.PropStrength__Project__r.CL_User_3__c != null) {
                    sendTo.add(ppd.Application_Booking_Interim__r.PropStrength__Project__r.CL_User_3__r.Email);
                }
                if(ppd.Application_Booking_Interim__r.PropStrength__Project__r.CL_User_4__c != null) {
                    sendTo.add(ppd.Application_Booking_Interim__r.PropStrength__Project__r.CL_User_4__r.Email);
                }
                if(ppd.Payment_Request__c != null) {
                    intPrMap.put(ppd.Id, ppd.Payment_Request__c);
                }
            }
            Map<Id, List<Attachment>> payReqMap = new Map<Id, List<Attachment>>();
            if(!intPrMap.isEmpty()) {
                List<Attachment> attList = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN :intPrMap.values()];
                for(Attachment att : attList) {
                    if(payReqMap.containsKey(att.ParentId)) {
                        payReqMap.get(att.ParentId).add(att);
                    } else {
                        payReqMap.put(att.ParentId, new List<Attachment>{att});
                    }
                }

            }
            if(!String.isBlank(fromaddress)) {
                List<OrgWideEmailAddress> orgwd = new List<OrgWideEmailAddress>([select id, Address from OrgWideEmailAddress where Address =: fromaddress LIMIT 1]);
                if(!orgwd.isEmpty()) {
                    owdId = orgwd[0].Id;
                }
            }
            for(Interim_Payments__c ppd : interimList) {
                List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                if(String.isNotblank(owdId))
                	email.setOrgWideEmailAddressId(owdId);
                email.setWhatId(ppd.id);
                email.setTargetObjectId(ppd.Application_Booking_Interim__r.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.setSaveAsActivity(true); 
                if(String.isNotblank(tempId))
                	email.setTemplateId(tempId);

                if(ppd.Payment_Request__c != null && payReqMap != null && !payReqMap.isEmpty() && payReqMap.containskey(ppd.Payment_Request__c) && !payReqMap.get(ppd.Payment_Request__c).isEmpty()){
                    for(Attachment att : payReqMap.get(ppd.Payment_Request__c)) {
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(att.Name);
                        efa.setBody(att.Body);
                        efalst.add(efa);
                    }
                    if(!efalst.isEmpty()) {
                        email.setFileAttachments(efalst);
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
    
    public static void createPaymentRecords(List<Interim_Payments__c> newInterimPayments, Map<id,Interim_Payments__c> oldMap) {
        Id receivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id incomeReceivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId();
        System.debug('incomeReceivedRecordTypeId::'+incomeReceivedRecordTypeId);
        System.debug('receivedRecordTypeId::'+receivedRecordTypeId);
        List<PropStrength__Received_Payment__c> paymentsToCreate = new List<PropStrength__Received_Payment__c>();
        List<Interim_Payments__c> intPayUpdChequeBounce = new List<Interim_Payments__c>();
        map<Id,PropStrength__Income_Charges__c> incomeChargesMap = new map<Id,PropStrength__Income_Charges__c>();
        set<Id> interimIds = new set<Id>();
        set<Id> projectIds = new set<Id>();
        set<Id> paymentRequestId = new set<Id>();
        Map<Id, Payment_Request__c> payReqMap = new Map<Id, Payment_Request__c>();

        for(Interim_Payments__c interimPayment : newInterimPayments) {
            if(oldMap != null){
                if(interimPayment.Cheque_Bounced_Interim__c == true && interimPayment.Payment_Request__c != null && 
                interimPayment.Cheque_Bounced_Interim__c != oldMap.get(interimPayment.id).Cheque_Bounced_Interim__c && 
                (interimPayment.RecordTypeId == incomeReceivedRecordTypeId ||
                interimPayment.RecordTypeId == receivedRecordTypeId)) {
                    paymentRequestId.add(interimPayment.Payment_Request__c);
                }
            }
        }

        if(!paymentRequestId.isEmpty()) {
            payReqMap = new Map<Id, Payment_Request__c>([SELECT Id, 
                        (SELECT Id, Bounced_Reason__c FROM Interim_Payments_Received__r WHERE Cheque_Bounced_Interim__c = false AND (RecordTypeId = :receivedRecordTypeId OR RecordTypeId = :incomeReceivedRecordTypeId) AND (NOT (Id IN :oldMap.keySet())) ) 
                        FROM Payment_Request__c WHERE Id IN :paymentRequestId]);
        }

        System.debug('payReqMap*****');
        System.debug(payReqMap);

        for(Interim_Payments__c interimPayment : newInterimPayments) {
            if(oldMap == null){
                if(interimPayment.Approval_Status_Interim__c == 'Approved'){
                    interimIds.add(interimPayment.id);
                }                
            }
            else{
                if(interimPayment.Approval_Status_Interim__c == 'Approved' && interimPayment.Instrument_Date__c != null &&
                   interimPayment.Approval_Status_Interim__c != oldMap.get(interimPayment.id).Approval_Status_Interim__c && 
                   interimPayment.RecordTypeId == receivedRecordTypeId) {
                       interimIds.add(interimPayment.id);
                   } else if(interimPayment.Approval_Status_Interim__c == 'Approved' && interimPayment.Instrument_Date__c != null &&
                             interimPayment.Approval_Status_Interim__c != oldMap.get(interimPayment.id).Approval_Status_Interim__c && 
                             interimPayment.RecordTypeId == incomeReceivedRecordTypeId) {
                       interimIds.add(interimPayment.id);
                   } else if(interimPayment.Cheque_Bounced_Interim__c == true && 
                             interimPayment.Cheque_Bounced_Interim__c != oldMap.get(interimPayment.id).Cheque_Bounced_Interim__c && 
                             (interimPayment.RecordTypeId == incomeReceivedRecordTypeId ||
                             interimPayment.RecordTypeId == receivedRecordTypeId)) {
                       interimIds.add(interimPayment.id);
                  }
            }
        }
        System.debug('interimIds::'+interimIds);
        if(!interimIds.isEmpty()) {
            List<Interim_Payments__c> existingList = [SELECT Id,Cheque_Date__c,Receipt_Date__c,Cheque_Deposit_Date__c,Name,RecordTypeId,Amount_Type__c,Application_Booking_Interim__c,Payment_Plan_Detail_Interim__c,
                                                      Payment_Received_Interim__c,Instrument_Date_Interim__c,Payment_Date_Interim__c,
                                                      Amount_Interim__c,Cheque_Demand_Draft_Number_Interim__c,Payment__c,Payment_Request__c,
                                                      Payment_Mode_Interim__c,Transaction_Request_Interim__c,IFSC_RTGS_Code_Interim__c,
                                                      Bank_Name_Interim__c,Bank_Branch_Address_Interim__c,Description__c,Bank_Account_Number__c,
                                                      Bounced_Reason__c,Cheque_Bounced_Interim__c,Receipt_Reversed_Interim__c,
                                                      Application_Booking_Interim__r.PropStrength__Project__c, Bank_GL__c, Instrument_Date__c, 
                                                      GL_Date__c, Payment_Clearance_Date__c, Instrument_Number__c, Debit_Account__c , Credit_Account__c
                                                      FROM Interim_Payments__c 
                                                      WHERE Id IN: interimIds];
            if(!interimIds.isEmpty()) {
                for(Interim_Payments__c interimPayment : existingList) {
                    projectIds.add(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c);
                }
                if(!projectIds.isEmpty()) {
                    for(PropStrength__Income_Charges__c incomeCharge : [SELECT Id,PropStrength__Amount__c,PropStrength__Project__c,PropStrength__Category__c
                                                                        FROM PropStrength__Income_Charges__c WHERE PropStrength__Project__c IN: projectIds AND PropStrength__Category__c =: 'Cheque Bouncing Charges']) {
                                                                            incomeChargesMap.put(incomeCharge.PropStrength__Project__c,incomeCharge);
                                                                        }
                }
                Map<String,String> mapOfRecordTypeAndName = new Map<String,String>();
                mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId() ,'Payment Received');
                mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId() ,'Income Charge Due');
                mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId() ,'Income Charge Received');
                mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId() ,'Payment Due');
                List<Payment_Object_Metadata_CS__c> metaDataRec = Payment_Object_Metadata_CS__c.getAll().values();        
                Map<String,String> mapOfchargeAndamountType = new Map<String,String>();
                for(Payment_Object_Metadata_CS__c rec : metaDataRec){
                      mapOfchargeAndamountType.put(rec.Other_Charges_Type__c+''+rec.Record_type__c, rec.Amount_Type__c);
                }
                System.debug('incomeChargesMap::'+incomeChargesMap);
                System.debug('mapOfchargeAndamountType::'+mapOfchargeAndamountType);
                for(Interim_Payments__c interimPayment : existingList) {
                    if(interimPayment.RecordTypeId == receivedRecordTypeId && interimPayment.Cheque_Bounced_Interim__c == false) {
                        PropStrength__Received_Payment__c newPayment = new PropStrength__Received_Payment__c();
                        newPayment.RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
                        newPayment.Charge_Type__c = (!String.isBlank(interimPayment.Amount_Type__c) ? interimPayment.Amount_Type__c : '');
                        if(!String.isBlank(interimPayment.Amount_Type__c) && mapOfchargeAndamountType.containskey(interimPayment.Amount_Type__c+''+mapOfRecordTypeAndName.get(newPayment.RecordTypeId)))
                            newPayment.PropStrength__Amount_Due_Type__c = mapOfchargeAndamountType.get(interimPayment.Amount_Type__c+''+mapOfRecordTypeAndName.get(newPayment.RecordTypeId));
                        newPayment.PropStrength__Application_Booking__c = (interimPayment.Application_Booking_Interim__c != null) ? interimPayment.Application_Booking_Interim__c : null;
                        newPayment.PropStrength__Payment_Plan_Detail__c = (interimPayment.Payment_Plan_Detail_Interim__c != null) ? interimPayment.Payment_Plan_Detail_Interim__c : null; 
                        newPayment.PropStrength__Prorated_Payment_Received__c = (interimPayment.Payment_Received_Interim__c != null) ? interimPayment.Payment_Received_Interim__c : 0;
                        newPayment.PropStrength__Issue_Date__c = (interimPayment.Instrument_Date_Interim__c != null) ? interimPayment.Instrument_Date_Interim__c : null;
                        newPayment.PropStrength__Payment_Date__c = (interimPayment.Payment_Date_Interim__c != null) ? interimPayment.Payment_Date_Interim__c : null;
                        newPayment.PropStrength__Amount__c = (interimPayment.Amount_Interim__c != null) ? interimPayment.Amount_Interim__c : 0;
                        newPayment.PropStrength__Payment_Type__c = (!String.isBlank(interimPayment.Payment_Mode_Interim__c) ? interimPayment.Payment_Mode_Interim__c : '');
                        newPayment.PropStrength__Cheque_Demand_Draft_Number__c = (!String.isBlank(interimPayment.Cheque_Demand_Draft_Number_Interim__c) ? interimPayment.Cheque_Demand_Draft_Number_Interim__c : '');
                        newPayment.PropStrength__Transaction_Request__c = (interimPayment.Transaction_Request_Interim__c != null) ? interimPayment.Transaction_Request_Interim__c : null;
                        newPayment.PropStrength__IFSC_RTGS_Code__c = (!String.isBlank(interimPayment.IFSC_RTGS_Code_Interim__c) ? interimPayment.IFSC_RTGS_Code_Interim__c : '');
                        newPayment.PropStrength__Bank_Name_Auto__c = (!String.isBlank(interimPayment.Bank_Name_Interim__c) ? interimPayment.Bank_Name_Interim__c : '');
                        newPayment.PropStrength__Bank_Branch_Address__c = (!String.isBlank(interimPayment.Bank_Branch_Address_Interim__c) ? interimPayment.Bank_Branch_Address_Interim__c : '');
                        newPayment.PropStrength__Bank_Account_Number__c =  (!String.isBlank(interimPayment.Bank_Account_Number__c) ? interimPayment.Bank_Account_Number__c : '');
                        newPayment.PropStrength__Description__c = (!String.isBlank(interimPayment.Description__c) ? interimPayment.Description__c : '');
                        newPayment.PropStrength__Bounced_Reason__c = (!String.isBlank(interimPayment.Bounced_Reason__c) ? interimPayment.Bounced_Reason__c : '');
                        newPayment.PropStrength__Cheque_Bounced__c = (interimPayment.Cheque_Bounced_Interim__c == true ? true : false);
                        newPayment.Payment_Request__c =  (interimPayment.Payment_Request__c != null) ? interimPayment.Payment_Request__c : null;
                        newPayment.PropStrength__Receipt_Reversed__c = (interimPayment.Receipt_Reversed_Interim__c == true ? true : false);
                        newPayment.Interim_Payments_Received__c = interimPayment.Id;
                        newPayment.Bank_GL__c = interimPayment.Bank_GL__c;
                        newPayment.Instrument_Date__c = interimPayment.Instrument_Date__c;
                        newPayment.GL_Date__c = interimPayment.GL_Date__c;
                        {//Added by Pulkit
                            newPayment.Receipt_Date__c = interimPayment.Receipt_Date__c;
                            newPayment.Cheque_Date__c = interimPayment.Cheque_Date__c;
                            newPayment.Cheque_Deposit_Date__c = interimPayment.Cheque_Deposit_Date__c;
                        }
                        newPayment.Payment_Clearance_Date__c = interimPayment.Payment_Clearance_Date__c;
                        newPayment.Instrument_Number__c = interimPayment.Instrument_Number__c;
                        newPayment.Debit_Account_1__c = interimPayment.Debit_Account__c;
                        newPayment.Credit_Account_1__c = interimPayment.Credit_Account__c;
                        paymentsToCreate.add(newPayment);
                    } 
                    else if(interimPayment.RecordTypeId == incomeReceivedRecordTypeId && interimPayment.Cheque_Bounced_Interim__c == false) {
                        PropStrength__Received_Payment__c newPayment = new PropStrength__Received_Payment__c();
                        newPayment.RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
                        newPayment.PropStrength__Income_Charge_Due__c = (interimPayment.Payment__c != null ? interimPayment.Payment__c : null);
                        newPayment.Interim_Payments_Received__c = interimPayment.Id;
                        newPayment.Charge_Type__c = (!String.isBlank(interimPayment.Amount_Type__c) ? interimPayment.Amount_Type__c : '');
                        String str = interimPayment.Amount_Type__c+''+mapOfRecordTypeAndName.get(newPayment.RecordTypeId);
                        System.debug(interimPayment.Amount_Type__c+'interimPayment.Amount_Type__c*---'+str);
                        if(!String.isBlank(interimPayment.Amount_Type__c) && mapOfchargeAndamountType.containskey(interimPayment.Amount_Type__c+''+mapOfRecordTypeAndName.get(newPayment.RecordTypeId))) {
                            newPayment.PropStrength__Amount_Due_Type__c = mapOfchargeAndamountType.get(interimPayment.Amount_Type__c+''+mapOfRecordTypeAndName.get(newPayment.RecordTypeId));
                        }
                        newPayment.PropStrength__Application_Booking__c = (interimPayment.Application_Booking_Interim__c != null) ? interimPayment.Application_Booking_Interim__c : null;
                        newPayment.PropStrength__Payment_Plan_Detail__c = (interimPayment.Payment_Plan_Detail_Interim__c != null) ? interimPayment.Payment_Plan_Detail_Interim__c : null; 
                        newPayment.PropStrength__Prorated_Payment_Received__c = (interimPayment.Payment_Received_Interim__c != null) ? interimPayment.Payment_Received_Interim__c : 0;
                        newPayment.PropStrength__Issue_Date__c = (interimPayment.Instrument_Date_Interim__c != null) ? interimPayment.Instrument_Date_Interim__c : null;
                        newPayment.PropStrength__Payment_Date__c = (interimPayment.Payment_Date_Interim__c != null) ? interimPayment.Payment_Date_Interim__c : null;
                        newPayment.PropStrength__Amount__c = (interimPayment.Amount_Interim__c != null) ? interimPayment.Amount_Interim__c : 0;
                        newPayment.PropStrength__Payment_Type__c = (!String.isBlank(interimPayment.Payment_Mode_Interim__c) ? interimPayment.Payment_Mode_Interim__c : '');
                        newPayment.PropStrength__Cheque_Demand_Draft_Number__c = (!String.isBlank(interimPayment.Cheque_Demand_Draft_Number_Interim__c) ? interimPayment.Cheque_Demand_Draft_Number_Interim__c : '');
                        newPayment.PropStrength__Transaction_Request__c = (interimPayment.Transaction_Request_Interim__c != null) ? interimPayment.Transaction_Request_Interim__c : null;
                        newPayment.PropStrength__IFSC_RTGS_Code__c = (!String.isBlank(interimPayment.IFSC_RTGS_Code_Interim__c) ? interimPayment.IFSC_RTGS_Code_Interim__c : '');
                        newPayment.PropStrength__Bank_Name_Auto__c = (!String.isBlank(interimPayment.Bank_Name_Interim__c) ? interimPayment.Bank_Name_Interim__c : '');
                        newPayment.PropStrength__Bank_Branch_Address__c = (!String.isBlank(interimPayment.Bank_Branch_Address_Interim__c) ? interimPayment.Bank_Branch_Address_Interim__c : '');
                        newPayment.PropStrength__Bank_Account_Number__c =  (!String.isBlank(interimPayment.Bank_Account_Number__c) ? interimPayment.Bank_Account_Number__c : '');
                        newPayment.PropStrength__Description__c = (!String.isBlank(interimPayment.Description__c) ? interimPayment.Description__c : '');
                        newPayment.PropStrength__Bounced_Reason__c = (!String.isBlank(interimPayment.Bounced_Reason__c) ? interimPayment.Bounced_Reason__c : '');
                        newPayment.PropStrength__Cheque_Bounced__c = (interimPayment.Cheque_Bounced_Interim__c == true ? true : false);
                        newPayment.Payment_Request__c =  (interimPayment.Payment_Request__c != null) ? interimPayment.Payment_Request__c : null;
                        newPayment.PropStrength__Receipt_Reversed__c = (interimPayment.Receipt_Reversed_Interim__c == true ? true : false);
                        newPayment.Bank_GL__c = interimPayment.Bank_GL__c;
                        newPayment.Instrument_Date__c = interimPayment.Instrument_Date__c;
                        newPayment.GL_Date__c = interimPayment.GL_Date__c;
                        {//Added by Pulkit
                            newPayment.Receipt_Date__c = interimPayment.Receipt_Date__c;
                            newPayment.Cheque_Date__c = interimPayment.Cheque_Date__c;
                            newPayment.Cheque_Deposit_Date__c = interimPayment.Cheque_Deposit_Date__c;

                        }
                        newPayment.Payment_Clearance_Date__c = interimPayment.Payment_Clearance_Date__c;
                        newPayment.Instrument_Number__c = interimPayment.Instrument_Number__c;
                        newPayment.Debit_Account_1__c = interimPayment.Debit_Account__c;
                        newPayment.Credit_Account_1__c = interimPayment.Credit_Account__c;
                        paymentsToCreate.add(newPayment);                    
                    } 
                    else if((interimPayment.RecordTypeId == incomeReceivedRecordTypeId || interimPayment.RecordTypeId == receivedRecordTypeId) && interimPayment.Cheque_Bounced_Interim__c == true) {
                        if(incomeChargesMap.containsKey(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c)) {
                            PropStrength__Received_Payment__c newPayment = new PropStrength__Received_Payment__c();
                            newPayment.RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
                            /*newPayment.PropStrength__Amount_Due_Type__c = (incomeChargesMap.get(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c).PropStrength__Category__c != null && incomeChargesMap.get(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c).PropStrength__Category__c != '') ?
                                										  incomeChargesMap.get(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c).PropStrength__Category__c : '';*/
                            newPayment.Charge_Type__c = (!String.isBlank(interimPayment.Amount_Type__c) ? interimPayment.Amount_Type__c : '');
                            if(!String.isBlank(interimPayment.Amount_Type__c) && mapOfchargeAndamountType.containskey(interimPayment.Amount_Type__c+''+mapOfRecordTypeAndName.get(newPayment.RecordTypeId))) {
                                newPayment.PropStrength__Amount_Due_Type__c = mapOfchargeAndamountType.get(interimPayment.Amount_Type__c+''+mapOfRecordTypeAndName.get(newPayment.RecordTypeId));
                            }  else {
                                newPayment.PropStrength__Amount_Due_Type__c = (incomeChargesMap.get(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c).PropStrength__Category__c != null && incomeChargesMap.get(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c).PropStrength__Category__c != '') ?
                                										  incomeChargesMap.get(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c).PropStrength__Category__c : '';
                            }
                            newPayment.PropStrength__Application_Booking__c = (interimPayment.Application_Booking_Interim__c != null) ? interimPayment.Application_Booking_Interim__c : null;
                            newPayment.PropStrength__Payment_Plan_Detail__c = (interimPayment.Payment_Plan_Detail_Interim__c != null) ? interimPayment.Payment_Plan_Detail_Interim__c : null; 
                            //newPayment.PropStrength__Prorated_Payment_Received__c = (interimPayment.Payment_Received_Interim__c != null) ? interimPayment.Payment_Received_Interim__c : 0;
                            //newPayment.PropStrength__Issue_Date__c = (interimPayment.Instrument_Date_Interim__c != null) ? interimPayment.Instrument_Date_Interim__c : null;
                            newPayment.PropStrength__Payment_Date__c = Date.Today();
                            newPayment.PropStrength__Actual_Payment_Date__c = Date.Today();
                            newPayment.PropStrength__Demand_Generation_Date__c = Date.Today();
                            newPayment.PropStrength__Demand_Generated__c = true;
                            newPayment.PropStrength__Demand_Email_Sent__c = true;
                            newPayment.PropStrength__Demand_Status__c = 'Demand Generated'; 
                            newPayment.PropStrength__Amount__c = (incomeChargesMap.get(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c).PropStrength__Amount__c != null) ?
                                								  incomeChargesMap.get(interimPayment.Application_Booking_Interim__r.PropStrength__Project__c).PropStrength__Amount__c : 0;
                            //newPayment.PropStrength__Payment_Type__c = (!String.isBlank(interimPayment.Payment_Mode_Interim__c) ? interimPayment.Payment_Mode_Interim__c : '');
                            //newPayment.PropStrength__Cheque_Demand_Draft_Number__c = (!String.isBlank(interimPayment.Cheque_Demand_Draft_Number_Interim__c) ? interimPayment.Cheque_Demand_Draft_Number_Interim__c : '');
                            //newPayment.PropStrength__Transaction_Request__c = (interimPayment.Transaction_Request_Interim__c != null) ? interimPayment.Transaction_Request_Interim__c : null;
                            //newPayment.PropStrength__IFSC_RTGS_Code__c = (!String.isBlank(interimPayment.IFSC_RTGS_Code_Interim__c) ? interimPayment.IFSC_RTGS_Code_Interim__c : '');
                            //newPayment.PropStrength__Bank_Name_Auto__c = (!String.isBlank(interimPayment.Bank_Name_Interim__c) ? interimPayment.Bank_Name_Interim__c : '');
                            //newPayment.PropStrength__Bank_Branch_Address__c = (!String.isBlank(interimPayment.Bank_Branch_Address_Interim__c) ? interimPayment.Bank_Branch_Address_Interim__c : '');
                            //newPayment.PropStrength__Bank_Account_Number__c =  (!String.isBlank(interimPayment.Bank_Account_Number__c) ? interimPayment.Bank_Account_Number__c : '');
                            //newPayment.PropStrength__Description__c = (!String.isBlank(interimPayment.Description__c) ? interimPayment.Description__c : '');
                            //newPayment.PropStrength__Bounced_Reason__c = (!String.isBlank(interimPayment.Bounced_Reason__c) ? interimPayment.Bounced_Reason__c : '');
                            newPayment.PropStrength__Cheque_Bounced__c = (interimPayment.Cheque_Bounced_Interim__c == true ? true : false);
                            newPayment.Payment_Request__c =  (interimPayment.Payment_Request__c != null) ? interimPayment.Payment_Request__c : null;
                            newPayment.Interim_Payments_Received__c = interimPayment.Id;
                            newPayment.Bank_GL__c = interimPayment.Bank_GL__c;
                            newPayment.Instrument_Date__c = interimPayment.Instrument_Date__c;
                            newPayment.GL_Date__c = interimPayment.GL_Date__c;
                            {//Added by Pulkit
                                newPayment.Receipt_Date__c = interimPayment.Receipt_Date__c;
                                newPayment.Cheque_Date__c = interimPayment.Cheque_Date__c;
                            }
                           newPayment.Payment_Clearance_Date__c = interimPayment.Payment_Clearance_Date__c;
                            newPayment.Instrument_Number__c = interimPayment.Instrument_Number__c;
                            newPayment.Debit_Account_1__c = interimPayment.Debit_Account__c;
                        	newPayment.Credit_Account_1__c = interimPayment.Credit_Account__c;
                            //newPayment.PropStrength__Receipt_Reversed__c = (interimPayment.Receipt_Reversed_Interim__c == true ? true : false);
                            paymentsToCreate.add(newPayment);

                            if(!payReqMap.isEmpty() && interimPayment.Payment_Request__c != null && payReqMap.containsKey(interimPayment.Payment_Request__c)) {
                                if(!payReqMap.get(interimPayment.Payment_Request__c).Interim_Payments_Received__r.isEmpty()) {
                                    for(Interim_Payments__c ip : payReqMap.get(interimPayment.Payment_Request__c).Interim_Payments_Received__r) {
                                        intPayUpdChequeBounce.add(new Interim_Payments__c(Id = ip.Id, Cheque_Bounced_Interim__c = true, Bounced_Reason__c = interimPayment.Bounced_Reason__c, Approval_Status_Interim__c = 'Cheque Dishonoured'));
                                    }
                                }
                            }
                        }                    
                    }
                }
                System.debug('paymentsToCreate::'+paymentsToCreate);
                System.debug('intPayUpdChequeBounce::'+intPayUpdChequeBounce);
                if(!paymentsToCreate.isEmpty()) {
                    insert paymentsToCreate;
                    List<Database.SaveResult> saveResults = Database.insert(paymentsToCreate, false);
                    System.debug('saveResults::'+saveResults);
                    for(Integer i=0;i<saveResults.size();i++){
                        if(!saveResults.get(i).isSuccess()){
                            Database.Error error = saveResults.get(i).getErrors().get(0);
                            String failedDML = error.getMessage();
                            System.debug('Error::'+failedDML);
                        }
                    }
                }

                if(!intPayUpdChequeBounce.isEmpty()) {
                    isRun2 = false;
                    update intPayUpdChequeBounce;
                }
            }
        }
    }
    
    public static void sendEmailPaymentRequest(List<Interim_Payments__c> newInterimPayments) {
        set<Id> bookingIds = new set<Id>();
        set<Id> interimPayIds = new set<Id>();
        for(Interim_Payments__c interimPayment : newInterimPayments) {
            if(interimPayment.Interim_Payment_Type__c == 'Payment Request') {
                   bookingIds.add(interimPayment.Application_Booking_Interim__c);
                   interimPayIds.add(interimPayment.Id);
               }
        }
        if(!interimPayIds.isEmpty() && !bookingIds.isEmpty()) {
            InterimPaymentsTriggerHandler.sendEmailCustomerPayRec(interimPayIds,bookingIds);
        }
    }
    
    @future
    public static void sendEmailCustomerPayRec(set<Id> interimIds,set<Id> bookingIds) {
        List<Interim_Payments__c> scope = new List<Interim_Payments__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        String tempId = '';
        String fromaddress = '';
        String owdId = '';
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                             FROM EmailTemplate 
                                             WHERE DeveloperName =: 'Pay_Rec_Notification_to_Customer'];
        if(!emailTemplate.isEmpty()) {
            tempId = emailTemplate[0].Id;
        }
        if(!interimIds.isEmpty() && !bookingIds.isEmpty()) {
            scope = [SELECT Id,Application_Booking_Interim__c,Application_Booking_Interim__r.PropStrength__Primary_Customer__c,
                     Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c
                     FROM Interim_Payments__c 
                     WHERE Id IN: interimIds
                     AND Application_Booking_Interim__c IN: bookingIds];
            for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c IN: bookingIds AND PropStrength__Active__c =: true AND PropStrength__Applicant_Acc__c != null]) {
                if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                    List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                    newPLI.add(appLicant);
                    applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                } else {
                    applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                }
            }
        }
        if(!scope.isEmpty()) {
            if(!applicantListMap.isEmpty()) {
                for(Interim_Payments__c ppd : scope) {
                    if(ppd.Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c != null) {
                        fromaddress = ppd.Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c;
                    }
                    if(applicantListMap.containskey(ppd.Application_Booking_Interim__c)) {
                        for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.Application_Booking_Interim__c)) {
                            if(applicant.PropStrength__Type__c == '1st Applicant') {
                                sendTo.add(applicant.PropStrength__Applicant_Email__c);
                            }
                            if(applicant.PropStrength__Type__c != '1st Applicant') {
                                ccList.add(applicant.PropStrength__Applicant_Email__c);
                            }
                        }
                    }
                }
                if(!String.isBlank(fromaddress)) {
                    List<OrgWideEmailAddress> orgwd = new List<OrgWideEmailAddress>([select id, Address from OrgWideEmailAddress where Address =: fromaddress LIMIT 1]);
                    if(!orgwd.isEmpty()) {
                        owdId = orgwd[0].Id;
                    }
                }
                for(Interim_Payments__c ppd : scope) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(!sendTo.isEmpty()) {
                        email.setToAddresses(sendTo);
                    }
                    if(!ccList.isEmpty()) {
                        email.setCcAddresses(ccList);
                    }
                    if(String.isNotblank(owdId))
                    	email.setOrgWideEmailAddressId(owdId);
                    email.setWhatId(ppd.id);
                    email.setTargetObjectId(ppd.Application_Booking_Interim__r.PropStrength__Primary_Customer__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.saveAsActivity = true;
                    if(String.isNotblank(tempId))
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
    }

    //Added by Nishank Manwani on 29/01/2024 to send Mail to applicants when status is Cheque Hold Approved OR Cheque Replacement Approved
    public static void sendMailChequeReturn(List<Interim_Payments__c> ipList, Map<Id, Interim_Payments__c> oldIPRecMap) {
        Set<Id> ipFinalId = new Set<Id>();
        Set<Id> bookingId = new Set<Id>();

        for(Interim_Payments__c ip : ipList) {
            if(ip.Application_Booking_Interim__c != null && (ip.Approval_Status_Interim__c == 'Cheque Hold Approved' || ip.Approval_Status_Interim__c == 'Cheque Replacement Approved' || test.isRunningTest()) && ip.Approval_Status_Interim__c != oldIPRecMap.get(ip.Id).Approval_Status_Interim__c) {
                ipFinalId.add(ip.Id);
                bookingId.add(ip.Application_Booking_Interim__c);
            }
        }

        InterimPaymentsTriggerHandler.sendMailToApplicants(ipFinalId, bookingId);
    }

    @Future(Callout=true)
    public static void sendMailToApplicants(set<Id> interimIds,set<Id> bookingIds) {
        List<Interim_Payments__c> scope = new List<Interim_Payments__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        String tempId = '';
        String fromaddress = '';
        String owdId = '';
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Cheque_Return_Acknowledgement'];
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
             owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];


        if(!emailTemplate.isEmpty()) {
            tempId = emailTemplate[0].Id;
        }
        if(!interimIds.isEmpty() && !bookingIds.isEmpty()) {
            scope = [SELECT Id,Application_Booking_Interim__c,Application_Booking_Interim__r.PropStrength__Primary_Customer__c, 
                    Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c 
                    FROM Interim_Payments__c 
                    WHERE Id IN: interimIds
                    AND Application_Booking_Interim__c IN: bookingIds];
            for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c IN: bookingIds AND PropStrength__Active__c =: true AND PropStrength__Applicant_Acc__c != null]) {
                if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                    List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                    newPLI.add(appLicant);
                    applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                } else {
                    applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                }
            }
        }
        if(!scope.isEmpty()) {
            if(!applicantListMap.isEmpty()) {
                for(Interim_Payments__c ppd : scope) {
                    if(applicantListMap.containskey(ppd.Application_Booking_Interim__c)) {
                        for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.Application_Booking_Interim__c)) {
                            if(applicant.PropStrength__Type__c == '1st Applicant') {
                                sendTo.add(applicant.PropStrength__Applicant_Email__c);
                            } else if(applicant.PropStrength__Type__c != '1st Applicant') {
                                ccList.add(applicant.PropStrength__Applicant_Email__c);
                            }
                        }
                    }
                }
                for(Interim_Payments__c ppd : scope) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(!sendTo.isEmpty()) {
                        email.setToAddresses(sendTo);
                    }
                    if(!ccList.isEmpty()) {
                        email.setCcAddresses(ccList);
                    }
                    email.setWhatId(ppd.id);
                    email.setTargetObjectId(ppd.Application_Booking_Interim__r.PropStrength__Primary_Customer__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.setSaveAsActivity(true); 
                    if(String.isNotblank(tempId))
                    	email.setTemplateId(tempId);
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }

                    PageReference pdf = Page.ChequeReturnAcknowledgement;
                    pdf.getParameters().put('id', String.valueOf(ppd.Id));
                    Blob bPdf;
                    if(!Test.isRunningTest()) {
                        bPdf = pdf.getContentAsPDF();
                    } else {
                        bPdf = Blob.valueOf('Test');
                    }
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName('ChequeReturnAcknowledgement.pdf');
                    efa.setBody(bPdf);
                    efalst.add(efa);
                    email.setFileAttachments(efalst);
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
    
    public static boolean runOnce(){
        if(isRun) {
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }
    public static void updateApprovalStatus(List<Interim_Payments__c> ipList) {
        List<Interim_Payments__c> updateInterimPayment = new List<Interim_Payments__c>();
        for(Interim_Payments__c rec : ipList) {
            if(rec.Payment_Mode_Interim__c != 'Cheque' && rec.Payment_Mode_Interim__c != 'Credit Card' &&  rec.Payment_Mode_Interim__c != 'Website') {
                updateInterimPayment.add(new Interim_Payments__c(Id = rec.Id, Approval_Status_Interim__c = 'Approved'));
            }
        }
        if(!updateInterimPayment.isEmpty()) {
          //  update updateInterimPayment;
        }

    }

    public static void attachInterimReceipt(List<Interim_Payments__c> ipList) {
        Set<Id> ipIds = new Set<Id>();
        for(Interim_Payments__c rec : ipList) {
            ipIds.add(rec.Id);
        }
        if(ipIds.size() > 0 ) {
            attachInterim(ipIds);
        }
    }
    @future(callout=true)
    public static void attachInterim(Set<Id> ipList) {
        List<Attachment> aList = new List<Attachment>();
        List<Interim_Payments__c> interimPaymentList = [SELECT Id,Name,Application_Booking_Interim__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,Application_Booking_Interim__c,Application_Booking_Interim__r.Project_Name__c,
                                Cheque_Demand_Draft_Number_Interim__c,Payment_Mode_Interim__c,Payment_Date_Interim__c,Amount_Interim__c,Application_Booking_Interim__r.PropStrength__Applicant_Address__c,
                                Application_Booking_Interim__r.PropStrength__Primary_Customer__r.Country_Code__c,
                                Application_Booking_Interim__r.CRM_Executive_Email__c,Application_Booking_Interim__r.PropStrength__Primary_Customer__c,Application_Booking_Interim__r.PropStrength__Primary_Customer__r.MobilePhone,
                                Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c,Interim_Receipt_sent_to_customer__c,
                                Application_Booking_Interim__r.PropStrength__Project__c, Application_Booking_Interim__r.PropStrength__Property__r.PropStrength__Property_Name__c
                                FROM Interim_Payments__c WHERE Id IN: ipList];
        for(Interim_Payments__c rec : interimPaymentList) {
            String frameSrc = '';
            if(rec.Application_Booking_Interim__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                frameSrc = '/apex/InterimReceiptSiniya?id=' +rec.Id+'&type=Receipt';
            } else {
                frameSrc = '/apex/InterimReceipt?id=' +rec.Id+'&type=Receipt';
            }
            String aName = 'InterimReceipt';
            String nameSubstring = aName +'.pdf';
            PageReference p1 = new PageReference(frameSrc);
            Attachment a1 = new Attachment();
            a1.parentId = rec.Id; 
            a1.name = aName +'.pdf';
            if(!Test.isRunningTest()){
                a1.body = p1.getContentAsPDF();
            } else
                a1.body = Blob.valueof('Test');
            aList.add(a1); 
        }
        if(!aList.isEmpty()) {
            insert aList; 
        }
    }
    
    public static void populateValuesFromPR(List<Interim_Payments__c> ips){
        Map<Id,List<Interim_Payments__c>> parentPRs = new Map<Id,List<Interim_Payments__c>>();
        for(Interim_Payments__c ip : ips){
            if(String.isBlank(ip.Payment_Request__c)) continue;
            
            List<Interim_Payments__c> mappedIps = parentPRs.containsKey(ip.Payment_Request__c) ?  parentPRs.get(ip.Payment_Request__c) : new List<Interim_Payments__c>();
            mappedIps.add(ip);
            parentPRs.put(ip.Payment_Request__c,mappedIps);
        }
        
        Map<Id,SObject> prMap = new Map<Id,SObject>(Database.queryWithBinds('SELECT CreatedDate,id,Account_Received_Date__c,Date_of_Initiation__c,Cheque_Date__c,Instrument_Date__c,Mode__c FROM Payment_Request__c WHERE Id IN :prIds AND (NOT Mode__c IN :modesToAvoid)',new Map<String,Object>{'prIds'=>parentPRs.keyset(),'modesToAvoid'=> new List<String>{''}},AccessLevel.SYSTEM_MODE));
        for(Id prId : prMap.keySet()){
            Payment_Request__c queriedPR = (Payment_Request__c) prMap.get(prId);
            for(Interim_Payments__c ip : parentPRs.get(prId)){
                ip.GL_Date__c = (queriedPR.Mode__c != 'Cheque' && queriedPR.Mode__c != 'CDM Cheque (Cheque Deposit in Machine)'&& queriedPR.Mode__c != 'Credit Card' && ip.GL_Date__c == NULL && queriedPR.Account_Received_Date__c != NULL) ? queriedPR.Account_Received_Date__c : ip.GL_Date__c;
                ip.Receipt_Date__c = queriedPR.createdDAte;
                if(queriedPR.Mode__c == 'IWT(International)' || queriedPR.Mode__c == 'DWT(Domestic)' || queriedPR.Mode__c == 'CDM Cash (Cash Deposit in Machine)'){
                    ip.Cheque_Date__c = queriedPR.Date_of_Initiation__c;
                }else if(queriedPR.Mode__c == 'Cheque'){
                    ip.Cheque_Date__c = queriedPR.Cheque_Date__c;
                }else if(queriedPR.Mode__c == 'OTC Deposits(Cash counter)' || queriedPR.Mode__c == 'Credit Card' || queriedPR.Mode__c == 'CDM Cheque (Cheque Deposit in Machine)'){
                    ip.Cheque_Date__c = queriedPR.Instrument_Date__c;
                }else if(queriedPR.Mode__c == 'Website'){
                    ip.Cheque_Date__c = queriedPR.CreatedDate;
                }
            }
            
        }
    }

    //Added by Nishank Manwani on 18/07/2024 to update all the rest PR if status is change
    public static void updateRestIpOnPR(List<Interim_Payments__c> intPayList, Map<Id, Interim_Payments__c> oldIntPayMap) {
        Id receivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id incomeReceivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId();
        System.debug('incomeReceivedRecordTypeId::'+incomeReceivedRecordTypeId);
        System.debug('receivedRecordTypeId::'+receivedRecordTypeId);

        List<Interim_Payments__c> intPayUpdChequeBounce = new List<Interim_Payments__c>();
        set<Id> paymentRequestId = new set<Id>();
        Map<Id, Payment_Request__c> payReqMap = new Map<Id, Payment_Request__c>();

        for(Interim_Payments__c interimPayment : intPayList) {
            if(oldIntPayMap != null){
                if(interimPayment.Approval_Status_Interim__c == 'Submitted for Cheque Hold' && interimPayment.Submit_for_Check_Hold__c && interimPayment.Approval_Status_Interim__c != oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c && (interimPayment.RecordTypeId == incomeReceivedRecordTypeId || interimPayment.RecordTypeId == receivedRecordTypeId)) {
                    paymentRequestId.add(interimPayment.Payment_Request__c);
                }
            }
        }

        if(!paymentRequestId.isEmpty()) {
            payReqMap = new Map<Id, Payment_Request__c>([SELECT Id, 
                        (SELECT Id, Bounced_Reason__c FROM Interim_Payments_Received__r WHERE Submit_for_Check_Hold__c = false AND (RecordTypeId = :receivedRecordTypeId OR RecordTypeId = :incomeReceivedRecordTypeId) AND (NOT (Id IN :oldIntPayMap.keySet())) ) 
                        FROM Payment_Request__c WHERE Id IN :paymentRequestId]);

            System.debug('payReqMap*****');
            System.debug(payReqMap);

            if(!payReqMap.isEmpty()) {
                for(Id payReqId : payReqMap.keySet()) {
                    if(!payReqMap.get(payReqId).Interim_Payments_Received__r.isEmpty()) {
                        for(Interim_Payments__c ip : payReqMap.get(payReqId).Interim_Payments_Received__r) {
                            intPayUpdChequeBounce.add(new Interim_Payments__c(Id=ip.Id, Approval_Status_Interim__c = 'Submitted for Cheque Hold', Submit_for_Check_Hold__c = true));
                        }
                    }
                }

                System.debug('intPayUpdChequeBounce*****');
                System.debug(intPayUpdChequeBounce);

                if(!intPayUpdChequeBounce.isEmpty()) {
                    isRun3 = false;
                    update intPayUpdChequeBounce;
                }
            }
        }
    }

    //Added by Nishank Manwani on 18/07/2024 to update all the rest PR if status is change
    public static void updateRestIpOnPR2(List<Interim_Payments__c> intPayList, Map<Id, Interim_Payments__c> oldIntPayMap) {
        Id receivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id incomeReceivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId();
        System.debug('incomeReceivedRecordTypeId::'+incomeReceivedRecordTypeId);
        System.debug('receivedRecordTypeId::'+receivedRecordTypeId);

        List<Interim_Payments__c> intPayUpdChequeBounce = new List<Interim_Payments__c>();
        set<Id> paymentRequestId = new set<Id>();
        Map<Id, Payment_Request__c> payReqMap = new Map<Id, Payment_Request__c>();

        for(Interim_Payments__c interimPayment : intPayList) {
            if(oldIntPayMap != null){
                if(oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c == 'Cheque Hold Approved' && interimPayment.Submit_for_Check_Hold__c && 
                interimPayment.Approval_Status_Interim__c != oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c && 
                (interimPayment.RecordTypeId == incomeReceivedRecordTypeId ||
                interimPayment.RecordTypeId == receivedRecordTypeId)) {
                    paymentRequestId.add(interimPayment.Payment_Request__c);
                }
            }
        }

        if(!paymentRequestId.isEmpty()) {
            payReqMap = new Map<Id, Payment_Request__c>([SELECT Id, 
                        (SELECT Id, Bounced_Reason__c FROM Interim_Payments_Received__r WHERE (RecordTypeId = :receivedRecordTypeId OR RecordTypeId = :incomeReceivedRecordTypeId) AND (NOT (Id IN :oldIntPayMap.keySet())) ) 
                        FROM Payment_Request__c WHERE Id IN :paymentRequestId]);

            System.debug('payReqMap*****');
            System.debug(payReqMap);

            if(!payReqMap.isEmpty()) {
                for(Interim_Payments__c interimPayment : intPayList) {
                    if(oldIntPayMap != null){
                        if(oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c == 'Cheque Hold Approved' && interimPayment.Submit_for_Check_Hold__c && 
                        interimPayment.Approval_Status_Interim__c != oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c && 
                        (interimPayment.RecordTypeId == incomeReceivedRecordTypeId ||
                        interimPayment.RecordTypeId == receivedRecordTypeId)) {
                            if(interimPayment.Payment_Request__c!= null && payReqMap.containsKey(interimPayment.Payment_Request__c) && !payReqMap.get(interimPayment.Payment_Request__c).Interim_Payments_Received__r.isEmpty()) {
                                for(Interim_Payments__c ip : payReqMap.get(interimPayment.Payment_Request__c).Interim_Payments_Received__r) {
                                    intPayUpdChequeBounce.add(new Interim_Payments__c(Id=ip.Id, Approval_Status_Interim__c = interimPayment.Approval_Status_Interim__c, Submit_for_Check_Hold__c = true));
                                }
                            }
                        }
                    }
                }

                System.debug('intPayUpdChequeBounce*****');
                System.debug(intPayUpdChequeBounce);

                if(!intPayUpdChequeBounce.isEmpty()) {
                    isRun4 = false;
                    update intPayUpdChequeBounce;
                }
            }
        }
    }

    //Added by Nishank Manwani on 18/07/2024 to update all the rest PR if status is change
    public static void updateRestIpOnPR3(List<Interim_Payments__c> intPayList, Map<Id, Interim_Payments__c> oldIntPayMap) {
        Id receivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id incomeReceivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId();
        System.debug('incomeReceivedRecordTypeId::'+incomeReceivedRecordTypeId);
        System.debug('receivedRecordTypeId::'+receivedRecordTypeId);

        List<Interim_Payments__c> intPayUpdChequeBounce = new List<Interim_Payments__c>();
        set<Id> paymentRequestId = new set<Id>();
        Map<Id, Payment_Request__c> payReqMap = new Map<Id, Payment_Request__c>();

        for(Interim_Payments__c interimPayment : intPayList) {
            if(oldIntPayMap != null){
                if(interimPayment.Approval_Status_Interim__c == 'Submitted for Cheque Replacement' && interimPayment.Submit_for_Cheque_Replacement_Approval__c && 
                interimPayment.Approval_Status_Interim__c != oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c && 
                (interimPayment.RecordTypeId == incomeReceivedRecordTypeId ||
                interimPayment.RecordTypeId == receivedRecordTypeId)) {
                    paymentRequestId.add(interimPayment.Payment_Request__c);
                }
            }
        }

        if(!paymentRequestId.isEmpty()) {
            payReqMap = new Map<Id, Payment_Request__c>([SELECT Id, 
                        (SELECT Id FROM Interim_Payments_Received__r WHERE Submit_for_Cheque_Replacement_Approval__c = false AND (RecordTypeId = :receivedRecordTypeId OR RecordTypeId = :incomeReceivedRecordTypeId) AND (NOT (Id IN :oldIntPayMap.keySet())) ) 
                        FROM Payment_Request__c WHERE Id IN :paymentRequestId]);

            System.debug('payReqMap*****');
            System.debug(payReqMap);

            if(!payReqMap.isEmpty()) {
                for(Interim_Payments__c interimPayment : intPayList) {
                    if(oldIntPayMap != null){
                        if(interimPayment.Approval_Status_Interim__c == 'Submitted for Cheque Replacement' && interimPayment.Submit_for_Cheque_Replacement_Approval__c && 
                        interimPayment.Approval_Status_Interim__c != oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c && 
                        (interimPayment.RecordTypeId == incomeReceivedRecordTypeId ||
                        interimPayment.RecordTypeId == receivedRecordTypeId)) {
                            if(interimPayment.Payment_Request__c!= null && payReqMap.containsKey(interimPayment.Payment_Request__c) && !payReqMap.get(interimPayment.Payment_Request__c).Interim_Payments_Received__r.isEmpty()) {
                                for(Interim_Payments__c ip : payReqMap.get(interimPayment.Payment_Request__c).Interim_Payments_Received__r) {
                                    intPayUpdChequeBounce.add(new Interim_Payments__c(Id=ip.Id, Approval_Status_Interim__c = interimPayment.Approval_Status_Interim__c, Submit_for_Cheque_Replacement_Approval__c = true, Parent_Interim_Payments__c = interimPayment.Parent_Interim_Payments__c, Cheque_Replacement_Record_3__c = interimPayment.Cheque_Replacement_Record_3__c, Cheque_Replacement_Record_2__c = interimPayment.Cheque_Replacement_Record_2__c));
                                }
                            }
                        }
                    }
                }

                System.debug('intPayUpdChequeBounce*****');
                System.debug(intPayUpdChequeBounce);

                if(!intPayUpdChequeBounce.isEmpty()) {
                    isRun5 = false;
                    update intPayUpdChequeBounce;
                }
            }
        }
    }

    //Added by Nishank Manwani on 18/07/2024 to update all the rest PR if status is change
    public static void updateRestIpOnPR4(List<Interim_Payments__c> intPayList, Map<Id, Interim_Payments__c> oldIntPayMap) {
        Id receivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id incomeReceivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId();
        System.debug('incomeReceivedRecordTypeId::'+incomeReceivedRecordTypeId);
        System.debug('receivedRecordTypeId::'+receivedRecordTypeId);

        List<Interim_Payments__c> intPayUpdChequeBounce = new List<Interim_Payments__c>();
        set<Id> paymentRequestId = new set<Id>();
        Map<Id, Payment_Request__c> payReqMap = new Map<Id, Payment_Request__c>();

        for(Interim_Payments__c interimPayment : intPayList) {
            if(oldIntPayMap != null){
                if(interimPayment.Approval_Status_Interim__c == 'Cheque Replacement Approved' && interimPayment.Submit_for_Cheque_Replacement_Approval__c && 
                interimPayment.Approval_Status_Interim__c != oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c && 
                (interimPayment.RecordTypeId == incomeReceivedRecordTypeId ||
                interimPayment.RecordTypeId == receivedRecordTypeId)) {
                    paymentRequestId.add(interimPayment.Payment_Request__c);
                }
            }
        }

        if(!paymentRequestId.isEmpty()) {
            payReqMap = new Map<Id, Payment_Request__c>([SELECT Id, 
                        (SELECT Id FROM Interim_Payments_Received__r WHERE (RecordTypeId = :receivedRecordTypeId OR RecordTypeId = :incomeReceivedRecordTypeId) AND (NOT (Id IN :oldIntPayMap.keySet())) ) 
                        FROM Payment_Request__c WHERE Id IN :paymentRequestId]);

            System.debug('payReqMap*****');
            System.debug(payReqMap);

            if(!payReqMap.isEmpty()) {
                for(Interim_Payments__c interimPayment : intPayList) {
                    if(oldIntPayMap != null){
                        if(interimPayment.Approval_Status_Interim__c == 'Cheque Replacement Approved' && interimPayment.Submit_for_Cheque_Replacement_Approval__c && 
                        interimPayment.Approval_Status_Interim__c != oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c && 
                        (interimPayment.RecordTypeId == incomeReceivedRecordTypeId ||
                        interimPayment.RecordTypeId == receivedRecordTypeId)) {
                            if(interimPayment.Payment_Request__c!= null && payReqMap.containsKey(interimPayment.Payment_Request__c) && !payReqMap.get(interimPayment.Payment_Request__c).Interim_Payments_Received__r.isEmpty()) {
                                for(Interim_Payments__c ip : payReqMap.get(interimPayment.Payment_Request__c).Interim_Payments_Received__r) {
                                    intPayUpdChequeBounce.add(new Interim_Payments__c(Id=ip.Id, Approval_Status_Interim__c = interimPayment.Approval_Status_Interim__c, Submit_for_Cheque_Replacement_Approval__c = true, Parent_Interim_Payments__c = interimPayment.Parent_Interim_Payments__c, Cheque_Replacement_Record_3__c = interimPayment.Cheque_Replacement_Record_3__c, Cheque_Replacement_Record_2__c = interimPayment.Cheque_Replacement_Record_2__c));
                                }
                            }
                        }
                    }
                }

                System.debug('intPayUpdChequeBounce*****');
                System.debug(intPayUpdChequeBounce);

                if(!intPayUpdChequeBounce.isEmpty()) {
                    isRun6 = false;
                    update intPayUpdChequeBounce;
                }
            }
        }
    }

    //Added by Nishank Manwani on 18/07/2024 to update all the rest PR if status is change
    public static void updateRestIpOnPR5(List<Interim_Payments__c> intPayList, Map<Id, Interim_Payments__c> oldIntPayMap) {
        Id receivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id incomeReceivedRecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId();
        System.debug('incomeReceivedRecordTypeId::'+incomeReceivedRecordTypeId);
        System.debug('receivedRecordTypeId::'+receivedRecordTypeId);

        List<Interim_Payments__c> intPayUpdChequeBounce = new List<Interim_Payments__c>();
        set<Id> paymentRequestId = new set<Id>();
        Map<Id, Payment_Request__c> payReqMap = new Map<Id, Payment_Request__c>();

        for(Interim_Payments__c interimPayment : intPayList) {
            if(oldIntPayMap != null){
                if(interimPayment.Approval_Status_Interim__c == 'Cheque Hold Approved' && interimPayment.Submit_for_Check_Hold__c && 
                interimPayment.Approval_Status_Interim__c != oldIntPayMap.get(interimPayment.id).Approval_Status_Interim__c && 
                (interimPayment.RecordTypeId == incomeReceivedRecordTypeId ||
                interimPayment.RecordTypeId == receivedRecordTypeId)) {
                    paymentRequestId.add(interimPayment.Payment_Request__c);
                }
            }
        }

        if(!paymentRequestId.isEmpty()) {
            payReqMap = new Map<Id, Payment_Request__c>([SELECT Id, 
                        (SELECT Id FROM Interim_Payments_Received__r WHERE Approval_Status_Interim__c != 'Cheque Hold Approved' AND (RecordTypeId = :receivedRecordTypeId OR RecordTypeId = :incomeReceivedRecordTypeId) AND (NOT (Id IN :oldIntPayMap.keySet())) ) 
                        FROM Payment_Request__c WHERE Id IN :paymentRequestId]);

            System.debug('payReqMap*****');
            System.debug(payReqMap);

            if(!payReqMap.isEmpty()) {
                for(Id payReqId : payReqMap.keySet()) {
                    if(!payReqMap.get(payReqId).Interim_Payments_Received__r.isEmpty()) {
                        for(Interim_Payments__c ip : payReqMap.get(payReqId).Interim_Payments_Received__r) {
                            intPayUpdChequeBounce.add(new Interim_Payments__c(Id=ip.Id, Approval_Status_Interim__c = 'Cheque Hold Approved', Submit_for_Check_Hold__c = true));
                        }
                    }
                }

                System.debug('intPayUpdChequeBounce*****');
                System.debug(intPayUpdChequeBounce);

                if(!intPayUpdChequeBounce.isEmpty()) {
                    isRun7 = false;
                    update intPayUpdChequeBounce;
                }
            }
        }
    }
    
    //public static void updateChequeDepositDate(List<>)
}
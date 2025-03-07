global without sharing class InterimReceiptButtonOnPaymentController {
    global string payId;
    public String frameSrc                                          {get;set;}
    global String opCode                                            {get;set;}
    public String msges                                             {get;set;}
    public List<PropStrength__Received_Payment__c> paymentList             {get;set;}
    public List<tableWrapper> paymentRecLineItemList             {get;set;}
    public wrapper wrapperRec             {get;set;}
    public PropStrength__Received_Payment__c payment                 		{get;set;}
    public PropStrength__Applicant_Detail__c applicantDetail						{get;set;}
    Public String e1                                                {get;set;}
    Public List<String> toList  {get;set;}
    public string projectLOGOId	{get;set;}
    public PropStrength__Received_Payment__c paymentRec;
    public QRCodeUtility_Copy.QR_Data qrData{get;private set;}
    
    public InterimReceiptButtonOnPaymentController() {
        qrData = new QRCodeUtility_Copy.QR_Data();
        frameSrc = '';
        payId = ApexPages.currentPage().getParameters().get('id'); 
        opCode = ApexPages.currentPage().getParameters().get('type');
        msges = '';projectLOGOId = '';
        paymentList = new List<PropStrength__Received_Payment__c>();
        paymentRecLineItemList = new List<tableWrapper>();
        payment = new PropStrength__Received_Payment__c();
        applicantDetail = new PropStrength__Applicant_Detail__c();
        //applicantDetailList = new List<PropStrength__Applicant_Detail__c>();
        toList = new List<String>();
        e1 = '';
        if(opCode == 'Receipt'){
        mainmethod();
        } else if(opCode == 'PaymentReceipt') {
            mainMethodPayRec();
        }
        if(String.isNotBlank(payId)){
            this.qrData = QRCodeUtility_Copy.getQrDataFor(payId);
        }
        System.debug('///**--'+this.qrData);
    }

    public class tableWrapper {
        public String unitNo {get;set;}
        public String paymentType {get;set;}
        public Date paymentDate {get;set;}
        public String adjustmentAgainst {get;set;}
        public Decimal amount {get;set;}

        public tableWrapper(String uNo, String payType, Date payDate, String adjagnst, Decimal amt) {
            unitNo = uNo;
            paymentType = payType;
            paymentDate = payDate;
            adjustmentAgainst = adjagnst;
            amount = amt;
        }
    }
    
    public class wrapper {
        public String name {get;set;}
        public String customerName {get;set;}
        public String projectName {get;set;}        
    }
    
    public void mainmethod(){
        if(payId != null && payId != '') {
            paymentList = [SELECT Id,Name,PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.Project_Name__c,
                                  PropStrength__Cheque_Demand_Draft_Number__c,PropStrength__Payment_Type__c,PropStrength__Payment_Date__c,PropStrength__Amount__c,
                                  PropStrength__Application_Booking__r.CRM_Executive_Email__c,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                  PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c,Interim_Receipt_sent_to_customer__c,
                                  PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c
                                  FROM PropStrength__Received_Payment__c WHERE Id =: payId AND Interim_Receipt_sent_to_customer__c =: false];
            List<PropStrength__Other_Charge_Due_Partition__c> paymentRecLineItemRecs = [SELECT Id,Name,PropStrength__Charge_Name__c,PropStrength__Amount_Recieved__c,PropStrength__Payment__r.PropStrength__Application_Booking__c,PropStrength__Payment__r.PropStrength__Application_Booking__r.Project_Name__c,
                                  PropStrength__Payment__r.PropStrength__Cheque_Demand_Draft_Number__c,PropStrength__Payment__r.PropStrength__Payment_Type__c,PropStrength__Payment__r.PropStrength__Payment_Date__c,PropStrength__Payment__r.PropStrength__Amount__c,
                                  PropStrength__Payment__r.PropStrength__Application_Booking__r.CRM_Executive_Email__c,PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                  PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c,PropStrength__Payment__r.Interim_Receipt_sent_to_customer__c,
                                  PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c
                                  FROM PropStrength__Other_Charge_Due_Partition__c WHERE PropStrength__Payment__c =: payId AND PropStrength__Payment__r.Interim_Receipt_sent_to_customer__c =: false AND RecordType.Name = 'Payment Received Line Item'];
            
            Map<String, Decimal> mapChargeAmt = new Map<String, Decimal>();
            Set<String> chargesName = new Set<String>();
            if(!paymentRecLineItemRecs.isEmpty()) {
                for(PropStrength__Other_Charge_Due_Partition__c pli : paymentRecLineItemRecs) {
                    if(mapChargeAmt.containsKey(pli.PropStrength__Charge_Name__c)) {
                        Decimal amt = mapChargeAmt.get(pli.PropStrength__Charge_Name__c) + pli.PropStrength__Amount_Recieved__c;
                        mapChargeAmt.remove(pli.PropStrength__Charge_Name__c);
                        mapChargeAmt.put(pli.PropStrength__Charge_Name__c, amt);
                    } else {
                        mapChargeAmt.put(pli.PropStrength__Charge_Name__c, pli.PropStrength__Amount_Recieved__c);
                        chargesName.add(pli.PropStrength__Charge_Name__c);
                    }
                }

                for(String crgeName : chargesName) {
                    for(PropStrength__Other_Charge_Due_Partition__c pli : paymentRecLineItemRecs) {
                        if(crgeName == pli.PropStrength__Charge_Name__c) {
                            paymentRecLineItemList.add(new tableWrapper(pli.PropStrength__Payment__r.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c, pli.PropStrength__Payment__r.PropStrength__Payment_Type__c, pli.PropStrength__Payment__r.PropStrength__Payment_Date__c, pli.PropStrength__Charge_Name__c, mapChargeAmt.get(pli.PropStrength__Charge_Name__c)));
                            break;
                        }
                    }
                }
            }
            if(!paymentList.isEmpty() && paymentList.size() > 0) {
                payment = paymentList[0];
                System.debug('payment*---'+payment);
                System.debug('payment*---11'+payment.Name);
                wrapperRec = new wrapper();
                wrapperRec.name = payment.name;
                
                wrapperRec.projectName = payment.PropStrength__Application_Booking__r.Project_Name__c;
                if(opCode =='Receipt'){
                    if(paymentList[0].PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                        framesrc = '/apex/PaymentReceiptSiniya?id='+payId+'&type=Receipt';
                    } else {
                        framesrc = '/apex/InterimReceiptOnPayment?id='+payId+'&type=Receipt';
                    }
                }
                for(Attachment att : [SELECT Id,Name, Body FROM Attachment WHERE parentId =: payment.PropStrength__Application_Booking__r.PropStrength__Project__c]) {
                    if(att.Name.contains('LOGO')){
                       String  attachmentBody = EncodingUtil.base64Encode(att.Body);
                        system.debug('inside attachments ');
                        projectLOGOId = attachmentBody;
                        // projectLOGOId = att.Id;
                        system.debug('103 '+projectLOGOId);
                    }
                }
                e1 = (payment.PropStrength__Application_Booking__r.CRM_Executive_Email__c != null) ? payment.PropStrength__Application_Booking__r.CRM_Executive_Email__c : '';
                System.debug('----------e1------'+e1);
                applicantDetail = [SELECT Id,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Name 
                                   FROM PropStrength__Applicant_Detail__c 
                                   WHERE PropStrength__Application__c =: payment.PropStrength__Application_Booking__c AND
                                   PropStrength__Type__c =: '1st Applicant' AND
                                   PropStrength__Active__c =: true];
                wrapperRec.customerName = applicantDetail.PropStrength__Applicant_Acc__r.Name;
            } else {
                msges = 'Payment Receipt sent to customer.';
            }
        }
    }
    
    public void mainMethodPayRec(){
        if(payId != null && payId != '') {
            List<PropStrength__Received_Payment__c> paymentList = [SELECT Id,Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c, PropStrength__Application_Booking__c, PropStrength__Payment_Plan_Detail__c FROM PropStrength__Received_Payment__c WHERE Id =: payId AND Receipt_Date__c = null];
            if(!paymentList.isEmpty() && paymentList.size() > 0) {
                paymentRec = paymentList[0];
                if(opCode =='PaymentReceipt'){
                    framesrc = '/apex/propstrength__ReceiptPDF?aid='+paymentRec.PropStrength__Application_Booking__c+'&id='+paymentRec.Id+'&pid='+paymentRec.PropStrength__Payment_Plan_Detail__c;
                }
                System.debug('framesrc==='+framesrc);
            } else {
                msges = 'Payment Receipt sent to customer.';
            }
        }
    }
    
    public pageReference recOrInv(){
        if(opCode =='Receipt') {
            saveAndEmailReceipt();
            return new pageReference('/'+payId);
        }
        if(opCode =='PaymentReceipt') {
            saveAndEmailPaymentReceipt();
            return new pageReference('/'+payId);
        }
        return null;
    }
    
    public void saveAndEmailReceipt(){
        if(payment != null) {
            set<String> emailAddress = new set<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            List<Attachment> att = new List<Attachment>();
            List<EmailTemplate> templatelist ;
            Id TempId;
            if(payId != null) {
                emailAddress.add(payment.PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c);
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if( !test.isrunningtest())
                    owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: emailAddress limit 1];             
                templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Payment Receipt Email Template' limit 1];
                if (owea.size() > 0) {
                    emails.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                if(!templatelist.isEmpty()) {
                    TempId = templatelist[0].id;
                }
                String frmsrc = '';
                if(paymentList[0].PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                    frmsrc = '/apex/PaymentReceiptSiniya?Id=' + payId+'&type=Receipt';
                } else {
                    frmsrc = '/apex/PaymentReceipt?Id=' + payId+'&type=Receipt';
                }
                PageReference p1 = new PageReference(frmsrc);
                String aName;
                String b;
                blob content;
                //PropStrength__Received_Payment__c pay = [SELECT Id,Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c FROM PropStrength__Received_Payment__c WHERE Id =: payId LIMIT 1];
                aName ='PaymentReceipt';
                Attachment a1 = new Attachment();
                a1.parentid = payId;
                a1.name = aName + '.pdf';
                System.debug('1');
                if (Test.IsRunningTest()) {
                    a1.body = Blob.valueOf('UNIT.TEST');
                    content =  Blob.valueOf('UNIT.TEST');
                } else {
                    a1.body = p1.getContentAsPDF();
                    content = p1.getContentAsPDF();
                } 
                insert a1;
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(aName+'.pdf');
                efa.setBody(content);
                emails.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                emails.setWhatId(payId);
                for(PropStrength__Applicant_Detail__c appDetails : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Name 
                                                                    FROM PropStrength__Applicant_Detail__c 
                                                                    WHERE PropStrength__Application__c =: payment.PropStrength__Application_Booking__c AND
                                                                    PropStrength__Active__c =: true]) {
                                                                        if(appDetails.PropStrength__Applicant_Email__c != null) {
                                                                            toList.add(appDetails.PropStrength__Applicant_Email__c);
                                                                        }
                                                                    }
                if(!toList.isEmpty()) {
                    emails.setToAddresses(toList); 
                }
                system.debug('===========toList ============'+toList);
                emails.setTemplateId(TempId);
                if(e1 != null && e1 != '') {
                    emails.setccAddresses(new String[] {e1});
                }
                emails.setSaveAsActivity(true); 
                emails.setTargetObjectId(payment.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                emails.setTreatTargetObjectAsRecipient(false); 
                emaillist.add(emails);
                try{
                    if(emaillist != null && emaillist.size()>0 ) {
                        msges = 'Mail sent successfully...';
                        Messaging.sendEmail(emaillist);
                        PropStrength__Received_Payment__c oneBook = new PropStrength__Received_Payment__c();
                        oneBook.Id = payId;
                        oneBook.Interim_Receipt_sent_to_customer__c = true;
                        oneBook.Interim_Receipt_Sent_Date__c = Date.today();
                        update oneBook;
                    }
                } catch(Exception ex){
                    msges = 'Mail not sent...';
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }  
        } else {
            msges = 'Email Can\'t be sent.';
        }
    }
    
    public void saveAndEmailPaymentReceipt(){
        if(paymentRec != null) {
            set<String> emailAddress = new set<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            List<Attachment> att = new List<Attachment>();
            List<EmailTemplate> templatelist ;
            Id TempId;
            if(payId != null) {
                emailAddress.add(paymentRec.PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c);
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if( !test.isrunningtest())
                    owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: emailAddress limit 1];             
                templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Payment Receipt Template' limit 1];
                if (owea.size() > 0) {
                    emails.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                if(!templatelist.isEmpty()) {
                    TempId = templatelist[0].id;
                }
                String frmsrc = '/apex/propstrength__ReceiptPDF?aid='+paymentRec.PropStrength__Application_Booking__c+'&id='+paymentRec.Id+'&pid='+paymentRec.PropStrength__Payment_Plan_Detail__c;
                PageReference p1 = new PageReference(frmsrc);
                String aName;
                String b;
                blob content;
                //PropStrength__Received_Payment__c pay = [SELECT Id,Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c FROM PropStrength__Received_Payment__c WHERE Id =: payId LIMIT 1];
                aName ='propstrength__ReceiptPDF';
                Attachment a1 = new Attachment();
                a1.parentid = payId;
                a1.name = aName + '.pdf';
                System.debug('1');
                if (Test.IsRunningTest()) {
                    a1.body = Blob.valueOf('UNIT.TEST');
                    content =  Blob.valueOf('UNIT.TEST');
                } else {
                    a1.body = p1.getContentAsPDF();
                    content = p1.getContentAsPDF();
                } 
                insert a1;
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(aName+'.pdf');
                efa.setBody(content);
                emails.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                emails.setWhatId(payId);
                
                if(paymentRec.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c != null) {
                    emails.setToAddresses(new String[]{paymentRec.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email}); 
                }
                system.debug('===========toList ============'+toList);
                emails.setTemplateId(TempId);
                if(e1 != null && e1 != '') {
                    emails.setccAddresses(new String[] {UserInfo.getUserEmail()});
                }
                emails.setSaveAsActivity(true); 
                emails.setTargetObjectId(paymentRec.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                emails.setTreatTargetObjectAsRecipient(false); 
                emaillist.add(emails);
                try{
                    if(emaillist != null && emaillist.size()>0 ) {
                        msges = 'Mail sent successfully...';
                        Messaging.sendEmail(emaillist);
                        PropStrength__Received_Payment__c oneBook = new PropStrength__Received_Payment__c();
                        oneBook.Id = payId;
                        oneBook.Receipt_Date__c = System.Now();
                        update oneBook;
                    }
                } catch(Exception ex){
                    msges = 'Mail not sent...';
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }  
        } else {
            msges = 'Email Can\'t be sent.';
        }
    }
    
    public pageReference saveDocFile(){
        if(payId != null && payId != ''){
            if(opCode =='Receipt'){
                if(paymentList[0].PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                    SavePdfAndHtmlToAttachement.doSaveReceipt(payId, 'PaymentReceiptSiniya');
                } else {
                    SavePdfAndHtmlToAttachement.doSaveReceipt(payId, 'PaymentReceipt');
                }
                if(payId != null && payId != ''){
                    return new pageReference('/'+payId);
                }
            }
            if(opCode =='PaymentReceipt'){
                SavePdfAndHtmlToAttachement.doSaveReceipt(payId, 'propstrength__ReceiptPDF');
                if(payId != null && payId != ''){
                    return new pageReference('/'+payId);
                }
            }
        }    
        return null;
    } 
    
    public void createErr(){
        if(String.isNotBlank(this.qrData?.serializedErr)) ExternalReferenceRegisterUtil_Copy.createERR(this.qrData.serializedErr);
    }
    
    public PageReference backToRecPage() {
        if(payId != null && payId != '') {
            return new pageReference('/'+payId);
        } else {
            return null;            
        }   
    }
}
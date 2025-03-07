public class InterimReceiptPdfController {
    public QRCodeUtility_Copy.QR_Data qrData{get;private set;}
    public string payId;
    public String frameSrc                                          {get;set;}
    public String opCode                                            {get;set;}
    public String msges                                             {get;set;}
    public List<tableWrapper> interimPaymentItemList             {get;set;}
    public List<Interim_Payments__c> interimPaymentList             {get;set;}
    public wrapper wrapperRec             {get;set;}
    public tableWrapper tableRec                 		{get;set;}
        public Interim_Payments__c interimPayment                 		{get;set;}
    public PropStrength__Applicant_Detail__c applicantDetail						{get;set;}
    //public List<PropStrength__Applicant_Detail__c> applicantDetailList              {get;set;}
    Public String e1                                                {get;set;}
    Public List<String> toList  {get;set;}
    public string projectLOGOId	{get;set;}
    public PropStrength__Received_Payment__c paymentRec;
    
    public InterimReceiptPdfController() {
        qrData = new QRCodeUtility_Copy.QR_Data();
        frameSrc = '';
        payId = ApexPages.currentPage().getParameters().get('id'); 
        if(String.isNotBlank(payId)){
            this.qrData = QRCodeUtility_Copy.getQrDataFor(payId);
            system.debug('line 22'+ this.qrData);
        }
        opCode = ApexPages.currentPage().getParameters().get('type');
        msges = '';
        projectLOGOId = '';
        interimPaymentList = new List<Interim_Payments__c>();
        interimPaymentItemList = new List<tableWrapper>();
        interimPayment = new Interim_Payments__c();
        applicantDetail = new PropStrength__Applicant_Detail__c();
        //applicantDetailList = new List<PropStrength__Applicant_Detail__c>();
        toList = new List<String>();
        e1 = '';
        if(opCode == 'Receipt'){
        mainmethod();
        } else if(opCode == 'PaymentReceipt') {
            mainMethodPayRec();
        }
    }
    
    public void createErr(){
        if(String.isNotBlank(this.qrData?.serializedErr)) ExternalReferenceRegisterUtil_Copy.createERR(this.qrData.serializedErr);
    }
    
    public void mainmethod(){
        if(payId != null && payId != '') {
            interimPaymentList = [SELECT Id,Name,Application_Booking_Interim__c,Application_Booking_Interim__r.Project_Name__c,
                                  Cheque_Demand_Draft_Number_Interim__c,Payment_Mode_Interim__c,Payment_Date_Interim__c,Amount_Interim__c,
                                  Application_Booking_Interim__r.CRM_Executive_Email__c,Application_Booking_Interim__r.PropStrength__Primary_Customer__c,
                                  Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c,Interim_Receipt_sent_to_customer__c,
                                  Application_Booking_Interim__r.PropStrength__Project__c, Application_Booking_Interim__r.PropStrength__Property__r.PropStrength__Property_Name__c
                                  FROM Interim_Payments__c WHERE Id =: payId AND Interim_Receipt_sent_to_customer__c = false];
            if(!interimPaymentList.isEmpty() && interimPaymentList.size() > 0) {
                interimPayment = interimPaymentList[0];
                tableWrapper tableRec = new tableWrapper();
                tableRec.unitNo = interimPayment.Application_Booking_Interim__r.PropStrength__Property__r.PropStrength__Property_Name__c;
                tableRec.paymentType  = interimPayment.Payment_Mode_Interim__c;
                tableRec.paymentDate = interimPayment.Payment_Date_Interim__c;
                tableRec.amount = interimPayment.Amount_Interim__c;
                interimPaymentItemList.add(tableRec);
                wrapperRec = new wrapper();
                wrapperRec.name = interimPayment.name;                
                wrapperRec.projectName = interimPayment.Application_Booking_Interim__r.Project_Name__c;
                
                if(opCode =='Receipt'){
                    framesrc = '/apex/InterimReceipt?id='+payId+'&type=Receipt';
                }
                for(Attachment att : [SELECT Id,Name,body FROM Attachment WHERE parentId =: interimPayment.Application_Booking_Interim__r.PropStrength__Project__c]) {
                    String  attachmentBody = EncodingUtil.base64Encode(att.Body);
                    if(att.Name.contains('LOGO')){
                        // projectLOGOId = attachmentBody;
                        // system.debug('line 74 projectLOGOId '+att.Id);
                        projectLOGOId = att.Id;

                    }
                }
                e1 = (interimPayment.Application_Booking_Interim__r.CRM_Executive_Email__c != null) ? interimPayment.Application_Booking_Interim__r.CRM_Executive_Email__c : '';
                System.debug('----------e1------'+e1);
                List<PropStrength__Applicant_Detail__c> applicantDetailList = [SELECT Id,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Name 
                                   FROM PropStrength__Applicant_Detail__c 
                                   WHERE PropStrength__Application__c =: interimPayment.Application_Booking_Interim__c AND
                                   PropStrength__Type__c =: '1st Applicant' AND
                                   PropStrength__Active__c =: true];
                if(applicantDetailList.size() > 0) {
                    applicantDetail = applicantDetailList[0];
                    wrapperRec.customerName = applicantDetail.PropStrength__Applicant_Acc__r.Name;
                }
            } else {
                msges = 'Interim Receipt sent to customer alredy send.';
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
                msges = 'Payment Receipt sent to customer alredy send.';
            }
        }
    }
    
    public pageReference recOrInv(){
        if(opCode =='Receipt') {
            saveAndEmailReceipt();
            system.debug('line 111 payId '+payId);
            return new pageReference('/'+payId);
        }
        if(opCode =='PaymentReceipt') {
            saveAndEmailPaymentReceipt();
            return new pageReference('/'+payId);
        }
        return null;
    }
    
    
    public void saveAndEmailReceipt(){
        if(interimPayment != null) {
            set<String> emailAddress = new set<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            List<Attachment> att = new List<Attachment>();
            List<EmailTemplate> templatelist ;
            Id TempId;
            if(payId != null) {
                emailAddress.add(interimPayment.Application_Booking_Interim__r.PropStrength__Project__r.Customer_Care_Email_ID__c);
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if( !test.isrunningtest())
                    owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: emailAddress limit 1];             
                templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Interim Receipt Email Template' limit 1];
                if (owea.size() > 0) {
                    emails.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                if(!templatelist.isEmpty()) {
                    TempId = templatelist[0].id;
                }
                String frmsrc = '/apex/InterimReceiptPdf?Id=' + payId+'&type=Receipt';
                PageReference p1 = new PageReference(frmsrc);
                String aName;
                String b;
                blob content;
                //Interim_Payments__c pay = [SELECT Id,Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c FROM PropStrength__Received_Payment__c WHERE Id =: payId LIMIT 1];
                aName ='InterimReceipt';
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
                                                                    WHERE PropStrength__Application__c =: interimPayment.Application_Booking_Interim__c AND
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
                emails.setTargetObjectId(interimPayment.Application_Booking_Interim__r.PropStrength__Primary_Customer__c);
                emails.setTreatTargetObjectAsRecipient(false); 
                emaillist.add(emails);
                try{
                    if(emaillist != null && emaillist.size()>0 ) {
                        msges = 'Mail sent successfully...';
                        Messaging.sendEmail(emaillist);
                        Interim_Payments__c oneBook = new Interim_Payments__c();
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
                templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Interim Receipt Template' limit 1];
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
                //Interim_Payments__c pay = [SELECT Id,Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c FROM PropStrength__Received_Payment__c WHERE Id =: payId LIMIT 1];
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
                SavePdfAndHtmlToAttachement.doSaveReceipt(payId, 'InterimReceipt');
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
    
    public PageReference backToRecPage() {
        if(payId != null && payId != '') {
            return new pageReference('/'+payId);
        } else {
            return null;            
        }   
    }
    
    public class tableWrapper {
        public String unitNo {get;set;}
        public String paymentType {get;set;}
        public Date paymentDate {get;set;}
        public String adjustmentAgainst {get;set;}
        public Decimal amount {get;set;}

      
    }
    
    public class wrapper {
        public String name {get;set;}
        public String customerName {get;set;}
        public String projectName {get;set;}        
    }
    
}
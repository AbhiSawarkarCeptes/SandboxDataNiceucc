public class BookingFormController {
    public String bookId;
    public String emailSend;
    public Boolean showAppDet {get;set;}
    public Boolean showAppDet2 {get;set;}
    public List<paymentWrapper> paymentWrapperList {get;set;}
    public PropStrength__Application_Booking__c bookingRec {get;set;}

    public BookingFormController() {
        bookId = ApexPages.currentPage().getParameters().get('id');
        bookingRec = new PropStrength__Application_Booking__c();
        paymentWrapperList = new List<paymentWrapper>();
        showAppDet2 = FALSE;
        showAppDet = FALSE;

        if(bookId != null && bookId != '') {
            Id payRecRecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
            Id payDueRecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId();
            Id IncRecRecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
            Id IncDueRecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
            
            bookingRec = [SELECT Id, PropStrength__Booking_Date__c, PropStrength__Primary_Customer__c, PropStrength__Primary_Customer__r.Email,Project_Name__c,PropStrength__Property_Name__c,
                        PropStrength__Super_Area__c,PropStrength__Basic_Sale_Price__c,PropStrength__Total_Sales_Consideration__c,
                        (SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Acc__r.Passport_No__c, PropStrength__Applicant_Acc__r.Passport_Expiry_Date__c,
                        PropStrength__Applicant_Acc__r.Passport_Nationality__c, PropStrength__Contact_Address__c, PropStrength__Applicant_Address__c, PropStrength__Applicant_Mobile__c,
                        PropStrength__Applicant_Email__c, PropStrength__Applicant_Acc__r.Fax, PropStrength__Type__c 
                        FROM PropStrength__Applicant_Details__r),
                        (SELECT Id, PropStrength__Booking_Amount_PPD__c, PropStrength__Amount_Percent__c, PropStrength__Total_Amount_Due__c, PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c, PropStrength__Milestone_Name__c,PropStrength__Payment_Due_Date__c FROM PropStrength__Payment_Plan_Details__r ORDER BY PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c)
                        FROM PropStrength__Application_Booking__c WHERE Id = :bookId];
            if(bookingRec.PropStrength__Primary_Customer__c != null) {
                emailSend = bookingRec.PropStrength__Primary_Customer__r.Email;
            }

            if(!bookingRec.PropStrength__Payment_Plan_Details__r.isEmpty()) {
                for(PropStrength__Payment_Plan_Details__c ppd : bookingRec.PropStrength__Payment_Plan_Details__r) {
                    if(ppd.PropStrength__Booking_Amount_PPD__c) {
                        paymentWrapperList.add(new paymentWrapper('Booking Amount', ppd.PropStrength__Amount_Percent__c, ppd.PropStrength__Total_Amount_Due__c, ppd.PropStrength__Payment_Due_Date__c, ppd.PropStrength__Milestone_Name__c));
                    } else {
                        String ord = '';
                        if(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c == 2) {
                            ord = String.valueOf(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c-1)+'st Installment';
                        } else if(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c == 3) {
                            ord = String.valueOf(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c-1)+'nd Installment';
                        } else if(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c == 4) {
                            ord = String.valueOf(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c-1)+'rd Installment';
                        } else if(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c != null){ 
                            ord = String.valueOf(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c-1)+'th Installment';
                        }
                        paymentWrapperList.add(new paymentWrapper(ord, ppd.PropStrength__Amount_Percent__c, ppd.PropStrength__Total_Amount_Due__c, ppd.PropStrength__Payment_Due_Date__c, ppd.PropStrength__Milestone_Name__c));
                    }
                    
                }
            }

            if(!bookingRec.PropStrength__Applicant_Details__r.isEmpty()) {
                showAppDet = TRUE;
                if(bookingRec.PropStrength__Applicant_Details__r.size() > 1) {
                    showAppDet2 = TRUE;
                }
            }
        }
    }

    public PageReference backToRecPage(){
        if(bookId != null && bookId != ''){
            return new pageReference('/'+bookId);
        }else {
            return null;            
        }   
    }

    public pageReference saveDocFile(){
        if(bookId != null && bookId != ''){
            SavePdfAndHtmlToAttachement.doSaveReceipt(bookId, 'Booking_Form');
            return new pageReference('/'+bookId);
        }    
        return null;
    }

    public pageReference saveAndEmail(){
        Set<String> contactEmail = new set<String>();
        List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
        List<Attachment> att = new List<Attachment>();
        List<EmailTemplate> templatelist ;
        Id TempId;
        if(bookId != null) {
            String searchTxt = 'Booking_Form';
            templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }
            PageReference p1 =  Page.Booking_Form;
            String aName = 'Booking_Form';
            p1.getParameters().put('id',(String)bookId); 
            p1.setRedirect(true);
            blob content;
            if(test.IsRunningTest())
                content= Blob.valueOf('This is Test');    
            else
                content= p1.getContentAsPDF(); 
            System.debug(p1);
            
            List<Attachment> allAttachment = new List<Attachment>();
            allAttachment = [SELECT Id, Name FROM Attachment WHERE parentid =: bookId];
            for(Attachment abc : allAttachment){
                if(abc.Name == 'Booking_Form.pdf'){
                    delete abc;
                }
            }
            
            SavePdfAndHtmlToAttachement.doSaveReceipt(bookId, 'Booking_Form');
            
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(aName+'.pdf');
            efa.setBody(content);
            emails.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            emails.setWhatId(bookId);
            emails.setToAddresses( new String[] {emailSend} ); 
            List<String> ccList = new List<String>();
            ccList.add(UserInfo.getUserEmail());
            emails.setTemplateId(TempId);
            emails.setccAddresses(ccList);
            emails.setSaveAsActivity(true); 
            emails.setTargetObjectId(UserInfo.getUserId());
            emails.setTreatTargetObjectAsRecipient(false); 
            emaillist.add(emails);
            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                    PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(RecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Booking Form').getRecordTypeId(), PropStrength__Application_Booking__c = bookId, Booking_Form_Sent_to_Customer__c = TRUE, Booking_Form_Sent_to_Customer_Date__c = System.Today());
                    insert tr;
                    PropStrength__Application_Booking__c bookingRec = new PropStrength__Application_Booking__c(Id = bookId, Booking_Form_Executed__c = true);
                    update bookingRec;
                    return new pageReference('/'+bookId);
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        } 
        return null;
    }

    public class paymentWrapper {
        public String installment {get;set;}
        public Decimal percOfPurchasePrice {get;set;}
        public Decimal amount {get;set;}
        public Date paymentDate {get;set;}
        public String milestone {get;set;}

        public paymentWrapper(String inst, Decimal percOfPP, Decimal amt, Date payDate, String milName) {
            installment = inst;
            percOfPurchasePrice = percOfPP;
            amount = amt;
            paymentDate = payDate;
            milestone = milName;
        }
    }
}
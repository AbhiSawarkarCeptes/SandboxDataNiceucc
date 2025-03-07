public without sharing class SRCustomer_Copy {
    public Integer state {get;private set;}//-1 = error, 1 = challenge with captcha, 2 = captcha succeeded & send OTP, 3 = otp done
    public String enteredOtp {get;set;}
    public String errorMessage {get;private set;}
    public String otpFailureMessage {get;private set;}
    public Boolean incorrectOtpEntered {get;private set;}
    public Boolean otpSent {get;private set;}
    public ReceiptWrapper rw {get;private set;}
    
    String externalReference;
    
    
    void setState(Integer state){
        if(state == NULL || state < -2 || state > 4){
            this.state = -3;
            this.errorMessage = 'Unknown Error occurred. Please contact Admin.';
            return;
        }
        
        if(this.state != state){
            this.state = state;
            
            switch on this.state{
                when -1{this.errorMessage = 'Invalid URL';}
                when -2{this.errorMessage = 'Invalid or Expired link. Please ask for a new Receipt.';}
                when 1{}
                when 2{sendOTP();}
                when 3{showDocument(this.externalReference);}
            }
        }
        
    }
    
    public SRCustomer_Copy(){
        this.otpFailureMessage = 'Incorrect OTP entered!';
        this.incorrectOtpEntered = false;
        this.otpSent = false;
        
        this.externalReference = ApexPages.currentPage().getParameters().get('erId');
        System.debug('externalReference*--'+ApexPages.currentPage().getParameters());
        if(String.isBlank(this.externalReference)){
            setState(-1);
            return;
        }else{
            setState(1);//captcha challenge    
        }
        
        
    }
    
    public PageReference captchaSucceeded(){
        setState(2);//otp challenge
        return null;
    }
    
    public void sendOTP(){
        System.debug('sendOTP()');
        System.debug('sendOTP() this.state - '+this.state);
        if(this.state == 2 && ExternalReferenceRegisterUtil_Copy.isValidReference(this.externalReference)){
            
            System.debug('sendOTP() IF');
            ExternalReferenceRegisterUtil_Copy.challenge(this.externalReference);
            this.otpSent = true;
        }else{
            System.debug('sendOTP() ELSE');
            setState(-2);
        }
    }
    
    public PageReference verifyOTP(){
        if(String.isBlank(this.enteredOtp)){
            this.incorrectOtpEntered = true;
            return null;
        }
        
        this.incorrectOtpEntered = false;
        PageReference pr;
        ExternalReferenceRegisterUtil_Copy.ChallengeResult cr = ExternalReferenceRegisterUtil_Copy.verifyChallenge(externalReference,this.enteredOtp);
        
        if(cr.cleared){
            setState(3);//show document
        }else{
            incorrectOtpEntered = true;
        }
        Id documentId = Id.valueOf(cr.internalReference);
        if(documentId.getSObjectType() == PropStrength__Received_Payment__c.SObjectType)
            pr = new pagereference('/apex/InterimReceiptOnPayment?id='+cr.internalReference+'&type=Receipt');
        else
            pr = new pagereference('/apex/InterimReceipt?id='+cr.internalReference+'&type=Receipt');
        this.enteredOtp = '';
        return pr;
    }
    
    void showDocument(String externalReference){
        Id documentId;
        System.debug('test*---');
        String documentIdStr = ExternalReferenceRegisterUtil_Copy.fetchInternalReference(externalReference);
        try{
            documentId = Id.valueOf(documentIdStr);
            System.debug(documentIdStr+'---test*---');
            if(documentId.getSObjectType() == PropStrength__Received_Payment__c.SObjectType){
                this.rw = new ReceiptWrapper(documentId);
                System.debug('test*---'+this.rw.isAvailable);
                if(this.rw.isAvailable){
                    setState(3);
                }else{
                    setState(-2);
                }
            }
        }catch(Exception ex){
            setState(-2);
            System.debug('PrintReceipt_Copy Exception @ '+System.now()+' - \n ex.getMessage()'+ex.getMessage()+'\n ex.getStackTraceString() - '+ex.getStackTraceString()+'\n externalReference - '+externalReference+'\n documentId - '+documentId);
        }
        
    }
    
    class ReceiptWrapper{
        Boolean isAvailable;
        public List<PropStrength__Received_Payment__c> lstPayment {get; set;}
        public Opportunity Customer {get;set;}  
        public string projectLOGOId {get;set;}
        public String strReceiptId {get; set;} 
        public string letterhead{get;set;} 
        public id bookingId {get; set;}
        public String ownerName{get;set;}
        public String ownerPhone{get;set;}
        public String ownerEmail{get;set;}
        public String ownerSalutation{get;set;}
        public Decimal amountRs{get;set;}
        public string legalAddress{get;set;}
        public string legalCity{get;set;}
        public string legalPinCode{get;set;} 
        public List<Receipt_Details__c> lstReceiptDetails {get; set;}       
        public Legal_Entity__c le {get; set;}
        public String PanNo{get;set;}
        public String ServiceTaxNo{get;set;}
        public String Address{get;set;}
        public String City{get;set;}
        public String PinCode{get;set;}    
        public String legalEntityName{get;set;}
        public String Signatory{get;set;}
        public decimal totalAmt{get;set;}
        public string tamt{get;set;}
        public string accMoney{get;set;}
        public String CustomerOtherApplicantName {get; set;}
        public String CustomerPrimaryName  {get; set;} 
        public String CustomerMailingAddress {get; set;} 
        public String CustomerMobilePhone  {get; set;}   
        public String UnitName  {get; set;}       
        public String ChequeDate {get;set;} // Added by Neha on 13/2/19
        public String ReceiptDate {get;set;} // Added by Neha on 13/2/19
        public String CurrencyString {get;set;} // Added by Neha on 13/2/19
        
        public String uiReceiptProjectName {get;private set;}
        public String uiReceiptProjectNameWithTowerName{get;private set;}
        public Date uiReceiptDate{get;private set;}
        public String uiReceiptNumber{get;private set;}
        public String uiReceiptCurrency{get;private set;}
        public String uiReceiptUnitName{get;private set;}
        public String uiReceiptMode{get;private set;}
        public Date uiReceiptChequeDDDate{get;private set;}
        public String uiReceiptStatus{get;private set;}
        //public String uiTowerName{get;private set;}
        public String uiReceiptName{get;private set;}
        
        
        public ReceiptWrapper(Id receiptId){
            isAvailable = false;
            le = new Legal_Entity__c();
            PanNo = '';
            ServiceTaxNo = '';
            Address = '';
            City = '';
            PinCode = '';
            accMoney = '';
            amountRs = 0;
            System.debug('I am in printreceipt');
            
            strReceiptId = receiptId;
            System.debug('strReceiptId - '+strReceiptId);
            
            if(String.isBlank(strReceiptId)){
                isAvailable = false;
            }else{
                getReceiptDetails();
            }
            System.debug('isAvailable - '+isAvailable);
        }
        
        public void getReceiptDetails() {
            // if we are coming form the receipt component, the strreceipt is already set
            if(strReceiptId != null)
            {
                lstPayment = [Select Id,name, PropStrength__Application_Booking__r.PropStrength__Project__r.name, PropStrength__Application_Booking__r.PropStrength__Property__r.name,
                          PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.name, Receipt_Number__c, Receipt_Date__c,PropStrength__Payment_Date__c,
                          PropStrength__Payment_Type__c, Currency__c, Receipt_Status__c, PropStrength__Application_Booking__r.PropStrength__Property_Name__c,PropStrength__Amount__c,PropStrength__Application_Booking__r.Sales_Manager__c,
                          PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingStreet,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Mailing_City__c,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Mailing_State__c,
                              PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCountry,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingPostalCode,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone,
                          PropStrength__Issue_Date__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c
                          from PropStrength__Received_Payment__c where id =: strReceiptId and ( recordType.Name = 'Payment Received' or recordType.Name = 'Income Charge Received' )];
            }  
            
            system.debug('lstPayment - ' + lstPayment );
            system.debug('lstPayment - ' + lstPayment?.size());
            
            if(lstPayment != null && lstPayment.size() == 1){
                PropStrength__Received_Payment__c receipt = lstPayment[0];
                // uiReceiptProjectName = receipt.Project__r.Name;
                uiReceiptProjectName = lstPayment[0].PropStrength__Application_Booking__r.PropStrength__Project__r.name;
                // uiReceiptProjectNameWithTowerName = receipt.Project_Name_with_Tower_Name__c;
                uiReceiptProjectNameWithTowerName = lstPayment[0].PropStrength__Application_Booking__r.PropStrength__Project__r.name + lstPayment[0].PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.name;
                uiReceiptDate = receipt.PropStrength__Payment_Date__c;
                uiReceiptNumber = receipt.Receipt_Number__c;
                uiReceiptCurrency = receipt.Currency__c;
                // uiReceiptUnitName = receipt.Project_Unit__r.Name;
                uiReceiptUnitName = receipt.PropStrength__Application_Booking__r.PropStrength__Property_Name__c;
                //uiReceiptMode = receipt.Mode__c;
                uiReceiptMode = receipt.PropStrength__Payment_Type__c;
                // uiReceiptChequeDDDate = receipt.Cheque_DD_Date__c;
                uiReceiptChequeDDDate = receipt.PropStrength__Issue_Date__c;
                uiReceiptStatus = receipt.Receipt_Status__C;
                //uiTowerName = receipt.Tower__r.Name;
                uiReceiptName = receipt.Name;
                
                
                system.debug('lstReceipt.size() == 1');
               
                
                // CustomerPrimaryName  = lstReceipt[0].Opportunity__r.Primary_Name__c;
                CustomerPrimaryName  = receipt.PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c;

                // CustomerOtherApplicantName = lstReceipt[0].Opportunity__r.Other_Applicants_Name__c;
                List<PropStrength__Received_Payment__c> paymentList = Database.query('SELECT Id, PropStrength__Application_Booking__c FROM PropStrength__Received_Payment__c where id= \''+receipt.id+'\''); 

                List<PropStrength__Application_Booking__c> bookingList = Database.query('SELECT id , (select id, PropStrength__Applicant_Email__c, Name from PropStrength__Applicant_Details__r)  from PropStrength__Application_Booking__c where id=\''+receipt.PropStrength__Application_Booking__c+'\'');
                for(Attachment att : [SELECT Id,Name FROM Attachment WHERE parentId =: receipt.PropStrength__Application_Booking__r.PropStrength__Project__c]) {
                    if(att.Name.contains('LOGO')){
                        projectLOGOId = att.Id;
                    }
                }
                for(Integer i=1;i<bookingList[0].PropStrength__Applicant_Details__r.size();i++){
                    CustomerOtherApplicantName += bookingList[0].PropStrength__Applicant_Details__r[i].Name; 
                }
                // CustomerOtherApplicantName = lstReceipt[0].Opportunity__r.Other_Applicants_Name__c;

                
                // CustomerMailingAddress = lstReceipt[0].Opportunity__r.Mailing_Address__c;
                CustomerMailingAddress = receipt.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingStreet+' ' + 
                    receipt.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Mailing_City__c+' ' + 
                    receipt.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Mailing_State__c+' '+ 
                    receipt.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCountry+' '+
                    receipt.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingPostalCode;

                CustomerMobilePhone  =  receipt.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone;
                UnitName = receipt.PropStrength__Application_Booking__r.PropStrength__Property_Name__c;
                if(receipt.PropStrength__Amount__c != null)
                    amountRs = receipt.PropStrength__Amount__c;
                if(receipt.PropStrength__Issue_Date__c != null)
                    ChequeDate = receipt.PropStrength__Issue_Date__c.format(); 
                if(receipt.Receipt_Date__c != null) 
                    ReceiptDate = receipt.Receipt_Date__c.format();
                if(receipt.Currency__c != '' && receipt.Currency__c != null)
                    CurrencyString = receipt.Currency__c.toUpperCase();
                ownerSalutation = '';
                ownerName = receipt.PropStrength__Application_Booking__r.Sales_Manager__c; 
                ownerPhone = ''; 
                ownerEmail =  '';

                isAvailable = true;
            }
        }
    }
    
}
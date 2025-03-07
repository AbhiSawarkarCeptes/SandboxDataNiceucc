//Test class : TestSRCustomer
public without sharing class SRCustomer {
    public final Boolean SHOW_PRINT_BUTTON{public get;private set;}
    public Integer state {get;private set;}//-1 = error, 1 = challenge with captcha, 2 = captcha succeeded & send OTP, 3 = otp done
    public String enteredOtp {get;set;}
    public String errorMessage {get;private set;}
    public String otpFailureMessage {get;private set;}
    public Boolean incorrectOtpEntered {get;private set;}
    public Boolean otpSent {get;private set;}
    public ReceiptWrapper rw {get;private set;}
    String externalReference;
    public QRCodeUtility.QR_Data qrData{get;private set;}//Added for SOB-1866
    
    void setState(Integer state){
        if(state == NULL || state < -3 || state > 4){
            this.state = -3;
            this.errorMessage = 'Unknown Error occurred. Please contact Admin.';
            return;
        }
        
        if(this.state != state){
            this.state = state;
            
            switch on this.state{
                when -1{this.errorMessage = 'Invalid URL';}
                when -2{this.errorMessage = 'Invalid or Expired link. Please ask for a new Receipt.';}
                when -3{this.errorMessage = 'This page is down for maintenance. Please try again in a while.';}
                when 1{}
                when 2{sendOTP();}
                when 3{showDocument(this.externalReference);}
            }
        }
        
    }
    
    public SRCustomer(){
        this.otpFailureMessage = 'Incorrect OTP entered!';
        this.incorrectOtpEntered = false;
        this.otpSent = false;
        this.SHOW_PRINT_BUTTON = false;
        
        this.externalReference = ApexPages.currentPage().getParameters().get('erId');
        //this.qrData = new QRCodeUtility.QR_Data();
        if(String.isBlank(this.externalReference)){
            setState(-1);
            return;
        }else{
        	setState(1);//captcha challenge    
        	//setState(3);//captcha challenge    
        }
        
        
    }

    public PageReference s2Check(){
        for(S2_Reciepts__c s2r : S2_Reciepts__c.getAll().values()){
            if(s2r.External_Reference__c == this.externalReference){
                setState(-3);
            }
        }
        return null;
    }
    
    public PageReference captchaSucceeded(){
        setState(2);//otp challenge
        return null;
    }
    
    public void sendOTP(){
        System.debug('sendOTP()'+this.externalReference);
        System.debug('sendOTP() this.state - '+this.state);
        if(this.state == 2 && ExternalReferenceRegisterUtil.isValidReference(this.externalReference)){
            ExternalReferenceRegisterUtil.challenge(this.externalReference);
            this.otpSent = true;
        }else{
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
        ExternalReferenceRegisterUtil.ChallengeResult cr = ExternalReferenceRegisterUtil.verifyChallenge(externalReference,this.enteredOtp);
        
        if(cr.cleared){
            setState(3);//show document
        }else{
            incorrectOtpEntered = true;
        }
        pr = null;
        this.enteredOtp = '';
        return pr;
    }
    
    void showDocument(String externalReference){
        Id documentId;
        String documentIdStr = ExternalReferenceRegisterUtil.fetchInternalReference(externalReference);
        try{
            documentId = Id.valueOf(documentIdStr);
            if(documentId.getSObjectType() == Receipt__c.SObjectType){
                this.rw = new ReceiptWrapper(documentId);
                this.qrData = QRCodeUtility.getQrDataFor(ExternalReferenceRegisterUtil.getExternalReferenceRegister(this.externalReference));
                if(this.rw.isAvailable){
                    setState(3);
                }else{
                    setState(-2);
                }
            }
        }catch(Exception ex){
            setState(-2);
            System.debug('SRCustomer Exception @ '+System.now()+' - \n ex.getMessage()'+ex.getMessage()+'\n ex.getStackTraceString() - '+ex.getStackTraceString()+'\n externalReference - '+externalReference+'\n documentId - '+documentId);
        }
        
    }
    
    class ReceiptWrapper{
        Boolean isAvailable;
        public List<Receipt__c> lstReceipt {get; set;}
        public Opportunity Customer {get;set;}   
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
        public String uiReceiptProjectTowerName{get;private set;}
        //public String uiTowerName{get;private set;}
        public String uiReceiptName{get;private set;}
        public String logoPath{get;set;}
        
        
        public ReceiptWrapper(Id receiptId){
            logoPath = '';
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
                lstReceipt = Database.query('Select Id,name,Receipt_Date__c, Receipt_No__c, Mode__c, Cheque_DD__c,Cheque_DD_Date__c,Receipt_Status__c,Project_Name_with_Tower_Name__c,'
                                            +' Cheque_DD_Amount_Rs__c, DraweeBank__c,Amount_in_Foreign_Currency__c, Foreign_Currency_Type__c,'
                                            +' Project__r.Name,'
                                            +' Project_Unit__c,Project_Unit__r.Legal_Entity__c, Project_Unit__r.Legal_Entity__r.Name, Project_Unit__r.Legal_Entity__r.RDS_Address1__c, Project_Unit__r.Name, Opportunity__c,'
                                            +' Project_Unit__r.Legal_Entity__r.RDS_PAN_No__c,Project_Unit__r.Legal_Entity__r.RDS_Service_Tax_No__c,'
                                            +' Project_Unit__r.Legal_Entity__r.RDS_City__c,Project_Unit__r.Legal_Entity__r.RDS_Pin_Code__c,'
                                            +' Opportunity__r.Name, Opportunity__r.Applicant_Name__c, Total_Amount__c,'
                                            +' Opportunity__r.AccountId, Opportunity__r.Account.Name, Opportunity__r.Account.Code__c,'
                                            +' Opportunity__r.Account.Correspondence_Address__c, Opportunity__r.Unit__r.Booking__r.Application_No__c,'
                                            +' Project_Unit__r.Booking__r.Application_No__c, Booking__r.Application_No__c,Drawee_Bank_If_Others__c,'
                                            +' (Select Amount__c, Id, Charges__r.Name from Receipt_Details__r),'
                                            +' Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity,Opportunity__r.Account.BillingState,Opportunity__r.Account.BillingPostalcode,'
                                            +' Opportunity__r.Account.BillingCountry,'                 
                                            +' Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Mailing_Address__c,Opportunity__r.Sales_Manager__c,'
                                            +' Opportunity__r.Account.PersonMobilePhone,'
                                            +' Opportunity__r.Unit__r.Name,Receipt_Number__c,Amount_Rs__c,'
                                            +' Booking__r.Owner.Name,Booking__r.Owner.Email,Booking__r.Owner.Phone,'
                                            +' Opportunity__r.Unit__r.Legal_Entity__r.RDS_PAN_No__c,'
                                            +' Opportunity__r.Unit__r.Legal_Entity__r.RDS_Service_Tax_No__c,'
                                            +' Opportunity__r.Unit__r.Legal_Entity__r.RDS_Address1__c,'
                                            +' Opportunity__r.Unit__r.Legal_Entity__r.RDS_City__c,'
                                            +' Opportunity__r.Unit__r.Legal_Entity__r.RDS_Pin_Code__c,'
                                            +' Opportunity__r.Unit__r.Tower__r.Name,'
                                            +' Opportunity__r.Unit__r.Floor__c,'
                                            +' Challan_No__c,NEFT__c, Currency__c,'
                                            +' Opportunity__r.Primary_Phone__c,'
                                            + ' Project_Unit__r.Tower__r.Name,'
                                            +' Project_Unit__r.Owner.Name,Project_Unit__r.Owner.Email,Project_Unit__r.Owner.Phone,On_Account_Money__c,'
                                            +' Description__c, Project_Unit__r.Sub_project_tower__c'
                                            +' from Receipt__c where id =: strReceiptId',AccessLevel.SYSTEM_MODE);
            }  
            
            system.debug('lstReceipt - ' + lstReceipt );
            system.debug('lstReceipt - ' + lstReceipt?.size());
            
            if(lstReceipt != null && lstReceipt.size() == 1){
                Receipt__c receipt = lstReceipt[0];
                uiReceiptProjectName = receipt.Project__r.Name;
                uiReceiptProjectNameWithTowerName = receipt.Project_Name_with_Tower_Name__c;
                uiReceiptProjectTowerName = String.isNotBlank(receipt.Project_Unit__r?.Tower__r?.Name) ? receipt.Project_Unit__r.Tower__r.Name : '' ;//
                uiReceiptDate = receipt.Receipt_Date__c;
                uiReceiptNumber = receipt.Receipt_Number__c;
                uiReceiptCurrency = receipt.Currency__c;
                uiReceiptUnitName = receipt.Project_Unit__r.Name;
                uiReceiptMode = receipt.Mode__c;
                uiReceiptChequeDDDate = receipt.Cheque_DD_Date__c;
                uiReceiptStatus = receipt.Receipt_Status__C;
                //uiTowerName = receipt.Tower__r.Name;
                uiReceiptName = receipt.Name;
                
                
                system.debug('lstReceipt.size() == 1');
               
                
                CustomerPrimaryName  = lstReceipt[0].Opportunity__r.Primary_Name__c;
                CustomerOtherApplicantName = lstReceipt[0].Opportunity__r.Other_Applicants_Name__c;
                CustomerMailingAddress = lstReceipt[0].Opportunity__r.Mailing_Address__c;
                CustomerMobilePhone  =  lstReceipt[0].Opportunity__r.Primary_Phone__c;
                UnitName = lstReceipt[0].Project_Unit__r.Name;
                if(lstReceipt[0].Amount_Rs__c != null)
                    amountRs = lstReceipt[0].Amount_Rs__c;
                if(lstReceipt[0].Cheque_DD_Date__c != null) // Added by Neha on 13/2/19
                    ChequeDate = lstReceipt[0].Cheque_DD_Date__c.format(); 
                if(lstReceipt[0].Receipt_Date__c != null) 
                    ReceiptDate = lstReceipt[0].Receipt_Date__c.format();
                if(lstReceipt[0].Currency__c != '' && lstReceipt[0].Currency__c != null)
                    CurrencyString = lstReceipt[0].Currency__c.toUpperCase();
                ownerSalutation = '';
                ownerName = lstReceipt[0].Opportunity__r.Sales_Manager__c; 
                ownerPhone = ''; 
                ownerEmail =  '';
                PanNo = lstReceipt[0].Project_Unit__r.Legal_Entity__r.RDS_PAN_No__c;  
                ServiceTaxNo = lstReceipt[0].Project_Unit__r.Legal_Entity__r.RDS_Service_Tax_No__c;
                Address = lstReceipt[0].Project_Unit__r.Legal_Entity__r.RDS_Address1__c;
                City = lstReceipt[0].Project_Unit__r.Legal_Entity__r.RDS_City__c;
                PinCode = lstReceipt[0].Project_Unit__r.Legal_Entity__r.RDS_Pin_Code__c;   
                setLogoPath(lstReceipt[0].Project_Unit__r?.Tower__r?.Name);
                isAvailable = true;
            }
        }
    
        void setLogoPath(String towerName){
            this.logoPath = '';
            if(String.isBlank(towerName)) return;

            this.logoPath = '/printAssets/sobhaText.png';

            if(towerName.containsIgnoreCase('Selene Beach')){
                this.logoPath = '/printAssets/SiniyaLogo.png';
            }else if(towerName.containsIgnoreCase('siniya')){
                this.logoPath = '/printAssets/SiniyaLogo.png';    
            }
        }
    }
    
}
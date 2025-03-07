public class PrintReceiptV2 {
    
    
    public List<Receipt__c> lstReceipt {get; set;}
    public Opportunity Customer {get;set;}   
    public String strReceiptId {get; set;} 
    public string letterhead{get;set;} 
    public id bookingId {get; set;}  
    //public list<Legal_Entity__c> le {get;set;}
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
    //public wrapperclass wrapperobj { get; set; }
    //public List < wrapperclass> wrapperList{get; set;}
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
    
    public QRCodeUtility.QR_Data qrData{get;private set;}//Added for SOB-1866
    
    
    
    public PrintReceiptV2()
    {
        qrData = new QRCodeUtility.QR_Data();
        le = new Legal_Entity__c();
        PanNo = '';
        ServiceTaxNo = '';
        Address = '';
        City = '';
        PinCode = '';
        accMoney = '';
        amountRs = 0;
        System.debug('I am in printreceipt');
        if(string.isBlank(strReceiptId)) {
            
            if(ApexPages.currentPage().getParameters().get('id') != null)
            {    
                strReceiptId = ApexPages.currentPage().getParameters().get('id');
                system.debug('i am strReceiptID'+strReceiptId);     
            }
            if(ApexPages.currentPage().getParameters().get('letterhead') != null)
            {    
                letterhead = ApexPages.currentPage().getParameters().get('letterhead');   
                system.debug('letterhead: ' + letterhead);
            }
            getReceiptDetails();
            
        }
        
        if(String.isNotBlank(strReceiptId)){
            this.qrData = QRCodeUtility.createQrDataFor(strReceiptId);
        }
        
    }
    
    public void createErr(){
        if(this.qrData?.err != NULL) ExternalReferenceRegisterUtil.createERR(this.qrData?.err);
    }
    
    public void getReceiptDetails() {
        // if we are coming form the receipt component, the strreceipt is already set
        if(strReceiptId != null)
        {
            lstReceipt = [Select Id,name,Receipt_Date__c, Receipt_No__c, Mode__c, Cheque_DD__c,Cheque_DD_Date__c,Receipt_Status__c,Project_Name_with_Tower_Name__c,
                          Cheque_DD_Amount_Rs__c, DraweeBank__c,Amount_in_Foreign_Currency__c, Foreign_Currency_Type__c,
                          Project__r.Name, 
                          Project_Unit__c,Project_Unit__r.Legal_Entity__c, Project_Unit__r.Legal_Entity__r.Name, Project_Unit__r.Legal_Entity__r.RDS_Address1__c, Project_Unit__r.Name, Opportunity__c,                  
                          Project_Unit__r.Legal_Entity__r.RDS_PAN_No__c,Project_Unit__r.Legal_Entity__r.RDS_Service_Tax_No__c,    
                          Project_Unit__r.Legal_Entity__r.RDS_City__c,Project_Unit__r.Legal_Entity__r.RDS_Pin_Code__c,
                          Opportunity__r.Name, Opportunity__r.Applicant_Name__c, Total_Amount__c, 
                          Opportunity__r.AccountId, Opportunity__r.Account.Name, Opportunity__r.Account.Code__c,
                          Opportunity__r.Account.Correspondence_Address__c, Opportunity__r.Unit__r.Booking__r.Application_No__c,
                          Project_Unit__r.Booking__r.Application_No__c, Booking__r.Application_No__c,Drawee_Bank_If_Others__c,
                          (Select Amount__c, Id, Charges__r.Name from Receipt_Details__r),
                          Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity,Opportunity__r.Account.BillingState,Opportunity__r.Account.BillingPostalcode,
                          Opportunity__r.Account.BillingCountry,
                          // New Added Fields                 
                          Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Mailing_Address__c,Opportunity__r.Sales_Manager__c,
                          Opportunity__r.Account.PersonMobilePhone,
                          Opportunity__r.Unit__r.Name,Receipt_Number__c,Amount_Rs__c,
                          Booking__r.Owner.Name,Booking__r.Owner.Email,Booking__r.Owner.Phone,
                          Opportunity__r.Unit__r.Legal_Entity__r.RDS_PAN_No__c,
                          Opportunity__r.Unit__r.Legal_Entity__r.RDS_Service_Tax_No__c,
                          Opportunity__r.Unit__r.Legal_Entity__r.RDS_Address1__c,
                          Opportunity__r.Unit__r.Legal_Entity__r.RDS_City__c,
                          Opportunity__r.Unit__r.Legal_Entity__r.RDS_Pin_Code__c,
                          Opportunity__r.Unit__r.Tower__r.Name,
                          Opportunity__r.Unit__r.Floor__c,
                          Challan_No__c,NEFT__c, Currency__c,
                          Opportunity__r.Primary_Phone__c,
                          Project_Unit__r.Owner.Name,Project_Unit__r.Owner.Email,Project_Unit__r.Owner.Phone,On_Account_Money__c,
                          Description__c, Project_Unit__r.Sub_project_tower__c 
                          from Receipt__c where id =: strReceiptId];
        }  
        system.debug('lstReceipt : ' + lstReceipt );
        if(lstReceipt != null && lstReceipt.size() == 1) {
            //ApplicantNames = lstReceipt[0].Opportunity__r.Other_Applicants_Name__c; 
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
            
        }       
        
    } // Close PrintReceipt
    
}
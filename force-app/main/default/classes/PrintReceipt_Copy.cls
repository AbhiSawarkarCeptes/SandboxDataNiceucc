public without sharing class PrintReceipt_Copy
{
  public List<PropStrength__Received_Payment__c> lstPayment {get; set;}
    public Opportunity Customer {get;set;}   
    public String strReceiptId {get; set;} 
    public string letterhead{get;set;} 
    public string projectNameWithTower{get;set;} 
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
    public String ChequeDate {get;set;} 
    public String ReceiptDate {get;set;} 
    public String CurrencyString {get;set;} 
    
    public QRCodeUtility_Copy.QR_Data qrData{get;private set;}
    
    public PrintReceipt_Copy()
    {
        qrData = new QRCodeUtility_Copy.QR_Data();
        le = new Legal_Entity__c();
        PanNo = '';
        ServiceTaxNo = '';
        Address = '';
        City = '';
        PinCode = '';
        accMoney = '';
        amountRs = 0;
        System.debug('I am in PrintReceipt_Copy');
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
            this.qrData = QRCodeUtility_Copy.getQrDataFor(strReceiptId);
        }
        
    }
    
    public void createErr(){
        if(String.isNotBlank(this.qrData?.serializedErr)) ExternalReferenceRegisterUtil_Copy.createERR(this.qrData.serializedErr);
    }
    
    public void getReceiptDetails() {
        // if we are coming form the receipt component, the strreceipt is already set
        if(strReceiptId != null)
        {
            lstPayment = [Select Id,name, PropStrength__Application_Booking__r.PropStrength__Project__r.name, PropStrength__Application_Booking__r.PropStrength__Property__r.name,
                          PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.name, Receipt_Number__c, Receipt_Date__c,
                          PropStrength__Payment_Type__c, Currency__c, Receipt_Status__c,PropStrength__Amount__c,PropStrength__Payment_Date__c, PropStrength__Customer_Name__c
                          from PropStrength__Received_Payment__c where id =: strReceiptId and ( recordType.Name = 'Payment Received' or recordType.Name = 'Income Charge Received' )];
        }  
        system.debug('lstReceipt : ' + lstPayment );
        if(lstPayment != null && lstPayment.size() == 1) {
            projectNameWithTower = lstPayment[0].PropStrength__Application_Booking__r.PropStrength__Project__r.name + lstPayment[0].PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.name;
            //ApplicantNames = lstReceipt[0].Opportunity__r.Other_Applicants_Name__c; 
            CustomerPrimaryName  = lstPayment[0].PropStrength__Customer_Name__c;
           /* CustomerOtherApplicantName = lstReceipt[0].Opportunity__r.Other_Applicants_Name__c;
            CustomerMailingAddress = lstReceipt[0].Opportunity__r.Mailing_Address__c;
            CustomerMobilePhone  =  lstReceipt[0].Opportunity__r.Primary_Phone__c;
            UnitName = lstReceipt[0].Project_Unit__r.Name;*/
            if(lstPayment[0].PropStrength__Amount__c != null)
                amountRs = lstPayment[0].PropStrength__Amount__c;
           /* if(lstReceipt[0].Cheque_DD_Date__c != null) // Added by Neha on 13/2/19
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
            PinCode = lstReceipt[0].Project_Unit__r.Legal_Entity__r.RDS_Pin_Code__c;  */  
        }
    }    
}
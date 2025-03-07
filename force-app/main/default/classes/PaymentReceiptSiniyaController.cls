public class PaymentReceiptSiniyaController {
    public QRCodeUtility_Copy.QR_Data qrData{get;private set;}
    public string payId;
    public String msges                                             {get;set;}
    public List<tableWrapper> interimPaymentItemList             {get;set;}
    public List<PropStrength__Received_Payment__c> interimPaymentList             {get;set;}
    public wrapper wrapperRec             {get;set;}
    public tableWrapper tableRec                 		{get;set;}
    public PropStrength__Received_Payment__c interimPayment                 		{get;set;}
    public PropStrength__Applicant_Detail__c applicantDetail						{get;set;}
    Public String e1                                                {get;set;}
    Public List<String> toList  {get;set;}
    public String formattedTime { get; set; }
    public PropStrength__Received_Payment__c paymentRec;
    
    public PaymentReceiptSiniyaController() {
        qrData = new QRCodeUtility_Copy.QR_Data();
        payId = ApexPages.currentPage().getParameters().get('id'); 
        if(String.isNotBlank(payId)){
            this.qrData = QRCodeUtility_Copy.getQrDataFor(payId);
            system.debug('line 22'+ this.qrData);
        }
        msges = '';
        interimPaymentList = new List<PropStrength__Received_Payment__c>();
        interimPaymentItemList = new List<tableWrapper>();
        interimPayment = new PropStrength__Received_Payment__c();
        applicantDetail = new PropStrength__Applicant_Detail__c();
        //applicantDetailList = new List<PropStrength__Applicant_Detail__c>();
        toList = new List<String>();
        e1 = '';
        formattedTime = DateTime.now().format('dd-MMM-yy HH:mm:ss \'(GMT)\'');
        mainmethod();
    }
    
    public void createErr(){
        if(String.isNotBlank(this.qrData?.serializedErr)) ExternalReferenceRegisterUtil_Copy.createERR(this.qrData.serializedErr);
    }
    public void mainmethod(){
        if(payId != null && payId != '') {
            interimPaymentList = [SELECT Id,Name,PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.Project_Name__c,
                                PropStrength__Cheque_Demand_Draft_Number__c,PropStrength__Payment_Type__c,PropStrength__Payment_Date__c,PropStrength__Amount__c,PropStrength__Application_Booking__r.PropStrength__Applicant_Address__c,
                                PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Country_Code__c,
                                PropStrength__Application_Booking__r.CRM_Executive_Email__c,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone,
                                PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c,Interim_Receipt_sent_to_customer__c,
                                PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c
                                FROM PropStrength__Received_Payment__c WHERE Id =: payId AND Interim_Receipt_sent_to_customer__c = false];
            if(!interimPaymentList.isEmpty() && interimPaymentList.size() > 0) {
                interimPayment = interimPaymentList[0];
                tableWrapper tableRec = new tableWrapper();
                tableRec.unitNo = interimPayment.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c;
                tableRec.paymentType  = interimPayment.PropStrength__Payment_Type__c;
                tableRec.paymentDate = interimPayment.PropStrength__Payment_Date__c;
                tableRec.amount = interimPayment.PropStrength__Amount__c;
                interimPaymentItemList.add(tableRec);
                wrapperRec = new wrapper();
                wrapperRec.name = interimPayment.name;                
                wrapperRec.address = interimPayment.PropStrength__Application_Booking__r.PropStrength__Applicant_Address__c;                
                wrapperRec.projectName = interimPayment.PropStrength__Application_Booking__r.Project_Name__c;
                wrapperRec.phone = interimPayment.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Country_Code__c+interimPayment.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone;
                
                e1 = (interimPayment.PropStrength__Application_Booking__r.CRM_Executive_Email__c != null) ? interimPayment.PropStrength__Application_Booking__r.CRM_Executive_Email__c : '';
                System.debug('----------e1------'+e1);
                List<PropStrength__Applicant_Detail__c> applicantDetailList = [SELECT Id,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Name 
                                                        FROM PropStrength__Applicant_Detail__c 
                                                        WHERE PropStrength__Application__c =: interimPayment.PropStrength__Application_Booking__c AND
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
        public String address {get;set;}     
        public String phone {get;set;}        
    }
    
}
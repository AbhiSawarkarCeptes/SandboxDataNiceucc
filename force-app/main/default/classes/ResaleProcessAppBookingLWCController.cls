public with sharing class ResaleProcessAppBookingLWCController {
    
    
    @AuraEnabled(cacheable=true)
    public static ChecklistWrapper getIntrimPaymentCounts(String transactionid){
        Boolean activeResale=false;
        PropStrength__Transaction_Requests__c trRec = [SELECT id,Total_Payment_Due__c,Total_Payment_Received__c,Total_Paid_Percent__c, is_cheklist_completed__c, Name,PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.Handover_Completed__c,
        PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__tower__r.BCC_completed__c  FROM PropStrength__Transaction_Requests__c WHERE Id=:transactionid];      
        ChecklistWrapper wrap = new ChecklistWrapper();
        if(!trRec.is_cheklist_completed__c){
            Integer InnterimRecordCount = [SELECT id from Interim_Payments__c WHERE Application_Booking_Interim__c =: trRec.PropStrength__Application_Booking__c AND Instrument_Date__c >: System.today() ].Size();
            System.debug('inside getactiveresale:==>'+InnterimRecordCount);

            
            wrap.PDCCount = InnterimRecordCount;
            if( trRec.PropStrength__Application_Booking__r.PropStrength__Property__c != null && trRec.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c != null)
                wrap.BccComplete = trRec.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__tower__r.BCC_completed__c;
            wrap.handoverStatus = trRec.propStrength__Application_Booking__r.Handover_Completed__c;
            wrap.totalPaymentDue = trRec.Total_Payment_Due__c;
            wrap.totalPaymentReceive = trRec.Total_Payment_Received__c;
            wrap.totalPaidPer = trRec.Total_Paid_Percent__c;
        }
        else{
            
            wrap.checkListCompleted = true;
        }
        return wrap;
    }
    
    @AuraEnabled(cacheable=false)
    public static String updateTransactionRec(String transactionRec, String transactionId){
        try {
            System.debug('Resale_Process*--'+transactionRec);
            PropStrength__Transaction_Requests__c transactionRecord = (PropStrength__Transaction_Requests__c) System.JSON.deserialize(transactionRec, PropStrength__Transaction_Requests__c.class); 
            transactionRecord.Id = transactionId;
            transactionRecord.is_cheklist_completed__c = true;
            System.debug('Resale_Process*--'+transactionRecord);
            Update transactionRecord;
            return 'Success,'+transactionRecord.Id;
        }
        catch (Exception e) {
            return e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean getactiveresale(String bookid){
        Boolean activeResale=false;
        for(PropStrength__Transaction_Requests__c trReq : [SELECT id, Name FROM PropStrength__Transaction_Requests__c WHERE PropStrength__Application_Booking__c=:bookid and  PropStrength__Status__c!='Request Completed' AND PropStrength__Status__c!='Rejected' ]) 
        {
            //activeResale=true;
        }
        System.debug('inside getactiveresale:==>'+activeResale);
        return activeResale;
        // return [SELECT id, Name FROM Resale_Process__c WHERE booking__c=:bookid and Resale_Process_Stage__c='Active'];
    }
    @AuraEnabled(cacheable=true)
    public static list<PropStrength__Applicant_Detail__c> getallapplicants(String bookid){
        System.debug('bookid*---'+bookid);
        return [SELECT id, Name, PropStrength__Application__r.PropStrength__Property__c, Passport_No_Doc__c, PropStrength__Application__r.PropStrength__Property__r.PropStrength__Tower__c, 
                PropStrength__Type__c, PropStrength__Applicant_Email__c, PropStrength__Applicant_Acc__r.Mailing_Address_Merge__c, PropStrength__Applicant_Acc__r.MobilePhone, 
                PropStrength__Applicant_Acc__r.PropStrength__Nationality__c, PropStrength__Applicant_Acc__r.Passport_Copy_Details_Arabic__c, PropStrength__Applicant_Acc__r.Name, PropStrength__Applicant_Address__c
                FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c=:bookid And PropStrength__Active__c = true];
    }
    @AuraEnabled(cacheable=true)
    public static WrapperClass getBookingDetails(String resaleid, String record){
        Decimal countofpdc=0, amountofpdc=0, latecharges=0;
        Boolean receiptstatus=false;
        Id bookId;
        string resaletyp;
        List<String> otherChargeTypesLst =  new List<String>();
        for(Resale_Other_Charges_Type__mdt roctm : [Select Other_Charges_Type__c  from Resale_Other_Charges_Type__mdt])
        {
            otherChargeTypesLst.add(roctm.Other_Charges_Type__c); 
        }
        bookId=resaleid;
        
        PropStrength__Application_Booking__c book = [SELECT id FROM PropStrength__Application_Booking__c WHERE Id=:bookId ];
        List<Receipt__c> receipts = [Select Id, Receipt_Status__c, Amount_Rs__c, Credit_Card_Charges__c,Other_Charges_Type__c, Total_Amount__c from Receipt__c where booking__c = :bookId];
        for(Receipt__c rec : receipts){
            if(rec.Receipt_Status__c=='UnProcessed' && otherChargeTypesLst.contains(rec.Other_Charges_Type__c ))
            {
                receiptstatus=true;
            }
            if(rec.Receipt_Status__c=='PDC')
            {
                countofpdc=countofpdc+1;
                amountofpdc=amountofpdc+rec.Amount_Rs__c;
                System.debug('PDC Count: '+countofpdc+'----'+amountofpdc);
            }
            if(rec.Other_Charges_Type__c=='Late Payment Charges' && rec.Receipt_Status__c=='Cleared'){
                latecharges=latecharges=rec.Amount_Rs__c;
            }
        }
        //        WrapperClass wrpcls = new WrapperClass(receiptstatus,resaletyp, book.unit__r.tower__r.BCC_completed__c, book.Handover_Completed_del__c, countofpdc, amountofpdc, book.Credit_Card_Charges_Colleceted__c, latecharges);
        WrapperClass wrpcls = new WrapperClass(receiptstatus,resaletyp, true , true, countofpdc, amountofpdc, 0, latecharges);
        return wrpcls;
    }
    
    @AuraEnabled(cacheable=false)
    public static String createResale(String resale, String buyers){
        try {
            PropStrength__Transaction_Requests__c Resale_Process = (PropStrength__Transaction_Requests__c) System.JSON.deserialize(resale, PropStrength__Transaction_Requests__c.class); 
            List<JSON2Apex> BuyerList = (List<JSON2Apex>) System.JSON.deserialize(buyers, List<JSON2Apex>.class); 
            Id customerContRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            Resale_Process.recordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId();
            Resale_Process.PropStrength__Status__c = 'Request Created';
            Resale_Process.PropStrength__Request_Received_from_Client__c = System.today();
            System.debug('Resale_Process*--'+Resale_Process);
            insert Resale_Process;
            System.debug('test---');
            Map<String, contact> mapOfEmailNewContactRec = new Map<String, contact>();
            Map<String, contact> mapOfEmailOldContactRec = new Map<String, contact>();
            List<String> emailList = new List<String>();
            for (JSON2Apex Buyer : BuyerList) {
                emailList.add(Buyer.Email);               
            }
            List<Contact> conRecList = [SELECT id,Email from Contact where email IN : emailList];
            List<Contact> newConRec = new List<Contact>();
            for(contact con : conRecList){
                mapOfEmailOldContactRec.put(con.Email, con);
            }
            
            for (JSON2Apex Buyer : BuyerList) {
                if(!mapOfEmailOldContactRec.containskey(Buyer.Email)){    
                    
                    contact con = new contact(); 
                    con.firstName = Buyer.first_Name;
                    con.phone = Buyer.Phone_Number;
                    con.RecordTypeId = customerContRecType; // Added By Gourav Gour 08/06/2024
                    con.mobilephone = Buyer.Phone_Number;
                    con.lastName = Buyer.last_Name;
                    con.Email = Buyer.Email;
                    con.Emirates_ID__c = Buyer.Emirates_Id;
                    con.MailingCountry = Buyer.Country;
                    con.MailingStreet = Buyer.Street;
                    con.MailingCity = Buyer.City;
                    con.MailingState = Buyer.State;
                    con.MailingPostalCode = Buyer.PostalCode;
                    con.Passport_No__c = Buyer.Passport_Number;
                    con.PropStrength__Nationality__c = Buyer.Nationality;
                    con.PropStrength__Resident_Status__c = Buyer.Residence_Status;                    
                    newConRec.add(con);
                    mapOfEmailNewContactRec.put(con.Email, con);
                }
            }
            if(newConRec.size() > 0){
                insert newConRec;
            }
            List<PropStrength__Customer_Detail__c> customerDetailRecList = new List<PropStrength__Customer_Detail__c>();
            for(JSON2Apex Buyer : BuyerList) {
                PropStrength__Customer_Detail__c customerDetailRec =  new PropStrength__Customer_Detail__c();
                customerDetailRec.PropStrength__Type__c	 = Buyer.Buyer_Type;
                customerDetailRec.Nationality__c = Buyer.Nationality;
                customerDetailRec.PropStrength__Transaction_Request__c = Resale_Process.Id;
                customerDetailRec.PropStrength__Active__c = true;
                customerDetailRec.Mobile__c = Buyer.Phone_Number;
                customerDetailRec.New_Sale_Value__c = Decimal.valueof(Buyer.New_Sale_Value);
                customerDetailRec.Buyer1_Unit_Share_Transfer__c = Decimal.valueof(Buyer.Buyer1_Unit_Share_Transfer);  
                customerDetailRec.PropStrength__Sharing_Ratio__c = Decimal.valueof(Buyer.Buyer1_Unit_Share_Transfer);              
                if(mapOfEmailNewContactRec.containskey(Buyer.email)){
                    customerDetailRec.PropStrength__Contact__c = mapOfEmailNewContactRec.get(Buyer.email).Id;
                    customerDetailRec.PropStrength__Customer_Type__c = 'New Applicant';
                }
                if(mapOfEmailOldContactRec.containskey(Buyer.email)){
                    customerDetailRec.PropStrength__Contact__c = mapOfEmailOldContactRec.get(Buyer.email).Id;
                    customerDetailRec.PropStrength__Customer_Type__c = 'Old Applicant';
                }
                customerDetailRecList.add(customerDetailRec);
            }
            if(customerDetailRecList.size() > 0){ 
               insert customerDetailRecList;
            }
            return 'Success,'+Resale_Process.Id;
        } 
        catch (Exception e) {
            return e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String createAttachment(String filedata,String parentId){
        try {
            if(String.isNotBlank(FileData)) {
                FileDataWP files = (FileDataWP) JSON.deserialize(filedata, FileDataWP.class);
                List<ContentVersion> cvList = new List<ContentVersion>();
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
                conVer.VersionData = EncodingUtil.base64Decode(files.fileContent);
                conVer.Title = files.fileName;
                conVer.PathOnClient = files.fileName;
                insert conVer;
                
                ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id];
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.LinkedEntityId = parentId;
                conDocLink.ContentDocumentId = cv.ContentDocumentId;
                conDocLink.Visibility = 'AllUsers';
                conDocLink.shareType = 'V'; 
                insert conDocLink;        
            }    
            return 'Success';
        } catch (Exception e) {
            return 'Failed';
        }
    }  
   
    
    public class FileDataWP {
        public String fileName;
        public String fileContent;
        public String parentId;
    }
    
    public class WrapperClass {
        @AuraEnabled
        public String resaletype {get; set;}
        @AuraEnabled
        public Boolean bcccompleted {get; set;}
        @AuraEnabled
        public Boolean handoverstatus {get; set;}
        @AuraEnabled
        public Decimal countofpdc {get; set;}
        @AuraEnabled
        public Decimal amountofpdc {get; set;}
        @AuraEnabled
        public Decimal othercharges {get; set;}
        @AuraEnabled
        public Decimal latecharges {get; set;}
        @AuraEnabled
        public Boolean UnprocessedReceipt {get; set;}
        
        public WrapperClass(Boolean UnprocessedReceipt, String resaletype, Boolean bcccompleted, Boolean handoverstatus, Decimal countofpdc, Decimal amountofpdc, Decimal othercharges, Decimal latecharges) 
        {
            this.UnprocessedReceipt=UnprocessedReceipt;
            this.resaletype=resaletype;
            this.bcccompleted=bcccompleted;
            this.handoverstatus=handoverstatus;
            this.countofpdc=countofpdc;
            this.amountofpdc=amountofpdc;
            this.othercharges=othercharges;
            this.latecharges=latecharges;
        }
    }
    
    public class JSON2Apex {        
        public String first_Name;
        public String last_Name;
        public String Salutation;
        public String Email;
        public String Phone_Number;
        public String Passport_Number;
        public String Address;
        public String Resale_Process;
        public String Nationality;
        public String Buyer_Type;
        public String New_Sale_Value;
        public String Emirates_Id;
        public String Country;
        public String City;
        public String Residence_Status;
        public String Street;
        public String State;
        public String PostalCode;
        public String Buyer1_Unit_Share_Transfer;
    }


    public class ChecklistWrapper {        
        @AuraEnabled public Integer PDCCount;
        @AuraEnabled public Decimal totalPaymentDue;
        @AuraEnabled public Decimal totalPaymentReceive;
        @AuraEnabled public Decimal totalPaidPer;
        @AuraEnabled public Boolean BccComplete;
        @AuraEnabled public Boolean handoverStatus;
        @AuraEnabled public Boolean checkListCompleted;
    }    
}
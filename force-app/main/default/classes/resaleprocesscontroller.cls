public without sharing class resaleprocesscontroller {
    
    @AuraEnabled(cacheable=true)
    public static Boolean getactiveresale(String bookid){
        Boolean activeResale=false;
        for(Resale_Process__c resale : [SELECT id, Name FROM Resale_Process__c WHERE booking__c=:bookid and Resale_Process_Stage__c='Active']) 
        {
            activeResale=true;
        }
        System.debug('inside getactiveresale:==>'+activeResale);
        return activeResale;
       // return [SELECT id, Name FROM Resale_Process__c WHERE booking__c=:bookid and Resale_Process_Stage__c='Active'];
    }
    @AuraEnabled(cacheable=true)
    public static list<Applicant_Details__c> getallapplicants(String bookid){
        return [SELECT id, Name, Seller_Percentage__c, Booking__c, Booking__r.Unit__c, Booking__r.unit__r.tower__c, Applicant_Number__c, Email_Address__c, Mailing_Address__c, 
        Mobile_Number__c, PassportNoDetails__c, Nationality__c, Passport_Copy_Details__c FROM Applicant_Details__c WHERE booking__c=:bookid ];
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
        if(record=='resale')
        {
            Resale_Process__c resale =[SELECT Booking__c, Resale_Type__c FROM Resale_Process__c WHERE Id=:resaleid];
            bookId=resale.Booking__c;
            resaletyp=resale.Resale_Type__c;
        }
        else {
            {
                bookId=resaleid;
            }
        }
        Booking__c book = [SELECT id, Credit_Card_Charges_Colleceted__c, Total_On_Account_Money_With_Registration__c, Paid_Percentage__c, Due_Payments__c, Handover_Completed_del__c, unit__r.tower__r.BCC_completed__c FROM Booking__c WHERE Id=:bookId ];
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
        WrapperClass wrpcls = new WrapperClass(receiptstatus,resaletyp, book.unit__r.tower__r.BCC_completed__c, book.Handover_Completed_del__c, countofpdc, amountofpdc, book.Credit_Card_Charges_Colleceted__c, latecharges);
        return wrpcls;
    }

    @AuraEnabled(cacheable=false)
    public static String createResale(String resale, String buyers){
        try {
            Resale_Process__c Resale_Process = (Resale_Process__c) System.JSON.deserialize(resale, Resale_Process__c.class); 
            List<Buyer__c> BuyerList = (List<Buyer__c>) System.JSON.deserialize(buyers, List<Buyer__c>.class); 
            insert Resale_Process;
            for (Buyer__c Buyer : BuyerList) {
                Buyer.Resale_Process__c = Resale_Process.Id;
            }
            insert BuyerList;
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
    
    public Static void onAfterInsertreceipt(List<Receipt__c > newReceiptLst)
    	{
            List<String> otherChargeTypesLst =  new List<String>();
            for(Resale_Other_Charges_Type__mdt roctm : [Select Other_Charges_Type__c  from Resale_Other_Charges_Type__mdt])
            {
              otherChargeTypesLst.add(roctm.Other_Charges_Type__c); 
            }
            Set<Id> bookids = new Set<Id>();
       		for(Receipt__c recp : newReceiptLst)
            {
               if(recp.Receipt_Status__c=='UnProcessed' && otherChargeTypesLst.contains(recp.Other_Charges_Type__c ))
               {
                   bookids.add(recp.Booking__c);
               }
            }
            updateResaleUnproRecords(bookids);
    	}
    
    public Static void onAfterUpdatereceipt(List<Receipt__c > newReceiptLst, Map<Id, Receipt__c> oldReceiptMap){
       		Set<Id> unpBookids = new Set<Id>();
            Set<Id> Bookids = new Set<Id>();
            Set<Id> prcBookids = new Set<Id>();
            List<String> otherChargeTypesLst =  new List<String>();
            for(Resale_Other_Charges_Type__mdt roctm : [Select Other_Charges_Type__c  from Resale_Other_Charges_Type__mdt])
            {
              otherChargeTypesLst.add(roctm.Other_Charges_Type__c); 
            }
            
            for(Receipt__c recep : newReceiptLst)
            {
                If(((recep.Receipt_Status__c == 'UnProcessed' && oldReceiptMap.get(recep.Id).Receipt_Status__c <> 'UnProcessed') || (recep.Receipt_Status__c == 'UnProcessed' && (recep.Other_Charges_Type__c != null && recep.Other_Charges_Type__c != oldReceiptMap.get(recep.id).Other_Charges_Type__c))) && otherChargeTypesLst.contains(recep.Other_Charges_Type__c ))
                	{
                        unpBookids.add(recep.Booking__c);
                    }
                 If(recep.Receipt_Status__c <> 'UnProcessed' && oldReceiptMap.get(recep.Id).Receipt_Status__c == 'UnProcessed' && otherChargeTypesLst.contains(recep.Other_Charges_Type__c ))
                    {
                        Bookids.add(recep.Booking__c);
                    }
                If(recep.Receipt_Status__c == 'UnProcessed' && ((recep.Other_Charges_Type__c != oldReceiptMap.get(recep.id).Other_Charges_Type__c) && !otherChargeTypesLst.contains(recep.Other_Charges_Type__c )))
                   { 
                       Bookids.add(recep.Booking__c);
                    }
            }
            for(Booking__c book :[Select Id,(Select Id, Receipt_Status__c,Other_Charges_Type__c from Receipts__r )  from Booking__c where Id in :Bookids])
            {
                Boolean check=true;
                for (Receipt__c rsp : book.Receipts__r)
                {
                    if(rsp.Receipt_Status__c == 'UnProcessed' && otherChargeTypesLst.contains(rsp.Other_Charges_Type__c ))
                    {
                        check=false;
                        break;
                    }
                }
                if(check)
                {
                    prcBookids.add(book.Id);
                }
            }
            if(!unpBookids.isEmpty())
            {
                updateResaleUnproRecords(unpBookids);
            }
            if(!prcBookids.isEmpty())
            {
               updateResaleproRecords(prcBookids); 
            }
            
    	}
    
        private static void updateResaleUnproRecords(Set<Id> bids){
       List<Resale_Process__c> unProResaleLst = new List<Resale_Process__c>();
       for(Resale_Process__c resale : [Select Id, Unprocessed_Receipt__c  from Resale_Process__c where booking__c in :bids]) 
       {
          if(!resale.Unprocessed_Receipt__c)
          {
             resale.Unprocessed_Receipt__c=true;
          	 unProResaleLst.add(resale); 
          }  
       }
        if(!unProResaleLst.isEmpty())
        {
            update unProResaleLst;
        }
    }
    
    private static void updateResaleproRecords(Set<Id> bids){
        List<Resale_Process__c> proResaleLst = new List<Resale_Process__c>();
       for(Resale_Process__c resale : [Select Id, Unprocessed_Receipt__c  from Resale_Process__c where booking__c in :bids]) 
       {
          if(resale.Unprocessed_Receipt__c)
          {
             resale.Unprocessed_Receipt__c=false;
          	 proResaleLst.add(resale); 
          }  
       }
        if(!proResaleLst.isEmpty())
        {
            update proResaleLst;
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

}
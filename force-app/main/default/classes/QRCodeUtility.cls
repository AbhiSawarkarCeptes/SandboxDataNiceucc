//Test class : TestSRCustomer
public class QRCodeUtility {
    public static final String QR_API = Label.QR_API;
    public static final String GUEST_SITE_LINK = Label.SobhaRealtyCustomerSiteBaseUrl;
	static QR_Data qrData;
    
    public static QR_Data createQrDataFor(String recordIdStr){//dispatcher
        qrData = new QR_Data();
        
        if(!Feature_Flag__mdt.getAll().containsKey('QRCodeInReceipt') || !Feature_Flag__mdt.getInstance('QRCodeInReceipt').Active__c){
            return qrData;
        }
        
        if(String.isBlank(recordIdStr)){
            System.debug('sfEdit recordIdStr - '+recordIdStr);
            return qrData;
        }
        
        Id recordId;
        try{
           recordId = Id.valueOf(recordIdStr); 
        }catch(Exception ex){
            System.debug('sfEdit exception - '+ex.getMessage()+' - '+ex.getStackTraceString());
            return qrData;
        }
        
        //SET LINK
        if(recordId.getSObjectType() == Receipt__c.SObjectType){
            List<Receipt__c> receipts = [SELECT Id FROM Receipt__c WHERE Id = :recordId];
            if(!receipts.isEmpty()) createQRDataFor(receipts[0]);
        }
        
        
        System.debug('sfEdit qrData - '+qrData);
        return qrData;
    }
    
    public static QR_Data getQrDataFor(External_Reference_Register__c err){//dispatcher
        qrData = new QR_Data();
        
        if(err == NULL) return qrData;
        
        qrData.setMessage('This receipt was generated on '+err.Entry_Creation_DateTime__c.format('dd-MMM-yy HH:mm:ss ')+'(GMT). The QR code is valid till '+err.Entry_Expiration_DateTime__c.format('dd-MMM-yy HH:mm:ss ')+'(GMT).');
        qrData.setLink(QR_API+GUEST_SITE_LINK+err.External_Reference__c);
        qrData.setErr(err);
        return qrData;
    }
    
    static void createQRDataFor(Receipt__c receipt){
        ExternalReferenceRegisterUtil.ERRCreationResult errCR = ExternalReferenceRegisterUtil.createExternalReference('Receipt',receipt?.Id);
        qrData.setMessage('This receipt was generated on '+DateTime.now().format('dd-MMM-yy HH:mm:ss ')+'(GMT). The QR code is valid till '+errCR?.err?.Entry_Expiration_DateTime__c.format('dd-MMM-yy HH:mm:ss ')+'(GMT).');
        qrData.setLink(QR_API+GUEST_SITE_LINK+errCR?.externalReference);
        qrData.setErr(errCR?.err);
    }    
    
    public class QR_Data{
        public Boolean isAvailable{get;private set;}
        public String link{get;private set;}
        public String validityMessage{get;private set;}
        public External_Reference_Register__c err{get;private set;}
        
        public QR_Data(){
            this.isAvailable = false;
        }
        
        void setLink(String link){
            this.link = link;
            reCalculateIsAvailable();
        }
        
        void setMessage(String validityMessage){
            this.validityMessage = String.isBlank(validityMessage) ? '' : validityMessage ;
            reCalculateIsAvailable();
        }
        
        void setErr(External_Reference_Register__c err){
            this.err = err;
        }
        
        void reCalculateIsAvailable(){
            this.isAvailable = (String.isNotBlank(link) && validityMessage != NULL);
        }
    }
}
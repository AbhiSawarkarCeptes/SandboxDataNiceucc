public class QRCodeUtility_Copy {
    private static final String GUEST_SITE_LINK = Label.SobhaRealtyCustomerSiteBaseUrlCopy;
	static QR_Data qrData;
    
    public static QR_Data getQrDataFor(String recordIdStr){//dispatcher
        qrData = new QR_Data();
        
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
        if(recordId.getSObjectType() == PropStrength__Received_Payment__c.SObjectType){
            List<PropStrength__Received_Payment__c> receipts = [SELECT Id FROM PropStrength__Received_Payment__c WHERE Id = :recordId];
            qrData.setLink(receipts.isEmpty() ? NULL : createLinkFor(receipts[0]));
        }
        
        if(recordId.getSObjectType() == Interim_Payments__c.SObjectType){
            List<Interim_Payments__c> receipts = [SELECT Id FROM Interim_Payments__c WHERE Id = :recordId];
            qrData.setLink(receipts.isEmpty() ? NULL : createLinkFor(receipts[0]));
        }
        //SET VALIDITY MESSAGE
        qrData.setMessage('This Receipt was generated @ '+DateTime.now()+'(GMT)');
        
        System.debug('sfEdit qrData - '+qrData);
        return qrData;
    }
    
    static String createLinkFor(Sobject receipt){
            ExternalReferenceRegisterUtil_Copy.ERRCreationResult errCR = ExternalReferenceRegisterUtil_Copy.createExternalReference('Payment',receipt.Id);
            qrData.setSerializedErr(errCR.serializedErr);
            System.debug(qrData+'-*-*--'+errCR);
            return GUEST_SITE_LINK+errCR.externalReference;
        }
    // static String createLinkFor(PropStrength__Received_Payment__c receipt){
    //     ExternalReferenceRegisterUtil_Copy.ERRCreationResult errCR = ExternalReferenceRegisterUtil_Copy.createExternalReference('Payment',receipt.Id);
    //     qrData.setSerializedErr(errCR.serializedErr);
    //     System.debug(qrData+'-*-*--'+errCR);
    //     return GUEST_SITE_LINK+errCR.externalReference;
    // }
    
    public class QR_Data{
        public Boolean isAvailable{get;private set;}
        public String link{get;private set;}
        public String validityMessage{get;private set;}
        public String serializedErr{get;private set;}
        
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
        
        void setSerializedErr(String serializedErr){
            this.serializedErr = String.isBlank(serializedErr) ? '' : serializedErr ;
        }
        
        void reCalculateIsAvailable(){
            this.isAvailable = (String.isNotBlank(link) && validityMessage != NULL);
        }
    }
    
}
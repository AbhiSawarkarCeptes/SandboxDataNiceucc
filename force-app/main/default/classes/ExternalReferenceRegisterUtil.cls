//Test class : TestSRCustomer
public without sharing class ExternalReferenceRegisterUtil {

    public static ERRCreationResult createExternalReference(String document,String internalReference){
        
        External_Reference_Register_Config__mdt config = External_Reference_Register_Config__mdt.getInstance(document);
        
        if(config == NULL) return NULL;
        
        Blob aesKey = Crypto.generateAesKey(Integer.valueOf(config.Encryption_Key_Size__c));
        Blob encrypted = Crypto.encryptWithManagedIV('AES'+Integer.valueOf(config.Encryption_Key_Size__c),aesKey, Blob.valueOf(internalReference));
        String externalReference = EncodingUtil.convertToHex(encrypted);
        
        External_Reference_Register__c err = new External_Reference_Register__c(
        	Internal_Reference__c = internalReference,
            External_Reference__c = externalReference,
            Entry_Creation_DateTime__c = System.now(),
            Entry_Expiration_DateTime__c = System.now().addHours(Integer.valueOf(config.Expiry_Duration_Hours__c)),
            Encryption_Key__c = EncodingUtil.convertToHex(aesKey),
            Encryption_Key_Size__c = Integer.valueOf(config.Encryption_Key_Size__c)
        );
        
        return new ERRCreationResult(err,err.External_Reference__c);
    }
    
    public static External_Reference_Register__c getExternalReferenceRegister(String externalReference){
        String query = 'SELECT Id,Internal_Reference__c,External_Reference__c,Entry_Creation_DateTime__c,Entry_Expiration_DateTime__c,Encryption_Key__c,Encryption_Key_Size__c,Verification_Code__c FROM External_Reference_Register__c WHERE External_Reference__c = :externalReference';
        Map<String,Object> filterMap = new Map<String,Object>{'externalReference' => externalReference};

        List<External_Reference_Register__c> errs = Database.queryWithBinds(query,filterMap,AccessLevel.SYSTEM_MODE);
        if(errs.isEmpty()) return NULL;
        
        return errs[0];
    }
    
    public static void createERR(External_Reference_Register__c err){
        if(err == NULL) return;
        insert err;
        createDocumentAccessLog(err.Internal_Reference__c,'Public Link Generated','Success');
    }
    
    public static Boolean isValidReference(String externalReference){
        return String.isNotBlank(fetchInternalReference(externalReference));
    }
    
    public static String fetchInternalReference(String externalReference){
        String query = 'SELECT Id,Internal_Reference__c,External_Reference__c,Entry_Creation_DateTime__c,Entry_Expiration_DateTime__c,Encryption_Key__c,Encryption_Key_Size__c,Verification_Code__c FROM External_Reference_Register__c WHERE External_Reference__c = :externalReference';
        Map<String,Object> filterMap = new Map<String,Object>{'externalReference' => externalReference};

        List<External_Reference_Register__c> errs = Database.queryWithBinds(query,filterMap,AccessLevel.SYSTEM_MODE);
        if(errs.isEmpty()) return NULL;
        
        External_Reference_Register__c err = errs[0];
        if(err.Entry_Expiration_DateTime__c == NULL || err.Entry_Expiration_DateTime__c <= System.Now() || String.isBlank(err.Internal_Reference__c)) return null;
        
        return err.Internal_Reference__c;
    }
    
    public static void challenge(String externalReference){
        String query = 'SELECT Id,Internal_Reference__c,External_Reference__c,Entry_Creation_DateTime__c,Entry_Expiration_DateTime__c,Encryption_Key__c,Encryption_Key_Size__c,Verification_Code__c FROM External_Reference_Register__c WHERE External_Reference__c = :externalReference';
        Map<String,Object> filterMap = new Map<String,Object>{'externalReference' => externalReference};
        List<External_Reference_Register__c> errs = Database.queryWithBinds(query,filterMap,AccessLevel.SYSTEM_MODE);
        Long randomLong = Crypto.getRandomLong();
    	randomLong = randomLong < 0 ? randomLong*(-1) : randomLong;
		Integer otp = Integer.valueOf((randomLong+'').substring(0,6));
        errs[0].Verification_Code__c = otp+'';
        update errs[0];
        sendOtpToCustomer(errs[0]);
        createDocumentAccessLog(errs[0].Internal_Reference__c,'Public Link Accessed','Success');
    }
    
    public static ChallengeResult verifyChallenge(String externalReference,String otp){
        String query = 'SELECT Id,Internal_Reference__c,External_Reference__c,Entry_Creation_DateTime__c,Entry_Expiration_DateTime__c,Encryption_Key__c,Encryption_Key_Size__c,Verification_Code__c FROM External_Reference_Register__c WHERE External_Reference__c = :externalReference';// AND Verification_Code__c  =:otp
        Map<String,Object> filterMap = new Map<String,Object>{'externalReference' => externalReference};//,'otp' => otp
        List<External_Reference_Register__c> errs = Database.queryWithBinds(query,filterMap,AccessLevel.SYSTEM_MODE);
        return new ChallengeResult(errs,otp);
    }
    
    public static void sendOtpToCustomer(External_Reference_Register__c err){
        if(err == NULL || String.isBlank(err.Internal_Reference__c)) return;
        Id documentId = Id.valueOf(err.Internal_Reference__c);
        if(documentId.getSObjectType() == Receipt__c.SObjectType){
            Set<String> targetEmailIds = new Set<String>();
            List<Applicant_Details__c> ads = Database.queryWithBinds('SELECT id,Email_Address__c FROM Applicant_Details__c WHERE Booking__c IN (SELECT Booking__c FROM Receipt__c WHERE Id = :documentId)',new Map<String,Object>{'documentId' => documentId},AccessLevel.SYSTEM_MODE);
            for(Applicant_Details__c ad : ads){
                if(String.isNotBlank(ad.Email_Address__c)) targetEmailIds.add(ad.Email_Address__c);
            }
            sendOtpEmail(new List<String>(targetEmailIds),err.Verification_Code__c);               
        }
    }
    
    static void sendOtpEmail(List<String> targetEmailIds,String otp){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
        List<OrgWideEmailAddress> owea = Database.queryWithBinds('SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName= :displayName',new Map<String,Object>{'displayName'=>Label.NoReplyOrgWideDisplayName},AccessLevel.SYSTEM_MODE);
        mail.setOrgWideEmailAddressId(owea[0].Id);
        mail.setToAddresses(targetEmailIds) ;
        mail.setSubject('OTP for Authentication');
        
        String body = '<html lang="en"><body>'+
                        '<br><br>'+
                        'Greetings,'+
                        '<br><br>'+'Please find the OTP for authentication of your payment receipt : '+otp+'</b><br>'+
                        '</body></html>';
        mail.setHtmlBody(body);
        if(!Test.isRunningTest()) Messaging.SendEmailResult[] sER = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public class ChallengeResult{
        public Boolean cleared;
        public String internalReference;
        ChallengeResult(List<External_Reference_Register__c> errs,String otp){
            this.cleared = errs != NULL && !errs.isEmpty() && errs[0].Verification_Code__c == otp;
            this.internalReference = this.cleared ? errs[0].Internal_Reference__c : NULL;
            createDocumentAccessLog(this.cleared ? errs.get(0).Internal_Reference__c : NULL,'Receipt Accessed',this.cleared ? 'Success' : 'Failure');
        }
    }
    
    public class ERRCreationResult{
        public String externalReference{get;set;}
        public External_Reference_Register__c err{get;set;}
        ERRCreationResult(External_Reference_Register__c err,String externalReference){
            this.err = err;
            this.externalReference = externalReference;
        }
    }
    public static void createDocumentAccessLog(String documentIdStr,String action,String actionResult){
        Document_Access_Log__c dal = new Document_Access_Log__c();
        try{
            Id documentId = Id.valueOf(documentIdStr);
            
            if(documentId.getSObjectType() == Receipt__c.SObjectType){
            	dal.Receipt__c = documentId;
            }
            
            dal.action__c = action;
            dal.action_result__c = actionResult;
            Database.insert(dal,AccessLevel.SYSTEM_MODE);
        }catch(Exception ex){}
    }
}
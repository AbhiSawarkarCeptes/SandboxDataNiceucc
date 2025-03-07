public without sharing class ExternalReferenceRegisterUtil_Copy{

    public static ERRCreationResult createExternalReference(String document,String internalReference){
        
        System.debug('sfEdit document / internalReference - '+document+' / '+internalReference);
        External_Reference_Register_Config_Copy__mdt config = External_Reference_Register_Config_Copy__mdt.getInstance(document);
        System.debug('sfEdit  config - '+config);
        
        if(config == NULL) return NULL;
        
        Blob aesKey = Crypto.generateAesKey(Integer.valueOf(config.Encryption_Key_Size__c));
        Blob encrypted = Crypto.encryptWithManagedIV('AES'+config.Encryption_Key_Size__c,aesKey, Blob.valueOf(internalReference));
        String externalReference = EncodingUtil.convertToHex(encrypted);
        
        External_Reference_Register__c err = new External_Reference_Register__c(
        	Internal_Reference__c = internalReference,
            External_Reference__c = externalReference,
            Entry_Creation_DateTime__c = System.now(),
            Entry_Expiration_DateTime__c = System.now().addHours(Integer.valueOf(config.Expiry_Duration_Hours__c)),
            Encryption_Key__c = EncodingUtil.convertToHex(aesKey),
            Encryption_Key_Size__c = Integer.valueOf(config.Encryption_Key_Size__c)
        );
        System.debug('err.External_Reference__c**---'+err.External_Reference__c);
        return new ERRCreationResult(JSON.serialize(err),err.External_Reference__c);
        //createERRAsync(JSON.serialize(err));
        //return err.External_Reference__c;
    }
    
    public static void createERR(String errString){
        System.debug('errString**---'+errString);
        External_Reference_Register__c err = (External_Reference_Register__c) JSON.deserialize(errString,External_Reference_Register__c.class);
        insert err;
    }
    
    public static Boolean isValidReference(String externalReference){
        return String.isNotBlank(fetchInternalReference(externalReference));
    }
    
    public static String fetchInternalReference(String externalReference){
        System.debug('externalReference**--'+externalReference);
        String query = 'SELECT Id,Internal_Reference__c,External_Reference__c,Entry_Creation_DateTime__c,Entry_Expiration_DateTime__c,Encryption_Key__c,Encryption_Key_Size__c FROM External_Reference_Register__c WHERE External_Reference__c = :externalReference';
        Map<String,Object> filterMap = new Map<String,Object>{'externalReference' => externalReference};

        List<External_Reference_Register__c> errs = Database.queryWithBinds(query,filterMap,AccessLevel.SYSTEM_MODE);
        if(errs.isEmpty()) return NULL;
        
        External_Reference_Register__c err = errs[0];
        
        if(err.Entry_Expiration_DateTime__c == NULL || err.Entry_Expiration_DateTime__c <= System.Now() || String.isBlank(err.Internal_Reference__c)) return null;
        System.debug('err.Internal_Reference__c**--'+err.Internal_Reference__c);
        return err.Internal_Reference__c;
    }
    
    public static void challenge(String externalReference){
        String query = 'SELECT Id,Internal_Reference__c,External_Reference__c,Entry_Creation_DateTime__c,Entry_Expiration_DateTime__c,Encryption_Key__c,Encryption_Key_Size__c,Verification_Code__c FROM External_Reference_Register__c WHERE External_Reference__c = :externalReference';
        Map<String,Object> filterMap = new Map<String,Object>{'externalReference' => externalReference};
        List<External_Reference_Register__c> errs = Database.queryWithBinds(query,filterMap,AccessLevel.SYSTEM_MODE);
        System.debug('sfEdit errs - '+errs);
        Long randomLong = Crypto.getRandomLong();
    	randomLong = randomLong < 0 ? randomLong*(-1) : randomLong;
		Integer otp = Integer.valueOf((randomLong+'').substring(0,6));
        errs[0].Verification_Code__c = otp+'';
        System.debug('sfEdit errs 2 - '+errs);
        update errs[0];
        sendOtpToCustomer(errs[0]);
    }
    
    public static ChallengeResult verifyChallenge(String externalReference,String otp){
        String query = 'SELECT Id,Internal_Reference__c,External_Reference__c,Entry_Creation_DateTime__c,Entry_Expiration_DateTime__c,Encryption_Key__c,Encryption_Key_Size__c,Verification_Code__c FROM External_Reference_Register__c WHERE External_Reference__c = :externalReference AND Verification_Code__c  =:otp';
        Map<String,Object> filterMap = new Map<String,Object>{'externalReference' => externalReference,'otp' => otp};
        List<External_Reference_Register__c> errs = Database.queryWithBinds(query,filterMap,AccessLevel.SYSTEM_MODE);
        return new ChallengeResult(errs);
    }
    
    public static void sendOtpToCustomer(External_Reference_Register__c err){
        System.debug('sfEdit err 3 - '+err);
        if(err == NULL || String.isBlank(err.Internal_Reference__c)) return;
        Id documentId = Id.valueOf(err.Internal_Reference__c);
        System.debug('sfEdit documentId - '+documentId);
        if(documentId.getSObjectType() == PropStrength__Received_Payment__c.SObjectType){
            Set<String> targetEmailIds = new Set<String>();
            List<PropStrength__Applicant_Detail__c> ads = Database.queryWithBinds('SELECT id,PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c  IN (SELECT PropStrength__Application_Booking__c FROM PropStrength__Received_Payment__c WHERE Id = :documentId and (recordType.Name = \'Payment Received\' or recordType.Name = \'Income Charge Received\'))',new Map<String,Object>{'documentId' => documentId},AccessLevel.SYSTEM_MODE);
            for(PropStrength__Applicant_Detail__c ad : ads){
                if(String.isNotBlank(ad.PropStrength__Applicant_Email__c)) targetEmailIds.add(ad.PropStrength__Applicant_Email__c);
            }
            System.debug('sfEdit targetEmailIds - '+targetEmailIds);
            sendOtpEmail(new List<String>(targetEmailIds),err.Verification_Code__c);
        }
        else if(documentId.getSObjectType() == Interim_Payments__c.SObjectType){
            Set<String> targetEmailIds = new Set<String>();
            List<PropStrength__Applicant_Detail__c> ads = Database.queryWithBinds('SELECT id,PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c  IN (SELECT Application_Booking_Interim__c FROM Interim_Payments__c WHERE Id = :documentId and (recordType.Name = \'Payment Received\' or recordType.Name = \'Income Charges Received\'))',new Map<String,Object>{'documentId' => documentId},AccessLevel.SYSTEM_MODE);
            for(PropStrength__Applicant_Detail__c ad : ads){
                if(String.isNotBlank(ad.PropStrength__Applicant_Email__c)) targetEmailIds.add(ad.PropStrength__Applicant_Email__c);
            }
            System.debug('sfEdit targetEmailIds - '+targetEmailIds);
            sendOtpEmail(new List<String>(targetEmailIds),err.Verification_Code__c);
        }
    }
    
    static void sendOtpEmail(List<String> targetEmailIds,String otp){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
        List<OrgWideEmailAddress> owea = Database.query('SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName= \'test\'');
        if(owea.size() > 0) {
                 mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setToAddresses(targetEmailIds);
        String str = [SELECT id from contact limit 1].id;
        System.debug('str*---'+owea); 
        mail.setSubject('OTP for Authentication');
        mail.setSaveAsActivity(true);         
        mail.setTargetObjectId(str); 
        mail.setTreatTargetObjectAsRecipient(false);
        String body = '<html lang="en"><body>'+
                        '<br><br>'+
                        'Greetings,'+
                        '<br><br>'+'Please find the OTP for authentication : '+otp+'</b><br>'+
                        '</body></html>';
        System.debug('sfEdit body - '+body);
        mail.setHtmlBody(body);
        Messaging.SendEmailResult[] sER = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('sfEdit sER - '+sER);
    }
    
    public class ChallengeResult{
        public Boolean cleared;
        public String internalReference;
        ChallengeResult(List<External_Reference_Register__c> errs){
            this.cleared = errs != NULL && !errs.isEmpty();
            this.internalReference = this.cleared ? errs[0].Internal_Reference__c : NULL;
        }
    }
    
    public class ERRCreationResult{
        public String externalReference{get;set;}
        public String serializedErr{get;set;}
        ERRCreationResult(String serializedErr,String externalReference){
            this.serializedErr = serializedErr;
            this.externalReference = externalReference;
        }
    }
    
}
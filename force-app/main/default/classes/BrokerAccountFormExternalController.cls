public without sharing class BrokerAccountFormExternalController {
    
    @AuraEnabled
    public static Map<String,Object> getRecord(Id recordId){
        try {
            if( recordId == null )
                throw new BrokerRegistrationException('Invalid record id');

            Map<String,Object> response = new Map<String,Object>();
            response.put('today', Date.today());
            // fields removed
// Witness_Name__c, Witness_Email_1__c, Registration_Link_Expiry_Date_Time__c,   Renewal_Status__c ,Registration_Number__c,, First_Name__c, Last_Name__c
            Account record = [ 
                SELECT Id, Account_Owner_Email__c, Name_as_per_trade_license__c,Mobile_No__c, Email_ID_1__c, Phone, Name_as_per_passport__c, Nationality__c, Designation1__c, Office_Apartment_number__c, 
                Villa_Building_name__c, Street_name__c, District_Area__c, BillingCity, Country__c, BillingPostalCode, Broker_Sub_Type__c, 
                Phone__c, Fax_correspondence__c, Mobile__c, Email__c, RERA_Number__c,Witness_Name__c, Witness_Email__c, Registration_Link_Expiry_Date_Time__c,
                Renewal_Status__c, Registration_Number__c,BillingStreet,BillingState, BillingCountry, Email_ID_2__c, 
                Broker_Category__c, PropStrength__Broker_Type__c, Status__c , Name, Broker_Created_Date__c,PropStrength__Broker_Approval_Status__c,PropStrength__Broker_Code__c,
                recordtype.Name
                FROM Account
                WHERE Id = :recordId
            ][0];
            
            if( record.PropStrength__Broker_Approval_Status__c != 'Broker Empanelment Form Filled' ){
                throw new BrokerRegistrationException('Your Registration is done. Check with the System admin for further process');
            }
            
            if( record.Registration_Link_Expiry_Date_Time__c <= DateTime.now()){
                throw new BrokerRegistrationException('Your Registration link is expired. Check with the System admin for further process');
            }
            
            response.put('record', record);
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    @AuraEnabled
    public static Account updateRecord(Account record){
        try {
            system.debug('~~ToCreate: '+record);
            /*if(record.Status__c=='Executed Agreement sent to broker' && record.Renewal_Status__c=='Renewal Initiated'){
               Account returnRecord = createRenewalRecord(record); 
               return returnRecord;
            }*/
            
            if(record.recordtype.Name!='Renewal'){
                /*if( BrokerAccountController.isDuplicate(record) ){
                    throw new BrokerRegistrationException('A broker is already registered with the provided name in \'Name as per Trade License\' field.');
                }*/
            } else {
                // Account parentBroker = [Select Id, Renewal_Status__c from Account where Renewal_Record_Id__c=:record.Id];
                // // parentBroker.Renewal_Status__c = 'Renewal In Progress';
                // update parentBroker;
            }

            // record.Status__c = 'CHRM Registration Done';
            String billingStreet = '';
            billingStreet += record.Office_Apartment_number__c != null ? record.Office_Apartment_number__c +', ' : '';
            billingStreet += record.Street_name__c != null ? record.Street_name__c +', ' : '';
            billingStreet += record.Villa_Building_name__c != null ? record.Villa_Building_name__c +', ' : '';
            record.State_Province__c = record.BillingState;
            record.City_Local__c = record.BillingCity;
            record.Country_CP__c = record.BillingCountry;
            record.Zip_Postal_Code_CP__c = record.BillingPostalCode;
            record.PropStrength__Broker_Approval_Status__c = 'Broker Registration Done';
            record.Broker_Created_Date__c = Datetime.now();
            record.Registration_Date__c = System.Today();
            record.Modified_by_guest_user__c = true;
            // record.Name_as_per_Trade_License__c = record.Name_as_per_Trade_License__c?.toUpperCase();
            update record;
            
            Account acc = [SELECT Id, PropStrength__Broker_Code__c FROM Account WHERE Id = :record.Id];
            List<Account> accCopy = [SELECT Id, PropStrength__Broker_Code__c FROM Account WHERE Al_Siniya_Partner__c = true AND PropStrength__Broker_Code__c = :acc.PropStrength__Broker_Code__c];
            
            if(!accCopy.isEmpty()) {
                Account tempUpdate = record;
                tempUpdate.Id = accCopy[0].Id;
                String billingStreet2 = '';
                billingStreet2 += record.Office_Apartment_number__c != null ? record.Office_Apartment_number__c +', ' : '';
                billingStreet2 += record.Street_name__c != null ? record.Street_name__c +', ' : '';
                billingStreet2 += record.Villa_Building_name__c != null ? record.Villa_Building_name__c +', ' : '';
                tempUpdate.State_Province__c = record.BillingState;
                tempUpdate.City_Local__c = record.BillingCity;
                tempUpdate.Country_CP__c = record.BillingCountry;
                tempUpdate.Zip_Postal_Code_CP__c = record.BillingPostalCode;
                tempUpdate.PropStrength__Broker_Approval_Status__c = 'Broker Registration Done';
                tempUpdate.Broker_Created_Date__c = Datetime.now();
                tempUpdate.Registration_Date__c = System.Today();
                tempUpdate.Modified_by_guest_user__c = true;
                update tempUpdate;
            }
            
            system.debug('~~~~~Records Updated: '+record);
            return record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Map<String,String>> picklistValues(String objectName, String fieldName) {
        List<Map<String,String>> values = new List<Map<String,String>>{};

        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    Map<String,String> option = new Map<String,String>{
                        'label' => entry.getLabel(),
                        'value' => entry.getValue()
                    };
                    values.add(option);
                }
            }
        }
        return values;
    }
    @AuraEnabled
    public static string deleteDocuments(List<Id> DocIds) {
        try {
            System.debug(DocIds);
            List<Id> tempId = new List<Id>();
            List<Id> cloneDocIds = DocIds;
            for(Id dId : cloneDocIds) {
                if(String.valueOf(dId).contains(',')) {
                    tempId.addAll(String.valueOf(dId).split(','));
                    DocIds.remove(DocIds.indexOf(dId));
                }
            }
            
            System.debug(DocIds);

            DocIds.addAll(tempId);
            
            System.debug(DocIds);
            
            Set<String> brId = new Set<String>();
            List<ContentDocument> existDocList = new List<ContentDocument>();
            List<BR_Document_History__c> brList = new List<BR_Document_History__c>();
            if(!DocIds.isEmpty()) {
                for(ContentDocument docRecord : [SELECT Id, ParentId, (SELECT Id, LinkedEntityId FROM ContentDocumentLinks) FROM ContentDocument WHERE ID IN: DocIds]) {
                    existDocList.add(new ContentDocument(id = docRecord.Id));
                    
                    if(docRecord.ContentDocumentLinks.size() < 2 && !brId.contains(docRecord.ParentId)) {
                        brList.add(new BR_Document_History__c(Id=docRecord.ParentId));
                        brId.add(docRecord.ParentId);
                    }
                }
            }
            if(!existDocList.isEmpty()) {
                delete existDocList;
            }
            if(!brList.isEmpty()) {
                delete brList;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static ID getDocID(String recordID){
          system.debug('recordID----'+recordID);
          if(recordID != null){
            ContentDocumentLink cdl = [SELECT contentDocumentId from ContentDocumentLink where LinkedEntityId =:recordID  order by SystemModstamp desc limit 1];

            return cdl.contentDocumentId;
          }else return null;
       
    }
    @AuraEnabled(cacheable=false)
    public static String createAttachment(String title, String fileName, String fileContent, String parentId) {
        System.debug('===> title ' + title);
        System.debug('===> fileName ' + fileName);
        System.debug('===> fileContent ' + fileContent);
        System.debug('===> parentId ' + parentId);
        List<BR_Document_History__c> existDocList = new List<BR_Document_History__c>();
        
        Account acc = [SELECT Id, PropStrength__Broker_Code__c FROM Account WHERE Id = :parentId];
        List<Account> accCopy = [SELECT Id, PropStrength__Broker_Code__c FROM Account WHERE Al_Siniya_Partner__c = true AND PropStrength__Broker_Code__c = :acc.PropStrength__Broker_Code__c];
        
        try {
            if(!String.isBlank(parentId) && !String.isBlank(title)) {
                existDocList = [SELECT Id, File_Type__c                                                             
                                    FROM BR_Document_History__c 
                                    WHERE Broker_Account__c =: parentId AND 
                                        File_Type__c =: title LIMIT 1];
            }
            System.debug('===> existDocList ' + existDocList);
            if(!String.isBlank(title) && !String.isBlank(fileContent) && !String.isBlank(fileName)) {
                if(!existDocList.isEmpty()) {
                    List<ContentVersion> cvList = new List<ContentVersion>();
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
                    conVer.VersionData = EncodingUtil.base64Decode(fileContent);
                    conVer.Title = title;
                    conVer.PathOnClient = fileName;
                    insert conVer;
                    
                    ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id];
                    ContentDocumentLink conDocLink = new ContentDocumentLink();
                    conDocLink.LinkedEntityId = existDocList[0].Id;
                    conDocLink.ContentDocumentId = cv.ContentDocumentId;
                    conDocLink.Visibility = 'AllUsers';
                    conDocLink.shareType = 'V'; 
                    insert conDocLink;  
                    
                    if(!accCopy.isEmpty()) {
                        existDocList = [SELECT Id, File_Type__c                                                             
                                    FROM BR_Document_History__c 
                                    WHERE Broker_Account__c =: accCopy[0].Id AND 
                                        File_Type__c =: title LIMIT 1];

                        ContentVersion conVer2 = new ContentVersion();
                        conVer2.ContentLocation = 'S'; // S = Salesforce, E = External Files
                        conVer2.VersionData = EncodingUtil.base64Decode(fileContent);
                        conVer2.Title = title;
                        conVer2.PathOnClient = fileName;
                        insert conVer2;
                        
                        ContentVersion cv2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer2.Id];
                        ContentDocumentLink conDocLink2 = new ContentDocumentLink();
                        conDocLink2.LinkedEntityId = existDocList[0].Id;
                        conDocLink2.ContentDocumentId = cv2.ContentDocumentId;
                        conDocLink2.Visibility = 'AllUsers';
                        conDocLink2.shareType = 'V'; 
                        insert conDocLink2;   

                        return cv.ContentDocumentId+','+cv2.ContentDocumentId;
                    }
                    
                    return cv.ContentDocumentId;
                } else if(!String.isBlank(parentId)) {
                    String fType = '';
                    if(title.containsIgnoreCase('RERA Certificate')) {
                        fType = 'RERA Certificate';
                    } else if(title.containsIgnoreCase('Trade')) {
                        fType = 'Trade Licence';
                    } else if(title.containsIgnoreCase('POA/MOA')) {
                        fType = 'POA/MOA';
                    } else if(title.containsIgnoreCase('Passport')) {
                        fType = 'Passport';
                    } else if(title.containsIgnoreCase('Emirates')) {
                        fType = 'Emirates Id';
                    } else if(title.containsIgnoreCase('Visa')) {
                        fType = 'Visa';
                    } else if(title.containsIgnoreCase('VAT')) {
                        fType = 'VAT Certificate / VAT Exemption Letter';
                    } else if(title.containsIgnoreCase('Translated')) {
                        fType = 'Translated Company documents';
                    } else if(title.containsIgnoreCase('Other document')) {
                        fType = 'Other Document';
                    } else {
                        fType = 'Secondary Document';
                    }
                    
                    BR_Document_History__c newBR = new BR_Document_History__c();
                    newBR.File_Name__c = fileName;
                    newBR.File_Type__c = fType;
                    newBR.Broker_Account__c = parentId;
                    insert newBR;
                    List<ContentVersion> cvList = new List<ContentVersion>();
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
                    conVer.VersionData = EncodingUtil.base64Decode(fileContent);
                    conVer.Title = title;
                    conVer.PathOnClient = fileName;
                    insert conVer;
                    
                    ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id];
                    ContentDocumentLink conDocLink = new ContentDocumentLink();
                    conDocLink.LinkedEntityId = newBR.Id;
                    conDocLink.ContentDocumentId = cv.ContentDocumentId;
                    conDocLink.Visibility = 'AllUsers';
                    conDocLink.shareType = 'V'; 
                    insert conDocLink; 
                    
                    if(!accCopy.isEmpty()) {
                        BR_Document_History__c newBR2 = new BR_Document_History__c();
                        newBR2.File_Name__c = fileName;
                        newBR2.File_Type__c = fType;
                        newBR2.Broker_Account__c = accCopy[0].Id;
                        insert newBR2;
                        ContentVersion conVer2 = new ContentVersion();
                        conVer2.ContentLocation = 'S'; // S = Salesforce, E = External Files
                        conVer2.VersionData = EncodingUtil.base64Decode(fileContent);
                        conVer2.Title = title;
                        conVer2.PathOnClient = fileName;
                        insert conVer2;
                        
                        ContentVersion cv2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer2.Id];
                        ContentDocumentLink conDocLink2 = new ContentDocumentLink();
                        conDocLink2.LinkedEntityId = newBR2.Id;
                        conDocLink2.ContentDocumentId = cv2.ContentDocumentId;
                        conDocLink2.Visibility = 'AllUsers';
                        conDocLink2.shareType = 'V'; 
                        insert conDocLink2;

                        return cv.ContentDocumentId+','+cv2.ContentDocumentId;
                    }
                           
                    return cv.ContentDocumentId;
                }
            }
        } catch (Exception e) {
            
        }
        return 'Failed';
        /*try {
            List<ContentVersion> cvList = new List<ContentVersion>();
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
            conVer.VersionData = EncodingUtil.base64Decode(fileContent);
            conVer.Title = title;
            conVer.PathOnClient = fileName;
            insert conVer;
            
            ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id];
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.LinkedEntityId = parentId;
            conDocLink.ContentDocumentId = cv.ContentDocumentId;
            conDocLink.Visibility = 'AllUsers';
            conDocLink.shareType = 'V'; 
            insert conDocLink;        
            return cv.ContentDocumentId;
        } catch (Exception e) {
            return 'Failed';
        }*/
    }
    public class FileDataWP {
        public String fileName;
        public String fileContent;
        public String parentId;
    }
    public class BrokerRegistrationException extends Exception {}
}
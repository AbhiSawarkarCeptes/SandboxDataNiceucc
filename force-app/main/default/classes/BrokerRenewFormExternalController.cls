public without sharing class BrokerRenewFormExternalController {
    @AuraEnabled
    public static Map<String,Object> getRecord(Id recordId){
        try {
            if( recordId == null )
                throw new BrokerRenewRegistrationException('Invalid record id');

            Map<String,Object> response = new Map<String,Object>();
            response.put('today', Date.today());
            Broker_Renewal__c record = [ 
                SELECT Id, Account_Owner_Email__c, Name_as_per_trade_license__c, Mobile_No__c,Owner_s_Email__c, Email_ID_1__c, Phone__c, Name_as_per_passport__c, Nationality__c, Designation__c, Office_Apartment_number__c, 
                Villa_Building_name__c, Street_name__c, District_Area__c, City_Province__c, Country__c, ZIP_Postal_Code_PO_Box__c, Broker_Sub_Type__c, 
                Fax__c, RERA_Registration_No__c, Witness_Name__c, Witness_Email__c, Registration_Link_Expiry_Date_Time__c,RERA_Number__c,
                Registration_Number__c,Broker_Account__r.PropStrength__Broker_Code__c, Company_Registered_In_Account__c,
                Broker_Category__c, Broker_Approval_Status__c , Name, Broker_Created_Date__c 
                FROM Broker_Renewal__c
                WHERE Id = :recordId
            ][0];
            
            if( record.Broker_Approval_Status__c != 'Broker Empanelment Form Filled' ){
                throw new BrokerRenewRegistrationException('Your Registration is done. Check with the System admin for further process');
            }
            
            if( record.Registration_Link_Expiry_Date_Time__c <= DateTime.now()){
                throw new BrokerRenewRegistrationException('Your Registration link is expired. Check with the System admin for further process');
            }
            
            response.put('record', record);
            return response;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Broker_Renewal__c updateRecord(Broker_Renewal__c record){
        try {
             
            // if(record.Office_Apartment_number__c != null || record.Villa_Building_name__c != null && record.BillingStreet != null) {
            //     record.BillingStreet = record.Office_Apartment_number__c +', '+ record.Villa_Building_name__c +', '+record.BillingStreet;
            // }
            record.Broker_Approval_Status__c = 'Broker Registration Done';
            record.Broker_Created_Date__c = Datetime.now();
            record.Modified_by_guest_user__c = true;
            // record.Name_as_per_Trade_License__c = record.Name_as_per_Trade_License__c?.toUpperCase();
            update record;
            record = [ 
                SELECT Id, Account_Owner_Email__c, Name_as_per_trade_license__c, Mobile_No__c,Owner_s_Email__c, Email_ID_1__c, Phone__c, Name_as_per_passport__c, Nationality__c, Designation__c, Office_Apartment_number__c, 
                Villa_Building_name__c, Street_name__c, District_Area__c, City_Province__c, Country__c, ZIP_Postal_Code_PO_Box__c, Broker_Sub_Type__c, 
                Fax__c, RERA_Registration_No__c, Witness_Name__c, Witness_Email__c, Registration_Link_Expiry_Date_Time__c,RERA_Number__c,
                Registration_Number__c,Broker_Account__r.PropStrength__Broker_Code__c, Company_Registered_In_Account__c,
                Broker_Category__c, Broker_Approval_Status__c , Name, Broker_Created_Date__c 
                FROM Broker_Renewal__c
                WHERE Id =: record.Id limit 1];
            return record;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string deleteDocuments(List<Id> DocIds) {
        try {
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
    public static ID getDocID(String recordID, string title){
          system.debug('recordID----'+recordID);
          if(recordID != null){
                ContentDocumentLink cdl = [SELECT contentDocumentId from ContentDocumentLink where LinkedEntityId =:recordID  order by SystemModstamp desc limit 1];
                ContentDocument cd = [select id,title from ContentDocument where Id=:cdl.contentDocumentId]; // Getting files from Parent record 
                    cd.Title = title;  // Changing file Title with user entered title
                try{  
                    update cd;  // Update ContentDocument (File)
                }catch(DMLException e){  system.debug('Exception has occurred! ' +e.getMessage());  
                }  
                return cdl.contentDocumentId;
          }else 
            return null;
    }
    @AuraEnabled(cacheable=false)
    public static String createAttachment(String title, String fileName, String fileContent ,String parentId){
        System.debug('===> title ' + title);
        System.debug('===> fileName ' + fileName);
        System.debug('===> fileContent ' + fileContent);
        System.debug('===> parentId ' + parentId);
        List<BR_Document_History__c> existDocList = new List<BR_Document_History__c>();
        try {
            if(!String.isBlank(parentId) && !String.isBlank(title)) {
                existDocList = [SELECT Id, File_Type__c                                                             
                                    FROM BR_Document_History__c 
                                    WHERE Broker_Renewal__c =: parentId AND 
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
                    newBR.Broker_Renewal__c = parentId;
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
    public class BrokerRenewRegistrationException extends Exception {}
}
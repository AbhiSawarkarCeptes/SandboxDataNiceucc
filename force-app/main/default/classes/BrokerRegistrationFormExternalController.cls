//Test class:BrokerRegistrationFormExternalCtrlTest
public without sharing class BrokerRegistrationFormExternalController {
    
    @AuraEnabled
    public static Map<String,Object> getRecord(Id recordId){
        try {
            if( recordId == null )
                throw new BrokerRegistrationException('Invalid record id');

            Map<String,Object> response = new Map<String,Object>();
            response.put('today', Date.today());

            Broker_Registration__c record = [
                SELECT Id, Name_as_per_trade_license__c,Sub_Category__c, Alternate_Email__c,Account_Email__c,	 Name_as_per_passport__c, Nationality__c, Designation__c, Office_Apartment_number__c, 
                Villa_Building_name__c, Street_name__c, District_Area__c, City_Province__c, Country__c, ZIP_Postal_Code_PO_Box__c, 
                Telephone__c, Fax__c, Mobile__c, Email__c, Witness_Name__c, Witness_Email_1__c, RERA_Number__c,
                Broker_Category__c, Status__c , Name, Broker_Created_Date__c, Registration_Number__c, Registration_Link_Expiry_Date_Time__c, 
                Renewal_Status__c, recordtype.Name, First_Name__c, Last_Name__c,Mobile_Country_Code__c,Telephone_Country_Code__c
                FROM Broker_Registration__c
                WHERE Id = :recordId
            ][0];

         	if( record.Status__c != null ){
                throw new BrokerRegistrationException('Your Registration is done. Check with the System admin for further process');
            }
            
            if( record.Registration_Link_Expiry_Date_Time__c <= DateTime.now() && record.Status__c!='Executed Agreement sent to broker'){
                throw new BrokerRegistrationException('Your Registration link is expired. Check with the System admin for further process');
            }
            
            if(record.Status__c=='Executed Agreement sent to broker' && record.Renewal_Status__c!='Renewal Initiated'){
                throw new BrokerRegistrationException('Your Registration link is expired. Check with the System admin for further process');
            }
             

            response.put('record', record);
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
     @AuraEnabled
    public static Integer validateRegistrationNo(String registrationNo, String obj, String category,String brRecordTypeId){
         Id newRecordTypeId = Schema.SObjectType.Broker_Registration__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        System.debug('registrationNo : '+registrationNo);
        System.debug('obj : '+obj);
        System.debug('category : '+category);
        system.debug('');
        Integer countRe =0;
        String cancelledAgreement = 'Cancelled Agreement- Broker Category Change';
        Id currentUser = UserInfo.getUserId();
        if(obj=='Broker'){
            List<Channel_Partner__c> cpList = [Select Id,Emergency_Created_ID__c,OwnerId, black_listed_user__c 
                                               from Channel_Partner__c 
                                               where (Passport_No__c =: registrationNo OR RERA_Registration_No__c =: registrationNo)
                                               
                                               ];
           // countRe = cpList.size();
             system.debug('cpList:'+cpList);
            if(cpList.size()>0){
                for(Channel_Partner__c channelPartner: cpList) {
                    if(channelPartner.black_listed_user__c == TRUE) {
                        return -1;
                    }
                }
                if(cpList[0].Emergency_Created_ID__c==true ){
                   countRe = 0; 
                }
            }
        } else {
            List<Sobha_Connect__c> scList = [Select Id,Emergency_Created_ID__c,OwnerId, black_listed_user__c from Sobha_Connect__c
                                             where (Registration__c =: registrationNo OR RERA_Number__c=: registrationNo)
                                             ];
           // countRe = scList.size();
            if(scList.size()>0){
                 for(Sobha_Connect__c sobhaConnect: scList) {
                    if(sobhaConnect.black_listed_user__c == TRUE) {
                        return -1;
                    }
                }
                if(scList[0].Emergency_Created_ID__c==true){
                   countRe = 0; 
                }
            }
        }
        if(countRe==0 && brRecordTypeId==newRecordTypeId){
        	List<AggregateResult> bgList = [Select count(Id) from Broker_Registration__c 
                                            where Registration_Number__c =: registrationNo
                                            AND Status__c != :cancelledAgreement 
                                           AND Broker_Category__c =:category];
            system.debug('bglist:'+bgList);
        	countRe = Integer.valueOf(bgList[0].get('expr0'));
            System.debug('countRe : '+countRe);
        }
        return countRe;
    }

    
    
    @AuraEnabled
    public static Broker_Registration__c updateRecord(Broker_Registration__c record){
        try {
            system.debug('~~ToCreate: '+record);
            /*if(record.Status__c=='Executed Agreement sent to broker' && record.Renewal_Status__c=='Renewal Initiated'){
               Broker_Registration__c returnRecord = createRenewalRecord(record); 
               return returnRecord;
            }*/
            
            if(record.recordtype.Name!='Renewal'){
               List<String> excludedCategory = new List<String>{'Sobha Connect - Intnl - Individual', 'Sobha Connect - UAE - Individual'};
                if( BrokerRegistrationController.isDuplicate(record) && !excludedCategory.contains(record.Broker_Category__c)){
                 //   throw new BrokerRegistrationException('A broker is already registered with the provided information.');
                }
            } else {
                System.debug('Inside Renewal');
                System.debug('record.Id'+record.Id);
                Broker_Registration__c parentBroker = [Select Id, Renewal_Status__c from Broker_Registration__c where Renewal_Record_Id__c=:record.Id];
                parentBroker.Renewal_Status__c = 'Renewal In Progress';
                update parentBroker;
            }
            record.Status__c = 'CHRM Registration Done';
            record.Broker_Created_Date__c = Datetime.now().addHours(4);
            record.Name_as_per_Trade_License__c = record.Name_as_per_Trade_License__c?.toUpperCase();
            record.Comments__c = '';
            update record;
            system.debug('~~~~~Records Updated: '+record);
            sendEmailToCHRM(record.Id);
            Id ownerId = [Select Id,OwnerId From Broker_Registration__c where Id=:record.Id].OwnerId;
            if(record.recordtype.Name =='Renewal' && ownerId != null){
                system.debug('~~~~~record.recordtype.Name Inside If:: '+record.recordtype.Name);
                system.debug('~~~~~record.recordtype.Name Inside If:: '+record.Status__c);
                Broker_Registration_Renewal__e eventRecord = new Broker_Registration_Renewal__e();
                eventRecord.RecordId__c = record.Id; // Pass the Broker_Registration__c record ID
                eventRecord.OwnerId__c = ownerId;
                EventBus.publish(eventRecord);
            }
            return record;
        } catch (Exception e) {
            System.debug('Error Message'+e.getMessage());
            System.debug('Error trace'+e.getStackTraceString());
             throw new AuraHandledException(e.getMessage());
        } 
    }
    
     public static void sendEmailToCHRM(String recordId){
        Broker_Registration__c record = [
            SELECT Id, CHRM_Manager_Email__c, First_Name__c, Last_Name__c
            FROM Broker_Registration__c
            WHERE Id = :recordId
        ][0];

        EmailTemplate template = [
            SELECT Id
            FROM EmailTemplate 
            WHERE Name = 'Broker Registration: Notify CHRM Manager on Broker Submission'
            LIMIT 1
        ];
        
        Contact dummyContact = new Contact(LastName = record.CHRM_Manager_Email__c, Email = record.CHRM_Manager_Email__c);
        insert dummyContact;

        Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
        String[] toaddresses = new String[] {record.CHRM_Manager_Email__c}; 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName =: system.label.WelcomeEmailOrgWideId];
          
        mymail.setToAddresses(toaddresses);
        mymail.setTemplateId(template.Id);
        mymail.setWhatId(record.Id);
        mymail.setTargetObjectId(dummyContact.Id);
        if(owea.size() > 0){
            mymail.setOrgWideEmailAddressId( owea.get(0).Id);
            
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });

        delete dummyContact;
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
    public static string deleteDocuments(List<Id> DocIds){
        try {
            
            List<ContentDocument> cdToDelete = new  List<ContentDocument>();
            for(id docId : DocIds){
                cdToDelete.add(new ContentDocument(id = docId));

            }
            delete cdToDelete;
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DocumentWrapper{
        public string versionId;
        public string filelabel;
        public string fileName; 
    }

    @AuraEnabled
    public static void createBRDocumentHistory(string brId, string docList){
        list<DocumentWrapper> dList = (list<DocumentWrapper>) JSON.deserialize(docList, list<DocumentWrapper>.class);
        set<string> versionIds = new set<string>();
        map<string, string> versionIdToContentDocumentId = new map<string, string>();
        list<BR_Document_History__c> historyToInsert = new list<BR_Document_History__c>();
        for(DocumentWrapper wrap : dList){
            if(wrap.versionId!=null){
                versionIds.add(wrap.versionId);
            }
            BR_Document_History__c  hist = new BR_Document_History__c();
            hist.File_Type__c = wrap.filelabel;
            hist.File_Name__c = wrap.fileName;
            hist.Broker_Registration__c = brId;
            hist.Document_Link_Id__c = wrap.versionId;
            historyToInsert.add(hist);
        }
        if(historyToInsert.size()>0){
            insert historyToInsert;
        }
        for(ContentVersion cv : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN: versionIds]){
            versionIdToContentDocumentId.put(cv.Id,cv.ContentDocumentId);
        }
        list<ContentDocumentLink> linksToInsert = new list<ContentDocumentLink>();
        for(BR_Document_History__c brDoc : [select Id,Document_Link_Id__c from BR_Document_History__c where Id IN: historyToInsert]){
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = versionIdToContentDocumentId.get(brDoc.Document_Link_Id__c);
            link.LinkedEntityId = brDoc.Id;
            link.Visibility = 'AllUsers';
            linksToInsert.add(link);
        }
        if(linksToInsert.size()>0){
            insert linksToInsert;
        }
    }

    @AuraEnabled
    public static ID getDocID(String recordID,String filelabel,String fileName){
          system.debug('recordID----'+recordID);
          if(recordID != null){
            ContentDocumentLink cdl = [SELECT id,contentDocumentId from ContentDocumentLink where LinkedEntityId =:recordID  order by SystemModstamp desc limit 1];
              if(cdl != null){
                  List<BR_Document_History__c> brhist = [select id, name from BR_Document_History__c where File_Type__c =:filelabel and Broker_Registration__c=:recordID order by createddate desc limit 1];
                  if(brhist != null && brhist.size() > 0){
                      ContentDocumentLink cdl2 = new ContentDocumentLink();
                      cdl2.LinkedEntityId = brhist[0].Id;
                      cdl2.ContentDocumentId = cdl.contentDocumentId;
                      insert cdl2;
                      delete cdl;
                  }else{ 
                      BR_Document_History__c  hist = new BR_Document_History__c();
                      hist.File_Type__c = filelabel;
                      hist.File_Name__c = fileName;
                    //  hist.Document_Link_Id__c = cdl.contentDocumentId.toString();
                      hist.Broker_Registration__c = recordID;
                      insert hist;
                      System.debug(''+hist.Id);
                      
                      ContentDocumentLink cdl2 = new ContentDocumentLink();
                      cdl2.LinkedEntityId = hist.Id;
                      cdl2.ContentDocumentId = cdl.contentDocumentId;
                      insert cdl2;
                      
                      delete cdl;
                  }
	  
              }
              
            return cdl.contentDocumentId;
          }else return null;
       
    }
    public class BrokerRegistrationException extends Exception {}
}
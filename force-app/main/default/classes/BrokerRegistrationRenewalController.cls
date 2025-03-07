public class BrokerRegistrationRenewalController {
    
    //@InvocableMethod
    public static List<ID> createRenewalRecordFromCPorSC(List<sObject> brRecord){
        List<Id> reutrnId = new List<Id>();
        system.debug('~~~~~'+brRecord);
        return reutrnId;
    }
	
    @InvocableMethod
    public static List<ID> createRenewalRecord(List<Broker_Registration__c> brRecord){
        try{
            Broker_Registration__c queryRecord = [Select Name_as_per_trade_license__c, Name_as_per_passport__c,  Nationality__c, Email__c, Mobile__c, OwnerId,
                                                 Designation__c, Broker_Created_Date__c, Registration_Number__c, CPID__c, SCID__c, CHRM_Manager__c,
                                                 RERA_Number__c, Broker_Category__c, First_Name__c, Last_Name__c, CHRM_Manager_Email__c, Sales_Manager__c,
                                                 Reporting_manager__c, Office_Apartment_number__c, Street_name__c, Villa_Building_name__c, District_Area__c,
                                                 City_Province__c, Country__c, ZIP_Postal_Code_PO_Box__c, Telephone__c, Fax__c FROM Broker_Registration__c WHERE ID=: brRecord[0].Id];
            system.debug('~~~Qrd: '+queryRecord.CHRM_Manager__c);
            Broker_Registration__c renewedRecord = queryRecord.clone(false,true);
            Id renewalRecordTypeId = Schema.SObjectType.Broker_Registration__c.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            renewedRecord.RecordTypeId = renewalRecordTypeId;
            renewedRecord.Parent_Record__c = brRecord[0].Id;
            renewedRecord.Registration_Number__c = '';
            system.debug('~~~AftQrd: '+renewedRecord.CHRM_Manager__c);
            insert renewedRecord;
            
            Broker_Registration__c updateRenewalInParent = new Broker_Registration__c();
            updateRenewalInParent.Id = brRecord[0].Id;
            updateRenewalInParent.Renewal_Record_Id__c = renewedRecord.Id;
            updateRenewalInParent.Renewal_Status__c = 'Renewal Initiated';
            updateRenewalInParent.Show_Send_Renewal_Link_Button__c = true;
            update updateRenewalInParent;
            
            List<Id> reutrnId = new List<Id>();
            reutrnId.add(renewedRecord.Id);
            return reutrnId;
        }  catch (Exception e) {
            system.debug('~~~Error: '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<ID> createRenewalRecordFromPortal(List<Broker_Registration__c> brRecord){
        try{
            Broker_Registration__c queryRecord = [Select Name_as_per_trade_license__c, Name_as_per_passport__c,  Nationality__c, Email__c, Mobile__c, OwnerId,
                                                 Designation__c, Broker_Created_Date__c, Registration_Number__c, CPID__c,CPID__r.Email_ID_1__c, SCID__c, CHRM_Manager__c,
                                                 RERA_Number__c, Broker_Category__c, First_Name__c, Last_Name__c, CHRM_Manager_Email__c, Sales_Manager__c,
                                                 Reporting_manager__c, Office_Apartment_number__c, Street_name__c, Villa_Building_name__c, District_Area__c,
                                                 City_Province__c, Country__c, ZIP_Postal_Code_PO_Box__c, Telephone__c, Fax__c FROM Broker_Registration__c WHERE ID=: brRecord[0].Id];
            system.debug('~~~Qrd: '+queryRecord.CHRM_Manager__c);
            Broker_Registration__c renewedRecord = queryRecord.clone(false,true);
            Id renewalRecordTypeId = Schema.SObjectType.Broker_Registration__c.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            renewedRecord.RecordTypeId = renewalRecordTypeId;
            renewedRecord.Parent_Record__c = brRecord[0].Id;
            renewedRecord.Registration_Number__c = '';
            renewedRecord.from_Portal__c=true;
            renewedRecord.Broker_Email__c=queryRecord.CPID__r.Email_ID_1__c;
            system.debug('~~~AftQrd: '+renewedRecord.CHRM_Manager__c);
            insert renewedRecord;
            
            Broker_Registration__c updateRenewalInParent = new Broker_Registration__c();
            updateRenewalInParent.Id = brRecord[0].Id;
            updateRenewalInParent.Renewal_Record_Id__c = renewedRecord.Id;
            updateRenewalInParent.Renewal_Status__c = 'Renewal Initiated';
            updateRenewalInParent.Show_Send_Renewal_Link_Button__c = true;
            update updateRenewalInParent;
            
            List<Id> reutrnId = new List<Id>();
            reutrnId.add(renewedRecord.Id);
            return reutrnId;
        }  catch (Exception e) {
            system.debug('~~~Error: '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Broker_Registration__c> getBRlist(Id brId){
        List<Broker_Registration__c> brokerList = [Select Id, CPID__c, SCID__c, Broker_Category__c, CreatedDate from Broker_Registration__c where Id =: brId];
        List<Broker_Registration__c> brokerRelatedList = new List<Broker_Registration__c>();
        if(brokerList.size()>0){
            brokerRelatedList = getBrokerRelatedData(brokerList[0]);
        }
        return brokerRelatedList;
    }
    
    public static List<Broker_Registration__c> getBrokerRelatedData(Broker_Registration__c breg){
        List<Broker_Registration__c> brokerRelatedList = new List<Broker_Registration__c>();
        if(breg.Broker_Category__c.contains('Broker') && breg.CPID__c!=null){
            brokerRelatedList = [Select Id, Name, RecordType.Name, CreatedDate, Broker_Expiry_Date__c from Broker_Registration__c where CPID__c =: breg.CPID__c AND CreatedDate>:breg.CreatedDate order by CreatedDate desc];
        } else if( breg.SCID__c!=null ){
            brokerRelatedList = [Select Id, Name, RecordType.Name, CreatedDate, Broker_Expiry_Date__c from Broker_Registration__c where SCID__c =: breg.SCID__c AND CreatedDate>:breg.CreatedDate order by CreatedDate desc];
        }
        return brokerRelatedList;
    }
    
    /*public static void generateRenewalWithCPorSC(){
        Map<Id, Id>brCPMap = new Map<Id, Id>();
        List<Broker_Registration__c> brokerRegToInsert = new List<Broker_Registration__c>();
        List<Channel_Partner__c> cpList = [Select Id from Channel_Partner__c];
        List<Broker_Registration__c> brCPList = [Select Id, CPID__c from Broker_Registration__c where CPID__c IN: cpList];
        if(brCPList.size()>0){
            for(Broker_Registration__c br: brCPList){
                brCPMap.put(br.CPID__c, br.Id);
            }
        }
        if(cpList.size()>0){
            for(Channel_Partner__c cp: cpList){
                if(!brCPMap.containskey(cp.Id)){
                    //Create BR of Type New
                    Broker_Registration__c brData = mapBrokerRegFields(cp);
                    if(brData!=null){
                        brokerRegToInsert.add(brData);
                    }
                }
            }
        }
        if(brokerRegToInsert.size()>0){
        	insert(brokerRegToInsert);
        }
    } 
    
    public static Broker_Registration__c mapBrokerRegFields(Channel_Partner__c cpData){
        Broker_Registration__c breg = new Broker_Registration__c();
        
        return breg;
    }*/
    
    
}
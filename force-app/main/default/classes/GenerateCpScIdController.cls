public class GenerateCpScIdController {
    
    private static final Set<String> SC_CATEGORY = new Set<String> {
        'Sobha Connect - UAE - Individual',
        'Sobha Connect - Intnl - Individual',
        'Sobha Connect - UAE - Company',
        'Sobha Connect - Intnl - Company'
    };
            
	private static final Set<String> CP_CATEGORY = new Set<String> { 
        'Broker - RERA',
         'Broker - UAE',
         'Broker - Intnl'
	};
                            
	@AuraEnabled
	public static String generate(Id recordId) {
        try {
            String returnState = 'no';
            Broker_Registration__c record = [
                SELECT Id, Broker_Category__c, First_Name__c, Last_Name__c, Telephone__c,frmBrokerRegistrationName__c,
                Mobile__c, Email__c, Status__c, Registration_Number__c, CHRM_Manager__c, CHRM_ManagerHead__c,
                CPID__c, SCID__c, Agreement_Created_Sent_Date__c, Broker_Created_Date__c, Sales_Manager__c, ownerId,
                Reporting_manager__c, CreatedById, RERA_Number__c, Office_Apartment_number__c, recordtype.Name,
                Street_name__c,Villa_Building_name__c,District_Area__c,City_Province__c,Country__c,ZIP_Postal_Code_PO_Box__c,
                Parent_Record__c, Parent_Record__r.Agreement_Created_Sent_Date__c, Parent_Record__r.Broker_Created_Date__c
                FROM Broker_Registration__c
                WHERE Id = :recordId
            ];
                                    
            //if( record.CPID__c != null || record.SCID__c != null )
            //    throw new BrokerRegistrationException('CP/SC ID already generated!');
                                    
            if( SC_CATEGORY.contains(record.Broker_Category__c) ) {
                record = generateSCID(record);
                Id scId = getCPorSCIdWithReg(record.Registration_Number__c, 'SC');
                if(scId!=null){
                    returnState = 'yes';
                }
            } else if( CP_CATEGORY.contains(record.Broker_Category__c) ) {
                record = generateCPID(record);
                Id cpId = getCPorSCIdWithReg(record.Registration_Number__c, 'CP');
                if(cpId!=null){
                    returnState = 'yes';
                }
            }
            
            update record;
            return returnState;
        } catch (Exception e) {
            System.debug('Exception: '+e.getMessage()+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @TestVisible
    private static Broker_Registration__c generateSCID(Broker_Registration__c record) {
        Id scId = getCPorSCIdWithReg(record.Registration_Number__c, 'SC');
        Sobha_Connect__c sc = new Sobha_Connect__c();
        //sc.Name__c = (record.First_Name__c + ' ' + record.Last_Name__c).trim();
        String nameField = record.frmBrokerRegistrationName__c;
        Integer maxSize = 80;
        if(nameField.length() > maxSize ){
            nameField = nameField.substring(0,maxSize);
        }
        sc.Name__c = nameField;
        sc.Contact_Person__c = sc.Name__c;
        sc.Telephone_Number__c = record.Telephone__c;
        sc.Mobile_No__c = record.Mobile__c;
        sc.Email_Id__c = record.Email__c;
        sc.Registration__c = record.Registration_Number__c;
        //sc.Channel_Relationship_Manager__c = record.CHRM_Manager__c;
        //sc.Channel_Relationship_Head__c = record.CHRM_ManagerHead__c;
        sc.Channel_Relationship_Manager__c = record.ownerId;
        sc.ownerId = record.ownerId;
        sc.Channel_Relationship_Head__c = record.CHRM_Manager__c;
        sc.Agent_Category__c = record.Broker_Category__c;
        sc.Creation_Date__c = record.Agreement_Created_Sent_Date__c;
        sc.Registration_Date__c = Date.valueOf(record.Broker_Created_Date__c);
        if(record.recordtype.Name!='New'){
            //sc.Creation_Date__c = record.Parent_Record__r.Agreement_Created_Sent_Date__c;
            sc.Registration_Date__c = Date.valueOf(record.Parent_Record__r.Broker_Created_Date__c);
        }
        /*if(record.recordtype.Name=='Renewal'){
        sc.Registration_Date__c = Date.valueOf(record.Agreement_Created_Sent_Date__c);
        }*/
        sc.Expiry_Date__c = Date.valueOf(record.Agreement_Created_Sent_Date__c).addMonths(12);
        sc.Renewal_New_Expiry__c = Date.valueOf(sc.Expiry_Date__c).addMonths(12);
        sc.Sales_Manager__c = record.Sales_Manager__c;
        sc.Sales_Head__c = record.Reporting_manager__c;
        sc.RERA_Number__c = record.RERA_Number__c;
        List<String> addressList = generateAddress(record);
        if(addressList.size()>0){
            sc.Address__c = String.join(addressList, ',');
        }
        
        sc.Id = scId;
        upsert sc;
        
        //added by Artee to create account record for sobha connect
        createAccountForSobhaConnect(record, sc.Id);
        //added by Artee to create account record for sobha connect
        
        record.SCID__c = sc.Id;
        record.Status__c = 'CP/SC ID Generated';
        return record;
    }
    
    private static List<String> generateAddress(Broker_Registration__c record){
        List<String> addressList = new List<String>();
        if(record.Office_Apartment_number__c!='' && record.Office_Apartment_number__c!=null){
            addressList.add(record.Office_Apartment_number__c);
        }
        if(record.Street_name__c!='' && record.Street_name__c!=null){
            addressList.add(record.Street_name__c);
        }
        if(record.Villa_Building_name__c!='' && record.Villa_Building_name__c!=null){
            addressList.add(record.Villa_Building_name__c);
        }
        if(record.District_Area__c!='' && record.District_Area__c!=null){
            addressList.add(record.District_Area__c);
        }
        if(record.City_Province__c!='' && record.City_Province__c!=null){
            addressList.add(record.City_Province__c);
        }
        if(record.Country__c!='' && record.Country__c!=null){
            addressList.add(record.Country__c);
        }
        if(record.ZIP_Postal_Code_PO_Box__c!='' && record.ZIP_Postal_Code_PO_Box__c!=null){
            addressList.add(record.ZIP_Postal_Code_PO_Box__c);
        }
        return addressList;
    }
    
    @TestVisible
    private static Broker_Registration__c generateCPID(Broker_Registration__c record) {
        Id cpId = getCPorSCIdWithReg(record.Registration_Number__c, 'CP');
        Channel_Partner__c cp = new Channel_Partner__c();
        //cp.Name = (record.First_Name__c + ' ' + record.Last_Name__c).trim();
        String nameField = record.frmBrokerRegistrationName__c;
        Integer maxSize = 80;
        if(nameField.length() > maxSize ){
            nameField = nameField.substring(0,maxSize);
        }
        cp.Name = nameField;
        cp.Contact_Person__c = cp.Name;
        cp.Phone__c = record.Telephone__c;
        cp.Mobile_No__c = record.Mobile__c;
        cp.Email_ID_1__c = record.Email__c;
        cp.Passport_No__c = record.Registration_Number__c;
        //cp.Channel_Relationship_Manager__c = record.CHRM_Manager__c;
        //cp.Channel_Relationship_Head__c = record.CHRM_ManagerHead__c;
        cp.Channel_Relationship_Manager__c = record.ownerId;
        cp.ownerId = record.ownerId;
        cp.Channel_Relationship_Head__c = record.CHRM_Manager__c;
        cp.Category__c = record.Broker_Category__c;
        cp.Creation_Date__c = record.Agreement_Created_Sent_Date__c;
        cp.Sub_Category__c = record.Sub_Category__c;
        cp.Registration_Date__c = Date.valueOf(record.Broker_Created_Date__c);
        if(record.recordtype.Name!='New'){
            //cp.Creation_Date__c  = record.Parent_Record__r.Agreement_Created_Sent_Date__c;
            cp.Registration_Date__c = Date.valueOf(record.Parent_Record__r.Broker_Created_Date__c);
        }
        /*if(record.recordtype.Name=='Renewal'){
        cp.Registration_Date__c = Date.valueOf(record.Agreement_Created_Sent_Date__c);
        }*/
        cp.Expiry_Date__c = Date.valueOf(record.Agreement_Created_Sent_Date__c).addMonths(12);
        cp.Renewal_New_Expiry__c = Date.valueOf(cp.Expiry_Date__c).addMonths(12);
        cp.Sales_Manager__c = record.Sales_Manager__c;
        cp.Sales_Manager_s_Line_Manager__c = record.Reporting_manager__c;
        cp.RERA_Registration_No__c = record.RERA_Number__c;
        List<String> addressList = generateAddress(record);
        if(addressList.size()>0){
            cp.Address__c = String.join(addressList, ',');
        }
        cp.Id = cpId;
        upsert cp;
        
        //added by Artee to create Account record for Channel Partner
        createAccountForChannelPartner(record, cp.Id);
        //added by Artee to create Account record for Channel Partner
        
        record.CPID__c = cp.Id;
        record.Status__c = 'CP/SC ID Generated';
        return record;
    }
    
    private static Id getCPorSCIdWithReg(String regNumber, String catgType){
        Id returnId = null;
        if(catgType=='SC'){
            List<Sobha_Connect__c> sbt = [Select Id from Sobha_Connect__c where Registration__c =: regNumber Limit 1];
            if(sbt.size()>0){
                returnId = sbt[0].id;
            }
        } else {
            List<Channel_Partner__c> cpt = [Select Id from Channel_Partner__c where Passport_No__c =: regNumber Limit 1];
            if(cpt.size()>0){
                returnId = cpt[0].id;
            }
        }
        return returnId;
    }
    
    class BrokerRegistrationException extends Exception {}
    
    //added by Artee
    //on 4th march
    private static Account createAccountForSobhaConnect(Broker_Registration__c br, String scid) {
        
        if (br == null) {
            throw new IllegalArgumentException('Broker Registration record cannot be null');
        }
        
        // Query for an existing Account with the same registration number
        Account existingAccount = [SELECT Id FROM Account WHERE Registration_Number__c = :br.Registration_Number__c LIMIT 1];
        
        if (existingAccount != null) {
            // Update Broker Registration with AccountId
            br.Account__c = existingAccount.Id;
            update br;
            return existingAccount;
        } 
        else {
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName();
            Id recordTypeId = recordTypes.get('Sobha Connect').getRecordTypeId();
            System.debug('Record Type Id: ' + recordTypeId);
            
            // Create an Account record and map fields from Sobha_Connect__c
            Account acc = new Account();
            
            // Mapping fields with the same API name
            acc.LastName = br.frmBrokerRegistrationName__c;
            acc.Contact_Person__c = acc.LastName;
            acc.Telephone_Number__c = br.Telephone__c;
            acc.Mobile_No__c = br.Mobile__c;
            acc.Email_Id__c = br.Email__c;
            acc.RegistrationPassport_Number__c = br.Registration_Number__c;
            acc.Channel_Relationship_Head__c = br.CHRM_Manager__c;
            acc.Agent_Category__c = br.Broker_Category__c;
            acc.Creation_Date__c = br.Agreement_Created_Sent_Date__c;
            acc.Registration_Date__c = Date.valueOf(br.Broker_Created_Date__c);
            if(br.recordtype.Name!='New'){
                acc.Registration_Date__c = Date.valueOf(br.Parent_Record__r.Broker_Created_Date__c);
            }
            acc.Expiry_Date__c = Date.valueOf(br.Agreement_Created_Sent_Date__c).addMonths(12);
            acc.Renewal_New_Expiry__c = Date.valueOf(acc.Expiry_Date__c).addMonths(12);
            acc.Sales_Manager_sc__c = br.Sales_Manager__c;
            acc.Sales_Head_sc__c = br.Reporting_manager__c;
            acc.RERA_Number__c = br.RERA_Number__c;
            List<String> addressList = generateAddress(br);
            if(addressList.size()>0){
                acc.Address__c = String.join(addressList, ',');
            }
            acc.OwnerId = br.OwnerId;
            acc.RecordTypeId = recordTypeId;
            acc.Sobha_Connect__c = scid;
            // Insert the Account record
            Insert acc;
            System.debug('sc aacount Id=> ' + acc.Id);
            
            // Update Broker Registration with AccountId
            br.Account__c = acc.Id;
            update br;
            
            return acc;
        }
    }
    
    //added by Artee
    //on 4th march
    private static Account createAccountForChannelPartner(Broker_Registration__c br, String cpid) {
        
        if (br == null) {
            throw new IllegalArgumentException('Broker Registration record cannot be null');
        }
        
        // Query for an existing Account with the same registration number
        Account existingAccount = [SELECT Id FROM Account WHERE Registration_Number__c = :br.Registration_Number__c LIMIT 1];
        
        if (existingAccount != null) {
            // Update Broker Registration with AccountId
            br.Account__c = existingAccount.Id;
            update br;
            return existingAccount;
        } 
        else {
            
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName();
            Id recordTypeId = recordTypes.get('Channel Partner').getRecordTypeId();
            System.debug('Record Type Id: ' + recordTypeId);
            
            // Create an Account record and map fields from Sobha_Connect__c
            Account acc = new Account();
            
            // Mapping fields with the same API name
            acc.LastName = br.frmBrokerRegistrationName__c;
            acc.Contact_Person__c = acc.LastName;
            acc.Phone__c = br.Telephone__c;
            acc.Mobile_No__c = br.Mobile__c;
            acc.Email_ID_1__c = br.Email__c;
            acc.RegistrationPassport_Number__c = br.Registration_Number__c;
            acc.Channel_Relationship_Manager__c = br.ownerId;
            acc.Channel_Relationship_Head__c = br.CHRM_Manager__c;
            acc.Category_cp__c = br.Broker_Category__c;
            acc.Creation_Date__c = br.Agreement_Created_Sent_Date__c;
            acc.Registration_Date__c = Date.valueOf(br.Broker_Created_Date__c);
            if(br.recordtype.Name!='New'){
                acc.Registration_Date__c = Date.valueOf(br.Parent_Record__r.Broker_Created_Date__c);
            }
            acc.Expiry_Date__c = Date.valueOf(br.Agreement_Created_Sent_Date__c).addMonths(12);
            acc.Renewal_New_Expiry__c = Date.valueOf(acc.Expiry_Date__c).addMonths(12);
            acc.Sales_Manager_s_Line_Manager__c = br.Reporting_manager__c;
            acc.RERA_Registration_No__c = br.RERA_Number__c;
            List<String> addressList = generateAddress(br);
            if(addressList.size()>0){
                acc.Address__c = String.join(addressList, ',');
            }
            acc.Sub_Category__c = br.Sub_Category__c;
            acc.OwnerId = br.OwnerId;
            acc.RecordTypeId = recordTypeId;
            acc.Channel_Partner__c = cpid;
            // Insert the Account record
            Insert acc;
            System.debug('cp aacount Id=> ' + acc.Id);
            
            // Update Broker Registration with AccountId
            br.Account__c = acc.Id;
            update br;
            
            return acc;
        }
    }
}
public class AccountMergeController {
    public static Boolean accountMergeProcessInProgress = false;
    
    @AuraEnabled(cacheable=true)
    public static String getDuplicates(Id accountId) {
        AccountFieldWrapper objAccFieldWraper = new AccountFieldWrapper();
        List<AccountWrapper> lstAccWrapper = new List<AccountWrapper>();
        System.debug('accountId>>'+accountId);
        Account acc = [
            SELECT Name, Id, Unique_Customer_ID__c, Unique_Customer_External_ID__c FROM Account
            WHERE Id = :accountId
        ];
        
        //S:Get Data from Custom Metadata and form query String.
        List<String> setFields = new List<String>();
        
        List<MergeAccountField__mdt> lstAccountFields = new List<MergeAccountField__mdt>();
        //mcs = MergeAccountField__mdt.getAll().values();
        lstAccountFields = [SELECT field_api_name__c,Masterlabel,Sequence__c  
                            FROM MergeAccountField__mdt 
                            WHERE object_api__c = 'Account' 
                            ORDER BY Sequence__c asc];
        
        map<string,string> fieldMap = new map<string,string>();
        if(!lstAccountFields.isEmpty()){
            for(MergeAccountField__mdt objAccField : lstAccountFields){
                if(!setFields.contains(objAccField.field_api_name__c)) {
                    setFields.add(objAccField.field_api_name__c);
                }
                fieldMap.put(objAccField.field_api_name__c, objAccField.Masterlabel);
            }
        }
        System.debug('setFields information->'+setFields);
        //String strFields = String.join(setFields, ', ');
        String dcExternalId = acc.Unique_Customer_External_ID__c;
        //Map<String, Object> bindParams = new Map<String, Object>{'CustExternalId' => dcExternalId};
        System.debug(setFields);
        String strQuery = 'SELECT Id,'+ String.join(setFields, ', ') + ',Unique_Customer_External_ID__c,Unique_Customer_ID__c FROM Account';
        strQuery += ' WHERE Unique_Customer_External_ID__c =: dcExternalId AND Unique_Customer_External_ID__c !=null ';
        strQuery += ' ORDER BY CreatedDate ASC';
        //strQuery += ' LIMIT 100'; //remove limit once null check logic is implemented
        
        
        List<Account> lstAccounts = new List<Account>();
        //lstAccounts = Database.Query(strQuery);
        lstAccounts = Database.query(strQuery);
        
        
        System.debug('list before=>'+lstAccounts);
        List<Map<String,Object>> lstDupAccMap = new List<Map<String,Object>>();
        for(Account ac :lstAccounts)
        {
            Map<String,Object> mapAccountFieldValue = new Map<String,Object>();
            for(String fieldName : setFields){
                mapAccountFieldValue.put(fieldMap.get(fieldName),String.valueOf(ac.get(fieldName)) );
            }
            Boolean isMaster = ac.Unique_Customer_ID__c == ac.Unique_Customer_External_ID__c ? true : false;
            mapAccountFieldValue.put('IsMaster',String.valueOf(isMaster) );
            mapAccountFieldValue.put('Id',ac.Id );
            lstDupAccMap.add(mapAccountFieldValue);
        }
        System.debug('before '+lstDupAccMap);
        // objAccFieldWraper.lstAcc = lstAccWrapper;
        // objAccFieldWraper.mapFieldCompare = fieldMap;
        //System.debug(JSON.serialize(lstDupAccMap));
        //
        JSONGenerator g = JSON.createGenerator(false);
        
        g.writeStartArray();
        for(Map<String,object> mapFieldValue : lstDupAccMap) {
            g.writeStartObject();
            for(String key : mapFieldValue.keySet()){
                if(mapFieldValue.get(key) != null)
                    g.writeStringField(key, String.valueOf(mapFieldValue.get(key)) );
                else 
                    g.writeStringField(key, '' );
            }
            g.writeEndObject();
        }
        g.writeEndArray();
        
        System.debug(g.getAsString());
        return g.getAsString();
    }
    
    @AuraEnabled
    public static Boolean mergeRecord(String masterSelectedRecord, String accountdsNeedToMerge){
        Boolean isMergeSuccessful = false;
        
        System.debug('My masterdata record->'+ masterSelectedRecord);
        System.debug('My accountdsNeedToMerge record->'+ accountdsNeedToMerge);
        
        Map<String,String> mapMasterRecordSelection = (Map<String,String>) JSON.deserialize(masterSelectedRecord, Map<String,String>.Class);
        List<Map<String,String>> lstMapAccountNeedToMerge = (List<Map<String,String>>) JSON.deserialize(accountdsNeedToMerge,List<Map<String,String>>.Class);
        
        System.debug('Null Bug  after des master recr ->'+ mapMasterRecordSelection);
        System.debug('Null Bug  after des ->'+ lstMapAccountNeedToMerge);
        
        List<MergeAccountField__mdt> lstAccountFields = new List<MergeAccountField__mdt>();
        //mcs = MergeAccountField__mdt.getAll().values();
        lstAccountFields = [SELECT field_api_name__c,Masterlabel 
                            FROM MergeAccountField__mdt 
                            WHERE object_api__c = 'Account' 
                            ORDER BY Sequence__c];
        
        map<string,string> fieldMap = new map<string,string>();
        fieldMap.put('IsMaster','MasterRecord__c');
        fieldMap.put('Id','Id');
        if(!lstAccountFields.isEmpty()){
            for(MergeAccountField__mdt objAccField : lstAccountFields){
                fieldMap.put(objAccField.Masterlabel,objAccField.field_api_name__c);
            }
        }
        
        List<Account> selectedRecord = new List<Account>();
        Account masterRecordData = new Account();
        for(String field : mapMasterRecordSelection.keySet()){
            String fieldValue = mapMasterRecordSelection.get(field);
            if(field != 'Name' && isFieldWriteable('Account',fieldMap.get(field))) {
                masterRecordData.put(fieldMap.get(field),fieldValue);
            }
        }
        
        for(Map<String,String> mapAccount : lstMapAccountNeedToMerge){
            Account objAccount = new Account();
            for(String field : mapAccount.keySet()){
                if(field != 'IsMaster' && isFieldWriteable('Account',fieldMap.get(field))){
                    String fieldValue = mapAccount.get(field);
                    objAccount.put(fieldMap.get(field),fieldValue);
                }
            }
            System.debug('here adding account object->'+objAccount);
            selectedRecord.add(objAccount);
        }        
        
        Set<Id> accId = new Set<Id>();
        for(Account account : selectedRecord) {
            accId.add(account.Id);
        }
        
        List<Account> lstAccount = [
            SELECT Name, Id, Unique_Customer_ID__c, Unique_Customer_External_ID__c FROM Account
            WHERE Id = :accId
        ];
        
        
        List<Account> accountsNeedToMerge = new List<Account>();
        for(Account objAccount : lstAccount) {
            if(objAccount.Unique_Customer_ID__c == objAccount.Unique_Customer_External_ID__c) {
                masterRecordData.Id = objAccount.Id;
            } else {
                accountsNeedToMerge.add(objAccount);
            }
        }
        
        System.debug('selectedRecord Record ->'+ selectedRecord);
        
        // Merge accounts into master
        AccountMergeController.accountMergeProcessInProgress = true;
        Database.MergeResult[] results = Database.merge(masterRecordData, accountsNeedToMerge, false);
        AccountMergeController.accountMergeProcessInProgress = false;
        
        for(Database.MergeResult res : results) {
            if (res.isSuccess()) {
                isMergeSuccessful = true;
                Set<Id> masterAccountId= new Set<Id> {res.getId()};
                    AccountMergeController.accountMergeProcessInProgress = true;
                   AccountUpdateChildUniqueId.updateUniqueId(masterAccountId ,true);
                AccountMergeController.accountMergeProcessInProgress = false;
                
            }else {
                for(Database.Error err : res.getErrors()) {
                    // Write each error to the debug output
                    System.debug(err.getMessage());
                    isMergeSuccessful = false;
                    throw new AuraHandledException(err.getMessage());
                    
                }
            }
        }
        
        return isMergeSuccessful;
    }
    
    public class myJson{
        public List<String> items;
    }
    
    public static Boolean isFieldWriteable(String objectName, String fieldName) {
        
        if(fieldName == 'Id') return true;
        
        Schema.SObjectField fields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName);        
        return fields?.getDescribe()?.isUpdateable();
        
    }
    public class AccountWrapper {
        @AuraEnabled public Account acc;
        @AuraEnabled public boolean isMaster; 
    }
    
    public class AccountFieldWrapper {
        List<AccountWrapper> lstAcc;
        Map<String,String> mapFieldCompare;
    }
}
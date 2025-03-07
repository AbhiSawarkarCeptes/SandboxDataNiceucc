public class LookupSearchComponentController {
 @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        
        string myQuery = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\'';
        
        if(ObjectName == 'Unit__c'){
            myQuery = myQuery + ' and (Unit_Status__c = \'Available\' or  Unit_Status__c = \'Requested for Hold\')';
        }
        for(sObject so : Database.Query(myQuery)) {
            String fieldvalue = (String)so.get(fieldName);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
        
        return sObjectResultList;
    }
    
    @AuraEnabled
    public static List<SObJectResult> getRecord(String RecId, String fields, String ObjectName) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        
        string myQuery = 'Select Id,'+fields+' FROM '+ObjectName+' WHERE Id = \'' +RecId+ '\'' ;
        
        for(sObject so : Database.Query(myQuery)) {
            String fieldvalue = (String)so.get(fields);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
        
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
    
    
}
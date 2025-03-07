public without sharing class BrokerRegAgeingReportController {
	
    /*@AuraEnabled(cacheable=true)
    public static List<Broker_Registration__c> getReportData(String searchString){
        String query = 'SELECT Id, Name, (SELECT Id,CreatedDate,OldValue,NewValue FROM Histories WHERE Field=\'Status__c\' ORDER BY CreatedDate asc) FROM Broker_Registration__c';
        if(searchString!=null){
      		query += ' WHERE Name LIKE %'+searchString+'%';      
        }
        query +=' ORDER BY Name DESC';
        system.debug('~~~'+query);
        List<Broker_Registration__c> brg = Database.query(query);
        
        //List<Broker_Registration__c> brg =[SELECT Id, Name, (SELECT Id,CreatedDate,OldValue,NewValue FROM Histories WHERE Field='Status__c' ORDER BY CreatedDate asc) FROM Broker_Registration__c order by name desc];
        system.debug('~~~'+brg);
        return brg;
    } */
    
    @AuraEnabled(cacheable=true)
    public static List<Broker_Registration__c> getBRData(List<String> includedStatusAPI){
        List<Broker_Registration__c> brgData = [Select Id, Name, Broker_Created_Date__c, createdDate, Status__c, (SELECT Id,CreatedDate,OldValue,NewValue FROM Histories WHERE Field='Status__c' ORDER BY CreatedDate DESC Limit 1) from Broker_Registration__c where Status__c IN:includedStatusAPI];
        return brgData;
    }
    
}
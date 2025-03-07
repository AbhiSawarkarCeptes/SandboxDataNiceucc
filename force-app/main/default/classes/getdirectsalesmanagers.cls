public with sharing class getdirectsalesmanagers {
    public getdirectsalesmanagers() {}

    @AuraEnabled(cacheable=true)
    public static List<Direct_Sales_Managers__c> getsalesmanagers()
    {
        return [Select Id, Name, Sales_Manager__c, Sales_Manager__r.Name, Availability_Status__c from Direct_Sales_Managers__c where Availability_Status__c=true];
    }
}
@RestResource(urlMapping='/sobhagetbrokers/')
global with sharing class SobhaGetBrokersAPI {
    @HttpGet
    global static List<Channel_Partner__c> getBrokers(){
        RestRequest request = RestContext.request;
        List<Channel_Partner__c> brokers = [SELECT Id,Name,Channel_Partner_Id__c,Email_ID_1__c,Email_ID_2__c,Mobile_No__c,
                                            Office_No__c,RERA_Registration_No__c,Address__c,Is_Active__c,Channel_Relationship_Manager_Name__c,Category__c
                                            FROM Channel_Partner__c 
                                            WHERE 
                                            Is_Active__c = TRUE];
        for(Channel_Partner__c c : brokers){
            c.Name = (c.Name == null)?'':c.Name;
            c.Email_ID_1__c = (c.Email_ID_1__c == null)?'':c.Email_ID_1__c;
            c.Email_ID_2__c = (c.Email_ID_2__c == null)?'':c.Email_ID_2__c;
            c.Mobile_No__c = (c.Mobile_No__c == null)?'':c.Mobile_No__c;
            c.Office_No__c = (c.Office_No__c == null)?'':c.Office_No__c;
            c.RERA_Registration_No__c = (c.RERA_Registration_No__c == null)?'':c.RERA_Registration_No__c;
            c.Address__c = (c.Address__c == null)?'':c.Address__c;
            c.Category__c = (c.Category__c == null)?'':c.Category__c;
        }
        return brokers;
    }
}
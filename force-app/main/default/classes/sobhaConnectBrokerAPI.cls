@RestResource(urlMapping='/sobhaconnectbrokers/')
global with sharing class sobhaConnectBrokerAPI {
	@HttpGet
    global static List<Sobha_Connect__c> getSobhaConnect(){
        RestRequest request = RestContext.request;
        List<Sobha_Connect__c> brokers = [SELECT Id,Name__c,SC_Id__c,Email_Id__c,Mobile_No__c,Contact_Person__c,
                                            RERA_Number__c,Address__c,Channel_Relationship_Manager__c
                                            FROM Sobha_Connect__c 
                                            ];
     for(Sobha_Connect__c c : brokers){
         //   c.Name = (c.Name == null)?'':c.Name;
            
            c.Name__c = (c.Name__c == null)?'':c.Name__c;
            c.Email_Id__c = (c.Email_Id__c == null)?'':c.Email_Id__c;
           // c.SC_Id__c = (c.SC_Id__c == null)?'':c.SC_Id__c;
            c.Mobile_No__c = (c.Mobile_No__c == null)?'':c.Mobile_No__c;
          //  c.Office_No__c = (c.Office_No__c == null)?'':c.Office_No__c;
            c.RERA_Number__c = (c.RERA_Number__c == null)?'':c.RERA_Number__c;
            c.Address__c = (c.Address__c == null)?'':c.Address__c;
          //  c.Category__c = (c.Category__c == null)?'':c.Category__c;
        } 
        return brokers;
    }
}
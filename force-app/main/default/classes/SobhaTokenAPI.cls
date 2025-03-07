/**
*  --------------------------------------------------------------------------------------------------------------------------------------
* @Who   : CEPTES Software Pvt.Ltd.
* @What  : Fetch records for Token System
* @Why   : To expose Sobha Connect and Channel Partner records data to third party.
* @When  : 06-Jan-2021
*  -------------------------------------------------------------------------------------------------------------------------------------
**/
@RestResource(urlMapping='/sobhatokensystem/')
global with sharing class SobhaTokenAPI {
    /**
* @Method       : doGet
* @Invoke       : When any third party hit the API
* @Description  : This API is used to expose the Sobha connect and Channel Partner Data
* @Return       : Records for Sobha Connect and Channel Partner for token system
* @Params       : Search String
**/
    @HttpGet
    global static SobhaTokenAPIWrapper doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String nameString;
        if (Test.isRunningTest()) {
            nameString = 'test';
        } else {
            nameString = req.params.get('search_string');
        }
        List<List<SObject>> searchList = new List<List<SObject>>();
        List<Sobha_Connect__c> sobhaConnect = new List<Sobha_Connect__c>();
        List<Channel_Partner__c> channelPartner = new List<Channel_Partner__c>();
        
        //Fetch unit data from unit object
        try{

            //String searchquery='FIND\''+nameString+'*\'IN NAME FIELDS RETURNING Sobha_Connect__c(id,name,Channel_Relationship_Head__c,Channel_Relationship_Manager__c,Contact_Person__c,Creation_Date__c,Email_Id__c,Expiry_Date__c,Geography_Head__c,Geography_Manager__c,Mobile_No__c,Name__c,Renewal_New_Expiry__c,Registration_Date__c),Channel_Partner__c(Id,Name,Approval_Status__c,Category__c,Channel_Partner_Id__c,Channel_Relationship_Head__c,Channel_Relationship_Manager__c,Contact_Person__c,New_Channel_Partner__c,No_of_Broker_Trainings__c,No_of_Open_Houses__c,Qualified_Sales_Value__c,Registration_Date__c,Renewal_New_Expiry__c,RERA_Registration_No__c,Sales_Manager__c)'; 
            //searchList = search.query(searchquery);
            String searchStringVal= '%'+nameString+'%';
            sobhaConnect = [Select id,
                                    name,
                                    Channel_Relationship_Head__c,
                                    Channel_Relationship_Head__r.Name,
                                    Channel_Relationship_Manager__c,
                                    Channel_Relationship_Manager__r.Name,
                                    Contact_Person__c,
                                    Creation_Date__c,
                                    Email_Id__c,
                                    Expiry_Date__c,
                                    Geography_Head__c,
                                    Geography_Manager__c,
                                    Geography_Manager__r.Name,
                                    Mobile_No__c,
                                    Name__c,
                                    Renewal_New_Expiry__c,
                                    Registration_Date__c
                                From Sobha_Connect__c
                                Where Name__c like :searchStringVal];
            
            channelPartner = [Select Id,
                                    Name,
                                    Approval_Status__c,
                                    Category__c,
                                    Channel_Partner_Id__c,
                                    Channel_Relationship_Head__c,
                                    Channel_Relationship_Head__r.Name,
                                    Channel_Relationship_Manager__c,
                                    Channel_Relationship_Manager__r.Name,
                                    Contact_Person__c,
                                    No_of_Broker_Trainings__c,
                                    No_of_Open_Houses__c,
                                    Qualified_Sales_Value__c,
                                    Registration_Date__c,
                                    Renewal_New_Expiry__c,
                                    RERA_Registration_No__c,
                                    Sales_Manager__c,
                                    Sales_Manager__r.Name
                                From Channel_Partner__c
                                Where name LIKE :searchStringVal];
            
            //If any issue in fetching the unit records   
        }catch(Exception e) {
            System.debug('Your exception message here....'+e.getMessage());
            SobhaTokenAPIWrapper exposeData = new SobhaTokenAPIWrapper();
            exposeData.success = false;
            exposeData.statusCode = 500;
            exposeData.message = 'INTERNAL_SERVER_ERROR!!';           
            return exposeData;
        }
        
        //If unitdata is not empty 
        if((sobhaConnect.size() > 0) || ( channelPartner!=null && !channelPartner.isEmpty())) {
            SobhaTokenAPIWrapper exposeData = new SobhaTokenAPIWrapper();
            exposeData.success = true;
            exposeData.statusCode = 200;
            //if (sobhaConnect!=null && !searchList.isEmpty()) {
                exposeData.sobhaConnectData = sobhaConnect;
            //if (channelPartner!=null && !channelPartner.isEmpty()) {
                exposeData.channelPartnerData = channelPartner;

            
            //exposeData.channelPartnerData = channelPartner;
            //If unitdata is empty
            return exposeData;
        }else{
                SobhaTokenAPIWrapper exposeData = new SobhaTokenAPIWrapper();
                exposeData.success = true;
                exposeData.statusCode = 200;
                exposeData.message = 'No matching records found!!';            
                return exposeData;
        	 }        
    }
    
    global with sharing class SobhaTokenAPIWrapper{
        Public Boolean success;
        public Integer statusCode;
        public String message='';
        //public List<List<SObject>> responseData;
        public List<Channel_Partner__c> channelPartnerData;
        public List<Sobha_Connect__c> sobhaConnectData;
        
    }
}
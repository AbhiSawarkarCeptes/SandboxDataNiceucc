@isTest
public with sharing class CreateEnquiey_2024_V1_Test {
    @testSetup
    public static void setUp() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        insert acc;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
    }
    @isTest
    static void contactNotExist() {
        String json = '['+
        '   {'+
        '      \"Name\":\"Pritam Polley\",'+
        '      \"Lead_Source\":\"\",'+
        '      \"Web_Source\":\"\",'+
        '      \"Lead_Sub_Source\":\"\",'+
        '      \"AD_Group\":\"\",'+
        '      \"Keyword\":\"\",'+
        '      \"Placement\":\"\",'+
        '      \"Channel_Cluster\":\"\",'+
        '      \"Goal\":\"\",'+
        '      \"Digital_Source\":\"\",'+
        '      \"UTM_Source\":\"\",'+
        '      \"UTM_Medium\":\"\",'+
        '      \"UTM_Campaign\":\"\",'+
        '      \"UTM_Content\":\"\",'+
        '      \"Last_Mile_Conversion\":\"\",'+
        '      \"Bid_Type\":\"\",'+
        '      \"Email\":\"pritam.polley@smaartt.com\",'+
        '      \"Dialing_Country\":\"\",'+
        '      \"Country_Code\":\"\",'+
        '      \"Mobile_Phone\":\"0545549067\",'+
        '      \"Phone\":\"\",'+
        '      \"Website_Language\":\"\",'+
        '      \"Project\":\"Test Project\",'+
        '      \"Project_Type\":\"\",'+
        '	   \"RDS_Country_Code\":\"+91\",'+
        '      \"Unit_Type\":\"\"'+
        '   }'+
        ']';
        RestRequest request = new RestRequest();
        request.requestUri ='https://sobharealty--fullcpy.sandbox.my.salesforce.com/services/apexrest/pushEnuiry/2024/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        RestContext.request = request;
        CreateEnquiey_2024_V1.doPost();
    }
    @isTest
    static void contactExist() {
        String json = '['+
        '   {'+
        '      \"Name\":\"Pritam Polley\",'+
        '      \"Lead_Source\":\"\",'+
        '      \"Web_Source\":\"\",'+
        '      \"Lead_Sub_Source\":\"\",'+
        '      \"AD_Group\":\"\",'+
        '      \"Keyword\":\"\",'+
        '      \"Placement\":\"\",'+
        '      \"Channel_Cluster\":\"\",'+
        '      \"Goal\":\"\",'+
        '      \"Digital_Source\":\"\",'+
        '      \"UTM_Source\":\"\",'+
        '      \"UTM_Medium\":\"\",'+
        '      \"UTM_Campaign\":\"\",'+
        '      \"UTM_Content\":\"\",'+
        '      \"Last_Mile_Conversion\":\"\",'+
        '      \"Bid_Type\":\"\",'+
        '      \"Email\":\"test@test.com\",'+
        '      \"Dialing_Country\":\"\",'+
        '      \"Country_Code\":\"\",'+
        '      \"Mobile_Phone\":\"0545549067\",'+
        '      \"Phone\":\"\",'+
        '      \"Website_Language\":\"\",'+
        '      \"Project\":\"Test Project\",'+
        '      \"Project_Type\":\"\",' +
        '	   \"RDS_Country_Code\":\"+91\",' +
        '      \"Unit_Type\":\"\"'+
        '   }'+
        ']';
        RestRequest request = new RestRequest();
        request.requestUri ='https://sobharealty--fullcpy.sandbox.my.salesforce.com/services/apexrest/pushEnuiry/2024/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        RestContext.request = request;
        CreateEnquiey_2024_V1.doPost();
    }
}
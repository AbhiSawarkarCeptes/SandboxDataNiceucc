@isTest
public class WhatsappInboundServiceTest {
    
    @testSetup static void setup() {
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator' LIMIT 1];   
        
        User presalesAgent = new User(firstName = 'Test', lastName = 'Agent', email='testagent@test.com.invalid', Username= 'testagent@test.com.invalid.inv', ProfileId = p.Id, alias='test',EmailEncodingKey='UTF-8', 
                                      LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US');
        insert presalesAgent;      
        lead thisLead = new lead();
        thisLead.LastName = 'TestRecord';
        thisLead.email = 'test@test.com';
        thisLead.MobilePhone = '1111';
        thisLead.Presales_Agent__c = presalesAgent.Id;
        insert thisLead;      
    }
    
    @isTest
    Public static void testGet() {

        Test.startTest();
        
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/getTeleSalesAgent/*/' + '1111';
        request.httpMethod = 'GET';
        RestContext.request = request;
        WhatsappInboundService.doGet();
     
        Test.stopTest();   
    }
}
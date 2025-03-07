@isTest
public class PSGetCountryMobile_Test {
	@isTest
    public static void TestPSGetCountryMobileSuccess(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getCountryList';
        RestContext.request = req;
        RestContext.response = res;
        
		Test.startTest();
        PSGetCountryMobile.getItems();
        Test.stopTest();
    }
    @isTest
    public static void TestPSGetCountryMobileFailure(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        res.statusCode = 400;
        req.requestURI = 'getCountryList';
        RestContext.request = req;
        RestContext.response = res;
        
		Test.startTest();
        PSGetCountryMobile.getItems();
        Test.stopTest();
    }
    @isTest
    public static void TestPSGetCountryMobileExcep(){  
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        res.statusCode = 400;
        Mobile_App_Log__c logError = new Mobile_App_Log__c();
        logError.Response_Body__c = 'error occured';
        logError.Class_Name__c = 'PSGetCountryMobile';
        logError.API_Name__c = '/services/apexrest/getCountryList/';
        logError.Status__c = '400';
        insert logError;
		Test.startTest();
        try{
            PSGetCountryMobile.getItems();
        }
        catch(exception e) {
            
        }
        Test.stopTest();
    }
}
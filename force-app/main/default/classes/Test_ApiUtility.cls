@isTest
public class Test_ApiUtility {
	
    @isTest
    static void testMethod1(){
		Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = 'Success';
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK'));
            ApiUtility.httpCalloutUsingUserNamePassword('eNDPOINT','METHODtYPE', 'UserName', 'PassCode');
        	ApiUtility.httpCalloutUsingNamedCredentials('eNDPOINT','METHODtYPE', 'Body');
        	ApiUtility.logAnException('eNDPOINT','Error', 'Body', 'APIType');
		Test.stopTest();        
    }
    
}
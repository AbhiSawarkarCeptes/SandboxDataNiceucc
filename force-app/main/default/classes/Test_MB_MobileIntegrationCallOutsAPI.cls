@isTest
public class Test_MB_MobileIntegrationCallOutsAPI {
	
    @isTest
    static void testCreateMasterComunity(){
        Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = 'Success';
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK'));
            MobileIntegrationCallOutsAPI.createMasterComunity();
        	MobileIntegrationCallOutsAPI.createComunity();
        	MobileIntegrationCallOutsAPI.createUnit();
        	MobileIntegrationCallOutsAPI.createUser();
        	MobileIntegrationCallOutsAPI.callMobileApp('eNDPOINT','METHODtYPE', 'Body');
        Test.stopTest();
    }
    
}
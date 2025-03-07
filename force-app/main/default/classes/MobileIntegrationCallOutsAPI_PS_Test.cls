@isTest
public class MobileIntegrationCallOutsAPI_PS_Test {
	@isTest
    public static void testCallMobileApp_Success() {
        Mobile_App__mdt mockMobileAppMdt = new Mobile_App__mdt(
            End_Point__c = 'mockEndpoint',
            sf_Token__c = 'mockSfToken',
            Subscription_Key__c = 'mockSubscriptionKey'
        );
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        MobileIntegrationCallOutsAPI_PS.TemplateData tt = new MobileIntegrationCallOutsAPI_PS.TemplateData();
        MobileIntegrationCallOutsAPI_PS.callMobileApp('mockEndpoint', 'GET', 'mockBody');
        try{
        MobileIntegrationCallOutsAPI_PS.sendnotifications('', 'GET', 'mockBody',tt,'');
        }catch(exception e){
            
        }
    }
}
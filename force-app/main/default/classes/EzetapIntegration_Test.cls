@isTest
public class EzetapIntegration_Test {
    @isTest
    public static void EzetapCancel_test(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EzetapCancelCalloutMock()); 
        EzetapIntegrationCancelCallout.sendRequest('230103090Test');
        Test.stopTest();
    }
    
    @isTest
    public static void EzetapStart_test(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EzetapStartCalloutMock()); 
        EzetapIntegrationStartCallout.sendRequest(100, 'D12345', 'PR-100001');
        Test.stopTest();
    }
    
    @isTest
    public static void EzetapStatus_test(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EzetapStatusCalloutMock()); 
        EzetapIntegrationStatusCallout.sendRequest('230103090Test');
        Test.stopTest();
    }
}
@isTest
public class triggerPlatformEventForMobileAPITest {
	
    @isTest
    static void testMethod1(){
        test.startTest();
        	triggerPlatformEventForMobileAPI.getTriggeredData(true,'triggeredNewData', 'triggeredOldData', 'objectName');
        test.stopTest();
    }
}
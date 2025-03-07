/***************************************************************************
Class Name     : Nice_LoggerTest
Covers         : Nice_LoggerUtility
Author         : Ashok Kumar M
*****************************************************************************/
@isTest
private class Nice_LoggerTest {
    
    @isTest
    private static void testCreateLog() {
        
        test.startTest();
        Nice_LoggerUtility.createLog('Nice_LoggerTest.testCreateLog', 'Request', 'Response', 200);
        test.stopTest();
        
    }
    

}
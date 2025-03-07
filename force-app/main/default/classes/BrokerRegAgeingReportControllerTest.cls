@isTest
public class BrokerRegAgeingReportControllerTest {
	
    @isTest
    static void testCreateRecord() {
         Broker_Registration__c testRecord = new Broker_Registration__c(
            FIrst_Name__c = 'Test',
            Last_Name__c = 'Broker',
            Email__c = 'test@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            status__c = 'CHRM Registration Done'
        );
        insert testRecord;
        List<String> testString = new List<String>{'CHRM Registration Done'};
        Test.startTest();
        	BrokerRegAgeingReportController.getBRData(testString);
        Test.stopTest();
    }
    
}
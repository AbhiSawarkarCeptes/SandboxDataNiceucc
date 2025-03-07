@isTest
public class ContentVersionTriggerHandlerTest {

    @isTest
    static void testAfterInsert() {
        Broker_Registration__c testRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            CHRM_Manager_Email__c = 'chrm@example.com'
        );
        insert testRecord;

        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test content'),
            PathOnCLient = 'Path',
            Related_Record_ID_fileupload__c = testRecord.Id
        );
        insert testContentVersion;
    }

}
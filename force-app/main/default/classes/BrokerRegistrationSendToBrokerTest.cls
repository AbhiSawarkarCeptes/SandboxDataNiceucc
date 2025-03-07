@isTest
public class BrokerRegistrationSendToBrokerTest {
	
    @IsTest
    static void testGenerate1() {
        Broker_Registration__c existingRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Broker_Created_Date__c = system.today(),
            Status__c = 'Executed Agreement sent to CRHM',
             Alternate_Email__c = 'existing@example.com'
        );
        insert existingRecord;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'NOC Test Document',
            VersionData = Blob.valueOf('NOC Test content'),
            PathOnCLient = 'Path'
        );
        insert testContentVersion;
        
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = existingRecord.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert testContentDocumentLink;
        
        existingRecord.Status__c='Executed Agreement sent to CRHM';
        update existingRecord;
        
        system.debug('~~~~~'+existingRecord);
		
        Test.startTest();
        BrokerRegistrationSendToBroker.sendAgreementAndNOCToBroker(existingRecord.Id);
        Test.stopTest();
    }
    
}
@isTest
public class brokerRegAgrDocuSignControlerTest {

    @IsTest
    static void sendEnvelopeMethodTest() {
         Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Witness_Email_1__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Alternate_Email__c = 'existing@example.com'
        );
        insert testBrokerRegistration;

    ContentVersion testContentVersion = new ContentVersion(
            Title = 'TestAgreement',
            VersionData = Blob.valueOf('TestAgreement'),
            PathOnCLient = 'Path'
        );
        insert testContentVersion;

        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = testBrokerRegistration.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert testContentDocumentLink;

        Test.startTest();

        brokerRegAgrDocuSignControler.sendEnvelopeMethod(new List<Id>{testBrokerRegistration.Id});

        Test.stopTest();

    }
}
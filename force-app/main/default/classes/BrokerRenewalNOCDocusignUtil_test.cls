@isTest
public class BrokerRenewalNOCDocusignUtil_test {
    
    @isTest
    private static void testGetPayment() {
        Broker_Renewal__c brokerRen = TestDataFactorySobha.createBrokerRenewal(null);
        brokerRen.Broker_Type__c = 'Standard';
        brokerRen.Broker_Sub_Type__c = 'Broker UAE';
        insert brokerRen;
        Broker_Renewal__c brokerRen1 = TestDataFactorySobha.createBrokerRenewal(null);
        brokerRen.Broker_Type__c = 'Standard';
        brokerRen.Broker_Sub_Type__c = 'Broker UAE';
        insert brokerRen1;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'NOC -',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = brokerRen.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Agreement - -',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;    
        List<ContentDocument> documents1 = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        dfsle__EnvelopeStatus__c dse = new dfsle__EnvelopeStatus__c(Envelope_Type__c = 'Booking Form',dfsle__DocuSignId__c = '1234');
        insert dse;
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = brokerRen1.id;
        cdl1.ContentDocumentId = documents1[0].Id;
        cdl1.ShareType = 'V';
        //insert cdl1;
        BrokerRenewalNOCDocusignUtil.getBrokerRenewal(brokerRen.Id);
        BrokerRenewalNOCDocusignUtil.getFileId(brokerRen.Id);
        BrokerRenewalNOCDocusignUtil.getFileId1(brokerRen1.Id);
        BrokerRenewalNOCDocusignUtil.docusignEmailBody(brokerRen);
        Map<String,String> emailToRoleMap = new Map<String,String>();
        BrokerRenewalNOCDocusignUtil.docusignPostProcessing('1234',brokerRen.Id,null,emailToRoleMap);
    }
}
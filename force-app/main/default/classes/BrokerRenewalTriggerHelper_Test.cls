@isTest
public class BrokerRenewalTriggerHelper_Test {
	@isTest
    static void testMethod1() {
        List<Broker_Renewal__c> brokerList = new List<Broker_Renewal__c>();
        Broker_Renewal__c broker = TestDataFactorySobha.createBrokerRenewal(null);
        broker.CRM_Email__c = 'Test@test.com';
        brokerList.add(broker);
        Broker_Renewal__c broker3 = TestDataFactorySobha.createBrokerRenewal(null);
        broker3.Al_Siniya_Partner__c = true;
        brokerList.add(broker3);
        Broker_Renewal__c broker1 = TestDataFactorySobha.createBrokerRenewal(null);
        broker1.CRM_Email__c = 'Test@test1.com';
        brokerList.add(broker1);
        Broker_Renewal__c broker2 = TestDataFactorySobha.createBrokerRenewal(null);
        broker2.CRM_Email__c = 'Test@test2.com';
        brokerList.add(broker2);
		insert brokerList;
        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(new ContentVersion(Title = 'Agreement - Test', PathOnClient = 'Penguins.PDF', VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true));
        cvList.add(new ContentVersion(Title = 'NOC - Test', PathOnClient = 'Penguins.PDF', VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true));
        insert cvList;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
	    //create ContentDocumentLink  record 
	    cdlList.add(new ContentDocumentLink(LinkedEntityId = brokerList[1].id, ContentDocumentId = documents[0].Id, ShareType = 'V'));
        cdlList.add(new ContentDocumentLink(LinkedEntityId = brokerList[1].id, ContentDocumentId = documents[1].Id, ShareType = 'V'));
        insert cdlList;
        
        brokerList[0].All_Documents_Uploaded__c = true;
        brokerList[0].All_Mandatory_Documents__c = true;
        brokerList[1].Broker_Approval_Status__c = 'Pending with Ashish Parakh/ Sent for final signatures';
        brokerList[2].Broker_Approval_Status__c = 'NOC Generated';
        brokerList[2].NOC_Generated__c = true;
        update brokerList;
        
    }
}
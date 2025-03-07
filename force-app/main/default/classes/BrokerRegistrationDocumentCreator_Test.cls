@isTest
public class BrokerRegistrationDocumentCreator_Test {
    @isTest
    static void testMethod1(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Account acc2 = TestDataFactorySobha.createAccount(null);
        insert acc2;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Broker_Agreement.pdf',
            PathOnClient = 'Broker_Agreement.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;  
        
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Broker_Agreement.pdf',
            PathOnClient = 'Broker_Agreement.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2; 
          
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc2.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        conList.add(cdl);
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = acc2.id;
        cdl2.ContentDocumentId = documents[1].Id;
        cdl2.shareType = 'V';
        //insert cdl;
        conList.add(cdl2);
    
        Insert conList;
        List<Id> lst = new List<Id>();
        lst.add(acc.Id);
        Test.StartTest();
        BrokerRegistrationDocumentCreator.brokerRegistrationAttacher(lst);
        BrokerRegistrationDocumentCreator.brokerRegistrationAttacher2(lst);
        Test.StopTest();
    }
}
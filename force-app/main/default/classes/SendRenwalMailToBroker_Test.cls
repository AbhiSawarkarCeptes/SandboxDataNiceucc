@isTest
public class SendRenwalMailToBroker_Test {
    
     @testsetup
    public static void createData() {
        Broker_Renewal__c testRecord = TestDataFactorySobha.createBrokerRenewal(null);
        insert testRecord; 
          ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
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
        cdl.LinkedEntityId = testRecord.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
    }
    
    @isTest
    static void testRecord() {
        Id recId = [SELECT Id FROM Broker_Renewal__c LIMIT 1].Id;
        Test.startTest();
        try{
            SendRenwalMailToBroker.sendEmail(new List<String>{recId});
            SendRenwalMailToBroker.sendEmailNotificationBroker(recId);
            }catch(Exception e){
        }
        Test.stopTest();
    }

}
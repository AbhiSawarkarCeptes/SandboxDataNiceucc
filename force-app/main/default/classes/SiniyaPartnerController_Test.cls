@isTest
public class SiniyaPartnerController_Test {
    @isTest
    public static void getAccountClone(){
        Id stExam = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        Account accc = new Account();
        accc.RecordTypeId = stExam;
        accc.Name = 'Smith';
        accc.Phone = '8579171110';
        //accc.Email = 'John@test.com';
        accc.Unique_Customer_ID__c = '1254';
        accc.Unique_Customer_External_ID__c = '1254';
        accc.Registration_Date__c = date.today();
        insert accc;
        
        BR_Document_History__c brClone = new BR_Document_History__c(Broker_Account__c = accc.Id, File_Name__c = 'test',File_Type__c = 'png');
        Insert brClone;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Booking form.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = accc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        conList.add(cdl);
        
        Insert conList;
        
        test.StartTest();
        SiniyaPartnerController.AccountClone(accc.Id);
        test.StopTest();
    }
}
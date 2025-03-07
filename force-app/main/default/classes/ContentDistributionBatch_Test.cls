@isTest
private class ContentDistributionBatch_Test {
    @testSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User guestUser = new User(
            Alias = 'bguest',
            Email = 'broker_guestuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Broker Account Site Guest User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'broker_guestuser@test.com'
        );
        insert guestUser;
        System.runAs(guestUser) {
            Account acc = TestDataFactorySobha.createAccount(null);
            acc.PropStrength__Broker_Approval_Status__c = 'Broker Empanelment Form Filled';
            acc.Registration_Link_Expiry_Date_Time__c = System.now().addDays(2);
            acc.Modified_by_guest_user__c = true;
            insert acc;
            
            Broker_Renewal__c brkRenew= TestDataFactorySobha.createBrokerRenewal(null);
            brkRenew.Modified_by_guest_user__c = true;
            insert brkRenew;
            
            BR_Document_History__c brd= new BR_Document_History__c();
            brd.Expiry_date__c=Date.Today().addDays(2);
            brd.File_Name__c='TestFile.pdf';
            brd.File_Type__c='Test';
            brd.Broker_Account__c = acc.Id;
            insert brd;
            
            BR_Document_History__c brd2  = new BR_Document_History__c();
            brd2.Expiry_date__c=Date.Today().addDays(2);
            brd2.File_Name__c='TestFile.pdf';
            brd2.File_Type__c='Test';
            brd2.Broker_Renewal__c = brkRenew.Id;
            insert brd2;
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Noc.pdf',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion; 
            
            ContentVersion contentVersion2 = new ContentVersion(
                Title = 'Noc.pdf',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion2;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = brd.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId = brd2.id;
            cdl2.ContentDocumentId = documents[1].Id;
            cdl2.shareType = 'V';
            insert cdl2;
        }
    }

    @isTest
    static void testExecuteBatch() {
        Test.startTest();
        ContentDistributionBatch batch = new ContentDistributionBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}
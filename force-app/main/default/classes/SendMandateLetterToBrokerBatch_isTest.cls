@isTest
public class SendMandateLetterToBrokerBatch_isTest {
    public static String CRON_EXP = '00 00 * ? * * *';
    @testSetup static void setup() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        chPartner.Seller_Representative__c = UserInfo.getUserId();
        insert chPartner;
        
        dfsle__EnvelopeStatus__c ob = new dfsle__EnvelopeStatus__c();
        ob.Channel_Partner__c = chPartner.id;
        ob.dfsle__Status__c = 'Completed';
        insert ob;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Mandate Test',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument order by Title];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = chPartner.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
    }

    @isTest static void testMandateletterToBroker() 
    	{  
            List<ID> cIds = new List<Id>();
            for (Channel_Partner__c cp : [SELECT Id FROM Channel_Partner__c]) 
            {
                 cIds.add(cp.Id);
        	}
            try 
            {
                SendMandateLetterToBrokerBatch obj = new SendMandateLetterToBrokerBatch();
                Database.executeBatch(obj);
                String jobId3 = System.schedule('SendMandateLetterToBrokerJob',CRON_EXP,new SendMandateLetterToBrokerBatch());
        		SendMandateLetterToBrokerBatch.scheduleThisEveryday('00 00 * ? * * *');
            } 
            catch(Exception e) {}
    	}

}
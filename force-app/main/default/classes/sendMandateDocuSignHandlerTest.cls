@isTest
public class sendMandateDocuSignHandlerTest 
{
	@testSetup static void setup() {
       
        // Added by Hitesh 
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        chPartner.Seller_Representative__c = UserInfo.getUserId();
        insert chPartner;
        
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
        
        // Addded by Hitesh : DocuSign is processing - Validation
        dfsle__EnvelopeStatus__c des = new dfsle__EnvelopeStatus__c();
        des.Envelope_Type__c='Mandate Letter';
        des.dfsle__Status__c='Sent';
        des.Channel_Partner__c=chPartner.Id;
        Insert des;
        
    }

    @isTest static void testBookingFormDocusignApplicant() 
    	{   
            List<ID> cIds = new List<Id>();
            for (Channel_Partner__c cp : [SELECT Id FROM Channel_Partner__c]) 
            {
                 cIds.add(cp.Id);
        	}
            try 
            {
                sendMandateDocuSignHandler.sendEnvelopeMethod(cIds);
                sendMandateDocuSignHandler1.sendEnvelopeMethod1(cIds);
            } 
            catch(Exception e) {}
    	}


}
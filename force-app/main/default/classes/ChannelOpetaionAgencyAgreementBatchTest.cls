@isTest
public class ChannelOpetaionAgencyAgreementBatchTest {
	
    @isTest
    private static void testBatch(){
        list<Channel_partner__c> channelList = new List<Channel_Partner__c>();
        Channel_Partner__c channel1 = new Channel_Partner__c();
        channel1.Name = 'Test Channel Partner';
        channel1.Expiry_Date__c = System.today();
        channel1.Channel_Relationship_Manager__c = UserInfo.getUserId();
        channelList.add(channel1);
        Channel_Partner__c channel2 = new Channel_Partner__c();
        channel2.Name = 'Test Channel Partner 2';
        channel2.Expiry_Date__c = System.today().addDays(15);
        channel2.Channel_Relationship_Manager__c = UserInfo.getUserId();
        channelList.add(channel2);
        Channel_Partner__c channel3 = new Channel_Partner__c();
        channel3.Name = 'Test Channel Partner 3';
        channel3.Expiry_Date__c = System.today().addDays(30);
        channel3.Channel_Relationship_Manager__c = UserInfo.getUserId();
        channelList.add(channel3);
        Channel_Partner__c channel4 = new Channel_Partner__c();
        channel4.Name = 'Test Channel Partner 4';
        channel4.Expiry_Date__c = System.today().addDays(30);
        channel4.Channel_Relationship_Manager__c = UserInfo.getUserId();
        channelList.add(channel4);
        
        insert channelList;
		Database.executeBatch(new ChannelOpetaionAgencyAgreementBatch());
        
    }
}
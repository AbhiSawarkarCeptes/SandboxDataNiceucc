@istest public class SobhaGetBrokersAPITest {
	public testmethod static void getBrokersTest() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        SobhaGetBrokersAPI.getBrokers();
    }
}
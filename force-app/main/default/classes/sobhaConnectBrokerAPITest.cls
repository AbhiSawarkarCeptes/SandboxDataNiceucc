@istest public class sobhaConnectBrokerAPITest {
	public testmethod static void getSobhaConnectTest() {
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert sc;
        sobhaConnectBrokerAPI.getSobhaConnect();
    }
}
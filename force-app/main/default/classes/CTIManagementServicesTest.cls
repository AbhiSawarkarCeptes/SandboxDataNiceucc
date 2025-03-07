@isTest
public with sharing class CTIManagementServicesTest {

static testMethod void testCallingQueue() {
	Test.startTest();
	Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
	User u1 = createUser('Test1', 'Testsobha', 'testabcde1234@stetig.in', 'testabcde1234@stetig.in', p1);

	Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Presales'];
	User u2 = createUser('Test2', 'Testsobha2', 'testabcde12345@stetig.in', 'testabcde12345@stetig.in', p2);

	User u3 = createUser('Test3', 'Testsobha3', 'testabcde12346@stetig.in', 'testabcde12346@stetig.in', p2);
	createCustomSetting();
	System.runAs(u2) {
		Lead lFresh = new Lead(MobilePhone='9876543210', lastName = 'fresh lead', is_serviced__c = false, Date_and_Time_of_Unserviced_Lead__c = system.now(), ownerId = u2.Id, presales_agent__c = u2.Id);
		insert lFresh;

		Lead lReenquiry = new Lead(MobilePhone='9876543211', lastName = 'Req lead', is_serviced__c = false, Date_and_Time_of_Unserviced_Lead__c = system.now().addMinutes(10), First_Call_Attempt_Date__c = system.now().addDays(-1), ownerId = u2.Id, presales_agent__c = u2.Id);
		insert lReenquiry;

		Lead lNoContactFollowup = new Lead(MobilePhone='9876543212', lastName = 'No Contact lead', is_serviced__c = true,  First_Call_Attempt_Date__c = system.now().addDays(-1),Last_Call_Attempt_Date__c = system.now().addDays(-1), Latest_Next_Action_Date__c = system.now().addDays(-1).addHours(5), Last_Call_Attempt_Status__c = 'No Contact',ownerId = u2.Id, presales_agent__c = u2.Id);
		insert lNoContactFollowup;

		Lead lFollowup = new Lead(MobilePhone='9876543213', lastName = 'Followup lead', is_serviced__c = true,  First_Call_Attempt_Date__c = system.now().addHours(-1),Last_Call_Attempt_Date__c = system.now().addDays(-1), Latest_Next_Action_Date__c = system.now().addDays(-1).addHours(5), Last_Call_Attempt_Status__c = 'Follow up',ownerId = u2.Id, presales_agent__c = u2.Id);
		insert lFollowup;
		Account aReenquiry = TestDataFactory.createPATemplate('Req Account', 'wc@email.com','9098777',false);
		aReenquiry.is_serviced__c = false;
		aReenquiry.presales_agent__c = u2.Id;
		update aReenquiry;

		Opportunity oFollowup = new Opportunity(accountId = aReenquiry.Id, Name = 'Follow up', Next_Action_Date__c = system.now().addDays(-1).addHours(5), Last_Call_Attempt_Date__c = system.now().addDays(-1), Last_call_attempt_status__c  = 'Follow up', presales_agent__c= u2.Id, StageName = 'Open', closeDate = system.today().addDays(30));
		insert oFollowup;

		Opportunity oNoContact = new Opportunity(accountId = aReenquiry.Id, Name = 'No Contact', Next_Action_Date__c = system.now().addDays(-1).addHours(5), Last_Call_Attempt_Date__c = system.now().addDays(-1), Last_call_attempt_status__c  = 'No Contact', presales_agent__c= u2.Id,  StageName = 'Open', closeDate = system.today().addDays(30));
		insert oNoContact;

		List<CTIManagementServices.callQueueWrapper> ctiWrapperList = new List<CTIManagementServices.callQueueWrapper>();
		ctiWrapperList = CTIManagementServices.priortiseDialingQueue(u2.Id);
		// system.assertequals(7, ctiWrapperList.size(), 'Actual:' + ctiWrapperList.size() + ' Vs Expected:4' );


	}
	System.runAs(u1) {
		List<CTIManagementServices.callQueueWrapper> ctiWrapperList1 = new List<CTIManagementServices.callQueueWrapper>();
		ctiWrapperList1 = CTIManagementServices.priortiseDialingQueue(u1.Id);
		// system.assertequals(7, ctiWrapperList1.size(), 'Actual:' + ctiWrapperList1.size() + ' Vs Expected:4' );
		CTIManagementServices.reassignLeads(ctiWrapperList1,u3.Id );
	}
	CTIManagementServices.getUserNamePicklist();
	Test.stopTest();
}
static testMethod void testCallbyId(){
	List<BitVoice__c> bvList = new List<BitVoice__c>();
	BitVoice__c bvRec = new BitVoice__c();
	bvRec.Name = 'Make Calls';
	bvRec.URL__c = 'http://sobha-llc-btkhdthwbr.dynamic-m.com:9253/app/api/makecall/yRdXznO2PqAsCx9con/';
	bvList.add(bvRec);

	BitVoice__c bvRec1 = new BitVoice__c();
	bvRec1.Name = 'Change Status';
	bvRec1.URL__c = 'http://sobha-llc-btkhdthwbr.dynamic-m.com:9253/app/api/agentstatus/yRdXznO2PqAsCx9con/';
	bvList.add(bvRec1);
	insert bvList;

	Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Presales'];
	User u2 = createUser('Test2', 'Testsobha2', 'testabcde12345@stetig.in', 'testabcde12345@stetig.in', p2);
	u2.status__c = 'OUTCALL';
	update u2;
	Lead lFresh = new Lead(MobilePhone='9876543210', lastName = 'fresh lead', is_serviced__c = false, Date_and_Time_of_Unserviced_Lead__c = system.now(), ownerId = u2.Id, presales_agent__c = u2.Id);
	insert lFresh;
	Test.StartTest();
	System.RunAS(u2) {
		Test.setMock(HttpCalloutMock.class, new CallByIdMock());
		CTIManagementServices.callById(lFresh.Id);
		CTIManagementServices.changeAgentStatusAfterCallHangup();
	}
	Test.stopTest();

}
public static User createUser(string fn, string ln, string username, string email, Profile pro) {

	Id umanager = UserInfo.getUserId();

	User u = new User(firstName = fn, lastName = ln, email=email,Username= username, ProfileId = pro.Id, alias= ln.substring(0,7),EmailEncodingKey='UTF-8',
	                  LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230', ManagerId = umanager);
	insert u;
	return u;

}
public static void createCustomSetting(){
	calling_priority__c cs = new calling_priority__c();
	cs.name = 'FRESH';
	cs.priority__c=1;
	insert cs;

	calling_priority__c cs1 = new calling_priority__c();
	cs1.name = 'REENQUIRY';
	cs1.priority__c=2;
	insert cs1;

	calling_priority__c cs2 = new calling_priority__c();
	cs2.name = 'NO CONTACT - FOLLOW UP';
	cs2.priority__c=4;
	insert cs2;

	calling_priority__c cs3 = new calling_priority__c();
	cs3.name = 'FOLLOW UP';
	cs3.priority__c=3;
	insert cs3;

}
}
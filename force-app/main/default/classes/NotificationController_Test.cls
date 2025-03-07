@isTest
private Class NotificationController_Test {
	public static testMethod void testNotificationController() {
		Test.startTest();

		User u = new User(
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'Presales'].Id,
			LastName = 'last',
			Email = 'puser000@amamama.com',
			Username = 'puser000@amamama.com' + System.currentTimeMillis(),
			CompanyName = 'TEST',
			Title = 'title',
			Alias = 'alias',
			TimeZoneSidKey = 'America/Los_Angeles',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			Status__c = 'AVAILABLE');
		u.ManagerId = userInfo.getUserId();
		insert u;
		System.runAs(u){
			List<BitVoice__c> bvList = new list<BitVoice__c>();
			BitVoice__c bv1 = new BitVoice__c();
			bv1.Name = 'Change Status';
			bv1.URL__C = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/agentstatus/yRdXznO2PqAsCx9con/';
			bvList.add(bv1);

			BitVoice__c bv3 = new BitVoice__c();
			bv3.Name = 'Logout';
			bv3.URL__C = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/agentlogout/yRdXznO2PqAsCx9con/';
			bvList.add(bv3);

			insert bvList;

			Account acc = new Account();
			acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
			acc.LastName = 'Test Account';
			acc.PersonMobilePhone = '98762342';
			insert acc;

			NotificationController.getUserExtension();
			NotificationController.checkAgentAvailability();
			NotificationController.getUserName();
			NotificationController.getAgentStatus();
			NotificationController.getUserExtensionAndLeadId(acc.Id);
			NotificationController.loginLogout('true');
			NotificationController.setAgentStatus('AVAILABLE');
		}
	}
	public static testMethod void testNotificationController2() {
		Test.startTest();

		User u = new User(
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'Presales'].Id,
			LastName = 'last',
			Email = 'puser000@amamama.com',
			Username = 'puser000@amamama.com' + System.currentTimeMillis(),
			CompanyName = 'TEST',
			Title = 'title',
			Alias = 'alias',
			TimeZoneSidKey = 'America/Los_Angeles',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			Status__c = 'AVAILABLE');
		u.ManagerId = userInfo.getUserId();
		insert u;
		System.runAs(u){
			List<BitVoice__c> bvList = new list<BitVoice__c>();
			BitVoice__c bv1 = new BitVoice__c();
			bv1.Name = 'Change Status';
			bv1.URL__C = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/agentstatus/yRdXznO2PqAsCx9con/';
			bvList.add(bv1);

			BitVoice__c bv3 = new BitVoice__c();
			bv3.Name = 'Logout';
			bv3.URL__C = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/agentlogout/yRdXznO2PqAsCx9con/';
			bvList.add(bv3);

			insert bvList;


			Lead leadRecord = new Lead();
			leadRecord.lastName = 'Satish';
			leadRecord.MobilePhone = '8987898765';
			leadRecord.Last_Call_Attempt_Status__c = 'visit confirmed';
			leadRecord.Primary_Number__c = '98762342';
			insert leadRecord;

			NotificationController.getUserExtension();
			NotificationController.checkAgentAvailability();
			NotificationController.getUserName();
			NotificationController.getAgentStatus();
			NotificationController.getUserExtensionAndLeadId(leadRecord.Id);
			NotificationController.loginLogout('true');
			NotificationController.setAgentStatus('AVAILABLE');
			try{NotificationController.loginLogout('false');}
			catch(Exception e) {}
		}
	}
}
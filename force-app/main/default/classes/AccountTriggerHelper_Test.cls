@isTest
public  class AccountTriggerHelper_Test {
    
    @isTest
    static void testupdateAccount() {
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        profile prof = [select id from profile where name = 'System Administrator'];
        
        User testUserc = new User(
            Alias = 'standard', Email='standarduse1111r@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = prof.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='testUser111A@testorganise.com');
        insert testUserc;
        
        
        List<Account> acc = new List<Account>();
        
        Account acc1 = new Account();
        acc1.name = 'Test account 1';
        acc1.RecordTypeId = RecordTypeIdAccount;
        acc1.PropStrength__Broker_Type__c ='Standard';
        acc1.Broker_Category__c = 'Individual';
        acc1.Name_as_per_passport__c = 'passportName';
        acc1.All_Documents_Updated__c = false;
        acc1.Emergency_CP_SC_ID__c = false;
        acc1.Registration_Passport_Number__c = '123';
        acc1.TRN_Number__c ='456';
        acc1.Channel_Relationship_Manager__c = testUserc.id;
        acc1.Sales_Manager_User__c = testUserc.id;
        acc1.PropStrength__Broker_Approval_Status__c = 'All Missing Documents Uploaded';
        acc.add(acc1);
        
        
        Account acc2 = new Account();
        acc2.name = 'Test account 2';
        acc2.RecordTypeId = RecordTypeIdAccount;
        acc2.PropStrength__Broker_Type__c ='Standard';
        acc2.Broker_Category__c = 'Company';
        acc2.Name_as_per_trade_license__c = 'passportName';
        acc.add(acc2);
        
        insert acc;
        
        Map<id,Account> oldMap = new Map<id,Account>();
        oldMap.put(acc1.id,acc1);
        oldMap.put(acc2.id, acc2);
        
        List<Account> updateList = new List<Account>();
        Account acc3 = new Account();
        acc3.id = acc1.id;
        acc3.name = 'Test account 3';
        acc3.Name_as_per_passport__c = 'changedPassportNmae';
        acc3.Broker_Category__c = 'Company';
        acc3.All_Documents_Updated__c = true;
        acc3.PropStrength__Broker_Approval_Status__c ='Executed Agreement Sent to CHRM';
        updateList.add(acc3);
        
        Account acc4 = new Account();
        acc4.id = acc2.id;
        acc4.name = 'Test account 4';
        acc4.Name_as_per_trade_license__c = 'changedTradeName';
        acc4.Broker_Category__c = 'Individual';
        acc4.PropStrength__Broker_Approval_Status__c = 'Sent for Final Signatures';
        updateList.add(acc4);
        
        update updateList;
        Test.startTest();
        AccountTriggerHelper.updateAccount(updateList,oldMap);
        AccountTriggerHelper.checkActiveStatus(updateList,oldMap);
        AccountTriggerHelper.updateCRMOpsUser(updateList,oldMap);
        AccountTriggerHelper.sendNocForFinalSignature(updateList,oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testaddChannelRelationshipAndSalesHead(){
        
        profile prof = [select id from profile where name = 'System Administrator'];
        
        User testUserc = new User(
            Alias = 'standard', Email='standarduse1111r@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = prof.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='testUser111A@testorganise.com');
        insert testUserc;
        
        User usr = new User();
        usr.LastName = 'teststandlead099';
        usr.Alias = 'test111';
        usr.ManagerId = testUserc.id;
        usr.Email = 'abctttt@gmail.com';
        usr.Username = 'abctttt@gmail.com';
        usr.CommunityNickname = 'User16801622611294507700';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US';
        usr.ProfileId  = prof.id;
        usr.TimeZoneSidKey  = 'America/New_York';
        
        insert usr;
        
        Profile pro = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUserA = new User(
            Alias = 'standard', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = pro.Id, ManagerID =usr.id,
        TimeZoneSidKey='America/Los_Angeles', UserName='testUserA@testorganise.com');
        
        User testUserB = new User(
            Alias = 'standard', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = pro.Id,  ManagerID = usr.id,
        TimeZoneSidKey='America/Los_Angeles', UserName='testUserB@testorganise.com');
        
        
        
        List<User> usersToInsert = new List<User>();
        usersToInsert.add(testUserA);
        usersToInsert.add(testUserB);
        insert usersToInsert;
        
        Group testGroup = new Group();
        testGroup.Name = 'testGroup';
        testGroup.DeveloperName = 'Broker_Reg_Channel_Partner_queue';
        testGroup.type = 'queue';
        INSERT testGroup;
        list<Group> groups = [SELECT Id, email FROM Group WHERE type = 'Queue' AND (DeveloperName='Broker_Reg_Channel_Partner_queue' OR DeveloperName='Broker_Registration_Sobha_Connect_Queue')];
        system.debug(groups);
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        List<Account> accList = new List<Account>();
        List<Account> accList2 = new List<Account>();
        Account acc1 = TestDataFactorySobha.createAccount(null);
        acc1.PropStrength__Broker_Type__c ='Sobha Connect';
        acc1.Broker_Category__c = 'Individual';
        acc1.Name = 'Test 1';
        accList.add(acc1);
        Account acc3 = TestDataFactorySobha.createAccount(null);
        acc3.PropStrength__Broker_Type__c ='Sobha Connect';
        acc3.Broker_Category__c = 'Individual';
        acc3.Name = 'Test 2';
        accList2.add(acc3);
        Account acc2 = TestDataFactorySobha.createAccount(null);
        acc2.PropStrength__Broker_Type__c ='Standard';
        acc2.Broker_Category__c = 'Individual';
        acc2.Name = 'Test 3';
        accList.add(acc2);
        Account acc4 = TestDataFactorySobha.createAccount(null);
        acc4.PropStrength__Broker_Type__c ='Standard';
        acc4.Broker_Category__c = 'Individual';
        acc4.Name = 'Test 4';
        accList2.add(acc4);
        insert accList;
        Test.startTest();
        insert accList2;
        Broker_Account_Approval_History__c rec = new Broker_Account_Approval_History__c();
        rec.Broker_Account__c = acc2.Id;
        rec.Status__c = 'Pending with Audit';
        insert rec;
        List<Account> updateList = new List<Account>();
        acc2.Email_Id_1__c = 'Test@Test.com';
        acc2.Send_Policy_Mandate_Letter__c = true;
        acc2.Field_Update_Request_Status__c = 'Pending With CHRM OPS Manager';
        acc1.Email_Id_1__c = 'Test@Test.com';
        acc1.Send_Policy_Mandate_Letter__c = true;
        acc1.PropStrength__Broker_Approval_Status__c = 'Broker Registration Done';
        updateList.add(acc1);
        updateList.add(acc2);
        update updateList;
        Test.stopTest();
    }
}
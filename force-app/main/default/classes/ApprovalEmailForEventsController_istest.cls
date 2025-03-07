@isTest
public class ApprovalEmailForEventsController_istest {
    @isTest
    public static void method1(){
                
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert sc;
        
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
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
        system.debug('userdebug' + usersToInsert);
        
        
        User u = [select id from user where userrole.name like '%Sales Manager%' limit 1];
      
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Name = 'Road Shows';
        evnt.Date_Of_Event__c = System.today().addDays(31);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        evnt.Stay_End_Date__c = System.today().addDays(23);
        evnt.Bypass_Validation_Rule__c = true;

        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Open Houses').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Channel_Partner__c = chPartner.id;
        //evnt.Sobha_Connect__c = sc.id;
        evnt.Sales_Manager__c = u.id;//usersToInsert[0].id;
        evnt.Sales_Director__c = usersToInsert[0].id;
        evnt.Sales_Head__c   = usersToInsert[0].id;
        evnt.Event_Approved_status__c = 'The event has been approved by Sales Director';
        evntlst.add(evnt);
        
        insert evntlst;
        system.debug('eventdebug' + evntlst);
        for(Events__c a: evntlst) {
            
            // Create an approval for the account and submit
            Approval.ProcessSubmitRequest AccountRequest = new Approval.ProcessSubmitRequest();
            AccountRequest.setObjectId(a.ID);
            AccountRequest.setComments('Submitting request for approval.');
            AccountRequest.setNextApproverIds(new Id[]{usersToInsert[0].Id});
            AccountRequest.setSkipEntryCriteria(true);
            Approval.ProcessResult AccountRequestResult = Approval.Process(AccountRequest);
            System.assert(AccountRequestResult.isSuccess());
            
            /*ProcessInstanceWorkitem pworkItem = new ProcessInstanceWorkitem();
            pworkItem.ActorId = userinfo.getuserId();
            pworkItem.OriginalActorId = userinfo.getuserId();
            pworkItem.ProcessInstanceId = AccountRequestResult.id;
            insert pworkItem;*/
           // System.assert(AccountRequestResult.isSuccess());  
            
        } // loop thru accounts submitting them for approval
        Test.startTest();
        ApprovalEmailForEventsController.currentId = evntlst[0].id;
        ApprovalEmailForEventsController.getrelatedTo();
        ApprovalEmailForEventsController.getLastApprovarName();
        ApprovalEmailForEventsController.getApprovalHistory();
        ApprovalEmailForEventsController.getCurrentUserName();
        ApprovalHistory_Control.eventWrap evt = new ApprovalHistory_Control.eventWrap('test','test1','test',system.now(),'test');
        test.stopTest();
        
    }
}
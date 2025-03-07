@isTest
public Class EnquiryDailyTrackingBatchTest {
    public static testMethod void testDailyTracking() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<User> UserList = new List<User>();
        Id proId = [SELECT Id FROM Profile WHERE Name LIKE 'System%'].Id;
        User u = new User(
            ProfileId = proId,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
            u.ManagerId = userInfo.getUserId();
            u.BitVoice_Agent_Ext__c = '1111';
            UserList.add(u);
            User u2 = new User(
            ProfileId = proId,
            LastName = 'last2',
            Email = 'puser000@ama.com',
            Username = 'puser000@ama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST2',
            Title = 'title2',
            Alias = 'alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
            u2.ManagerId = userInfo.getUserId();
            u2.BitVoice_Agent_Ext__c = '2222';
            UserList.add(u2);
        insert UserList; 
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        Marketing_Plan__c mp = new Marketing_Plan__c(Active__c = TRUE, Marketing_Plan_Cost__c = 1000000, Start_Date__c = System.Today().addDays(-2), End_Date__c = System.Today().addDays(60));
        insert mp;
        
        Marketing_Channel__c mc = new Marketing_Channel__c(Budget_Allotted__c = 100000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mc;
        
        PropStrength__Advertisement__c advt = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
    
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[1].Id;
        enq.Last_Attempt_Status__c = 'No Contact - Follow-up';
        enq.Temp_CreatedDate__c = SYstem.today().addDays(-1);
        insert enq;
        
        Day_Tracking__c dayTrack = new Day_Tracking__c();
        dayTrack.Name = 'Day 1';
        dayTrack.Enquiry__c = enq.Id;
        insert dayTrack;
        
        Attempt_Tracking__c attemptRec = new Attempt_Tracking__c();
        attemptRec.Attempt_Sequence__c = '1';
        attemptRec.Day_Tracking__c = dayTrack.Id;
        attemptRec.Name = 'Sobha Landline';
        attemptRec.Attempted_By__c = UserInfo.getuserId();
        attemptRec.RecordTypeId = Schema.getGlobalDescribe().get('Attempt_Tracking__c').getDescribe().getRecordTypeInfosByName().get('Sobha Landline').getRecordTypeId();
        insert attemptRec;
        
        attemptRec.Status__c = 'No Contact - Follow-up';
        update attemptRec;
        
        EnquiryDailyTrackingBatchScheduler sche = new EnquiryDailyTrackingBatchScheduler(); 
        String sch ='0 0 * * * ?'; 
        System.schedule('Schedule Batch', sch, sche);
        
        Test.stopTest();
    }
    public static testMethod void testDailyTrackingTwo() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<User> UserList = new List<User>();
        Id proId = [SELECT Id FROM Profile WHERE Name LIKE 'System%'].Id;
        User u = new User(
            ProfileId = proId,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
            u.ManagerId = userInfo.getUserId();
            u.BitVoice_Agent_Ext__c = '1111';
            UserList.add(u);
            User u2 = new User(
            ProfileId = proId,
            LastName = 'last2',
            Email = 'puser000@ama.com',
            Username = 'puser000@ama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST2',
            Title = 'title2',
            Alias = 'alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
            u2.ManagerId = userInfo.getUserId();
            u2.BitVoice_Agent_Ext__c = '2222';
            UserList.add(u2);
        insert UserList; 
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        Marketing_Plan__c mp = new Marketing_Plan__c(Active__c = TRUE, Marketing_Plan_Cost__c = 1000000, Start_Date__c = System.Today().addDays(-2), End_Date__c = System.Today().addDays(60));
        insert mp;
        
        Marketing_Channel__c mc = new Marketing_Channel__c(Budget_Allotted__c = 100000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mc;
        
        PropStrength__Advertisement__c advt = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
    
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[1].Id;
        enq.Last_Attempt_Status__c = 'No Contact - Follow-up';
        insert enq;
        
        Day_Tracking__c dayTrack = new Day_Tracking__c();
        dayTrack.Name = 'Day 1';
        dayTrack.Enquiry__c = enq.Id;
        insert dayTrack;
        
        Attempt_Tracking__c attemptRec = new Attempt_Tracking__c();
        attemptRec.Attempt_Sequence__c = '3';
        attemptRec.Day_Tracking__c = dayTrack.Id;
        attemptRec.Name = 'Official Mobile';
        attemptRec.Attempted_By__c = UserInfo.getuserId();
        attemptRec.RecordTypeId = Schema.getGlobalDescribe().get('Attempt_Tracking__c').getDescribe().getRecordTypeInfosByName().get('Official Mobile').getRecordTypeId();
        insert attemptRec;
        
        Test.stopTest();
    }
    public static testMethod void testDailyTrackingThree() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<User> UserList = new List<User>();
        Id proId = [SELECT Id FROM Profile WHERE Name LIKE 'System%'].Id;
        User u = new User(
            ProfileId = proId,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
            u.ManagerId = userInfo.getUserId();
            u.BitVoice_Agent_Ext__c = '1111';
            UserList.add(u);
            User u2 = new User(
            ProfileId = proId,
            LastName = 'last2',
            Email = 'puser000@ama.com',
            Username = 'puser000@ama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST2',
            Title = 'title2',
            Alias = 'alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
            u2.ManagerId = userInfo.getUserId();
            u2.BitVoice_Agent_Ext__c = '2222';
            UserList.add(u2);
        insert UserList; 
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        Marketing_Plan__c mp = new Marketing_Plan__c(Active__c = TRUE, Marketing_Plan_Cost__c = 1000000, Start_Date__c = System.Today().addDays(-2), End_Date__c = System.Today().addDays(60));
        insert mp;
        
        Marketing_Channel__c mc = new Marketing_Channel__c(Budget_Allotted__c = 100000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mc;
        
        PropStrength__Advertisement__c advt = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
    
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[1].Id;
        enq.Last_Attempt_Status__c = 'No Contact - Follow-up';
        enq.PropStrength__Email_Address__c = 'test@test.com';
        insert enq;
        
        Day_Tracking__c dayTrack = new Day_Tracking__c();
        dayTrack.Name = 'Day 1';
        dayTrack.Enquiry__c = enq.Id;
        insert dayTrack;
        
        Attempt_Tracking__c attemptRec = new Attempt_Tracking__c();
        attemptRec.Attempt_Sequence__c = '3';
        attemptRec.Day_Tracking__c = dayTrack.Id;
        attemptRec.Name = 'Email';
        attemptRec.Attempted_By__c = UserInfo.getuserId();
        attemptRec.RecordTypeId = Schema.getGlobalDescribe().get('Attempt_Tracking__c').getDescribe().getRecordTypeInfosByName().get('Email').getRecordTypeId();
        insert attemptRec;
        
        EnquiryNurturingController.loadEmailTemplate(dayTrack.Id);
        EnquiryNurturingController.sendEmailToCustomer(dayTrack.Id);
        
        Test.stopTest();
    }
}
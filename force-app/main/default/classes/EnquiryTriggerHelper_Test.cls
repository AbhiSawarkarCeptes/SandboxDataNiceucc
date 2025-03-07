/*********************************************************************
* Class Name  :   EnquiryTriggerHelper_Test
* Description :   Test Class of EnquiryTriggerHelper
* Created Date:   24/07/2023
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 24/07/2023
                    Deepak Sharma 04/12/2023
*********************************************************************/
@isTest
public class EnquiryTriggerHelper_Test {
    
    
    @testSetup 
    static void testData() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq1  = TestDataFactorySobha.createEnquiry(null);
        enq1.Sales_Manager__c = userInfo.getUserId();
        insert enq1; 
    }
  
    @isTest
    static void testMethod1() {
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
        
        PropStrength__Advertisement__c advt1 = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
         PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Sales_Manager__c = UserList[0].Id;
        enq1.Secondary_Sales_Manager__c = UserList[1].Id;
        insert enq1; 
          Test.startTest();
       PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        //enq.PropStrength__Request_Source__c = 'Web';
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[1].Id;
        enq.PropStrength__Request_Status__c = 'Site Visit Done';
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt1.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Sales_Head__c = UserList[1].Id;
        enq.Sales_Manager__c = UserList[1].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        enq.Secondary_Sales_Manager__c = UserList[0].Id;
        enq.Update_New_Enquiry_Source__c = true;
        
		enq.New_Enquiry_Source_Values__c = 'PropStrength__Enquiry_Type__c:;Broker_Type__c:;PropStrength__Request_Source__c:;Enquiry_Sub_Source__c:;';
        //enq.PropStrength__Request_Source__c = 'Walk-in';
        EnquiryTriggerHelper.dontRun = false;
        try{
            update enq;
            }
        catch(exception e) {
            
        }
        Test.stopTest();
        delete enq;
    } 
    
    @isTest
    static void testMethod2() {
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
        
        PropStrength__Advertisement__c advt1 = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);

        PropStrength__Assignment_Group_Name__c groupName2 = new PropStrength__Assignment_Group_Name__c();
        groupName2.Name = 'Main Queue';
        groupName2.PropStrength__Type__c = 'Enquiry';
        groupName2.PropStrength__Active__c = true;
        grpNameList.add(groupName2);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
        PropStrength__Assignment_Rule_Entry__c ruleEntry1 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry1.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry1.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry1.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Equals Russian)  AND (Enquiry: UTM_Campaign__c Contains YX-, Sobha)';
        ruleEntryList.add(ruleEntry1);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry2 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry2.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry2.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry2.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Equals Investor Relation)';
        ruleEntryList.add(ruleEntry2);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry3 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry3.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry3.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry3.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Not Equal To Investor Relation)';
        ruleEntryList.add(ruleEntry3);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry4 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry4.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry4.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry4.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Starts With Investor Relation)';
        ruleEntryList.add(ruleEntry4);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry5 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry5.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry5.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry5.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Contains Investor Relation)';
        ruleEntryList.add(ruleEntry5);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry6 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry6.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry6.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry6.PropStrength__Criteria__c =  '(Enquiry: Prefered_LAnguage__c Does Not Contains Arabic)';
        ruleEntryList.add(ruleEntry6);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        enq1.Campaign_Name__c = 'Investor ';
        insert enq1; 
        Test.startTest();
       PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        //enq.PropStrength__Request_Source__c = 'Web';
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Campaign_Name__c = 'Investor';
        enq.Secondary_Sales_Head__c = userList[1].Id;
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt1.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Sales_Head__c = UserList[1].Id;
        enq.Sales_Manager__c = UserList[1].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        //enq.PropStrength__Request_Source__c = 'Walk-in';
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod3() {
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
        
        PropStrength__Advertisement__c advt1 = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);

        PropStrength__Assignment_Group_Name__c groupName2 = new PropStrength__Assignment_Group_Name__c();
        groupName2.Name = 'Main Queue';
        groupName2.PropStrength__Type__c = 'Enquiry';
        groupName2.PropStrength__Active__c = true;
        grpNameList.add(groupName2);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
 
        PropStrength__Assignment_Rule_Entry__c ruleEntry1 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry1.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry1.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry1.PropStrength__Criteria__c =  '(Enquiry: Age__c Less Or Equal 25)';
        ruleEntryList.add(ruleEntry1);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry2 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry2.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry2.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry2.PropStrength__Criteria__c =  '(Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry2);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry3 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry3.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry3.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry3.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Includes Investor Relation)';
        ruleEntryList.add(ruleEntry3);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry4 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry4.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry4.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry4.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Excludes Investor Relation)';
        ruleEntryList.add(ruleEntry4);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry5 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry5.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry5.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry5.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Not Equal To Investor Relation)';
        ruleEntryList.add(ruleEntry5);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry6 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry6.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry6.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry6.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Starts With Investor Relation)';
        ruleEntryList.add(ruleEntry6);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        insert enq1; 
        Test.startTest();
       PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        //enq.PropStrength__Request_Source__c = 'Web';
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[1].Id;
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt1.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Sales_Head__c = UserList[1].Id;
        enq.Sales_Manager__c = UserList[1].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        //enq.PropStrength__Request_Source__c = 'Walk-in';
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }
    
     @isTest
    static void testMethod4() {
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
        
        PropStrength__Advertisement__c advt1 = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);

        PropStrength__Assignment_Group_Name__c groupName2 = new PropStrength__Assignment_Group_Name__c();
        groupName2.Name = 'Main Queue';
        groupName2.PropStrength__Type__c = 'Enquiry';
        groupName2.PropStrength__Active__c = true;
        grpNameList.add(groupName2);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry1 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry1.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry1.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry1.PropStrength__Criteria__c =  '(Enquiry: Age__c Less Than 25)';
        ruleEntryList.add(ruleEntry1);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry2 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry2.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry2.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry2.PropStrength__Criteria__c =  '(Enquiry: Age__c Greater Than 25)';
        ruleEntryList.add(ruleEntry2);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        insert enq1; 
        Test.startTest();
       PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[1].Id;
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt1.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Sales_Head__c = UserList[1].Id;
        enq.Sales_Manager__c = UserList[1].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }

    @isTest
    static void testMethod5() {
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
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry1 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry1.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry1.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry1.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Not Equal To Russian)  AND (Enquiry: UTM_Campaign__c Contains YX-, Sobha)';
        ruleEntryList.add(ruleEntry1);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry2 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry2.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry2.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry2.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Starts With Russian)  AND (Enquiry: UTM_Campaign__c Contains YX-, Sobha)';
        ruleEntryList.add(ruleEntry2);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry3 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry3.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry3.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry3.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Contains Russian)  AND (Enquiry: UTM_Campaign__c Contains YX-, Sobha)';
        ruleEntryList.add(ruleEntry3);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry4 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry4.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry4.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry4.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Does Not Contains Russian)  AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry4);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry5 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry5.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry5.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry5.PropStrength__Criteria__c =  '(Enquiry: Age__c Less Than 25) AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry5);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry6 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry6.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry6.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry6.PropStrength__Criteria__c =  '(Enquiry: Age__c Greater Than 25) AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry6);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry7 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry7.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry7.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry7.PropStrength__Criteria__c =  '(Enquiry: Age__c Less Or Equal 25) AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry7);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry8 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry8.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry8.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry8.PropStrength__Criteria__c =  '(Enquiry: Age__c Greater Or Equal 25) AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry8);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry9 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry9.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry9.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry9.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Less Than 2015-07-27;) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry9);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry10 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry10.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry10.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry10.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Greater Than 2015-07-27;) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry10);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry11 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry11.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry11.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry11.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Less Or Equal 2015-07-27;) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry11);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry12 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry12.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry12.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry12.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Greater Or Equal 2015-07-27;) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry12);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry13 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry13.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry13.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry13.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Less Than 2023-10-5 12:20:20;) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry13);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry14 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry14.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry14.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry14.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Greater Than 2023-10-5 12:20:20;) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry14);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry15 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry15.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry15.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry15.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Less Or Equal 2023-10-5 12:20:20;) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry15);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry16 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry16.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry16.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry16.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Greater Or Equal 2023-10-5 12:20:20;) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry16);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        enq1.Birthdate__c = Date.valueof('2016-07-27');
        enq1.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        insert enq1; 
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod6() {
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
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
   
        PropStrength__Assignment_Rule_Entry__c ruleEntry3 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry3.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry3.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry3.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Less Or Equal 2015-07-27)';
        ruleEntryList.add(ruleEntry3);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry4 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry4.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry4.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry4.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Greater Or Equal 2015-07-27)';
        ruleEntryList.add(ruleEntry4);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry5 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry5.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry5.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry5.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Less Than 2023-10-5 12:20:20)';
        ruleEntryList.add(ruleEntry5);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry6 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry6.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry6.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry6.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Greater Than 2023-10-5 12:20:20)';
        ruleEntryList.add(ruleEntry6);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry7 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry7.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry7.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry7.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Less Or Equal 2023-10-5 12:20:20)';
        ruleEntryList.add(ruleEntry7);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry8 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry8.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry8.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry8.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Greater Or Equal 2023-10-5 12:20:20)';
        ruleEntryList.add(ruleEntry8);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        enq1.Birthdate__c = Date.valueof('2016-07-27');
        enq1.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        insert enq1; 
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod7() {
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
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry1 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry1.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry1.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry1.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Less Than 2015-07-27)';
        ruleEntryList.add(ruleEntry1);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry2 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry2.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry2.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry2.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Greater Than 2015-07-27)';
        ruleEntryList.add(ruleEntry2);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry3 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry3.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry3.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry3.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Less Than 2023-10-5 12:20:20)';
        ruleEntryList.add(ruleEntry3);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry4 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry4.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry4.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry4.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Greater Than 2023-10-5 12:20:20)';
        ruleEntryList.add(ruleEntry4);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        enq1.Birthdate__c = Date.valueof('2016-07-27');
        enq1.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        insert enq1; 
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }
    
        @isTest
    static void testMethod8() {
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
        
        PropStrength__Advertisement__c advt1 = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);

        PropStrength__Assignment_Group_Name__c groupName2 = new PropStrength__Assignment_Group_Name__c();
        groupName2.Name = 'Main Queue';
        groupName2.PropStrength__Type__c = 'Enquiry';
        groupName2.PropStrength__Active__c = true;
        grpNameList.add(groupName2);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
        PropStrength__Assignment_Rule_Entry__c ruleEntry1 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry1.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry1.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry1.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Equals Russian)  AND (Enquiry: UTM_Campaign__c Contains YX-, Sobha)';
        ruleEntryList.add(ruleEntry1);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry2 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry2.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry2.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry2.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Equals Investor,  Relation)';
        ruleEntryList.add(ruleEntry2);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry3 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry3.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry3.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry3.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Not Equal To Investor,  Relation)';
        ruleEntryList.add(ruleEntry3);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry4 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry4.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry4.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry4.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Starts With Investor,  Relation)';
        ruleEntryList.add(ruleEntry4);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry5 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry5.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry5.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry5.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Contains Investor,  Relation)';
        ruleEntryList.add(ruleEntry5);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry6 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry6.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry6.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry6.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Does Not Contains Investor,  Relation)';
        ruleEntryList.add(ruleEntry6);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        enq1.Campaign_Name__c = 'Investor ';
        insert enq1; 
        Test.startTest();
       PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        //enq.PropStrength__Request_Source__c = 'Web';
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Campaign_Name__c = 'Investor';
        enq.Secondary_Sales_Head__c = userList[1].Id;
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt1.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Sales_Head__c = UserList[1].Id;
        enq.Sales_Manager__c = UserList[1].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        //enq.PropStrength__Request_Source__c = 'Walk-in';
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod9() {
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
        
        PropStrength__Advertisement__c advt1 = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);

        PropStrength__Assignment_Group_Name__c groupName2 = new PropStrength__Assignment_Group_Name__c();
        groupName2.Name = 'Main Queue';
        groupName2.PropStrength__Type__c = 'Enquiry';
        groupName2.PropStrength__Active__c = true;
        grpNameList.add(groupName2);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
 
        PropStrength__Assignment_Rule_Entry__c ruleEntry1 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry1.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry1.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry1.PropStrength__Criteria__c =  '(Enquiry: Age__c Less Or Equal 25, 26)';
        ruleEntryList.add(ruleEntry1);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry2 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry2.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry2.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry2.PropStrength__Criteria__c =  '(Enquiry: Age__c Greater Or Equal 25, 26)';
        ruleEntryList.add(ruleEntry2);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry3 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry3.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry3.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry3.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Includes Investor Relation)';
        ruleEntryList.add(ruleEntry3);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry4 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry4.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry4.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry4.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Excludes Investor,  Relation)';
        ruleEntryList.add(ruleEntry4);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry5 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry5.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry5.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry5.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Not Equal To Investor,  Relation)';
        ruleEntryList.add(ruleEntry5);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry6 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry6.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry6.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry6.PropStrength__Criteria__c =  '(Enquiry: Campaign_Name__c Starts With Investor,  Relation)';
        ruleEntryList.add(ruleEntry6);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        enq1.Campaign_Name__c = 'Investor';
        insert enq1; 
        Test.startTest();
       PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        //enq.PropStrength__Request_Source__c = 'Web';
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Campaign_Name__c = 'Investor';
        enq.Secondary_Sales_Head__c = userList[1].Id;
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt1.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Sales_Head__c = UserList[1].Id;
        enq.Sales_Manager__c = UserList[1].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        //enq.PropStrength__Request_Source__c = 'Walk-in';
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }
    
     @isTest
    static void testMethod10() {
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
        
        PropStrength__Advertisement__c advt1 = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000, PropStrength__IsActive__c = true);
        insert advt1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);

        PropStrength__Assignment_Group_Name__c groupName2 = new PropStrength__Assignment_Group_Name__c();
        groupName2.Name = 'Main Queue';
        groupName2.PropStrength__Type__c = 'Enquiry';
        groupName2.PropStrength__Active__c = true;
        grpNameList.add(groupName2);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry1 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry1.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry1.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry1.PropStrength__Criteria__c =  '(Enquiry: Age__c Less Than 25, 26)';
        ruleEntryList.add(ruleEntry1);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry2 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry2.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry2.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry2.PropStrength__Criteria__c =  '(Enquiry: Age__c Greater Than 25, 26)';
        ruleEntryList.add(ruleEntry2);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        insert enq1; 
        Test.startTest();
       PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Sales_Head__c = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[1].Id;
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt1.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Sales_Head__c = UserList[1].Id;
        enq.Sales_Manager__c = UserList[1].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }

    @isTest
    static void testMethod11() {
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
        
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Contact Center';
        groupName.PropStrength__Type__c = 'Enquiry';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);
        insert grpNameList;  
        
        PropStrength__Assignment_Rule__c AssignmentRule = new PropStrength__Assignment_Rule__c();
        AssignmentRule.PropStrength__Active__c = true;
        AssignmentRule.Name = 'Enquiry Assignment Group';
        AssignmentRule.PropStrength__Rule_Object__c = 'Enquiry';
        insert AssignmentRule;
        
        List<PropStrength__Assignment_Rule_Entry__c> ruleEntryList = new List<PropStrength__Assignment_Rule_Entry__c>();
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry1 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry1.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry1.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry1.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Not Equal To Russian, Indian)  AND (Enquiry: UTM_Campaign__c Contains YX-, Sobha)';
        ruleEntryList.add(ruleEntry1);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry2 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry2.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry2.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry2.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Starts With Russian, Indian)  AND (Enquiry: UTM_Campaign__c Contains YX-, Sobha)';
        ruleEntryList.add(ruleEntry2);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry3 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry3.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry3.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry3.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Contains Russian, Indian)  AND (Enquiry: UTM_Campaign__c Contains YX-, Sobha)';
        ruleEntryList.add(ruleEntry3);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry4 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry4.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry4.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry4.PropStrength__Criteria__c = '(Enquiry: Prefered_LAnguage__c Does Not Contains Russian, Indian)  AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry4);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry5 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry5.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry5.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry5.PropStrength__Criteria__c =  '(Enquiry: Age__c Less Than 25) AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry5);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry6 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry6.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry6.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry6.PropStrength__Criteria__c =  '(Enquiry: Age__c Greater Than 25, 26) AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry6);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry7 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry7.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry7.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry7.PropStrength__Criteria__c =  '(Enquiry: Age__c Less Or Equal 25, 26) AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry7);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry8 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry8.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry8.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry8.PropStrength__Criteria__c =  '(Enquiry: Age__c Greater Or Equal 25, 26) AND (Enquiry: UTM_Campaign__c Excludes YX-, Sobha)';
        ruleEntryList.add(ruleEntry8);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry9 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry9.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry9.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry9.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Less Than 2015-07-27, 2016-07-27) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry9);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry10 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry10.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry10.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry10.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Greater Than 2015-07-27, 2016-07-27) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry10);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry11 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry11.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry11.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry11.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Less Or Equal 2015-07-27, 2016-07-27) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry11);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry12 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry12.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry12.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry12.PropStrength__Criteria__c =  '(Enquiry: Birthdate__c Greater Or Equal 2015-07-27, 2016-07-27) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry12);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry13 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry13.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry13.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry13.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Less Than 2023-10-5 12:20:20, 2023-10-5 12:20:20) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry13);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry14 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry14.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry14.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry14.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Greater Than 2023-10-5 12:20:20,  2023-10-5 12:20:20) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry14);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry15 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry15.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry15.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry15.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Less Or Equal 2023-10-5 12:20:20, 2023-10-5 12:20:20) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry15);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry16 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry16.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry16.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry16.PropStrength__Criteria__c =  '(Enquiry: Time_of_New_Enquiry__c Greater Or Equal 2023-10-5 12:20:20, 2023-10-5 12:20:20) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry16);
        
        PropStrength__Assignment_Rule_Entry__c ruleEntry17 = new PropStrength__Assignment_Rule_Entry__c();
        ruleEntry17.PropStrength__Assignment_Group__c = groupName.Id;
        ruleEntry17.PropStrength__Assignment_Rule__c = AssignmentRule.Id;
        ruleEntry17.PropStrength__Criteria__c =  '(Enquiry: Prefered_LAnguage__c Includes Russian, Indian) AND (Enquiry: Age__c Greater Or Equal 25)';
        ruleEntryList.add(ruleEntry17);
        insert ruleEntryList;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Project__c = proj.Id;
        enq1.Age__c = 20;
        enq1.Birthdate__c = Date.valueof('2016-07-27');
        enq1.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq1.Prefered_LAnguage__c = 'Russian';
        insert enq1; 
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        enq.Prefered_LAnguage__c = 'Russian';
        insert enq; 
                
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
            
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        EnquiryTriggerHelper.dontRun = true;
        update enq;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod12() {
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
        
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        enq.Prefered_LAnguage__c = 'Russian';
        insert enq; 

        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.PropStrength__Enquiry_Type__c = 'Direct';
        enq.Secondary_Sales_Head__c = userList[0].Id;
        //enq.Broker_Type__c = 'Channel Partner';
        //enq.Enquiry_Source__c = 'Channel Partner';
        //enq.PropStrength__Request_Source__c = 'Channel Partner';
        enq.Enquiry_Sub_Source__c = 'Facebook';
        update enq;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod13() {
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
        
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        enq.Prefered_LAnguage__c = 'Russian';
        insert enq;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Commercial - Units').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Super_Area__c = 10.2);
        insert prop;
        PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
        insert poc;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500, PropStrength__Rate_per_unit_Area__c = 100.00));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        enq.PropStrength__Selected_Property_Ids__c = String.valueOf(prop.Id);
        enq.Input_Value__c = 10;
        enq.Calculated_Value__c = 12;
        enq.Proforma_Invoice_Type__c= 'Unit Price';
        enq.Proforma_Invoice_Sub_Type__c = 'Amount';
        update enq;
        Test.stopTest();
    }
    
     @isTest
    static void testMethod14() {
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
        
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        enq.Prefered_LAnguage__c = 'Russian';
        insert enq;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Commercial - Units').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Super_Area__c = 10.2);
        insert prop;
        PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
        insert poc;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500, PropStrength__Rate_per_unit_Area__c = 100.00));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        enq.PropStrength__Selected_Property_Ids__c = String.valueOf(prop.Id);
        enq.Input_Value__c = 10;
        enq.Calculated_Value__c = 12;
        enq.Proforma_Invoice_Type__c= 'Unit Price';
        update enq;
        Test.stopTest();
    }

     @isTest
    static void testMethod15() {
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
        
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        enq.Prefered_LAnguage__c = 'Russian';
        insert enq;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Commercial - Units').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Super_Area__c = 10.2);
        insert prop;
        PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
        insert poc;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500, PropStrength__Rate_per_unit_Area__c = 100.00));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        enq.PropStrength__Selected_Property_Ids__c = String.valueOf(prop.Id);
        enq.Input_Value__c = 10;
        enq.Calculated_Value__c = 12;
        enq.Proforma_Invoice_Type__c= 'Unit Price';
        enq.Proforma_Invoice_Sub_Type__c = 'Percentage';
        update enq;
        Test.stopTest();
    }

     @isTest
    static void testMethod16() {
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
        
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        enq.Prefered_LAnguage__c = 'Russian';
        insert enq;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Commercial - Units').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Super_Area__c = 10.2);
        insert prop;
        PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
        insert poc;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500, PropStrength__Rate_per_unit_Area__c = 100.00));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        enq.PropStrength__Selected_Property_Ids__c = String.valueOf(prop.Id);
        enq.Input_Value__c = 10;
        enq.Calculated_Value__c = 12;
        enq.Proforma_Invoice_Type__c= 'DLD Amount';
        update enq;
        Test.stopTest();
    }

     @isTest
    static void testMethod17() {
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
        
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        enq.Prefered_LAnguage__c = 'Russian';
        insert enq;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Commercial - Units').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Super_Area__c = 10.2);
        insert prop;
        PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
        insert poc;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500, PropStrength__Rate_per_unit_Area__c = 100.00));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        enq.PropStrength__Selected_Property_Ids__c = String.valueOf(prop.Id);
        enq.Input_Value__c = 10;
        enq.Calculated_Value__c = 12;
        
        update enq;
        Test.stopTest();
    }

    @isTest
    static void testMethod18() {
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
        
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        enq.Prefered_LAnguage__c = 'Russian';
        insert enq; 

        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        enq.PropStrength__Request_Status__c = 'Open';
        enq.Enquiry_Idle_Days__c = 30;
        enq.PropStrength__Primary_Contact__c = cont.Id;
        update enq;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod19() {
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
        
        Test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.Age__c = 20;
        enq.Birthdate__c = Date.valueof('2014-07-27');
        enq.Time_of_New_Enquiry__c = DateTime.newInstance(2024, 3, 4, 21, 2, 2);
        enq.Sales_Head__c = UserList[0].Id;
        enq.Prefered_LAnguage__c = 'Russian';
        enq.Re_Enquiry__c = true;
        insert enq;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Commercial - Units').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Super_Area__c = 10.2);
        insert prop;
        PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
        insert poc;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500, PropStrength__Rate_per_unit_Area__c = 100.00));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        enq.PropStrength__Advertisement__c = advt.Id;
        enq.OwnerId = UserList[0].Id;
        enq.Secondary_Sales_Head__c = userList[0].Id;
        enq.PropStrength__Selected_Property_Ids__c = String.valueOf(prop.Id) + ',' + String.valueOf(prop.Id) ;
        enq.Input_Value__c = 10;
        enq.Calculated_Value__c = 12;
        enq.PropStrength__Request_Status__c = 'Closed/ Lost';
        update enq;
        Test.stopTest();
    }
  
    @isTest
    static void validateBrokerAccountTest(){
        List<PropStrength__Request__c> propStrengthReq = [SELECT Id,OwnerId,Re_Enquiry__c,Owner.Email, PropStrength__Primary_Contact__c,PropStrength__Broker_Account__c 
                                                          FROM PropStrength__Request__c];
        Test.startTest();
        EnquiryTriggerHelper.validateBrokerAccount(propStrengthReq);
        Test.stopTest();                                                      
    }

    @isTest
    static void isTodayWithinRangeTest(){
        Test.startTest();
        EnquiryTriggerHelper.isTodayWithinRange(Date.valueof('2014-07-27'), Date.valueof('2026-07-27'));
        Test.stopTest();                                                      
    }
    
    @isTest
    static void sendEmailToSalesManagerTest(){
        User u = [SELECT Id, Name FROM User LIMIT 1];
        List<PropStrength__Request__c> propStrengthReq = [SELECT Id,OwnerId,Re_Enquiry__c,Owner.Email, PropStrength__Primary_Contact__c,PropStrength__Broker_Account__c, Sales_Manager__c
                                                          FROM PropStrength__Request__c];
        propStrengthReq[0].Sales_Manager__c = u.Id;
        update propStrengthReq;
        Test.startTest();
        Set<Id> enqIds =  new Set<Id>();
        for(PropStrength__Request__c rec : propStrengthReq){
            enqIds.add(rec.Id);
        } 
        EnquiryTriggerHelper.sendEmailToSalesManager(enqIds);
        Test.stopTest();                                                      
    }     
}
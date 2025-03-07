@isTest
public class TestCallOzonetelSchedulerAPI {
    
    @isTest
    public static void testScheduleCall(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;
        
     
        Lead l = new lead();
        l.LastName = 'Test callout';
        l.RDS_Country_Code__c = '+91';
        l.RDS_Country__c = 'India';
        l.MobilePhone = '3423457600';
        l.Project__c = p.Id;  
        //l.RecordTypeId = [Select Id, Name, sObjectType from RecordType where sObjectType='Lead' AND Name='New lead'].Id;
        l.auto_assign__c = true;
        l.Campaign_Code__C = 'camp';
        insert l;
        
        task t = new task();
        t.Subject = 'New Task';
        t.Task_Type__c = 'Presales Call';
        t.activityDate = System.Today();
        t.whoId = l.id;      
        t.call_time__c = TaskManagementServices.FormatTime(system.now());
        t.Call_Attempt_Status__c = 'Follow Up';
        t.Next_Action_Date__c = System.now();
        insert t;
        tskIdSet.add(t.Id);
 
        
        /*
        Lead l4 = new lead();
        l4.LastName = 'Test callout';
        l4.RDS_Country_Code__c = '0091';
        l4.RDS_Country__c = 'United Arab Emirates';
        l4.MobilePhone = '5458238622';
        l4.Project__c = p.Id;  
        l4.auto_assign__c = true;
        l4.Campaign_Code__C = 'camp';
        insert l4;
        
        
        task t4 = new task();
        t4.Subject = 'New Task';
        t4.Task_Type__c = 'Presales Call';
        t4.activityDate = System.Today();
        t4.Call_Proposed_Date_Of_Visit__c = System.Today() + 1;
        t4.whoId = l4.id;      
        t4.call_time__c = TaskManagementServices.FormatTime(system.now());
        t4.Call_Attempt_Status__c = 'Visit proposed';
        t4.Next_Action_Date__c = System.now();
        insert t4;
        tskIdSet.add(t4.Id);
        
        
        Lead l5 = new lead();
        l5.LastName = 'Test callout';
        l5.RDS_Country_Code__c = '0091';
        l5.RDS_Country__c = 'India';
        l5.MobilePhone = '5458238622';
        l5.Project__c = p.Id;  
        l5.auto_assign__c = true;
        l5.Campaign_Code__C = 'camp';
        insert l5;
        
        task t5 = new task();
        t5.Subject = 'New Task';
        t5.Task_Type__c = 'Presales Call';
        t5.activityDate = System.Today();
        t5.whoId = l5.id;      
        t5.call_time__c = TaskManagementServices.FormatTime(system.now());
        t5.Call_Attempt_Status__c = 'No contact';        
        insert t5;
        tskIdSet.add(t5.Id);*/
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
    }
    
    
    @isTest
    public static void testScheduleCall1(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;
        
        Account acc = createPATemplate('TestPA1' , 'testleada3@stetig.in', '564734555', false);
        acc.Country__c= 'United Arab Emirates';
        acc.Country_Code__c = '+971';  
        update acc;
        
        
        List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 1);
        system.debug('Opportunity list :: '+ oList);
        
        Id oppId;
        oppId = oList[0].id;
        
        List<Task>  tList = createTasksForOpp(oppId,1,'Presales Call');
        system.debug('Task list :: '+ tList);
      
        task t4 = new task();
        t4.Subject = 'New Task';
        t4.Task_Type__c = 'Presales Call';
        t4.activityDate = System.Today();
        //t4.Call_Proposed_Date_Of_Visit__c = System.Today() + 2;
        t4.whatId = oList[0].id;      
        t4.call_time__c = TaskManagementServices.FormatTime(system.now());
        t4.Call_Attempt_Status__c = 'Follow up';
        t4.Next_Action_Date__c = System.now()+1;
        insert t4;
        tskIdSet.add(t4.Id);
        
                
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
    }
    
      
     // creates  a person account with the basic parameters
          public static Account createPATemplate(String accName, String Email, String Mobile, Boolean isMaster) {
            
                RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
                Account a = new Account(lastName=accName, personEmail = email, personMobilePhone  = Mobile, RecordType = personAccountRecordType, MasterRecord__c = isMaster, Country__c = 'test');
                
               insert a;
               return a;
           }  
           
           
           
      public static List<Opportunity> createOpptyForAccount(Id  accId, Id ProjId, Integer numOfOpp){
            
        List<Opportunity> oList = new List<Opportunity>();
        Date closeDate; 
        
        for(Integer i =0;i<numOfOpp; i++){
          closeDate = Date.newInstance(2015, 8,29);
            Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Qualification', Amount=5000000, AccountId =accId, LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', Project__c = ProjId,closeDate=System.today()); //S_Budget_In_lacs__c = 5000000,Phone__c = '9876544442'
            oList.add(o);            
        }
        
        insert oList;
        return oList;
      }
      
      
       public static List<Task> createTasksForOpp(Id oppId, Integer NumberofTasks, String TaskType) {
        List<task> tList = new List<task>();
        for(Integer i=0; i<NumberofTasks; i++){
          task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whatId = oppId, call_time__c = TaskManagementServices.FormatTime(system.now()) );
          tList.add(t);
        }
        insert tList;
        return tList;
      }
      
      
        @isTest
    public static void testScheduleCall2(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;
        
       
        
        Lead l2 = new lead();
        l2.LastName = 'Test callout';
        l2.RDS_Country_Code__c = '+971';
        l2.RDS_Country__c = 'United Arab Emirates';
        l2.MobilePhone = '545823865';
        l2.Project__c = p.Id;  
      //  l2.RecordTypeId = [Select Id, Name, sObjectType from RecordType where sObjectType='Lead' AND Name='New lead'].Id;
        l2.auto_assign__c = true;
        l2.Campaign_Code__C = 'camp';
        insert l2;
        
        task t2 = new task();
        t2.Subject = 'New Task';
        t2.Task_Type__c = 'Presales Call';
        t2.activityDate = System.Today();
        t2.whoId = l2.id;      
        t2.call_time__c = TaskManagementServices.FormatTime(system.now());
        t2.Call_Attempt_Status__c = 'Follow Up';
        t2.Next_Action_Date__c = System.now();
        insert t2;
        tskIdSet.add(t2.Id);
        
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
     }
     
     
     
    @isTest
    public static void testScheduleCall3(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;
        
       
        Lead l3 = new lead();
        l3.LastName = 'Test callout';
        l3.RDS_Country_Code__c = '091';
        l3.RDS_Country__c = 'India';
        l3.MobilePhone = '5458238612';
        l3.Project__c = p.Id;  
        l3.auto_assign__c = true;
        l3.Campaign_Code__C = 'camp';
        insert l3;
        
        
        task t3 = new task();
        t3.Subject = 'New Task';
        t3.Task_Type__c = 'Presales Call';
        t3.activityDate = System.Today();
        t3.Call_Proposed_Date_Of_Visit__c = System.Today() + 1;
        t3.whoId = l3.id;      
        t3.call_time__c = TaskManagementServices.FormatTime(system.now());
        t3.Call_Attempt_Status__c = 'Visit Confirmed';
        t3.Next_Action_Date__c = System.now();
        insert t3;
        tskIdSet.add(t3.Id);
        
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
     }
     
     
      @isTest
    public static void testScheduleCall4(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;
        
       
        Lead l3 = new lead();
        l3.LastName = 'Test callout';
        l3.RDS_Country_Code__c = '+971';
        l3.RDS_Country__c = 'United Arab Emirates';
        l3.Phone = '545823861';
        l3.Project__c = p.Id;  
        l3.auto_assign__c = true;
        l3.Campaign_Code__C = 'camp';
        insert l3;
        
        
        task t5 = new task();
        t5.Subject = 'New Task';
        t5.Task_Type__c = 'Presales Call';
        t5.activityDate = System.Today();
        t5.Call_Proposed_Date_Of_Visit__c = System.Today() + 1;
        t5.whoId = l3.id;      
        t5.call_time__c = TaskManagementServices.FormatTime(system.now());
        t5.Call_Attempt_Status__c = 'Visit Confirmed';
        t5.Next_Action_Date__c = System.now();
        insert t5;
        tskIdSet.add(t5.Id);
        
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
     }
     
     
      @isTest
    public static void testScheduleCall6(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;
        
        Account acc = createPATemplate('TestPA1' , 'testleada4@stetig.in', '564734595', false);
        acc.Country__c= 'India';
        acc.Country_Code__c = '+91';  
        update acc;
        
        
        List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 1);
        system.debug('Opportunity list :: '+ oList);
        
        Id oppId;
        oppId = oList[0].id;
        
        List<Task>  tList = createTasksForOpp(oppId,1,'Presales Call');
        system.debug('Task list :: '+ tList);
      
        task t6 = new task();
        t6.Subject = 'New Task';
        t6.Task_Type__c = 'Presales Call';
        t6.activityDate = System.Today();
        t6.Call_Proposed_Date_Of_Visit__c = System.Today() + 2;
        t6.whatId = oList[0].id;      
        t6.call_time__c = TaskManagementServices.FormatTime(system.now());
        t6.Call_Attempt_Status__c = 'Visit proposed';
        t6.Next_Action_Date__c = System.now()+1;
        insert t6;
        tskIdSet.add(t6.Id);
                        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
    }
    
     @isTest
    public static void testScheduleCall7(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;       
        
        
        Lead l5 = new lead();
        l5.LastName = 'Test callout';
        l5.RDS_Country_Code__c = '+91';
        l5.RDS_Country__c = 'India';
        l5.MobilePhone = '5458238552';
        l5.Project__c = p.Id;  
        l5.auto_assign__c = true;
        l5.Campaign_Code__C = 'camp';
        insert l5;
        
        task t5 = new task();
        t5.Subject = 'New Task';
        t5.Task_Type__c = 'Presales Call';
        t5.activityDate = System.Today();
        t5.whoId = l5.id;      
        t5.call_time__c = TaskManagementServices.FormatTime(system.now());
        t5.Call_Attempt_Status__c = 'Follow up';   
        t5.Next_Action_Date__c = System.now()+1;            
        insert t5;
        tskIdSet.add(t5.Id);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
    }
    
    
    @isTest
    public static void testScheduleCall8(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;       
        
        
        Lead l5 = new lead();
        l5.LastName = 'Test callout ++';
        l5.RDS_Country_Code__c = '+091';
        l5.RDS_Country__c = 'India';
        l5.Phone = '5456638622';
        l5.Project__c = p.Id;  
        l5.auto_assign__c = true;
        l5.Campaign_Code__C = 'camp';
        insert l5;
        
        task t5 = new task();
        t5.Subject = 'New Task';
        t5.Task_Type__c = 'Presales Call';
        t5.activityDate = System.Today();
        t5.whoId = l5.id;      
        t5.call_time__c = TaskManagementServices.FormatTime(system.now());
        //t5.Call_Attempt_Status__c = 'Follow up';   
        t5.Next_Action_Date__c = System.now()+1;     
        insert t5;
        tskIdSet.add(t5.Id);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
    }
    
    @isTest
    public static void testScheduleCall9(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;
        
        Account acc = createPATemplate('TestPA1' , 'testleada3@stetig.in', '564734555', false);
        acc.Country__c= 'United Arab Emirates';
        acc.Country_Code__c = '+971';  
        acc.PersonMobilePhone = '';
        update acc;
        
        
        List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 1);
        system.debug('Opportunity list :: '+ oList);
        
        Id oppId;
        oppId = oList[0].id;
        
        List<Task>  tList = createTasksForOpp(oppId,1,'Presales Call');
        system.debug('Task list :: '+ tList);
      
        task t4 = new task();
        t4.Subject = 'New Task';
        t4.Task_Type__c = 'Presales Call';
        t4.activityDate = System.Today();
        //t4.Call_Proposed_Date_Of_Visit__c = System.Today() + 2;
        t4.whatId = oList[0].id;      
        t4.call_time__c = TaskManagementServices.FormatTime(system.now());
        t4.Call_Attempt_Status__c = 'Follow up';
        t4.Next_Action_Date__c = System.now()+1;
        insert t4;
        tskIdSet.add(t4.Id);
        
                
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
    }
    @isTest
    public static void testScheduleCall10(){
        
       /* WebEngagementAuthDetails__c setting = new WebEngagementAuthDetails__c();
        setting.Name = 'Auth';
        setting.License__c = '~c2ab30b6';
        setting.API_Key__c = 'ef503ec8-905f-418d-b1ab-3940ad94886d';
        insert setting;*/
        
        Set<Id> tskIdSet = new Set<Id>();
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        User a1 =TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@test.com', 'galvatron1@test.com');
        a1.OzoneTel_AgentId__c = 'testStetig';
        update a1;
        
        Account acc = createPATemplate('TestPA1' , 'testleada3@stetig.in', '564734555', false);
        acc.Country__c= 'United Arab Emirates';
        acc.Country_Code__c = '+971';  
        //acc.PersonMobilePhone = '';
         acc.Phone = '564734555';
         update acc;
        
        
        List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 1);
        system.debug('Opportunity list :: '+ oList);
        
        Id oppId;
        oppId = oList[0].id;
        
        List<Task>  tList = createTasksForOpp(oppId,1,'Presales Call');
        system.debug('Task list :: '+ tList);
      
        task t4 = new task();
        t4.Subject = 'New Task';
        t4.Task_Type__c = 'Presales Call';
        t4.activityDate = System.Today();
        //t4.Call_Proposed_Date_Of_Visit__c = System.Today() + 2;
        t4.whatId = oList[0].id;      
        t4.call_time__c = TaskManagementServices.FormatTime(system.now());
        t4.Call_Attempt_Status__c = 'Follow up';
        t4.Next_Action_Date__c = System.now()+1;
        insert t4;
        tskIdSet.add(t4.Id);
        
                
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        CallOzonetelSchedulerAPI.scheduleCall(tskIdSet);
        
    }
    
}
@isTest
public class TaskManagementServices_Test {

    @testSetup static void createData(){
        User usr = TestDataFactorySobha.createUser(null);
        insert usr;
        
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;
        
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        
        Assignment_Group_Name__c groupName = new Assignment_Group_Name__c();
        groupName.Name = 'Normal Agent Group';
        insert groupName;
        
        Assignment_Groups__c assignmentGroup = new Assignment_Groups__c();
        assignmentGroup.Name = 'Test';        
        assignmentGroup.User__c = usr.Id;
        assignmentGroup.Active__c = 'true';
        assignmentGroup.Group_Name__c = groupName.Id;
        insert assignmentGroup;

        PropStrength__Request__c req = TestDataFactorySobha.createEnquiry(null);
        insert req;
    }
    
    @isTest static void updateStatusOnEnquiryTest(){
        Lead l = new lead();
        l.LastName = 'Test callout';
        l.RDS_Country_Code__c = '+91';
        l.RDS_Country__c = 'India';
        l.RDS_Email__c = 'test@email.com';
        l.RDS_Mobile__c = '99999';
        l.Budget_In_Lacs__c = '1';
        l.MobilePhone = '3423457600';
        l.auto_assign__c = true;
        l.Campaign_Code__C = 'camp';
        l.description__c = 'Test description';
        l.web_banner_source__c = 'src';
        l.web_banner_size__c = '1';
        l.IP_address_web2lead__c = 'address';
        l.leadSource = 'Digital';
        l.Lead_Sub_Source__c = 'inbound-emailer';
        l.UTM_Campaign__c = 'camp';
        l.UTM_Medium__c = 'medium';
        l.UTM_Source__c = 'src';
        l.UTM_Term__c = 'term';
        l.Special_Request_Info__c = 'req';
        l.Web_Source__c = 'src';
        l.Adgroup__c = 'grp';
        l.Goal__c = 'goal';
        l.Digital_Source__c = '12';
        l.Channel_Cluster__c ='clusetr';
        l.Keyword__c = 'key';
        l.Adposition__c = 'adp';
        l.Placement__c = 'pl';
        l.Matchtype__c = 'match';
        l.Bid_Type__c = 'bid';
        l.UTM_Content__c = 'con';
        l.Last_Mile_Conversion__c = 'milestone';
        l.Device__c = 'laptop';
        l.OS__c = '11';
        l.Resolution__c = '11';
        l.Browser__c = '11';
        l.GCLID__c = '12';
        l.Time_Spent_before_Form_Submit__c='20';
        l.Landing_Page_URL__c = '/.com';
        l.Website_Language__c = 'En';
        l.Interested_In__c = 'Int';
        l.Date_of_Visit__c= Date.Today();
        l.HH__c = '12';
        l.MM__c = '1';
        insert l;
        
        PropStrength__Request__c req = [SELECT Id FROM PropStrength__Request__c LIMIT 1];
        Map<Id,String> enqToCallStatus = new Map<Id,String>{req.Id => 'Qualified;Follow-up'};
        Map<Id,Lead> enquiriesMap = new Map<Id,Lead>{l.Id => l};
        Test.startTest();
        
        TaskManagementServices.updateStatusOnEnquiry(enqToCallStatus);
        try{
            TaskManagementServices.createTaskforEnquiries(enquiriesMap);  
        } catch(Exception ex) {}
        
        TaskManagementServices.updateLastCallStatusOnLead(new List<Lead>{l});  
        TaskManagementServices.isRevisit(l.Id); 
        TaskManagementServices.isFirstVisit(l.Id);  
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        try{
           TaskManagementServices.getTaskByType('','','','', acc.Id);
        }catch(Exception e){}
        try{
           TaskManagementServices.getTaskByType('Site Visit', 'ALL', 'createdDate', 'DES', acc.Id);
        }catch(Exception e){}
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.Today().addDays(2);
        opp.StageName = 'Followup';  
        opp.AccountId = acc.Id;
        insert opp;        
        
        Task presalesTask = new Task(
            WhatId = opp.Id,
            Subject = 'Presales Call',
            Task_Type__c = 'Presales Call',
            ActivityDate = Date.today().addDays(-1),
            Call_Attempt_Status__c = 'Completed',
            Sub_Dispositions__c = 'Interested',
            Next_Action_Date__c = Date.today().addDays(2),
            Call_Proposed_Date_Of_Visit__c = Date.today().addDays(5),
            Status = 'Completed',
            Priority = 'Normal'
        );
        insert presalesTask;
        
        Task tobj = new Task();
        tobj.WhatId = req.Id;
        tobj.Task_Type__c ='Home Loan';
        tobj.Call_Attempt_Status__c = 'In progress';
        insert tObj;
        
        tobj.Call_Attempt_Status__c = 'Completed';
        update tObj;
        
        Task tobj2 = new Task();
        tobj2.WhatId = Opp.Id;
        tobj2.Task_Type__c ='Sales Call';
        tobj2.Call_Attempt_Status__c = 'No Contact'; 
        insert tObj2;
        
        Task tobj3 = new Task();
        tobj3.whoId = l.Id;
        tobj3.Task_Type__c = 'Sales Call';
        tobj3.Call_Attempt_Status__c = 'No Contact';        
        insert tObj3;
        
        Task tobj4 = new Task();
        tobj4.whoId = l.Id;
        tobj4.Task_Type__c = 'Presales Call';
        tobj4.Call_Attempt_Status__c = 'No Contact';        
        insert tObj4;
        
        Task tobj5 = new Task();
        tobj5.WhatId = Opp.Id;
        tobj5.Task_Type__c ='Site Visit';
        insert tObj5;
        
        tobj5.Next_Action_Date__c = System.Today();
        tobj5.Status = 'Completed';
        update tobj5;
        
        TaskManagementServices.getTaskByTypeLead('Home Loan', 'ALL', 'Task_Type__c ','ASC', opp.id);
        TaskManagementServices.getTaskByTypeLead('Home Loan', 'Open', 'Task_Type__c ','ASC', opp.id);          
        try{
           TaskManagementServices.getTaskByTypeLead('', '', 'Task_Type__c ','ASC', opp.id);  
        }catch(Exception e){}                     
        try{
           TaskManagementServices.getTaskByTypeLead('Home Loan', 'All', 'Task_Type__c ','ASCD', opp.id); 
        }catch(Exception e){}
        try{
           TaskManagementServices.latestTaskRollupToLead(new List<Task>{tObj3}); 
        }catch(Exception e){}  
        try{
            TaskManagementServices.latestTaskRollupToOpp(new List<Task>{tObj2});  
        }catch(Exception e){}           
        
        TaskManagementServices.latestTaskRollupToOpp(new List<Task>{presalesTask}); 
        TaskManagementServices.latestTaskRollupToOpp(new List<Task>{tObj5}); 
        
        TaskManagementServices.incrementNoContactCounter(new List<Task>{tObj3}); 
        TaskManagementServices.latestTaskRollupToLead(new List<Task>{tObj4});
        TaskManagementServices.setZeroNoContactCounter(new List<Task>{tObj3}); 
        TaskManagementServices.processReEnquiryTasks(new List<Task>{tObj3}, new Map<String, Task>{l.Id => tObj3}); 
        TaskManagementServices.processEnquiriesOnOpportunity(new list<Opportunity>{opp});

        delete opp;
        TaskManagementServices.processEnquiriesOnOpportunity(new list<Opportunity>{opp});          
        Test.stopTest();
    }   
    
    @isTest static void rollUpCampaignCodeToAccountTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account acc2 = TestDataFactorySobha.createAccount(null);
        insert acc2;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.Today().addDays(2);
        opp.StageName = 'Followup';    
        insert opp; 
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp2';
        opp2.CloseDate = Date.Today().addDays(2);
        opp2.StageName = 'Followup';    
        insert opp2;   
        
        Task tobj1 = new Task();
        tobj1.WhatId = acc.Id;
        tobj1.Task_Type__c ='Sales Call';
        insert tObj1;
        
        Task tobj2 = new Task();
        tobj2.WhatId = acc2.Id;
        tobj2.Task_Type__c ='Sales Call';
        insert tObj2;
        
        Task tobj3 = new Task();
        tobj3.WhatId = Opp.Id;
        tobj3.Task_Type__c ='Sales Call';
        insert tObj3;
        
        Task tobj4 = new Task();
        tobj4.WhatId = Opp2.Id;
        tobj4.Task_Type__c ='Sales Call';
        insert tObj4;
        
        Lead l = new lead();
        l.LastName = 'Test callout';
        l.RDS_Country_Code__c = '+91';
        l.RDS_Country__c = 'India';
        l.RDS_Email__c = 'test@email.com';
        l.RDS_Mobile__c = '99999';
        l.Budget_In_Lacs__c = '1';
        l.MobilePhone = '3423457600';
        l.auto_assign__c = true;
        l.Campaign_Code__C = 'camp';
        l.description__c = 'Test description';
        l.OwnerId = UserInfo.getUserId();
        
        Test.startTest();
        TaskManagementServices.rollUpCampaignCodeToAccount(new List<Task>{tObj1, tObj2, tObj3, tObj4});
        TaskManagementServices.createTaskforEnquiries(new Map<Id,Lead>{acc.Id => l});  
		TaskManagementServices.latestTaskRollupToBooking(new List<Task>{tObj1, tObj2, tObj3, tObj4}); 
        TaskManagementServices.HomeLoanTaskRollupToOpp(new List<Task>{tObj1, tObj2, tObj3, tObj4});
        Test.stopTest();        
    }
}
@isTest
public class TestLeadTrigger {
    
    @isTest
    public static void TestLeadTrigger(){
          Test.setMock(HttpCalloutMock.class, new WebEngageMockData.MockHttpResponseGenerator());
       Test.startTest();
        Project__c p =new Project__c();
        p.Name='Test Project';
        p.City__c = 'Test ProjectCity';
        p.PossessionRequirement__c = 'Ready to Move in';
        p.Configuration__c = '3 BHK';
        p.Max_Budget__c = 100;
        p.Min_Budget__c = 10;
        p.Project_Code__c = 'Test';
        p.Expiry_Days__c = 10;
        insert p;
       
        Campaign c = new Campaign();
        c.Name = 'Test Campaign';
        insert c;
        /*Lead_Hoping_Settings__c myCS2 = new Lead_Hoping_Settings__c();
        myCS2.Name='Lead hoping Queue Name';
        myCS2.Value__c ='TestQueue';
        Group g1 = new Group(Name=myCS2.Value__c, type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        insert q1;*/
        User user1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron12@radius.com', 'galvatron12@radius.com');
        List<group> superAgentEnglishQueue = [SELECT ID,DeveloperName  FROM group WHERE  DeveloperName = 'Telesales_Agent'];
        string queueId = superAgentEnglishQueue[0].id;
        Assignment_Group_Name__c agn = new Assignment_Group_Name__c();
        agn.Name = 'test';
        agn.Type__c = 'lead';
        //agn.CurrencyIsoCode = 'AED';
        insert agn;
        
        Assignment_Group_Queues__c ag = new Assignment_Group_Queues__c();
        ag.Name = 'telesales';
        ag.QueueId__c = queueId;
        ag.Type__c = 'Lead';
        //ag.CurrencyIsoCode = 'AED';
        ag.Active__c = 'true';
        ag.Assignment_Group_Name__c = agn.Id;
        insert ag;
        
        Assignment_Groups__c agr = new Assignment_Groups__c();
        agr.Group_Name__c = agn.id;
        agr.Active__c = 'true';
        agr.Millisecond__c = 34;
        //agr.CurrencyIsoCode = 'AED';
        agr.User__c = user1.id;
        insert agr;
        
        Lead l1 = new Lead();
        l1.lastname='Test1';
        l1.MobilePhone = '01234567891';
        l1.Phone = '01234567891';
        l1.Project__c =p.ID;
        l1.RDS_Country__c ='Test India';
        l1.Campaign_Code__c='Test Campaign';
        //l1.Presales_Agent__c = q1.id;
        l1.ownerId = queueId;
        l1.RDS_Country_Code__c = '+9710';
        insert l1;
        l1.Last_Call_Attempt_Status__c = 'Follow up';
         l1.status ='Qualified';
       update l1;
        
        /*User user1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@radius.com', 'galvatron1@radius.com');
        
        Assignment_Group_Name__c groupName = new Assignment_Group_Name__c();
        groupName.Name = myCS2.Value__c;
        insert groupName;
        
        Assignment_Groups__c assignmentGroup = new Assignment_Groups__c();
        assignmentGroup.User__c = user1.Id;
        assignmentGroup.Active__c = 'true';
        assignmentGroup.Name = myCS2.Value__c;
        assignmentGroup.Group_Name__c = groupName.Id;
        */
        l1.lastname='Test2';
        l1.Campaign_Code__c='Test Campaign 1';
		l1.MobilePhone = '012345 67891';  
        l1.Phone = '0123456 7891';
        l1.RDS_Country_Code__c = '+9810';
        update l1;
        LeadTriggerHandler.insertErrorLog('test','test','test','test','test');
        // Set up mock callout
        WebEngageUtility.createLog( 'errorMsg',l1.Id, 'className');
      

       Test.stopTest();
    } 
    @isTest
    
    public static void TestLeadTrigger1(){  
          Test.setMock(HttpCalloutMock.class, new WebEngageMockData.MockHttpResponseGenerator());
      Test.startTest();
        
        Project__c p1 =new Project__c();
        p1.Name='Test Project 1';
        p1.City__c = 'Test ProjectCity 1';
        p1.PossessionRequirement__c = 'Ready to Move in';
        p1.Configuration__c = '3 BHK';
        p1.Max_Budget__c = 100;
        p1.Min_Budget__c = 10;
        p1.Project_Code__c = 'Test';
        p1.Expiry_Days__c = 10;
        insert p1;
        
        Lead l2 = new Lead();
        l2.lastname='Test 4';
        l2.MobilePhone = '1234567890';
        l2.Project__c =p1.ID;
        l2.RDS_Country__c ='Test India';
        insert l2;
        
       
        
        try{
        
        
       
            
        Lead l3= new Lead();
        l3.lastname='Test 6';
        l3.MobilePhone = '1234567890';
        l3.Project__c =p1.ID;
        l3.RDS_Country__c ='Test India';
        insert l3;
        
      /*  l3.lastname='Test7';
        l3.Campaign_Code__c='Test Campaign 3';
        l3.MobilePhone = '1234567890';
        update l3; */
        }catch(GlobalException ex){
             System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
        } 
      Test.stopTest();
      }   
    
     @isTest  
    public static void TestLeadTrigger2(){  
          Test.setMock(HttpCalloutMock.class, new WebEngageMockData.MockHttpResponseGenerator());
      Test.startTest();
        
        Project__c p2 =new Project__c();
        p2.Name='Test Project 2';
        p2.City__c = 'Test ProjectCity 2';
        p2.PossessionRequirement__c = 'Ready to Move in';
        p2.Configuration__c = '3 BHK';
        p2.Max_Budget__c = 100;
        p2.Min_Budget__c = 10;
        p2.Project_Code__c = 'Test';
        p2.Expiry_Days__c = 10;
        insert p2;
        
        Lead l4 = new Lead();
        l4.lastname='Test 4';
        l4.MobilePhone = '2234567890';
        l4.Project__c =p2.ID;
        l4.RDS_Country__c ='Test India';
        insert l4;
        
        
        
        try{
        
             
       /* Lead l5= new Lead();
        l5.lastname='Test 6';
        l5.MobilePhone = '2224567890';
        l5.Project__c =p2.ID;
        l5.RDS_Country__c ='Test India';
        insert l5;*/
    
        //l5.lastname='Test8';
        //l5.Campaign_Code__c='Test Campaign 8';
        l4.MobilePhone = '2234567890';
        update l4;
        }catch(GlobalException ex){
             System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
        } 
      Test.stopTest();
      }   
      
  
      
    }
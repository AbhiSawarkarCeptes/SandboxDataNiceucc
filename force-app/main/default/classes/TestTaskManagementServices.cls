@isTest
private  Class TestTaskManagementServices {
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"Test":"Test"}');
            return res;
        }
    }
    
    public static boolean firstRun = true;

  @isTest  
  static void TaskTest() {
    Project__c p = createProject('Xa_prj','111');
    Account acc = createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
               
    List<Lead> llist = createLead(3);
    List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 3);

//// Presales Call rollup on Opty      
      task t = new task();
      t.Subject = 'New Task';
      t.Task_Type__c = 'Sales Call';
      t.Call_Attempt_Status__c = 'No Contact';
      t.Next_Action_Date__c = System.today().adddays(5);
      t.activityDate = System.Today();
      t.whatId = oList[0].Id;
      t.UTM_Campaign__c = 'test';
      t.call_time__c = TaskManagementServices.FormatTime(system.now());
      insert t;
      
      task t1 = new task();
      t1.Subject = 'New enquiry Task';
      t1.Task_Type__c = 'Site Visit';
      t1.activityDate = System.Today();
      t1.whatId = oList[1].Id;
      t1.UTM_Campaign__c = 'test';
      t1.call_time__c = TaskManagementServices.FormatTime(system.now());
      insert t1;
      
      
      t.Call_Attempt_Status__c = 'RNR';
      update t;
      
     
      
//// Sales Call roll up on Opty      
      task t2 = new task();
      t2.Subject = 'New Task';
      t2.Task_Type__c = 'Sales Call';
      t2.Call_Attempt_Status__c = 'No Contact';
      t2.Next_Action_Date__c = System.today().adddays(5);
      t2.activityDate = System.Today();
      t2.whatId = oList[0].Id;
      t2.UTM_Campaign__c = 'test';
      t2.call_time__c = TaskManagementServices.FormatTime(system.now());
      insert t2;
      
      Test.startTest(); 
      Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
      List<Task> tList11 = createTasksForLead(lList[0].Id, 2, 'Presales');
      tList11[0].Call_Attempt_Status__c = 'No Contact';
      tList11[0].Next_Action_Date__c = System.today().adddays(5);
      update tList11[0];
      
      List<Task> tList22 = createTasksForLead(lList[1].Id, 2, 'Enquiry Received');
    
      List<Opportunity> updatedOList = [Select Id, Presales_Call_counter__c from Opportunity where Id = :oList[0].Id];      
      List<Opportunity> updatedOList1 = [Select Id, visit_counter__c from Opportunity where Id = :oList[1].Id];  
      
      list<Task> reEnquiryTasks = new list<Task>();
      map<string,Task> leadIdToTask = new map<string,Task>();
      reEnquiryTasks.add(t2);
      leadIdToTask.put(lList[0].Id,t2);
      TaskManagementServices.processReEnquiryTasks(reEnquiryTasks,leadIdToTask);
      TaskManagementServices.prepareErrorLog('test','test','test','test','test');
      TaskManagementServices.prepareErrorLog('test','test','testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest','test','test');
      Test.stopTest(); 
  }
  
  public static Project__c createProject(String ProjName, String ProjectCode){
        Project__c objProject = new Project__c(Name = ProjName, Project_Code__c = projectCode);
        insert objProject;
        return objProject;
    }
    
    public static Account createPATemplate(String accName, String Email, String Mobile, Boolean isMaster) {
    List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
    Account a = new Account(lastName=accName, personEmail = email, personMobilePhone= Mobile, RecordTypeId = personAccountRecordType[0].id, MasterRecord__c = isMaster);
    insert a;
    return a;
  }
  
  public static List<Lead> createLead(Integer numofLeads) {
    List<Lead> leads = new List<Lead>();
        for(Integer i=0; i<numofLeads; i++) {            
            Lead l = new Lead(firstName = 'first' , lastName='radiusLead' + i, Email='radiuslead' +i +'@radiustest.com' , mobilePhone='123456789' + i);            
            leads.add(l);
        }
        insert leads;
        return leads;  
  }
  
   public static List<Opportunity> createOpptyForAccount(Id  accId, Id ProjId, Integer numOfOpp){
    List<Opportunity> oList = new List<Opportunity>();
    Date closeDate; 
    for(Integer i =0;i<numOfOpp; i++){
      closeDate = Date.newInstance(2015, 8,29);
      Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Opportunity Identified', Amount=5000000, AccountId =accId, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', S_Budget_In_lacs__c = 5000000, Project__c = ProjId,closeDate=System.today());
      oList.add(o);            
    }
    insert oList;
    return oList;
  }
  
   public static List<Task> createTasksForLead(Id leadId, Integer NumberofTasks, String TaskType) {
    List<task> tList = new List<task>();
    
    for(Integer i=0; i<NumberofTasks; i++){
      task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whoId = leadId, call_time__c = TaskManagementServices.FormatTime(system.now()) );
      tList.add(t);
    }
    insert tList;
    return tList;
  }
  
  @isTest  
  static void TaskTest2222() {
    Account acc = new Account();
    acc.LastName='Test Acc';  
    acc.AccountNumber='TestAcc101';
    acc.PersonMobilePhone = '1234567890';
    acc.PersonEmail = 'test@test.in';
    List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
    acc.RecordTypeId = personAccountRecordType[0].id; 
    insert acc;
    
    Opportunity opp=new Opportunity();
    opp.Name='Test Opp';
    opp.CloseDate=Date.Today().addDays(10);
    opp.StageName='Followup';    
    insert opp;        
       
    Task tobj=new Task();
    tobj.WhatId=Opp.Id;
    tobj.Task_Type__c ='Home Loan';
    insert tObj;
    
    List<Task> tlist= new List<Task>();
    tlist.add(tobj);
    TaskManagementServices.HomeLoanTaskRollupToOpp(tList);
    
    Task tobj2=new Task();
    tobj2.WhatId=Opp.Id;
    tobj2.Task_Type__c ='Registration';
    tobj2.UTM_Campaign__c = 'test';
    insert tObj2;
        
   tlist.add(tobj2);
   TaskManagementServices.RegTaskRollupToOpp(tList);
   TaskManagementServices.getTaskByTypeLead('Home Loan', 'Open', 'Task_Type__c ','ASC', opp.id);  
   }
     
    @isTest
    private static void TaskPageTest() {
      Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
      Account acc = createPATemplate('TestPA1' , 'testleada@radiustest.com', '9876544441', false);
      Project__c p = createProject('ONE BKC','111');
      List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 1);                     
      
      Lead l = createLeadTemplate('BigLead', 'biglead@email.com', '1234567890', false);
      l.Status = 'Book Site Visit - Visit Confirmed'; // Neha
      update l;
      lead cLead = convertLead(l); 
      
      Map<String,Id> recordIdMap = new Map<String,Id>();
      recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
      
      Quotation__c q = new Quotation__c();
      q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
      q.Unit__c = recordIdMap.get('UNIT');
      q.Payment_Plan__c = recordIdMap.get('PLAN');
      insert q; 
     
      Booking__c b = new Booking__c();
      b.Booking_Date__c = System.today().addDays(-10);
      b.Project__c = recordIdMap.get('PROJECT');
      b.Tower__c = recordIdMap.get('TOWER');
      b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
      b.Quotation__c = q.Id;
      b.Unit__c = recordIdMap.get('UNIT');
      b.Agreement_Value__c = 6000000;
      insert b;
      
      PageReference pRef = Page.CallAttemptEditPage2;
      Test.setCurrentPage(pRef);
      ApexPages.currentPage().getParameters().put('retURL',cLead.ConvertedOpportunityId);
      ApexPages.currentPage().getParameters().put('cancelURL',cLead.ConvertedOpportunityId);
      ApexPages.currentPage().getParameters().put('origin','New Call Attempt');
      ApexPages.currentPage().getParameters().put('who_id',cLead.Id);
      ApexPages.currentPage().getParameters().put('what_id',cLead.ConvertedOpportunityId); 
      ApexPages.currentpage().getparameters().put('bookingId', b.Id);  
      Task t = new Task();
        Test.startTest();
      ApexPages.StandardController sc = new ApexPages.StandardController(t);
      CustomTaskControllerClass tExtn = new CustomTaskControllerClass(sc);
      tExtn.save();
     //// tExtn.Savedoc();
      
      PageReference pRef1 = Page.CallAttemptEditPage2;
      Test.setCurrentPage(pRef1);
      ApexPages.currentPage().getParameters().put('retURL',cLead.ConvertedOpportunityId);
      ApexPages.currentPage().getParameters().put('cancelURL',cLead.ConvertedOpportunityId);
      ApexPages.currentPage().getParameters().put('origin','New Call Attempt');
      ApexPages.currentPage().getParameters().put('who_id',cLead.Id);
      ApexPages.currentpage().getparameters().put('bookingId', b.Id);  
      Task t1 = new Task();
      ApexPages.StandardController sc1 = new ApexPages.StandardController(t1);
      CustomTaskControllerClass tExtn1 = new CustomTaskControllerClass(sc1);  
      tExtn1.cancel();  
      PageReference pRef2 = Page.CallAttemptEditPage2;
      Test.setCurrentPage(pRef2);
      ApexPages.currentPage().getParameters().put('retURL',cLead.ConvertedOpportunityId);     
      Task t2 = new Task();
      ApexPages.StandardController sc2 = new ApexPages.StandardController(t2);
      CustomTaskControllerClass tExtn2 = new CustomTaskControllerClass(sc2);     
      Test.stopTest();
 }
 
   public static Lead createLeadTemplate(String lastName, String email, String mobile, Boolean isMaster) {
        Lead l = new Lead(firstName ='first', lastName= lastName, Email= email , mobilePhone= mobile, MasterRecord__c = isMaster, Company='test');
        insert l;
        return l;  
  }
  
  public static Lead convertLead(Lead l) {
    LeadStatus convertStatus = [
            select MasterLabel
            from LeadStatus
            where IsConverted = true
            limit 1];
       List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
       if (!l.isConverted) {
            Database.LeadConvert lc = new Database.LeadConvert();
            String oppName = l.Name;
             lc.setLeadId(l.Id);
             lc.setOpportunityName(oppName);
             lc.setConvertedStatus(convertStatus.MasterLabel);
             leadConverts.add(lc);
        }
       if (!leadConverts.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
       }
       lead clead = [Select Id, ConvertedAccountId, ConvertedOpportunityId, IsConverted from Lead where id = :l.Id];
       return clead;
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
  static void TestEnquiryMethods() {
      	Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
          Project__c p = createProject('Test_prj','111');
          Lead l2 = createLeadTemplate('BigLead2`', 'biglead2@email.com', '1234567897', false);
          l2.RDS_Email__c = 'test@test.in';
          l2.RDS_Country__c = 'India';
          l2.RDS_Country_Code__c = '91';
          l2.RDS_Mobile__c = '1258745210';
          l2.Budget_In_Lacs__c = '0.5 to 1';
          l2.Source_Remarks__c = 'test';
          l2.Project__c = p.id;
          
          l2.web_banner_source__c = 'test';
          l2.web_banner_size__c = 'test';
          l2.IP_address_web2lead__c = 'test';
          l2.UTM_Campaign__c= 'test';
          l2.UTM_Display__c= 'test';
          l2.UTM_Medium__c= 'test';
          l2.UTM_Source__c= 'test';
          l2.UTM_Term__c= 'test';
          l2.description__c = 'Test'; // Neha
          l2.leadSource = 'Digital'; // Neha
          l2.Lead_Sub_Source__c = 'Website'; // Neha
          l2.Special_Request_Info__c = 'Book an appointment'; // Neha          
          l2.Web_Source__c = 'test';  // Neha 
          l2.Adgroup__c = 'test';  // Neha 
          l2.Goal__c = 'test';  // Neha 
          l2.Digital_Source__c = 'test';  // Neha 
          l2.Channel_Cluster__c = 'test';  // Neha 
          l2.Keyword__c = 'Test'; // Neha
          l2.Placement__c = 'Digital'; // Neha
          l2.Adposition__c = 'Website'; // Neha
          l2.Matchtype__c= 'Test'; // Neha          
          l2.network__c = 'test';  // Neha 
          l2.Bid_Type__c = 'test';  // Neha 
          l2.UTM_Content__c = 'test';  // Neha 
          l2.Lead_Source__c = 'Digital';  // Neha 
          l2.Last_Mile_Conversion__c = 'test';  // Neha 
          l2.Device__c = 'Laptop'; // Neha
          l2.OS__c = 'Windows'; // Neha
          l2.Resolution__c = '2408'; // Neha
          l2.Browser__c = 'Chrome'; // Neha          
          l2.GCLID__c = 'test';  // Neha 
          l2.Time_Spent_before_Form_Submit__c = '2';  // Neha 
          l2.Landing_Page_URL__c = 'www.sobharealty.com'; // Neha
          l2.Interested_In__c = 'Villa'; // Neha
          l2.Date_of_Visit__c = System.today(); // Neha
          l2.HH__c = '12'; // Neha
          l2.MM__c = '15';  // Neha 
          l2.Website_Language__c = 'en'; // Neha
          l2.Count_of_Non_Contactable_Calls__c = null;
          update l2;
          map<id,lead> leadMap = new map<id,lead>();
          leadmap.put(l2.id, l2);
          TaskManagementServices.createTaskforEnquiries(leadMap);
          TaskManagementServices.updateLastCallStatusOnLead(leadMap.values());
  } 
  
  @isTest
  private static void testbookingRollUpMethod(){
      
      Map<String,Id> recordIdMap = new Map<String,Id>();
      Id RecordTypeId;
      if(Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collection') != null)
          RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
      recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
      
      Quotation__c q = new Quotation__c();
      q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
      q.Unit__c = recordIdMap.get('UNIT');
      q.Payment_Plan__c = recordIdMap.get('PLAN');
      insert q; 
     
      Booking__c b = new Booking__c();
      b.Booking_Date__c = System.today().addDays(-10);
      b.Project__c = recordIdMap.get('PROJECT');
      b.Tower__c = recordIdMap.get('TOWER');
      b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
      b.Quotation__c = q.Id;
      b.Unit__c = recordIdMap.get('UNIT');
      b.Agreement_Value__c = 6000000;
      insert b;
      
      Task t = new Task();
      t.Task_Type__c = 'Post Sales Call';
      t.Booking__c = b.Id;
      t.WhatId = recordIdMap.get('OPPORTUNITY');
      t.UTM_Campaign__c = 'test';
      if(RecordTypeId != null){
          t.RecordTypeId = RecordTypeId;
      }
      t.Subject = 'Post Sales Call';
      t.Call_Attempt_Status__c = 'Follow up';
      t.Next_Action_Date__c = System.today().addDays(5);
      insert t;         
  }
    
     @isTest  
    static void TestRollupOnOppty() {
        
        Project__c pro = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert pro;
        // Create Parent Campaign
        //Campaign camparent = TestDataFactory.createCampaignCC('Test Parent Camp', 'Digital', System.Today(), System.today().addDays(7));
        
        // Create Child Campaign
        //Campaign camchild = TestDataFactory.createCampaignCCNew('Test Child Camp', pro.Id, System.Today(), System.today().addDays(7),camparent.Id);
        
        Lead l = new lead();
        l.LastName = 'Test callout';
        l.RDS_Country_Code__c = '+91';
        l.RDS_Country__c = 'India';
        l.MobilePhone = '3423457600';
        l.Project__c = pro.Id;  
        //l.RecordTypeId = [Select Id, Name, sObjectType from RecordType where sObjectType='Lead' AND Name='New lead'].Id;
        l.auto_assign__c = true;
        l.Campaign_Code__C = 'camp';
        l.Last_Call_Attempt_Status__c  = 'Visit Confimed';
        l.Count_of_Non_Contactable_Calls__c = null;
        insert l;
        
        
        system.debug('lead project:: ' + l.Project__c);
              
        Lead lconv = TestDataFactory.convertLead(l);
                
        Opportunity objOpp = [SELECT Id, Name, Project__c FROM Opportunity WHERE Id = :lconv.ConvertedOpportunityId];
        system.debug('opty project:: ' + objOpp.Project__c);
        
        /* validating duplicate opty for same project */
        List<Opportunity> optyList = TestdataFactory.createOpptyForAccount(l.ConvertedAccountId, pro.Id, 1);
        Test.startTest();
        
       // RecordType presalesCallRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Task' AND Name = 'Presales Call'];
       // RecordType salesCallRecordType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Task' AND Name = 'Sales Call'];
        // Presales Call rollup on Opty
        List<Task> tasklist = new List<Task>();
        Task t = new Task();
        t.Subject = 'Call'; 
        t.Status = 'Completed';
        t.CallType = 'Inbound';
        t.UTM_Campaign__c = 'test';
        t.Call_Attempt_Status__c = 'Contact';
        t.Next_Action_Date__c = System.today().adddays(5);
        t.activityDate = System.Today();
        t.whatId = objOpp.Id;
        t.Task_Type__c = 'Presales';
        
        //t.recordTypeId = presalesCallRecordType.Id;
        //t.DID__c = 'TestCamp';
        insert t;
        tasklist.add(t);
        TaskManagementServices.latestTaskRollupToOpp(tasklist);
        t.Call_Attempt_Status__c = 'No Contact';
        t.Next_Action_Date__c = System.today().adddays(10);
        update t;
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp());
        
        Call_Ozonetel_Manual_API__c  oz = New Call_Ozonetel_Manual_API__c();
        oz.Name = 'API Calling';
        oz.Scheduler_API_to_be_Called__c = True;
        insert oz;
        
        //// Sales Call roll up on Opty   
        List<Task> tasklist1 = new List<Task>();
        task t2 = new task();
        t2.Subject = 'Call';  
        t2.Status = 'Completed';
        t2.CallType = 'Outbound';
        t2.Call_Attempt_Status__c = 'Contact';
        t2.Next_Action_Date__c = System.today().adddays(5);
        t2.activityDate = System.Today();
        t2.whatId = objOpp.Id; 
        t2.Task_Type__c = 'Site Visit';
        //t2.recordTypeId = salesCallRecordType.Id;
        insert t2;
        tasklist1.add(t2);
        TaskManagementServices.latestTaskRollupToOpp(tasklist1);
        checkRecursion.firstRun =true;
        t2.Next_Action_Date__c = System.today().adddays(10);
        update t2;
        Test.setMock(HttpCalloutMock.class, new CallOzonetelSchedulerMockImp()); 

        Test.stopTest();        
    }
    
    @isTest  
    static void TaskRollupOnLead() {
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        List<Task> tasklist = new List<Task>();
       
        Project__c pro = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert pro;
        
        // Create Parent Campaign
        //Campaign camparent = TestDataFactory.createCampaignCC('Test Parent Camp', 'Digital', System.Today(), System.today().addDays(7));
        
        // Create Child Campaign
        //Campaign camchild = TestDataFactory.createCampaignCCNew('Test Child Camp', pro.Id, System.Today(), System.today().addDays(7),camparent.Id);
        
        // Create Lead
        Lead l = new lead();
        l.LastName = 'Test callout';
        l.RDS_Country_Code__c = '+91';
        l.RDS_Country__c = 'India';
        l.MobilePhone = '3423457600';
        l.Project__c = pro.Id;  
        //l.RecordTypeId = [Select Id, Name, sObjectType from RecordType where sObjectType='Lead' AND Name='New lead'].Id;
        l.auto_assign__c = true;
        l.Campaign_Code__C = 'camp';
        l.Count_of_Non_Contactable_Calls__c = null;
        insert l;
        
        //RecordType presalesCallRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Task' AND Name = 'Presales Call'];
        task t = new task();
        t.Subject = 'Call'; 
        t.Status = 'Completed';
        t.Communication_Type__c = 'OutCall';
        t.Call_Attempt_Status__c = 'No Contact';
        t.Next_Action_Date__c = System.today().adddays(5);
        t.activityDate = System.Today();
        t.whoId = l.Id;
        t.UTM_Campaign__c = 'test';
        t.task_type__c = 'Presales Call';
        //t.recordTypeid = presalesCallRecordType.id; 
        //t.DID__c = 'TestCamp';
        insert t;
        
        
        Test.startTest();
        // Presales Call rollup on Lead
        tasklist.add(t);  
        TaskManagementServices.latestTaskRollupToLead(tasklist);              
        TaskManagementServices.incrementNoContactCounter(tasklist);
        TaskManagementServices.setZeroNoContactCounter(tasklist);
      /*  List<Task> tasklist2 = new List<Task>();
        t.task_type__c = 'Sales Call';
        upsert t;
        tasklist2.add(t);
        TaskManagementServices.latestTaskRollupToLead(tasklist2); */
        /* DupResultsDTO */
        Map<String,Set<Id>> dupMap = new Map<String,Set<Id>>();
        DupResultsDTO drDTO = new DupResultsDTO(l, l.Id, t.Id, dupMap);       
        Test.stopTest();        
    }  
    
    
}
@isTest
private class X_Test_Service {
    
    // Test data setup method
    //@testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Project__C proj=TestDataFactory.createProject('TestProject','Lk001');
        List<Tower__c> testTowerList=TestDataFactory.createTowers(1,proj.Id);
        // List<Unit__c> testUnitList=TestDataFactory.createUnits(testTowerList[0].Id,proj.Id);
        Unit__c testUnit = new Unit__c();
        testUnit.name = 'TestUnit';
        testUnit.Carpet_Area__c = 425;
        testUnit.Chargeable_Area__c = 923;
        testUnit.Configuration__c = '2BHK';
        testUnit.Unit_Status__c = 'Available';
        testUnit.Active_Inactive__c = 'Active';
        testUnit.Project__c = proj.id;
        testUnit.Tower__c = testTowerList[0].id;
        testUnit.Floor__c = 10;
        //testUnit.Project_Code__c='pr10';
        insert testUnit;
        
        
        // Create Opportunity
        List<Opportunity> oppList= TestDataFactory.createOpptyForAccount(acc.ID,proj.id,1 );
        Opportunity opp = oppList[0];
        
        
        // Create Applicant Details
        Applicant_Details__c applDetail= new Applicant_Details__c(
            Opportunity__c = opp.Id,
            Name = 'Applicant1',
            Applicant_Number__c = '0098237',
            DOB__c = system.today(),
            Permanent_Address__c = 'Pike Street, New World, 45000',
            Country__c = 'India',
            City__c = 'Nagpur',
            Mailing_Country__c = null,
            Mobile_Number__c = '909090903',
            Email_Address__c = 'newman@justnow.com',
            Nationality__c = 'Indian',
            Type_Of_Applicant__c = 'Individual Buyer',
            Subtype_Of_Applicant__c = 'Indian National'
        );
        insert applDetail;
        Payment_Plan__c testPayPlan = new Payment_Plan__c();
        testPayPlan.Tower__c = testTowerList[0].Id;
        testPayPlan.Plan_Code__c = '001';
        testPayPlan.Project__c = proj.Id;
        testPayPlan.No_GST_on_Token__c = true;
        testPayPlan.NoofMilestones__c = 6;
        testPayPlan.Is_Access_Restricted__c = true;
        testPayPlan.Valid_Till__c = System.today().addDays(5);
        
        insert testPayPlan;
        
        
        Quotation__c testQuote= new Quotation__C(
            Unit__C = testUnit.Id ,
            Opportunity__c = opp.id,
            Payment_Plan__c=testPayPlan.Id
        );
        insert testQuote;
        Booking__c testBooking = new Booking__c(
            Opportunity__c=opp.Id,
            Unit__C=testUnit.Id,
            Quotation__c = testQuote.Id,
            Primary_Applicant_Email__c='AAbbdd@gmail.com',
            SMT__c=true); 
        Insert testBooking;
        
        Receipt__c testRec = new Receipt__c();
        testRec.Cheque_DD_Amount_Rs__c = 20000000;
        testRec.Cheque_DD__c = '908888';
        testRec.Cheque_DD_Date__c = system.today();
        testRec.Project__c = proj.Id;
        testRec.Project_Unit__c = testUnit.Id;
        testRec.Opportunity__c = opp.Id;
        testRec.CheckReceipt__c = true;
        testRec.Token_Amount_Receipt__c = true;
        testRec.Physically_Cheque_Received__c = true;
        testRec.Approval_Status__c = 'Approved';
        testRec.Receipt_Date__c = system.today();
        testRec.DraweeBank__c = 'Axis Bank';
        testRec.Total_Amount__c = 20000000;
        testRec.Amount_Rs__c = 20000000;
        testRec.Amount_Advanced__c = 0;
        testRec.mode__c = 'Cheque';
        testRec.Currency__c = 'AED';
        testRec.Booking__c = testBooking.Id;
        testRec.Receipt_Status__c = 'UnProcessed';
        insert testRec;
        
        Demand__c testDemand = new Demand__c(
            Milestone_Name__c='testDemand',
            Project__c = proj.Id,
            Unit__c = testUnit.Id,
            Booking__c = testBooking.Id
        );
        
        
        
    }
    
    //Test method to cover CustomerPostAPI
    @isTest
    static void testCustomerPostAPI() {
        
        //Create test data
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Project__C proj=TestDataFactory.createProject('TestProject','Lk001');
        List<Tower__c> testTowerList=TestDataFactory.createTowers(1,proj.Id);
        Unit__c testUnit = new Unit__c();
        testUnit.name = 'TestUnit';
        testUnit.Carpet_Area__c = 425;
        testUnit.Chargeable_Area__c = 923;
        testUnit.Configuration__c = '2BHK';
        testUnit.Unit_Status__c = 'Available';
        testUnit.Active_Inactive__c = 'Active';
        testUnit.Project__c = proj.id;
        testUnit.Tower__c = testTowerList[0].id;
        testUnit.Floor__c = 10;
        //testUnit.Project_Code__c='pr10';
        insert testUnit;
        
        
        // Create Opportunity
        List<Opportunity> oppList= TestDataFactory.createOpptyForAccount(acc.ID,proj.id,1 );
        Opportunity opp = oppList[0];
        
        
        // Create Applicant Details
        Applicant_Details__c applDetail= new Applicant_Details__c(
            Opportunity__c = opp.Id,
            Name = 'Applicant1',
            Applicant_Number__c = '0098237',
            DOB__c = system.today(),
            Permanent_Address__c = 'Pike Street, New World, 45000',
            Country__c = 'India',
            City__c = 'Nagpur',
            Mailing_Country__c = null,
            Mobile_Number__c = '909090903',
            Email_Address__c = 'newman@justnow.com',
            Nationality__c = 'Indian',
            Type_Of_Applicant__c = 'Individual Buyer',
            Subtype_Of_Applicant__c = 'Indian National'
        );
        insert applDetail;
        
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new X_MockData.MockHttpResponseGenerator());
        
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(currentUser)
        {
            // get Applicant Details
            List<X_Service.X_APIData> apiDataList = new List<X_Service.X_APIData>();
            X_Service.X_APIData apiData = new X_Service.X_APIData();
            apiData.recordId=applDetail.Id;
            apiData.apiMethodName='POST';
            apiDataList.add(apiData);
            Test.startTest();
            X_Service xs = new X_Service(apiData);xs.sync();//handleAPI(apiDataList);
            
            Test.stopTest();
            
            
            // Assertion
            List<API_Callout_Log__c> log=[SELECT id,Data_Source__c,Context_User__c,Response_Status_Code__c ,Request_Headers__c
                                          FROM API_Callout_Log__c
                                          WHERE Data_Source__c Like :applDetail.Id 
                                          Limit 1];
            system.debug('Requestcustomerpost:'+log);
            system.debug('responseCode:'+log[0]?.Response_Status_Code__c);
            //System.assertEquals(200, log[0]?.Response_Status_Code__c, 'Request failed');
            
            
        }
        
    }
    
    // Test method to cover testcustomerPutAPI
    @isTest
    static void testCustomerPutAPI() {
        //Create test Data
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Project__C proj=TestDataFactory.createProject('TestProject','Lk001');
        List<Tower__c> testTowerList=TestDataFactory.createTowers(1,proj.Id);
        
        Unit__c testUnit = new Unit__c();
        testUnit.name = 'TestUnit';
        testUnit.Carpet_Area__c = 425;
        testUnit.Chargeable_Area__c = 923;
        testUnit.Configuration__c = '2BHK';
        testUnit.Unit_Status__c = 'Available';
        testUnit.Active_Inactive__c = 'Active';
        testUnit.Project__c = proj.id;
        testUnit.Tower__c = testTowerList[0].id;
        testUnit.Floor__c = 10;
        //testUnit.Project_Code__c='pr10';
        insert testUnit;
        
        
        // Create Opportunity
        List<Opportunity> oppList= TestDataFactory.createOpptyForAccount(acc.ID,proj.id,1 );
        Opportunity opp = oppList[0];
        
        
        // Create Applicant Details
        Applicant_Details__c applDetail= new Applicant_Details__c(
            Opportunity__c = opp.Id,
            Name = 'Applicant1',
            Applicant_Number__c = '0098237',
            DOB__c = system.today(),
            Permanent_Address__c = 'Pike Street, New World, 45000',
            Country__c = 'India',
            City__c = 'Nagpur',
            Mailing_Country__c = null,
            Mobile_Number__c = '909090903',
            Email_Address__c = 'newman@justnow.com',
            Nationality__c = 'Indian',
            Type_Of_Applicant__c = 'Individual Buyer',
            Subtype_Of_Applicant__c = 'Indian National'
        );
        insert applDetail;
        
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new X_MockData.MockHttpResponseGenerator());
        
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(currentUser)
        {
            List<X_Service.X_APIData> apiDataList = new List<X_Service.X_APIData>();
            X_Service.X_APIData apiData = new X_Service.X_APIData();
            apiData.recordId=applDetail.Id;
            apiData.apiMethodName='Put';
            apiDataList.add(apiData);
            Test.startTest();
            X_Service xs = new X_Service(apiData);xs.sync();//handleAPI(apiDataList);
            
            Test.stopTest();
            
            
            // Assertion
            List<API_Callout_Log__c> log=[SELECT id,Data_Source__c,Context_User__c,Response_Status_Code__c,Request_Headers__c 
                                          FROM API_Callout_Log__c
                                          WHERE Data_Source__c Like :applDetail.Id 
                                          Limit 1];
            //system.debug('Request:'+log[0]?.Request_Headers__c);
            //System.assertEquals(currentUser.Id, log[0]?.Context_User__c, 'Context_User__c is not equal to current user');
            //System.assertEquals(200, log[0]?.Response_Status_Code__c, 'Request failed');
            
            
        }
        
    }
    
    // Test method to cover PhasePostAPI
    @isTest
    static void testTowerPostAPI() {
        //Create test data
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Project__C proj=TestDataFactory.createProject('TestProject','Lk001');
        List<Tower__c> testTowerList=TestDataFactory.createTowers(1,proj.Id);
        testTowerList[0].Xpedeon_Project_Code__c='102'; 
        update testTowerList[0];
        /*Unit__c testUnit = new Unit__c();
testUnit.name = 'TestUnit';
testUnit.Carpet_Area__c = 425;
testUnit.Chargeable_Area__c = 923;
testUnit.Configuration__c = '2BHK';
testUnit.Unit_Status__c = 'Available';
testUnit.Active_Inactive__c = 'Active';
testUnit.Project__c = proj.id;
testUnit.Tower__c = testTowerList[0].id;
testUnit.Floor__c = 10;
testUnit.Project_Code__c='pr10';
insert testUnit;*/
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new X_MockData.MockHttpResponseGenerator());
        
        List<X_Service.X_APIData> apiDataList = new List<X_Service.X_APIData>();
        X_Service.X_APIData apiData = new X_Service.X_APIData();
        apiData.recordId=testTowerList[0].Id;
        apiData.apiMethodName='POST';
        apiDataList.add(apiData);
        Test.startTest();
        X_Service xs = new X_Service(apiData);xs.sync();//handleAPI(apiDataList);
        
        Test.stopTest();
        
        
        // Assertion
        List<API_Callout_Log__c> log=[SELECT id,Data_Source__c,Context_User__c,Response_Status_Code__c,Request_Headers__c 
                                      FROM API_Callout_Log__c
                                      WHERE Data_Source__c Like :testTowerList[0].Id 
                                      Limit 1];
        system.debug('Request:'+log[0]?.Request_Headers__c);
        // Assert that Context_User__c is equal to current user
        
        //System.assertEquals(200, log[0]?.Response_Status_Code__c, 'Request failed');
        
    }
    
    
    // Test method to cover UnitPostAPI
    @isTest
    static void testUnitPostAPI() {
        //Create test data
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Project__C proj=TestDataFactory.createProject('TestProject','Lk001');
        List<Tower__c> testTowerList=TestDataFactory.createTowers(1,proj.Id);
        testTowerList[0].Xpedeon_Project_Code__c='102';
        update testTowerList[0];
        Unit__c testUnit = new Unit__c();
        testUnit.name = 'TestUnit';
        testUnit.Carpet_Area__c = 425;
        testUnit.Chargeable_Area__c = 923;
        testUnit.Configuration__c = '2BHK';
        testUnit.Unit_Status__c = 'Available';
        testUnit.Active_Inactive__c = 'Active';
        testUnit.Project__c = proj.id;
        testUnit.Tower__c = testTowerList[0].id;
        testUnit.Floor__c = 10;
        //testUnit.Project_Code__c='pr10';
        insert testUnit;
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new X_MockData.MockHttpResponseGenerator());
        
        List<X_Service.X_APIData> apiDataList = new List<X_Service.X_APIData>();
        X_Service.X_APIData apiData = new X_Service.X_APIData();
        apiData.recordId=testUnit.Id;
        apiData.apiMethodName='POST';
        apiDataList.add(apiData);
        Test.startTest();
        X_Service xs = new X_Service(apiData);xs.sync();//handleAPI(apiDataList);
        
        
        
        Test.stopTest();
        
        
        // Assertion
        List<API_Callout_Log__c> log=[SELECT id,Data_Source__c,Context_User__c,Response_Status_Code__c,Request_Headers__c 
                                      FROM API_Callout_Log__c
                                      WHERE Data_Source__c Like :testUnit.Id 
                                      Limit 1];
        system.debug('Request:'+log[0]?.Request_Headers__c);
        // Assert that Context_User__c is equal to current user
        
        //System.assertEquals(200, log[0]?.Response_Status_Code__c, 'Request failed');
        
    }
    
    // test method to cover UnAllocateReceiptPostAPI
    @isTest
    static void testUnAllocatedRecPostAPI() {
        //Create test data
        
        
        // Create Account
        /*Account acc = new Account(Name = 'Test Account');
insert acc;

Project__C proj=TestDataFactory.createProject('TestProject','Lk001');
List<Tower__c> testTowerList=TestDataFactory.createTowers(1,proj.Id);
Unit__c testUnit = new Unit__c();
testUnit.name = 'TestUnit';
testUnit.Carpet_Area__c = 425;
testUnit.Chargeable_Area__c = 923;
testUnit.Configuration__c = '2BHK';
testUnit.Unit_Status__c = 'Available';
testUnit.Active_Inactive__c = 'Active';
testUnit.Project__c = proj.id;
testUnit.Tower__c = testTowerList[0].id;
testUnit.Floor__c = 10;
testUnit.Project_Code__c='pr10';
insert testUnit;


// Create Opportunity
List<Opportunity> oppList= TestDataFactory.createOpptyForAccount(acc.ID,proj.id,1 );
Opportunity opp = oppList[0];


// Create Applicant Details
Applicant_Details__c applDetail= new Applicant_Details__c(
Opportunity__c = opp.Id,
Name = 'Applicant1',
Applicant_Number__c = '0098237',
DOB__c = system.today(),
Permanent_Address__c = 'Pike Street, New World, 45000',
Country__c = 'India',
City__c = 'Nagpur',
Mailing_Country__c = null,
Mobile_Number__c = '909090903',
Email_Address__c = 'newman@justnow.com',
Nationality__c = 'Indian',
Type_Of_Applicant__c = 'Individual Buyer',
Subtype_Of_Applicant__c = 'Indian National'
);
insert applDetail;
Payment_Plan__c testPayPlan = new Payment_Plan__c();
testPayPlan.Tower__c = testTowerList[0].Id;
testPayPlan.Plan_Code__c = '001';
testPayPlan.Project__c = proj.Id;
testPayPlan.No_GST_on_Token__c = true;
testPayPlan.NoofMilestones__c = 6;
testPayPlan.Is_Access_Restricted__c = true;
testPayPlan.Valid_Till__c = System.today().addDays(5);

insert testPayPlan;


Quotation__c testQuote= new Quotation__C(
Unit__C = testUnit.Id ,
Opportunity__c = opp.id,
Payment_Plan__c=testPayPlan.Id
);
insert testQuote;
Booking__c testBooking = new Booking__c(
Opportunity__c=opp.Id,
Unit__C=testUnit.Id,
Quotation__c = testQuote.Id,
Primary_Applicant_Email__c='AAbbdd@gmail.com',
SMT__c=true); 
Insert testBooking;

Payment_Request__c pr = new Payment_Request__c();
pr.name__c = 'shravani';
pr.Booking__c=testBooking.id;
pr.Email__c = 'shravani.@ceptes.com';
pr.Mobile_Number__c='9550987889';
pr.Emirates_Id_Passport_Number__c='12xgy';
pr.Mode__c = 'OTC Deposits';
pr.Status__c='Approved';
pr.Amount__c = 123;
pr.Unit__c = testUnit.id;
pr.Approved_Date_and_Time__c=System.today();
pr.From_Booking__c = true;
insert pr;


Receipt__c testRec = new Receipt__c();
testRec.Cheque_DD_Amount_Rs__c = 20000000;
testRec.Cheque_DD__c = '908888';
testRec.Cheque_DD_Date__c = system.today();
testRec.Project__c = proj.Id;
testRec.Project_Unit__c = testUnit.Id;
testRec.Opportunity__c = opp.Id;
testRec.CheckReceipt__c = true;
testRec.Token_Amount_Receipt__c = true;
testRec.Physically_Cheque_Received__c = true;
testRec.Approval_Status__c = 'Approved';
testRec.Receipt_Date__c = system.today();
testRec.DraweeBank__c = 'Axis Bank';
testRec.Total_Amount__c = 20000000;
testRec.Amount_Rs__c = 20000000;
testRec.Amount_Advanced__c = 0;
testRec.mode__c = 'Cheque';
testRec.Currency__c = 'AED';
testRec.Booking__c = testBooking.Id;
testRec.Receipt_Status__c = 'Cleared';
testRec.Payment_Request__c = pr.id;
testRec.Receipt_Status__C='Cleared';
insert testRec;*/
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Quotation__c qController = new Quotation__c();
        
        qController.Opportunity__c = oppId;
        qController.Unit__c = unitId;
        qController.Payment_Plan__c = recordMap.get('PLAN');
        qController.Quote_Status__c = 'Valid';
        insert qController;
        
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = qController.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        insert b;
        Payment_Request__c pr = new Payment_Request__c();
        pr.name__c = 'shravani';
        pr.Booking__c= b.id;
        pr.Email__c = 'shravani.@ceptes.com';
        pr.Mobile_Number__c='9550987889';
        pr.Emirates_Id_Passport_Number__c='12xgy';
        pr.Mode__c = 'OTC Deposits';
        pr.Status__c='Approved';
        pr.Amount__c = 123;
        // pr.Unit__c = testUnit.id;
        pr.Approved_Date_and_Time__c=System.today();
        pr.From_Booking__c = true;
        insert pr;
        
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Amount_Rs__c = 200000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Currency__c = 'Indian Rupee';
        r1.On_Account_Money__c = 200000;
        r1.Booking__c = b.Id;
        r1.Payment_Request__C=pr.ID;
        r1.Receipt_Status__c = 'Cleared';
        insert r1;
        
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new X_MockData.MockHttpResponseGenerator());
        
        List<X_Service.X_APIData> apiDataList = new List<X_Service.X_APIData>();
        X_Service.X_APIData apiData = new X_Service.X_APIData();
        apiData.recordId=pr.Id;
        apiData.apiMethodName='POST';
        apiDataList.add(apiData);
        Test.startTest();
        
        X_Service xs = new X_Service(apiData);xs.sync();//handleAPI(apiDataList);
        xs.UnAllocatedRecPostAPI(apiData.recordId);
        Test.stopTest();
        
        
        // Assertion
        List<API_Callout_Log__c> log=[SELECT id,Data_Source__c,Context_User__c,Response_Status_Code__c,Request_Headers__c 
                                      FROM API_Callout_Log__c
                                      WHERE Data_Source__c Like :pr.Id 
                                      Limit 1];
        //system.debug('Request:'+log[0]?.Request_Headers__c);
        // Assert that Context_User__c is equal to current user
        
        //System.assertEquals(200, log[0]?.Response_Status_Code__c, 'Request failed');
        
    }
    
    // test method to cover AllocateReceiptPostAPI
    @isTest
    static void testAllocatedRecPostAPI() {
        //Create test data
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Quotation__c qController = new Quotation__c();
        
        qController.Opportunity__c = oppId;
        qController.Unit__c = unitId;
        qController.Payment_Plan__c = recordMap.get('PLAN');
        qController.Quote_Status__c = 'Valid';
        insert qController;
        
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = qController.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        insert b;
        Payment_Request__c pr = new Payment_Request__c();
        pr.name__c = 'shravani';
        pr.Booking__c= b.id;
        pr.Email__c = 'shravani.@ceptes.com';
        pr.Mobile_Number__c='9550987889';
        pr.Emirates_Id_Passport_Number__c='12xgy';
        pr.Mode__c = 'OTC Deposits';
        pr.Status__c='Approved';
        pr.Amount__c = 123;
        // pr.Unit__c = testUnit.id;
        pr.Approved_Date_and_Time__c=System.today();
        pr.From_Booking__c = true;
        insert pr;
        
        
        Receipt__c rec = new Receipt__c();
        rec.Cheque_DD_Amount_Rs__c = 200000;
        rec.Cheque_DD__c = '908888';
        rec.Cheque_DD_Date__c = system.today();
        rec.Project__c = projectId;
        rec.Project_Unit__c = unitId;
        rec.Opportunity__c = oppId;
        rec.CheckReceipt__c = true;
        rec.Token_Amount_Receipt__c = true;
        rec.Physically_Cheque_Received__c = true;
        rec.Approval_Status__c = 'Approved';
        rec.Receipt_Date__c = system.today();
        rec.DraweeBank__c = 'Axis Bank';
        rec.Total_Amount__c = 200000;
        rec.Amount_Rs__c = 200000;
        rec.Amount_Advanced__c = 0;
        rec.mode__c = 'Cheque';
        rec.Currency__c = 'Indian Rupee';
        rec.On_Account_Money__c = 200000;
        rec.Booking__c = b.Id;
        rec.Payment_Request__C=pr.ID;
        rec.Receipt_Status__c = 'Cleared';
        insert rec;
        
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new X_MockData.MockHttpResponseGenerator());
        
        List<X_Service.X_APIData> apiDataList = new List<X_Service.X_APIData>();
        X_Service.X_APIData apiData = new X_Service.X_APIData();
        apiData.recordId=rec.Id;
        apiData.apiMethodName='POST';
        apiDataList.add(apiData);
        Test.startTest();
        
        X_Service xs = new X_Service(apiData);xs.sync();//handleAPI(apiDataList);
        xs.AllocatedRecPostAPI(apiData.recordId);
        Test.stopTest();
        
        
        // Assertion
        List<API_Callout_Log__c> log =[SELECT id,Data_Source__c,Context_User__c,Response_Status_Code__c,Request_Headers__c 
                                       FROM API_Callout_Log__c
                                       WHERE Data_Source__c Like :rec.Id 
                                       Limit 1];
        //system.debug('Request:'+log[0]?.Request_Headers__c);
        // Assert that Context_User__c is equal to current user
        
        //System.assertEquals(200, log[0]?.Response_Status_Code__c, 'Request failed');
        
    }
    
    
    // Test method to cover invoicePostAPI
    @isTest
    static void testinvoicePostAPI() {
        //create test Data
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');
        
        Tower__c tower = [SELECT Id, Name, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;      
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Due_Date__c = System.today().addDays(-100);
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = q.Id;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 100000;          
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 0;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm;
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Milestone_Due_Till_Date__c = 60000;
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test@test.com';
        insert b;
        
        
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c =recordIdMap.get('PROJECT');
        objRec.Opportunity__c =recordIdMap.get('OPPORTUNITY');
        objRec.Project_Unit__c = recordIdMap.get('UNIT');
        objRec.Booking__c = b.Id; 
        objRec.Receipt_Status__c = 'Cleared';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Amount_Rs__c = 500;
        objRec.Total_Amount__c = 5000;
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        insert objRec;
        
        
        // list<Demand__c> dList = new list<Demand__c>();
        Demand__c d = new Demand__c();
        d.Milestone_Name__c = 'Debit note for DLD Charges';       
        d.Debit_Demanded__c = 100;
        d.Debit_CGST__c = 0;
        d.Total_Amount_Demanded__c = 240000;
        d.Tax_Rate__c = 'OUT OF SCOPE';
        d.Debit_Type__c = 'Interest Charges';
        d.Invoice_Date__c = System.Today();
        d.GL_Date__c = System.Today();
        d.Due_Date__c = pm.Milestone_Due_Date__c;
        d.Project__c = recordIdMap.get('PROJECT');
        d.Other_Charges_Type__c ='DEWA Charges';
        d.Booking__c = b.Id;
        d.Unit__c = unitId;
        d.Corporate_Collection_Control_Report__c = 20; 
        d.Registration_Collection_Control_Report__c = 20;
        d.Payment_Towards__c = 'Corporate Account';
        d.Payment_Milestones__c = pm.id;
        d.OutStanding_days_calculated__c = '100';
        insert d;
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new X_MockData.MockHttpResponseGenerator());
        List<X_Service.X_APIData> apiDataList = new List<X_Service.X_APIData>();
        X_Service.X_APIData apiData = new X_Service.X_APIData();
        apiData.recordId=d.Id;
        apiData.apiMethodName='POST';
        apiDataList.add(apiData);
        Test.startTest();
        X_Service xs = new X_Service(apiData);xs.sync();//handleAPI(apiDataList);
        
        Test.stopTest();
        
        
        // Assertion
        List<API_Callout_Log__c> log=[SELECT id,Data_Source__c,Context_User__c,Response_Status_Code__c,Request_Headers__c 
                                      FROM API_Callout_Log__c
                                      WHERE Data_Source__c Like :d.Id 
                                      Limit 1];
        //system.debug('Request:'+log[0]?.Request_Headers__c);
        
        
        //System.assertEquals(200, log[0]?.Response_Status_Code__c, 'Request failed');
        
        
        
        
    }
    
    
    
    // Test method to cover getRequestHeaders
    /*  @isTest
static void testGetRequestHeaders() {

Test.startTest();
Map<String,String> headers = X_CustomerPostRequestHandler.getRequestHeaders();
Test.stopTest();

// Assertion
//System.assertNotEquals(null, headers);
}*/
}
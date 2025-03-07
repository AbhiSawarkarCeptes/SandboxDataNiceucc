@isTest public class PaymentRequestMockControllerTest {
    @isTest public static void test1(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true); 
        insert contentVersion;
        
        Blacklisted_Customer__c bc = new Blacklisted_Customer__c();
        bc.Blacklisted__c = true;
        bc.Name = 'name';
        bc.From_Date__c = system.today()+5;
        insert bc;
        
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','test######102',false,false,'Marketing#Digital','');
        Payment_Request_Mock__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request_Mock__c Limit 1];
        pr.Mode_Option__c = 'Single Mode';
        pr.Status__c = 'Approved';
        
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','test######102',false,false,'Marketing#Digital','');
        Payment_Request_Mock__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request_Mock__c where id !=: pr.id];
        Test.startTest();
        pr.Secondary_Mode__c = 'OTC Deposits';
        update pr;
        pr.amount__c = 98219;
        pr.Status__c = 'Rejected by Accounts';
        pr.Payment_Request_Mock__c = pr1.id;
        update pr;
        Test.stopTest();
        pr.Status__c = 'Rejected by System';
        update pr;
        pr.Status__c = 'Amount Confirmed by Accounts';
        PaymentRequestMockController.insertErrorLog('test','test','test','NewSaleApprovalTriggerHandler','validations');
        //update pr;
    }
    
    @isTest public static void test2(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        
        Unit__c u = new Unit__c(Id=unitId);
        u.Unit_Hold_min_percentage__c = 10;
        u.Puchase_Price__c = 100000;
        u.Unit_Status__c = 'Available';
        u.Not_Available_for_Sales__c = false;
        update u;
        
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges; 
        
        List<Booking__c> bList = new List<Booking__c>();
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.Status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Current_Status__c = 'Audit Accepted';
        insert b;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
                Test.startTest();

        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','AED','12345','12345',string.valueOf(system.today()),null,'100',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000'},b.Id,'undefined','undefined','undefined','undefined','false###false###false###false','','','','82','','','test######102',false,false,'Marketing#Digital','');
        Payment_Request_Mock__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request_Mock__c Limit 1];
        pr.Status__c = 'Partially Approved';
        update pr;
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000'},b.Id,'Single Mode','OTC Deposits','undefined','undefined','false###false###false###false','','','','','',pr.Id,'test######102',false,false,'Marketing#Digital','');
        Payment_Request_Mock__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request_Mock__c order by createddate desc Limit 1];
        pr1.Status__c = 'Approved';
        pr1.from_booking__c = true;
        pr1.booking__c = b.id;
        update pr1;
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000'},b.Id,'Single Mode','OTC Deposits','undefined','undefined','false###false###false###false','','100','','100','Title Deed Charges',pr.Id,'',false,false,'Marketing#Digital','1');
        
       
        PaymentRequestMockController.rejectWebsiteRequests(new list<string>{pr.Payment_Request_Wrapper__c});
        PaymentRequestMockController.updateUnit(new List<Id>{pr.Id});
        PaymentRequestMockController.unitDetails(unitId);
        PaymentRequestMockController.getUnitId(b.Id);
        PaymentRequestMockController.getCurrencyRate();
        Test.stopTest();
    }
    
    /*@isTest public static void test3(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        Unit__c u = new Unit__c(Id=unitId);
        u.Unit_Hold_min_percentage__c = 10;
        u.Puchase_Price__c = 1000;
        u.Unit_Status__c = 'Available';
        u.Not_Available_for_Sales__c = false;
        update u;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','',false,false,'Marketing#Digital','');
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','',false,false,'Marketing#Digital','');
        Payment_Request_Mock__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request_Mock__c Limit 1];
        update pr;
        PaymentRequestForm.rejectPaymentRequests(new List<Id>{pr.Id});
    }*/
    
    @isTest public static void test4(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        Unit__c u1 = new Unit__c(Id=unitId);
        u1.Unit_Hold_min_percentage__c = 10;
        u1.Puchase_Price__c = 1000;
        u1.Unit_Status__c = 'Available';
        u1.Not_Available_for_Sales__c = false;
        update u1;
        
        Unit__c u = new Unit__c();   
        u.Unit_Status__c = 'Available';
        u.Name = 'TestFive';  
        insert u;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId, u.Id},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','',false,false,'Marketing#Digital','');
        Payment_Request_Mock__c pr = [select Id, Status__c, Payment_Request_Wrapper__c from Payment_Request_Mock__c Limit 1];
        
        PaymentRequestFormRejected.rejectedPaymentRequests(new List<Id>{pr.Id});
    }
    
    @isTest public static void test5(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        Unit__c u1 = new Unit__c(Id=unitId);
        u1.Unit_Hold_min_percentage__c = 10;
        u1.Puchase_Price__c = 1000;
        u1.Unit_Status__c = 'Available';
        u1.Not_Available_for_Sales__c = false;
        update u1;
        
        Unit__c u = new Unit__c();    
        u.Name = 'TestFive';  
        u.Unit_Status__c = 'Available';
        u.Puchase_Price__c = 100000;
        insert u;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{u.Id+'##USD##10000'},'undefined','Single Mode','undefined','undefined','undefined','false###false###false###false','','','','','','','',false,false,'Marketing#Digital','');
        PaymentRequestForm.unlockRecords();
    }
    
    @isTest public static void test6(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        Unit__c u1 = new Unit__c(Id=unitId);
        u1.Unit_Hold_min_percentage__c = 10;
        u1.Puchase_Price__c = 1000;
        u1.Unit_Status__c = 'Available';
        u1.Not_Available_for_Sales__c = false;
        
        update u1;
        
        Unit__c u = new Unit__c();  
        u.Unit_Status__c = 'Available';
        u.Name = 'TestFive';  
        u.Puchase_Price__c = 1000;
        insert u;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000', u.Id+'##AED##10000'},'undefined','Single Mode','undefined','undefined','undefined','false###false###false###false','','','','','','','',false,false,'Marketing#Digital','');
        Payment_Request_Mock__c pr = [select Id, Status__c, Payment_Request_Wrapper__c from Payment_Request_Mock__c Limit 1];
        pr.Amount__c = 100000;       
        PaymentRequestFormRejected.rejectedPaymentRequests(new List<Id>{pr.Id});
    }
    
    @isTest public static void test7(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        Unit__c u1 = new Unit__c(Id=unitId);
        u1.Unit_Hold_min_percentage__c = 10;
        u1.Puchase_Price__c = 100000;
        u1.Unit_Status__c = 'Available';
        u1.Not_Available_for_Sales__c = false;
        update u1;
        
        Unit__c u = new Unit__c();    
        u.Name = 'TestFive'; 
        u.Puchase_Price__c = 2000;
        insert u;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','AED','12345','12345',string.valueOf(system.today()),null,'10',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000', u.Id+'##AED##100000'},'undefined','Single Mode','Cheque','undefined','undefined','false###false###false###false','','','','82','','','',false,false,'Marketing#Digital',''); 
        
        Payment_Request_Mock__c pr = [select Id, Status__c, Payment_Request_Wrapper__c from Payment_Request_Mock__c Limit 1];
        list<string> unitList = new list<string>();
        unitList.add(unitId+'##AED##100000');
        unitList.add(u.Id+'##AED##100000');
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,unitList,'undefined','Single Mode','Cheque','undefined','undefined','false###false###false###false','','','','','',pr.Id,'',false,false,'Marketing#Digital',''); 
    }
    
    @isTest public static void test8(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        Unit__c u1 = new Unit__c(Id=unitId);
        u1.Unit_Hold_min_percentage__c = 10;
        u1.Puchase_Price__c = 100000;
        u1.Unit_Status__c = 'Available';
        u1.Not_Available_for_Sales__c = false;
        update u1;
        
        Unit__c u = new Unit__c();    
        u.Name = 'TestFive'; 
        u.Puchase_Price__c = 10000;
        insert u;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','AED','12345','12345',string.valueOf(system.today()),null,'10',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000', u.Id+'##AED##10000'},'undefined','Single Mode','Cheque','undefined','undefined','false###false###false###false','','','','82','','','',false,false,'Marketing#Digital',''); 
        Payment_Request_Mock__c pr = [select Id, Status__c, Payment_Request_Wrapper__c from Payment_Request_Mock__c Limit 1];
        pr.Status__c = 'Partially Approved';
        update pr;
        list<string> unitList = new list<string>();
        unitList.add(unitId+'##AED##100000');
        unitList.add(u.Id+'##AED##100000');
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,unitList,'undefined','Single Mode','Cheque','undefined','undefined','false###false###false###false','','','','82','',pr.Id,'',false,false,'Marketing#Digital',''); 
        pr.amount__c = 1289273;
        pr.Status__c = 'Resubmitted to SM/SD';
        Test.startTest();
        update pr;
        List<ContentDocument> docList = [select Id from ContentDocument];
        PaymentRequestMockController.updateUploadedFileName('Test',docList[0].Id);
        PaymentRequestMockController.getPaymentRequestDetails(pr.Id);
        try{
            RequestUnitHoldController.validateUnitAvailablity(u.id);
            RequestUnitHoldController.saveAttachements(pr.Id,new List<Id>{docList[0].id});
        
        }catch(exception e){
            
        }
       Test.stopTest();
    } 
    
    public static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
        
        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp ;
        objQuote1.Payment_Plan__c = pp ;
        objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        
        objQuote1.Charge3Bucket__c = 'Agreement Value';
        objQuote1.Charge3Name__c = 'PLC';
        objQuote1.Charge3Value__c = 1123;
        
        objQuote1.Charge4Bucket__c = 'Other Charges';
        objQuote1.Charge4Name__c = 'test';
        objQuote1.Charge4Value__c = 1123;
        objQuote1.Final_Approved_Date__c = System.today();
        insert objQuote1;
        return objQuote1;
    } 
    
    private static Payment_Milestones__c createPaymentMilestone(Id quote) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 300000000;          
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 2475;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm;        
        return pm;                  
    }  
    
    @isTest
    private static void testPRValidation(){ 
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        
        Unit__c u = new Unit__c(Id=unitId);
        u.Unit_Hold_min_percentage__c = 10;
        u.Puchase_Price__c = 1000;
        u.Unit_Status__c = 'Available';
        u.Not_Available_for_Sales__c = false; 
        //u.Restricted_PR_Start_Time__c = System.today().addDays(-1);
        //u.Restricted_PR_End_time__c = System.today().addDays(1);
        //u.Restric_PR__c = true;
        update u;
        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Trade Receivable';
        amList.add(am1);
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Discount/rebate credit note';
        amList.add(am2);
        insert amList;
        System.debug('starting craetion');
        String message = PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','USD','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000', u.Id+'##AED##10000'},'undefined','Single Mode','Cheque','undefined','undefined','false###false###false###false','','','','82','','','',false,false,'Marketing#Digital',''); 
        String res = PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','International Wire Transfer','USD','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000##Corporate##'+amList[0].Id, u.Id+'##AED##10000####ESCROW##'+amList[1].Id},'undefined','Single Mode','International Wire Transfer','undefined','undefined','false###false###false###false','','','','82','','','',false,false,'Marketing#Digital','');
        PaymentRequestMockController.checkifUnitIsBlocked(unitId);
    }
    @isTest public static void testNegative(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        
        Unit__c u = new Unit__c(Id=unitId);
        u.Unit_Hold_min_percentage__c = 10;
        u.Puchase_Price__c = 100000;
        u.Unit_Status__c = 'Available';
        u.Not_Available_for_Sales__c = false;
        update u;
        
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges; 
        
        List<Booking__c> bList = new List<Booking__c>();
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.Status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Current_Status__c = 'Audit Accepted';
        insert b;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
               

        //PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','AED','12345','12345',string.valueOf(system.today()),null,'100000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000'},b.Id,'undefined','undefined','undefined','undefined','false###false###false###false','','','','','82','','',false,false,'Marketing#Digital','');
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','AED','12345','12345',string.valueOf(system.today()),null,'10000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000'},b.Id,'undefined','undefined','undefined','undefined','false###false###false###false','','','','82','','','',false,false,'Marketing#Digital','');
        

       Payment_Request_Mock__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request_Mock__c Limit 1];
        pr.Status__c = 'Partially Approved';
        update pr;
        
        test.startTest();
       
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId+'##AED##10000'},b.Id,'Single Mode','OTC Deposits','undefined','undefined','false###false###false###false','','','','82','',pr.Id,'',false,false,'Marketing#Digital','');
        Payment_Request_Mock__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request_Mock__c order by createddate desc Limit 1];
        pr1.Status__c = 'Approved';
        pr1.from_booking__c = true;
        pr1.booking__c = b.id;
        pr1.Others__c = 'Title Deed Charges';
        pr1.Towards_Other_Charges_Amount__c = 100;
        update pr1;
       
        try{
            PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},b.Id,'Single Mode','OTC Deposits','undefined','undefined','false###false###false###false','','','','82','',pr.Id,'',false,false,'Marketing#Digital','');
        
        }catch(Exception e){
            
        }
        test.stopTest();
    }
    
   /**  @isTest public static void testfinancefields(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        Profile prof = [select id from profile where name LIKE '%Finance%' LIMIT 1];
        User usr = new User();
        usr.firstName = 'test1';
        usr.lastName = 'test2';
        usr.profileId = prof.id;
        usr.Alias = 'sdffer';
        usr.username = 'testsdncbjdsc@test.com';
        usr.email = 'testcdscdvcdv@test.com';
        usr.TimeZoneSidKey = 'America/New_York';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
        
         
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true); 
        insert contentVersion;
        
        PaymentRequestMockController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined',false,'','','','','','','test######102',false,false,'Marketing#Digital','');
        Payment_Request_Mock__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request_Mock__c Limit 1];

        pr.Status__c = 'Rejected by Accounts';
        pr.Account_Remarks__c = 'test';
         update pr;
         
    }**/
}
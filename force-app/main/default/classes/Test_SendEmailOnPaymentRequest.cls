@isTest
public class Test_SendEmailOnPaymentRequest {
    @isTest public static void test1(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'), 
            IsMajorVersion = true);
        insert contentVersion;
        
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined',false,'','','','','','','',false,false,'Marketing#Digital','');
         PaymentRequestFormController.createPaymentRequest('ya','ya@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined',false,'','','','','','','',false,false,'Marketing#Digital','');
        Payment_Request__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request__c Limit 1];
         Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c Where email__C = 'ya@test.com' Limit 1];
        pr1.payment_request__c = pr.id;
        pr1.Status__c = 'Pending for Accounts Approval';
        update pr1;
        pr.payment_request__c = pr1.id;
        update pr;
        List<Id> prIdList = new List<Id>();
        prIdList.add(pr.Id);
        List<Payment_Request__c> prList = new List<Payment_Request__c>();
        prList.add(pr);
        test.starttest();
        pr.Mode_Option__c = 'Multi Mode';
        pr.Status__c = 'Approved';
        pr.Secondary_Mode__c = 'OTC Deposits';
        update pr;
        SendEmailOnPaymentRequest.insertBookings(prIdList);
        pr.Status__c = 'Rejected by Accounts';
        update pr;
        pr.Status__c = 'Rejected by System';
        update pr;
        pr.Status__c = 'Amount Confirmed by Accounts';
        update pr;
        pr.Status__c = 'Pending for Accounts Approval';
        update pr;
        CancelPaymentRequest1Hr.email1Hr(prList);
        test.stoptest();
    }
    
    @isTest public static void test2(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        
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
        unit__c u = new unit__c(id= unitId);
        u.unit_status__c = 'Available';
        u.Reason_for_Cancellation__c = 'Test';
        update u;
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','OTC Deposits','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',0,new list<string>{unitId+'##AED##10000'},'undefined','undefined','undefined','undefined','undefined',false,'','','','','','','',false,false,'Marketing#Digital','');
        
        Payment_Request__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request__c Limit 1];
        PaymentRequestFormController.rejectWebsiteRequests(new list<string>{pr.Payment_Request_Wrapper__c});
        PaymentRequestFormController.updateUnit(new List<Id>{pr.Id});
        PaymentRequestFormController.unitDetails(unitId);
        PaymentRequestFormController.getUnitId(b.Id);
    }
    
    @isTest public static void test3(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined',false,'','','','','','','',false,false,'Marketing#Digital','');
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined',false,'','','','','','','',false,false,'Marketing#Digital','');
        Payment_Request__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request__c Limit 1];
        
        PaymentRequestForm.rejectPaymentRequests(new List<Id>{pr.Id});
    }
    
    @isTest public static void test4(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        Unit__c u = new Unit__c();    
        u.Name = 'TestFive';  
        insert u;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined',false,'','','','','','','',false,false,'Marketing#Digital','');
        Payment_Request__c pr = [select Id, Status__c, Payment_Request_Wrapper__c from Payment_Request__c Limit 1];
                
        PaymentRequestFormRejected.rejectedPaymentRequests(new List<Id>{pr.Id});
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
}
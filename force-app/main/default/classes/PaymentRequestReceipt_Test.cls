@isTest
public class PaymentRequestReceipt_Test {
    @isTest
    public static void frrCreation_New() {
        Profile prof = [select id from profile where name LIKE '%System Administrator%' LIMIT 1];
        userRole ur = [SELECT Id, Name FROM UserRole WHERE Name = 'Sales Head 1'];
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
        usr.UserRoleId = ur.id;
        usr.IsActive=true;
        insert usr;
        
        System.runAs(usr) {
            
            Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
            Id oppId  =   recordMap.get('OPPORTUNITY');
            Id unitId = recordMap.get('UNIT');
            Id projectId = recordMap.get('PROJECT');
            Id projCharges = recordMap.get('BASIC');
            
            Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
            
            //Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
            //pm1.Charge_1_Lookup__c = projCharges;
            //update pm1;     
            Account_Master__c am = new Account_Master__c();
            am.Name = 'TRADE RECEIVABLE';
            am.Account_Number__c = '1234';
            am.Type__c = 'Others';
            insert am;
            Account_Master__c am1 = new Account_Master__c();
            am1.Name = 'MAIN CASH';
            am1.Account_Number__c = '12345';
            am1.Type__c = 'Others';
            insert am1;
            Account_Master__c am2 = new Account_Master__c();
            am2.Name = 'Interest Charges';
            am2.Account_Number__c = '123456';
            am2.Type__c = 'Others';
            insert am2;
            
            Booking__c b = new Booking__c();
            b.Booking_Date__c = system.today();
            b.Project__c = projectId;
            b.Opportunity__c = oppId;
            b.Unit__c = unitId;
            b.status__c = 'Processed';
            b.Quotation__c = quote.Id;
            b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
            b.Future_Correspondence_Contact__c = 'First Applicant';
            b.Agreement_Value__c = 6000000;
            b.Stage_of_Booking__c = 'Booked';
            insert b;
            
            
            Payment_Request__c pr = new Payment_Request__c();
            pr.name__c = 'yamini';
            pr.Booking__c=b.id;
            pr.Email__c = 'yamini.jakka@ceptes.com';
            pr.Mobile_Number__c='9550987889';
            pr.Emirates_Id_Passport_Number__c='12xgy';
            pr.Mode__c = 'OTC Deposits';
            pr.Status__c='Approved';
            pr.Amount__c = 123;
            pr.Unit__c = unitId;
            pr.Approved_Date_and_Time__c=System.today();
            pr.From_Booking__c = true;
            insert pr;
            
            Receipt__c rrq = new Receipt__c();
            rrq.Cheque_DD_Amount_Rs__c = 20000000;
            rrq.Cheque_DD__c = '908888';
            rrq.Cheque_DD_Date__c = system.today();
            rrq.Project__c = projectId;
            rrq.Project_Unit__c = unitId;
            rrq.Opportunity__c = oppId;
            rrq.CheckReceipt__c = true;
            rrq.Token_Amount_Receipt__c = true;
            rrq.Physically_Cheque_Received__c = true;
            rrq.Approval_Status__c = 'Approved';
            rrq.Receipt_Date__c = system.today();
            rrq.DraweeBank__c = 'Axis Bank';
            rrq.Total_Amount__c = 20000000;
            rrq.Amount_Rs__c = 20000000;
            rrq.Amount_Advanced__c = 0;
            rrq.mode__c = 'Cheque';
            rrq.Currency__c = 'AED';
            rrq.Booking__c = b.Id;
            //r1.Mode__c='Credit Note';
            rrq.Receipt_Status__c = 'UnProcessed';
            rrq.Payment_Request__c = pr.id;
            insert rrq;
            
            Payment_Request__c pr1 = new Payment_Request__c();
            pr1.name__c = 'yamini';
            pr1.Booking__c=b.id;
            pr1.Email__c = 'yamini.jakka@ceptes.com';
            pr1.Mobile_Number__c='9550987889';
            pr1.Emirates_Id_Passport_Number__c='12xgy';
            pr1.Mode__c = 'OTC Deposits';
            pr1.Status__c='Approved';
            pr1.Amount__c = 123;
            pr1.Unit__c = unitId;
            pr1.Approved_Date_and_Time__c=System.today();
            pr1.Towards_Other_Charges_Amount__c =10;
            pr1.Towards_Pre_Registration_Amount__c =23;
            pr1.Towards_Unit_Price_Amount__c = 100;
            pr1.Mortgage_Value__c = 100;
            pr1.From_Booking__c = true;
            pr1.Others__c = 'DEWA Charges';
            
            Test.startTest();
            insert pr1;
            
            
            List<Id> receiptList = new List<Id>();
            List<Receipt__c> receiptsList = new List<Receipt__c>();
            receiptList.add(rrq.id);
            receiptsList.add(rrq);
            
            PageReference pref = Page.PrintReceiptSobhaDubai;       
            pref.getParameters().put('id',rrq.id);
            Test.setCurrentPage(pref);
            
            ApexPages.StandardController con = new ApexPages.StandardController(rrq);
            //PaymentRequestReceiptEmail.sendAttachedReceiptbatch(receiptsList);
            //PaymentRequestReceiptEmail.AttachReceiptbatch(receiptsList);
            
            
            List<Unit_Hold_Request__c> req = [SELECT Id,Approval_Status__c,Agent_Name__c,Booking__c,Payment_Request__r.Cheque_Date__c,Payment_Request__r.Cheque_No__c,Payment_Request__r.Mode__c,Mode__c,(select id from Receipts__r) FROM unit_hold_request__c];
            System.debug('I am req'+ req);
            for(Unit_Hold_Request__c u : req){
                u.Approval_Status__c = 'Approved';
                update u;
            }
            
            PaymentRequestReceiptCreation obj = new PaymentRequestReceiptCreation();
            list<Payment_Request__c> tmpList = [SELECT Id,Name,Mortgage_Value__c,Status__c,Currency__c,Original_Amount__c,Booking__c,Amount__c,Amount_Towards__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c,Towards_Unit_Price_Amount__c,Booking__r.Unit__r.Name,Booking__r.Project__c,booking__r.Unit__c,Remarks__c,Payment_Transaction_Tracking_Id__c,Account_Received_Date__c,Approved_Date_and_Time__c,Account_Master__c,Instrument_Date__c,Instrument_Number__c,Reference_Number__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Transaction_Number__c,CreatedDate,Unit__c,Cheque_Date__c,Cheque_No__c,Mode__c,Others__c,(select id from Receipts__r) FROM Payment_Request__c WHERE Id =: pr1.Id];
            obj.execute(null, tmpList);
            
            System.enqueueJob(new PaymentRequestReceiptQueueable(receiptList)); 
            
            PaymentRequestReceiptSchedule sh1 = new PaymentRequestReceiptSchedule();
            String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1);
            
            Test.stopTest();
            
        }
    }
    
    @isTest
    public static void frrCreation_New1() {
        Profile prof = [select id from profile where name LIKE '%System Administrator%' LIMIT 1];
        userRole ur = [SELECT Id, Name FROM UserRole WHERE Name = 'Sales Head 1'];
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
        usr.UserRoleId = ur.id;
        usr.IsActive=true;
        insert usr;
        
        System.runAs(usr) {
            
            Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
            Id oppId  =   recordMap.get('OPPORTUNITY');
            Id unitId = recordMap.get('UNIT');
            Id projectId = recordMap.get('PROJECT');
            Id projCharges = recordMap.get('BASIC');
            
            Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
            
            //Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
            //pm1.Charge_1_Lookup__c = projCharges;
            //update pm1;     
            Account_Master__c am = new Account_Master__c();
            am.Name = 'TRADE RECEIVABLE';
            am.Account_Number__c = '1234';
            am.Type__c = 'Others';
            insert am;
            Account_Master__c am1 = new Account_Master__c();
            am1.Name = 'MAIN CASH';
            am1.Account_Number__c = '12345';
            am1.Type__c = 'Others';
            insert am1;
            
            Booking__c b = new Booking__c();
            b.Booking_Date__c = system.today();
            b.Project__c = projectId;
            b.Opportunity__c = oppId;
            b.Unit__c = unitId;
            b.status__c = 'Processed';
            b.Quotation__c = quote.Id;
            b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
            b.Future_Correspondence_Contact__c = 'First Applicant';
            b.Agreement_Value__c = 6000000;
            b.Stage_of_Booking__c = 'Booked';
            insert b;
            
            
            Payment_Request__c pr = new Payment_Request__c();
            pr.name__c = 'yamini';
            pr.Booking__c=b.id;
            pr.Email__c = 'yamini.jakka@ceptes.com';
            pr.Mobile_Number__c='9550987889';
            pr.Emirates_Id_Passport_Number__c='12xgy';
            pr.Mode__c = 'OTC Deposits';
            pr.Status__c='Approved';
            pr.Amount__c = 123;
            pr.Unit__c = unitId;
            pr.Approved_Date_and_Time__c=System.today();
            pr.From_Booking__c = true;
            insert pr;
            
            Receipt__c rrq = new Receipt__c();
            rrq.Cheque_DD_Amount_Rs__c = 20000000;
            rrq.Cheque_DD__c = '908888';
            rrq.Cheque_DD_Date__c = system.today();
            rrq.Project__c = projectId;
            rrq.Project_Unit__c = unitId;
            rrq.Opportunity__c = oppId;
            rrq.CheckReceipt__c = true;
            rrq.Token_Amount_Receipt__c = true;
            rrq.Physically_Cheque_Received__c = true;
            rrq.Approval_Status__c = 'Approved';
            rrq.Receipt_Date__c = system.today();
            rrq.DraweeBank__c = 'Axis Bank';
            rrq.Total_Amount__c = 20000000;
            rrq.Amount_Rs__c = 20000000;
            rrq.Amount_Advanced__c = 0;
            rrq.mode__c = 'Cheque';
            rrq.Currency__c = 'AED';
            rrq.Booking__c = b.Id;
            //r1.Mode__c='Credit Note';
            rrq.Receipt_Status__c = 'UnProcessed';
            rrq.Payment_Request__c = pr.id;
            insert rrq;
            
            Payment_Request__c pr1 = new Payment_Request__c();
            pr1.name__c = 'yamini';
            pr1.Booking__c=b.id;
            pr1.Email__c = 'yamini.jakka@ceptes.com';
            pr1.Mobile_Number__c='9550987889';
            pr1.Emirates_Id_Passport_Number__c='12xgy';
            pr1.Mode__c = 'OTC Deposits';
            pr1.Status__c='Approved';
            pr1.Amount__c = 123;
            pr1.Unit__c = unitId;
            pr1.Submitted_Date__c = String.valueOf(System.today());
            pr1.Approved_Date_and_Time__c=System.today();
            pr1.Towards_Other_Charges_Amount__c =10;
            pr1.Payment_Request__c = pr.Id;
            pr1.Towards_Pre_Registration_Amount__c =23;
            pr1.Towards_Unit_Price_Amount__c = 100;
            pr1.Mortgage_Value__c = 100;
            Test.startTest();
            pr1.From_Booking__c = true;
            insert pr1;
            
            pr1.Submitted_Date__c = String.valueOf(System.today().addDays(1));
            pr1.Status__c = 'Resubmitted to SM/SD';
            update pr1;
            
            pr1.status__c = 'Rejected by Accounts';
            update pr1;
            pr1.status__c = 'Rejected by System';
            update pr1;
            
            
            List<Id> receiptList = new List<Id>();
            List<Receipt__c> receiptsList = new List<Receipt__c>();
            receiptList.add(rrq.id);
            receiptsList.add(rrq);
            
            PageReference pref = Page.PrintReceiptSobhaDubai;       
            pref.getParameters().put('id',rrq.id);
            Test.setCurrentPage(pref);
            
            ApexPages.StandardController con = new ApexPages.StandardController(rrq);
            //PaymentRequestReceiptEmail.sendAttachedReceiptbatch(receiptsList);
            //PaymentRequestReceiptEmail.AttachReceiptbatch(receiptsList);
            
            
            List<Unit_Hold_Request__c> req = [SELECT Id,Approval_Status__c,Agent_Name__c,Booking__c,Payment_Request__r.Cheque_Date__c,Payment_Request__r.Cheque_No__c,Payment_Request__r.Mode__c,Mode__c,(select id from Receipts__r) FROM unit_hold_request__c];
            System.debug('I am req'+ req);
            for(Unit_Hold_Request__c u : req){
                u.Approval_Status__c = 'Approved';
                update u;
            }
            
            //PaymentRequestReceiptCreationOneTime obj1 = new PaymentRequestReceiptCreationOneTime();
            //list<Payment_Request__c> tmpListNew = [SELECT Id,Status__c,Currency__c,Original_Amount__c,Booking__c,Amount__c,Amount_Towards__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c,Towards_Unit_Price_Amount__c,Booking__r.Unit__r.Name,Booking__r.Project__c,Payment_Transaction_Tracking_Id__c,Account_Received_Date__c,Approved_Date_and_Time__c,Account_Master__c,Instrument_Date__c,Instrument_Number__c,Reference_Number__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Transaction_Number__c,CreatedDate,Unit__c,Cheque_Date__c,Cheque_No__c,Mode__c,Others__c,(select id from Receipts__r) FROM Payment_Request__c WHERE Id =: pr1.Id];
            //obj1.execute(null, tmpListNew);
            
            PaymentRequestReceiptSchedule sh1 = new PaymentRequestReceiptSchedule();
            String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1);
            
            Test.stopTest();
            
        }
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
    
   
    
    
}
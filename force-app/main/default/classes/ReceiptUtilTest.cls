@isTest public class ReceiptUtilTest {
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
            b.status__c = 'Cancelled';
            b.Quotation__c = quote.Id;
            b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
            b.Future_Correspondence_Contact__c = 'First Applicant';
            b.Agreement_Value__c = 6000000;
            b.Stage_of_Booking__c = 'Booked';
            insert b;
            unit__c u1 = new unit__c();
            u1.id = unitid;
            u1.Unit_Status__c = 'Available';   
            u1.Reason_for_Cancellation__c = 'Test';
            update u1;
            
            List<Payment_Request__c> prInsertList = new LIst<Payment_Request__c>();
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
            pr1.from_booking__c = true;
            prInsertList.add(pr1);
            
            Payment_Request__c pr2 = new Payment_Request__c();
            pr2.name__c = 'yamini1';
            pr2.Booking__c=b.id;
            pr2.Email__c = 'yamini1.jakka@ceptes.com';
            pr2.Mobile_Number__c='95150987889';
            pr2.Emirates_Id_Passport_Number__c='12xgy';
            pr2.Mode__c = 'CDM Cheque';
            pr2.Status__c='Approved';
            pr2.Amount__c = 123;
            pr2.Unit__c = unitId;
            pr2.Approved_Date_and_Time__c=System.today();
            pr2.Towards_Other_Charges_Amount__c =10;
            pr2.Towards_Pre_Registration_Amount__c =23;
            pr2.Towards_Unit_Price_Amount__c = 100;
            pr2.from_booking__c = true;
            prInsertList.add(pr2);
            
            Payment_Request__c pr3 = new Payment_Request__c();
            pr3.name__c = 'yamini2';
            pr3.Booking__c=b.id;
            pr3.Email__c = 'yamini1.jakka@ceptes.com';
            pr3.Mobile_Number__c='95150987889';
            pr3.Emirates_Id_Passport_Number__c='12xgy';
            pr3.Mode__c = 'CDM Cash';
            pr3.Status__c='Approved';
            pr3.Amount__c = 123;
            pr3.Unit__c = unitId;
            pr3.Approved_Date_and_Time__c=System.today();
            pr3.Towards_Other_Charges_Amount__c =10;
            pr3.Towards_Pre_Registration_Amount__c =23;
            pr3.Towards_Unit_Price_Amount__c = 100;
            pr3.from_booking__c = true;
            prInsertList.add(pr3);
            
            Payment_Request__c pr4 = new Payment_Request__c();
            pr4.name__c = 'yamini3';
            pr4.Booking__c=b.id;
            pr4.Email__c = 'yamini1.jakka@ceptes.com';
            pr4.Mobile_Number__c='95150987889';
            pr4.Emirates_Id_Passport_Number__c='12xgy';
            pr4.Mode__c = 'Cheque';
            pr4.Status__c='Approved';
            pr4.Amount__c = 123;
            pr4.Unit__c = unitId;
            pr4.Approved_Date_and_Time__c=System.today();
            pr4.Towards_Other_Charges_Amount__c =10;
            pr4.Towards_Pre_Registration_Amount__c =23;
            pr4.Towards_Unit_Price_Amount__c = 100;
            pr4.from_booking__c = true;
            prInsertList.add(pr4);
            
            insert prInsertList;
            
            List<Payment_Request__c> prUpdateList = new LIst<Payment_Request__c>();
            pr1.Status__c = 'Approved';
            pr2.Status__c = 'Approved';
            pr3.Status__c = 'Approved';
            pr4.Status__c = 'Approved';
            prUpdateList.add(pr1);
            prUpdateList.add(pr2);
            prUpdateList.add(pr3);
            prUpdateList.add(pr4);
            update prUpdateList;
            
            Test.startTest();
             Account_Master__c am2 = new Account_Master__c();
            am2.Name = 'MAIN CASH'+Datetime.now();
            am2.Account_Number__c = '12345';
            am2.Type__c = 'Others';
            insert am2;
            am2.Account_Number__c = '123456';
             update am2;
            
            
            List<Payment_Request__c> prObj = [SELECT Id,Name FROM Payment_Request__c LIMIT 5];
            List<String> prNameList = new List<String>();
            for(Payment_Request__c pr: prObj){
            	prNameList.add(pr.Name);
            }
            ReceiptUtil.createReceiptBookingLevel(prNameList);
            
            Test.stopTest();
            
        }
    }
    
    @isTest
    public static void frrCreation() {
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
            b.status__c = 'Cancelled';
            b.Quotation__c = quote.Id;
            b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
            b.Future_Correspondence_Contact__c = 'First Applicant';
            b.Agreement_Value__c = 6000000;
            b.Stage_of_Booking__c = 'Booked';
            insert b;
            
            
            unit__c u = new unit__c();
            u.id = unitid;
            u.Unit_Status__c = 'Available'; 
            u.Reason_for_Cancellation__c = 'Test';
            update u;
            
            List<Payment_Request__c> paymentReqList = new List<Payment_Request__c>();
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
            pr.from_booking__c = true;
            pr.Approved_Date_and_Time__c=System.today();    
            pr.ownerid = userinfo.getuserid();
            pr.Sales_Manager__c = userinfo.getuserid();
            paymentReqList.add(pr);
            
            Payment_Request__c pr1 = new Payment_Request__c();
            pr1.name__c = 'yamini';
            pr1.Booking__c=b.id;
            pr1.Email__c = 'yamini.jakka@ceptes.com';
            pr1.Mobile_Number__c='9550987889';
            pr1.Emirates_Id_Passport_Number__c='12xgy';
            pr1.Mode__c = 'CDM Cash';
            pr1.Status__c='Approved';
            pr1.Amount__c = 123;
            pr1.Unit__c = unitId;
            pr1.from_booking__c = true;
            pr1.Approved_Date_and_Time__c=System.today();    
            pr1.ownerid = userinfo.getuserid();
            pr1.Sales_Manager__c = userinfo.getuserid();
            paymentReqList.add(pr1);
            
            Payment_Request__c pr2 = new Payment_Request__c();
            pr2.name__c = 'yamini';
            pr2.Booking__c=b.id;
            pr2.Email__c = 'yamini.jakka@ceptes.com';
            pr2.Mobile_Number__c='9550987889';
            pr2.Emirates_Id_Passport_Number__c='12xgy';
            pr2.Mode__c = 'Cheque';
            pr2.Status__c='Approved';
            pr2.Amount__c = 123;
            pr2.Unit__c = unitId;
            pr2.from_booking__c = true;
            pr2.Approved_Date_and_Time__c=System.today();    
            pr2.ownerid = userinfo.getuserid();
            pr2.Sales_Manager__c = userinfo.getuserid();
            paymentReqList.add(pr2);
            
            insert paymentReqList;
            
            List<unit_hold_request__c> uhrInsertList = new List<unit_hold_request__c>();
            unit_hold_request__c newsale = new unit_hold_request__c();
            newsale.Agent_Name__c = 'yamni';
            newsale.Blocking_Amount_Paid__c = 123;
            newsale.Payment_Request__c = paymentReqList[0].Id;
            newsale.Booking__c = b.id;
            newsale.Approval_Status__c = 'Approved';
            newsale.DLD_Amount__c = 1234;
            newsale.DLD_Amount_2__c = 1342;
            newsale.DP_Amount_2__c = 321;
            newsale.How_Many_Applicants__c = 'One Applicant';
            newsale.Sales_Head_Value__c = usr.id;
            newsale.Sales_Head_VP__c = usr.id;
            newsale.Sales_Manager_Value__c = usr.id;
            newsale.Approved_Date__c = System.today()+5;
            newsale.DP_Amount__c = 1234;
            //newsale.ownerid = userinfo.getuserid();
            
            uhrInsertList.add(newsale);
            
            unit_hold_request__c newsale1 = new unit_hold_request__c();
            newsale1.Agent_Name__c = 'yamni1';
            newsale1.Blocking_Amount_Paid__c = 123;
            newsale1.Payment_Request__c = paymentReqList[0].Id;
            newsale1.Booking__c = b.id;
            newsale1.Approval_Status__c = 'Approved';
            newsale1.DLD_Amount__c = 1234;
            newsale1.DP_Amount__c = 1234;
            newsale1.DLD_Amount_2__c = 1342;
            newsale1.DP_Amount_2__c = 321;
            newsale1.How_Many_Applicants__c = 'One Applicant';
            newsale1.Sales_Head_Value__c = usr.id;
            newsale1.OwnerId = usr.id;
            newsale1.Sales_Head_VP__c = usr.id;
            newsale1.Sales_Manager_Value__c = usr.id;
            newsale.Approved_Date__c = System.today()+5;
            //newsale1.ownerid = userinfo.getuserid();
            uhrInsertList.add(newsale1);
            
            unit_hold_request__c newsale2 = new unit_hold_request__c();
            newsale2.Agent_Name__c = 'yamni2';
            newsale2.Blocking_Amount_Paid__c = 123;
            newsale2.Payment_Request__c = paymentReqList[1].Id;
            newsale2.Booking__c = b.id;
            newsale2.Approval_Status__c = 'Approved';
            newsale2.DLD_Amount__c = 1234;
            newsale2.DP_Amount__c = 1234;
            newsale2.DLD_Amount_2__c = 1342;
            newsale2.DP_Amount_2__c = 321;
            newsale2.How_Many_Applicants__c = 'One Applicant';
            newsale2.Sales_Head_Value__c = usr.id;
            newsale2.OwnerId = usr.id;
            newsale2.Sales_Head_VP__c = usr.id;
            newsale2.Sales_Manager_Value__c = usr.id;
            newsale2.Approved_Date__c = System.today()+5;
            //newsale1.ownerid = userinfo.getuserid();
            uhrInsertList.add(newsale2);
            
            unit_hold_request__c newsale3 = new unit_hold_request__c();
            newsale3.Agent_Name__c = 'yamni3';
            newsale3.Blocking_Amount_Paid__c = 123;
            newsale3.Payment_Request__c = paymentReqList[2].Id;
            newsale3.Booking__c = b.id;
            newsale3.Approval_Status__c = 'Approved';
            newsale3.DLD_Amount__c = 1234;
            newsale3.DP_Amount__c = 1234;
            newsale3.DLD_Amount_2__c = 1342;
            newsale3.DP_Amount_2__c = 321;
            newsale3.How_Many_Applicants__c = 'One Applicant';
            newsale3.Sales_Head_Value__c = usr.id;
            newsale3.OwnerId = usr.id;
            newsale3.Sales_Head_VP__c = usr.id;
            newsale3.Sales_Manager_Value__c = usr.id;
            newsale3.Approved_Date__c = System.today()+5;
            //newsale1.ownerid = userinfo.getuserid();
            uhrInsertList.add(newsale3);
            insert uhrInsertList;
            
            Test.startTest();
            List<String> uhrNameList = new List<String>();
            List<Unit_Hold_Request__c> req = [SELECT Id,Name,Approval_Status__c,Agent_Name__c,Booking__c,Booking__r.Project__c,Payment_Request__r.Cheque_Date__c,Payment_Request__r.Cheque_No__c,Payment_Request__r.Mode__c,Mode__c,(select id from Receipts__r) FROM unit_hold_request__c];
            List<Unit_Hold_Request__c> updateList = new List<Unit_Hold_Request__c>();
            for(Unit_Hold_Request__c u1 : req){
                u1.Approval_Status__c = 'Approved';
                updateList.add(u1);
                uhrNameList.add(u1.Name);
            }
            update updateList;
            
            //uhrNameList.add(req[0].Name);
            ReceiptUtil.createReceiptUnitLevel(uhrNameList);
            
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
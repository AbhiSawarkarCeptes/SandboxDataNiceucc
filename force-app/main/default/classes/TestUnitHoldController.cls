@isTest
public class TestUnitHoldController {
     @isTest
    private static void test3(){

        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Name='paymentPlan';
        pp.NoofMilestones__c =22;
        pp.Tower__c = tower.id;
        insert pp;
        
        Opportunity opp1 = [SELECT Id, StageName, S_Active__c, Unit__c, Booking__c FROM Opportunity  WHERE Id = :optyId];
        opp1.StageName = 'Booking confirmed';
        opp1.S_Active__c = true;
        opp1.Unit__c = unitId;
        //  opp1.Booking__c = b.Id;
        update opp1;
        
        Quotation__c objQuote2 = new Quotation__c();        
        objQuote2.Opportunity__c = opp1.id ;
        objQuote2.Payment_Plan__c = pp.Id ;
        // objQuote1.Unit__c = ut1;
        objQuote2.Basic_Original_PSF__c = 12;
        objQuote2.Charge1Bucket__c = 'Agreement Value';
        objQuote2.Charge2Value__c = 1123;
        insert objQuote2;
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = recordMap.get('PROJECT');
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = objQuote2.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Primary_Applicant_Email__c = 'test123@stetig.in';
        insert b;
        
        Opportunity opp = [SELECT Id, StageName, S_Active__c, Unit__c, Booking__c FROM Opportunity  WHERE Id = :optyId];
        opp.StageName = 'Booking confirmed';
        opp.S_Active__c = true;
        opp.Unit__c = unitId;
        opp.Booking__c = b.Id;
        update opp;

        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp.id ;
        objQuote1.Payment_Plan__c = pp.Id ;
        // objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        insert objQuote1;
        
        Unit__c u = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Booking__c = b.Id;
        u.Customers__c = opp.Id;
        u.Unit_Status__c='Available';
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
 
        list<Units_Hold_For_SM__c> uh1 = new list<Units_Hold_For_SM__c>();
        Units_Hold_For_SM__c uh = new Units_Hold_For_SM__c();
        uh.Payment_Type__c = 'Draft';
        uh.Unit__c = u.id;
        uh.Approval_Status__c ='Rejected';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Status_O__c = 'UnderWriting';
        uh1.add(uh);
        
        Units_Hold_For_SM__c uh4 = new Units_Hold_For_SM__c();
        uh4.Payment_Type__c = 'Draft';
        uh4.Unit__c = u.id;
        uh4.Approval_Status__c ='Rejected';
        uh4.Sales_Manager__c = UserInfo.getUserId();
        uh4.Status_O__c = 'UnderWriting';
        uh1.add(uh4);
        
         Units_Hold_For_SM__c uhf = new Units_Hold_For_SM__c();
        uhf.Payment_Type__c = 'Draft';
        uhf.Unit__c = u.id;
        uhf.Approval_Status__c ='Pending for Approval';
        uhf.Sales_Manager__c = UserInfo.getUserId();
        uhf.Status_O__c = 'Payment Collected';
        uh1.add(uhf);
        
        Units_Hold_For_SM__c uhf1 = new Units_Hold_For_SM__c();
        uhf1.Payment_Type__c = 'Draft';
        uhf1.Unit__c = u.id;
        uhf1.Approval_Status__c =null;
        uhf1.Sales_Manager__c = UserInfo.getUserId();
        uhf1.Status_O__c = 'Payment Collected';
        uh1.add(uhf1);
        insert uh1;
        
        Blob b1 = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = uhf1.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b1;
        
         Blob b2 = Blob.valueOf('Test Data');
        Attachment attachment1 = new Attachment();
        attachment1.ParentId = uhf.Id;
        attachment1.Name = 'Test Attachment for Parent';
        attachment1.Body = b2;
        
         Blob b3 = Blob.valueOf('Test Data');
        Attachment attachment2 = new Attachment();
        attachment2.ParentId = uhf.Id;
        attachment2.Name = 'Test Attachment for Parent';
        attachment2.Body = b3;
        
        unit_hold_request__c newSale = new unit_hold_request__c();
        newSale.Approval_Status__c='Pending';
        newSale.Units_Hold_Request_Form__c = uh.id;
        newSale.Client_Phone_No__c = '8903823';
        newSale.Client_Address__c ='test address';
        newSale.Deal_Type_Wholesale_Retail__c ='Retail';
        newSale.Client_E_mail_Address__c ='test_123@gmail.com';
        newSale.Agent_Name__c ='test agent name';
        newSale.Remarks_If_Any__c ='test';
        newSale.Discount_from_Sobha_If_Applicable__c = 10;
  		newSale.Sales_Head_VP__c = UserInfo.getUserId();
        newSale.How_Many_Applicants__c = 'One Applicant';
        insert newSale; 
      
        Unit__c u1 = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u1.Unit_Status__c = 'Sold';
        u1.Booking__c = b.Id;
        u1.Customers__c = opp.Id;
        u1.Unit_Status__c='Available';
        update u1;
       
        u1.Unit_Status__c = 'Sold';
        u1.Booking__c = b.Id;
        u1.Customers__c = opp.Id;
        u1.Unit_Status__c='Available';
        update u1;
    
        u1.Unit_Status__c='Available';
        update u1;
        Test.startTest();
        
        UnitHoldController.submit(uhf.Id);
        TRY{
         uh.Approval_Status__c = 'Approved';
        update uh;
        UnitHoldController.submit(uh.Id);
        uh.Approval_Status__c = 'Rejected';
        UnitHoldController.submit(uh4.Id);
        update uh;
        UnitHoldController.submit(uh.Id);
        uh.Approval_Status__c = '';
        update uh;
        system.debug('i am in uh'+uh);
        UnitHoldController.submit(uh.Id);
        }CATCH(exception e){
         
        }
        
       
        Test.stopTest();
    }
    
     @isTest
    private static void test5(){

        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Name='paymentPlan';
        pp.NoofMilestones__c =22;
        pp.Tower__c = tower.id;
        insert pp;
        
        Opportunity opp1 = [SELECT Id, StageName, S_Active__c, Unit__c, Booking__c FROM Opportunity  WHERE Id = :optyId];
        opp1.StageName = 'Booking confirmed';
        opp1.S_Active__c = true;
        opp1.Unit__c = unitId;
        //  opp1.Booking__c = b.Id;
        update opp1;
        
        Quotation__c objQuote2 = new Quotation__c();        
        objQuote2.Opportunity__c = opp1.id ;
        objQuote2.Payment_Plan__c = pp.Id ;
        // objQuote1.Unit__c = ut1;
        objQuote2.Basic_Original_PSF__c = 12;
        objQuote2.Charge1Bucket__c = 'Agreement Value';
        objQuote2.Charge2Value__c = 1123;
        insert objQuote2;
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = recordMap.get('PROJECT');
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = objQuote2.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Primary_Applicant_Email__c = 'test123@stetig.in';
        insert b;
        
        Opportunity opp = [SELECT Id, StageName, S_Active__c, Unit__c, Booking__c FROM Opportunity  WHERE Id = :optyId];
        opp.StageName = 'Booking confirmed';
        opp.S_Active__c = true;
        opp.Unit__c = unitId;
        opp.Booking__c = b.Id;
        update opp;

        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp.id ;
        objQuote1.Payment_Plan__c = pp.Id ;
        // objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        insert objQuote1;
        
        Unit__c u = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Booking__c = b.Id;
        u.Customers__c = opp.Id;
        u.Unit_Status__c='Available';
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
 
        list<Units_Hold_For_SM__c> uh1 = new list<Units_Hold_For_SM__c>();
        Units_Hold_For_SM__c uh = new Units_Hold_For_SM__c();
        uh.Payment_Type__c = 'Draft';
        uh.Unit__c = u.id;
        uh.Approval_Status__c ='Rejected';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Status_O__c = 'Payment Collected';
        uh1.add(uh);
        
         Units_Hold_For_SM__c uhf = new Units_Hold_For_SM__c();
        uhf.Payment_Type__c = 'Draft';
        uhf.Unit__c = u.id;
        uhf.Approval_Status__c ='Pending for Approval';
        uhf.Sales_Manager__c = UserInfo.getUserId();
        uhf.Status_O__c = 'Payment Collected';
        uh1.add(uhf);
        
        Units_Hold_For_SM__c uhf1 = new Units_Hold_For_SM__c();
        uhf1.Payment_Type__c = 'Draft';
        uhf1.Unit__c = u.id;
        uhf1.Approval_Status__c ='Pending for Approval';
        uhf1.Sales_Manager__c = UserInfo.getUserId();
        uhf1.Status_O__c = 'Payment Collected';
        uh1.add(uhf1);
        insert uh1;
        
        unit_hold_request__c newSale = new unit_hold_request__c();
        newSale.Approval_Status__c='Pending';
        newSale.Units_Hold_Request_Form__c = uh.id;
        newSale.Client_Phone_No__c = '8903823';
        newSale.Client_Address__c ='test address';
        newSale.Deal_Type_Wholesale_Retail__c ='Retail';
        newSale.Client_E_mail_Address__c ='test_123@gmail.com';
        newSale.Agent_Name__c ='test agent name';
        newSale.Remarks_If_Any__c ='test';
        newSale.Discount_from_Sobha_If_Applicable__c = 10;
  		newSale.Sales_Head_VP__c = UserInfo.getUserId();
        newSale.How_Many_Applicants__c = 'One Applicant';
        insert newSale; 
      
        Unit__c u1 = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u1.Unit_Status__c = 'Sold';
        u1.Booking__c = b.Id;
        u1.Customers__c = opp.Id;
        u1.Unit_Status__c='Available';
        update u1;
       
        u1.Unit_Status__c = 'Sold';
        u1.Booking__c = b.Id;
        u1.Customers__c = opp.Id;
        u1.Unit_Status__c='Available';
        update u1;
    
        u1.Unit_Status__c='Available';
        update u1;
        Test.startTest();
        uhf1.Approval_Status__c = null;
        update uhf1; 
        UnitHoldController.submit(uhf1.Id);
        system.debug('i am in uhfq'+uhf1);
        Test.stopTest();
    }
    
    @isTest
    private static void test4(){
        
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Name='paymentPlan';
        pp.NoofMilestones__c =22;
        pp.Tower__c = tower.id;
        insert pp;
        
        Opportunity opp1 = [SELECT Id, StageName, S_Active__c, Unit__c, Booking__c FROM Opportunity  WHERE Id = :optyId];
        opp1.StageName = 'Booking confirmed';
        opp1.S_Active__c = true;
        opp1.Unit__c = unitId;
        //  opp1.Booking__c = b.Id;
        update opp1;
        
        Quotation__c objQuote2 = new Quotation__c();        
        objQuote2.Opportunity__c = opp1.id ;
        objQuote2.Payment_Plan__c = pp.Id ;
        // objQuote1.Unit__c = ut1;
        objQuote2.Basic_Original_PSF__c = 12;
        objQuote2.Charge1Bucket__c = 'Agreement Value';
        objQuote2.Charge2Value__c = 1123;
        insert objQuote2;
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = recordMap.get('PROJECT');
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = objQuote2.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Primary_Applicant_Email__c = 'test123@stetig.in';
        insert b;
        
        
        
        Opportunity opp = [SELECT Id, StageName, S_Active__c, Unit__c, Booking__c FROM Opportunity  WHERE Id = :optyId];
        opp.StageName = 'Booking confirmed';
        opp.S_Active__c = true;
        opp.Unit__c = unitId;
        opp.Booking__c = b.Id;
        update opp;
        
        
        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp.id ;
        objQuote1.Payment_Plan__c = pp.Id ;
        // objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        insert objQuote1;
        
        
        //  Quotation__c quote = createQuotation(recordMap.get('OPPORTUNITY'), recordMap.get('UNIT'));
        
        
        Unit__c u = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Booking__c = b.Id;
        u.Customers__c = opp.Id;
        u.Unit_Status__c='Available';
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
        
        list<Units_Hold_For_SM__c> uh1 = new list<Units_Hold_For_SM__c>();
        Units_Hold_For_SM__c uh = new Units_Hold_For_SM__c();
        uh.Payment_Type__c = 'Draft';
        uh.Unit__c = u.id;
        uh.Approval_Status__c ='Approved';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh1.add(uh);
        insert uh1;
        
        unit_hold_request__c newSale = new unit_hold_request__c();
        newSale.Approval_Status__c='Pending';
        newSale.Units_Hold_Request_Form__c = uh.id;
        newSale.Client_Phone_No__c = '8903823';
        newSale.Client_Address__c ='test address';
        newSale.Deal_Type_Wholesale_Retail__c ='Retail';
        newSale.Client_E_mail_Address__c ='test_123@gmail.com';
        newSale.Agent_Name__c ='test agent name';
        newSale.Remarks_If_Any__c ='test';
        newSale.Discount_from_Sobha_If_Applicable__c = 10;
  		newSale.Sales_Head_VP__c = UserInfo.getUserId();
        newSale.How_Many_Applicants__c = 'One Applicant';
        insert newSale;
        
        List<Id> newSaleApprovalIds = new List<Id>();
        newSaleApprovalIds.add(newSale.Id);
        
        Test.startTest();
        	UnitHoldController.updateNSABookingFormUser(newSaleApprovalIds);
        Test.stopTest();
        

        }
}
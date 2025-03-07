@istest
public class NewSaleMockControllerTest {
      @isTest
    private static void updateAmount(){
        
        
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
        u.reason_for_cancellation__c = 'test';
       
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
        
        
        
        
        list<Payment_Request_Mock__c> uh1 = new list<Payment_Request_Mock__c>();
        Payment_Request_Mock__c uh = new Payment_Request_Mock__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Unit__c = u.id;
        uh.Status__c ='Approved';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.pop_Amount__c = 100000;
        uh.pop_Amount__c = 100000;
         uh.Currency__c ='USD';
        uh.Mobile_Number__c = '1234567898';
        insert uh;
        Test.startTest();
        Payment_Request_Mock__c pr1 = new Payment_Request_Mock__c();
        pr1.mode__C = 'International Wire Transfer';
        pr1.Unit__c = u.id;
        pr1.Status__c ='Approved';
        pr1.Sales_Manager__c = UserInfo.getUserId();
        pr1.Amount__c = 100000;
        pr1.Total_Amount__c = 100000;
        pr1.pop_Amount__c = 100000;
        pr1.Mode_Option__c = 'Single Mode';
        pr1.Payment_Request_Mock__c = uh.id;
        pr1.Currency__c ='USD';
        pr1.Mobile_Number__c = '1234567898';
        insert pr1;
        uh.Payment_Request_Mock__c = pr1.id;
        update uh;
        New_Sale_Approval_Mock__c newSale = new New_Sale_Approval_Mock__c();
        newSale.Approval_Status__c='Pending';
        newSale.Payment_Request_Mock__c = uh.id;
        newSale.Client_Phone_No__c = '8903823';
        newSale.Client_Address__c ='test address';
        newSale.Deal_Type_Wholesale_Retail__c ='Retail';
        newSale.Client_E_mail_Address__c ='test_123@gmail.com';
        newSale.Agent_Name__c ='test agent name';
        newSale.Remarks_If_Any__c ='test';
        newSale.Discount_from_Sobha_If_Applicable__c = 10;
        newSale.Sales_Head_VP__c = UserInfo.getUserId();
        newSale.Sales_Head_Value__c = UserInfo.getUserId();
        newSale.How_Many_Applicants__c = 'One Applicant';
        newSale.dld_amount__c = 100;
        newSale.dp_amount__c = 100;
        insert newSale; 
        
       
      
         
        
         u.Unit_Status__c='Available';
        update u;
        Payment_Request_Mock__c uh2 = new Payment_Request_Mock__c();
        uh2.mode__c = 'International Wire Transfer';
        uh2.Unit__c = u.id;
        uh2.Status__c ='Approved';
        uh2.Sales_Manager__c = UserInfo.getUserId();
        uh2.Amount__c = 10000;
        uh2.Total_Amount__c = 100000;
        uh2.pop_Amount__c = 100000;
         uh2.Currency__c ='USD';
        uh2.Payment_Request_Mock__c = uh.id;
        uh2.mode_option__c = 'Single Mode';
        uh2.Mobile_Number__c = '12242356';
        insert uh2; 
        
       // UpdateAmountOnNewSaleApprovalController.getNewSaleApproval(uh2.id);
        Cancelled_Unit_Detail__c ob = new Cancelled_Unit_Detail__c();
        ob.Amount__c = 500;
        NewSaleMockButtonController.saveCancelledUnitDetails(JSON.serialize(ob));
        
        Test.stopTest();
        
        
    }   
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
        
        User userRec = [Select id from user where Profile.Name LIKE '%System Administrator%' and isActive = true LIMIT 1];
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
        b.Sales_Managers__c = userRec.Id;
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
        u.reason_for_cancellation__c = 'test';
       
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
        
        
        
        
        list<Payment_Request_Mock__c> uh1 = new list<Payment_Request_Mock__c>();
        Payment_Request_Mock__c uh = new Payment_Request_Mock__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Unit__c = u.id;
        uh.Status__c ='Approved';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.pop_Amount__c = 100000;
         uh.Currency__c ='USD';
        uh.Mobile_Number__c = '1234567898';
        insert uh;
        
        Payment_Request_Mock__c pr1 = new Payment_Request_Mock__c();
        pr1.mode__C = 'International Wire Transfer';
        pr1.Unit__c = u.id;
        pr1.Status__c ='Approved';
        pr1.Sales_Manager__c = UserInfo.getUserId();
        pr1.Amount__c = 100000;
        pr1.Total_Amount__c = 100000;
        pr1.pop_Amount__c = 100000;
        pr1.Mode_Option__c = 'Single Mode';
        pr1.Payment_Request_Mock__c = uh.id;
        pr1.Currency__c ='USD';
        pr1.Mobile_Number__c = '1234567898';
        insert pr1;
               
        
         Test.startTest();
         New_Sale_Approval_Mock__c newSale = new New_Sale_Approval_Mock__c();
         newSale.Approval_Status__c='Pending';
         newSale.Payment_Request_Mock__c = uh.id;
         newSale.Client_Phone_No__c = '8903823';
         newSale.Client_Address__c ='test address';
         newSale.Deal_Type_Wholesale_Retail__c ='Retail';
         newSale.Client_E_mail_Address__c ='test_123@gmail.com';
         newSale.Agent_Name__c ='test agent name';
         newSale.Remarks_If_Any__c ='test';
         newSale.Discount_from_Sobha_If_Applicable__c = 10;
         newSale.Sales_Head_VP__c = UserInfo.getUserId();
         newSale.Sales_Head_Value__c = UserInfo.getUserId();
         newSale.How_Many_Applicants__c = 'One Applicant';
         newSale.dld_amount__c = 100;
         newSale.dp_amount__c = 100;
         insert newSale; 
        NewSaleMockButtonController.getUnitHoldData(uh.Id);
        NewSaleMockButtonController.getUnitHoldData(pr1.Id);
        NewSaleMockButtonController.getPaymentPlans(uh.id);
        NewSaleMockButtonController.getPaymentPlanId('paymentPlan', uh.id);
        NewSaleMockButtonController.getOpportunityDetails(opp.id,'Digital');
        NewSaleMockButtonController.getPaymentPlanId('Others', uh.id);
        // UnitHoldRequestFormController.getOpportunityDetails(null);
        uh.status__c = 'Rejected by System';
        Unit__c u1 = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u1.Unit_Status__c = 'Sold';
        u1.Booking__c = b.Id;
        u1.Customers__c = opp.Id;
        u1.Unit_Status__c='Available';
        update u1;
        update uh;
        
        
        //NewSaleMockButtonController.getUnitHoldData(uh.Id);
        
        Channel_Partner__c ch = new Channel_Partner__c(Name='Test Ch Name');
        insert ch;
        
        u1.Unit_Status__c = 'Sold';
        u1.Booking__c = b.Id;
        u1.Customers__c = opp.Id;
        u1.Unit_Status__c='Available';
        update u1;
        
        opp.Channel_Partner__c = ch.id;
        update opp;
        //NewSaleMockButtonController.getUnitHoldData(uh.Id);
        
        // ch.Name = '';
        //update ch;
        Sobha_Connect__c sc = new Sobha_Connect__c(Name__c='test sc');
        insert sc;
        
        u1.Unit_Status__c='Available';
        update u1;
        
        
        Payment_Request_Mock__c uh2 = new Payment_Request_Mock__c();
        uh2.mode__c = 'OTC Deposits';
        uh2.Unit__c = u.id;
        uh2.Status__c ='Approved';
        uh2.Sales_Manager__c = UserInfo.getUserId();
        uh2.Amount__c = 10000;
        uh2.Total_Amount__c = 100000;
        uh2.pop_Amount__c = 100000;
         uh2.Currency__c ='AED';
        uh2.Mobile_Number__c = '1234567878';
        insert uh2; 
        
        NewSaleMockButtonController.Value valueddata = new NewSaleMockButtonController.Value();
        valueddata.Body ='testdataa';
        valueddata.ContentType='testcontent';
        valueddata.Name ='testname';
        valueddata.parentID ='testmyname';
        
        NewSaleMockButtonController.uploadedDocs uplodaobject = new  NewSaleMockButtonController.uploadedDocs();
        uplodaobject.key ='1';
        uplodaobject.value =valueddata;
        
        List< NewSaleMockButtonController.uploadedDocs> listunitupload = new  List< NewSaleMockButtonController.uploadedDocs>();
        listunitupload.add(uplodaobject);
        String jsondata = JSON.serialize(listunitupload);
       	update new Booking__c(Id = b.Id, Status__c = 'Cancelled', Reason_For_Cancellation_D__c = 'xyz' );
		NewSaleMockButtonController.getUnitDetailsWithCatg(userRec.Id,'abc.abc@abc.com');       
        
        Test.stopTest();
        
        
    }   
    @isTest
    private static void test1(){
        
        
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
        u.reason_for_cancellation__c = 'test';
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
        
        list<Payment_Request_Mock__c> uh1 = new list<Payment_Request_Mock__c>();
        Payment_Request_Mock__c uh = new Payment_Request_Mock__c();
        uh.mode__C = 'OTC Deposits';
        uh.Unit__c = u.id;
        uh.Status__c ='Approved';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.pop_Amount__c = 100000;
         uh.Currency__c ='AED';
        uh.Mobile_Number__c = '1234567898';
        insert uh;
        
        Test.startTest();

        Payment_Request_Mock__c pr1 = new Payment_Request_Mock__c();
        pr1.mode__C = 'OTC Deposits';
        pr1.Unit__c = u.id;
        pr1.Status__c ='Approved';
        pr1.Sales_Manager__c = UserInfo.getUserId();
        pr1.Amount__c = 100000;
        pr1.pop_Amount__c = 100000;
        //pr1.Total_Amount__c = 100000;
        pr1.Mode_Option__c = 'Single Mode';
        pr1.Payment_Request_Mock__c = uh.id;
        pr1.Currency__c ='AED';
        pr1.Mobile_Number__c = '1234567898';
        insert pr1;
               
        New_Sale_Approval_Mock__c newSale = new New_Sale_Approval_Mock__c();
        newSale.Approval_Status__c='Pending';
        newSale.Payment_Request_Mock__c = uh.id;
        newSale.Client_Phone_No__c = '8903823';
        newSale.Client_Address__c ='test address';
        newSale.Deal_Type_Wholesale_Retail__c ='Retail';
        newSale.Client_E_mail_Address__c ='test_123@gmail.com';
        newSale.Agent_Name__c ='test agent name';
        newSale.Remarks_If_Any__c ='test';
        newSale.Discount_from_Sobha_If_Applicable__c = 10;
        newSale.Sales_Head_VP__c = UserInfo.getUserId();
        newSale.Sales_Head_Value__c = UserInfo.getUserId();
        newSale.How_Many_Applicants__c = 'One Applicant';
        newSale.dld_amount__c = 100;
        newSale.dp_amount__c = 100;
        insert newSale; 
        
        
        
        NewSaleMockButtonController.getPaymentPlans(uh.id);
        NewSaleMockButtonController.getPaymentPlanId('paymentPlan', uh.id);
        NewSaleMockButtonController.getOpportunityDetails(opp.id,'digital');
        NewSaleMockButtonController.getPaymentPlanId('Others', uh.id);
        // UnitHoldRequestFormController.getOpportunityDetails(null);
        uh.status__c = 'Rejected by System';
        Unit__c u1 = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u1.Unit_Status__c = 'Sold';
        u1.Booking__c = b.Id;
        u1.Customers__c = opp.Id;
        u1.Unit_Status__c='Available';
        update u1;
        update uh;
        
        
      
        // ch.Name = '';
        //update ch;
        Sobha_Connect__c sc = new Sobha_Connect__c(Name__c='test sc');
        insert sc;
        
        u1.Unit_Status__c='Available';
        update u1;
        
        
        Payment_Request_Mock__c uh2 = new Payment_Request_Mock__c();
        uh2.mode__c = 'OTC Deposits';
        uh2.Unit__c = u.id;
        uh2.Status__c ='Approved';
        uh2.Sales_Manager__c = UserInfo.getUserId();
        uh2.Amount__c = 10000;
        uh2.pop_Amount__c = 100000;
       // uh2.Total_Amount__c = 100000;
       uh2.Mobile_Number__c = '12242356';
         uh2.Currency__c ='AED';
        insert uh2; 
         
        NewSaleMockButtonController.Value valueddata = new NewSaleMockButtonController.Value();
        valueddata.Body ='testdataa';
        valueddata.ContentType='testcontent';
        valueddata.Name ='testname';
        valueddata.parentID ='testmyname';
        
        NewSaleMockButtonController.uploadedDocs uplodaobject = new  NewSaleMockButtonController.uploadedDocs();
        uplodaobject.key ='1';
        uplodaobject.value =valueddata;
        
        List< NewSaleMockButtonController.uploadedDocs> listunitupload = new  List< NewSaleMockButtonController.uploadedDocs>();
        listunitupload.add(uplodaobject);
        String jsondata = JSON.serialize(listunitupload);
        
       
        NewSaleMockButtonController.getUnitHoldData(uh2.Id);
        //NewSaleMockButtonController.saveAttachements(uh2.id, jsondata);
        newSale.Approval_Status__c = 'Approved';
        newSale.Payment_Request_Mock__c = uh2.id;
        update newSale;
       // UpdateAmountOnNewSaleApprovalController.getNewSaleApproval(uh2.id);
        try{
              ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion;
			List<Id> contentDocId = new List<Id>();
            for(ContentDocument documents : [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]){
                	contentDocId.add(documents.id);
            }
            
            NewSaleMockButtonController.saveAttachements(newSale.id, contentDocId,new List<String> {contentDocId+'###test'}); 
        }catch(Exception e){
            System.debug('Testing the exception scenario, error in test class - '+ e.getMessage());
        }
        try{
            UpdateAmountOnNewSaleApprovalController.getNewSaleApproval('test');
        }catch(exception e){
            
        }
        NewSaleMockButtonController.extraMethod();
        Test.stopTest();
        
        
    }  
}
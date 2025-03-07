@IsTest(SeeAllData=false)
public class PaymentPublicPageControllerCopy_Test {
    
    @testSetup
    public static void testdata(){
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        
        insert uhw;
    }

    @isTest
    private static void testGetPayment() {
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
        b.status__c = 'Cancelled';
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
        u.Reason_for_Cancellation__c = 'Test';
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
        
    

        
        
        
        Account acc2 = TestDataFactorySobha.createAccount(null);
        insert acc2;
        User u1 = TestDataFactorySobha.createUser(null);
        insert u1;
        Contact cont = TestDataFactorySobha.createContact(null);
        //insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower1 = TestDataFactorySobha.createTower(null);
        insert tower1;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Unit_Status__c ='Hold';
        insert prop;
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        
        insert uhw;
        
        list<Payment_Request__c> uh1 = new list<Payment_Request__c>();
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C ='OTC Deposits';
        uh.Unit__c = u.id;
        uh.Status__c ='Approved';
        uh.Mobile_Number__c = '9876543210';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Property__c = prop.id;
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.add(uh);
        insert uh1;
        
        
        
        
        uhw.Public_Payment_Link_Click_Counter__c = 1;
        uhw.Payment_Public_Link_Click_Log__c= 'test';
        update uhw;
        String jsonVal = '{"error_desc":"","invoice_id":"6921919","tiny_url":"http://payae.cc/P853E658D8C79558839589EBDD0C9EE44","qr_code":"iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9CAYAAACPgGwlAAACPElEQVR42u3dUW7EIAwFwNz_0u0VWuFnDMyT-lN10yyDRDAk-X7kuXyaALpAF-gCXaALdIEu0AW6QBfoAl2gC3SBLtAFOvTlg31f-c9fjr9ybivfcVc7QIcOHfpG9AnH-e_xVzrhSe0AHTp06Ac2ZmJ8rDrPqnaADh069IvRE_8r3TmhQ4cOHfp2oF3nDx06dOiPV-RWFlwSi0oqctChQ38EPb2efsrvbaKADh36BeidSWyp6hhPR7QddOjQoWfH9BXQXeczobIHHTp06BvH9MQXTN8QUXX9kOi00KFDhz4QvXPaVTVNS4z7ic9Chw4d-hD0zvvCJixwVF3DQIcOHfrAilzV3yQWUxLr-xPHcejQoUPf1AE6G61qOnZqZ4AOHTr0cEVr127Yqiri5OsW6NChQ--YIoS3GHU-9jPdCY9ecIEOHfoL6NOeOJHuVFV7A6BDhw79oDF9V1Vt1-7ZxDQQOnTo0IdU5Dqx0tcbiTH9yk0U0KFDvxV9ZVpUNd5NuG9uyi3J0KFDhx6Grvps531qN7xpETp06NAPyc6GSlYRPSYUOnTojz8FOl3pmvaKsePKsNChQ38BvfM46W1I6U7Vfd0CHTp06IFK2rQnKlctlJxUnYMOHTr0YegTdqsmrj2uqchBhw4dev_7x6dNJ698TCh06NBfQ090nqoxMXEr8fSdsdChQ4ceWJjorIClp2-da_rQoUOHvhFdzgh06AJdoAt0gS7QBbpAF-gCXaALdIEu0AW6QBfob-YXM_4b0h5WGEEAAAAASUVORK5CYII","invoice_status":0,"error_code":""}';
        CCAvenueResponse.parse(jsonVal);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CCAvenuepaymentLinkMock());
        PaymentPublicPageControllerCopy.getPaymentRequestData(uhw.Id);
        Test.stopTest();
        
    }
    
    @isTest
    private static void testGetPayment2() {
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
        b.status__c = 'Cancelled';
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
        u.Reason_for_Cancellation__c = 'Test';
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
        
    

        
        
        
        Account acc2 = TestDataFactorySobha.createAccount(null);
        insert acc2;
        User u1 = TestDataFactorySobha.createUser(null);
        insert u1;
        Contact cont = TestDataFactorySobha.createContact(null);
        //insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower1 = TestDataFactorySobha.createTower(null);
        insert tower1;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Unit_Status__c ='Hold';
        insert prop;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        
        insert uhw;
        
        list<Payment_Request__c> uh1 = new list<Payment_Request__c>();
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C ='OTC Deposits';
        uh.Unit__c = u.id;
        uh.Status__c ='Approved';
        uh.Mobile_Number__c = '9876543210';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Property__c = prop.id;
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.add(uh);
        insert uh1;
        
        
        
        uhw.Public_Payment_Link_Click_Counter__c = 1;
        uhw.Payment_Public_Link_Click_Log__c= 'test';
        update uhw;
        String jsonVal = '{"error_desc":"","invoice_id":"6921919","tiny_url":"http://payae.cc/P853E658D8C79558839589EBDD0C9EE44","qr_code":"iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9CAYAAACPgGwlAAACPElEQVR42u3dUW7EIAwFwNz_0u0VWuFnDMyT-lN10yyDRDAk-X7kuXyaALpAF-gCXaALdIEu0AW6QBfoAl2gC3SBLtAFOvTlg31f-c9fjr9ybivfcVc7QIcOHfpG9AnH-e_xVzrhSe0AHTp06Ac2ZmJ8rDrPqnaADh069IvRE_8r3TmhQ4cOHfp2oF3nDx06dOiPV-RWFlwSi0oqctChQ38EPb2efsrvbaKADh36BeidSWyp6hhPR7QddOjQoWfH9BXQXeczobIHHTp06BvH9MQXTN8QUXX9kOi00KFDhz4QvXPaVTVNS4z7ic9Chw4d-hD0zvvCJixwVF3DQIcOHfrAilzV3yQWUxLr-xPHcejQoUPf1AE6G61qOnZqZ4AOHTr0cEVr127Yqiri5OsW6NChQ--YIoS3GHU-9jPdCY9ecIEOHfoL6NOeOJHuVFV7A6BDhw79oDF9V1Vt1-7ZxDQQOnTo0IdU5Dqx0tcbiTH9yk0U0KFDvxV9ZVpUNd5NuG9uyi3J0KFDhx6Grvps531qN7xpETp06NAPyc6GSlYRPSYUOnTojz8FOl3pmvaKsePKsNChQ38BvfM46W1I6U7Vfd0CHTp06IFK2rQnKlctlJxUnYMOHTr0YegTdqsmrj2uqchBhw4dev_7x6dNJ698TCh06NBfQ090nqoxMXEr8fSdsdChQ4ceWJjorIClp2-da_rQoUOHvhFdzgh06AJdoAt0gS7QBbpAF-gCXaALdIEu0AW6QBfob-YXM_4b0h5WGEEAAAAASUVORK5CYII","invoice_status":0,"error_code":""}';
        CCAvenueResponse.parse(jsonVal);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CCAvenuepaymentLinkMock());
        PaymentPublicPageControllerCopy.paymentValidation(uhw.Id);
        PaymentPublicPageControllerCopy.getCCAvenuePaymentLink(uhw.Id);
        Test.stopTest();
        
    }
    
    @isTest
    private static void testGetPaymentStatus() {
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
        b.status__c = 'Cancelled';
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
        u.Reason_for_Cancellation__c = 'Test';
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;

        
        list<Payment_Request__c> uh1 = new list<Payment_Request__c>();
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C ='OTC Deposits';
        uh.Unit__c = u.id;
        uh.Status__c ='Approved';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Mobile_Number__c = '9876543210';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.add(uh);
        insert uh1;
        
        

        String jsonVal = '{"error_desc":"","invoice_id":"6921919","tiny_url":"http://payae.cc/P853E658D8C79558839589EBDD0C9EE44","qr_code":"iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9CAYAAACPgGwlAAACPElEQVR42u3dUW7EIAwFwNz_0u0VWuFnDMyT-lN10yyDRDAk-X7kuXyaALpAF-gCXaALdIEu0AW6QBfoAl2gC3SBLtAFOvTlg31f-c9fjr9ybivfcVc7QIcOHfpG9AnH-e_xVzrhSe0AHTp06Ac2ZmJ8rDrPqnaADh069IvRE_8r3TmhQ4cOHfp2oF3nDx06dOiPV-RWFlwSi0oqctChQ38EPb2efsrvbaKADh36BeidSWyp6hhPR7QddOjQoWfH9BXQXeczobIHHTp06BvH9MQXTN8QUXX9kOi00KFDhz4QvXPaVTVNS4z7ic9Chw4d-hD0zvvCJixwVF3DQIcOHfrAilzV3yQWUxLr-xPHcejQoUPf1AE6G61qOnZqZ4AOHTr0cEVr127Yqiri5OsW6NChQ--YIoS3GHU-9jPdCY9ecIEOHfoL6NOeOJHuVFV7A6BDhw79oDF9V1Vt1-7ZxDQQOnTo0IdU5Dqx0tcbiTH9yk0U0KFDvxV9ZVpUNd5NuG9uyi3J0KFDhx6Grvps531qN7xpETp06NAPyc6GSlYRPSYUOnTojz8FOl3pmvaKsePKsNChQ38BvfM46W1I6U7Vfd0CHTp06IFK2rQnKlctlJxUnYMOHTr0YegTdqsmrj2uqchBhw4dev_7x6dNJ698TCh06NBfQ090nqoxMXEr8fSdsdChQ4ceWJjorIClp2-da_rQoUOHvhFdzgh06AJdoAt0gS7QBbpAF-gCXaALdIEu0AW6QBfob-YXM_4b0h5WGEEAAAAASUVORK5CYII","invoice_status":0,"error_code":""}';
        CCAvenueResponse.parse(jsonVal);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CCAvenuepaymentLinkMock());
        PaymentPublicPageControllerCopy.getCCAvenuePaymentStatus(uh.Id);
        PaymentPublicPageControllerCopy.getPaymentRequestData(uhw.Id);
        Test.stopTest();
        
    }
    
    
    @isTest
    private static void testGetPaymentStatus2() {
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
        b.status__c = 'Cancelled';
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
        u.Reason_for_Cancellation__c = 'Test';
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
        
    

        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        list<Payment_Request__c> uh1 = new list<Payment_Request__c>();
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C ='OTC Deposits';
        uh.Unit__c = u.id;
        uh.Status__c ='Approved';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Mobile_Number__c = '9876543210';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.add(uh);
        insert uh1;
        
        
        
        String jsonVal = '{"error_desc":"","invoice_id":"6921919","tiny_url":"http://payae.cc/P853E658D8C79558839589EBDD0C9EE44","qr_code":"iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9CAYAAACPgGwlAAACPElEQVR42u3dUW7EIAwFwNz_0u0VWuFnDMyT-lN10yyDRDAk-X7kuXyaALpAF-gCXaALdIEu0AW6QBfoAl2gC3SBLtAFOvTlg31f-c9fjr9ybivfcVc7QIcOHfpG9AnH-e_xVzrhSe0AHTp06Ac2ZmJ8rDrPqnaADh069IvRE_8r3TmhQ4cOHfp2oF3nDx06dOiPV-RWFlwSi0oqctChQ38EPb2efsrvbaKADh36BeidSWyp6hhPR7QddOjQoWfH9BXQXeczobIHHTp06BvH9MQXTN8QUXX9kOi00KFDhz4QvXPaVTVNS4z7ic9Chw4d-hD0zvvCJixwVF3DQIcOHfrAilzV3yQWUxLr-xPHcejQoUPf1AE6G61qOnZqZ4AOHTr0cEVr127Yqiri5OsW6NChQ--YIoS3GHU-9jPdCY9ecIEOHfoL6NOeOJHuVFV7A6BDhw79oDF9V1Vt1-7ZxDQQOnTo0IdU5Dqx0tcbiTH9yk0U0KFDvxV9ZVpUNd5NuG9uyi3J0KFDhx6Grvps531qN7xpETp06NAPyc6GSlYRPSYUOnTojz8FOl3pmvaKsePKsNChQ38BvfM46W1I6U7Vfd0CHTp06IFK2rQnKlctlJxUnYMOHTr0YegTdqsmrj2uqchBhw4dev_7x6dNJ698TCh06NBfQ090nqoxMXEr8fSdsdChQ4ceWJjorIClp2-da_rQoUOHvhFdzgh06AJdoAt0gS7QBbpAF-gCXaALdIEu0AW6QBfob-YXM_4b0h5WGEEAAAAASUVORK5CYII","invoice_status":0,"error_code":""}';
        CCAvenueResponse.parse(jsonVal);
        Test.startTest();
        PaymentPublicPageControllerCopy.paymentValidation(uhw.Id);
        PaymentPublicPageControllerCopy.getCCAvenuePaymentLink(uhw.Id);
        Test.stopTest();
        
    }
    @isTest
    private static void coverCallOutClass() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new CCAvenuepaymentLinkMock());
        Payment_Request_Wrapper__c pwr = [SELECT id from Payment_Request_Wrapper__c]   ;
            PaymentPublicPageControllerCopy.getCCAvenuePaymentLink(pwr.Id);
        Test.stopTest();
    }
}
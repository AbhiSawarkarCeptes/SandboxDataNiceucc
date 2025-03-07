@isTest
public class PaymentRequestTriggerHandler_Test {
    @isTest
    static void testMethod1() {
         
       UserRole ur = new UserRole(Name = 'Sales Manager');
       insert ur;
       User u1 = TestDataFactorySobha.createUser(null);
       u1.userRoleId =ur.Id;
       insert u1;
        
        System.runAs(u1) {
            User u = TestDataFactorySobha.createUser(null);
            insert u;
            Account acc = TestDataFactorySobha.createAccount(null);
            insert acc; 
            Contact cont1 = TestDataFactorySobha.createContact(null);
            cont1.Birthdate = System.Today();
            cont1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            insert cont1;
            PropStrength__Request__c enq1 = TestDataFactorySobha.createEnquiry(null);
            insert enq1;
            PropStrength__Projects__c proj1 = TestDataFactorySobha.createProject(null);
            insert proj1;
            PropStrength__Property_Type__c propType1 = TestDataFactorySobha.createPropertyType(null);
            insert propType1;
            PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
            insert tower;
            PropStrength__Property__c prop1 = TestDataFactorySobha.createProperty(null);
            insert prop1;
            PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
            insert pp;
            PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
            insert offer;
            Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
            insert incSlab;
            PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
            insert ppRec;
            PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
            insert brkScheme;
            PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
            insert brkSlab;
            Test.StartTest();
            PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
            insert appBook;
            
            PropStrength__Projects__c proj = new PropStrength__Projects__c(Expiry_Days__c = 10, Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
            insert proj;
    
            PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
            insert propType;
            
            PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
            insert prop;
    
            PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
            insert ppd;
    
           
            Contact cont = new Contact();
            cont.FirstName = 'Test' + DateTime.now();
            cont.LastName = 'testKYCForm';
            cont.Email = 'test@test.com';
            insert cont;
    
            PropStrength__Request__c enq  = new PropStrength__Request__c();
            enq.PropStrength__Primary_Contact__c = cont.Id;
            enq.PropStrength__Project__c = proj.Id;
            insert enq;
    
            Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
            uhw.mode__C = 'website';
            uhw.Customer_Name__c = 'Testing';
            uhw.Email__c = 'test@test.com';
            uhw.Mobile_Number__c = '9999999999';
            uhw.Amount__c = 1.00;
            
            insert uhw;
            
            Payment_Request__c prTest = new Payment_Request__c();
            prTest.Mode__c = 'Credit Card';
            prTest.Status__c = 'Rejected by System';
            prTest.Enquiry__c = enq.Id;
            prTest.Property__c = prop.Id;
            prTest.Mobile_Mode_App__c = 'Website';
            prTest.Mode_Option__c = 'Multi Mode';
            prTest.Towards_Other_Charges_Amount__c = 500;
            prTest.Towards_Pre_Registration_Amount__c = 500;
            prTest.Towards_Unit_Price_Amount__c = 500;
            prTest.Payment_Request_Wrapper__c = uhw.Id;
            prTest.currency__c = 'USD';
            prTest.Amount__c = 500;
            prTest.Enquiry_Source__c = 'Web';
            insert prTest;
    
            prTest.Mode_Option__c = 'Multi Mode';
            prTest.Amount__c = 1500;
            prTest.Secondary_Mode__c = null;
            
            prTest.Status__c = 'Approved';
            prTest.Application_Booking__c = appBook.Id;
            Update prTest;
    
            /*Payment_Request__c prTest1 = new Payment_Request__c();
            prTest1.Mode__c = 'Credit Card';
            prTest1.Status__c = 'Rejected by System';
            prTest1.Enquiry__c = enq.Id;
            prTest1.Mode_Option__c = 'Multi Mode';
            prTest1.currency__c = 'USD';
            prTest1.Mobile_Mode_App__c = 'International Wire Transfer';
            prTest1.Payment_Request__c = prTest.Id;
            prTest1.Amount__c = 1000;
            prTest1.Enquiry_Source__c = 'Web';
            insert prTest1;
    
            List<Payment_Request__c> prList = new List<Payment_Request__c>();
    
            Payment_Request__c pr = new Payment_Request__c();
            pr.Mode__c = 'Credit Card';
            pr.Status__c = 'Rejected by System';
            pr.Enquiry__c = enq.Id;
            pr.Mobile_Mode_App__c = 'CDM Cash';
            pr.Mode_Option__c = 'Multi Mode';
            prList.add(pr);
    
            Payment_Request__c pr1 = new Payment_Request__c();
            pr1.Mode__c = 'Credit Card';
            pr1.Status__c = 'Rejected by Accounts';
            pr1.Enquiry__c = enq.Id;
            pr1.Payment_Request__c = prTest.Id;
            pr.Mobile_Mode_App__c = 'Domestic Wire Transfer';
            pr1.currency__c = 'USD';
            prList.add(pr1);
    
            insert prList;
    
            prList[0].Status__c = 'Approved';
            prList[1].Status__c = 'Rejected by System';
            update prList;
    
            prList[0].Submitted_Date__c = System.Today().format();
            prList[0].Status__c = 'Resubmitted to SM/SD';
            prList[0].Mode__c = 'OTC Deposits';
            prList[1].Submitted_Date__c = System.Today().format();
            prList[1].Status__c = 'Resubmitted to SM/SD';
            prList[1].Mode__c = 'CDM Cash';
            update prList;
    
            Payment_Request__c pr2 = new Payment_Request__c();
            pr2.Mode__c = 'Credit Card';
            pr2.Status__c = 'Rejected by Accounts';
            pr2.Enquiry__c = enq.Id;
            pr2.Payment_Request__c = prTest1.Id;
            pr2.currency__c = 'USD';
            pr2.Mode_Option__c = 'Multi Mode';
            insert pr2;
    
            pr2.Secondary_Mode__c = 'Cheque';
            pr2.Amount__c = 1200;
            update pr2;
    
            pr2.Status__c = 'Approved';
            update pr2;*/
            Test.StopTest();             
        }
    }

    @isTest
    static void testMethod2() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Expiry_Days__c = 10, Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
        insert proj;

        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;

        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;       

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;
        
        Payment_Request__c pr2 = new Payment_Request__c();
        pr2.Mode__c = 'Credit Card';
        pr2.Status__c = 'Partially Approved';
        pr2.Towards_Unit_Price_Amount__c = 1000;
        pr2.Towards_Other_Charges_Amount__c = 1000;
        pr2.Towards_Pre_Registration_Amount__c = 1000;
        pr2.Enquiry_Source__c = 'Web';
        insert pr2;

        pr2.Status__c = 'Approved';
        pr2.Instrument_Date__c = System.Today();
        update pr2;
    }

    @isTest
    static void testMethod3() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Expiry_Days__c = 10, Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
        insert proj;

        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;

        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;

        Payment_Request__c pr1 = new Payment_Request__c();
        pr1.Mode__c = 'Cheque';
        pr1.Status__c = 'Partially Approved';
        pr1.Towards_Unit_Price_Amount__c = 1000;
        pr1.Towards_Other_Charges_Amount__c = 1000;
        pr1.Towards_Pre_Registration_Amount__c = 1000;
        pr1.Amount_Towards__c = 'Unit Price'; 
        pr1.Enquiry_Source__c = 'Web';
        insert pr1;
        
        Payment_Request__c pr2 = new Payment_Request__c();
        pr2.Mode__c = 'Cheque';
        pr2.Status__c = 'Partially Approved';
        pr2.Towards_Unit_Price_Amount__c = 1000;
        pr2.Towards_Other_Charges_Amount__c = 1000;
        pr2.Towards_Pre_Registration_Amount__c = 1000;
        pr2.Amount_Towards__c = 'Unit Price'; 
        pr2.Enquiry_Source__c = 'Web';
        pr2.X1st_Level_Approved__c = false; 
        
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        
        Payment_Request__c pr3 = new Payment_Request__c();
        pr3.Mode__c = 'Cheque';
        pr3.Status__c = 'Approved';
        pr3.Towards_Unit_Price_Amount__c = 1000;
        pr3.Towards_Other_Charges_Amount__c = 1000;
        pr3.Towards_Pre_Registration_Amount__c = 1000;
        pr3.Amount_Towards__c = 'Unit Price';   
        pr3.X1st_Level_Approved__c = true;  
        pr3.Enquiry_Source__c = 'Web';
        pr3.Offer__c = offer.Id;                   

        
        Map<Id, Payment_Request__c> oldPrMap = new Map<Id, Payment_Request__c>{pr2.Id => pr2};

        pr1.Status__c = 'Approved';
        pr1.Offer__c = offer.Id;
                
        PaymentRequestTriggerHandler.updatePaymentRequestDetails(new List<Payment_Request__c>{pr3}, oldPrMap);
        update pr1;
        
        try{
        PaymentRequestTriggerHandler.updateOfferAndBooking(new List<Payment_Request__c>{pr3}, oldPrMap);
        }catch(Exception e){}
    }

    @isTest
    static void testMethod4() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Expiry_Days__c = 10, Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
        insert proj;

        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;

        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;

        Payment_Request__c pr7 = new Payment_Request__c();
        pr7.Mode__c = 'Cheque';
        pr7.Status__c = 'Partially Approved';
        pr7.Towards_Unit_Price_Amount__c = 1000;
        pr7.Towards_Other_Charges_Amount__c = 1000;
        pr7.Towards_Pre_Registration_Amount__c = 1000;
        pr7.Amount_Towards__c = 'Other Amount';
        pr7.Enquiry_Source__c = 'Web';
        insert pr7;

        pr7.Status__c = 'Approved';
        update pr7;
    }

    @isTest
    static void testMethod5() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Expiry_Days__c = 10, Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
        insert proj;

        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;

        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;

        Payment_Request__c pr8 = new Payment_Request__c();
        pr8.Mode__c = 'Cheque';
        pr8.Status__c = 'Partially Approved';
        pr8.Towards_Unit_Price_Amount__c = 1000;
        pr8.Towards_Other_Charges_Amount__c = 1000;
        pr8.Towards_Pre_Registration_Amount__c = 1000;
        pr8.Amount_Towards__c = 'Registration Amount';
        pr8.Enquiry_Source__c = 'Web';
        insert pr8;

        pr8.Status__c = 'Approved';
        update pr8;
    }

    @isTest
    static void testMethod6() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Expiry_Days__c = 10, Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
        insert proj;

        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;

        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;

        Payment_Request__c pr3 = new Payment_Request__c();
        pr3.Mode__c = 'CDM Cash';
        pr3.Status__c = 'Partially Approved';
        pr3.Towards_Unit_Price_Amount__c = 1000;
        pr3.Towards_Other_Charges_Amount__c = 1000;
        pr3.Towards_Pre_Registration_Amount__c = 1000;
        pr3.Enquiry_Source__c = 'Web';
        insert pr3;

        pr3.Status__c = 'Approved';
        pr3.Account_Type__c = 'ESCROW';
        update pr3;
    }

    @isTest
    static void testMethod7() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Expiry_Days__c = 10, Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
        insert proj;

        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;

        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;

        Payment_Request__c pr4 = new Payment_Request__c();
        pr4.Mode__c = 'CDM Cash';
        pr4.Status__c = 'Partially Approved';
        pr4.Towards_Unit_Price_Amount__c = 1000;
        pr4.Towards_Other_Charges_Amount__c = 1000;
        pr4.Towards_Pre_Registration_Amount__c = 1000;
        pr4.Enquiry_Source__c = 'Web';
        insert pr4;

        pr4.Status__c = 'Approved';
        pr4.Account_Type__c = 'Corporate';
        update pr4;
    }
    /*
    @isTest
    static void testMethod8() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        insert pay;
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        Payment_Request__c pr6 = new Payment_Request__c();
        pr6.Mode__c = 'Cheque';
        pr6.Status__c = 'Partially Approved';
        pr6.Towards_Unit_Price_Amount__c = 1000;
        pr6.Towards_Other_Charges_Amount__c = 1000;
        pr6.Application_Booking__c = appBook.Id;
        pr6.Towards_Pre_Registration_Amount__c = 1000;
        pr6.Property__c = prop.id;
        insert pr6;
        
        Map<Id, Payment_Request__c> oldPRmap = new Map<Id, Payment_Request__c>();
        System.debug('befroe update  '+pr6.Status__c);
        pr6.Status__c = 'Approved';
        pr6.Account_Type__c = 'Corporate';
        update pr6;
        
        List<Payment_Request__c> payReq = [Select id,Mode__c,Status__c,Towards_Unit_Price_Amount__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c From Payment_Request__c where id = :pr6.id]; 
        payReq[0].Status__c = 'Partially Approved';
        oldPRmap.put(pr6.id,payReq[0]);
        
        System.debug('chekkkkkkking '+oldPRmap);
        System.debug('chekkhhhhoooooking '+oldPRmap.get(pr6.id).status__c);
        List<Payment_Request__c> prList = new List<Payment_Request__c>{pr6};
        
        PaymentRequestTriggerHandler.createInterimPaymentOnApprove(prList,oldPRmap );
        PaymentRequestTriggerHandler.rejectRestOfPROnApprove(prList,oldPRmap );
        Test.StopTest();
    }*/

    @isTest
    static void testMethod10() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        insert pay;
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        Payment_Request__c pr6 = new Payment_Request__c();
        pr6.Mode__c = 'Cheque';
        pr6.Instrument_Number__c = '1234';
        pr6.Amount_Towards__c = 'Other Amount';
        pr6.Status__c = 'Partially Approved';
        pr6.Towards_Unit_Price_Amount__c = 1000;
        pr6.Towards_Other_Charges_Amount__c = 1000;
        pr6.Application_Booking__c = appBook.Id;
        pr6.Towards_Pre_Registration_Amount__c = 1000;
        pr6.Enquiry_Source__c = 'Web';
        insert pr6;
        
        Map<Id, Payment_Request__c> oldPRmap = new Map<Id, Payment_Request__c>();
        System.debug('befroe update  '+pr6.Status__c);
        pr6.Status__c = 'Approved';
        pr6.Account_Type__c = 'Corporate';
        update pr6;
        
        List<Payment_Request__c> payReq = [Select id,Mode__c,Status__c,Towards_Unit_Price_Amount__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c From Payment_Request__c where id = :pr6.id]; 
        payReq[0].Status__c = 'Partially Approved';
        oldPRmap.put(pr6.id,payReq[0]);
        
        System.debug('chekkkkkkking '+oldPRmap);
        System.debug('chekkhhhhoooooking '+oldPRmap.get(pr6.id).status__c);
        List<Payment_Request__c> prList = new List<Payment_Request__c>{pr6};
        
        PaymentRequestTriggerHandler.createInterimPaymentOnApprove(prList,oldPRmap );
        Test.StopTest();
    }
    
    @isTest
    static void testMethod11() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        insert pay;
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        Payment_Request__c pr6 = new Payment_Request__c();
        pr6.Mode__c = 'Cheque';
        pr6.Instrument_Number__c = '1234';
        pr6.Amount_Towards__c = 'Other Amount';
        pr6.Status__c = 'Partially Approved';
        pr6.Towards_Unit_Price_Amount__c = 1000;
        pr6.Towards_Other_Charges_Amount__c = 1000;
        pr6.Application_Booking__c = appBook.Id;
        pr6.Towards_Pre_Registration_Amount__c = 1000;
        pr6.Enquiry_Source__c = 'Web';
        insert pr6;
        
        Map<Id, Payment_Request__c> oldPRmap = new Map<Id, Payment_Request__c>();
        System.debug('befroe update  '+pr6.Status__c);
        pr6.Status__c = 'Approved';
        pr6.Account_Type__c = 'Corporate';
        update pr6;
        pr6.Amount__c = 200;
        pr6.Mode_Option__c = 'Multi Mode';
        pr6.Secondary_Mode__c = 'Cheque';
        pr6.currency__c = 'AED';
        try{
        update pr6;
        }
        catch(exception e){
            
        }
        List<Payment_Request__c> payReq = [Select id,Mode__c,Status__c,Towards_Unit_Price_Amount__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c From Payment_Request__c where id = :pr6.id]; 
        payReq[0].Status__c = 'Partially Approved';
        oldPRmap.put(pr6.id,payReq[0]);
        
        System.debug('chekkkkkkking '+oldPRmap);
        System.debug('chekkhhhhoooooking '+oldPRmap.get(pr6.id).status__c);
        List<Payment_Request__c> prList = new List<Payment_Request__c>{pr6};
        
        PaymentRequestTriggerHandler.createInterimPaymentOnApprove(prList,oldPRmap );
        Test.StopTest();
    }
    
    @isTest
    static void testMethod9() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Expiry_Days__c = 10, Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
        insert proj;

        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;

        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;
        
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        
        Payment_Request__c pr5 = new Payment_Request__c();
        pr5.Mode__c = 'International Wire Transfer';
        pr5.Status__c = 'Partially Approved';
        pr5.Towards_Unit_Price_Amount__c = 1000;
        pr5.Towards_Other_Charges_Amount__c = 1000;
        pr5.Towards_Pre_Registration_Amount__c = 1000;
        //pr5.Is_approved__c = false;
        pr5.offer__c = offer.id;
        pr5.Enquiry_Source__c = 'Web';
        pr5.Property__c = prop.id;
        
        insert pr5;

        pr5.Status__c = 'Approved';
        pr5.Account_Type__c = 'ESCROW';
        //pr5.Is_approved__c = true;
        update pr5;
        
        List<Payment_Request__c> prList = new List<Payment_Request__c>{pr5};
        Test.StartTest();
        
        PaymentRequestTriggerHandler.checkCurrrentUserRole(prList);
        Test.StopTest();
    }
    
    @isTest
    static void testMethod12() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        insert pay;
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        Payment_Request__c pr6 = new Payment_Request__c();
        pr6.Mode__c = 'Website';
        pr6.Instrument_Number__c = '1234';
        pr6.Amount_Towards__c = 'Other Amount';
        pr6.Status__c = 'Partially Approved';
        pr6.Towards_Unit_Price_Amount__c = 1000;
        pr6.Towards_Other_Charges_Amount__c = 1000;
        pr6.Application_Booking__c = appBook.Id;
        pr6.Towards_Pre_Registration_Amount__c = 1000;
        pr6.Enquiry_Source__c = 'Web';
        insert pr6;
        
        Map<Id, Payment_Request__c> oldPRmap = new Map<Id, Payment_Request__c>();
        System.debug('befroe update  '+pr6.Status__c);
        pr6.Status__c = 'Approved';
        pr6.Account_Type__c = 'Corporate';
        update pr6;
        
        List<Payment_Request__c> payReq = [Select id,Mode__c,Status__c,Towards_Unit_Price_Amount__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c From Payment_Request__c where id = :pr6.id]; 
        payReq[0].Status__c = 'Partially Approved';
        oldPRmap.put(pr6.id,payReq[0]);
        
        System.debug('chekkkkkkking '+oldPRmap);
        System.debug('chekkhhhhoooooking '+oldPRmap.get(pr6.id).status__c);
        List<Payment_Request__c> prList = new List<Payment_Request__c>{pr6};
        PaymentRequestTriggerHandler.backupCover();
        PaymentRequestTriggerHandler.createInterimPaymentOnApprove(prList,oldPRmap );
        Test.StopTest();
    }
}
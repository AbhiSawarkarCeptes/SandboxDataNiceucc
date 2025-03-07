/*********************************************************************
* Class Name  :   OfferTriggerHelper_Test
* Description :   Test class for the OfferTriggerHelper
* Created Date:   05/06/2022
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 05/06/2022
*********************************************************************/
@isTest
public class OfferTriggerHelper_Test {


    @TestSetup
    static void setupData() {
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        
        User u2 = TestDataFactorySobha.createUser(null);
        u2.ManagerId = u.Id;
        insert u2;
        
        User u3 = TestDataFactorySobha.createUser(null);
        u3.ManagerId = u2.Id;
        insert u3;
    
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        offer.PropStrength__Request__c = enq.Id;
        Offer.Sales_Manager__c = u3.Id;
        offer.Secondary_Sales_Manager__c = u3.Id;
        offer.Payment_Method__c = 'Multiple';
        insert offer;
    }
    
     @isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123');
        insert mileSt;
        
        PropStrength__Payment_Plan_Line_Items__c ppli = new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = mileSt.Id, PropStrength__Order__c = 1, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI');
        insert ppli;
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;
        PropStrength__Offer__c pc = [SELECT ID,Payment_Method__c,Offer_Valid_Till__c,Total_Pre_Payment_Received__c,Hold_Amount__c FROM PropStrength__Offer__c LIMIT 1];
        pc.Payment_Method__c = 'Single'; 
        update pc;
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Payment_Method__c = 'Single',PropStrength__Request__c = enq.Id, PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id, Sales_Manager__c = u.Id, Secondary_Sales_Manager__c = u.Id, PropStrength__Status__c = 'New');
        insert offer;
        offer.Payment_Method__c = 'Multiple';
        update offer;
    }
    
    @isTest
    static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        
        User u2 = TestDataFactorySobha.createUser(null);
        u2.ManagerId = u.Id;
        insert u2;
        
        User u3 = TestDataFactorySobha.createUser(null);
        u3.ManagerId = u2.Id;
        insert u3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Super_Area__c = 10000, PropStrength__Rate_per_unit_area__c = 1000, Requisite_Hold_Payment_Type__c = '%', Requisite_Hold_Payment__c = 2, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123');
        insert mileSt;
        
        PropStrength__Payment_Plan_Line_Items__c ppli = new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = mileSt.Id, PropStrength__Order__c = 1, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI');
        insert ppli;
           Test.startTest(); 
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Payment_Method__c = 'Multiple', Total_Pre_Payment_Received__c = 10000,Offer_Valid_Till__c = System.now().addDays(2),  PropStrength__Status__c = 'Negotiation / Review',PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Property__c = prop.Id, PropStrength__Project__c = proj.Id, PropStrength__Property_Type__c = propType.Id, Sales_Manager__c = u3.Id, Secondary_Sales_Manager__c = u3.Id);
        insert offer;
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
        pr3.Property__c = prop.Id;
        pr3.Enquiry_Source__c = 'Web';
        insert pr3;
        
        Payment_Request__c pr4 = new Payment_Request__c();
        pr4.Mode__c = 'CDM Cash';
        pr4.Status__c = 'Partially Approved';
        pr4.Towards_Unit_Price_Amount__c = 1000;
        pr4.Towards_Other_Charges_Amount__c = 1000;
        pr4.Towards_Pre_Registration_Amount__c = 1000;
        pr4.Property__c = prop.Id;
        pr4.Enquiry_Source__c = 'Web';
        insert pr4;
        offer.PropStrength__Request__c = enq.Id;
        offer.Payment_Method__c = 'Single';
        offer.PropStrength__Property__c = prop.Id;
        offer.Total_Pre_Payment_Received__c = 22000;
        offer.PropStrength__Status__c = 'Pre-Closed Won';
        offer.PropStrength__Primary_Contact__c = cont.Id;
        offer.DP_Amount__c = 500;
        offer.Payment_Request_1__c = pr3.Id;
        offer.Payment_Request_2__c = pr4.Id;
        
        offer.Emirates_ID_Uploaded__c = true;
        offer.Passport_Uploaded__c = true;
        //offer.PropStrength__Status__c = 'Closed Won';
        update offer;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod3() { 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        
        User u2 = TestDataFactorySobha.createUser(null);
        u2.ManagerId = u.Id;
        insert u2;
        
        User u3 = TestDataFactorySobha.createUser(null);
        u3.ManagerId = u2.Id;
        insert u3;
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Super_Area__c = 10000, PropStrength__Rate_per_unit_area__c = 1000, Requisite_Hold_Payment_Type__c = '%', Requisite_Hold_Payment__c = 2, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request__c pr3 = new Payment_Request__c();
        pr3.Mode__c = 'CDM Cash';
        pr3.Status__c = 'Partially Approved';
        pr3.Towards_Unit_Price_Amount__c = 1000;
        pr3.Towards_Other_Charges_Amount__c = 1000;
        pr3.Towards_Pre_Registration_Amount__c = 1000;
        pr3.Property__c = prop.Id;
        pr3.Enquiry_Source__c = 'Web';
        insert pr3;
        
        Payment_Request__c pr4 = new Payment_Request__c();
        pr4.Mode__c = 'CDM Cash';
        pr4.Status__c = 'Partially Approved';
        pr4.Towards_Unit_Price_Amount__c = 1000;
        pr4.Towards_Other_Charges_Amount__c = 1000;
        pr4.Towards_Pre_Registration_Amount__c = 1000;
        pr4.Property__c = prop.Id;
        pr4.Enquiry_Source__c = 'Web';
        insert pr4;
        
           Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123');
        insert mileSt;
        
        PropStrength__Payment_Plan_Line_Items__c ppli = new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = mileSt.Id, PropStrength__Order__c = 1, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI');
        insert ppli;
            
        PropStrength__Offer__c pc = new PropStrength__Offer__c(Payment_Method__c = 'Multiple', Total_Pre_Payment_Received__c = 10000,Offer_Valid_Till__c = System.now().addDays(2),  PropStrength__Status__c = 'Negotiation / Review',PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Property__c = prop.Id, PropStrength__Project__c = proj.Id, PropStrength__Property_Type__c = propType.Id, Sales_Manager__c = u3.Id, Secondary_Sales_Manager__c = u3.Id);
        insert pc;
           System.debug('Debug 1' +pc.Payment_Method__c);
           pc.Offer_Valid_Till__c = System.Now() + 5;
           pc.Total_Pre_Payment_Received__c = 500;
           pc.Hold_Amount__c = 300;
        pc.Payment_Request_1__c = pr3.Id;
        pc.Payment_Request_2__c = pr4.Id;
        pc.Emirates_ID_Uploaded__c = true;
        pc.Passport_Uploaded__c = true;
            
           //pc.Payment_Method__c = 'Single';
           System.debug('Debug 2' +pc.Payment_Method__c);
           update pc;
    }
    @isTest
    static void testMethod4() { 
           PropStrength__Offer__c pc = [SELECT ID,PropStrength__Property__c,PropStrength__Status__c,Total_Pre_Payment_Received__c,Hold_Amount__c FROM PropStrength__Offer__c LIMIT 1];
           PropStrength__Property__c ppt = [SELECT Id FROM PropStrength__Property__c LIMIT 1];
        contact cont1 = [SELECT id from Contact limit 1];
        PropStrength__Projects__c proj = [SELECT id from PropStrength__Projects__c limit 1];
           PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        enq.PropStrength__Primary_Contact__c = cont1.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq;
           Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
           pc.PropStrength__Property__c = ppt.Id;
           pc.PropStrength__Status__c = 'Closed Won';
           //pc.Payment_Method__c = 'Single';
           pc.PropStrength__Primary_Contact__c = cont.Id;
        pc.Deviation_on_Payment_Plan__c = false;
        pc.PropStrength__Request__c = enq.id;
        //try{
            update pc;
        
           
    }
    @isTest
    static void testMethod5() { 
           PropStrength__Offer__c pc = [SELECT ID,DLD_Amount__c,DLD_Amount_2__c,PropStrength__Property__c,PropStrength__Status__c,Total_Pre_Payment_Received__c,Hold_Amount__c FROM PropStrength__Offer__c LIMIT 1];       
           pc.DLD_Amount__c = 500;
           pc.DLD_Amount_2__c = 1000;
        pc.Deviation_on_Payment_Plan__c = false;
        try{
            update pc;
        }
        catch(exception e){
            
        }
        
    }
    @isTest
    static void testMethod6() { 
        Payment_Request__c pr3 = new Payment_Request__c();
        pr3.Mode__c = 'CDM Cash';
        pr3.Status__c = 'Partially Approved';
        pr3.Towards_Unit_Price_Amount__c = 1000;
        pr3.Amount__c = 1100;
        pr3.Towards_Other_Charges_Amount__c = 1000;
        pr3.Towards_Pre_Registration_Amount__c = 1000;
        pr3.Enquiry_Source__c = 'Web';
        insert pr3;
        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'CDM Cash';
        pr.Status__c = 'Partially Approved';
        pr.Towards_Unit_Price_Amount__c = 1100;
        pr.Amount__c = 1000;
        pr.Towards_Other_Charges_Amount__c = 1200;
        pr.Towards_Pre_Registration_Amount__c = 1300;
         pr.Enquiry_Source__c = 'Web';
        insert pr;
         PropStrength__Offer__c pc = [SELECT ID,DP_Amount__c,DP_Amount_2__c,PropStrength__Status__c,PropStrength__Approval_Status__c FROM PropStrength__Offer__c LIMIT 1];       
           /*pc.DP_Amount__c = 500;
           pc.DLD_Amount__c = 500;
           pc.DP_Amount_2__c = 600;
           pc.DLD_Amount_2__c = 500;
           pc.PropStrength__Status__c = 'Pre-Closed Won';
           pc.Payment_Request_2__c = pr3.Id;
           pc.Payment_Request_1__c = pr.Id;*/
        pc.PropStrength__Status__c = 'Discount Approved';
        pc.PropStrength__Approval_Status__c = 'Approved';
        update pc;
        PropStrength__Property__c ppt = [SELECT Id FROM PropStrength__Property__c LIMIT 1];
           
           Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
        pc.PropStrength__Property__c = ppt.Id;
        pc.PropStrength__Status__c = 'Closed Won';
        //pc.Payment_Method__c = 'Single';
        pc.PropStrength__Primary_Contact__c = cont.Id;
        pc.Booked_Date__c = System.Now().Date();
       pc.Deviation_on_Payment_Plan__c = false;
        try{
            update pc;
        }
        catch(exception e) {
            
        }
        OfferTriggerHelper.getSha256('test');
        OfferTriggerHelper.isTodayWithinRange(System.today(), System.today().addDays(2));
    }
    
    @isTest
    static void testMethod7() { 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        
        User u2 = TestDataFactorySobha.createUser(null);
        u2.ManagerId = u.Id;
        insert u2;
        
        User u3 = TestDataFactorySobha.createUser(null);
        u3.ManagerId = u2.Id;
        insert u3;
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Super_Area__c = 10000, PropStrength__Rate_per_unit_area__c = 1000, Requisite_Hold_Payment_Type__c = '%', Requisite_Hold_Payment__c = 2, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request__c pr3 = new Payment_Request__c();
        pr3.Mode__c = 'CDM Cash';
        pr3.Status__c = 'Partially Approved';
        pr3.Towards_Unit_Price_Amount__c = 1000;
        pr3.Towards_Other_Charges_Amount__c = 1000;
        pr3.Towards_Pre_Registration_Amount__c = 1000;
        pr3.Property__c = prop.Id;
        pr3.Enquiry_Source__c = 'Web';
        insert pr3;
        
        Payment_Request__c pr4 = new Payment_Request__c();
        pr4.Mode__c = 'CDM Cash';
        pr4.Status__c = 'Partially Approved';
        pr4.Towards_Unit_Price_Amount__c = 1000;
        pr4.Towards_Other_Charges_Amount__c = 1000;
        pr4.Towards_Pre_Registration_Amount__c = 1000;
        pr4.Property__c = prop.Id;
         pr4.Enquiry_Source__c = 'Web';
        insert pr4;
        
           Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123');
        insert mileSt;
        
        PropStrength__Payment_Plan_Line_Items__c ppli = new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = mileSt.Id, PropStrength__Order__c = 1, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI');
        insert ppli;
            
        PropStrength__Offer__c pc = new PropStrength__Offer__c(Payment_Method__c = 'Multiple', Total_Pre_Payment_Received__c = 10000,Offer_Valid_Till__c = System.now().addDays(2),  PropStrength__Status__c = 'Negotiation / Review',PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Property__c = prop.Id, PropStrength__Project__c = proj.Id, PropStrength__Property_Type__c = propType.Id, Sales_Manager__c = u3.Id, Secondary_Sales_Manager__c = u3.Id);
        insert pc;
           System.debug('Debug 1' +pc.Payment_Method__c);
           pc.Offer_Valid_Till__c = System.Now() + 5;
           pc.Total_Pre_Payment_Received__c = 500;
           pc.Hold_Amount__c = 300;
        pc.Payment_Request_1__c = pr3.Id;
        pc.Payment_Request_2__c = pr4.Id;
        pc.Emirates_ID_Uploaded__c = true;
        pc.Passport_Uploaded__c = true;
        pc.Sales_Manager__c = u2.id;
            
           //pc.Payment_Method__c = 'Single';
           System.debug('Debug 2' +pc.Payment_Method__c);
           update pc;
    }

}
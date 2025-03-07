@isTest
public class CreateOfferFromPRControllerTest {

    @isTest
    static void testCreateOfferRecord() {
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

        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Status__c = 'Approved';
        pr.Property__c = prop.Id;
        pr.Enquiry__c = enq.Id;
        insert pr;

        Payment_Request__c pr2 = new Payment_Request__c();
        pr2.Mode__c = 'Credit Card';
        pr2.Payment_Request__c = pr.Id;
        pr2.Status__c = 'Approved';
        pr2.Enquiry__c = enq.Id;
        pr2.Property__c = prop.Id;
        insert pr2;

        String ppId = ppd.Id;
        String recId = pr.Id;
        String fromClassic = 'true';

        Test.startTest();
        String result = CreateOfferFromPRController.createOfferRecord(ppId, recId, fromClassic);
        String result1 = CreateOfferFromPRController.createOfferRecord(ppId, recId, 'false');
        Test.stopTest();
    }

    @isTest
    static void testCheckOfferIsCreatedOrNot() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
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
        insert enq;

        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;

        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Status__c = 'Approved';
        pr.Enquiry__c = enq.Id;
        pr.Property__c = prop.Id;
        pr.Offer__c = off.Id;
        insert pr;

        String recId = pr.Id;
        String fromClassic = 'true';

        Test.startTest();
        String result = CreateOfferFromPRController.checkOfferIsCreatedOrNot(recId, fromClassic);
        String result1 = CreateOfferFromPRController.checkOfferIsCreatedOrNot(recId, 'false');
        Test.stopTest();
    }

    @isTest
    static void testCheckOfferIsCreatedOrNot2() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
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
        
        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Status__c = 'Approved';
        pr.Property__c = prop.Id;
        insert pr;

        String recId = pr.Id;
        String fromClassic = 'true';

        Test.startTest();
        String result = CreateOfferFromPRController.checkOfferIsCreatedOrNot(recId, fromClassic);
        String result1 = CreateOfferFromPRController.checkOfferIsCreatedOrNot(recId, 'false');
        Test.stopTest();
    }

    @isTest
    static void testSearchPPlans() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
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
        insert enq;

        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Enquiry__c = enq.Id;
        pr.Property__c = prop.Id;
        insert pr;

        String searchKeyWrd = 'test';
        String recId = pr.Id;

        Test.startTest();
        List<PropStrength__Payment_Plan__c> result = CreateOfferFromPRController.searchPPlans(searchKeyWrd, recId);
        Test.stopTest();
    }
}
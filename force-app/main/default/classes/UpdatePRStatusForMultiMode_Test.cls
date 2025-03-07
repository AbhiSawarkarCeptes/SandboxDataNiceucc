@isTest
public class UpdatePRStatusForMultiMode_Test {
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
            prTest.Offer__c = offer.Id;
            prTest.Enquiry_Source__c = 'Web';
            insert prTest;
            
            list<Payment_Request__c> prList = new list<Payment_Request__c>();
            prList.add(prTest);
            Test.StopTest();   
            UpdatePRStatusForMultiMode.updatestatusValue(prList);
        }
    }
}
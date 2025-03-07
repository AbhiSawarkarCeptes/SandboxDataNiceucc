@IsTest
public class AutoCancelBookingAfter15Days_PS_Test {
    @isTest
    static void testBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c pro = TestDataFactorySobha.createProject(null);
        insert pro;
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact con = TestDataFactorySobha.createContact(null);
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert con;
        PropStrength__Property_Type__c type = TestDataFactorySobha.createPropertyType(null);
        insert type;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Request__c req = TestDataFactorySobha.createEnquiry(null);
        insert req;
        PropStrength__Property__c property = TestDataFactorySobha.createProperty(null);
        insert property;
        
        
        
        PropStrength__Payment_Plan__c plan = TestDataFactorySobha.createPaymentPlan(null);
        insert plan;
        
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        
        
        PropStrength__Brokerage_Scheme__c broker = TestDataFactorySobha.createBrokerageScheme(null);
        insert broker;
        PropStrength__Application_Booking__c book = TestDataFactorySobha.createApplicationBooking(null);
        book.PropStrength__Booking_Date__c = Date.today().addDays(-24);
        book.PropStrength__Total_Basic_Sales_Price__c = 150;
        book.Sales_Manager__c = u.Id;
        book.SBF_Assigned_To__c = u.Id;
        book.Sales_Director__c = u.Id;
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=con.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
         Payment_Request__c prTest = new Payment_Request__c();
        prTest.Mode__c = 'Credit Card';
        prTest.Status__c = 'Approved by Accounts';
        prTest.Enquiry__c = req.Id;
        prTest.Mode_Option__c = 'Multi Mode';
        prTest.currency__c = 'USD';
        prTest.Enquiry_Source__c = 'Web';
        prTest.Amount__c = 1000;
        prTest.Property__c = property.Id;
        prTest.Application_Booking__c = book.Id;
        Test.startTest();
        insert prTest;
        
        
        AutoCancelBookingAfter15Days_PS batch = new AutoCancelBookingAfter15Days_PS();
        Database.executeBatch(batch);
        
        Test.stopTest();

    }
     @isTest
    static void testBatchSchedule() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        AutoCancelBookingAfter15Days_PS sh1 = new AutoCancelBookingAfter15Days_PS();
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check test', sch, sh1); 
        
        Test.stopTest();

    }
    
  
    
}
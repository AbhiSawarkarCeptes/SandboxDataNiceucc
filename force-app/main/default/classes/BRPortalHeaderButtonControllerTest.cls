@isTest
public class BRPortalHeaderButtonControllerTest {
    
    @testSetup
    static void setupTestData() {
       ID ProfileID = [ Select id from Profile where name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' limit 1].id;
        
        Account acc = new Account(Name = 'Test Account');
        
        insert acc ;
        
        List<Contact> ContactList = new List<Contact>();
        
        Contact Con = new Contact( AccountID = acc .id, FirstName = 'User', LastName = 'test',
                                  
                                  email = 'testuser@xyz.com' );
        
        insert Con;
        User u = new User( email='test.user@example.com', contactid = con.id, profileid = profileid, UserName='testuser@xyz.com', alias='tuser', CommunityNickName='tuser',
                          
                          TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1',
                          
                          LanguageLocaleKey='en_US', FirstName = 'User', LastName = 'Test' );
        
        insert u;
    }
    @isTest
    static void testUserWithContact() {
        // Fetch the test user and contact from setup
        User testUser = [SELECT Id, Email, ContactId FROM User WHERE Email = 'test.user@example.com' LIMIT 1];
        Contact testContact = [SELECT Id, Email, FirstName, LastName FROM Contact  LIMIT 1];
       
        Test.startTest();
        System.runAs(testUser){
            String createdCaseId = BRPortalHeaderButtonController.createCase('testTest@example.com', '1234567890', 'Test Remarks', 'Test');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSendEmail() {
        Test.startTest();
        BRPortalHeaderButtonController.send_Email(new List<String>{'test@example.com'}, new List<String>{'test@example.com'}, 'serviceNumber', 'Test');
        Test.stopTest();
    }
    
    @isTest
    static void testGetAllCasesByCurrentUser() {
        User testUser = [SELECT Id, Email, ContactId FROM User WHERE Email = 'test.user@example.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        //User u = TestDataFactorySobha.createUser(null);
        //insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.Birthdate = System.Today();
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        proj.Accounts_Executive__c = testUser.Id;
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
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        insert appDetail;
        
        PropStrength__Request__c enq3  = new PropStrength__Request__c();
        enq3.PropStrength__Primary_Contact__c = cont.Id;
        insert enq3;
        
        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = cont.FirstName;
        enq2.PropStrength__Last_Name__c =cont.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Application_Booking__c = appBook.id;
        enq2.PropStrength__Project__c = proj.id;
        enq2.PropStrength__Comments_by_Query_Owner__c = 'Test Comments : Query Resolved';
        enq2.Contact__c = testUser.contactId;
        insert enq2;
        
        System.runAs(testUser) {
            List<BRPortalHeaderButtonController.SRWrapper> cases = BRPortalHeaderButtonController.getAllCasesByCurrentUser();
            System.assertNotEquals(null, cases, 'List of cases should be fetched successfully');            
        }
        Test.stopTest();
    }
}
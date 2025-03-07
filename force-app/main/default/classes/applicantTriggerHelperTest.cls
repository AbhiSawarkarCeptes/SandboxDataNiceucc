@isTest
public class applicantTriggerHelperTest {
    @TestSetup
    static void SetupTestData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        User usr = TestDataFactorySobha.createUser(NULL);
        insert usr;
        
        Account testAccount = TestDataFactorySobha.createAccount(null);
        insert testAccount;
        
        //contact testContact = TestDataFactorySobha.createContact(null);
        Contact testContact = new Contact();
        testContact.FirstName = 'Test' + DateTime.now();
        testContact.LastName = 'testKYCForm';
        testContact.Email = 'test@test.com';
        testContact.MobilePhone = '1234567891';
        testContact.MailingStreet = 'Test';
        testContact.Passport_No__c = '12346';
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert testContact;
        
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        
        PropStrength__Payment_Plan__c ppd = TestDataFactorySobha.createPaymentPlan(null);
        insert ppd;
        
        PropStrength__Request__c enq  = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c ptower = TestDataFactorySobha.createTower(null);
        insert ptower;
        
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        PropStrength__Brokerage_Scheme__c pbscheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert pbscheme;
        test.starttest();
        PropStrength__Application_Booking__c book = TestDataFactorySobha.createApplicationBooking(null);
        insert book;
        PropStrength__Application_Booking__c book1 = TestDataFactorySobha.createApplicationBooking(null);
        insert book1;
        
        List<PropStrength__Applicant_Detail__c> appDetailList = new List<PropStrength__Applicant_Detail__c>();
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c = testContact.Id, PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        appDetailList.add(appDetail);
        PropStrength__Applicant_Detail__c appDetail1 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c = testContact.Id, PropStrength__Type__c = '2nd Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book1.Id);
        appDetailList.add(appDetail1);
        insert appDetailList;
        List<PropStrength__Applicant_Detail__c> appDetailList1 = new List<PropStrength__Applicant_Detail__c>();
        for(Integer i=0; i<5; i++) {
            PropStrength__Applicant_Detail__c appDetail2 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c = testContact.Id, PropStrength__Type__c = '2nd Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
            appDetailList1.add(appDetail2);
        }        
        insert appDetailList1;
        test.stoptest();
    }
    
    @isTest
    static void testUpdateFirstApplicantFields() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<PropStrength__Applicant_Detail__c> applicantDetails = [SELECT id,Nationality__c, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c,
                                                             PropStrength__Applicant_Mobile__c, PropStrength__Applicant_Address__c, Passport_No_Doc__c, 
                                                             Formatted_Applicant_Nationality_Docgen__c, Formatted_Applicant_Name_For_Docgen__c,PropStrength__Application__c ,                                                         
                                                             PropStrength__Contact__r.MailingAddress,PropStrength__Contact__r.Passport_No__c, Formatted_Applicant_Email_For_Docgen__c,
                                                             Formatted_Applicant_Phone_For_Docgen__c, Formatted_Applicant_Address_For_Docgen__c, Formatted_Applicant_Passport_For_Docgen__c,
                                                             PropStrength__Type__c  from PropStrength__Applicant_Detail__c ];
        
        // Call the method to be tested
        Test.startTest();
        applicantTriggerHelper.updateFirstApplicantFields(applicantDetails);
        applicantTriggerHelper.sendToMobileAPI(new set<Id>{applicantDetails[0].Id});
        Test.stopTest();
        
    }
    
}
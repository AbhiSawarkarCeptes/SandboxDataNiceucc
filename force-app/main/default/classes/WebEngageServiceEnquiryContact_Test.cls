@isTest
public class WebEngageServiceEnquiryContact_Test {
	@isTest 
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        cont.LastName = 'Testing';
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        WebEngageServiceEnquiryContactHandler.userPostAPI(JSON.serialize(enq));
        WebEngageServiceEnquiryContactHandler.enquiryPostAPI(JSON.serialize(enq),'Test Event');
    }
}
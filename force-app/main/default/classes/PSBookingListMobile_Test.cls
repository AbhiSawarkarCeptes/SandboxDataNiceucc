@isTest
public class PSBookingListMobile_Test {
    @testSetup
    public static void setUp() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
       	insert acc;
        
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.AccountId = acc.ID;
        cont.Email = 'test@test.com';
        insert cont;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        
        PropStrength__Payment_Plan__c ppd = TestDataFactorySobha.createPaymentPlan(null);
        ppd.PropStrength__Project__c = proj.Id;
        insert ppd;
        
        PropStrength__Request__c enq  = TestDataFactorySobha.createEnquiry(null);
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        tower.PropStrength__Project_Name__c = proj.Id; 
        insert tower;
        
        PropStrength__Property_Type__c pType =  TestDataFactorySobha.createPropertyType(null);
        pType.PropStrength__Project__c = proj.Id;
		insert pType;
        
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Tower__c = tower.Id;
        prop.PropStrength__Property_Type__c = pType.Id;
        prop.PropStrength__Project_Name__c = proj.Id;
        insert prop;
        
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        offer.PropStrength__Request__c = enq.Id;
        offer.PropStrength__Payment_Plan__c = ppd.Id;
        offer.PropStrength__Project__c = proj.Id; 
        offer.PropStrength__Property__c = prop.Id; 
        offer.PropStrength__Property_Type__c = pType.Id;
        offer.PropStrength__Primary_Contact__c = cont.Id;
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        TestDataFactorySobha.recordTypeName = 'Transfer Of Property';
        PropStrength__Transaction_Requests__c tr = TestDataFactorySobha.createTransactionRequest(null);
        tr.PropStrength__Application_Booking__c = book.Id;
        insert tr;
    }
    @isTest
    static void getBookingDetails() {
        String json ='   {'+
        '      \"email\":\"test@test.com\"'+
        '   }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.httpMethod = 'POST';
        req.requestUri ='services/apexrest/getBookingList_Test';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response = res;
        PSBookingListMobile.MobileToSFDC();
    }
    @isTest
    static void NoApplicantExist() {
        String json ='   {'+
        '      \"email\":\"test@test123.com\"'+
        '   }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.httpMethod = 'POST';
        req.requestUri ='services/apexrest/getBookingList_Test';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response = res;
        PSBookingListMobile.MobileToSFDC();
    }
	@isTest
    static void NoEmail() {
        String json ='   {'+
        '      \"email\":\"\"'+
        '   }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.httpMethod = 'POST';
        req.requestUri ='services/apexrest/getBookingList_Dummy';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response = res;
        PSBookingListMobile.MobileToSFDC();
    }
}
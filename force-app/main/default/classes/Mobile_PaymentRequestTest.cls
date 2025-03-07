@isTest
private class Mobile_PaymentRequestTest {

    @testSetup
    static void setupTestData() {
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true); 
        insert contentVersion;
        
        Mobile_TestUtil.createBooking();
        
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','test######102',false,false,'Marketing#Digital','');
        
    }

    @isTest
    static void testCreatePaymentRequestWithValidData() {
        // Test the case where valid data is provided
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/paymentRequest';
        request.httpMethod = 'POST';
        // Set the request body with valid parameters

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Unit__c u = [Select id From Unit__c limit 1];
        Mobile_PaymentRequest.createPaymentRequest(100.00, u.id, '1234567890', 'test@example.com', 'TestName', '1234567890', '12345', Date.today(), Date.today(), 'Base64ImageData', 'India', 'USD', false, '', 'PaymentType', 'TestBookingId', 'Comments');
        Test.stopTest();

        // Assert the response status code and any other expected results
        System.assertEquals(400, response.statusCode);
        
        // Add more assertions as needed
    }
    
    @isTest
    static void testCreatePaymentRequestWithValidDataWebsite() {
        // Test the case where valid data is provided
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/paymentRequest';
        request.httpMethod = 'POST';
        // Set the request body with valid parameters

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Unit__c u = [Select id From Unit__c limit 1];
        Booking__c b = [Select id From Booking__c limit 1];
        Mobile_PaymentRequest.createPaymentRequest(100.00, u.id, '1234567890', 'test@example.com', 'TestName', '1234567890', '12345', Date.today(), Date.today(), 'Base64ImageData', 'India', 'USD', false, '', 'Website', b.id, 'Comments');
        Test.stopTest();

        // Assert the response status code and any other expected results
        System.assertEquals(200, response.statusCode);
        
        // Add more assertions as needed
    }
    
    @isTest
    static void testCreatePaymentRequestWithValidNoWebsite() {
        // Test the case where valid data is provided
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/paymentRequest';
        request.httpMethod = 'POST';
        // Set the request body with valid parameters

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Unit__c u = [Select id From Unit__c limit 1];
        Booking__c b = [Select id From Booking__c limit 1];
        Mobile_PaymentRequest.createPaymentRequest(100.00, u.id, '1234567890', 'test@example.com', 'TestName', '1234567890', '12345', Date.today(), Date.today(), 'Base64ImageData', 'India', 'USD', false, '', 'CDM Cash', b.id, 'Comments');
        Test.stopTest();

        // Assert the response status code and any other expected results
        System.assertEquals(200, response.statusCode);
        
        // Add more assertions as needed
    }

    @isTest
    static void testCreatePaymentRequestWithException() {
        // Test the case where an exception is thrown in the code
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/paymentRequest';
        request.httpMethod = 'POST';
        // Set the request body with valid parameters

        RestContext.request = request;
        RestContext.response = response;

        // Simulate an exception by passing invalid parameters

        Test.startTest();
        Mobile_PaymentRequest.createPaymentRequest(100.00, 'TestUnit', '1234567890', 'test@example.com', 'TestName', '1234567890', '12345', Date.today(), Date.today(), 'InvalidBase64Data', 'India', 'USD', false, '', 'PaymentType', 'TestBookingId', 'Comments');
        Test.stopTest();
        
		Payment_Request__c pr = [select Id, Unit__c from Payment_Request__c limit 1];
        // Assert the response status code and any other expected results
        System.assertEquals(400, response.statusCode);
        String base64Data = 'pdf,encoded,data,goes,here';
        Mobile_PaymentRequest.uploadFile(base64Data,pr.id);
        Mobile_PaymentRequest.otherModes(pr,response);
    }
    
    /*private static Unit__c createUnit( Id prId, Id twId) {
    Unit__c objUnit = new Unit__c ();
    objUnit.name = 'testUnit1';
    objUnit.Project_Property_Type__c = 'Residential';
    objUnit.Carpet_Area__c = 1233;
    objUnit.Chargeable_Area__c = 1234; 
    objUnit.Balcony_Area_Sq_Ft__c = 123;
    objUnit.Project__c = prId;
    objUnit.Tower__c = twID;
    //insert objUnit;
    return objUnit;
    }
 
    private static Tower__c createTower( Id projID) {
    Tower__c tw = new Tower__c();        
    tw.Name = 'Maple B';
    tw.project__c = projID;
    insert tw;
    return tw;
    }

    private static Project__c createProject() {
    Project__c proj = new Project__c();         
    proj.Configuration__c='1.5 BHK';
    proj.Max_Budget__c=10000;
    proj.Min_Budget__c=10000;
    proj.Expiry_Days__c = 10;
    proj.name = 'ParkWest';
    proj.Project_Code__c = 'test';
    insert proj;
    return proj;
    }
    
    public static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
        
        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp ;
        objQuote1.Payment_Plan__c = pp ;
        objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        
        objQuote1.Charge3Bucket__c = 'Agreement Value';
        objQuote1.Charge3Name__c = 'PLC';
        objQuote1.Charge3Value__c = 1123;
        
        objQuote1.Charge4Bucket__c = 'Other Charges';
        objQuote1.Charge4Name__c = 'test';
        objQuote1.Charge4Value__c = 1123;
        objQuote1.Final_Approved_Date__c = System.today();
        insert objQuote1;
        return objQuote1;
    } 
    
    private static Payment_Milestones__c createPaymentMilestone(Id quote) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 300000000;          
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 2475;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm;        
        return pm;                  
    } */
}
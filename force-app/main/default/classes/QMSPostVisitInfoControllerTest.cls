@IsTest
public class QMSPostVisitInfoControllerTest {
    @IsTest
    static void testDoPost_Success() {
        // Create necessary data
Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        Id towerId = recordMap.get('TOWER');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);   
        unit__c u = [select id,name from unit__c where id =: unitId];
        u.name = 'WS-11';
        UPDATE U;

        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
              
        // Create the request wrapper
        QMSRequestWrapper.postVisitInfoWrapper requestWrapper = new QMSRequestWrapper.postVisitInfoWrapper();
        requestWrapper.email = 'test@example.com';
        requestWrapper.mobile = '0987654321';
        requestWrapper.description = 'Test description';
        requestWrapper.requestType = 'Test request type';
        requestWrapper.bookingId = b.Id;
        requestWrapper.internalDescription = 'Internal description';
        requestWrapper.tokenNumber = '12345';
        requestWrapper.issuedTime = '2023-01-01T12:00:00+00:00';
        requestWrapper.serviceName = 'Test service';
        requestWrapper.passport = EncodingUtil.base64Encode(Blob.valueOf('test passport image'));

        // Serialize the request
        String requestBody = JSON.serialize(requestWrapper);

        // Set up the mock request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        QMSPostVisitInfoController.doPost();
        Test.stopTest();

        // Assert the response
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
       System.assert(responseBody.contains('Successful'), 'Response does not contain success message');
    }

    @IsTest
    static void testDoPost_ValidationError() {
        // Create the request wrapper with missing email
        QMSRequestWrapper.postVisitInfoWrapper requestWrapper = new QMSRequestWrapper.postVisitInfoWrapper();
        requestWrapper.mobile = '0987654321';
        requestWrapper.description = 'Test description';
        requestWrapper.requestType = 'Test request type';
        requestWrapper.bookingId = 'TestBookingId';
        requestWrapper.internalDescription = 'Internal description';
        requestWrapper.tokenNumber = '12345';
        requestWrapper.issuedTime = '2023-01-01T12:00:00+00:00';
        requestWrapper.serviceName = 'Test service';

        // Serialize the request
        String requestBody = JSON.serialize(requestWrapper);

        // Set up the mock request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        QMSPostVisitInfoController.doPost();
        Test.stopTest();

        // Assert the response
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('Email missing'), 'Response does not contain missing email message');
    }

    @IsTest
    static void testDoPost_NoBooking() {
        // Create the request wrapper
        QMSRequestWrapper.postVisitInfoWrapper requestWrapper = new QMSRequestWrapper.postVisitInfoWrapper();
        requestWrapper.email = 'test@example.com';
        requestWrapper.mobile = '0987654321';
        requestWrapper.description = 'Test description';
        requestWrapper.requestType = 'Test request type';
        requestWrapper.bookingId = 'NonExistentBookingId';
        requestWrapper.internalDescription = 'Internal description';
        requestWrapper.tokenNumber = '12345';
        requestWrapper.issuedTime = '2023-01-01T12:00:00+00:00';
        requestWrapper.serviceName = 'Test service';

        // Serialize the request
        String requestBody = JSON.serialize(requestWrapper);

        // Set up the mock request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        QMSPostVisitInfoController.doPost();
        Test.stopTest();

        // Assert the response
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('No Booking Available'), 'Response does not contain no booking available message');
    }

    @IsTest
    static void testDoPost_Exception() {
        // Create the request wrapper with invalid issuedTime
        QMSRequestWrapper.postVisitInfoWrapper requestWrapper = new QMSRequestWrapper.postVisitInfoWrapper();
        requestWrapper.email = 'test@example.com';
        requestWrapper.mobile = '0987654321';
        requestWrapper.description = 'Test description';
        requestWrapper.requestType = 'Test request type';
        requestWrapper.bookingId = 'TestBookingId';
        requestWrapper.internalDescription = 'Internal description';
        requestWrapper.tokenNumber = '12345';
        requestWrapper.issuedTime = 'InvalidDateTime';
        requestWrapper.serviceName = 'Test service';

        // Serialize the request
        String requestBody = JSON.serialize(requestWrapper);

        // Set up the mock request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        QMSPostVisitInfoController.doPost();
        Test.stopTest();

        // Assert the response
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('Something went wrong'), 'Response does not contain error message');
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
}
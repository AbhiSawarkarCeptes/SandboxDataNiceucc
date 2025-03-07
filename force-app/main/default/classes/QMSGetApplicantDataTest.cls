@IsTest
public class QMSGetApplicantDataTest {
    
    @IsTest
    static void testDoGet_Success() {
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create a new user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser@example.com' + System.currentTimeMillis(), // Ensure unique username
            Email = 'testuser@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        Booking__c bk = [select id,name from booking__C where id=:b.id];
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.name = 'test';
        app.Booking__c = bk.id;
        insert app;
        
        QMSRequestWrapper.GetUnitInfoWrapper requestWrapper = new QMSRequestWrapper.GetUnitInfoWrapper();
        requestWrapper.unitId = '11';
        requestWrapper.towerId = 'WS-';
        String jsonRequest = JSON.serialize(requestWrapper);
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getApplicantData';
        req.params.put('unitId', '11');
        req.params.put('towerId', 'WS-');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QmsGetApplicantData.doGet();
        
        // Set up HTTP request
        RestRequest req1 = new RestRequest();
        req1.requestUri = '/services/apexrest/getApplicantData';
        req1.params.put('unitId', '');
        req1.params.put('towerId', 'WS-');
        req1.httpMethod = 'GET';
        req1.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req1;
        
        // Set up HTTP response
        RestResponse res1 = new RestResponse();
        RestContext.response = res1;
        
        // Call the method
        QmsGetApplicantData.doGet();
        
    }
    
    @IsTest
    static void testDoGet_Failure() {
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
        // b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
        
        Booking__c bk = [select id,name from booking__C where id=:b.id];
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.name = 'test';
        app.Booking__c = bk.id;
        insert app;
        
        QMSRequestWrapper.GetUnitInfoWrapper requestWrapper = new QMSRequestWrapper.GetUnitInfoWrapper();
        requestWrapper.unitId = '11';
        requestWrapper.towerId = 'WS-';
        String jsonRequest = JSON.serialize(requestWrapper);
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getApplicantData';
        req.params.put('unitId', '11');
        req.params.put('towerId', 'WS-');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QmsGetApplicantData.doGet();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        system.debug('responseBody:'+res.responseBody.toString());
        System.assert(responseBody.contains('No Booking linked'), 'Response is not correct');
        
    }
    
    
    @IsTest
    static void testDoGet_ImproperRequest() {
        // Prepare improper request data
        String invalidJsonRequest = '{invalidJson}';
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getApplicantData';
        req.httpMethod = 'Get';
        req.params.put('unitId', 'WS');
        
        //req.requestBody = Blob.valueOf(invalidJsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QmsGetApplicantData.doGet();
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
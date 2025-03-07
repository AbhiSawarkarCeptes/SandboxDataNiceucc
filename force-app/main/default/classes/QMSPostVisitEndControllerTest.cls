@IsTest
private class QMSPostVisitEndControllerTest {
    
    @IsTest
    static void testDoPost_Success() {
        // Create test data
        Case testCase = new Case(Status = 'Open', Subject = 'Test Case', is_QMS_Case__c = true);
        insert testCase;
        
        // Prepare request data
        QMSRequestWrapper.PostVisitEndInfoWrapper requestWrapper = new QMSRequestWrapper.PostVisitEndInfoWrapper();
        requestWrapper.caseId = testCase.Id;
        requestWrapper.servingTime = 30;
        requestWrapper.description = 'Test visit end';
        
        String jsonRequest = JSON.serialize(requestWrapper);
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/PostVisitEndInfo/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QMSPostVisitEndController.doPost();
        
        // Verify the response
        System.assertEquals(200, res.statusCode);
        System.assertEquals('{"success":true,"statusCode":200,"status":"Success","Message":"Visit Ended Successfully."}', res.responseBody.toString());
        
        // Verify the case was updated
        testCase = [SELECT Status, Serving_Time__c, RM_Remarks__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Closed', testCase.Status);
        System.assertEquals(30, testCase.Serving_Time__c);
        System.assertEquals('Test visit end', testCase.RM_Remarks__c);
        
        // Verify logging
        // Add assertions to check the log entries if applicable
    }
    
    @IsTest
    static void testDoPost_VisitAlreadyEnded() {
        // Create test data
        Case testCase = new Case(Status = 'Closed', Subject = 'Test Case', is_QMS_Case__c=true);
        insert testCase;
        
        // Prepare request data
        QMSRequestWrapper.PostVisitEndInfoWrapper requestWrapper = new QMSRequestWrapper.PostVisitEndInfoWrapper();
        requestWrapper.caseId = testCase.Id;
        requestWrapper.servingTime = 30;
        requestWrapper.description = 'Test visit end';
        
        String jsonRequest = JSON.serialize(requestWrapper);
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/PostVisitEndInfo/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QMSPostVisitEndController.doPost();
        
        // Verify the response
        System.assertEquals(200, res.statusCode);
        System.assertEquals('{"success":true,"statusCode":200,"status":"Success","Message":"Visit Already Ended"}', res.responseBody.toString());
    }
    
    @IsTest
    static void testDoPost_ImproperRequest() {
        // Prepare improper request data
        String invalidJsonRequest = '{invalidJson}';
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/PostVisitEndInfo/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(invalidJsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QMSPostVisitEndController.doPost();
        
        // Verify the response
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('Please send proper request.'));
        
            }
    
    @IsTest
    static void testDoPost_InvalidCaseId() {
        // Prepare request data with invalid CaseId
        QMSRequestWrapper.PostVisitEndInfoWrapper requestWrapper = new QMSRequestWrapper.PostVisitEndInfoWrapper();
        requestWrapper.caseId = '123456';
        requestWrapper.servingTime = 30;
        requestWrapper.description = 'Test visit end';
        
        String jsonRequest = JSON.serialize(requestWrapper);
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/PostVisitEndInfo/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QMSPostVisitEndController.doPost();
        
        // Verify the response
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('Improper CaseId.'));
        
        
    }
}
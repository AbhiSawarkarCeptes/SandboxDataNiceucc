@IsTest
public class QMSPostTransferControllerTest {
    @IsTest
    static void testDoPost_Success() {
        // Create test data
        Case testCase = new Case(Status = 'Open', Subject = 'Test Case', is_QMS_Case__c = true);
        insert testCase;
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
        
        // Prepare request data
        QMSRequestWrapper.postTokenCalledInfoWrapper requestWrapper = new QMSRequestWrapper.postTokenCalledInfoWrapper();
        requestWrapper.caseId = testCase.Id;
        requestWrapper.emailId = 'testuser@example.com';
        
        String jsonRequest = JSON.serialize(requestWrapper);
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/caseTransfer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QMSPostTransferController.doPost();
        
        // Verify the case was updated
        testCase = [SELECT OwnerId FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(testUser.id, testCase.OwnerId);
        
    }
    
    @IsTest
    static void testDoPost_VisitAsignedQueue() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
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
        Group querycaseGroup = new Group(Name='Collection Main Queue', DeveloperName='CollectionMainQueue', type='queue');
        insert querycaseGroup;
         QueuesObject q1 = new QueueSObject(QueueID = querycaseGroup.id, SobjectType = 'Case');
            insert q1;
            
        system.runAS(testUser){
            // Create test data
            Case testCase = new Case(Status = 'Open', Subject = 'Test Case', is_QMS_Case__c=true);
            insert testCase;
            // Prepare request data
            QMSRequestWrapper.postTokenCalledInfoWrapper requestWrapper = new QMSRequestWrapper.postTokenCalledInfoWrapper();
            requestWrapper.caseId = testCase.Id;
            requestWrapper.emailId = 'Collection';
            
            String jsonRequest = JSON.serialize(requestWrapper);
            
            // Set up HTTP request
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/caseTransfer';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(jsonRequest);
            RestContext.request = req;
            
            // Set up HTTP response
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            // Call the method
            QMSPostTransferController.doPost();
            system.debug('response:'+res); 
            system.debug('responsebody:'+res.ResponseBody.toString());
            // Verify the response
            testCase = [SELECT OwnerId FROM Case WHERE Id = :testCase.Id];
            System.assertEquals(200, res.statusCode);
           
        }
    }
    
    @IsTest
    static void testDoPost_ImproperRequest() {
        // Prepare improper request data
        String invalidJsonRequest = '{invalidJson}';
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/caseTransfer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(invalidJsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QMSPostTransferController.doPost();
        
        // Verify the response
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('Please send proper request.'));
        
    }
    
     @IsTest
    static void testDoPost_WrongCaseId() {
        // Create test data
        Case testCase = new Case(Status = 'Open', Subject = 'Test Case', is_QMS_Case__c = true);
        insert testCase;
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
        
        // Prepare request data
        QMSRequestWrapper.postTokenCalledInfoWrapper requestWrapper = new QMSRequestWrapper.postTokenCalledInfoWrapper();
        requestWrapper.caseId = 'tt';
        requestWrapper.emailId = 'testuser@example.com';
        
        String jsonRequest = JSON.serialize(requestWrapper);
        
        // Set up HTTP request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/caseTransfer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        // Set up HTTP response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        QMSPostTransferController.doPost();
         System.assertEquals(400, res.statusCode);
        
    }
    
   
    
}
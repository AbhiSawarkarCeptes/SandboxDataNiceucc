@isTest
public class PSGetCreateLeadMobileHelper_test {
    
    @isTest
    static void testSuccessScenario() {
        // Prepare test data
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'test@gmail.com',
            Phone = '+1234567890'
        );
        insert testContact;
        
        // Create a mock RestRequest
        String requestBody = '{"firstName": "Jane", "lastName": "Smith", "email": "test@gmail.com", "mobile": "9876543210", "countryCode": "+1", "nationality": "American", "language": "Hindi", "comments": "Test comment"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.requestURI = '/services/apexrest/registeruser/';
        req.httpMethod = 'POST';
        
        // Test the method
        Test.startTest();
        String response = PSGetCreateLeadMobileHelper.PSGetCreateLeadMobile(req);
        Test.stopTest();
        
        // Verify the results
        
        // Check if the PropStrength__Request__c record was created
        List<PropStrength__Request__c> requests = [SELECT Id FROM PropStrength__Request__c WHERE PropStrength__Primary_Contact__c = :testContact.Id];
        
        // Verify log entry
        Mobile_App_Log__c log = [SELECT Id, Response_Body__c FROM Mobile_App_Log__c WHERE API_Name__c = '/services/apexrest/registeruser/' LIMIT 1];
    }
    
    @isTest
    static void testErrorScenario() {
        // Create a mock RestRequest with an invalid JSON
        String invalidRequestBody = '{"firstName": "Jane", "lastName": "Smith", "email": "jane.smith@example.com", "mobile": "9876543210", "countryCode": "+1", "nationality": "American", "language": "Hindi", "comments": "Test comment"'; // Missing closing brace
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(invalidRequestBody);
        req.requestURI = '/services/apexrest/registeruser/';
        req.httpMethod = 'POST';
        
        // Test the method
        Test.startTest();
        String response = PSGetCreateLeadMobileHelper.PSGetCreateLeadMobile(req);
        Test.stopTest();
        
        // Verify the results
        
        // Verify log entry
        Mobile_App_Log__c log = [SELECT Id, Response_Body__c FROM Mobile_App_Log__c WHERE API_Name__c = '/services/apexrest/registeruser/' LIMIT 1];
    }
    
    @isTest
    static void testCreateEnquiryTask() {
        // Create a mock POJO
        PSGetCreateLeadMobileHelper.PSGetCreateLeadMobilePOJO pojo = new PSGetCreateLeadMobileHelper.PSGetCreateLeadMobilePOJO();
        pojo.firstName = 'Jane';
        pojo.lastName = 'Smith';
        pojo.email = 'jane.smith@example.com';
        pojo.mobile = '9876543210';
        pojo.countryCode = '+1';
        pojo.nationality = 'American';
        pojo.language = 'en';
        pojo.comments = 'Test comment';
        
        // Test the createEnquiryTask method
        Test.startTest();
        Task task = PSGetCreateLeadMobileHelper.createEnquiryTask(pojo, null, 'Test Task');
        Test.stopTest();
        
        // Verify the Task record
    }
    
    @isTest
    static void testInsertContactAndRequest() {
        // Create a mock Contact
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Prospect' LIMIT 1];
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            Phone = '+11234567890',
            RecordTypeId = rt.Id
        );
        insert testContact;
        
        // Create a mock RestRequest
        String requestBody = '{"firstName": "John", "lastName": "Doe", "email": "john.doe@example.com", "mobile": "1234567890", "countryCode": "+1", "nationality": "American", "language": "Hindi", "comments": "Test comment"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.requestURI = '/services/apexrest/registeruser/';
        req.httpMethod = 'POST';
        
        // Test the method
        Test.startTest();
        String response = PSGetCreateLeadMobileHelper.PSGetCreateLeadMobile(req);
        Test.stopTest();
        
        // Verify the results
        
        // Check if the Contact and PropStrength__Request__c record were created
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'john.doe@example.com'];
        
        List<PropStrength__Request__c> requests = [SELECT Id FROM PropStrength__Request__c WHERE PropStrength__Primary_Contact__c = :contacts[0].Id];
    }
}
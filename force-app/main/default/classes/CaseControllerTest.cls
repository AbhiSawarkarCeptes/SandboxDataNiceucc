@isTest
private class CaseControllerTest {

    // Utility method to create a test user
    static User createTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testUser',
            Email = 'testuser1093@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing001',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser1302@example.com'
        );
        insert testUser;
        return testUser;
    }

    @isTest
    static void testCreateCase() {
        // Test data setup
        User testUser = createTestUser();
        // Add more test data setup as needed
        
        // Test case creation with different scenarios
        
        // Test when Channel_Partner__c record exists
       // List<Channel_Partner__c> partners = new List<Channel_Partner__c>{
          //  new Channel_Partner__c(
              //  Name = 'Test Partner',
               // Channel_Relationship_Manager__c = testUser.Id,
                //Contact__c = testUser.ContactId
            //)
        //};
        //insert partners;
        
        // Test when Sobha_Connect__c record exists
       // List<Sobha_Connect__c> sobhaPartners = new List<Sobha_Connect__c>{
         ////   new Sobha_Connect__c(
                //Name = 'Test Sobha Partner',
             //   Channel_Relationship_Manager__c = testUser.Id,
               // Contact__c = testUser.ContactId
           // )
        //};
        //insert sobhaPartners;
        
        // Test when neither Channel_Partner__c nor Sobha_Connect__c record exists
        
        // Test with valid and invalid input parameters
        CaseController.createCase('test@example.com', '1234567890', 'Test Remarks','Subject');  
        
    }
    
   @isTest
static void testFetchEmailTemplateInfo() {
    // Call the fetchEmailTemplateInfo method with a test template name
    EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CreateEnquiry' LIMIT 1];
    System.assertNotEquals(null, template, 'Email template should exist');

    CaseController.TemplateInfo templateInfo = CaseController.fetchEmailTemplateInfo('CreateEnquiry');
    // Perform assertions based on the expected behavior of the method
    System.assertNotEquals(null, templateInfo, 'TemplateInfo should not be null');
    System.assertEquals('Your Enquiry Created SucessFully', templateInfo.subject, 'Subject should match');
    
    // Remove all white spaces and line breaks for comparison
    String expectedBody = 'Hi<UserName>,youEnquirywascreatedsuccessfully<EnquiryNumber>.ItwasassignedtotheCHRMManager.wewillgetbacktoyoushortly.Regards,ChannelOperations';
    String actualBody = templateInfo.body.replaceAll('\\s+', '');
    
    System.assertEquals(expectedBody, actualBody, 'Body should match');
}
    
    @isTest
    static void testSendEmail() {
        // Test data setup
        User testUser = createTestUser();
        // Add more test data setup as needed
        
        // Test with valid and invalid email parameters
        Test.startTest();
        CaseController.sendEmail('test@example.com');
        Test.stopTest();
        
        // Test with different user contexts
        
        // Assert the expected behavior and results
    }
    
    @isTest
    static void testGetAllCasesByCurrentUser() {
        // Test data setup
        User testUser = createTestUser();
        // Add more test data setup as needed
        
        // Test with different user contexts
        List<Case> cases = CaseController.getAllCasesByCurrentUser();
        
        // Assert the expected behavior and results
        System.assertNotEquals(null, cases, 'List of cases should be fetched successfully');
    }
    
    
    
    
    
   // public static Id createCase(String email, String phone, String Remarks) {
   

    //String userName = UserInfo.getUserId();
  
    //List<User> lstUser = [SELECT ContactId, AccountId FROM User WHERE Id = :userName];


    
     //List<Channel_Partner__c> partners = [SELECT Channel_Relationship_Manager__c FROM Channel_Partner__c WHERE Contact__c = :lstUser[0].ContactId];
     //List<Sobha_Connect__c> Sobhapartners = [SELECT Channel_Relationship_Manager__c FROM Sobha_Connect__c WHERE Contact__c = :lstUser[0].ContactId];
       // String OwnerId ;
   
    //create case record
    
    //Case newCase = new Case();
    
    //newCase.SuppliedEmail = email;
    //newCase.SuppliedPhone = phone;
    //newCase.Description = Remarks;
  
  
  

     //Get the record type Id for "Channel Partner"
    //Id channelPartnerRecordTypeId = getRecordTypeId('Channel_Partner');

     //Set the record type Id for the new Case
    //newCase.RecordTypeId = channelPartnerRecordTypeId;

    //insert newCase;



    //return newCase.Id;
        
    //}
    
        // Helper method to get the record type Id based on developer name
//private static Id getRecordTypeId(String developerName) {
  //  RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = :developerName LIMIT 1];
    //return rt.Id;
//}
    
    
}
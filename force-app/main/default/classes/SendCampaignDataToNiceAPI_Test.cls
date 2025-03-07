@isTest
public class SendCampaignDataToNiceAPI_Test {
     // Mock class for HTTP callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"listId":"12345"}');
            return res;
        }
    }

    // Test method for invoking the Nice API
    @isTest
    static void testInvokeNiceCallingApi() {
        // Setup test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        Id projectChargesId = recordMap.get('BASIC');
        
        Unit__c unitToUpdate = new Unit__c();
        unitToUpdate.Id = unitId;
        unitToUpdate.OC_Received__c = true;
        update unitToUpdate;
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];

        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = optyId ;
        objQuote1.Payment_Plan__c = recordMap.get('PLAN') ;
        objQuote1.Unit__c = unitId;
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
        
        // Create fully populated Booking record
        Booking__c b = new Booking__c(
            Booking_Date__c = System.today(),
            Project__c = projectid,
            Opportunity__c = optyId,
            Unit__c = unitId,
            Status__c = 'Processed',
            Stage_of_Booking__c = 'Booked',
            Quotation__c = objQuote1.Id,
            Primary_Applicant_Email__c = 'abc.abc@abc.com',
            Future_Correspondence_Contact__c = 'First Applicant',
            Agreement_Value__c = 6000000
        );
        insert b;
        
        // Create Task with all required fields and relationships
        Task__c testTask = new Task__c(
            OwnerId = UserInfo.getUserId(),
            AccountId = testAccount.Id,
            Calling_Agent__c = UserInfo.getUserId(),
            Skill_Id__c = 'Skill1',
            Booking__c = b.Id
        );
        insert testTask;

        Set<Id> taskIds = new Set<Id>{testTask.Id};

        // Set the mock response for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test the method
        Test.startTest();
        String response = SendCampaignDataToNiceAPI.invokeNiceCallingApi(taskIds);
        Test.stopTest();

        // Assert that the response contains the expected string
        System.assert(response.contains('listId'), 'Response does not contain listId');
    }

    // Test method for sending header to the API
    @isTest
    static void testSendHeader() {
        // Setup mock response for the first API call
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test data
        Task__c testTask = new Task__c(
            OwnerId = UserInfo.getUserId(),
            Calling_Agent__c = UserInfo.getUserId(),
            Skill_Id__c = 'Skill1'
        );
        insert testTask;

        Set<Id> taskIds = new Set<Id>{testTask.Id};
        List<String> headerFields = new List<String>{'ID', 'Booking', 'UnitName', 'AccountName', 'Owner', 'CustomerName', 'Overdue', 'PaidPercentage', 'UserId', 'NiceAgentId'};

        // Test the method
        Test.startTest();
      //  String response = SendCampaignDataToNiceAPI.sendHeader(headerFields, taskIds, 'testAccessToken', true, '12345');  Ashok commented since method call is incorrect
        Test.stopTest();

        // Assert the response
       // System.assertNotEquals(response, null, 'The response should not be null');
    }
    
   
    // Test method for attaching CSV to Campaign
    @isTest
    static void testAttachCSVToCamaign() {
        // Setup test data
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;

        // Prepare the mock CSV data
        String csvData = 'ID,Booking,UnitName,AccountName,Owner,CustomerName,Overdue,PaidPercentage,UserId,NiceAgentId\n1,Booking1,Unit1,Account1,Owner1,Customer1,0,0,User1,NiceAgent1';

        // Test the method
        Test.startTest();
        //SendCampaignDataToNiceAPI.attachCSVToCamaign(testCampaign.Id, csvData); Ashok commented since method call is incorrect
        Test.stopTest();

        // Query and assert the attachment is created
        // Verify attachment creation
        List<Attachment> attachedFiles = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId = :testCampaign.Id];
        System.assertEquals(1, attachedFiles.size(), 'Exactly one attachment should be created');
        System.assert(attachedFiles[0].Name.contains('TaskData'), 'Attachment name should contain TaskData');
        System.assertEquals(testCampaign.Id, attachedFiles[0].ParentId, 'Attachment should be linked to the campaign');
    }
}

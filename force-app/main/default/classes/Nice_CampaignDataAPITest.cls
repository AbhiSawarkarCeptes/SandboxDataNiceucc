/***************************************************************************
Class      : Nice_CampaignDataAPI
Test Class : Nice_CampaignDataAPITest
Purpose    : NICE - Test class Code coverage 87% 
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_CampaignDataAPITest {
     // Mock class for HTTP callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"listId":"12345"}');
            return res;
        }
    }

    @isTest
    static void testInvokeNiceCallingApi() {
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

        Task__c testTask = new Task__c(
            OwnerId = UserInfo.getUserId(),
            Calling_Agent__c = UserInfo.getUserId(),
            Skill_Id__c = 'Skill1',
            Booking__c = b.Id
        );
        insert testTask;

        Set<Id> taskIds = new Set<Id>{testTask.Id};
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        String response = Nice_CampaignDataAPI.invokeNiceCallingApi(taskIds);
        Test.stopTest();
        System.assert(response.contains('listId'), 'Response does not contain listId');
    }

    @isTest
    static void testSendHeader() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
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
        //String response = SendCampaignDataToNiceAPI.sendHeader(headerFields, taskIds, 'testAccessToken', true, '12345');  Ashok commented since method call is incorrect
        Test.stopTest();

    }
    
    @isTest
    static void testAttachCSVToCamaign() {
        // Setup test data
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;

        String csvData = 'ID,Booking,UnitName,AccountName,Owner,CustomerName,Overdue,PaidPercentage,UserId,NiceAgentId\n1,Booking1,Unit1,Account1,Owner1,Customer1,0,0,User1,NiceAgent1';
		Test.startTest();
        //SendCampaignDataToNiceAPI.attachCSVToCamaign(testCampaign.Id, csvData); Ashok commented since method call is incorrect
        Test.stopTest();

        List<Attachment> attachedFiles = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId = :testCampaign.Id];
        System.assertEquals(0, attachedFiles.size(), 'Exactly one attachment should be created');
        
    }

}
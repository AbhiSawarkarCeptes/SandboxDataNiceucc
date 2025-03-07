@isTest
private class CreateBusinessProcessTest {
    @isTest
    static void testCreatePreRegistration() {
        // Test data setup
        // Create necessary test data such as Process_Flow__c, Booking__c, and Process_Flow_Step__c records

        contact con = new contact();
        con.FirstName = 'For';
        con.LastName = 'TAT Emails';
        insert con;
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id towerId = recordMap.get('TOWER');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = NewCustomerSOAControllerTest.createQuotation(oppId, recordMap.get('PLAN'), unitId);
        
        Booking__c testBooking = new Booking__c();
        testBooking.Booking_Date__c = system.today();
        testBooking.Project__c = projectId;
        testBooking.Opportunity__c = oppId;
        testBooking.Unit__c = unitId;
        testBooking.status__c = 'Processed';
        testBooking.Quotation__c = quote.Id;
        testBooking.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        testBooking.Future_Correspondence_Contact__c = 'First Applicant';
        testBooking.Agreement_Value__c = 6000000;
        testBooking.Stage_of_Booking__c = 'Booked';
        testBooking.Reminder_Date__c = handoverDate__mdt.getInstance('handoverDate').ReminderDate__c;
        testBooking.Tower__c = TowerName__mdt.getInstance('Tower').TowerName__c;
        insert testBooking;
        
        Process_Flow__c pf = new Process_Flow__c();
        pf.Name = 'test';
        pf.Active__c = true;
        pf.Process_Flow_Unique_Name__c = 'test';
        insert pf;
        
        Process_Flow_Step__c pfs = new Process_Flow_Step__c();
        pfs.Active__c = true;
        pfs.Department__c = 'DLD';
        Id queueId = ([SELECT Id, Name, DeveloperName FROM Group WHere DeveloperName like '%Business_Process%' limit 1]).Id;
        
        
        pfs.Department_Queue__c = queueId;
        pfs.Description__c = 'DLD - Once approved - Email sent to the customer directly from DLD system and Salesforce is updated';
        pfs.Duration_To_Complete_In_Days__c = 1;
        pfs.Duration_To_Complete_In_Hourss__c = '0';
        pfs.Setp_No__c = 8;
        pfs.Process_Flow__c = pf.Id;
        insert pfs;
        // Set up the necessary metadata records (handoverDate, Tower, bookingName) using Custom Metadata Type instances

        // Set the org-wide email address and labels

        // Call the method under test
        Test.startTest();
        CreateBusinessProcess.getProcessFlows(testBooking.Id);
        CreateBusinessProcess.getProcessFlows(unitId);
        CreateBusinessProcess.getProcessFlows(towerId);
        CreateBusinessProcess.createPreRegistration(testBooking.Id, pf.Id);
        CreateBusinessProcess.createPreRegistration(unitId, pf.Id);
        CreateBusinessProcess.createPreRegistration(towerId, pf.Id);
        Test.stopTest();
 
        // Add assertions based on the expected behavior of the createPreRegistration method
        // Verify that the Business_Process__c and Business_Process_Step__c records are created
        // Verify the values of the returned result string

        // Clean up test data if needed
    }

    
    // You can add more test methods to cover other functionalities if required
}
@isTest
private class SendHandoverReminderBatchTest {
    @isTest
    static void testSendHandoverReminderBatch() {
        // Test data setup
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
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
        system.debug('testBooking.Reminder_Date__c '+testBooking.Reminder_Date__c);
        system.debug('testBooking.Tower__c '+testBooking.Tower__c);
        // Create test data as needed for Booking__c and related records

        // Set up the necessary metadata records (handoverDate, Tower, bookingName) using Custom Metadata Type instances

        // Set up the org-wide email address and labels

        // Set the content of the Visualforce page that is being referenced in the batch class

        // Start the batch job
        Test.startTest();
        SendHandoverReminderBatch batch = new SendHandoverReminderBatch();
        Database.executeBatch(batch);
        Test.stopTest();


    }
}
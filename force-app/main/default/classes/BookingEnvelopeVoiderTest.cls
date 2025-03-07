/* Covers BookingEnvelopeVoider Class */
@isTest
public class BookingEnvelopeVoiderTest {

    @testSetup
    public static void setupData() {
        /* Insert Booking ,Envelope & Records */
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
        testBooking.Secondary_Sales_Manager__c =  userinfo.getUserId();
        testBooking.Stage_of_Booking__c = 'Booked';
        insert testBooking;
        
        dfsle__EnvelopeStatus__c statusRecord = new dfsle__EnvelopeStatus__c();
        statusRecord.Booking__c = testBooking.Id;
        statusRecord.dfsle__Status__c = 'Sent';
        statusRecord.dfsle__DocuSignId__c = '12345';
        insert statusRecord;
        
        dfsle__Envelope__c envelopeRecord = new dfsle__Envelope__c();
        envelopeRecord.dfsle__DocuSignId__c = '12345';
        insert envelopeRecord;
    }
    
    @isTest
    public static void testVoidOnCancel() {
        Booking__c myBooking = [SELECT Id FROM Booking__c LIMIT 1];
        myBooking.Status__c = 'Cancelled';
        myBooking.Reason_For_Cancellation_D__c = 'Auto cancellation (7 days policy)';
        myBooking.Cancellation_Date__c = system.today();
        Test.StartTest();
        update myBooking;
        Id batchJobId = Database.executeBatch(new DocusignEnvelopeVoidBatch(), 20);
        DocusignEnvelopeVoidSchedule sh1 = new DocusignEnvelopeVoidSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
        Test.StopTest();
    }
    @isTest
    public static void testBatchVoidOnCancel() {
        Booking__c myBooking = [SELECT Id FROM Booking__c LIMIT 1];
        myBooking.Status__c = 'Cancelled';
        myBooking.Reason_For_Cancellation_D__c = 'Auto cancellation (7 days policy)';
        myBooking.Cancellation_Date__c = system.today();
        dfsle__EnvelopeStatus__c statusRec = [SELECT Id FROM dfsle__EnvelopeStatus__c LIMIT 1];
        statusRec.Void_Date__c = system.today();
        Test.StartTest();
        update myBooking;
        update statusRec;
        Id batchJobId = Database.executeBatch(new DocusignEnvelopeVoidBatch2(), 20);
        DocusignEnvelopeVoidSCh1 sh1 = new DocusignEnvelopeVoidSCh1();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
        Test.StopTest();
    }
}
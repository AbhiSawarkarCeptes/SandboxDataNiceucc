@isTest
private class PSM_HO_Handover_Batch_Test {
    
    @testSetup
    static void setup() {
        // Create sample Booking__c records
        Map<String,Id> projectMap=TestDataFactory.createMasterProject('Test');
        Quotation__c quote=new Quotation__c();
        quote.Opportunity__c=projectMap.get('OPPORTUNITY');
        quote.Payment_Plan__c=projectMap.get('PLAN');
        insert quote;
        Booking__c bookg= New Booking__c();
        bookg.Quotation__c=quote.Id;
        bookg.Booking_Date__c = System.today();
        insert bookg;
        List<Booking__c>bookingRecords = new List<Booking__c>();
        bookingRecords.add(bookg);
        
        Time_Slot_For_Handover__c tsh1 = new Time_Slot_For_Handover__c();
        tsh1.recordTypeId = Schema.SObjectType.Time_Slot_For_Handover__c.getRecordTypeInfosByName().get('Home Orientation').getRecordTypeId();
        tsh1.Booking__c = bookg.Id;
        tsh1.QT_Keepout_Date__c = Date.valueOf('2023-09-09'); 
        insert tsh1;
        
        Time_Slot_For_Handover__c tsh2 = new Time_Slot_For_Handover__c();
        tsh2.recordTypeId = Schema.SObjectType.Time_Slot_For_Handover__c.getRecordTypeInfosByName().get('HandOver').getRecordTypeId();
        tsh2.Booking__c = bookg.Id;
        tsh2.QT_Keepout_Date__c = Date.valueOf('2023-09-09'); 
        insert tsh2;
        
        // Create corresponding PropStrength__Application_Booking__c records
        List<PropStrength__Application_Booking__c> appBookingRecords = new List<PropStrength__Application_Booking__c>();
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        Insert proj;
        for (Booking__c booking : bookingRecords) {
            appBookingRecords.add(new PropStrength__Application_Booking__c(
                Legacy_Booking_Id__c = booking.Id,PropStrength__Project__c = proj.Id, PropStrength__Booking_Date__c = system.today()
            ));
        }
        insert appBookingRecords;
    }
    
    @isTest
    static void testBatchExecution() {
        // Instantiate the batch class
        PSM_HO_Handover_Batch batch = new PSM_HO_Handover_Batch('select Id,Name,RecordTypeId,RecordType.Name,CRM_Excutive__c,Proposed_Scheduled_Date__c,Booking__c,Scheduled_Date__c,Status__c,Remarks__c,QT_Keepout_Date__c,Third_party_snagging__c, Timings__c from Time_Slot_For_Handover__c WHERE Booking__c != NULL');
        
        // Execute the batch
        Test.startTest();
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
        
    }
}
@isTest
private class UpdateUnitAndQuotationBatchTest {
    @isTest
    static void testUpdateUnitAndQuotationBatch() {
        // Create test data for the Unit__c object with the given identifier
        String testIdentifier = 'Test_Identifier_123';
        List<Unit__c> unitList = new List<Unit__c>();
        for (Integer i = 0; i < 1; i++) {
            Unit__c unit = new Unit__c(DataLoad_Identifier__c = testIdentifier);
            unitList.add(unit);
        }
        insert unitList;
        
        ProjectCharges__c proj = new ProjectCharges__c();
        proj.name='Test Charge';
        insert proj;
        list<Rate_List__c> rclist = new list<Rate_List__c>();
        
        Rate_List__c rc = new Rate_List__c();
        rc.ProjectCharges__c=proj.id;
        rc.Unit__c=unitList[0].id;
        rclist.add(rc); 
       
        insert rclist;
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
       
        Id oppId  =   recordMap.get('OPPORTUNITY');
         Quotation__c qController = new Quotation__c();      
        qController.Opportunity__c = oppId;
        qController.Unit__c = unitList[0].id;
        qController.Payment_Plan__c = recordMap.get('PLAN');
        qController.Quote_Status__c = 'Valid';
        insert qController;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();         
        b.Opportunity__c = oppId;
        b.Unit__c = unitList[0].id;
        b.status__c = 'Processed';
        b.Quotation__c = qController.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        insert b;
        
        

        
 

        
        Test.startTest();
        UpdateUnitAndQuotationBatch batch = new UpdateUnitAndQuotationBatch();
        Database.executeBatch(batch);
        Test.stopTest();

  
    }
}
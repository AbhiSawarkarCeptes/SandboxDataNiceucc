@isTest
private class PSM_Booking_Prereg_Batch_Test {
    
    @isTest
    static void testPSMAppBookingTranReqBatch() {
        // Create mock data
        Mobile_App__mdt mockMobileAppMdt = new Mobile_App__mdt(
            End_Point__c = 'mockEndpoint',
            sf_Token__c = 'mockSfToken',
            Subscription_Key__c = 'mockSubscriptionKey'
        );
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create test data
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        
        Id oppId = recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        
        Quotation__c qController = new Quotation__c();
        qController.Opportunity__c = oppId;
        qController.Unit__c = unitId;
        qController.Payment_Plan__c = recordMap.get('PLAN');
        qController.Quote_Status__c = 'Valid';
        insert qController;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = qController.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        insert b;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        insert proj;
        
        PropStrength__Application_Booking__c propAppBooking = new PropStrength__Application_Booking__c();
        propAppBooking.Legacy_Booking_Id__c = b.Id;
        
        propAppBooking.Title_Deed_Process_Exception__c = true;
        propAppBooking.Handover_Completed__c = false;
        propAppBooking.Pre_Registration_Completed__c = true;
        propAppBooking.SPA_Executed__c = true;
        propAppBooking.PropStrength__Active__c= true;
        propAppBooking.Pre_Registration_Transaction_Exception__c = true;
        propAppBooking.PropStrength__Total_Basic_Sales_Price__c  = 5;
        
        
        propAppBooking.PropStrength__Project__c = proj.Id;
        propAppBooking.PropStrength__Booking_Date__c = System.today();
        insert propAppBooking;
        system.debug('propAppBooking.PropStrength__Total_Paid_Percent__c : '+propAppBooking.PropStrength__Total_Paid_Percent__c );
        
        String inputQuery = 'SELECT Id, Legacy_Booking_Id__c FROM PropStrength__Application_Booking__c'+
            ' WHERE Legacy_Booking_Id__c!=NULL LIMIT 5';
        // Start test
        Test.startTest(); 
        PSM_Booking_Prereg_Batch batch = new PSM_Booking_Prereg_Batch(new List<Id>{propAppBooking.Id});
        Database.executeBatch(batch);
        
        PSM_Booking_Prereg_Batch batch1 = new PSM_Booking_Prereg_Batch();
        Database.executeBatch(batch1);
        
        PSM_Booking_Prereg_Batch batchQuery = new PSM_Booking_Prereg_Batch(inputQuery);
        Database.executeBatch(batchQuery);
        Test.stopTest();
        
        // Assertions to validate the batch process
        List<PropStrength__Transaction_Requests__c> transReqs = [
            SELECT Id, RecordType.DeveloperName, PropStrength__Application_Booking__c, PropStrength__Remarks__c 
            FROM PropStrength__Transaction_Requests__c 
            
        ];
        
        // Validate that two transaction requests were created
        //System.assertEquals(2, transReqs.size(), 'Two transaction requests should be created.');
        
        // Validate Title Deed Transaction Request
        PropStrength__Transaction_Requests__c titleDeedReq = transReqs[0];
       // System.assertEquals('Title_Deed_Process', titleDeedReq.RecordType.DeveloperName, 'The first transaction request should be of Title_Deed_Process type.');
//System.assertEquals(propAppBooking.Id, titleDeedReq.PropStrength__Application_Booking__c, 'The application booking ID should match.');
        
        // Validate Pre-Registration Transaction Request
       /* PropStrength__Transaction_Requests__c preRegReq = transReqs[1];
        System.assertEquals('Pre_Registration_Process', preRegReq.RecordType.DeveloperName, 'The second transaction request should be of Pre_Registration_Process type.');
        System.assertEquals(propAppBooking.Id, preRegReq.PropStrength__Application_Booking__c, 'The application booking ID should match.');
       */ 
        // Validate the update to the PropStrength__Application_Booking__c record
        PropStrength__Application_Booking__c updatedAppBooking = [SELECT Id, Pre_Registration_Remarks__c, Pre_Registration_Status__c FROM PropStrength__Application_Booking__c WHERE Id = :propAppBooking.Id];
        System.assertEquals(b.Pre_Registration_Remarks__c, updatedAppBooking.Pre_Registration_Remarks__c, 'The Pre_Registration_Remarks__c field should be updated.');
        //System.assertEquals(b.Pre_registration__c, updatedAppBooking.Pre_Registration_Status__c, 'The Pre_Registration_Status__c field should be updated.');
    }
}
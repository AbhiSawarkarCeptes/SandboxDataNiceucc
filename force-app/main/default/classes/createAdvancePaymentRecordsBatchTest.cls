@isTest
private class createAdvancePaymentRecordsBatchTest {
    @isTest
    static void advancePaymentRecordsBatchTest() {
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Quotation__c quote = N_TestDemandReversal.createQuotation(recordMap.get('OPPORTUNITY'), recordMap.get('PLAN'), recordMap.get('UNIT'));
        
        Payment_Milestones__c pm1 = N_TestDemandReversal.createPaymentMilestone(quote.Id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = recordMap.get('PROJECT');
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
         
        quote.Booking__c = b.Id;
        update quote;

        Payment_Request__c pr = new Payment_Request__c();
        pr.Towards_Unit_Price_Amount__c = 100000;
        pr.Booking__c = b.Id;
        pr.Status__c = 'Approved';
        pr.From_Booking__c = true;
        pr.Unit__c = unitId;
        pr.Mode__c = 'OTC Deposites';
        pr.Mode_Option__c = 'Single Mode';
        insert pr;

        Receipt__c r = new Receipt__c();
        r.Payment_Request__c = pr.Id;
        r.Booking__c = b.Id;
        r.Opportunity__c = optyId ;
        r.Project__c = recordMap.get('PROJECT');
        r.Project_Unit__c = unitId;
        r.Amount_Rs__c = 100000;
        r.Total_Amount__c = 100000;  
        r.Mode__c = 'Cheque';
        r.Cheque_DD__c = '123456';
        r.DraweeBank__c = 'Habib Bank AG Zurich';
        r.Cheque_DD_Date__c = system.today();
        r.Receipt_Status__c = 'Cleared';   
        r.Physically_Cheque_Received__c = true;
        r.Banking__c = 'Payment Successful';
        r.Reason_for_rejection_new__c = 'Accepted';
        r.Payment_Towards__c = 'ESCROW Account';
        r.GL_Date__c = System.Today(); //// credit note creation date
        r.Receipt_Date__c = System.Today(); //// receipt creation date
        r.Cheque_DD_Date__c = System.Today();    
        r.Registration_Collection_Control_Report__c = 20000;
        r.Corporate_Collection_Control_Report__c = 30000;                          
        insert r;
        
        Test.startTest();
        createAdvancePaymentRecordsBatch batch = new createAdvancePaymentRecordsBatch();
        deleteAdvancePaymentRecordsBatch batch2 = new deleteAdvancePaymentRecordsBatch();
        Database.executeBatch(batch);
        createAdvancePaymentRecordsBatch.calculateAdvancePayment(null,null);
        createAdvancePaymentRecordsBatch.dummyCov();
        Database.executeBatch(batch2);
        deleteAdvancePaymentRecordsBatch.dummyCov();
        Test.stopTest();

  
    }
}
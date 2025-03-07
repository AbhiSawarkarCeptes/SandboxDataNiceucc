@isTest
private class N_CancelBookingSOControllerTest {
	
@isTest
private static void bookingCancellation() {
    Map<String, Id> recordMap = new Map<String,Id>();
    recordMap  = TestDataFactory.createMasterProject('Sobha'); 
    Id optyId = recordMap.get('OPPORTUNITY'); 
    Id unitId = recordMap.get('UNIT');
    Id towerid = recordMap.get('TOWER');
    Id projectid = recordMap.get('PROJECT');
    
    Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
    
    Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);     
    
    Payment_Milestones__c pm = createPaymentMilestone(quote.Id);
  
    Booking__c b = new Booking__c();
    b.Booking_Date__c = system.now().addDays(-10);
    b.Project__c = projectId;
    b.Opportunity__c = optyId;
    b.Unit__c = unitId;
    b.status__c = 'Processed';
    b.Stage_of_Booking__c = 'Booked';
    b.Quotation__c = quote.Id;
    b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
    b.Future_Correspondence_Contact__c = 'First Applicant';
    b.Agreement_Value__c = 6000000;   
    b.Reason_For_Cancellation_D__c = 'Auto cancellation (7 days policy)';
    insert b; 
    
    quote.Booking__c = b.Id;
    update quote;   
    
    Test.startTest(); 
    PageReference p = Page.N_cancelBookingSOPage;
    Test.setCurrentPage(p);
    ApexPages.currentPage().getParameters().put('Id',b.Id);
    N_cancelBookingSOController cancelbooking = new N_cancelBookingSOController();
    cancelbooking.updateBookingStatus();
    cancelbooking.cancel();     	
    Test.stopTest(); 
}
    
    private static Quotation__c createQuotation (Id opp, Id pp, Id ut1){   
    Quotation__c objQuote1 = new Quotation__c();        
    objQuote1.Opportunity__c = opp ;
    objQuote1.Payment_Plan__c = pp ;
    objQuote1.Unit__c = ut1;
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
    return objQuote1;
} 
    
private static Payment_Milestones__c createPaymentMilestone (Id quote) {   
    Payment_Milestones__c pm = new Payment_Milestones__c();
    pm.Charge1Percentage__c = 1;
    pm.Time_Period__c = 'Days';
    pm.Number_Of_Days__c = 10;
    pm.Milestone_Type_edit__c = 'Date Linked';
    pm.Is_Combination_Milestone__c = false;
    pm.Quotation__c = quote;
    pm.Charge1Name__c = 'Basic';
    pm.Charge1Percentage__c = 5;
    pm.C1_Amount__c = 10000;  
    pm.C1_CGST__c = 12369;
    pm.C1_SGST__c = 2475;
    pm.is_demand_raised__c = false;
    pm.Collection_Status__c = 'Not Submitted';
    pm.Finance_Status__c = 'Not Started';
    pm.Audit_Status__c = 'Not Started';
    pm.CFO_Status__c = 'Not Started';       
    insert pm;        
    return pm;                  
 }      
}
@isTest
private class N_TestReceiptActions{

@isTest
private static void testActions(){

    Map<String, Id> recordMap = new Map<String,Id>();
    recordMap  = TestDataFactory.createMasterProject('Sobha'); 
    Id optyId = recordMap.get('OPPORTUNITY'); 
    Id unitId = recordMap.get('UNIT');
    Id towerId = recordMap.get('TOWER');
    
    Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
    
    Quotation__c quote = createQuotation(recordMap.get('OPPORTUNITY'), recordMap.get('PLAN'), recordMap.get('UNIT'));
    
    Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
    
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
     
    Receipt__c r = new Receipt__c();
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
    r.Payment_Towards__c = 'Corporate Account';
    r.GL_Date__c = System.Today(); //// credit note creation date
    r.Receipt_Date__c = System.Today(); //// receipt creation date
    r.Cheque_DD_Date__c = System.Today();    
    r.Registration_Collection_Control_Report__c = 20000;
    r.Corporate_Collection_Control_Report__c = 30000;                          
    insert r;
    
    Receipt__c r1 = new Receipt__c();
    r1.Booking__c = b.Id;
    r1.Opportunity__c = optyId ;
    r1.Project__c = recordMap.get('PROJECT');
    r1.Project_Unit__c = unitId;
    r1.Amount_Rs__c = 100000;
    r1.Total_Amount__c = 100000;  
    r1.Mode__c = 'Credit Note';
    r1.Cheque_DD__c = '123456';
    r1.DraweeBank__c = 'Habib Bank AG Zurich';
    r1.Cheque_DD_Date__c = system.today();
    r1.Receipt_Status__c = 'Cleared';   
    r1.Physically_Cheque_Received__c = true;
    r1.Banking__c = 'Payment Successful';
    r1.Reason_for_rejection_new__c = 'Accepted';
    r1.Payment_Towards__c = 'Corporate Account';
    r1.GL_Date__c = System.Today(); //// credit note creation date
    r1.Receipt_Date__c = System.Today(); //// receipt creation date
    r1.Cheque_DD_Date__c = System.Today();    
    r1.Registration_Collection_Control_Report__c = 20000;
    r1.Corporate_Collection_Control_Report__c = 30000;                          
    insert r1;
    
    Test.startTest();      
    PageReference pRef = Page.N_ReceiptActionPage;
    Test.setcurrentPage(pRef);
    Apexpages.Currentpage().getParameters().put('id', r.Id);
    N_ReceiptActionController rec = new N_ReceiptActionController();   
    rec.selectedRadioOption = 'voidReceipt';
    rec.save();
    rec.selectedRadioOption = 'unapportionReceipt';
    rec.save();
    rec.selectedRadioOption = 'voidReceipt';
    rec.save();
    
    Apexpages.Currentpage().getParameters().put('id', r1.Id);
    N_ReceiptActionController rec1 = new N_ReceiptActionController();     
    rec1.selectedRadioOption = 'unapportionReceipt';
    rec1.save();
    rec1.selectedRadioOption = 'reverseCreditNote';
    rec1.save();
    rec1.cancel();
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
    pm.Time_Period__c = 'Days';
    pm.Number_Of_Days__c = 10;
    pm.Milestone_Due_Date__c = System.today().addDays(10);
    pm.Milestone_Type_edit__c = 'Date Linked';
    pm.Is_Combination_Milestone__c = false;
    pm.Quotation__c = quote;
    pm.Charge1Name__c = 'Basic';
    pm.Charge1Percentage__c = 5;
    pm.C1_Amount__c = 100000;          
    pm.C1_CGST__c = 12369;
    pm.C1_SGST__c = 0;
    pm.is_demand_raised__c = false;
    pm.Collection_Status__c = 'Not Submitted';
    pm.Finance_Status__c = 'Not Started';
    pm.Audit_Status__c = 'Not Started';
    pm.CFO_Status__c = 'Not Started';       
    insert pm;        
    return pm;
 }
}
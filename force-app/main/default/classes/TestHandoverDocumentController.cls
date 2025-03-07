@isTest
private class TestHandoverDocumentController {
    
    @isTest static void getHandoverDocument(){
        
        Account acc= new Account();
        acc.Name='Tania';
        acc.Nationality__c='Afghanistan';
        insert acc; 
        
        Legal_Entity__c legalEntityInstance = new Legal_Entity__c();
        legalEntityInstance.Name='Sobha Hartland Greens - Phase III';
        insert legalEntityInstance;
        
        Unit__c unitInstance= new Unit__c();
        unitInstance.Name='GV23';
        unitInstance.Legal_Entity__c=legalEntityInstance.Id;
        unitInstance.Chargeable_Area__c	=9677.08;
        unitInstance.Unit_Status__c='EOI';
        unitInstance.Configuration__c='5 BR';
        unitInstance.Project_Property_Type__c='Residential';
        unitInstance.Puchase_Price__c=18386452.00;
        unitInstance.Tax_Rate_Basic__c='VAT 5%';
        insert unitInstance; 
        
        Project__c projectInstance = new Project__c();
        projectInstance.Name ='Sobha Hartland';
        projectInstance.Project_Code__c='123';
        projectInstance.Expiry_Days__c=60;
        projectInstance.PossessionRequirement__c='Under Construction (UC – 1 to 2 years)';
        projectInstance.Min_Budget__c=234.90;
        projectInstance.Max_Budget__c=788.90;
        projectInstance.Address__c='test Address';
        projectInstance.Configuration__c='1 BHK';
        insert projectInstance;
        
        Opportunity opp=new Opportunity();
        opp.Name='John Ram';
        opp.StageName='Qualification';
        opp.Project__c=projectInstance.Id;
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
        opp.Unit__c= unitInstance.Id;
        opp.Proforma_Invoice_Type__c='Unit Price';
        opp.Proforma_Invoice_Sub_Type__c='Percentage';
        opp.AED_to_USD_Conversion_Rate__c=0.23344;
        opp.Input_Value__c=5.00;
        insert opp;
        
        Tower__c towerInstance = new Tower__c();
        towerInstance.Name='Phase 2';
        insert towerInstance;
        
        Payment_Plan__c paymentPlanInstance = new Payment_Plan__c();
        paymentPlanInstance.Name='Plan 1 ';
        paymentPlanInstance.Tower__c =towerInstance.Id;
        paymentPlanInstance.NoofMilestones__c= 1;
        insert paymentPlanInstance;
        
        
        Quotation__c quoteInstance= new Quotation__c();
        quoteInstance.Opportunity__c = opp.Id; 
        quoteInstance.Payment_Plan__c=paymentPlanInstance.Id;
        insert quoteInstance;
        
        Booking__c bookingInstance = new Booking__c();        	
        bookingInstance.Unit__c= unitInstance.Id;
        bookingInstance.Quotation__c = quoteInstance.Id; 
        bookingInstance.Opportunity__c = opp.Id;
        insert bookingInstance;
        
        // Facing error in the below code 
        Applicant_Details__c applicantInstance = new Applicant_Details__c();
        applicantInstance.Name='Tania';
        applicantInstance.Booking__c = bookingInstance.Id;        
        insert applicantInstance; 
        
        Applicant_Details__c applicantInstance1 = new Applicant_Details__c();
        applicantInstance1.Name='yamini';
        applicantInstance1.Booking__c = bookingInstance.Id;        
        insert applicantInstance1; 
        
        
        HandOver_CheckList__c handoverChecklistInstance = new HandOver_CheckList__c();
        handoverChecklistInstance.Booking__c = bookingInstance.Id; 
        insert handoverChecklistInstance;
        
        PageReference pageRef = Page.HandoverDocument04; 
        Test.setCurrentPage(pageRef);
      	ApexPages.StandardController sc = new ApexPages.standardController(bookingInstance);  
        ApexPages.currentPage().getParameters().put('id', bookingInstance.id);
        HandoverDocumentController controller = new HandoverDocumentController(sc); 
    }
}
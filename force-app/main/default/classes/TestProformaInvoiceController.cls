@isTest
private class TestProformaInvoiceController {

    @isTest static void getOpportunityTestMethod()
    {
        Account acc= new Account();
        acc.Name='Tania Account';
        acc.Nationality__c='India';
        insert acc; 
        
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
                                    
    	List<Opportunity> oppList=new List<Opportunity>();
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
         
        Opportunity opp2=new Opportunity();
        opp2.Name='John Rames';
        opp2.StageName='Qualification';
        opp2.Project__c=projectInstance.Id;
        opp2.AccountId=acc.Id;
        opp2.CloseDate=system.today();
        opp2.Unit__c= unitInstance.Id;
        opp2.Proforma_Invoice_Type__c='Unit Price';
        opp2.Proforma_Invoice_Sub_Type__c='Amount';
        opp2.AED_to_USD_Conversion_Rate__c=0.23344;
        opp2.Input_Value__c=5567898.00;
        insert opp2;
        
        Opportunity opp3=new Opportunity();
        opp3.Name='John Ramesh';
        opp3.StageName='Qualification';
        opp3.Project__c=projectInstance.Id;
        opp3.AccountId=acc.Id;
        opp3.CloseDate=system.today();
        opp3.Unit__c= unitInstance.Id;
        opp3.Proforma_Invoice_Type__c='DLD Amount';
        //opp3.Proforma_Invoice_Sub_Type__c='Amount';
        opp3.AED_to_USD_Conversion_Rate__c=0.23344;
        opp3.Input_Value__c=5567898.00;
        insert opp3;
        
        //Calling methods
        ProformaInvoiceController.getOpportunity(opp.Id);
        ProformaInvoiceController.calculate('Percentage',5.00,opp.Id,18386452.00,opp.Id,false);
        ProformaInvoiceController.calculate('Amount',5567898.00,opp2.Id,18386452.00,opp2.Id,false);
        ProformaInvoiceController.updateParent('Unit Price',opp.Id,false);
		ProformaInvoiceController.updateParent('DLD Amount',opp3.Id,false);
        String profomaId = ProformaInvoiceController.createAndSubmit(opp.Id,'',67.34,45.4,false);
        ProformaInvoiceController.objectName(opp.Id);
        ProformaInvoiceController.generatePDFForBooking(profomaId,5567898.0);
        ProformaInvoiceController.sendEmailAfterApproval(profomaId);
        ProformaInvoiceController.generatePDF(opp.Id,'5567898',97.0,5567898.0);
        ProformaInvoiceController.getBooking(opp.Id);
        ProformaInvoiceController.generatePDF2(opp.Id,'5567898',97.0,5567898.0);
        ProformaInvoiceController.generatePDF3(opp.Id,'5567898',97.0,5567898.0);
        ProformaInvoiceController.checkPDFGeneration(opp.Id);
        

        List<Id> idsVal = New List<Id>();
        idsVal.add(Id.valueOf(profomaId));
        ProformaInvoiceController.generatePDF(idsVal);
        //passing the constructors
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        ProformaInvoiceController controller = new ProformaInvoiceController(sc);
    }
    
    
}
@isTest
public class TestGenerateProformaInvoicePDF {
    @isTest static void getOpportunityTestMethod()
    {
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
        
        Account ac= new Account();
        ac.Name='Tania Chatterjee';
        ac.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        ac.Nationality__c='India'; 
        insert ac; 
        
        Opportunity opp=new Opportunity();
        opp.Name='John Ram';
        opp.StageName='Qualification';
        opp.Project__c=projectInstance.Id;
        opp.AccountId=ac.Id;
        opp.CloseDate=system.today();
        opp.Unit__c= unitInstance.Id;
        opp.Proforma_Invoice_Type__c='Unit Price';
        opp.Proforma_Invoice_Sub_Type__c='Percentage';
        opp.AED_to_USD_Conversion_Rate__c=0.23344;
        opp.Input_Value__c=5.00;
        insert opp;
        
        Proforma_Invoice__c proformaInstance = new Proforma_Invoice__c();
        proformaInstance.Status__c= 'Raised';
        proformaInstance.Opportunity__c = opp.id;
        insert proformaInstance;
        
        Test.startTest();
        PageReference performaInvoicePage = Page.PerformaInvoice;
        Test.setCurrentPage(performaInvoicePage);
        ApexPages.currentPage().getParameters().put('id',proformaInstance.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(proformaInstance);
        generateProformaInvoicePDF2 controller = new generateProformaInvoicePDF2(sc);
        controller.savePdf();
        Test.stopTest();
        
    }
    @isTest static void getOpportunityTestMethod2()
    {
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
        
        Account ac= new Account();
        ac.Name='Tania Chatterjee';
        ac.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        ac.Nationality__c='India'; 
        insert ac; 

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        Opportunity opp=new Opportunity();
        opp.Name='John Ram';
        opp.StageName='Qualification';
        opp.Project__c=projectInstance.Id;
        opp.AccountId=ac.Id;
        opp.CloseDate=system.today();
        opp.Unit__c= unitInstance.Id;
        opp.Proforma_Invoice_Type__c='Unit Price';
        opp.Proforma_Invoice_Sub_Type__c='Percentage';
        opp.AED_to_USD_Conversion_Rate__c=0.23344;
        opp.Input_Value__c=5.00;
        insert opp;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true,T_link_Demand_Days__c = 1,Grace_Days_Time_Linked__c = 5,Grace_Days__c =5);
        insert proj;
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Super_Area__c = 1000, PropStrength__House_Unit_No__c = 'test123');
        insert prop;

        PropStrength__Assignment_Group_Name__c assGrp = TestDataFactorySobha.createAssignmentGroup(null);
        insert assGrp;

        Bank_GL__c bg = new Bank_GL__c(Bank_Account_Type__c='Escrow Account', Project__c=proj.Id);
        insert bg;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        enq.PropStrength__Selected_Property_Ids__c = prop.Id;
        insert enq;
        
        Proforma_Invoice__c proformaInstance = new Proforma_Invoice__c();
        proformaInstance.Status__c= 'Raised';
        proformaInstance.Opportunity__c = opp.id;
        proformaInstance.Generate_invoice_in_USD__c = true;
        proformaInstance.Enquiry__c = enq.Id;
        insert proformaInstance;
        
        Test.startTest();
        PageReference performaInvoicePage = Page.PerformaInvoice;
        Test.setCurrentPage(performaInvoicePage);
        ApexPages.currentPage().getParameters().put('id',proformaInstance.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(proformaInstance);
        generateProformaInvoicePDF2 controller = new generateProformaInvoicePDF2(sc);
        controller.savePdf();
        Test.stopTest();
        
    }
}
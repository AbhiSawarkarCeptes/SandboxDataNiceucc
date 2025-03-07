@isTest
public class ProformaInvoiceTrigHelper_test {
    @testSetup
    public static void makeData(){
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
        unitInstance.Chargeable_Area__c =9677.08;
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
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Emirates_ID__c = ' 784-1234-1234567-2';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Projects__c psp = TestDataFactorySobha.createProject(null);
        insert psp;
        PropStrength__Property_Type__c pspt = TestDataFactorySobha.createPropertyType(null);        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        enq.PropStrength__Selected_Property_Ids__c = '00N3N00000OIOWl';
        insert enq;       
        
        Proforma_Invoice__c proformaInstance = new Proforma_Invoice__c();
        proformaInstance.Status__c= 'Raised';
        proformaInstance.Opportunity__c = opp.id;
        proformaInstance.Enquiry__c = enq.Id;
        insert proformaInstance;
    }
    
    @isTest
    public static void testValidationPropCheckOnEnq(){
        List<Proforma_Invoice__c> piList = [select id, Enquiry__c from Proforma_Invoice__c];
        ProformaInvoiceTrigHelper.validationPropCheckOnEnq(piList);
    }
}
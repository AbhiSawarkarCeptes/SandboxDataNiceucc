@isTest
public class InventoryCostServicesMultiUnitClone_Test{
    @isTest
    static void testGetPlanList(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        List<PropStrength__Income_Charges__c> icList = new List<PropStrength__Income_Charges__c>();
        icList.add(new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property', Display_on_Quotation__c = true));
        icList.add(new PropStrength__Income_Charges__c(Name='DLD Fees',PropStrength__Rate_Per_Unit_Area__c = 0.0, PropStrength__Income_Charge_Code__c = 'DLD Fees', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Flexible').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Flexible', PropStrength__Category__c = 'DLD Fees', Display_on_Quotation__c = true,Charge__c = 5));
        insert icList;
        List<PropStrength__Payment_Plan__c> pplList = new List<PropStrength__Payment_Plan__c>();
        pplList.add(new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan1', PropStrength__Active__c = true, Name = 'Test Plan 1'));
        pplList.add(new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan2', PropStrength__Active__c = true, Name = 'Test Plan 2'));
        insert pplList;
        
        List<PropStrength__Milestone__c> pm = new List<PropStrength__Milestone__c>();
        pm.add(new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile 1', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 1'));
        pm.add(new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile 2' , PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 2'));
        pm.add(new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile 3', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 3'));
        insert pm;
        
        List<PropStrength__Payment_Plan_Line_Items__c> ppliList = new List<PropStrength__Payment_Plan_Line_Items__c>();
        ppliList.add(new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = pm[0].Id, PropStrength__Order__c = 1, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = pplList[0].Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test 1', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI 1'));
        ppliList.add(new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = pm[1].Id, PropStrength__Order__c = 2, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = pplList[0].Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test 2', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI 2'));
        ppliList.add(new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = pm[2].Id, PropStrength__Order__c = 3, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = pplList[0].Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test 3', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI 3'));
        insert ppliList;
        
        Test.startTest();
        List<PropStrength__Payment_Plan__c> newPlan = InventoryCostServicesMultiUnitClone.getPlanList(proj.Id);
        List<PropStrength__Income_Charges__c> incomelst = InventoryCostServicesMultiUnitClone.getIncomeChargeList(proj.Id);
        PropStrength__Request__c req = InventoryCostServicesMultiUnitClone.getEnquiry(enq.Id);
        List<PropStrength__Payment_Plan_Line_Items__c> ppl = InventoryCostServicesMultiUnitClone.getPPL(pp.Id);
        Test.stopTest();

    }
}
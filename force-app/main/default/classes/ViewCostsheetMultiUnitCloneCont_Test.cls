@isTest
public class ViewCostsheetMultiUnitCloneCont_Test {
  @testSetup static void setup() {
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', T_link_Demand_Days__c = 0);
        insert  proj;
        
        Bank_GL__c bg = new Bank_GL__c(Bank_Account_Type__c='Escrow Account', Project__c = proj.Id);
        insert bg;
        
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

        PropStrength__Property_Type__c pType = new PropStrength__Property_Type__c(Current_Rate_Per_Unit_Area__c = 1000, PropStrength__Project__c = proj.Id, PropStrength__Area__c = 1000, PropStrength__Property_Type_Code__c = '2BHK');
        insert pType;
        
        PropStrength__Tower__c pTower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'Test Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1');
    insert pTower;
        
        List<PropStrength__Property__c> ptList = new List<PropStrength__Property__c>();
        ptList.add(new PropStrength__Property__c(PropStrength__Tower__c = pTower.Id, PropStrength__Unit_Type__c ='2Bhk', PropStrength__Property_Name__c = 'prop 1', PropStrength__Project_Name__c = proj.Id, PropStrength__Rate_Per_Unit_Area__c = 10000, PropStrength__Allotted__c = true, PropStrength__Active__c = true, 
                                            PropStrength__Property_Type__c = pType.Id, PropStrength__Super_Area__c = 1600));
        ptList.add(new PropStrength__Property__c(PropStrength__Tower__c = pTower.Id, PropStrength__Property_Name__c = 'prop 2', PropStrength__Project_Name__c = proj.Id, PropStrength__Rate_Per_Unit_Area__c = 20000, PropStrength__Allotted__c = true, PropStrength__Active__c = true, 
                                            PropStrength__Property_Type__c = pType.Id,  PropStrength__Super_Area__c = 1000));
        ptList.add(new PropStrength__Property__c(PropStrength__Property_Name__c = 'prop 3',PropStrength__Project_Name__c = proj.Id, PropStrength__Rate_Per_Unit_Area__c = 30000, PropStrength__Allotted__c = true, PropStrength__Active__c = true, 
                                            PropStrength__Property_Type__c = pType.Id, PropStrength__Super_Area__c = 1400));
        insert ptList;
        PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
         insert poc;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = ptList[0].Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = ptList[0].Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        List<PropStrength__Income_Charges__c> icList = new List<PropStrength__Income_Charges__c>();
        icList.add(new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property', Display_on_Quotation__c = true));
        icList.add(new PropStrength__Income_Charges__c(Name='DLD Fees',PropStrength__Rate_Per_Unit_Area__c = 0.0, PropStrength__Income_Charge_Code__c = 'DLD Fees', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Flexible').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Flexible', PropStrength__Category__c = 'DLD Fees', Display_on_Quotation__c = true,Charge__c = 5));
        insert icList;
        
        String ids = '';
        String name = '';
        for(PropStrength__Property__c p : ptList) {
            ids +=  p.Id + ',';
            name += p.PropStrength__Property_Name__c +',';
        }
        Quote__c q = new Quote__c(Basic_Sale_Price_Original__c = 10000, Basic_Sale_Price_Modified__c = 9000, Discount_Amount__c = 1000, Total_Discount__c = 1000,Quote_for_Multi_Properties__c = true,Multi_Properties_Id_s__c = ids,Payment_Plan__c =pplList[0].Id,Discount_Type__c = 'Discount');
        Integer i = 1;
        for(PropStrength__Income_Charges__c ic : icList) {
            q.put('Income_Charge_'+i+'__c', ic.name);
            q.put('Income_Charge_'+i+'_Amount__c', ic.PropStrength__Amount__c);
            i++;    
        }
        insert q;
        
        CS_Unit_plan__c up = new CS_Unit_plan__c(Tower__c = pTower.Id, Unit_Type__c = '2Bhk');
        insert up;
        
        Blob b = Blob.valueOf('Test Data');
      Attachment attachment = new Attachment();
      attachment.ParentId = up.Id;
      attachment.Name = 'Unit Plan';
      attachment.Body = b;
      insert attachment;
        Quote__c q1 = new Quote__c(Property__c =ptList[0].Id, Basic_Sale_Price_Original__c = 10000, Basic_Sale_Price_Modified__c = 9000, Discount_Amount__c = 1000, Total_Discount__c = 1000,Quote_for_Multi_Properties__c = false, Payment_Plan__c =pplList[0].Id,Discount_Type__c = 'Discount');
        i = 1;
        for(PropStrength__Income_Charges__c ic : icList) {
            q1.put('Income_Charge_'+i+'__c', ic.name);
            q1.put('Income_Charge_'+i+'_Amount__c', ic.PropStrength__Amount__c);
            i++;    
        }
        insert q1;
  }
    @isTest
    public static void getQuote() {
        Id qId = [SELECT Id FROM Quote__c WHERE Property__c = null LIMIT 1].Id;
        Test.startTest();
        PageReference pRef = Page.CreateQuoteMultiUnitClone;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('qId',qId);
        ViewCostsheetMultiUnitCloneController vcs = new ViewCostsheetMultiUnitCloneController();
        Test.stopTest();
    }
    @isTest
    public static void getQuoteSingleProperty() {
        Id qId = [SELECT Id FROM Quote__c WHERE Property__c != null LIMIT 1].Id;
        Test.startTest();
        PageReference pRef = Page.CreateQuoteMultiUnitClone;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('qId',qId);
        ViewCostsheetMultiUnitCloneController vcs = new ViewCostsheetMultiUnitCloneController();
        Test.stopTest();
    }
}
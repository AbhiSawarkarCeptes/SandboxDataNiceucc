@isTest
private  Class CraeteQuoteMultiUnit_IsTest {
@isTest
   private static void generateQuoteTest() {
      Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
      Test.startTest();
      PageReference pRef = Page.CreateQuoteMultiUnit;
      Test.setCurrentPage(pRef);
      ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
      ApexPages.currentPage().getParameters().put('stringOfUnitSelected',recordMap.get('UNIT'));
     
      CraeteQuoteMultiUnit qController = new CraeteQuoteMultiUnit();
      qController.startQuote();
      qController.oppId = recordMap.get('OPPORTUNITY');
      ApexPages.currentPage().getParameters().put('editedRate','Basic');
      string unitId = recordMap.get('UNIT');
      qController.unitList = unitId.split(',');
      qController.rateSelectedForEditMap = new Map<String, Boolean>();
     
      //qController.openForEdit();
      /*qController.rateListForEditing.get('Basic').PSF_rate__c = 4600;
      //qController.rateListForEditing.get('Basic').ChargeBucket__c = 'Agreement Value';
      qController.applyNewRates();
      qController.q.Car_Park_Count_1__c =2;
      qController.addCarPark();
      
      qController.q.Car_Park_Count_1__c =1;
      qController.addCarPark();
      qController.q.Discount_PSF__c = 100;
      qController.q.Discount_Lumpsum__c = 100;
      qController.applyDiscounts();      */      
       Test.stopTest();
           
     /* PageReference pRef2 = Page.ViewQuotation;
      Test.setCurrentPage(pRef2);
      ApexPages.currentPage().getParameters().put('qId',qController.q.id);
      ViewQuotation qView = new ViewQuotation();
      qView.sendQuote();
      
      PageReference pRef3 = Page.ViewQuotationPDFPage;
      Test.setCurrentPage(pRef3);
      ApexPages.currentPage().getParameters().put('qId',qController.q.id);
      ViewQuotationPDFcontlr qView2 = new ViewQuotationPDFcontlr();*/
   }
   @isTest
   private static void quoteTest2() {
          Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project1');
          Test.startTest();
          PageReference pRef = Page.CreateQuoteMultiUnit;
          Test.setCurrentPage(pRef);
          ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
          ApexPages.currentPage().getParameters().put('Id',recordMap.get('UNIT'));
          String payplanId = recordMap.get('PLAN');
          String payplanId1 = recordMap.get('PLAN1');
          Id unitId = recordMap.get('UNIT');
          Id projectId = recordMap.get('PROJECT');
          Id towerId = recordMap.get('TOWER');
          CraeteQuoteMultiUnit qController = new CraeteQuoteMultiUnit();
          qController.oppId = recordMap.get('OPPORTUNITY');
          string unitIdText = recordMap.get('UNIT');
          qController.unitList = unitIdText.split(',');
          
          qController.startQuote();
          qController.selectedPlan = payplanId;
          qController.planSelect();
          qController.selectedPlan = payplanId1;
         /* qController.planSelect();
          qController.cancelEditSchedule();
          qController.modifyNPV();*/
          
      //// Commented by Neha on 22/2/19 and added in quoteTest3()   
         /* Map<String,Decimal> rateListMap = new Map<String, Decimal>();
          rateListMap = InventoryCostServicesMultiUnit.getRateList(unitId);
          InventoryCostServicesMultiUnit.getAllCharges(unitId,10000,1000,rateListMap);
          InventoryCostServicesMultiUnit.INFormatR(1000);*/
          
          
          InventoryCostServicesMultiUnit.getLegalEntityDetails(unitId,projectId,towerId);
          Test.stopTest();
   }
//// Added by Neha on 09/01/19   
   @isTest
   private static void quoteTest3() {
      Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project2');                
      Test.startTest();
      PageReference pRef = Page.CreateQuoteMultiUnit;
      Test.setCurrentPage(pRef);
      ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
      ApexPages.currentPage().getParameters().put('stringOfUnitSelected',recordMap.get('UNIT'));
     
      CraeteQuoteMultiUnit qController = new CraeteQuoteMultiUnit();   
      qController.updatePlan();  
      qController.oppId = recordMap.get('OPPORTUNITY');
       Id unitId = recordMap.get('UNIT');
       Map<String,Decimal> rateListMap = new Map<String, Decimal>();
       rateListMap = InventoryCostServicesMultiUnit.getRateList(new List<String>{unitId});
       InventoryCostServicesMultiUnit.getAllCharges(unitId,10000,1000,rateListMap);
       InventoryCostServicesMultiUnit.INFormatR(1000);          
            
      Test.stopTest();
   }
///// Added by Neha on 22/02/19      
   @isTest
   private static void quoteTest4() {
      Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project2');                
     PageReference pRef = Page.CreateQuoteMultiUnit;
      Test.setCurrentPage(pRef);
      ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
      ApexPages.currentPage().getParameters().put('stringOfUnitSelected',recordMap.get('UNIT'));
     
      CraeteQuoteMultiUnit qController = new CraeteQuoteMultiUnit();   
      qController.oppId = recordMap.get('OPPORTUNITY');
      qController.q.opportunity__C = recordMap.get('OPPORTUNITY');
      qController.selectedPlan = recordMap.get('PLAN');
     // qController.changePlan();
      qController.continueMethod();
      Discount__c ds = new Discount__c();
      ds.Type__c = 'PSF';
      ds.Reason__c = 'Armed Forces';
      ds.PSF_Amount__c = 100;
      ds.Project__c = recordMap.get('PROJECT');
      ds.Cluster__c = recordMap.get('CLUSTER'); // Added by Neha on 09/01/19
      ds.applied__c = true;
      ds.Special_Discount__c = true; 
      ds.Start_Date__c = system.today().addDays(-10);
      ds.End_Date__c = system.today().addDays(10);
      Discount__c ds1 = new Discount__c();
      ds1.Type__c = 'User Defined';
      ds1.Reason__c = 'Armed Forces';
      ds1.Lumpsum_AMount__c = 100;
      ds1.PSF_Amount__c = 100;
      ds1.Project__c = recordMap.get('PROJECT');
      ds1.Cluster__c = recordMap.get('CLUSTER'); // Added by Neha on 09/01/19
      ds1.applied__c = true;
      ds1.Special_Discount__c = true; 
      ds1.Start_Date__c = system.today().addDays(-10);
      ds1.End_Date__c = system.today().addDays(10);
      Discount__c ds2 = new Discount__c();
      ds2.Type__c = 'Lumpsum';
      ds2.Reason__c = 'Armed Forces';
      ds2.PSF_Amount__c = 100;
      ds2.Project__c = recordMap.get('PROJECT');
      ds2.Cluster__c = recordMap.get('CLUSTER'); // Added by Neha on 09/01/19
      ds2.applied__c = true;
      ds2.Special_Discount__c = true; 
      ds2.Start_Date__c = system.today().addDays(-10);
      ds2.End_Date__c = system.today().addDays(10);
      
      List<Discount__c> dList = new List<Discount__C>();
      dList.add(ds1);
      dList.add(ds2);
      dList.add(ds);
      insert dList;
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds);
      qController.dList.add(ds1);
      qController.dList.add(ds2);
      qController.planSelect();
      qController.applyDiscounts();
      ds1.Lumpsum_AMount__c = null;
      ds1.PSF_AMount__C = null;
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds);
      qController.dList.add(ds1);
      qController.dList.add(ds2);
      qController.applyDiscounts();
      
      ds1.Lumpsum_AMount__c = null;
      ds1.PSF_AMount__C = 100;
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds);
      qController.dList.add(ds1);
      qController.dList.add(ds2);
      qController.applyDiscounts();
      Discount__c ds3 = new Discount__c();
      ds3.Type__c = 'Percentage';
      ds3.Reason__c = 'Armed Forces';
      ds3.PSF_Amount__c = 100;
      ds3.Project__c = recordMap.get('PROJECT');
      ds3.Cluster__c = recordMap.get('CLUSTER'); // Added by Neha on 09/01/19
      ds3.applied__c = true;
      ds3.Special_Discount__c = true; 
      ds3.Start_Date__c = system.today().addDays(-10);
      ds3.End_Date__c = system.today().addDays(10);
      ds3.applied__c = true;
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds3);
     
      qController.applyDiscounts();
      Discount__c ds4 = new Discount__c();
      ds4.Type__c = 'Percentage of Basic';
      ds4.Reason__c = 'Armed Forces';
      ds4.PSF_Amount__c = 100;
      ds4.Project__c = recordMap.get('PROJECT');
      ds4.Cluster__c = recordMap.get('CLUSTER'); // Added by Neha on 09/01/19
      ds4.applied__c = true;
      ds4.Special_Discount__c = true; 
      ds4.Start_Date__c = system.today().addDays(-10);
      ds4.End_Date__c = system.today().addDays(10);
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds4);
      Test.startTest();
      
      qController.applyDiscounts();
      ds4.Percentage_Of_AV__c = 7;
      ds4.applied__c = true;
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds4);
     
      qController.applyDiscounts();
      ds4.Percentage_Of_AV__c = 5;
      ds4.applied__c = true;
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds4);
     
      qController.applyDiscounts();
      ds.applied__c = true;
      ds.psf_amount__c = null;
      ds.Lumpsum_AMount__c = null;
      ds.Type__c = 'User Defined';
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds);
     
      qController.applyDiscounts();
      ds.applied__c = true;
      ds.psf_amount__c = 100;
      ds.Type__c = 'User Defined';
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds);
     
      qController.applyDiscounts();
      ds3.applied__c = true;
      ds3.Percentage_Of_AV__c = 100;
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds3);
     
      qController.applyDiscounts();
      ds3.applied__c = true;
      ds3.Percentage_Of_AV__c = 4;
      qController.dList = new List<Discount__C>();
      qController.dList.add(ds);
     
      qController.applyDiscounts();
      qController.editSchedule();
      qController.payPlanDetails[0].ppm.Charge1Type__c = 'Percentage';
      qController.payPlanDetails[0].pm.Charge1Percentage__c = 2;   
      qController.updatePlan(); 
      qController.payPlanDetails[0].ppm.Charge1Type__c = 'Percentage';
      qController.payPlanDetails[0].pm.Charge1Percentage__c = 1;
      qController.payPlanDetails[1].ppm.Charge1Type__c = 'Percentage';
      qController.payPlanDetails[1].pm.Charge1Percentage__c = 3;
      qController.actionType = 'add';
      qController.rowNumber = 1;
      qController.rowModify();
      qController.payPlanDetails[2].ppm.Charge1Type__c = 'Percentage';
      qController.payPlanDetails[2].pm.Charge1Percentage__c = 1;
      qController.payPlanDetails[2].pm.Number_Of_Days__c = 25;
      qController.payPlanDetails[2].pm.Milestone_Type_edit__c = 'Date Linked';
      qController.q.opportunity__c = recordMap.get('OPPORTUNITY');
      
      //qController.updatePlan(); 
      qController.saveQuote();
      //qController.cancelEditSchedule();
      qController.confirmEditSchedule();
      //qController.modifyNPV();
      qController.resetQuote(); 
      Test.stopTest();
   }
   
    
    @isTest
    public static void InventoryCostServicesMultiUnitTest(){
        Map<String, Id> recordMap1 = TestDataFactory.createMasterProject('Test Project');
        Id projectid = recordMap1.get('PROJECT');
        Test.startTest();
        //InventoryCostServicesMultiUnit inventory = new InventoryCostServicesMultiUnit();
        InventoryCostServicesMultiUnit.getConstructionStagesByName(projectid);
        InventoryCostServicesMultiUnit.getApprovers(projectid);
        InventoryCostServicesMultiUnit.getProjectLevelDiscounts(projectid);
        InventoryCostServicesMultiUnit.getinstallmentDetails(7,44,'Sixth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(8,44,'Seventh Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(9,44,'Eight Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(10,44,'Ninth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(11,44,'Tenth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(12,44,'Eleventh Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(13,44,'Twelth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(14,44,'Thirteenth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(15,44,'Fourteenth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(16,44,'Fifteenth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(17,44,'Sixteenth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(18,44,'Seventeenth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(19,44,'Eighteenth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(20,44,'Ninteenth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(21,44,'Twenteth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(22,44,'Twenty-One Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(23,44,'Twenty-Two Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(24,44,'Twenty-Three Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(25,44,'Twenty-Four Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(26,44,'Twenty-Five Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(27,44,'Twenty-Sixth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(28,44,'Twenty-Seventh Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(29,44,'Twenty-Eighth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(30,44,'Twenty-Ninth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(31,44,'Thirteth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(32,44,'Thirty-One Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(33,44,'Thirty-Two Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(34,44,'Thirty-Three Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(35,44,'Thirty-Four Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(36,44,'Thirty-Five Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(37,44,'Thirty-Six Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(38,44,'Thirty-Seven Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(39,44,'Thirty-Eight Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(40,44,'Thirty-Nine Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(41,44,'Fourteth Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(42,44,'Fourty-One Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(43,44,'Fourty-Two Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(44,44,'Fourty-Three Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(45,44,'Fourty-Four Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(46,44,'Fourty-Five Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(47,44,'Fourty-Six Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(48,44,'Fourty-Seven Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(49,44,'Fourty-Eight Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(50,44,'Fourty-Nine Installment');
        InventoryCostServicesMultiUnit.getinstallmentDetails(51,44,'On Booking date');
        //InventoryCostServicesMultiUnit.getinstallmentDetails(52,44,'Fifty-One Installment');
        Test.stopTest();
    }
    
    @isTest
    public static void testPlanDetailWrapper (){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project1');
        String payplanId = recordMap.get('PLAN');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id towerId = recordMap.get('TOWER');
        Unit__c u = [Select Id,Project__r.Name,Tower__r.Id from Unit__c where Id =: unitId];
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordMap.get('OPPORTUNITY');
        q.Unit__c = recordMap.get('UNIT');
        q.Payment_Plan__c = recordMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;      
        
        Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        
        Project_Construction_Stages__c pgs = new Project_Construction_Stages__c();
        pgs.Planned_date_of_completion__c = System.today().addDays(30);
        pgs.project__c = projectId;
        pgs.Tower__c = towerId;
        pgs.Name = 'On Completion';
        insert pgs;        
                               
        Payment_Plan_Milestones__c ppm = new Payment_Plan_Milestones__c();
        ppm = createPaymentPlanMilestone(payplanId, pgs.id); 
        
        list<InventoryCostServicesMultiUnit.PlanDetailWrapper> wrapList = new list<InventoryCostServicesMultiUnit.PlanDetailWrapper>();
        InventoryCostServicesMultiUnit.PlanDetailWrapper wrap1 = new InventoryCostServicesMultiUnit.PlanDetailWrapper(ppm,pm,'',100,'',100,'','','',true,null,null,false);
        wrap1.editedRowStyle = 'Edited';
        wrapList.add(wrap1);
        InventoryCostServicesMultiUnit.PlanDetailWrapper wrap2 = new InventoryCostServicesMultiUnit.PlanDetailWrapper(ppm,pm,'',100,'',100,'','','',true,null,null,false);
        wrap2.editedRowStyle = 'Edited';
        wrapList.add(wrap2);
        InventoryCostServicesMultiUnit.updatePlanDetails(u, payplanId, new Map<String,Decimal>{'Agreement Value AMOUNTTOTAL' => 10}, wrapList);
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
    
    private static Payment_Plan_Milestones__c createPaymentPlanMilestone (Id pp, Id pgs) {               
         Payment_Plan_Milestones__c pm = new Payment_Plan_Milestones__c();
         pm.Plan_Milestone_Type__c = 'Construction Linked';
         pm.Number_Of_Days_Plan__c = 0;       
         pm.Milestone_Name_Picklist__c = '<<Construction Stage Name>>';
         pm.Project_Construction_Stages__c = pgs;
         pm.Payment_Plan__c = pp;
         pm.Charge1Name__c = 'Percentage';
         insert pm;
         return pm;
     }
  }
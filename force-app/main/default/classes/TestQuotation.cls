@isTest
private  Class TestQuotation {
@isTest
   private static void generateQuoteTest() {
      Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
      Test.startTest();
      PageReference pRef = Page.CreateQuote;
      Test.setCurrentPage(pRef);
      ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
      ApexPages.currentPage().getParameters().put('Id',recordMap.get('UNIT'));
     
      CreateQuote qController = new CreateQuote();
      qController.startQuote();
      ApexPages.currentPage().getParameters().put('editedRate','Basic');
      qController.openForEdit();
      qController.rateListForEditing.get('Basic').PSF_rate__c = 4600;
      //qController.rateListForEditing.get('Basic').ChargeBucket__c = 'Agreement Value';
      
      qController.applyNewRates();
      qController.q.Car_Park_Count_1__c =2;
      qController.addCarPark();
      
      qController.q.Car_Park_Count_1__c =1;
      qController.addCarPark();
      qController.q.Discount_PSF__c = 100;
      qController.q.Discount_Lumpsum__c = 100;
      qController.applyDiscounts();            
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
          PageReference pRef = Page.CreateQuote;
          Test.setCurrentPage(pRef);
          ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
          ApexPages.currentPage().getParameters().put('Id',recordMap.get('UNIT'));
          String payplanId = recordMap.get('PLAN');
          String payplanId1 = recordMap.get('PLAN1');
          Id unitId = recordMap.get('UNIT');
          Id projectId = recordMap.get('PROJECT');
          Id towerId = recordMap.get('TOWER');
          CreateQuote qController = new CreateQuote();
          qController.startQuote();
          qController.selectedPlan = payplanId;
          qController.planSelect();
          qController.selectedPlan = payplanId1;
          qController.planSelect();
          qController.cancelEditSchedule();
          qController.modifyNPV();
          
      //// Commented by Neha on 22/2/19 and added in quoteTest3()   
         /* Map<String,Decimal> rateListMap = new Map<String, Decimal>();
          rateListMap = InventoryCostServices.getRateList(unitId);
          InventoryCostServices.getAllCharges(unitId,10000,1000,rateListMap);
          InventoryCostServices.INFormatR(1000);*/
          
          
          InventoryCostServices.getLegalEntityDetails(unitId,projectId,towerId);
          Test.stopTest();
   }
//// Added by Neha on 09/01/19   
   @isTest
   private static void quoteTest3() {
      Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project2');                
      Test.startTest();
      PageReference pRef = Page.CreateQuote;
      Test.setCurrentPage(pRef);
      ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
      ApexPages.currentPage().getParameters().put('Id',recordMap.get('UNIT'));
     
      CreateQuote qController = new CreateQuote();   
      qController.updatePlan();  
      
       Id unitId = recordMap.get('UNIT');
       Map<String,Decimal> rateListMap = new Map<String, Decimal>();
       rateListMap = InventoryCostServices.getRateList(unitId);
       InventoryCostServices.getAllCharges(unitId,10000,1000,rateListMap);
       InventoryCostServices.INFormatR(1000);          
            
      Test.stopTest();
   }
///// Added by Neha on 22/02/19      
   @isTest
   private static void quoteTest4() {
      Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project2');                
      Test.startTest();
      PageReference pRef = Page.CreateQuote;
      Test.setCurrentPage(pRef);
      ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
      ApexPages.currentPage().getParameters().put('Id',recordMap.get('UNIT'));
     
      CreateQuote qController = new CreateQuote();   
      
      qController.selectedPlan = recordMap.get('PLAN');
     // qController.changePlan();
      qController.continueMethod();
      
      qController.planSelect();
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
      //qController.updatePlan(); 
      qController.saveQuote();
      //qController.cancelEditSchedule();
      qController.confirmEditSchedule();
      //qController.modifyNPV();
      qController.resetQuote(); 
      Test.stopTest();
   }
    
    @isTest
    public static void InventoryCostServicesTest(){
        Map<String, Id> recordMap1 = TestDataFactory.createMasterProject('Test Project');
        Id projectid = recordMap1.get('PROJECT');
        Test.startTest();
        //InventoryCostServices inventory = new InventoryCostServices();
        InventoryCostServices.getConstructionStagesByName(projectid);
        InventoryCostServices.getApprovers(projectid);
        InventoryCostServices.getProjectLevelDiscounts(projectid);
        InventoryCostServices.getinstallmentDetails(7,44,'Sixth Installment');
        InventoryCostServices.getinstallmentDetails(8,44,'Seventh Installment');
        InventoryCostServices.getinstallmentDetails(9,44,'Eight Installment');
        InventoryCostServices.getinstallmentDetails(10,44,'Ninth Installment');
        InventoryCostServices.getinstallmentDetails(11,44,'Tenth Installment');
        InventoryCostServices.getinstallmentDetails(12,44,'Eleventh Installment');
        InventoryCostServices.getinstallmentDetails(13,44,'Twelth Installment');
        InventoryCostServices.getinstallmentDetails(14,44,'Thirteenth Installment');
        InventoryCostServices.getinstallmentDetails(15,44,'Fourteenth Installment');
        InventoryCostServices.getinstallmentDetails(16,44,'Fifteenth Installment');
        InventoryCostServices.getinstallmentDetails(17,44,'Sixteenth Installment');
        InventoryCostServices.getinstallmentDetails(18,44,'Seventeenth Installment');
        InventoryCostServices.getinstallmentDetails(19,44,'Eighteenth Installment');
        InventoryCostServices.getinstallmentDetails(20,44,'Ninteenth Installment');
        InventoryCostServices.getinstallmentDetails(21,44,'Twenteth Installment');
        InventoryCostServices.getinstallmentDetails(22,44,'Twenty-One Installment');
        InventoryCostServices.getinstallmentDetails(23,44,'Twenty-Two Installment');
        InventoryCostServices.getinstallmentDetails(24,44,'Twenty-Three Installment');
        InventoryCostServices.getinstallmentDetails(25,44,'Twenty-Four Installment');
        InventoryCostServices.getinstallmentDetails(26,44,'Twenty-Five Installment');
        InventoryCostServices.getinstallmentDetails(27,44,'Twenty-Sixth Installment');
        InventoryCostServices.getinstallmentDetails(28,44,'Twenty-Seventh Installment');
        InventoryCostServices.getinstallmentDetails(29,44,'Twenty-Eighth Installment');
        InventoryCostServices.getinstallmentDetails(30,44,'Twenty-Ninth Installment');
        InventoryCostServices.getinstallmentDetails(31,44,'Thirteth Installment');
        InventoryCostServices.getinstallmentDetails(32,44,'Thirty-One Installment');
        InventoryCostServices.getinstallmentDetails(33,44,'Thirty-Two Installment');
        InventoryCostServices.getinstallmentDetails(34,44,'Thirty-Three Installment');
        InventoryCostServices.getinstallmentDetails(35,44,'Thirty-Four Installment');
        InventoryCostServices.getinstallmentDetails(36,44,'Thirty-Five Installment');
        InventoryCostServices.getinstallmentDetails(37,44,'Thirty-Six Installment');
        InventoryCostServices.getinstallmentDetails(38,44,'Thirty-Seven Installment');
        InventoryCostServices.getinstallmentDetails(39,44,'Thirty-Eight Installment');
        InventoryCostServices.getinstallmentDetails(40,44,'Thirty-Nine Installment');
        InventoryCostServices.getinstallmentDetails(41,44,'Fourteth Installment');
        InventoryCostServices.getinstallmentDetails(42,44,'Fourty-One Installment');
        InventoryCostServices.getinstallmentDetails(43,44,'Fourty-Two Installment');
        InventoryCostServices.getinstallmentDetails(44,44,'Fourty-Three Installment');
        InventoryCostServices.getinstallmentDetails(45,44,'Fourty-Four Installment');
        InventoryCostServices.getinstallmentDetails(46,44,'Fourty-Five Installment');
        InventoryCostServices.getinstallmentDetails(47,44,'Fourty-Six Installment');
        InventoryCostServices.getinstallmentDetails(48,44,'Fourty-Seven Installment');
        InventoryCostServices.getinstallmentDetails(49,44,'Fourty-Eight Installment');
        InventoryCostServices.getinstallmentDetails(50,44,'Fourty-Nine Installment');
        InventoryCostServices.getinstallmentDetails(51,44,'On Booking date');
        //InventoryCostServices.getinstallmentDetails(52,44,'Fifty-One Installment');
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
        
        list<InventoryCostServices.PlanDetailWrapper> wrapList = new list<InventoryCostServices.PlanDetailWrapper>();
        InventoryCostServices.PlanDetailWrapper wrap1 = new InventoryCostServices.PlanDetailWrapper(ppm,pm,'',100,'',100,'','','',true,null,null,false);
        wrap1.editedRowStyle = 'Edited';
        wrapList.add(wrap1);
        InventoryCostServices.PlanDetailWrapper wrap2 = new InventoryCostServices.PlanDetailWrapper(ppm,pm,'',100,'',100,'','','',true,null,null,false);
        wrap2.editedRowStyle = 'Edited';
        wrapList.add(wrap2);
        InventoryCostServices.updatePlanDetails(u, payplanId, new Map<String,Decimal>{'Agreement Value AMOUNTTOTAL' => 10}, wrapList);
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
@isTest
private class TestCollectionsDashboardNewController{
    
    @isTest
    private static void testCollection(){
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Hartland'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        Id projId = recordMap.get('PROJECT');
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Quotation__c quote = createQuotation(recordMap.get('OPPORTUNITY'), recordMap.get('PLAN'), recordMap.get('UNIT'));
        
        Payment_Milestones__c pm = createPaymentMilestone(quote.Id);
        
        List<User> userList = [SELECT Id FROM User WHERE Profile.Name ='Collection'];
        
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
        b.Collection_User__c = userList[0].Id;
        insert b;    
        
        quote.Booking__c = b.Id;
        update quote;
        
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :optyId];
        opp.StageName = 'Booking confirmed';
        opp.S_Active__c = true;
        opp.Unit__c = unitId;
        update opp;
        
        Unit__c u = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Booking__c = b.Id;
        u.Customers__c = opp.Id;
        update u;
        
        List<Demand__c> demandToInsert = new List<Demand__c>();
        for(integer i=0; i<=50; i++){            
            Demand__c d = new Demand__C();
            d.Project__c = projId;
            d.Unit__c = unitId;
            d.Quotation__c = quote.Id;
            d.Booking__c = b.Id;
            d.Payment_Milestones__c = pm.Id;
            d.Invoice_Date__c = System.Today();
            d.Due_Date__c = System.Today().addDays(30);
            d.Remarks__c = '';
            d.Agreement_Value_Demanded_New__c = 1000000;
            d.Charge_1_Name__c = 'Basic';
            d.Charge_1_Demanded__c = 1000000;
            d.Charge_1_Lookup__c = recordMap.get('BASIC');       
            demandToInsert.add(d);
        }
        insert demandToInsert;
        
        Test.startTest();
        PageReference pRef = Page.S_CollectionsDashboardNew;
        Test.setCurrentPage(pRef);
        S_CollectionsDashboardNewController cd = new S_CollectionsDashboardNewController();
        /* First Tab */
        List <SelectOption> proList = cd.lstProjects;
        cd.selectedProjectId = projId;     
        List<SelectOption> towerList = cd.lstTowers;     
        cd.selectedTowerId = tower.Id;
        List<SelectOption> rmList = cd.getRMs;
        cd.selectedRM = 'All';
        cd.getDemandReciepts();
        
        cd.searchByName = 'Test';
        cd.getDemandReciepts();
        cd.Next();
        cd.getDisableNext();
        cd.Previous();
        cd.getDisablePrevious();
        cd.End();        
        cd.Beginning();       
        cd.clearSearch();
        
        /* Second Tab */
        cd.selectedProjectIdF = projId;
        List<SelectOption> towerListF = cd.lstTowersF;
        cd.selectedTowerIdF = tower.Id;
        List<SelectOption> rmListF = cd.getRMsF;
        cd.selectedRMF = 'All';
        
        cd.selectedRadioOption = 'Today';
        cd.getRadioPanel(); 
        cd.followupsearchByName = 'Test';
        cd.clearSearchFollowUp();
        
        cd.selectedRadioOption = 'Pending';
        cd.getRadioPanel(); 
        cd.NextF();
        cd.getDisableNextF();
        cd.PreviousF();
        cd.getDisablePreviousF();
        cd.EndF();
        cd.BeginningF();        
        cd.followupsearchByName = 'Test';
        cd.clearSearchFollowUp();
        
        cd.selectedRadioOption = 'PendingDLD';
        cd.getRadioPanel(); 
        cd.followupsearchByName = 'Test';
        cd.clearSearchFollowUp();
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
        pm.C1_Amount__c = 100000;          
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
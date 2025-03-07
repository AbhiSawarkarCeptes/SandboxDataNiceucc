@isTest
private  Class S_InventoryMatrixMultiUnitTest {
    @isTest
    private static void InventoryViewTest() {
        
        Project__c p = createProject('Xa_prj','111');
        
        //create Clusters
        List<Cluster__c> cList = TestDataFactory.createClusters(2, p.Id);
        
        //create Towers
        List<Tower__c> tList = TestDataFactory.createTowers(2, p.Id);
        
        //create Units
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, p.Id);
        
        Test.startTest();
        PageReference pRef = Page.S_InventoryMatrixview;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('projectsent','test');
        ApexPages.currentPage().getParameters().put('towersent','test');
        
        S_InventoryMatrix_MultiUnit invController = new S_InventoryMatrix_MultiUnit();
        invController.selectedVal = p.Id;
        invController.SelectedClusterId = cList[0].Id;
        invController.selectedTower = tList[0].Id;
        invController.selectedstatus = '';
        invController.selectedConf = uList[0].Id ;
        invController.sold = true;
        invController.open = true;
        invController.booked = true;
        invController.reserved = true;
        invController.blocked = true;      
        invController.onebhk = true;
        invController.twobhk = true;
        invController.threebhk = true;
        invController.fourbhk = true;
        invController.fivebhk = true;
        
        List<SelectOption> pl = invController.getProjects;
        List<SelectOption> tl = invController.getTowers; 
        List<SelectOption> clusterNames = invController.getClusterNames; 
        List<SelectOption> projectUnitTypes = invController.getProjectunittype; 
        List<Decimal> floorSeq = invController.floorDescSeqList;
        Map<Decimal,List<S_InventoryMatrix_MultiUnit.unitWrapper>> UnitMap = invController.JMap;    
        ApexPages.currentPage().getParameters().put('floorId','1');
        invController.checkAllUnitsForFloor();
        invController.FloorSelected =1;
        invController.selectUnitForQuote();  
        invController.confirmQuoteGenerate();
        invController.backToInventoryMatrix();
        invController.showSelectedUnits();
        Test.stopTest();
    }
    
    public static Project__c createProject(String ProjName, String ProjectCode){
        Project__c objProject = new Project__c(Name = ProjName, Project_Code__c = projectCode);
        insert objProject;
        return objProject;
    }
    
    public static Cluster__c createCluster(Id pr){
        Cluster__c cl = new Cluster__c ();
        cl.Project__c = pr;
        cl.MAHA_RERA_No__c = '12334';
        insert cl;
        return cl;
    }    
    
   
    
    
  
    
    
  
   
}
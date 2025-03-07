@isTest
private  Class TestViewCostSheet {
    
    @isTest
    private static void generateCostSheetTest()
    {
        Test.startTest();
        PageReference pRef = Page.ViewCostsheetDubai;
        Test.setCurrentPage(pRef);
        
        
       Variant_Description__mdt vd= new Variant_Description__mdt();
        vd.Label='test1';
        vd.Variant__c='test 123';
        vd.Description__c='Description 1';
        vd.DeveloperName='test1';
        //insert vd;
        
        Account acc = new Account();
        acc.LastName = 'Test Acc';
        acc.PersonMobilePhone = '1245785212';
        insert acc;
        Id accId = acc.Id;
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp = createPaymentPlan();
        
        Project__c pr = new Project__c();
        pr = createProject();
        
        Opportunity opp = new Opportunity();
        opp = createOpp ( accId, pr.id);
        
        Tower__c tw = new Tower__c ();
        tw = createTower(pr.id);
        
        Unit__c ut = new Unit__c();
        ut = createUnit(pr.id,tw.id);
        
        ProjectCharges__c pc = new ProjectCharges__c ();
        pc.Name = 'Basic';
        pc.Charge_Name__c = 'Basic';
        pc.project__c = pr.Id;
        pc.Tower__c = tw.Id;
        pc.Active__c = true;
        pc.ChargeBucket__c = 'Agreement Value';
        insert pc;
        
        ProjectCharges__c pc1 = new ProjectCharges__c ();
        pc1.Name = 'Floor Rise';
        pc1.Charge_Name__c = 'Floor Rise';
        pc1.project__c = pr.Id;
        pc1.Tower__c = tw.Id;
        pc1.Active__c = true;
        pc1.ChargeBucket__c = 'Agreement Value';
        insert pc1;
        
        ProjectCharges__c pc2 = new ProjectCharges__c ();
        pc2.Charge_Name__c = 'Knowledge Fees';
        pc2.project__c = pr.Id;
        pc2.Tower__c = tw.Id;
        pc2.Active__c = true;
        pc2.Name ='Knowledge Fees';
        pc2.ChargeBucket__c = 'Agreement Value';
        insert pc2;
        
        
        
        ProjectCharges__c pc3 = new ProjectCharges__c ();
        pc3.Name = 'DLD Admin Fees';
        pc3.Charge_Name__c = 'Stamp Duty';
        pc3.project__c = pr.Id;
        pc3.Tower__c = tw.Id;
        pc3.Active__c = true;
        pc3.ChargeBucket__c = 'Stamp Duty and Registration';
        insert pc3;
        
        
        
        Rate_List__c rl = new Rate_List__c();
        rl.Unit__c = ut.Id;
        rl.Type__c = 'Lumpsum';
        rl.Lumpsum_Amount__c = 100000;
        rl.ProjectCharges__c = pc3.Id;
        insert rl; 
        
        
        Unit_Layout__c ul = new Unit_Layout__c();
        ul.Typology__c = '2 BHK';
        ul.Tower__c = tw.Id; 
        insert ul;  
        
        //from Here
        
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = ul.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        
        insert(attachment);
        
        string totalKnowledgefeesString = 'test';
        
        string floorNo='test1';
        Decimal stampDutyPerce= 1.1;
        
        /*  ProjectCharges__c pc4 = new ProjectCharges__c ();
pc4.Charge_Name__c = 'DLD';
pc4.project__c = pr.Id;
pc4.Tower__c = tw.Id;
pc4.Active__c = true;
pc4.ChargeBucket__c = 'Agreement Value';
insert pc4;*/
        
        string addresses = 'test,teste';
        //insert addresses;
        
        
        //To Here   
        Unit_plan__c up = new Unit_Plan__c();
        up.Unit_Type__c ='test 123';
        up.Tower__c = tw.id;
        insert up;
        
        Floor_Plan__c fp = new Floor_Plan__c();
        fp.Plan_Floor_From__c =1;
        fp.Plan_Floor_To__c =10;
        fp.Tower__c = tw.id;
        insert fp;
        
        Quotation__c quote = new Quotation__c();
        quote = createQuotation(opp.id, pp.id, ut.id);
        quote.tower__c =  tw.Id;
        quote.project__c =  pr.Id;
        update quote;
        Unit_For_Quote__C ufq = new Unit_For_Quote__C();
        ufq.quotation__c = quote.id;
        ufq.unit__c = ut.id;
        insert ufq;
        ContentVersion content=new ContentVersion(); 
        content.Title='Unit Layout'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentVersion content1=new ContentVersion(); 
        content1.Title='Floor Layout'; 
        content1.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob1=Blob.valueOf('Unit Test ContentVersion Body'); 
        content1.VersionData=bodyBlob; 
        //content1.LinkedEntityId=fp.id;
        content1.origin = 'H';
        insert content1;
        
        ContentDocumentLink contentlinkFloorPlan=new ContentDocumentLink();
        //contentlinkFloorPlan.LinkedEntityId=fp.id;
        contentlinkFloorPlan.contentdocumentid=[select contentdocumentid from contentversion where id =: content1.id].contentdocumentid;
        contentlinkFloorPlan.ShareType = 'I';
        contentlinkFloorPlan.Visibility = 'AllUsers'; 
        //insert contentlinkFloorPlan;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        //contentlink.LinkedEntityId=up.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        //insert contentlink;
        
        Payment_Milestones__c pm1 = new Payment_Milestones__c();
        pm1 = createPaymentMilestone1(quote.id);
        
        ApexPages.currentPage().getParameters().put('qId',quote.id);
        ViewCostsheetDubaiController vcs = new ViewCostsheetDubaiController();
        vcs.sendQuote();
        ViewCostsheetDubaiMultiUnit vcs1 = new ViewCostsheetDubaiMultiUnit();
        vcs1.sendQuote();
        Test.stopTest();
    }
    
    private static Quotation__c createQuotation (Id opp, Id pp, Id ut1)
    {
        
        Quotation__c objQuote1 = new Quotation__c();
        
        objQuote1.Opportunity__c = opp ;
        objQuote1.Payment_Plan__c =pp ;
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
        
        
        objQuote1.Unit__c = ut1;
        
        
        insert objQuote1;
        return objQuote1;
    }
    
    private static Opportunity createOpp (Id accId, Id projId) {
        //Account a = createPAAccount();
        //project__c p = createProject();
        
        Opportunity objOpp = new Opportunity();
        objopp.Name = 'TestOpp';
        objopp.Accountid = accId;
        objopp.CloseDate = System.today().addDays(30);
        objopp.StageName = 'Qualification';//'Unit Booked';
        objopp.Project__c = projId;
        
        insert objOpp;
        Opportunity objOppToreturn = [Select id,Project__c,AccountId ,StageName 
                                      from Opportunity where id =:objOpp.id];
        return objOppToreturn ;
    }
    private static Payment_Plan__c createPaymentPlan () {
        //Account a = createPAAccount();
        //project__c p = createProject();
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.NoofMilestones__c = 10;
        insert pp;
        return pp;
    }
    
    private static Unit__c createUnit( Id prId, Id twId)
    {
        Unit__c objUnit = new Unit__c ();
        objUnit.name = 'testUnit1';
        objUnit.Floor__c = 3;
        objUnit.Project_Property_Type__c = 'Residential';
        objUnit.Carpet_Area__c = 1233;
        objUnit.Chargeable_Area__c = 1234; 
        objUnit.Balcony_Area_Sq_Ft__c = 123;
        objUnit.Project__c = prId;
        objUnit.Tower__c = twID;
        objUnit.Typology__c ='2 BHK';
        objUnit.Utility_Area__c = 123;
        objUnit.Courtyard_Area_Sq_Ft__c = 1212;
        objUnit.RERA_Terrace_Area_Sq_Ft__c = 1223;
        objUnit.Super_Builtup_Area_Sq_Ft__c = 1233;
        objUnit.RERA_Other_Usable_Area_Sq_Ft__c = 345;
        objUnit.Garden_Area_Sq_Ft__c = 7654;
        objUnit.Chargeable_Garden_Area_Sq_Ft__c = 8765;
        objUnit.Chargeable_Courtyard_Area_Sq_Ft__c = 8765;
        objUnit.Chargeable_Terrace_Area_Sq_Ft__c = 7654;
        objUnit.Unit_Type__c = 'test 123';
        objUnit.Unit_Type_Variant__c = 'test 123';
        insert objUnit;
        return objUnit;
    }
    
    
    private static Tower__c createTower( Id projID)
    {
        Tower__c tw = new Tower__c();
        
        tw.Name = 'Maple B';
        tw.project__c = projID;
        insert tw;
        return tw;
    }
    
    private static Project__c createProject()
    {
        Project__c proj = new Project__c();
        
        proj.Configuration__c='1.5 BHK';
        proj.Max_Budget__c=10000;
        proj.Min_Budget__c=10000;
        proj.Expiry_Days__c = 10;
        proj.name = 'ParkWest';
        proj.Project_Code__c = 'test';
        insert proj;
        return proj;
    }
    
    private static Payment_Milestones__c createPaymentMilestone1 (Id quote)
    {
        List<Payment_Milestones__c> lstPM = new List<Payment_Milestones__c>();
        for(Integer i=0; i < 24; i++) {
            Payment_Milestones__c pm = new Payment_Milestones__c();
            //pm.Charge1Percentage__c = 1;
            pm.Number_Of_Days__c = 25;
            pm.Milestone_Complete_At_Booking__c =true;
            pm.Milestone_Type_edit__c = 'Date Linked';
            pm.Quotation__c = quote;
            pm.Charge1Name__c = 'Basic';
            pm.Charge1Percentage__c = 5;
            pm.C1_Amount__c = 10000;          
            pm.C1_CGST__c = 41250;
            pm.C1_SGST__c = 2475;
            pm.Charge2Name__c='Knowledge Fees';
            pm.C2_Amount__c = 10000;
            pm.Charge2Percentage__c = 100;         
            pm.C2_CGST__c = 0;
            pm.C2_SGST__c = 0;
            pm.Charge3Name__c='DLD Admin Fees';
            pm.C3_Amount__c = 1000; 
            pm.Charge3Percentage__c = 100;
            pm.C3_CGST__c = 0;
            pm.C3_SGST__c = 0;
            pm.Charge4Name__c='PLC';
            pm.C4_Amount__c = 20000;          
            pm.C4_CGST__c = 0;
            pm.Charge1Percentage__c = 1000;
            pm.C4_SGST__c = 0;
            lstPM.add(pm);
        }
        
        
        
        
        insert lstPM;
        return lstPM[0];
        
    }
    
    public testmethod static void pMWrapperTest(){
        ViewCostsheetDubaiController.PMWrapper objWrapper= new ViewCostsheetDubaiController.PMWrapper(2, date.today(), 'Total', '',125,false, 'On Booking Date',3);
    }
}
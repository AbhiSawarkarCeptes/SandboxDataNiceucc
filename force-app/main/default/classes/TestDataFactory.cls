@isTest
public with sharing class TestDataFactory {
    
    // creating the complete structure of a project 
    // with project charges, legal entities, towers
    // construction stages, payment plan
    public static Map<String,Id> createMasterProject(String pName) {
            Map<String,Id> recordIdMap = new Map<String,Id>();
            
            // Legal Entity Creation
            Legal_Entity__c objlglentity = new Legal_Entity__c();
            objlglentity.Name ='RS';
            objlglentity.RDS_Company_Code__c='rs';
            objlglentity.RDS_Service_Tax_No__c= '123456789012345';
            objlglentity.RDS_Company_Name__c='111';
            objlglentity.RDS_Address1__c='123';
            objlglentity.RDS_Address2__c='234';
            objlglentity.RDS_City__c='delhi';
            objlglentity.RDS_Pin_Code__c='201301';
            objlglentity.RDS_Phone__c='9953528045';
            objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
            recordIdMap.put('LEGAL ENTITY',objlglentity.Id);            
         
            // Project Creation
            Project__c objpr = new Project__c();
            objpr.Project_Code__c = 'T35';
            objpr.Name = pName;
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Company_Code__c = objlglentity.Id;
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Stage__c='Launch';
            objpr.Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
            objpr.Project_Property_Type__c = 'Residential';
            objpr.Sales_Manager_Discount__c = 400;
            objpr.Site_Head_Discount__c  = 50;
            objpr.Sales_Head_Discount__c = 1000;
            objpr.Service_Tax_Required_On_Token_Amount__c = true;
            objpr.Car_Park_Type_1__c = 'Stack';
            objpr.Charge_Value_1__c = 200000;
            objpr.Car_Park_Type_2__c = 'Open';
            objpr.Charge_Value_2__c = 300000;
            objpr.NPV__c = 12;
            objpr=RDSCommon.CreateProject(objpr);
            recordIdMap.put('PROJECT',objpr.Id);
            
            // Cluster Creation added by Neha on 09/01/19
            Cluster__c clus = new Cluster__c();
            clus.Name = 'Cluster 1';
            clus.Project__c  = objpr.Id;
            insert clus; 
            recordIdMap.put('CLUSTER',clus.Id);                       
            
            Discount__c ds = new Discount__c();
            ds.Type__c = 'PSF';
            ds.Reason__c = 'Armed Forces';
            ds.PSF_Amount__c = 100;
            ds.Project__c = objpr.Id;
            ds.Cluster__c = clus.Id; // Added by Neha on 09/01/19
            ds.applied__c = true;
            ds.Special_Discount__c = true; 
            ds.Start_Date__c = system.today().addDays(-10);
            insert ds;
            
            // tower creation 
             Tower__c t = new Tower__c();
             t.Name = 'Sobha Hartland II Villas';
             t.Project__c = objpr.Id;
             t.Cluster__c = clus.Id; // Added by Neha on 09/01/19
             t = RDSCommon.CreateTower(t);
             recordIdMap.put('TOWER',t.Id);
        Tower__c t1 = new Tower__c();
             t1.Name = 'Phase IV';
             t1.Project__c = objpr.Id;
             t1.Cluster__c = clus.Id; // Added by Neha on 09/01/19
             t1 = RDSCommon.CreateTower(t1);
             recordIdMap.put('TOWER1',t1.Id);
Tower__c t2 = new Tower__c();
             t2.Name = 'Townhouse';
             t2.Project__c = objpr.Id;
             t2.Cluster__c = clus.Id; // Added by Neha on 09/01/19
             t2 = RDSCommon.CreateTower(t2);
             recordIdMap.put('TOWER2',t2.Id);
        Tower__c t3 = new Tower__c();
             t3.Name = 'Hartland Extension';
             t3.Project__c = objpr.Id;
             t3.Cluster__c = clus.Id; // Added by Neha on 09/01/19
             t3 = RDSCommon.CreateTower(t3);
             recordIdMap.put('TOWER3',t3.Id);
        Tower__c t4 = new Tower__c();
             t4.Name = 'Phase III - Building 5';
             t4.Project__c = objpr.Id;
             t4.Cluster__c = clus.Id; // Added by Neha on 09/01/19
             t4 = RDSCommon.CreateTower(t4);
             recordIdMap.put('TOWER4',t4.Id);
        Tower__c t5 = new Tower__c();
             t5.Name = 'Dipak';
             t5.Project__c = objpr.Id;
             t5.Cluster__c = clus.Id; // Added by Neha on 09/01/19
             t5 = RDSCommon.CreateTower(t5);
             recordIdMap.put('TOWER5',t5.Id);
             // tax slabs creation
             Tax_Slab__c taxS = new Tax_Slab__C();
             taxS.From_Date__c = System.today().addDays(-10);
             taxS.To_Date__c = System.today().addDays(10);
             taxS.Tax_Name__c = 'GST Affordable Housing';
             taxS.Tax1_Name__c = 'CGST';
             taxS.Tax1_Code__c = 'CGST';
             taxS.Tax1_Percentage__c = 5.00; //// 9
             taxS.Taxable1_Percentage__c = 100; /// 66.66667
             taxS.Tax_Rate__c = 'VAT 5%'; /// GST 12%
             taxS.Tax2_Name__c = 'SGST';
             taxS.Tax2_Code__c = 'SGST';
             taxS.Tax2_Percentage__c = 0.00; //// 9
             taxS.Taxable2_Percentage__c = 0; //// 66.66667
             taxS = RDSCommon.CreateTaxSlab(taxS);
             
             Tax_Slab__c taxS1 = new Tax_Slab__C();
             taxS1.From_Date__c = System.today().addDays(-10);
             taxS1.To_Date__c = System.today().addDays(10);
             taxS1.Tax_Name__c = 'GST Other Charges';
             taxS1.Tax1_Name__c = 'CGST';
             taxS1.Tax1_Code__c = 'CGST';
             taxS1.Tax1_Percentage__c = 0; //// 9.00
             taxS1.Taxable1_Percentage__c = 0;
             taxS1.Tax_Rate__c = 'VAT 0%'; /// GST 18%
             taxS1.Tax2_Name__c = 'SGST';
             taxS1.Tax2_Code__c = 'SGST';
             taxS1.Tax2_Percentage__c = 0; //// 9.00
             taxS1.Taxable2_Percentage__c = 0;
             taxS1 = RDSCommon.CreateTaxSlab(taxS1);
             
             Tax_Slab__c taxS2 = new Tax_Slab__C();
             taxS2.From_Date__c = System.today().addDays(-10);
             taxS2.To_Date__c = System.today().addDays(10);
             taxS2.Tax_Name__c = 'Cheque Bounce GST';
             taxS2.Tax1_Name__c = 'CGST';
             taxS2.Tax1_Code__c = 'CGST';
             taxS2.Tax1_Percentage__c = 0.00; ////9
             taxS2.Taxable1_Percentage__c = 0; ///100
             taxS2.Tax_Rate__c = 'OUT OF SCOPE'; /// GST 18%
             taxS2.Tax2_Name__c = 'SGST';
             taxS2.Tax2_Code__c = 'SGST';
             taxS2.Tax2_Percentage__c = 0.00; // 9
             taxS2.Taxable2_Percentage__c = 0; //// 100
             taxS2.Charge_Type__c = 'Cheque Bounce';
             taxS2 = RDSCommon.CreateTaxSlab(taxS2);
                         
             // project charges creation
             // first is always basic
             ProjectCharges__c PCharge = new ProjectCharges__c();
             PCharge.Project__c = objpr.Id;
             PCharge.Tower__c = t.Id;
             PCharge.Name = 'Basic';
             PCharge.Charge_Name__c = 'Basic';
             PCharge.Active__c = true;
             PCharge.Calculatedas__c = 'Rate List at Unit Level';
             PCharge.ChargeBucket__c = 'Agreement Value';
             PCharge.Editable__c = true;
             pCharge.Taxable__c = 66.6667;
             pCharge.SGST__c = 9.00;
             pCharge.CGST__c = 9.00;
             PCharge.Tax_Rate__c = 'VAT 5%';
             PCharge=RDSCommon.CreateProjectCharges(PCharge);
             recordIdMap.put('BASIC',PCharge.Id);
            
             ProjectCharges__c PCharge1 = new ProjectCharges__c();
             PCharge1.Project__c = objpr.Id;
             PCharge1.Tower__c = t.Id;
             PCharge1.Name = 'Floor Rise';
             PCharge1.Charge_Name__c = 'Floor Rise';
             PCharge1.Active__c = true;
             PCharge1.Calculatedas__c = 'Rate List at Unit Level';
             PCharge1.ChargeBucket__c = 'Agreement Value';
             PCharge1.Editable__c = true;
             PCharge1.Taxable__c = 66.6667;
             PCharge1.SGST__c = 9.00;
             PCharge1.CGST__c = 9.00;
             PCharge1.Tax_Rate__c = 'VAT 5%';
             PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
             
             ProjectCharges__c PCharge2 = new ProjectCharges__c();
             PCharge2.Project__c = objpr.Id;
             PCharge2.Tower__c = t.Id;
             PCharge2.Name = 'PLC';
             PCharge2.Charge_Name__c = 'PLC';
             PCharge2.Active__c = true;
             PCharge2.Calculatedas__c = 'Rate List at Unit Level';
             PCharge2.ChargeBucket__c = 'Agreement Value';
             PCharge2.Editable__c = true;
             PCharge2.Taxable__c = 66.6667;
             PCharge2.SGST__c = 9.00;
             PCharge2.CGST__c = 9.00;
             PCharge2.Tax_Rate__c = 'VAT 5%';
             PCharge2=RDSCommon.CreateProjectCharges(PCharge2);
             
             ProjectCharges__c PCharge3 = new ProjectCharges__c();
             PCharge3.Project__c = objpr.Id;
             PCharge3.Tower__c = t.Id;
             PCharge3.Name = 'Common Area Charges';
             PCharge3.Charge_Name__c = 'Common Area Charges';
             PCharge3.Active__c = true;
             PCharge3.Calculatedas__c = 'Rate List at Unit Level';
             PCharge3.ChargeBucket__c = 'Agreement Value';
             PCharge3.Editable__c = false;
             PCharge3.Taxable__c = 66.6667;
             PCharge3.SGST__c = 9.00;
             PCharge3.CGST__c = 9.00;
             PCharge3.Tax_Rate__c = 'VAT 5%';
             PCharge3=RDSCommon.CreateProjectCharges(PCharge3);
             
             ProjectCharges__c PCharge4 = new ProjectCharges__c();
             PCharge4.Project__c = objpr.Id;
             PCharge4.Tower__c = t.Id;
             PCharge4.Name = 'Utility Charges';
             PCharge4.Charge_Name__c = 'Utility Charges';
             PCharge4.Active__c = true;
             PCharge4.Calculatedas__c = 'Rate List at Unit Level';
             PCharge4.ChargeBucket__c = 'Other Charges';
             PCharge4.Editable__c = false;
             PCharge4.Taxable__c = 100;
             PCharge4.SGST__c = 9.00;
             PCharge4.CGST__c = 9.00;
             PCharge4.Tax_Rate__c = 'VAT 0%';
             PCharge4=RDSCommon.CreateProjectCharges(PCharge4);            
             
             ProjectCharges__c PCharge5 = new ProjectCharges__c();
             PCharge5.Project__c = objpr.Id;
             PCharge5.Tower__c = t.Id;
             PCharge5.Name = 'Legal Charges';
             PCharge5.Charge_Name__c = 'Legal Charges';
             PCharge5.Active__c = true;
             PCharge5.Calculatedas__c = 'Rate List at Unit Level';
             PCharge5.ChargeBucket__c = 'Other Charges';
             PCharge.Editable__c = false;
             PCharge5.Taxable__c = 100;
             PCharge5.SGST__c = 9.00;
             PCharge5.CGST__c = 9.00;
             PCharge5.Tax_Rate__c = 'VAT 0%';
             PCharge5=RDSCommon.CreateProjectCharges(PCharge5);
             
             ProjectCharges__c PCharge6 = new ProjectCharges__c();
             PCharge6.Project__c = objpr.Id;
             PCharge6.Tower__c = t.Id;
             PCharge6.Name = 'Share Money';
             PCharge6.Charge_Name__c = 'Share Money';
             PCharge6.Active__c = true;
             PCharge6.Calculatedas__c = 'Rate List at Unit Level';
             PCharge6.ChargeBucket__c = 'Society Charges';
             PCharge6.Editable__c = false;
             PCharge6.Taxable__c = 0;
             PCharge6.SGST__c = 0.00;
             PCharge6.CGST__c = 0.00;
             PCharge6.Tax_Rate__c = 'VAT 0%';
             PCharge6=RDSCommon.CreateProjectCharges(PCharge6);
             
             ProjectCharges__c PCharge7 = new ProjectCharges__c();
             PCharge7.Project__c = objpr.Id;
             PCharge7.Tower__c = t.Id;
             PCharge7.Name = 'Society Formation Charges';
             PCharge7.Charge_Name__c = 'Society Formation Charges';
             PCharge7.Active__c = true;
             PCharge7.Calculatedas__c = 'Rate List at Unit Level';
             PCharge7.ChargeBucket__c = 'Other Charges';
             PCharge7.Editable__c = false;
             PCharge7.Taxable__c = 100;
             PCharge7.SGST__c = 9.00;
             PCharge7.CGST__c = 9.00;
             PCharge7.Tax_Rate__c = 'VAT 0%';
             PCharge7=RDSCommon.CreateProjectCharges(PCharge7);
             
             ProjectCharges__c PCharge8 = new ProjectCharges__c();
             PCharge8.Project__c = objpr.Id;
             PCharge8.Tower__c = t.Id;
             PCharge8.Name = 'Stamp Duty';
             PCharge8.Charge_Name__c = 'Stamp Duty';
             PCharge8.Active__c = true;
             PCharge8.Calculatedas__c = 'Percentage of Agreement Value';
             PCharge8.ChargeBucket__c = 'Stamp Duty and Registration';
             PCharge8.Agreement_Value_Percentage__c = 6;
             PCharge8.Editable__c = false;
             PCharge8.Taxable__c = 0;
             PCharge8.SGST__c = 0.00;
             PCharge8.CGST__c = 0.00;
             PCharge8=RDSCommon.CreateProjectCharges(PCharge8);
             
             ProjectCharges__c PCharge9 = new ProjectCharges__c();
             PCharge9.Project__c = objpr.Id;
             PCharge9.Tower__c = t.Id;
             PCharge9.Name = 'Registration Charges';
             PCharge9.Charge_Name__c = 'Registration Charges';
             PCharge9.Active__c = true;
             PCharge9.Calculatedas__c = 'Rate list at Unit level';
             PCharge9.ChargeBucket__c = 'Stamp Duty and Registration';
             PCharge9.Editable__c = false;
             PCharge9.Taxable__c = 0;
             PCharge9.SGST__c = 0.00;
             PCharge9.CGST__c = 0.00;
             PCharge9=RDSCommon.CreateProjectCharges(PCharge9);
           //  recordIdMap.put('STAMPDUTY',PCharge9.Id);
             
             // unit creation associated to project and tower
                Unit__c objPU1 = new Unit__c();    
                objPU1.Name = 'TestFive';      
                objPU1.Project__c = objpr.Id;            
                objPU1.Unit_status__c='Available';
                objPU1.Chargeable_Area__c = 936;
                objPU1.Carpet_Area__c = 452;
                objPU1.Tower__c = t.Id;
                objPU1.Active_Inactive__c = 'Active';
                objPU1.Carpet_Area_in_Sq_Mts__c = 45.02;
                objPU1.Cupboard_Area_in_Sq_Mtrs__c = 3.95;
                objPU1.Enclosed_Balcony_in_Sq_Mtrs__c = 2.66;
                objPU1.Floor__c = 2;
                objPU1.Not_Available_for_Sales__c = False;
                objPU1=RDSCommon.CreateProjectUnit(objPU1);
                recordIdMap.put('UNIT',objPU1.Id);  
        
        Unit__c objPU2 = new Unit__c();    
                objPU2.Name = 'TestFive';      
                objPU2.Project__c = objpr.Id;            
                objPU2.Unit_status__c='Available';
                objPU2.Chargeable_Area__c = 936;
                objPU2.Carpet_Area__c = 452;
                objPU2.Tower__c = t1.Id;
                objPU2.Active_Inactive__c = 'Active';
                objPU2.Carpet_Area_in_Sq_Mts__c = 45.02;
                objPU2.Cupboard_Area_in_Sq_Mtrs__c = 3.95;
                objPU2.Enclosed_Balcony_in_Sq_Mtrs__c = 2.66;
                objPU2.Floor__c = 2;
                objPU2.Not_Available_for_Sales__c = False;
                objPU2=RDSCommon.CreateProjectUnit(objPU2);
                recordIdMap.put('UNIT2',objPU2.Id);
        Unit__c objPU3 = new Unit__c();    
                objPU3.Name = 'TestFive';      
                objPU3.Project__c = objpr.Id;            
                objPU3.Unit_status__c='Available';
                objPU3.Chargeable_Area__c = 936;
                objPU3.Carpet_Area__c = 452;
                objPU3.Tower__c = t2.Id;
                objPU3.Active_Inactive__c = 'Active';
                objPU3.Carpet_Area_in_Sq_Mts__c = 45.02;
                objPU3.Cupboard_Area_in_Sq_Mtrs__c = 3.95;
                objPU3.Enclosed_Balcony_in_Sq_Mtrs__c = 2.66;
                objPU3.Floor__c = 2;
                objPU3.Not_Available_for_Sales__c = False;
                objPU3=RDSCommon.CreateProjectUnit(objPU3);
                recordIdMap.put('UNIT3',objPU3.Id);
        Unit__c objPU4 = new Unit__c();    
                objPU4.Name = 'TestFive';      
                objPU4.Project__c = objpr.Id;            
                objPU4.Unit_status__c='Available';
                objPU4.Chargeable_Area__c = 936;
                objPU4.Carpet_Area__c = 452;
                objPU4.Tower__c = t3.Id;
                objPU4.Active_Inactive__c = 'Active';
                objPU4.Carpet_Area_in_Sq_Mts__c = 45.02;
                objPU4.Cupboard_Area_in_Sq_Mtrs__c = 3.95;
                objPU4.Enclosed_Balcony_in_Sq_Mtrs__c = 2.66;
                objPU4.Floor__c = 2;
                objPU4.Not_Available_for_Sales__c = False;
                objPU4=RDSCommon.CreateProjectUnit(objPU4);
                recordIdMap.put('UNIT4',objPU4.Id);
        Unit__c objPU5 = new Unit__c();    
                objPU5.Name = 'TestFive';      
                objPU5.Project__c = objpr.Id;            
                objPU5.Unit_status__c='Available';
                objPU5.Chargeable_Area__c = 936;
                objPU5.Carpet_Area__c = 452;
                objPU5.Tower__c = t4.Id;
                objPU5.Active_Inactive__c = 'Active';
                objPU5.Carpet_Area_in_Sq_Mts__c = 45.02;
                objPU5.Cupboard_Area_in_Sq_Mtrs__c = 3.95;
                objPU5.Enclosed_Balcony_in_Sq_Mtrs__c = 2.66;
                objPU5.Floor__c = 2;
                objPU5.Not_Available_for_Sales__c = False;
                objPU5=RDSCommon.CreateProjectUnit(objPU5);
                recordIdMap.put('UNIT5',objPU5.Id);
        Unit__c objPU6 = new Unit__c();    
                objPU6.Name = 'TestFive';      
                objPU6.Project__c = objpr.Id;            
                objPU6.Unit_status__c='Available';
                objPU6.Chargeable_Area__c = 936;
                objPU6.Carpet_Area__c = 452;
                objPU6.Tower__c = t5.Id;
                objPU6.Active_Inactive__c = 'Active';
                objPU6.Carpet_Area_in_Sq_Mts__c = 45.02;
                objPU6.Cupboard_Area_in_Sq_Mtrs__c = 3.95;
                objPU6.Enclosed_Balcony_in_Sq_Mtrs__c = 2.66;
                objPU6.Floor__c = 2;
                objPU6.Not_Available_for_Sales__c = False;
                objPU6=RDSCommon.CreateProjectUnit(objPU6);
                recordIdMap.put('UNIT6',objPU2.Id);
        
             
             // account creation 
             Account objac = new Account();
             objac.FirstName = 'Shock';
             objac.LastName = 'Wave';
             objac.Correspondence_Address__c = 'Delhi';
             objac.Category__c = 'General';
             objac.Unit__c = objPU1.Id;
             objac=RDSCommon.CreateAccount(objac);
             recordIdMap.put('ACCOUNT',objac.Id);
             
             // opportunity creation              
             Opportunity objOpportunity = new Opportunity();
             objOpportunity.Name = 'Test';
             objOpportunity.CloseDate = System.today();
             objOpportunity.AccountId = objac.Id; 
             objOpportunity.Status__c = 'Active'; 
             objOpportunity.StageName = 'Opportunity Identified'; 
             objOpportunity.Project__c = objpr.Id; 
             objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
             recordIdMap.put('OPPORTUNITY',objOpportunity.Id);
            
             // construction stage creation
             // two stages are being created
             Project_Construction_Stages__c objPCS = new Project_Construction_Stages__c();
             objPCS.Project__c = objpr.Id;
             objPCS.Name = 'Completion of Plinth';
             objPCS.Sequence_No__c =1;
             objPCS.Planned_date_of_completion__c = System.today().addDays(365);
             objPCS.Tower__c = t.Id;
             insert objPCS;
             recordIdMap.put('PROJECTCONSTRUCTIONSTAGE1',objPCS.Id);
             
             Project_Construction_Stages__c objPCS1 = new Project_Construction_Stages__c();
             objPCS1.Project__c = objpr.Id;
             objPCS1.Name = 'Completion of Escavation';
             objPCS1.Sequence_No__c = 2;
             objPCS1.Planned_date_of_completion__c = System.today().addDays(365);
             objPCS1.Tower__c = t.Id;
             insert objPCS1;
             recordIdMap.put('PROJECTCONSTRUCTIONSTAGE2',objPCS1.Id);
            
             Rate_List__c objRld = new Rate_List__c();
             //objRld.Name = 'Basic';
             objRld.Type__c = 'PSF';
             objRld.PSF_rate__c = 5100;
             objRld.ProjectCharges__c = PCharge.id;
             objRld.Unit__c =   objPU1.id;
             objRld.Rate_List_Bucket__c = 'Agreement Value';
             objRld.Area_type__c = 'Chargeable Area';
             objRld = RDSCommon.createRateList(objRld);
             
             Rate_List__c objRld1 = new Rate_List__c();
             //objRld1.Name = 'Floor Rise';
             objRld1.Type__c = 'PSF';
             objRld1.PSF_rate__c = 840;
             objRld1.ProjectCharges__c = PCharge1.id;
             objRld1.Unit__c =   objPU1.id;
             objRld1.Rate_List_Bucket__c = 'Agreement Value';
             objRld1.Area_type__c = 'Chargeable Area';
             objRld1 = RDSCommon.createRateList(objRld1);
             
             Rate_List__c objRld2 = new Rate_List__c();
            // objRld2.Name = 'PLC';
             objRld2.Type__c = 'PSF';
             objRld2.PSF_rate__c = 0;
             objRld2.ProjectCharges__c = PCharge2.id;
             objRld2.Unit__c =   objPU1.id;
             objRld2.Rate_List_Bucket__c = 'Agreement Value';
             objRld2.Area_type__c = 'Chargeable Area';
             objRld2 = RDSCommon.createRateList(objRld2);
             
             Rate_List__c objRld3 = new Rate_List__c();
             //objRld3.Name = 'Common Area Charges';
             objRld3.Type__c = 'Lumpsum';
             objRld3.Lumpsum_Amount__c = 275000;
             objRld3.ProjectCharges__c = PCharge3.id;
             objRld3.Unit__c =   objPU1.id;
             objRld3.Rate_List_Bucket__c = 'Agreement Value';
             objRld3.Area_type__c = 'Chargeable Area';
             objRld3 = RDSCommon.createRateList(objRld3);
             
             Rate_List__c objRld4 = new Rate_List__c();
             //objRld4.Name = 'Utlity Charges';
             objRld4.Type__c = 'Lumpsum';
             objRld4.Lumpsum_Amount__c = 75000;
             objRld4.ProjectCharges__c = PCharge4.id;
             objRld4.Unit__c =   objPU1.id;
             objRld4.Rate_List_Bucket__c = 'Other Charges';
             objRld4.Area_type__c = 'Chargeable Area';
             objRld4 = RDSCommon.createRateList(objRld4);
             
             Rate_List__c objRld5 = new Rate_List__c();
             //objRld5.Name = 'Legal Charges';
             objRld5.Type__c = 'Lumpsum';
             objRld5.Lumpsum_Amount__c = 25000;
             objRld5.ProjectCharges__c = PCharge5.id;
             objRld5.Unit__c =   objPU1.id;
             objRld5.Rate_List_Bucket__c = 'Other Charges';
             objRld5.Area_type__c = 'Chargeable Area';
             objRld5 = RDSCommon.createRateList(objRld5);
             
             Rate_List__c objRld6 = new Rate_List__c();
             //objRld6.Name = 'Share Money';
             objRld6.Type__c = 'Lumpsum';
             objRld6.Lumpsum_Amount__c = 600;
             objRld6.ProjectCharges__c = PCharge6.id;
             objRld6.Unit__c =   objPU1.id;
             objRld6.Rate_List_Bucket__c = 'Society Charges';
             objRld6.Area_type__c = 'Chargeable Area';
             objRld6 = RDSCommon.createRateList(objRld6);
             
             Rate_List__c objRld7 = new Rate_List__c();
             //objRld7.Name = 'Society Formation Charges';
             objRld7.Type__c = 'Lumpsum';
             objRld7.Lumpsum_Amount__c = 25000;
             objRld7.ProjectCharges__c = PCharge7.id;
             objRld7.Unit__c =   objPU1.id;
             objRld7.Rate_List_Bucket__c = 'Society Charges';
             objRld7.Area_type__c = 'Chargeable Area';
             objRld7 = RDSCommon.createRateList(objRld7);
             
             Rate_List__c objRld8 = new Rate_List__c();
             //objRld8.Name = 'Registration Charges';
             objRld8.Type__c = 'Lumpsum';
             objRld8.Lumpsum_Amount__c = 30000;
             objRld8.ProjectCharges__c = PCharge9.id;
             objRld8.Unit__c =   objPU1.id;
             objRld8.Rate_List_Bucket__c = 'Stamp Duty and Registration';
             objRld8.Area_type__c = 'Chargeable Area';
             objRld8 = RDSCommon.createRateList(objRld8);
             
             //payment plan header record creation.
             
             Payment_Plan__c pp = new Payment_Plan__c();
             pp.Tower__c = t.Id;
             pp.Plan_Code__c = '001';
             pp.Project__c = objpr.Id;
             pp.No_GST_on_Token__c = true;
             pp.NoofMilestones__c = 6;
             pp.Is_Access_Restricted__c = true;
             pp.Valid_Till__c = System.today().addDays(5);
             pp = RDSCommon.createPaymentPlan(pp);
             recordIdMap.put('PLAN',pp.Id);
             
             Payment_Plan__c pp1 = new Payment_Plan__c();
             pp1.Tower__c = t.Id;
             pp1.Plan_Code__c = '002';
             pp1.Project__c = objpr.Id;
             pp1.No_GST_on_Token__c = true;
             pp1.NoofMilestones__c = 6;
             pp1.Subvention_Payment_Plan__c = true;
             pp1.Is_Access_Restricted__c = true;
             pp1.Valid_Till__c = System.today().addDays(5); 
             pp1 = RDSCommon.createPaymentPlan(pp1);
             recordIdMap.put('PLAN1',pp1.Id);
             
             //// Created by Neha on 14/5/19 for Floor specific Payment Plan     
             Payment_Plan__c pp2 = new Payment_Plan__c();
             pp2.Tower__c = t.Id;
             pp2.Plan_Code__c = '003';
             pp2.Project__c = objpr.Id;
             pp2.No_GST_on_Token__c = true;
             pp2.NoofMilestones__c = 6;
             pp2.Subvention_Payment_Plan__c = true;
             pp2.Is_Access_Restricted__c = true; // Added by Neha on 14/5/19
             pp2.Valid_Till__c = System.today().addDays(5); // Added by Neha on 14/5/19
             pp2.From_Floor__c = 1; // Added by Neha on 14/5/19
             pp2.To_Floor__c = 3; // Added by Neha on 14/5/19
             pp2 = RDSCommon.createPaymentPlan(pp2);
             recordIdMap.put('PLAN2',pp2.Id);
             
             // payment plan milestone records
             List<Payment_Plan_Milestones__c> ppmList = [Select Id from Payment_Plan_Milestones__c where Payment_Plan__c = :pp.Id order by createdDate desc];
             if(ppmList != null && ppmList.size() ==6) {
               // token amount 50K
               ppmList[0].Plan_Milestone_Type__c = 'Date Linked';
               ppmList[0].Number_Of_Days_Plan__c = 10;
               ppmList[0].Time_Period__c = 'Days'; 
               
               ppmList[0].Charge1Value__c = 50000;
               ppmList[0].Charge1Type__c = 'Amount';
               ppmList[0].Charge_1_Lookup__c = pCharge.Id;
               
               ppmList[0].Charge2Value__c = 0;
               ppmList[0].Charge2Type__c = 'Amount';
               ppmList[0].Charge_2_Lookup__c = pCharge1.Id;
               
               ppmList[0].Charge3Value__c = 0;
               ppmList[0].Charge3Type__c = 'Amount';
               ppmList[0].Charge_3_Lookup__c = pCharge2.Id;
               
               ppmList[0].Charge4Value__c = 0;
               ppmList[0].Charge4Type__c = 'Amount';
               ppmList[0].Charge_4_Lookup__c = pCharge3.Id;
               
               // 5% Consideration Value - 50K, second milestone
               ppmList[1].Plan_Milestone_Type__c = 'Date Linked';
               ppmList[1].Deduct_Token__c = true;
               ppmList[1].Token_Amount__c = 50000;
               ppmList[1].Add_Token_GST__c = true;
               ppmList[1].Number_Of_Days_Plan__c = 20;
               ppmList[1].Time_Period__c = 'Days'; 
               
               ppmList[1].Charge1Type__c = 'Percentage';
               ppmList[1].Charge1Value__c = 5;
               ppmList[1].Charge_1_Lookup__c = pCharge.Id;
               
               ppmList[1].Charge2Type__c = 'Percentage';
               ppmList[1].Charge2Value__c = 5;
               ppmList[1].Charge_2_Lookup__c = pCharge1.Id;
               
               ppmList[1].Charge3Type__c = 'Percentage';
               ppmList[1].Charge3Value__c = 5;
               ppmList[1].Charge_3_Lookup__c = pCharge2.Id;
               
               ppmList[1].Charge4Type__c = 'Percentage';
               ppmList[1].Charge4Value__c = 5;
               ppmList[1].Charge_4_Lookup__c = pCharge3.Id;
               
               // 5% Consideration Value third milestone
               ppmList[2].Plan_Milestone_Type__c = 'Date Linked';
               ppmList[2].Number_Of_Days_Plan__c = 2;
               ppmList[2].Time_Period__c = 'Month'; 
               ppmList[2].Charge1Type__c = 'Percentage';
               ppmList[2].Charge1Value__c = 5;
               ppmList[2].Charge_1_Lookup__c = pCharge.Id;
               
               ppmList[2].Charge2Type__c = 'Percentage';
               ppmList[2].Charge2Value__c = 5;
               ppmList[2].Charge_2_Lookup__c = pCharge1.Id;
               
               ppmList[2].Charge3Type__c = 'Percentage';
               ppmList[2].Charge3Value__c = 5;
               ppmList[2].Charge_3_Lookup__c = pCharge2.Id;
               
               ppmList[2].Charge4Type__c = 'Percentage';
               ppmList[2].Charge4Value__c = 5;
               ppmList[2].Charge_4_Lookup__c = pCharge3.Id;
               
               // On registration milestone  fourth milestone 20% of Consideration Value + 100 of registration charges
               ppmList[3].Plan_Milestone_Type__c = 'On Registration';
               ppmList[3].Number_Of_Days_Plan__c = 3;
               ppmList[3].Time_Period__c = 'Month';
               ppmList[3].Charge1Type__c = 'Percentage'; //Basic
               ppmList[3].Charge1Value__c = 20;
               ppmList[3].Charge_1_Lookup__c = pCharge.Id;
               
               ppmList[3].Charge2Type__c = 'Percentage'; //Floor Rise
               ppmList[3].Charge2Value__c = 20;
               ppmList[3].Charge_2_Lookup__c = pCharge1.Id;
               
               ppmList[3].Charge3Type__c = 'Percentage'; //PLC
               ppmList[3].Charge3Value__c = 20;
               ppmList[3].Charge_3_Lookup__c = pCharge2.Id;
               
               ppmList[3].Charge4Type__c = 'Percentage';  //Common Area
               ppmList[3].Charge4Value__c = 20;
               ppmList[3].Charge_4_Lookup__c = pCharge3.Id;
               
               ppmList[3].Charge9Type__c = 'Percentage'; //SD charges
               ppmList[3].Charge9Value__c = 100;
               ppmList[3].Charge_9_Lookup__c = pCharge8.Id;
               
               ppmList[3].Charge10Type__c = 'Percentage'; //registration charges
               ppmList[3].Charge10Value__c = 100;
               ppmList[3].Charge_10_Lookup__c = pCharge9.Id;
               
               // CLP - 5th milestone 30% of Consideration Value
               ppmList[4].Plan_Milestone_Type__c = 'Construction Linked';
               ppmList[4].Number_Of_Days_Plan__c = 100;
               ppmList[4].Time_Period__c = 'Days';
               ppmList[4].Project_Construction_Stages__c = objPCS.Id;
               ppmList[4].Charge1Type__c = 'Percentage'; //Basic
               ppmList[4].Charge1Value__c = 30;
               ppmList[4].Charge_1_Lookup__c = pCharge.Id;
               
               ppmList[4].Charge2Type__c = 'Percentage'; //Floor Rise
               ppmList[4].Charge2Value__c = 30;
               ppmList[4].Charge_2_Lookup__c = pCharge1.Id;
               
               ppmList[4].Charge3Type__c = 'Percentage'; //PLC
               ppmList[4].Charge3Value__c = 30;
               ppmList[4].Charge_3_Lookup__c = pCharge2.Id;
               
               ppmList[4].Charge4Type__c = 'Percentage';  //Common Area
               ppmList[4].Charge4Value__c = 30;
               ppmList[4].Charge_4_Lookup__c = pCharge3.Id;
               
               // CLP - 6th milestone 40% of Consideration Value + 100% of society and other charges
               ppmList[5].Plan_Milestone_Type__c = 'Date Linked';
               ppmList[5].Number_Of_Days_Plan__c = 200;
               ppmList[5].Time_Period__c = 'Days';
               ppmList[5].Is_Combination_Milestone__c = true; 
               ppmList[5].Project_Construction_Stages__c = objPCS1.Id;
               ppmList[5].Charge1Type__c = 'Percentage'; //Basic
               ppmList[5].Charge1Value__c = 40;
               ppmList[5].Charge_1_Lookup__c = pCharge.Id;
               
               ppmList[5].Charge2Type__c = 'Percentage'; //Floor Rise
               ppmList[5].Charge2Value__c = 40;
               ppmList[5].Charge_2_Lookup__c = pCharge1.Id;
               
               ppmList[5].Charge3Type__c = 'Percentage'; //PLC
               ppmList[5].Charge3Value__c = 40;
               ppmList[5].Charge_3_Lookup__c = pCharge2.Id;
               
               ppmList[5].Charge4Type__c = 'Percentage';  //Common Area
               ppmList[5].Charge4Value__c = 40;
               ppmList[5].Charge_4_Lookup__c = pCharge3.Id;
               
               ppmList[5].Charge5Type__c = 'Percentage';  //Utility
               ppmList[5].Charge5Value__c = 100;
               ppmList[5].Charge_5_Lookup__c = pCharge4.Id;
               
               ppmList[5].Charge6Type__c = 'Percentage';  //Legal
               ppmList[5].Charge6Value__c = 100;
               ppmList[5].Charge_6_Lookup__c = pCharge5.Id;
               
               ppmList[5].Charge7Type__c = 'Percentage';  //Share money
               ppmList[5].Charge7Value__c = 40;
               ppmList[5].Charge_7_Lookup__c = pCharge6.Id;
               
               ppmList[5].Charge8Type__c = 'Percentage';  //Society Formation
               ppmList[5].Charge8Value__c = 100;
               ppmList[5].Charge_8_Lookup__c = pCharge7.Id;
               
               update ppmList;               
             }
             // create car parks
             Car_Park__c cp = new Car_Park__c();
             cp.project__c = objpr.Id;
             cp.Type__c = 'Stack';
             cp.Category__c = 'Additional';
             cp.Status__c = 'Available';
             insert cp;
                          
             Car_Park__c cp1 = new Car_Park__c();
             cp1.project__c = objpr.Id;
             cp1.Type__c = 'Open';
             cp1.Category__c = 'Additional';
             cp1.Status__c = 'Available';
             insert cp1;
             
             //create the approvers team
             Team__c objTeam = new Team__c();
             objTeam.Name = 'Sales Approvers Team';
             objTeam.Project__c = objpr.id;
             objTeam.Team_Type__c = 'Sales Approvers Team';
             objTeam.Tower__c = t.id;
             insert objTeam;
             //create users
             User a1 = createUserSysAdmin('One','Galvatron', 'galvatron'+Crypto.getRandomInteger()+'@example.com', 'galvatron1@example.com');
             User a2 = createUserSysAdmin('Two','Galvatron', 'galvatron'+Crypto.getRandomInteger()+'@example.com', 'galvatron2@example.com');
             User a3 = createUserSysAdmin('Three','Galvatron', 'galvatron'+Crypto.getRandomInteger()+'@example.com', 'galvatron3@example.com');
             
             a1.Special_Payment_Plan_Visible__c = true; // Added by Neha on 14/5/19
             update a1;
             // insert team as team members
             Team_Members__c tm1 = new Team_Members__c();
             tm1.Team__c = objTeam.Id;
             tm1.User_Active__c = true;
             tm1.Approver_Type__c = 'First Level';
             tm1.User__c = a1.id;
             insert tm1;
             recordIdMap.put('APPROVER1',tm1.Id);
             
             Team_Members__c tm2 = new Team_Members__c();
             tm2.Team__c = objTeam.Id;
             tm2.User_Active__c = true;
             tm2.Approver_Type__c = 'Second Level';
             tm2.User__c = a2.id;
             insert tm2;
             recordIdMap.put('APPROVER2',tm2.Id);
             
             Team_Members__c tm3 = new Team_Members__c();
             tm3.Team__c = objTeam.Id;
             tm3.User_Active__c = true;
             tm3.Approver_Type__c = 'Third Level';
             tm3.User__c = a3.id;
             insert tm3;
            recordIdMap.put('APPROVER3',tm3.Id);     
            
            return recordIdMap;    
  } 
  public static List<Lead> createLead(Integer numofLeads) {
    List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numofLeads;i++){           
            Lead l = new Lead(firstName = 'first' , lastName='radiusLead' + i, Email='radiuslead' +i +'@radiustest.com' , mobilePhone='123456789' + i);           
            leads.add(l);
        }
        insert leads;
        return leads;  
  }
   
  /// Create lead for project sms field by vikas  
   public static List<Lead> createLeadProject(Integer numofLeads, Id ProjectId) {
    List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numofLeads;i++) {            
            Lead l = new Lead(firstName = 'first' , lastName='radiusLead' + i, Email='radiuslead' +i +'@radiustest.com' , mobilePhone='123456789' + i, Project__c = ProjectId);            
            leads.add(l);
        }
        insert leads;
        return leads;  
  }
  
  public static Lead createLeadTemplate(String lastName, String email, String mobile, Boolean isMaster) {
        Lead l = new Lead(firstName ='first', lastName= lastName, Email= email , mobilePhone= mobile, MasterRecord__c = isMaster);
        insert l;
        return l;  
  }


public static Lead createLeadTemplateA(String lastName, String email, String mobile, Boolean isMaster) {
        Lead l = new Lead(lastName= lastName, Email= email , mobilePhone= mobile, MasterRecord__c = isMaster);
        insert l;
        return l;   
    }
    
    public static Lead createLeadTemplateB(String lastName, String email, String mobile, Boolean isMaster, String campaignCode, String country) {
        Lead l = new Lead(lastName= lastName, Email= email , mobilePhone= mobile, MasterRecord__c = isMaster, Campaign_Code__c = campaignCode );
        insert l;
        return l;   
    }
    
    public static Lead createLeadTemplateE(String lastName, String email, String altEmail, String mobile, Boolean isMaster) {
        Lead l = new Lead(lastName= lastName, Email= email , mobilePhone= mobile,   RDS_Alternate_Email_Id__c = altemail, MasterRecord__c = isMaster);
        insert l;
        return l;  
    }
      
    public static Lead createLeadTemplateF(String lastName, String email, String mobile, String altMobile, Boolean isMaster) {
            Lead l = new Lead(lastName= lastName, Email= email , mobilePhone= mobile, phone= altMobile, MasterRecord__c = isMaster);
            insert l;
            return l;  
    }

  // creates  a person account with the basic parameters
  public static Account createPATemplate(String accName, String Email, String Mobile, Boolean isMaster) {
    List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
    Account a = new Account(lastName=accName, personEmail = email, personMobilePhone= Mobile, RecordTypeId = personAccountRecordType[0].id, MasterRecord__c = isMaster);
    insert a;
    return a;
  }
 
   // creates  a person account with the CAMPAIGN  AND CHANNEL parameters
    public static Account createPATemplateB(String accName, String Email, String Mobile, Boolean isMaster,String campaignCode) {
        List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account a = new Account(lastName=accName, personEmail = email, personMobilePhone= Mobile, RecordTypeId = personAccountRecordType[0].id, MasterRecord__c = isMaster, Campaign_Code__c = campaignCode);
        insert a;
        return a;
    }

    // creates  a person account with the CAMPAIGN  AND CHANNEL parameters and alternate contact details
    public static Account createPATemplateAlt(String accName, String Email, String Mobile, Boolean isMaster,String campaignCode) {
        List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account a = new Account(lastName=accName, Alternate_Email__c = email, phone= Mobile, RecordTypeId = personAccountRecordType[0].id, MasterRecord__c = isMaster, Campaign_Code__c = campaignCode );
        insert a;
        return a;
  }
  
     //create Campaign with CampaignCode
      public static Campaign createCampaignCC(String cName, String Type) {
        Campaign c = new Campaign(Name = cName, Type = Type, isActive = true);
        insert c;
        Campaign cnew = [Select Id, Name, Campaign_Code__C, Type from Campaign where id= : c.id];
        return cnew;
    }
    //create Campaign with CampaignCode
    public static Campaign createCampaignCCNew(String cName, String Type, String ccCode) {
        Campaign c = new Campaign(Name = cName, Type = Type, isActive = true, Digital_Maketing_Campaign_Code__c=ccCode);
        insert c;
        Campaign cnew = [Select Id, Name, Campaign_Code__C, Digital_Maketing_Campaign_Code__c,Type from Campaign where id= : c.id];
        return cnew;
    }
   
 public static User createUserSysAdmin(string fn, string ln, string username, string email) {
    
    Profile p = [Select Id, Name from Profile where Name = 'System Administrator' LIMIT 1];   
    User u1 = [SELECT Id, Name FROM User WHERE Username LIKE '%sfc.abdul@sobharealty.com%' LIMIT 1];
    User u = new User(firstName = fn, lastName = ln,Department__C = 'Finance', email=email, Username= username, ProfileId = p.Id, alias= ln.substring(0,7),EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230', ManagerId = u1.Id);
    insert u;
    return u;    
  }
  
  public static Lead convertLead(Lead l) {
    LeadStatus convertStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1];
       List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
       if (!l.isConverted) {
            Database.LeadConvert lc = new Database.LeadConvert();
            String oppName = l.Name;
             lc.setLeadId(l.Id);
             lc.setOpportunityName(oppName);
             lc.setConvertedStatus(convertStatus.MasterLabel);
             leadConverts.add(lc);
        }
       if (!leadConverts.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
       }
       lead clead = [Select Id, ConvertedAccountId, ConvertedOpportunityId, IsConverted from Lead where id = :l.Id];
       return clead;
  }
  
  public static Project__c createProject(String ProjName, String ProjectCode){
        Project__c objProject = new Project__c(Name = ProjName, Project_Code__c = projectCode);
        insert objProject;
        return objProject;
    }  
        
      public static List<Cluster__c> createClusters(Integer numOfClusters, Id projId){
        List<Cluster__c> cList = new list<Cluster__c>();
        for(Integer i=0;i<numOfClusters;i++){
            Cluster__c c = new Cluster__c(Name='Cluster'+i, Project__c = projId);
            cList.add(c);
        }
        insert cList;
        List<Cluster__c> newList = [Select Id, Name,Project__c, Project__r.Id from Cluster__c where Id in :cList];
        return newList;
    }
    public static List<Tower__c> createTowers(Integer numOfTowers, Id projId){
        List<Tower__c> tList = new list<Tower__c>();
        for(Integer i=0;i<numOfTowers;i++){
            Tower__c t = new Tower__c(Name='Tower'+i, Project__c = projId, Business_Unit__c = 'Hartland', Business_Unit_Code__c = '101');
            tList.add(t);
        }
        insert tList;
        List<Tower__c> newList = [Select Id, Name,Project__c , Project__r.Id from Tower__c where Id in :tList];
        return newList;
    }
    
    public static Unit__c createProjectUnit(Id projId){
        Unit__c objProjUnit = new Unit__c(Name = 'Test Project Unit', Unit_Status__c = 'Available', Project__c = projId);
        insert objProjUnit;
        return objProjUnit;
    }
    public static List<Unit__c> createUnits(Id TowerId){
        List<Unit__c> uList = new list<Unit__c>();
        return uList;
    }
  
    public static List<Unit__c> createUnits(Id TowerId, Id pId){
        List<Unit__c> uList = new List<Unit__c>();
        for(integer i=1;i<=3;i++){
            Unit__c uObj = new Unit__c();
            uObj.name = '100'+ i;
            uObj.Carpet_Area__c = 425;
            uObj.Chargeable_Area__c = 923;
            uObj.Configuration__c = '2BHK';
            uObj.Unit_Status__c = 'Available';
            uObj.Active_Inactive__c = 'Active';
            uObj.Project__c = pId;
            uObj.Tower__c = TowerId;
            uObj.Floor__c = i;
            uList.add(uObj);
        }
        insert uList;
        return uList;
    } 
     
  // the parameters are set to match the project parameters to fulfill the data needs for opportunity rating calculation
  public static List<Opportunity> createOpptyForAccount(Id  accId, Id ProjId, Integer numOfOpp){
    List<Opportunity> oList = new List<Opportunity>();
    Date closeDate; 
    for(Integer i =0;i<numOfOpp; i++){
      closeDate = Date.newInstance(2015, 8,29);
      Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Opportunity Identified', Amount=5000000, AccountId =accId, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', S_Budget_In_lacs__c = 5000000, Project__c = ProjId,closeDate=System.today());
      oList.add(o);            
    }
    insert oList;
    return oList;
  } 
 
 // Create oppty for account with sub marketing as Cross project
   public static List<Opportunity> createOpptyForAccountCross(Id  accId, Id ProjId, Integer numOfOpp){
    List<Opportunity> oList = new List<Opportunity>();
    Date closeDate; 
    for(Integer i =0;i<numOfOpp; i++){
      closeDate = Date.newInstance(2015, 8,29);
      Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Opportunity Identified', Amount=5000000, AccountId =accId, Status__c ='Active', Marketing_Source__c = 'Presales', Marketing_sub_source__c = 'Cross Project', S_Budget_In_lacs__c = 5000000, Project__c = ProjId,closeDate=System.today(), Possession_Requirement__c = 'Ready to Live In (RTLI)', Purpose__c = 'Capital Gain');
      oList.add(o);            
    }
    insert oList;
    return oList;
  } 
  
  public static List<Task> createTasksForOpp(Id oppId, Integer NumberofTasks, String TaskType) {
    List<task> tList = new List<task>();
    for(Integer i=0; i<NumberofTasks; i++){
      task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whatId = oppId, call_time__c = TaskManagementServices.FormatTime(system.now()) );
      tList.add(t);
    }
    insert tList;
    return tList;
  }
  
    public static List<Task> createTasksForOppWithStatus(Id oppId, Integer NumberofTasks, String TaskType, String callAttemptStatus,String previousCallStatus) {
    List<task> tList = new List<task>();
    for(Integer i=0; i<NumberofTasks; i++){
      task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whatId = oppId, call_time__c = TaskManagementServices.FormatTime(system.now()),   Call_Attempt_Status__c = callAttemptStatus, Previous_Call_Attempt_Status__c=PreviousCallStatus);
      tList.add(t);
    }
    insert tList;
    return tList;
  }
  
   public static List<Task> createTasksForLead(Id leadId, Integer NumberofTasks, String TaskType) {
    List<task> tList = new List<task>();
    
    for(Integer i=0; i<NumberofTasks; i++){
      task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whoId = leadId, call_time__c = TaskManagementServices.FormatTime(system.now()) );
      tList.add(t);
    }
    insert tList;
    return tList;
  }
  
     public static List<Task> createTasksForLeadWithStatus (Id leadId, Integer NumberofTasks, String TaskType, String callAttemptStatus,String PreviousCallStatus) {
    List<task> tList = new List<task>();
    for(Integer i=0; i<NumberofTasks; i++){
      task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whoId = leadId, call_time__c = TaskManagementServices.FormatTime(system.now()), Call_Attempt_Status__c = callAttemptStatus,Previous_Call_Attempt_Status__c=PreviousCallStatus );
      tList.add(t);
    }
    insert tList;
    return tList;
  }
  
      // For Sending Brochure Attachment. added by Netra. - 19/04/2016
      public static void createEmailTemplate(String tName, String subject, String Body, String devName){
            EmailTemplate et = new EmailTemplate(Name=tName, Subject=subject, Body=body,developerName = devName);
            et.FolderId = UserInfo.getUserId();
            et.TemplateType ='Text';
            system.debug('et ::'+et);
            insert et;
      } 
      
      public static Blocking_Detail__c createBlockRecord(Id oppId, Id accId, Id uId, String status){
        Blocking_Detail__c b = new Blocking_Detail__c();
        b.Opportunity__c = oppId;
        b.Account_Name__c = accId;
        b.Unit__c = uId;
        b.Status__c = status;
        if(status.equals('Blocked'))
        b.comments__c = 'Blocked ' + uId;
        else 
        b.release_comments__c = 'Released ' + uId;
        insert b;
        return b;
     }
}
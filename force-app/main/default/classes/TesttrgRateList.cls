@isTest
public class TesttrgRateList{
@isTest
private static void TestupdateUnit() { 
      
 Project__c pro;
 Unit__c unit1;
 Unit__c unit2;
 Opportunity opty1;
 ProjectCharges__c projchrg1;
 
 pro = TestDataFactory.createProject('Sobha_project', '123'); // create project
 
 List<Cluster__c> cList = TestDataFactory.createClusters(3, pro.Id); // create cluster
       
 List<Tower__c> tList = TestDataFactory.createTowers(4, pro.Id); // create tower
 
 unit1 = new Unit__c();
 List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, pro.Id); // create unit
 unit1 = uList[0];
 
 unit2 = new Unit__c();
 unit2 = uList[1];
 
 projchrg1 = new ProjectCharges__c(); // create projectcharges
 projchrg1.name = 'Basic';
 projchrg1.Active__c = true;
 projchrg1.Project__c = pro.id;
 projchrg1.Calculatedas__c = 'Rate list at Unit level';
 projchrg1.ChargeBucket__c = 'Agreement Value';
 projchrg1.Taxable__c = 67.0;
 projchrg1.SGST__c = 9.0;
 projchrg1.CGST__c = 9.0;
 projchrg1.IGST__c = 0.0;
 insert projchrg1; 
      
 Rate_List__c r = new Rate_List__c();
 r.Unit__c = unit1.Id;   
 r.ProjectCharges__c = projchrg1.Id;    
 r.Area_Type__c = 'Chargeable Area';
 r.Type__c = 'PSF'; 
 r.PSF_rate__c = 1485;
 r.Rate_List_Bucket__c = 'Agreement Value';
 insert r;  
     }
  }